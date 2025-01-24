import 'dart:io';

import 'package:dio/dio.dart';

class NetworkException implements Exception {
  final String message;
  NetworkException(this.message);

  @override
  String toString() => 'NetworkException: $message';
}

class NetworkService {
  final Dio _dio;

  NetworkService() : _dio = Dio() {
    _initializeDio();
  }

  void _initializeDio() {
    _dio.options = BaseOptions(
      baseUrl: 'https://api.currentsapi.services/',
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
    );

    // Add interceptors for debugging
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        print('Request URL: ${options.uri}');
        return handler.next(options);
      },
      onError: (DioException e, handler) {
        print('Network Error: ${e.message}');
        return handler.next(e);
      },
    ));
  }

  Future<Response> get({
    required String endpoint,
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final response = await _dio.get(
        endpoint,
        queryParameters: queryParameters,
      );
      return response;
    } on DioException catch (e) {
      String errorMessage = 'Unknown error occurred';

      // Checking DioException based on the available fields
      if (e.error is SocketException) {
        errorMessage = 'Network error: No Internet connection';
      } else if ((e.message??'').contains("timeout")) {
        errorMessage = 'Connection timed out';
      } else if (e.response != null) {
        errorMessage = 'Server responded with status: ${e.response?.statusCode}';
      } else if (e.error != null) {
        errorMessage = 'Network error: ${e.error}';
      }

      throw NetworkException(errorMessage);
    }
  }
}
