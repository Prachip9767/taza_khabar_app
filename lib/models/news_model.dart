class NewsResponse {
  final String status;
  // final int totalResults;
  final List<NewsArticle> articles;

  NewsResponse({
    required this.status,
    // required this.totalResults,
    required this.articles,
  });

  factory NewsResponse.fromJson(Map<String, dynamic> json) {
    return NewsResponse(
      status: json['status'] ?? '',
      // totalResults: json['totalResults'] ?? 0,
      articles: (json['news'] as List?)
          ?.map((articleJson) => NewsArticle.fromJson(articleJson))
          .toList() ?? [],
    );
  }
}

class NewsArticle {
  final String source;
  final String? author;
  final String title;
  final String? description;
  final String url;
  final String? urlToImage;
  final String publishedAt;
  final String? content;
  final List<String> category;

  NewsArticle( {
    required this.category,
    required this.source,
    this.author,
    required this.title,
    this.description,
    required this.url,
    this.urlToImage,
    required this.publishedAt,
    this.content,
  });

  factory NewsArticle.fromJson(Map<String, dynamic> json) {
    return NewsArticle(
      category: (json['category'] as List<dynamic>?)
          ?.map((category) => category as String)
          .toList() ??
          [],
      // source: NewsSource.fromJson(json['source'] ?? {}),
      // author: json['author'],
      // title: json['title'] ?? '',
      // description: json['description'],
      // url: json['url'] ?? '',
      // urlToImage: json['urlToImage'],
      // publishedAt: json['publishedAt'] ?? '',
      // content: json['content'],
      source: json['id'] ?? '',
      author: json['author'],
      title: json['title'] ?? '',
      description: json['description'],
      url: json['url'] ?? '',
      urlToImage: json['image'],
      publishedAt: json['published'] ?? '',
      content: json['content'],
    );
  }
}

class NewsSource {
  final String? id;
  final String name;

  NewsSource({this.id, required this.name});

  factory NewsSource.fromJson(Map<String, dynamic> json) {
    return NewsSource(
      id: json['id'],
      name: json['name'] ?? 'Unknown Source',
    );
  }
}