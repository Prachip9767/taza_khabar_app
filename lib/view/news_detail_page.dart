import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:taza_khabar_app/models/news_article_model.dart';
import 'package:taza_khabar_app/utils/app_color.dart';
import 'package:taza_khabar_app/utils/png_images.dart';

/// Detailed page displaying a single news article
class NewsDetailPage extends StatelessWidget {
  /// News article to be displayed
  final NewsArticle article;

  const NewsDetailPage({super.key, required this.article});

  @override
  Widget build(BuildContext context) {
    // Calculate screen dimensions for responsive design
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;
    double imageHeight = screenHeight * 0.35;

    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Article image with back and bookmark icons
          Stack(
            children: [
              // Cached network image with error and placeholder handling
              ClipRRect(
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(16),
                  bottomRight: Radius.circular(16),
                ),
                child: CachedNetworkImage(
                  height: imageHeight,
                  width: double.infinity,
                  imageUrl: article.urlToImage ?? '',
                  cacheKey: article.urlToImage ?? '',
                  errorWidget: (context, url, error) =>
                      Image.asset(AssetsAnnotationPNG().defaultImage,
                        fit: BoxFit.cover, ),
                  placeholder: (context, url) =>
                      Image.asset(AssetsAnnotationPNG().defaultImage,
                        fit: BoxFit.cover,  ),
                  fit: BoxFit.cover,
                ),
              ),
              // Back button with navigation and keyboard dismissal
              GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                  FocusScope.of(context).unfocus();
                },
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: screenWidth * 0.05,
                    vertical: screenHeight * 0.05,
                  ),
                  child: const Icon(Icons.arrow_back, color:AppColors.white),
                ),
              ),
              // Bookmark icon
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: screenWidth * 0.05,
                  vertical: screenHeight * 0.05,
                ),
                child: const Align(
                  alignment: Alignment.topRight,
                  child: Icon(Icons.bookmark, color: AppColors.white),
                ),
              ),
            ],
          ),
          // Scrollable article content
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: screenWidth * 0.05,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: screenHeight * 0.03),
                    // Article title with accent bar
                    Row(
                      children: [
                        Container(
                          width: screenWidth * 0.01,
                          color: AppColors.accent,
                          height: screenHeight * 0.075,
                        ),
                        SizedBox(width: screenWidth * 0.02),
                        Expanded(
                          child: Text(
                            article.title,
                            maxLines: 2,
                            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                              height: 1.1,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: screenHeight * 0.04),
                    // Article description
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.04),
                      child: Text(
                        '${article.description?.replaceAll('\n', ' ')}'
                            '${article.description?.replaceAll('\n', ' ')}',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w400,
                          height: 1.5,
                        ),
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.03),
                    // Publication date
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.04),
                      child: Text(
                        DateFormat("d MMM y").format(article.publishedAt),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppColors.black54,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    const SizedBox(height: 50,)
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}