import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:taza_khabar_app/events/news_events.dart';
import 'package:taza_khabar_app/models/news_article_model.dart';
import 'package:taza_khabar_app/repository/news_repository.dart';
import 'package:taza_khabar_app/state/news_state.dart';
import 'dart:async';

/// Bloc to manage the state and events for the news application.
class NewsBloc extends Bloc<NewsEvent, NewsState> {
  /// Repository instance to fetch news data from an API or other sources.
  final NewsRepository _repository;

  /// Controller for managing search input from the user.
  final TextEditingController searchController = TextEditingController();

  /// Controller for managing scrolling in the news list view.
  final ScrollController scrollController = ScrollController();

  /// A list to keep track of recent search queries entered by the user.
  final List<String> recentSearches = [];

  /// List to store all fetched news articles.
  List<NewsArticle> _allArticles = [];

  /// List to store filtered news articles based on search queries.
  List<NewsArticle> _filteredArticles = [];

  /// The current page being fetched for pagination.
  int _currentPage = 1;

  /// Number of articles to fetch per page.
  static const int _pageSize = 20;

  /// Current search query string entered by the user.
  String _currentSearchQuery = '';

  /// Constructor to initialize the NewsBloc with the repository and set up event handlers.
  NewsBloc(this._repository) : super(NewsInitial()) {
    // Event handlers for different types of events.
    on<FetchNews>(_onFetchNews);
    on<LoadMoreNews>(_onLoadMoreNews);
    on<SearchNews>(_onSearchNews);
    on<AddRecentSearch>(_onAddRecentSearch);
    on<RemoveRecentSearch>(_onRemoveRecentSearch);

    // Listen to scroll events to trigger pagination.
    scrollController.addListener(_onScroll);
  }

  /// Handles the FetchNews event by fetching the first page of news articles.
  Future<void> _onFetchNews(FetchNews event, Emitter<NewsState> emit) async {
    emit(NewsLoading());
    try {
      _currentPage = 1;
      _allArticles = await _repository.fetchNewsByPage(
        page: _currentPage,
        pageSize: _pageSize,
        query: 'en', // Fetch news in English.
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

  /// Handles the LoadMoreNews event for pagination by fetching the next page of news articles.
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

  /// Handles the SearchNews event by filtering articles based on the search query.
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

  /// Filters the list of articles based on the current search query.
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

  /// Handles the AddRecentSearch event by adding a search query to the recent searches list.
  void _onAddRecentSearch(AddRecentSearch event, Emitter<NewsState> emit) {
    if (!recentSearches.contains(event.query)) {
      recentSearches.insert(0, event.query);
      if (recentSearches.length > 5) {
        recentSearches.removeLast(); // Keep the recent searches list to a maximum of 5.
      }
    }
    emit(NewsLoaded(
      articles: _filteredArticles,
      hasReachedMax: _filteredArticles.length < _pageSize,
      recentSearches: recentSearches,
    ));
  }

  /// Handles the RemoveRecentSearch event by removing a search query from the recent searches list.
  void _onRemoveRecentSearch(RemoveRecentSearch event, Emitter<NewsState> emit) {
    recentSearches.remove(event.query);
    emit(NewsLoaded(
      articles: _filteredArticles,
      hasReachedMax: _filteredArticles.length < _pageSize,
      recentSearches: recentSearches,
    ));
  }

  /// Listens to scroll events and triggers loading more news when the user scrolls to the bottom.
  void _onScroll() {
    if (scrollController.position.pixels >= scrollController.position.maxScrollExtent - 100) {
      add(LoadMoreNews());
    }
  }

  /// Disposes resources like controllers when the Bloc is closed.
  @override
  Future<void> close() {
    searchController.dispose();
    scrollController.dispose();
    return super.close();
  }
}
