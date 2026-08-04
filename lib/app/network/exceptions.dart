import 'package:dio/dio.dart';
import '../utils/app_strings.dart';

abstract class AppException implements Exception {
  final String message;

  AppException(this.message);

  factory AppException.fromDioError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return TimeoutException(AppStrings.errorTimeout);
      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode;
        if (statusCode == 401 || statusCode == 403) {
          return UnauthorizedException(AppStrings.errorUnauthorized);
        }
        return ServerException('Server error: $statusCode');
      case DioExceptionType.connectionError:
        return NetworkException(AppStrings.errorInternet);
      case DioExceptionType.cancel:
      case DioExceptionType.unknown:
      case DioExceptionType.badCertificate:
      default:
        return UnknownException(AppStrings.errorUnknown);
    }
  }

  @override
  String toString() => message;
}

class TimeoutException extends AppException {
  TimeoutException(super.message);
}

class UnauthorizedException extends AppException {
  UnauthorizedException(super.message);
}

class ServerException extends AppException {
  ServerException(super.message);
}

class NetworkException extends AppException {
  NetworkException(super.message);
}

class UnknownException extends AppException {
  UnknownException(super.message);
}
