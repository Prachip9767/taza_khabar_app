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

/// Main application entry point with dependency and state management
class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        // Setup network and repository services
        RepositoryProvider(create: (context) => NetworkService()),
        RepositoryProvider(
          create: (context) => NewsRepository(
            context.read<NetworkService>(),
          ),
        ),
      ],
      child: MultiBlocProvider(
        providers: [
          // Initialize NewsBloc with initial fetch event
          BlocProvider(
            create: (context) => NewsBloc(
              context.read<NewsRepository>(),
            )..add(FetchNews()),
          ),
        ],
        child: const App(),
      ),
    );
  }
}

/// App configuration with theme and initial route
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
