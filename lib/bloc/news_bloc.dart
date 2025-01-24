// News BLoC
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:taza_khabar_app/events/news_events.dart';
import 'package:taza_khabar_app/models/news_article_model.dart';
import 'package:taza_khabar_app/repository/news_repository.dart';
import 'package:taza_khabar_app/state/news_state.dart';
// BLoC
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:taza_khabar_app/events/news_events.dart';
import 'package:taza_khabar_app/models/news_article_model.dart';
import 'package:taza_khabar_app/repository/news_repository.dart';
import 'package:taza_khabar_app/state/news_state.dart';

class NewsBloc extends Bloc<NewsEvent, NewsState> {
  final NewsRepository _repository;
  final TextEditingController searchController = TextEditingController();
  final ScrollController scrollController = ScrollController();

  // Keep the list of all articles and filtered articles
  List<NewsArticle> _allArticles = [];
  List<NewsArticle> _filteredArticles = [];

  // Pagination control
  int _currentPage = 1;
  static const int _pageSize = 20;

  // Search query tracking
  String _currentSearchQuery = '';

  NewsBloc(this._repository) : super(NewsInitial()) {
    on<FetchNews>(_onFetchNews);
    on<LoadMoreNews>(_onLoadMoreNews);
    on<SearchNews>(_onSearchNews);

    // Scroll listener for loading more news when scrolled near the bottom
    scrollController.addListener(_onScroll);
  }

  // Fetch the initial set of news articles
  Future<void> _onFetchNews(FetchNews event, Emitter<NewsState> emit) async {
    emit(NewsLoading());
    try {
      _currentPage = 1;
      _allArticles = await _repository.fetchNewsByPage(
        page: _currentPage,
        pageSize: _pageSize,
        query: 'en', // Always fetch in English
      );
      _filteredArticles = List.from(_allArticles);  // Initially show all articles
      emit(NewsLoaded(
        articles: _filteredArticles,
        hasReachedMax: _filteredArticles.length < _pageSize,
      ));
    } catch (e) {
      emit(NewsError(e.toString()));
    }
  }

  // Handle loading more news when the user scrolls to the bottom
  Future<void> _onLoadMoreNews(LoadMoreNews event, Emitter<NewsState> emit) async {
    if (state is! NewsLoaded) return;

    final currentState = state as NewsLoaded;
    if (currentState.hasReachedMax) return;

    try {
      _currentPage++;
      final nextPage = await _repository.fetchNewsByPage(
        page: _currentPage,
        pageSize: _pageSize,
        query: 'en',
      );

      if (nextPage.isEmpty) {
        emit(currentState.copyWith(hasReachedMax: true));
      } else {
        _allArticles.addAll(nextPage);  // Append new articles to the existing list
        _filteredArticles = _applySearchFilter(_allArticles);
        emit(NewsLoaded(
          articles: _filteredArticles,
          hasReachedMax: nextPage.length < _pageSize,
        ));
      }
    } catch (e) {
      emit(NewsError(e.toString()));
    }
  }

  // Handle searching for news
  Future<void> _onSearchNews(SearchNews event, Emitter<NewsState> emit) async {
    final query = event.query?.trim() ?? '';

    if (_currentSearchQuery == query) return; // Avoid unnecessary reload if the query hasn't changed

    _currentSearchQuery = query;
    emit(NewsLoading());

    try {
      _filteredArticles = query.isEmpty
          ? List.from(_allArticles) // Show all if no query
          : _applySearchFilter(_allArticles);

      emit(NewsLoaded(
        articles: _filteredArticles,
        hasReachedMax: _filteredArticles.length < _pageSize,
      ));
    } catch (e) {
      emit(NewsError(e.toString()));
    }
  }

  // Apply search filters to the articles
  List<NewsArticle> _applySearchFilter(List<NewsArticle> articles) {
    final searchQuery = _currentSearchQuery.toLowerCase();
    return articles.where((article) {
      final lowerCaseTitle = article.title.toLowerCase();
      final categoryMatch = article.category.any(
            (category) => category.toLowerCase().contains(searchQuery),
      );
      return lowerCaseTitle.contains(searchQuery) || categoryMatch;
    }).toList();
  }

  // Scroll listener for fetching more data when nearing the bottom
  void _onScroll() {
    if (scrollController.position.pixels >= scrollController.position.maxScrollExtent - 100) {
      add(LoadMoreNews());
    }
  }

  @override
  Future<void> close() {
    searchController.dispose();
    scrollController.dispose();
    return super.close();
  }
}






