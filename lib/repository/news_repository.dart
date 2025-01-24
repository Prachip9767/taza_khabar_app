import 'package:taza_khabar_app/models/news_article_model.dart';
import 'package:taza_khabar_app/network/network_service.dart';

import '../models/news_model.dart';

class NewsRepository {
  final NetworkService _networkService;
  static const String _apiKey = 'szkv3Y4XDlOXNR_sMN7_avJQIKo6w3Tm7dy-kDcsPzPehoms';

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

      if (response.statusCode == 200) {
        final newsResponse = NewsResponse.fromJson(response.data);
        return newsResponse.articles;
      } else {
        throw Exception('Failed to load news: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching news: $e');
    }
  }
}



