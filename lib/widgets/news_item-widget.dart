import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:taza_khabar_app/models/news_article_model.dart';
import 'package:taza_khabar_app/utils/app_color.dart';
import 'package:taza_khabar_app/utils/png_images.dart';

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
    double screenHeight = MediaQuery.of(context).size.height;
    double cardHeight = screenHeight * 0.3;

    return Card(
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(8)),
      ),
      margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      child: GestureDetector(
        onTap: onTap,
        child: SizedBox(
          height: cardHeight,
          child: Stack(
            children: [
              _buildBackgroundImage(),
              _buildGradientOverlay(),
              _buildContent(context),
            ],
          ),
        ),
      ),
    );
  }

  // Helper methods for building different parts of the card
  Widget _buildBackgroundImage() {
    return ClipRRect(
      borderRadius: const BorderRadius.all(Radius.circular(8)),
      child: CachedNetworkImage(
        imageUrl: article.urlToImage ?? '',
        cacheKey: article.urlToImage ?? '',
        errorWidget: (context, url, error) =>  Image.asset(AssetsAnnotationPNG().defaultImage,
          fit: BoxFit.cover, ),
        placeholder: (context, url) => Image.asset(AssetsAnnotationPNG().defaultImage,
          fit: BoxFit.cover,),
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
      ),
    );
  }

  Widget _buildGradientOverlay() {
    return Positioned.fill(
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
    );
  }

  Widget _buildContent(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          _buildDate(),
          const SizedBox(height: 4),
          _buildTitle(),
          const SizedBox(height: 4),
          if (article.description?.isNotEmpty ?? false) _buildDescription(),
        ],
      ),
    );
  }

  Widget _buildDate() {
    return Text(
      DateFormat("d MMM y").format(article.publishedAt),
      style: const TextStyle(
        color:  AppColors.white,
        fontSize: 14,
        fontWeight: FontWeight.w400,
      ),
    );
  }

  Widget _buildTitle() {
    return Text(
      article.title,
      maxLines: 2,
      style: const TextStyle(
        color:  AppColors.white,
        fontSize: 18,
        height: 1.1,
        fontWeight: FontWeight.w500,
      ),
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildDescription() {
    return Text(
      article.description!.replaceAll('\n', ' '),
      maxLines: 2,
      style: const TextStyle(
        color: AppColors.white,
        height: 1.1,
        fontSize: 12,
      ),
      overflow: TextOverflow.ellipsis,
    );
  }
}
