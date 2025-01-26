import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:taza_khabar_app/models/news_article_model.dart';
import 'package:taza_khabar_app/utils/png_images.dart';

class NewsDetailPage extends StatelessWidget {
  final NewsArticle article;

  const NewsDetailPage({super.key, required this.article});

  @override
  Widget build(BuildContext context) {
    // Get the screen height and width
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;
    double imageHeight = screenHeight * 0.35;

    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(16),
                  bottomRight: Radius.circular(16),
                ),
                child: CachedNetworkImage(
                  height: imageHeight, // Dynamic height for image
                  width: double.infinity,
                  imageUrl: article.urlToImage ?? '',
                  cacheKey: article.urlToImage ?? '',
                  errorWidget: (context, url, error) =>  Image.asset(AssetsAnnotationPNG().defaultImage,
                    fit: BoxFit.cover, ),
                  placeholder: (context, url) => Image.asset(AssetsAnnotationPNG().defaultImage,
                    fit: BoxFit.cover,  ),
                  fit: BoxFit.cover,
                ),
              ),
              GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                  // Close the keyboard when popping the page
                  FocusScope.of(context).unfocus();
                },
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: screenWidth * 0.05,
                    vertical: screenHeight * 0.05,
                  ),
                  child: const Icon(Icons.arrow_back, color: Colors.white),
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: screenWidth * 0.05,
                  vertical: screenHeight * 0.05,
                ),
                child: const Align(
                  alignment: Alignment.topRight,
                  child: Icon(Icons.bookmark, color: Colors.white),
                ),
              ),
            ],
          ),
          // Content section (scrollable)
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
                    Row(
                      children: [
                        Container(
                          width: screenWidth * 0.01,
                          color: Colors.orange,
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
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.04),
                      child: Text(
                        '${article.description?.replaceAll('\n', ' ')}'
                            '${article.description?.replaceAll('\n', ' ')}' ??
                            'No description available',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w400,
                          height: 1.5,
                        ),
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.03),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.04),
                      child: Text(
                        DateFormat("d MMM y").format(article.publishedAt),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: Colors.black54,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    SizedBox(height: 50,)
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
