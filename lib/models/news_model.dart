import 'package:taza_khabar_app/models/news_article_model.dart';

/// Represents the response from a news API
class NewsResponse {
  final String status;
  final List<NewsArticle> articles;

  /// Constructor for creating a NewsResponse instance
  NewsResponse({
    required this.status,
    required this.articles,
  });

  /// Factory method to parse JSON into a NewsResponse object
  /// Handles potential null values with default empty list for articles
  factory NewsResponse.fromJson(Map<String, dynamic> json) {
    return NewsResponse(
      status: json['status'] ?? '',
      articles: (json['news'] as List?)
          ?.map((articleJson) => NewsArticle.fromJson(articleJson))
          .toList() ?? [],
    );
  }
}