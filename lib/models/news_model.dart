import 'package:taza_khabar_app/models/news_article_model.dart';

class NewsResponse {
  final String status;
  final List<NewsArticle> articles;

  NewsResponse({
    required this.status,
    required this.articles,
  });

  factory NewsResponse.fromJson(Map<String, dynamic> json) {
    return NewsResponse(
      status: json['status'] ?? '',
      articles: (json['news'] as List?)
          ?.map((articleJson) => NewsArticle.fromJson(articleJson))
          .toList() ?? [],
    );
  }
}