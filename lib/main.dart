import 'package:bali_heritage/Baliloka_stories/screens/stories_page.dart';
import 'package:bali_heritage/Bookmarks/screens/bookmarks.dart';
import 'package:bali_heritage/Forum/forum_create_page.dart';
import 'package:bali_heritage/authentication/login.dart';
import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Provider(
      create: (_) {
        CookieRequest request = CookieRequest();
        return request;
      },
      child: MaterialApp(
        routes: {
    
          '/create_post': (context) => const ForumCreatePage(),
        },
        title: 'Bali Heritage',
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSwatch(
            primarySwatch: Colors.orange,
          ).copyWith(
            secondary: Colors.orange[400],
            background: Colors.white,
          ),
        ),
        home: const StoriesPage(),
      ), // Removed the misplaced semicolon here.
    );
  }
}
