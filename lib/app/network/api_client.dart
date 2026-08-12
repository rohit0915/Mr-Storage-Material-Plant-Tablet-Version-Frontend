import 'package:dio/dio.dart';
import 'package:get/get.dart' as getx;
import '../routes/app_routes.dart';
import '../services/shared_pref_service.dart';
import '../utils/app_constants.dart';
import '../utils/app_logger.dart';
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

    // Auth & Token Expiration Interceptor
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
          if (error.response?.statusCode == 401) {
            AppLogger.error('Unauthorized request (401). Clearing session...');
            if (getx.Get.isRegistered<SharedPrefService>()) {
              await getx.Get.find<SharedPrefService>().clearSession();
            }
            if (getx.Get.currentRoute != AppRoutes.login) {
              getx.Get.offAllNamed(AppRoutes.login);
            }
          }
          return handler.next(error);
        },
      ),
    );
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
