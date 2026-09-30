import 'package:dio/dio.dart';
import 'package:get/get.dart' as getx;
import '../routes/app_routes.dart';
import '../services/shared_pref_service.dart';
import '../services/plant_socket_service.dart';
import '../utils/app_constants.dart';
import 'api_endpoints.dart';
import 'exceptions.dart';
import '../utils/app_logger.dart';
import 'dart:convert';

class ApiClient {
  late final Dio _dio;
  Future<String?>? _refreshInFlight;
  Future<void>? _logoutInFlight;

  ApiClient({Dio? dio}) {
    _dio = dio ?? Dio(
      BaseOptions(
        baseUrl: AppConstants.baseUrl,
        connectTimeout: const Duration(
          milliseconds: AppConstants.connectionTimeout,
        ),
        receiveTimeout: const Duration(
          milliseconds: AppConstants.receiveTimeout,
        ),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    // Auth & Refresh Token Interceptor
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          if (!_isPublicAuth(options.path) && getx.Get.isRegistered<SharedPrefService>()) {
            final token = getx.Get.find<SharedPrefService>().getToken();
            if (token != null && token.isNotEmpty) {
              options.headers['Authorization'] = 'Bearer $token';
            }
          }
          return handler.next(options);
        },
        onError: (DioException error, handler) async {
          if (error.response?.statusCode != 401 ||
              _isPublicAuth(error.requestOptions.path)) {
            return handler.next(error);
          }
          final prefs = getx.Get.isRegistered<SharedPrefService>()
              ? getx.Get.find<SharedPrefService>() : null;
          if (error.requestOptions.extra['authRetried'] == true) {
            await _expireSession();
            return handler.next(error);
          }
          try {
            final currentToken = prefs?.getToken();
            final sentToken = error.requestOptions.headers['Authorization'];
            final token = currentToken != null && currentToken.isNotEmpty &&
                    sentToken != 'Bearer $currentToken'
                ? currentToken
                : await _refreshToken();
            if (token == null) {
              await _expireSession();
            } else {
              final options = error.requestOptions;
              options.extra['authRetried'] = true;
              options.headers['Authorization'] = 'Bearer $token';
              return handler.resolve(await _dio.fetch(options));
            }
          } on DioException catch (refreshError) {
            // A temporary refresh outage is not evidence that the session expired.
            if (refreshError.response?.statusCode == 401 ||
                refreshError.response?.statusCode == 403) {
              await _expireSession();
            }
            return handler.next(refreshError);
          } catch (_) {
            await _expireSession();
          }

          return handler.next(error);
        },
      ),
    );
  }

  bool _isPublicAuth(String path) => {
    ApiEndpoints.login, ApiEndpoints.refreshToken, ApiEndpoints.forgotPassword,
    ApiEndpoints.verifyOtp, ApiEndpoints.resetPassword,
  }.contains(path.replaceFirst(RegExp(r'^/'), ''));

  Future<String?> _refreshToken() async {
    if (_refreshInFlight != null) return _refreshInFlight!;
    final future = _performRefresh();
    _refreshInFlight = future;
    try {
      return await future;
    } finally {
      if (identical(_refreshInFlight, future)) _refreshInFlight = null;
    }
  }

  Future<String?> _performRefresh() async {
    if (!getx.Get.isRegistered<SharedPrefService>()) return null;
    final prefs = getx.Get.find<SharedPrefService>();
    final refreshToken = prefs.getRefreshToken();
    if (refreshToken == null || refreshToken.isEmpty) return null;
    final response = await _dio.post(ApiEndpoints.refreshToken,
        data: {'refreshToken': refreshToken});
    final body = response.data;
    final data = body is Map ? body['data'] : null;
    final token = data is Map ? data['accessToken'] : null;
    if (token is! String || token.isEmpty) return null;
    // Do not revive a session that was logged out while refresh was in flight.
    if (prefs.getRefreshToken() != refreshToken) return null;
    await prefs.setToken(token);
    final rotated = data['refreshToken'];
    if (rotated is String && rotated.isNotEmpty) {
      await prefs.setRefreshToken(rotated);
    }
    if (getx.Get.isRegistered<PlantSocketService>()) {
      getx.Get.find<PlantSocketService>().reconnectWithLatestToken();
    }
    return token;
  }

  Future<void> _expireSession() async {
    if (_logoutInFlight != null) return _logoutInFlight!;
    final future = _logoutAndRedirect();
    _logoutInFlight = future;
    try { await future; } finally { _logoutInFlight = null; }
  }

  Future<void> _logoutAndRedirect() async {
    if (getx.Get.isRegistered<PlantSocketService>()) {
      getx.Get.find<PlantSocketService>().disconnect();
    }
    if (getx.Get.isRegistered<SharedPrefService>()) {
      await getx.Get.find<SharedPrefService>().clearSession();
    }
    if (getx.Get.currentRoute != AppRoutes.login) {
      getx.Get.offAllNamed(AppRoutes.login);
    }
  }

  Future<Response> get(
    String url, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.get(
        url,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException catch (e) {
      throw AppException.fromDioError(e);
    } catch (e) {
      throw UnknownException(e.toString());
    }
  }

  Future<Response> post(
    String url, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    final traceShipperOrder = RegExp(r'^/?plant/projects/[^/]+/consolidated-bom/send$').hasMatch(url);
    final traceId = DateTime.now().microsecondsSinceEpoch.toString();
    final timer = Stopwatch()..start();
    void logResponse(dynamic body, int? status) {
      if (!traceShipperOrder) return;
      AppLogger.info('[ShipperOrder:$traceId] response status=$status '
          'elapsedMs=${timer.elapsedMilliseconds} body=${jsonEncode(_safeDiagnostic(body))}');
    }
    if (traceShipperOrder) {
      AppLogger.info('[ShipperOrder:$traceId] POST $url '
          'payload=${jsonEncode(_safeDiagnostic(data))}');
    }
    try {
      final response = await _dio.post(
        url,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
      logResponse(response.data, response.statusCode);
      return response;
    } on DioException catch (e) {
      logResponse(e.response?.data, e.response?.statusCode);
      if (traceShipperOrder) {
        AppLogger.warning('[ShipperOrder:$traceId] transport=${e.type.name}');
      }
      throw AppException.fromDioError(e);
    } catch (e) {
      throw UnknownException(e.toString());
    }
  }

  static dynamic _safeDiagnostic(dynamic value) {
    if (value is Map) {
      return value.map((key, item) => MapEntry(key.toString(),
          RegExp(r'token|password|authorization|cookie|secret|url', caseSensitive: false)
                  .hasMatch(key.toString())
              ? '[REDACTED]'
              : _safeDiagnostic(item)));
    }
    if (value is List) return value.map(_safeDiagnostic).toList();
    return value;
  }

  Future<Response> postMultipart(
    String url, {
    required FormData formData,
    Map<String, dynamic>? queryParameters,
    Options? options,
    void Function(int, int)? onSendProgress,
  }) async {
    try {
      return await _dio.post(
        url,
        data: formData,
        queryParameters: queryParameters,
        options: options,
        onSendProgress: onSendProgress,
      );
    } on DioException catch (e) {
      throw AppException.fromDioError(e);
    } catch (e) {
      throw UnknownException(e.toString());
    }
  }

  Future<Response> put(
    String url, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.put(
        url,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException catch (e) {
      throw AppException.fromDioError(e);
    } catch (e) {
      throw UnknownException(e.toString());
    }
  }

  Future<Response> putExternal(
    String url, {
    required dynamic data,
    required String contentType,
    void Function(int, int)? onSendProgress,
  }) async {
    try {
      return await Dio().put(
        url,
        data: data,
        options: Options(
          contentType: contentType,
          headers: {'Content-Type': contentType},
        ),
        onSendProgress: onSendProgress,
      );
    } on DioException catch (e) {
      throw AppException.fromDioError(e);
    } catch (e) {
      throw UnknownException(e.toString());
    }
  }

  Future<Response> patch(
    String url, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.patch(
        url,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException catch (e) {
      throw AppException.fromDioError(e);
    } catch (e) {
      throw UnknownException(e.toString());
    }
  }

  Future<Response> delete(
    String url, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.delete(
        url,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException catch (e) {
      throw AppException.fromDioError(e);
    } catch (e) {
      throw UnknownException(e.toString());
    }
  }
}
