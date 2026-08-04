import 'package:dio/dio.dart';
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

    _dio.interceptors.add(LogInterceptor(
      request: true,
      requestHeader: true,
      requestBody: true,
      responseHeader: true,
      responseBody: true,
      error: true,
      logPrint: (obj) => AppLogger.debug(obj.toString()),
    ));
    
    // Add auth interceptor if needed
    // _dio.interceptors.add(InterceptorsWrapper(
    //   onRequest: (options, handler) async {
    //     // String token = await sharedPrefService.getToken();
    //     // options.headers['Authorization'] = 'Bearer $token';
    //     return handler.next(options);
    //   },
    // ));
  }

  Future<Response> get(String url, {Map<String, dynamic>? queryParameters, Options? options}) async {
    try {
      return await _dio.get(url, queryParameters: queryParameters, options: options);
    } on DioException catch (e) {
      throw AppException.fromDioError(e);
    } catch (e) {
      throw UnknownException(e.toString());
    }
  }

  Future<Response> post(String url, {dynamic data, Map<String, dynamic>? queryParameters, Options? options}) async {
    try {
      return await _dio.post(url, data: data, queryParameters: queryParameters, options: options);
    } on DioException catch (e) {
      throw AppException.fromDioError(e);
    } catch (e) {
      throw UnknownException(e.toString());
    }
  }

  Future<Response> put(String url, {dynamic data, Map<String, dynamic>? queryParameters, Options? options}) async {
    try {
      return await _dio.put(url, data: data, queryParameters: queryParameters, options: options);
    } on DioException catch (e) {
      throw AppException.fromDioError(e);
    } catch (e) {
      throw UnknownException(e.toString());
    }
  }

  Future<Response> delete(String url, {dynamic data, Map<String, dynamic>? queryParameters, Options? options}) async {
    try {
      return await _dio.delete(url, data: data, queryParameters: queryParameters, options: options);
    } on DioException catch (e) {
      throw AppException.fromDioError(e);
    } catch (e) {
      throw UnknownException(e.toString());
    }
  }
}
