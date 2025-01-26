// News BLoC
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:taza_khabar_app/events/news_events.dart';
import 'package:taza_khabar_app/models/news_article_model.dart';
import 'package:taza_khabar_app/repository/news_repository.dart';
import 'package:taza_khabar_app/state/news_state.dart';
import 'dart:async';

class NewsBloc extends Bloc<NewsEvent, NewsState> {
  final NewsRepository _repository;
  final TextEditingController searchController = TextEditingController();
  final ScrollController scrollController = ScrollController();
  final List<String> recentSearches = [];


  List<NewsArticle> _allArticles = [];
  List<NewsArticle> _filteredArticles = [];

  int _currentPage = 1;
  static const int _pageSize = 20;

  String _currentSearchQuery = '';

  NewsBloc(this._repository) : super(NewsInitial()) {
    on<FetchNews>(_onFetchNews);
    on<LoadMoreNews>(_onLoadMoreNews);
    on<SearchNews>(_onSearchNews);
    on<AddRecentSearch>(_onAddRecentSearch);
    on<RemoveRecentSearch>(_onRemoveRecentSearch);
    scrollController.addListener(_onScroll);
  }

  Future<void> _onFetchNews(FetchNews event, Emitter<NewsState> emit) async {
    emit(NewsLoading());
    try {
      _currentPage = 1;
      _allArticles = await _repository.fetchNewsByPage(
        page: _currentPage,
        pageSize: _pageSize,
        query: 'en',
      );
      _filteredArticles = List.from(_allArticles);
      emit(NewsLoaded(
        recentSearches: recentSearches,
        articles: _filteredArticles,
        hasReachedMax: _filteredArticles.length < _pageSize,
      ));
    } catch (e) {
      emit(NewsError(
        message: 'Failed to load news. Please try again.',
        onRetry: () {
          add(FetchNews());
        },
      ));
    }
  }

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
        _allArticles.addAll(nextPage);
        _filteredArticles = _applySearchFilter(_allArticles);
        emit(NewsLoaded(
          articles: _filteredArticles,
          hasReachedMax: nextPage.length < _pageSize,
          recentSearches: recentSearches,
        ));
      }
    } catch (e) {
      emit(NewsError(
        message: 'Failed to load news. Please try again.',
        onRetry: () {
          add(FetchNews());
        },
      ));
    }
  }

  Future<void> _onSearchNews(SearchNews event, Emitter<NewsState> emit) async {
    final query = event.query?.trim() ?? '';

    if (query.isEmpty) {
      _currentSearchQuery = '';
      _filteredArticles = List.from(_allArticles);
      emit(NewsLoaded(
        recentSearches: recentSearches,
        articles: _filteredArticles,
        hasReachedMax: _filteredArticles.length < _pageSize,
      ));
      return;
    }

    if (_currentSearchQuery == query) return;

    _currentSearchQuery = query;
    emit(NewsLoading());

    try {
      _filteredArticles = _applySearchFilter(_allArticles);
      emit(NewsLoaded(
        recentSearches: recentSearches,
        articles: _filteredArticles,
        hasReachedMax: _filteredArticles.length < _pageSize,
      ));
    } catch (e) {
      emit(NewsError(
        message: 'Failed to load news. Please try again.',
        onRetry: () {
          add(FetchNews());
        },
      ));
    }
  }

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

  void _onAddRecentSearch(AddRecentSearch event, Emitter<NewsState> emit) {
    if (!recentSearches.contains(event.query)) {
      recentSearches.insert(0, event.query);
      if (recentSearches.length > 5) {
        recentSearches.removeLast();
      }
    }
    emit(NewsLoaded(
      articles: _filteredArticles,
      hasReachedMax: _filteredArticles.length < _pageSize,
      recentSearches: recentSearches,
    ));
  }

  void _onRemoveRecentSearch(RemoveRecentSearch event, Emitter<NewsState> emit) {
    recentSearches.remove(event.query);
    emit(NewsLoaded(
      articles: _filteredArticles,
      hasReachedMax: _filteredArticles.length < _pageSize,
      recentSearches: recentSearches,
    ));
  }

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






