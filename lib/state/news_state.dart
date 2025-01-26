import 'package:flutter/material.dart';
import 'package:taza_khabar_app/models/news_article_model.dart';

class NewsState {}

class NewsInitial extends NewsState {}

class NewsLoading extends NewsState {}

class NewsLoaded extends NewsState {
  final List<NewsArticle> articles;
  final bool hasReachedMax;
  final List<String> recentSearches;

  NewsLoaded({required this.articles, required this.hasReachedMax,
    required this.recentSearches,});

  NewsLoaded copyWith({List<NewsArticle>? articles, bool? hasReachedMax}) {
    return NewsLoaded(
      articles: articles ?? this.articles,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      recentSearches: this.recentSearches,
    );
  }
}

class NewsError extends NewsState {
  final String message;
  final VoidCallback onRetry;

  NewsError({required this.message, required this.onRetry});
}

