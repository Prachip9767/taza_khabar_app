import 'package:dio/dio.dart';
import 'package:taza_khabar_app/models/news_article_model.dart';
import 'package:taza_khabar_app/models/news_model.dart';
import 'package:taza_khabar_app/network/network_service.dart';

/// Repository for fetching news articles from the API
class NewsRepository {
  final NetworkService _networkService;
  static const String _apiKey = 'szkv3Y4XDlOXNR_sMN7_avJQIKo6w3Tm7dy-kDcsPzPehoms';

  /// Constructor taking a NetworkService for making API requests
  NewsRepository(this._networkService);

  /// Fetches news articles by page with configurable parameters
  /// [page] specifies the page number
  /// [pageSize] determines number of articles per page (default 20)
  /// [query] sets language filter (default 'en')
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

      // Validate response and parse news articles
      if (response.statusCode == 200 && response.data != null) {
        final newsResponse = NewsResponse.fromJson(response.data);

        if (newsResponse.articles.isEmpty) {
          throw Exception('No news articles found.');
        }

        return newsResponse.articles;
      } else {
        throw Exception('Failed to load news. Status code: ${response.statusCode}');
      }
    } catch (e) {
      // Handle different types of errors
      if (e is DioException) {
        throw Exception('Network Error: ${e.message}');
      }
      throw Exception('Error fetching news: $e');
    }
  }
}