import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:taza_khabar_app/bloc/news_bloc.dart';
import 'package:taza_khabar_app/events/news_events.dart';
import 'package:taza_khabar_app/state/news_state.dart';
import 'package:taza_khabar_app/view/news_detail_page.dart';
import 'package:taza_khabar_app/widgets/bottom_loader.dart';
import 'package:taza_khabar_app/widgets/news_item-widget.dart';

class NewsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: _buildAppBar(),
        body: Column(
          children: [
            _buildSearchBar(context),
            Expanded(child: _buildNewsList(context)),
          ],
        ),
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      title: const Text(
        'Taza Khabar',
        style: TextStyle(fontWeight: FontWeight.w700, fontSize: 28, height: 2),
      ),
      leading: const Icon(Icons.menu_outlined, color: Colors.black),
      centerTitle: true,
    );
  }

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
                  FocusScope.of(context).unfocus();
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

  Widget _buildSearchBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          Expanded(
            child: _buildSearchTextField(context),
          ),
          const SizedBox(width: 8),
          _buildSearchButton(context),
        ],
      ),
    );
  }

  Widget _buildSearchTextField(BuildContext context) {
    return TextField(
      controller: context.read<NewsBloc>().searchController,
      decoration: const InputDecoration(
        hintText: 'Search by title or category...',
        border: OutlineInputBorder(),
      ),
      onChanged: (query) {
        context.read<NewsBloc>().add(SearchNews(query: query));
      },
    );
  }

  Widget _buildSearchButton(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(40)),
        color: Colors.black26,
      ),
      child: IconButton(
        icon: const Icon(Icons.search_rounded, color: Colors.white),
        onPressed: () {
          final query = context.read<NewsBloc>().searchController.text.trim();
          context.read<NewsBloc>().add(SearchNews(query: query));
          FocusScope.of(context).unfocus();
        },
      ),
    );
  }
}
