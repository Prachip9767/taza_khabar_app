import 'package:taza_khabar_app/models/news_model.dart';

class NewsState {}

class NewsInitial extends NewsState {}

class NewsLoading extends NewsState {}

class NewsLoaded extends NewsState {
  final List<NewsArticle> articles;
  final bool hasReachedMax;

  NewsLoaded({required this.articles, required this.hasReachedMax});

  NewsLoaded copyWith({List<NewsArticle>? articles, bool? hasReachedMax}) {
    return NewsLoaded(
      articles: articles ?? this.articles,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
    );
  }
}

class NewsError extends NewsState {
  final String message;

  NewsError(this.message);
}
// State
abstract class DateState {}

class DateInitial extends DateState {}

class DateFormatted extends DateState {
  final String formattedDate;
  DateFormatted(this.formattedDate);
}

class DateError extends DateState {
  final String errorMessage;
  DateError(this.errorMessage);
}