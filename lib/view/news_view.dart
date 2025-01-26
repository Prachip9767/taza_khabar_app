import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:taza_khabar_app/bloc/news_bloc.dart';
import 'package:taza_khabar_app/events/news_events.dart';
import 'package:taza_khabar_app/state/news_state.dart';
import 'package:taza_khabar_app/utils/app_color.dart';
import 'package:taza_khabar_app/utils/app_string.dart';
import 'package:taza_khabar_app/view/news_detail_page.dart';
import 'package:taza_khabar_app/widgets/bottom_loader.dart';
import 'package:taza_khabar_app/widgets/news_item-widget.dart';

/// Main news listing page with search and navigation functionality
class NewsPage extends StatefulWidget {
  NewsPage({super.key});

  @override
  _NewsPageState createState() => _NewsPageState();
}

class _NewsPageState extends State<NewsPage> {
  /// Scaffold and focus management keys
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final FocusNode _focusNode = FocusNode();

  // Add a flag to show/hide the Scroll to Top button
  bool _isScrollToTopButtonVisible = false;

  @override
  void initState() {
    super.initState();
    // Listen to the scroll controller to show/hide the button
    context.read<NewsBloc>().scrollController.addListener(_scrollListener);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_focusNode.hasFocus) {
        _focusNode.unfocus();
      }
    });
  }

  @override
  void dispose() {
    context.read<NewsBloc>().scrollController.removeListener(_scrollListener);
    _focusNode.dispose();
    super.dispose();
  }

  // Listen to the scroll position and update the visibility of the button
  void _scrollListener() {
    final scrollPosition = context.read<NewsBloc>().scrollController.position.pixels;
    if (scrollPosition > 300 && !_isScrollToTopButtonVisible) {
      setState(() {
        _isScrollToTopButtonVisible = true;
      });
    } else if (scrollPosition <= 300 && _isScrollToTopButtonVisible) {
      setState(() {
        _isScrollToTopButtonVisible = false;
      });
    }
  }
  /// Unfocus the text field
  void _unfocusTextField() {
    FocusScope.of(context).unfocus();}
  // Scroll to the top of the list when the button is pressed
  void _scrollToTop() {
    context.read<NewsBloc>().scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (_focusNode.hasFocus) {
          _unfocusTextField();
          return false;
        }
        return true;
      },
      child: GestureDetector(
        onTap: () {
          _unfocusTextField();
          _focusNode.unfocus();
        },
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
                  child: Text(AppStrings.recentSearches,
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                  ),
                ),
              if (context.read<NewsBloc>().recentSearches.isNotEmpty)
                _buildRecentSearchChips(context),
              Expanded(child: _buildNewsList(context)),
            ],
          ),
          floatingActionButton: _isScrollToTopButtonVisible
              ? FloatingActionButton(
            onPressed: _scrollToTop,
            backgroundColor: AppColors.purple,
            child: const Icon(Icons.arrow_upward),
          )
              : null,
        ),
      ),
    );
  }
  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      title: const Text(
        AppStrings.appName,
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
                  AppStrings.appName,
                  style: TextStyle(color: AppColors.black87, fontSize: 24),
                ),
              ),
            ),
          ),
          _buildDrawerItem(context, Icons.home,AppStrings.home),
          _buildDrawerItem(context, Icons.business,AppStrings.business),
          _buildDrawerItem(context, Icons.trending_up,AppStrings.trending),
          _buildDrawerItem(context, Icons.sports_cricket,AppStrings.sports),
          _buildDrawerItem(context, Icons.settings, AppStrings.settings),
        ],
      ),
    );
  }

  Widget _buildDrawerItem(BuildContext context, IconData icon, String title) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      onTap: () {
        Navigator.pop(context);
        _unfocusTextField();
      },
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              focusNode: _focusNode,
              controller: context.read<NewsBloc>().searchController,
              decoration: const InputDecoration(
                hintText: AppStrings.searchHint,
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

  void _handleSearch(BuildContext context, String query) {
    if (query.isNotEmpty) {
      if (!context.read<NewsBloc>().recentSearches.contains(query)) {
        context.read<NewsBloc>().recentSearches.insert(0, query);
        if (context.read<NewsBloc>().recentSearches.length > 5) {
          context.read<NewsBloc>().recentSearches.removeLast();
        }
      }
      context.read<NewsBloc>().add(SearchNews(query: query));
      _unfocusTextField();
    }
  }

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

  Widget _buildNewsList(BuildContext context) {
    return BlocBuilder<NewsBloc, NewsState>(
      builder: (context, state) {
        if (state is NewsLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state is NewsError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(state.message),
                TextButton(
                  onPressed: state.onRetry,
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }
        if (state is NewsLoaded) {
          if (state.articles.isEmpty) {
            return const Center(child: Text(AppStrings.noNewsFound));
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
                  _unfocusTextField();
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
