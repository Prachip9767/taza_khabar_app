import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:taza_khabar_app/bloc/news_bloc.dart';
import 'package:taza_khabar_app/events/news_events.dart';
import 'package:taza_khabar_app/state/news_state.dart';
import 'package:taza_khabar_app/utils/app_color.dart';
import 'package:taza_khabar_app/view/news_detail_page.dart';
import 'package:taza_khabar_app/widgets/bottom_loader.dart';
import 'package:taza_khabar_app/widgets/news_item-widget.dart';

/// The NewsPage widget is the main screen of the app where users can view
/// news articles and search for specific topics.
class NewsPage extends StatefulWidget {
  NewsPage({super.key});

  @override
  _NewsPageState createState() => _NewsPageState();
}

class _NewsPageState extends State<NewsPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final FocusNode _focusNode = FocusNode(); // FocusNode to manage TextField focus

  @override
  void initState() {
    super.initState();
    // Unfocus the text field when coming back to the page
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_focusNode.hasFocus) {
        _focusNode.unfocus();
      }
    });
  }

  @override
  void dispose() {
    _focusNode.dispose(); // Dispose of the FocusNode when the widget is destroyed
    super.dispose();
  }

  /// Helper function to unfocus the text field and hide the keyboard.
  void _unfocusTextField() {
    FocusScope.of(context).unfocus();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (_focusNode.hasFocus) {
          _unfocusTextField(); // Close the keyboard if the TextField is focused
          return false; // Prevent the default back action
        }
        return true; // Allow the default back action if the keyboard is not visible
      },
      child: GestureDetector(
        onTap: () => _unfocusTextField(), // Hide the keyboard on tapping outside
        child: Scaffold(
          key: _scaffoldKey,
          resizeToAvoidBottomInset: false,
          appBar: _buildAppBar(context),
          drawer: _buildDrawer(context),
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSearchBar(context),
              if (context.read<NewsBloc>().recentSearches.isNotEmpty)
                const Padding(
                  padding: EdgeInsets.only(left: 12.0),
                  child: Text('Recent Searches',
                    style: TextStyle(
                      color: AppColors.black,
                      height: 1.1,
                      fontSize: 14,
                      fontWeight: FontWeight.w600
                    ),
                  ),
                ),
              if (context.read<NewsBloc>().recentSearches.isNotEmpty)
                _buildRecentSearchChips(context),
              Expanded(child: _buildNewsList(context)),
            ],
          ),
        ),
      ),
    );
  }

  /// Builds the AppBar widget with a title and a menu button to open the drawer.
  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      title: const Text(
        'Taza Khabar',
        style: TextStyle(fontWeight: FontWeight.w700, fontSize: 28, height: 2),
      ),
      leading: IconButton(
        icon: const Icon(Icons.menu_outlined, color:AppColors.black),
        onPressed: () {
          _scaffoldKey.currentState?.openDrawer();
          _unfocusTextField();
        },
      ),
      centerTitle: true,
    );
  }

  /// Builds the Drawer widget that contains a list of menu items for navigation.
  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          SizedBox(
            height: 150,
            child: DrawerHeader(
              decoration: BoxDecoration(
                color: AppColors.purple.withOpacity(0.2),
              ),
              child: const Align(
                alignment: Alignment.bottomLeft,
                child: Text(
                  'Taza Khabar',
                  style: TextStyle(color: AppColors.black87, fontSize: 24),
                ),
              ),
            ),
          ),
          _buildDrawerItem(context, Icons.home, 'Home'),
          _buildDrawerItem(context, Icons.business, 'Business'),
          _buildDrawerItem(context, Icons.trending_up, 'Trending'),
          _buildDrawerItem(context, Icons.sports_cricket, 'Sports'),
          _buildDrawerItem(context, Icons.settings, 'Settings'),
        ],
      ),
    );
  }

  /// Builds a list item for the Drawer with an icon and title.
  Widget _buildDrawerItem(BuildContext context, IconData icon, String title) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      onTap: () {
        Navigator.pop(context);
        _unfocusTextField(); // Remove focus from the search field
      },
    );
  }

  /// Builds the search bar where users can input search queries.
  Widget _buildSearchBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              focusNode: _focusNode, // Attach the FocusNode to the TextField
              controller: context.read<NewsBloc>().searchController,
              decoration: const InputDecoration(
                hintText: 'Search by title or category...',
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                if (value.trim().isEmpty) {
                  context.read<NewsBloc>().add(SearchNews(query: ''));
                }
              },
              onSubmitted: (value) {
                _handleSearch(context, value.trim());
              },
              onTap: () {
                // Only open keyboard when the user taps on the search TextField
                _focusNode.requestFocus();
              },
            ),
          ),
          const SizedBox(width: 8),
          _buildSearchButton(context),
        ],
      ),
    );
  }

  /// Builds the search button inside the search bar.
  Widget _buildSearchButton(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.all(Radius.circular(40)),
        color: AppColors.purple.withOpacity(0.3),
      ),
      child: IconButton(
        icon: const Icon(Icons.search_rounded, color:AppColors.black),
        onPressed: () {
          final query = context.read<NewsBloc>().searchController.text.trim();
          _handleSearch(context, query);
        },
      ),
    );
  }

  /// Handles the search logic when a query is submitted or changed.
  void _handleSearch(BuildContext context, String query) {
    if (query.isNotEmpty) {
      if (!context.read<NewsBloc>().recentSearches.contains(query)) {
        context.read<NewsBloc>().recentSearches.insert(0, query);
        if (context.read<NewsBloc>().recentSearches.length > 5) {
          context.read<NewsBloc>().recentSearches.removeLast();
        }
      }
      context.read<NewsBloc>().add(SearchNews(query: query));
      _unfocusTextField(); // Hide the keyboard after search
    }
  }

  /// Builds the list of recent search chips for quick access.
  Widget _buildRecentSearchChips(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Wrap(
          spacing: 8.0,
          children: context.read<NewsBloc>().recentSearches.map((query) {
            return GestureDetector(
              onTap: () {
                // Perform the search with the selected query
                context.read<NewsBloc>().searchController.text = query;
                _handleSearch(context, query);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey, width: 1),
                  borderRadius: const BorderRadius.all(Radius.circular(20)),
                ),
                child: Text(query),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  /// Builds the list of news articles to be displayed in the body of the screen.
  Widget _buildNewsList(BuildContext context) {
    return BlocBuilder<NewsBloc, NewsState>(
      builder: (context, state) {
        if (state is NewsLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state is NewsError) {
          return Center(child: Text(state.message));
        }
        if (state is NewsLoaded) {
          if (state.articles.isEmpty) {
            return const Center(child: Text('No news found.'));
          }
          return ListView.builder(
            controller: context.read<NewsBloc>().scrollController,
            itemCount: state.hasReachedMax
                ? state.articles.length
                : state.articles.length + 1,
            itemBuilder: (context, index) {
              if (index >= state.articles.length) {
                return const BottomLoader();
              }
              final article = state.articles[index];
              return NewsArticleItem(
                article: article,
                onTap: () {
                  _focusNode.unfocus();
                  _unfocusTextField(); // Close the keyboard when tapping on an article
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => NewsDetailPage(article: article),
                    ),
                  );
                },
              );
            },
          );
        }
        return const SizedBox.shrink();
      },
    );
  }
}
