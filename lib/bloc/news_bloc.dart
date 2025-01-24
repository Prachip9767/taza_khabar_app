// News BLoC
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:taza_khabar_app/events/news_events.dart';
import 'package:taza_khabar_app/models/news_article_model.dart';
import 'package:taza_khabar_app/repository/news_repository.dart';
import 'package:taza_khabar_app/state/news_state.dart';
// BLoC
import 'dart:async';
class NewsBloc extends Bloc<NewsEvent, NewsState> {
  final NewsRepository _repository;
  final TextEditingController searchController = TextEditingController();
  final ScrollController scrollController = ScrollController();

  List<NewsArticle> _allArticles = [];
  List<NewsArticle> _filteredArticles = [];
  int _currentPage = 1;
  static const int _pageSize = 20;
  String _currentSearchQuery = '';

  NewsBloc(this._repository) : super(NewsInitial()) {
    on<FetchNews>(_onFetchNews);
    on<LoadMoreNews>(_onLoadMoreNews);
    on<SearchNews>(_onSearchNews);

    // Add a listener to the ScrollController
    scrollController.addListener(() {
      if (scrollController.position.pixels >= scrollController.position.maxScrollExtent - 100) {
        // Trigger LoadMoreNews when near the bottom
        add(LoadMoreNews());
      }
    });
  }


  // Fetch initial data
  Future<void> _onFetchNews(FetchNews event, Emitter<NewsState> emit) async {
    emit(NewsLoading());
    try {
      _currentPage = 1;
      _allArticles = await _repository.fetchNewsByPage(
        page: _currentPage,
        pageSize: _pageSize,
        query: 'en', // Always in English
      );
      _filteredArticles = List.from(_allArticles);  // Initially show all data
      emit(NewsLoaded(
        articles: _filteredArticles,
        hasReachedMax: _filteredArticles.length < _pageSize,
      ));
    } catch (e) {
      emit(NewsError(e.toString()));
    }
  }

  // Load more data on scroll
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
        _allArticles.addAll(nextPage); // Append new articles to the master list
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

  // Search handler
  Future<void> _onSearchNews(SearchNews event, Emitter<NewsState> emit) async {
    final query = event.query?.trim() ?? '';

    // If search query is the same as the last one, avoid unnecessary reload
    if (_currentSearchQuery == query) return;

    _currentSearchQuery = query;
    emit(NewsLoading());

    try {
      if (query.isEmpty) {
        // If the search query is empty, show all data
        _filteredArticles = List.from(_allArticles);
      } else {
        // Filter articles by title or category
        _filteredArticles = _applySearchFilter(_allArticles);
      }

      emit(NewsLoaded(
        articles: _filteredArticles,
        hasReachedMax: _filteredArticles.length < _pageSize,
      ));
    } catch (e) {
      emit(NewsError(e.toString()));
    }
  }

  List<NewsArticle> _applySearchFilter(List<NewsArticle> articles) {
    return articles.where((article) {
      final lowerCaseTitle = article.title.toLowerCase();
      final searchQuery = _currentSearchQuery.toLowerCase();

      // Check if the search query matches the title or any category in the list
      final categoryMatch = article.category.any((category) =>
          category.toLowerCase().contains(searchQuery));

      return lowerCaseTitle.contains(searchQuery) || categoryMatch;
    }).toList();
  }

  // Dispose method to clean up controllers
  @override
  Future<void> close() {
    searchController.dispose();
    scrollController.dispose();
    return super.close();
  }
}






