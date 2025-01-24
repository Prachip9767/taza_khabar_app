// News BLoC
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:taza_khabar_app/events/news_events.dart';
import 'package:taza_khabar_app/models/news_model.dart';
import 'package:taza_khabar_app/repository/news_repository.dart';
import 'package:taza_khabar_app/state/news_state.dart';
// BLoC
import 'dart:async';
class NewsBloc extends Bloc<NewsEvent, NewsState> {
  final NewsRepository _repository;
  List<NewsArticle> _allArticles = [];
  int _currentPage = 1;
  static const int _pageSize = 20;

  NewsBloc(this._repository) : super(NewsInitial()) {
    // Existing handlers
    on<FetchNews>(_onFetchNews);
    on<LoadMoreNews>(_onLoadMoreNews);  // Ensure this handler is registered

    // Add a handler for the SearchNews event
    on<SearchNews>(_onSearchNews);
  }

  /// Fetches the initial page of data
  Future<void> _onFetchNews(FetchNews event, Emitter<NewsState> emit) async {
    emit(NewsLoading());
    try {
      _currentPage = 1;
      _allArticles = await _repository.fetchNewsByPage(
        page: _currentPage,
        pageSize: _pageSize,
        query: event.query ?? 'en',
      );
      emit(NewsLoaded(
        articles: _allArticles,
        hasReachedMax: _allArticles.length < _pageSize,
      ));
    } catch (e) {
      emit(NewsError(e.toString()));
    }
  }

  /// Loads more data when scrolling down (pagination)
  Future<void> _onLoadMoreNews(LoadMoreNews event, Emitter<NewsState> emit) async {
    if (state is! NewsLoaded) return;

    final currentState = state as NewsLoaded;
    if (currentState.hasReachedMax) return;

    try {
      _currentPage++;
      final nextPage = await _repository.fetchNewsByPage(
        page: _currentPage,
        pageSize: _pageSize,
        query: 'en', // Get language from current articles
      );

      if (nextPage.isEmpty) {
        emit(currentState.copyWith(hasReachedMax: true));
      } else {
        emit(NewsLoaded(
          articles: currentState.articles + nextPage,
          hasReachedMax: nextPage.length < _pageSize,
        ));
      }
    } catch (e) {
      emit(NewsError(e.toString()));
    }
  }

  // New event handler for SearchNews
  Future<void> _onSearchNews(SearchNews event, Emitter<NewsState> emit) async {
    emit(NewsLoading());
    try {
      _currentPage = 1;  // Reset to page 1 for new search
      _allArticles = await _repository.fetchNewsByPage(
        page: _currentPage,
        pageSize: _pageSize,
        query: event.query ?? 'en',  // Use search query from event
      );
      emit(NewsLoaded(
        articles: _allArticles,
        hasReachedMax: _allArticles.length < _pageSize,
      ));
    } catch (e) {
      emit(NewsError(e.toString()));
    }
  }
}




