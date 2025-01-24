import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:taza_khabar_app/models/news_article_model.dart';

class NewsDetailPage extends StatelessWidget {
  final NewsArticle article;

  const NewsDetailPage({super.key, required this.article});

  @override
  Widget build(BuildContext context) {
    // Get the screen height and width
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;
    double imageHeight = screenHeight * 0.35; // 35% of screen height for the image

    return SafeArea(
      child: Scaffold(
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image section (non-scrollable)
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
                    errorWidget: (context, url, error) => const Icon(Icons.error, color: Colors.red),
                    placeholder: (context, url) => const Center(child: CircularProgressIndicator()),
                    fit: BoxFit.cover,
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                    FocusScope.of(context).unfocus();
                  },
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: screenWidth * 0.05, // 5% of screen width for padding
                      vertical: screenHeight * 0.03, // 3% of screen height for vertical padding
                    ),
                    child: const Icon(Icons.arrow_back, color: Colors.white),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: screenWidth * 0.05, // 5% of screen width for padding
                    vertical: screenHeight * 0.03, // 3% of screen height for vertical padding
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
                    horizontal: screenWidth * 0.05, // 5% of screen width for padding
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: screenHeight * 0.03), // 3% of screen height
                      Row(
                        children: [
                          Container(
                            width: screenWidth * 0.01, // 1% of screen width for line
                            color: Colors.orange,
                            height: screenHeight * 0.075, // 12% of screen height for line height
                          ),
                          SizedBox(width: screenWidth * 0.02), // 2% of screen width
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
                      SizedBox(height: screenHeight * 0.04), // 4% of screen height
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
                      SizedBox(height: screenHeight * 0.03), // 3% of screen height
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
      ),
    );
  }
}
