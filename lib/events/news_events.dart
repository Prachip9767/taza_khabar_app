
abstract class NewsEvent {}

class FetchNews extends NewsEvent {
  final String query;

  FetchNews({this.query = 'en'});
}

class LoadMoreNews extends NewsEvent {}


class SearchNews extends NewsEvent {
  final String? query;
  final String? language;
  final String? author;
  final String? category;

  SearchNews({
    this.query,
    this.language,
    this.author,
    this.category,
  });
}


abstract class DateEvent {}

class FormatDateEvent extends DateEvent {
  final String dateString;
  FormatDateEvent(this.dateString);
}