class NewsArticle {
  final String source;
  final String? author;
  final String title;
  final String? description;
  final String url;
  final String? urlToImage;
  final DateTime publishedAt;
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
      source: json['id'] ?? '',
      author: json['author'],
      title: json['title'] ?? '',
      description: json['description'],
      url: json['url'] ?? '',
      urlToImage: json['image'],
      publishedAt: DateTime.tryParse(json['published'] ?? '') ?? DateTime.now(),
      content: json['content'],
    );
  }
}