import 'package:dio/dio.dart';
import 'package:taza_khabar_app/models/news_article_model.dart';
import 'package:taza_khabar_app/network/network_service.dart';
import 'package:taza_khabar_app/models/news_model.dart';

class NewsRepository {
  final NetworkService _networkService;
  static const String _apiKey = 'szkv3Y4XDlOXNR_sMN7_avJQIKo6w3Tm7dy-kDcsPzPehoms'; // Move to a more secure storage method later

  NewsRepository(this._networkService);

  /// Fetches news articles from the API for a specific page and page size
  Future<List<NewsArticle>> fetchNewsByPage({
    required int page,
    int pageSize = 20,
    String query = 'en',
  }) async {
    try {
      final response = await _networkService.get(
        endpoint: 'v1/latest-news',
        queryParameters: {
          'language': query,
          'apiKey': _apiKey,
          'page': page.toString(),
          'pageSize': pageSize.toString(),
        },
      );

      // Check if the response is successful
      if (response.statusCode == 200 && response.data != null) {
        final newsResponse = NewsResponse.fromJson(response.data);

        // Ensure articles are returned
        if (newsResponse.articles.isEmpty) {
          throw Exception('No news articles found.');
        }

        return newsResponse.articles;
      } else {
        throw Exception('Failed to load news. Status code: ${response.statusCode}');
      }
    } catch (e) {
      // Add more detailed error handling
      if (e is DioException) {
        throw Exception('Network Error: ${e.message}');
      }
      throw Exception('Error fetching news: $e');
    }
  }
}
