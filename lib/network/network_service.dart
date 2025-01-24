import 'package:dio/dio.dart';

class NetworkException implements Exception {
  final String message;
  NetworkException(this.message);
}

class NetworkService {
  final Dio _dio;

  NetworkService() : _dio = Dio() {
    _initializeDio();
  }
  // https://api.currentsapi.services/v1/latest-news?language=en&apiKey=szkv3Y4XDlOXNR_sMN7_avJQIKo6w3Tm7dy-kDcsPzPehoms
  void _initializeDio() {
    _dio.options = BaseOptions(
      baseUrl: 'https://api.currentsapi.services/',
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
    );

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
      throw NetworkException(e.message ?? 'Network Error');
    }
  }
}