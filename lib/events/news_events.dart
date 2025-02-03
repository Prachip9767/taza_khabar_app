/// Abstract base class for news-related events in the application
abstract class NewsEvent {}

/// Event to fetch news articles
/// [query] allows specifying a default language or search term
class FetchNews extends NewsEvent {
  final String query;

  FetchNews({this.query = 'en'});
}

/// Event to trigger loading more news articles
/// Used for implementing pagination or infinite scroll functionality
class LoadMoreNews extends NewsEvent {}

/// Event to add a recent search query to the app's search history
/// [query] is the search term to be added to recent searches
class AddRecentSearch extends NewsEvent {
  final String query;
  AddRecentSearch({required this.query});
}

/// Event to remove a specific search query from the recent search history
/// [query] is the search term to be removed from recent searches
class RemoveRecentSearch extends NewsEvent {
  final String query;
  RemoveRecentSearch({required this.query});
}

/// Event for performing advanced news search with multiple filtering options
/// Allows searching news with optional filters like query, language, author, and category
class SearchNews extends NewsEvent {
  final String? query;     // Search text
  final String? language;  // Language of news articles
  final String? author;    // Specific author's articles
  final String? category;  // News category

  SearchNews({
    this.query,
    this.language,
    this.author,
    this.category,
  });
}

class UpdateScrollToTopVisibility extends NewsEvent {
  final bool isVisible;
  UpdateScrollToTopVisibility(this.isVisible);
}