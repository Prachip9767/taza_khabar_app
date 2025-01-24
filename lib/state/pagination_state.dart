
import 'package:taza_khabar_app/models/news_model.dart';

abstract class NewsPaginationState {}

class NewsPaginationInitial extends NewsPaginationState {}
class NewsPaginationLoading extends NewsPaginationState {}
class NewsPaginationError extends NewsPaginationState {
  final String message;
  NewsPaginationError(this.message);
}
class NewsPaginationLoaded extends NewsPaginationState {
  final List<NewsArticle> articles;
  final int page;
  final bool hasMore;

  NewsPaginationLoaded({
    required this.articles,
    required this.page,
    required this.hasMore,
  });
}