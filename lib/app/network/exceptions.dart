import 'package:dio/dio.dart';
import '../utils/app_strings.dart';

abstract class AppException implements Exception {
  final String message;

  AppException(this.message);

  factory AppException.fromDioError(DioException error) {
    String? serverMessage;
    final responseData = error.response?.data;
    if (responseData != null) {
      if (responseData is Map) {
        final rawMsg = responseData['message']?.toString();
        final rawErr = responseData['error']?.toString();
        final details =
            responseData['errors'] ?? responseData['details'] ?? responseData['data'];
        if (details is List && details.isNotEmpty) {
          final detailStr = details
              .map((d) => d is Map
                  ? (d['message'] ?? d['msg'] ?? d['error'] ?? d.toString())
                  : d.toString())
              .join(', ');
          serverMessage = (rawMsg != null && rawMsg.isNotEmpty)
              ? '$rawMsg: $detailStr'
              : detailStr;
        } else if (details is Map && details.isNotEmpty) {
          final detailStr = details.values
              .map((v) => v is Map
                  ? (v['message'] ?? v['msg'] ?? v.toString())
                  : v.toString())
              .join(', ');
          serverMessage = (rawMsg != null && rawMsg.isNotEmpty)
              ? '$rawMsg: $detailStr'
              : detailStr;
        } else {
          serverMessage = rawMsg ?? rawErr;
        }
      } else if (responseData is String && responseData.isNotEmpty) {
        serverMessage = responseData;
      }
    }

    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return TimeoutException(AppStrings.errorTimeout);
      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode;
        final msg = (serverMessage != null && serverMessage.isNotEmpty)
            ? serverMessage
            : (statusCode == 401 || statusCode == 403
                ? AppStrings.errorUnauthorized
                : 'Server error: $statusCode');
        if (statusCode == 401 || statusCode == 403) {
          return UnauthorizedException(msg);
        }
        return ServerException(msg);
      case DioExceptionType.connectionError:
        return NetworkException(AppStrings.errorInternet);
      case DioExceptionType.cancel:
      case DioExceptionType.unknown:
      case DioExceptionType.badCertificate:
      default:
        return UnknownException(
          (serverMessage != null && serverMessage.isNotEmpty)
              ? serverMessage
              : AppStrings.errorUnknown,
        );
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
