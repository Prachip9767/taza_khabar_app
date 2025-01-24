import 'package:taza_khabar_app/network/network_service.dart';

import '../models/news_model.dart';


// class NewsRepository {
//   final NetworkService _networkService;
//   // static const String _apiKey = 'f8eb191d756b4cabaeafb1018fc825bc';
//   static const String _apiKey = 'szkv3Y4XDlOXNR_sMN7_avJQIKo6w3Tm7dy-kDcsPzPehoms';
//
//   NewsRepository(this._networkService);
//
//   Future<NewsResponse> getTopHeadlines({
//     String query = 'en',
//     // String query = 'apple',
//     // String fromDate = '2025-01-22',
//     // String toDate = '2025-01-22',
//     // String sortBy = 'popularity',
//     int page = 1,
//     int pageSize = 20,
//   }) async {
//     final response = await _networkService.get(
//       endpoint: 'v1/latest-news?language=en&apiKey=szkv3Y4XDlOXNR_sMN7_avJQIKo6w3Tm7dy-kDcsPzPehoms',
//       queryParameters: {
//         'language':query,
//         // 'q': query,
//         // 'from': fromDate,
//         // 'to': toDate,
//         // 'sortBy': sortBy,
//         'page': page,
//         'pageSize': pageSize,
//         'apiKey': _apiKey,
//       },
//     );
//
//     return NewsResponse.fromJson(response.data);
//   }
// }


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



