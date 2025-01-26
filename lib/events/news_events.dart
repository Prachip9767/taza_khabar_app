
abstract class NewsEvent {}

class FetchNews extends NewsEvent {
  final String query;

  FetchNews({this.query = 'en'});
}

class LoadMoreNews extends NewsEvent {}


class AddRecentSearch extends NewsEvent {
  final String query;
  AddRecentSearch({required this.query});
}

class RemoveRecentSearch extends NewsEvent {
  final String query;
  RemoveRecentSearch({required this.query});
}
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