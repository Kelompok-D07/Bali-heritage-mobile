// lib/main.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:bali_heritage/authentication/login.dart'; // Pastikan path benar
import 'package:bali_heritage/authentication/register.dart';
import 'package:bali_heritage/Homepage/screens/homepage.dart';
import 'package:bali_heritage/Forum/forumpage.dart';
import 'package:bali_heritage/Forum/forum_create_page.dart';
import 'package:bali_heritage/Forum/forum_edit_page.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        Provider<CookieRequest>(
          create: (_) => CookieRequest(),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
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
      home: const LoginPage(), // Mulai dari halaman login
      routes: {
        '/register': (context) => const RegisterPage(),
        '/home': (context) => const HomePage(),
        '/forum': (context) => const ForumPage(),
        '/create_post': (context) => const ForumCreatePage(),
        // Tambahkan route lainnya jika diperlukan
      },
    );
  }
}
