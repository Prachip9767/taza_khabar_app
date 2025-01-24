import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:taza_khabar_app/models/news_article_model.dart';

class NewsDetailPage extends StatelessWidget {
  final NewsArticle article;

  const NewsDetailPage({super.key, required this.article});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(16)
                        ,bottomRight: Radius.circular(16)),
                    child: CachedNetworkImage(
                      height: 250,
                      width: double.maxFinite,
                      imageUrl: article.urlToImage ?? '',
                      cacheKey: article.urlToImage ?? '',
                      errorWidget: (context, url, error) => const SizedBox(),
                      placeholder: (context, url) => const SizedBox(),
                      fit: BoxFit.fill,
                    ),
                  ),
                  GestureDetector(
                    onTap: (){
                      Navigator.pop(context);
                      FocusScope.of(context).unfocus();
                    },
                    child: const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 10.0,vertical: 16),
                      child: Icon(Icons.arrow_back,color: Colors.white,),
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10.0,vertical: 16),
                    child: Align(
                        alignment: Alignment.topRight,
                        child: Icon(Icons.bookmark,color: Colors.white,)),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.only(left: 10.0,right: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const SizedBox(width: 14,),
                        Container(width: 4,color: Colors.orange,height: 50,),
                        const SizedBox(width: 8,),
                        Expanded(
                          child: Text(
                            maxLines: 2,
                            article.title,
                            style: Theme.of(context).textTheme.headlineMedium?.
                            copyWith(fontWeight: FontWeight.w700,height: 1.1,),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 14.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${article.description?.replaceAll('\n', ' ')} '
                                '${article.description?.replaceAll('\n', ' ')}'
                                '${article.description?.replaceAll('\n', ' ')}'?? 'No description available',
                            style: Theme.of(context).textTheme.bodyMedium?.
                            copyWith(fontWeight: FontWeight.w400,height: 1.2),
                          ),
                          const SizedBox(height: 14),
                          // Text(' Current News',
                          //   style: Theme.of(context).textTheme.bodySmall?.
                          // copyWith(fontWeight: FontWeight.w600),),
                          Text( DateFormat("d MMM y").format(article.publishedAt),
                            style: Theme.of(context).textTheme.bodySmall?.
                            copyWith(fontWeight: FontWeight.w600,color: Colors.black54,
                                fontSize: 12),),
                        ],
                      ),
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
