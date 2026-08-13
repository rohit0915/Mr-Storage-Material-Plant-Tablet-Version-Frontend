import 'package:dio/dio.dart';
import 'package:get/get.dart' as getx;
import '../routes/app_routes.dart';
import '../services/shared_pref_service.dart';
import '../utils/app_constants.dart';
import '../utils/app_logger.dart';
import 'api_endpoints.dart';
import 'exceptions.dart';

class ApiClient {
  late final Dio _dio;

  ApiClient() {
    _dio = Dio(
      BaseOptions(
        baseUrl: AppConstants.baseUrl,
        connectTimeout: const Duration(milliseconds: AppConstants.connectionTimeout),
        receiveTimeout: const Duration(milliseconds: AppConstants.receiveTimeout),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    // Logging Interceptor
    _dio.interceptors.add(LogInterceptor(
      request: true,
      requestHeader: true,
      requestBody: true,
      responseHeader: true,
      responseBody: true,
      error: true,
      logPrint: (obj) => AppLogger.debug(obj.toString()),
    ));

    // Auth & Refresh Token Interceptor
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          if (getx.Get.isRegistered<SharedPrefService>()) {
            final token = getx.Get.find<SharedPrefService>().getToken();
            if (token != null && token.isNotEmpty) {
              options.headers['Authorization'] = 'Bearer $token';
            }
          }
          return handler.next(options);
        },
        onError: (DioException error, handler) async {
          final requestPath = error.requestOptions.path;

          if (error.response?.statusCode == 401) {
            // Avoid infinite retry loops on auth endpoints
            if (requestPath.contains(ApiEndpoints.refreshToken) || requestPath.contains(ApiEndpoints.login)) {
              AppLogger.error('Auth endpoint returned 401. Clearing session...');
              await _logoutAndRedirect();
              return handler.next(error);
            }

            if (getx.Get.isRegistered<SharedPrefService>()) {
              final prefService = getx.Get.find<SharedPrefService>();
              final savedRefreshToken = prefService.getRefreshToken();

              if (savedRefreshToken != null && savedRefreshToken.isNotEmpty) {
                AppLogger.debug('Token expired (401). Attempting automatic refresh using refreshToken...');
                try {
                  final refreshDio = Dio(
                    BaseOptions(
                      baseUrl: AppConstants.baseUrl,
                      connectTimeout: const Duration(milliseconds: AppConstants.connectionTimeout),
                      receiveTimeout: const Duration(milliseconds: AppConstants.receiveTimeout),
                      headers: {'Content-Type': 'application/json'},
                    ),
                  );

                  final refreshResponse = await refreshDio.post(
                    ApiEndpoints.refreshToken,
                    data: {'refreshToken': savedRefreshToken},
                  );

                  if (refreshResponse.data != null && refreshResponse.data['success'] == true) {
                    final newAccessToken = (refreshResponse.data['data']?['accessToken'] ?? '').toString();
                    if (newAccessToken.isNotEmpty) {
                      AppLogger.debug('Token refreshed successfully! Updating session and retrying request...');
                      await prefService.setToken(newAccessToken);

                      final newRefreshToken = refreshResponse.data['data']?['refreshToken']?.toString();
                      if (newRefreshToken != null && newRefreshToken.isNotEmpty) {
                        await prefService.setRefreshToken(newRefreshToken);
                      }

                      // Retry original failed request with new access token
                      final opts = error.requestOptions;
                      opts.headers['Authorization'] = 'Bearer $newAccessToken';
                      final retryResponse = await _dio.fetch(opts);
                      return handler.resolve(retryResponse);
                    }
                  }
                } catch (refreshErr) {
                  AppLogger.error('Refresh token request failed: $refreshErr');
                }
              }
            }

            AppLogger.error('Unauthorized request (401) and refresh token failed. Clearing session...');
            await _logoutAndRedirect();
          }

          return handler.next(error);
        },
      ),
    );
  }

  Future<void> _logoutAndRedirect() async {
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
      return await _dio.get(url, queryParameters: queryParameters, options: options);
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
    try {
      return await _dio.post(url, data: data, queryParameters: queryParameters, options: options);
    } on DioException catch (e) {
      throw AppException.fromDioError(e);
    } catch (e) {
      throw UnknownException(e.toString());
    }
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
      return await _dio.put(url, data: data, queryParameters: queryParameters, options: options);
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
      return await _dio.delete(url, data: data, queryParameters: queryParameters, options: options);
    } on DioException catch (e) {
      throw AppException.fromDioError(e);
    } catch (e) {
      throw UnknownException(e.toString());
    }
  }
}
