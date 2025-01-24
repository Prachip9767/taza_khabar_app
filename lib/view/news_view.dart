import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:taza_khabar_app/bloc/news_bloc.dart';
import 'package:taza_khabar_app/events/news_events.dart';
import 'package:taza_khabar_app/models/news_model.dart';
import 'package:taza_khabar_app/state/news_state.dart';


class NewsPage extends StatefulWidget {
  @override
  _NewsPageState createState() => _NewsPageState();
}

class _NewsPageState extends State<NewsPage> {
  final _scrollController = ScrollController();
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _searchController.addListener(_onSearchChanged);

    // Fetch initial news
    context.read<NewsBloc>().add(FetchNews());
  }

  void _onScroll() {
    if (_isBottom) {
      context.read<NewsBloc>().add(LoadMoreNews());
    }
  }

  bool get _isBottom {
    if (!_scrollController.hasClients) return false;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;
    return currentScroll >= (maxScroll * 0.9);
  }

  void _onSearchChanged() {
    final query = _searchController.text.trim();
    context.read<NewsBloc>().add(SearchNews(query: query));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Indian Business News'),
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          Expanded(
            child: BlocBuilder<NewsBloc, NewsState>(
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
                    controller: _scrollController,
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
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                hintText: 'Search news...',
                border: OutlineInputBorder(),
              ),
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              final query = _searchController.text.trim();
              context.read<NewsBloc>().add(SearchNews(query: query));
            },
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }
}


class BottomLoader extends StatelessWidget {
  const BottomLoader({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }
}

class NewsArticleItem extends StatelessWidget {
  final NewsArticle article;
  final VoidCallback onTap;

  const NewsArticleItem({
    super.key,
    required this.article,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: const BeveledRectangleBorder
        (borderRadius:BorderRadius.all(Radius.circular(8))),
      margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      child: SizedBox(
        height: 200,
        child: Stack(
          children: [
            // Background Image
            CachedNetworkImage(
              imageUrl: article.urlToImage ?? '',
              errorWidget: (context, url, error) => const SizedBox(),
              placeholder: (context, url) => const SizedBox(),
              fit: BoxFit.cover, // Ensures the image covers the area
              width: double.infinity,
              height: double.infinity, // Matches the parent's constraints
            ),
            // Black Overlay
            Container(
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.5), // Semi-transparent black overlay
              ),
              width: double.infinity,
              height: double.infinity,
            ),
            // Content
            ListTile(
              title: Text(
                article.title,
                maxLines: 1,
                style: const TextStyle(color: Colors.white),
                overflow: TextOverflow.ellipsis,
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Source: Current News',
                    style: TextStyle(color: Colors.white),
                  ),
                  Text(
                    'Published: ${article.publishedAt ?? 'Unknown'}',
                    style: const TextStyle(color: Colors.white),
                  ),
                  if (article.description != null)
                    Text(
                      article.description!.replaceAll('\n', ' '),
                      maxLines: 2,
                      style: const TextStyle(color: Colors.white),
                      overflow: TextOverflow.ellipsis,
                    ),
                ],
              ),
              onTap: onTap,
            ),
          ],
        ),
      )

    );
  }
}

class NewsDetailPage extends StatelessWidget {
  final NewsArticle article;

  const NewsDetailPage({super.key, required this.article});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(article.title),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              article.title,
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 8),
            const Text('Source: Current News'),
            Text('Published: ${article.publishedAt ?? 'Unknown'}'),
            const SizedBox(height: 16),
            Text(
              article.description ?? 'No description available.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}
