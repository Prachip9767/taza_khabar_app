import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:taza_khabar_app/models/news_article_model.dart';

class NewsArticleItem extends StatelessWidget {
  final NewsArticle article;
  final VoidCallback onTap;

  const NewsArticleItem({
    super.key,
    required this.article,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(8)), // Set circular radius
      ),
      margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      child: GestureDetector(
        onTap: onTap,
        child: SizedBox(
          height: 200,
          child: Stack(
            children: [
              // Background Image
              ClipRRect(
                borderRadius: const BorderRadius.all(Radius.circular(8)),
                child: CachedNetworkImage(
                  imageUrl: article.urlToImage ?? '',
                  cacheKey: article.urlToImage ?? '',
                  errorWidget: (context, url, error) => const SizedBox(),
                  placeholder: (context, url) => const SizedBox(),
                  fit: BoxFit.cover, // Ensures the image covers the area
                  width: double.infinity,
                  height: double.infinity, // Matches the parent's constraints
                ),
              ),
              // Gradient shadow overlay (bottom to middle)
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    gradient: LinearGradient(
                      colors: [
                        Colors.black.withOpacity(0.9),
                        Colors.black.withOpacity(0.9),
                        Colors.black.withOpacity(0.9),
                        Colors.black.withOpacity(0.3),
                      ],
                      begin: Alignment.bottomCenter,
                      end: Alignment.center,
                    ),
                  ),
                ),
              ),
              // Content
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      '${DateFormat("d MMM y").format(article.publishedAt)}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      article.title,
                      maxLines: 2,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        height: 1.1,
                        fontWeight: FontWeight.w500,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    if (article.description != null && (article.description ?? '').isNotEmpty)
                      Text(
                        article.description!.replaceAll('\n', ' '),
                        maxLines: 2,
                        style: const TextStyle(
                          color: Colors.white,
                          height: 1.1,
                          fontSize: 12,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );

  }
}
