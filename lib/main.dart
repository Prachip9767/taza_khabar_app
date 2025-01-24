import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:taza_khabar_app/bloc/news_bloc.dart';
import 'package:taza_khabar_app/events/news_events.dart';
import 'package:taza_khabar_app/network/network_service.dart';
import 'package:taza_khabar_app/repository/news_repository.dart';
import 'package:taza_khabar_app/view/news_view.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // The MultiRepositoryProvider and MultiBlocProvider will provide the required
    // dependencies and BLoC to the widget tree.
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider(
          create: (context) => NetworkService(),
        ),
        RepositoryProvider(
          create: (context) => NewsRepository(
            context.read<NetworkService>(),  // Properly access NetworkService
          ),
        ),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (context) => NewsBloc(
              context.read<NewsRepository>(),  // Dependency Injection
            )..add(FetchNews()),
          ),
        ],
        child: const App(),
      ),
    );
  }
}

class App extends StatelessWidget {
  const App({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'News App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        textTheme: const TextTheme(
          headlineMedium: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          bodyMedium: TextStyle(fontSize: 16),
          bodySmall: TextStyle(fontSize: 14),
        ),
      ),
      home: NewsPage(),
    );
  }
}
