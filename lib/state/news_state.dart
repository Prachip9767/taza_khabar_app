import 'package:flutter/material.dart';
import 'package:taza_khabar_app/models/news_article_model.dart';

/// Base abstract class for news-related states
abstract class NewsState {}

/// Initial state when no news has been loaded
class NewsInitial extends NewsState {}

/// State representing news loading in progress
class NewsLoading extends NewsState {}

/// State representing successfully loaded news
class NewsLoaded extends NewsState {
  final List<NewsArticle> articles;
  final bool hasReachedMax;
  final List<String> recentSearches;
  final bool showScrollToTop;

  NewsLoaded({
    required this.articles,
    required this.hasReachedMax,
    required this.recentSearches,
    this.showScrollToTop = false,
  });

  NewsLoaded copyWith({
    List<NewsArticle>? articles,
    bool? hasReachedMax,
    List<String>? recentSearches,
    bool? showScrollToTop,
  }) {
    return NewsLoaded(
      articles: articles ?? this.articles,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      recentSearches: recentSearches ?? this.recentSearches,
      showScrollToTop: showScrollToTop ?? this.showScrollToTop,
    );
  }
}

/// State representing an error during news loading
class NewsError extends NewsState {
  final String message;
  final VoidCallback onRetry;

  /// Constructor for NewsError state
  NewsError({required this.message, required this.onRetry});
}