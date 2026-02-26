import 'package:flutter/material.dart';
import 'package:velvaere_app/view/login_page.dart';
import 'package:velvaere_app/view/home_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Velvaere',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF1B4FD8)),
        useMaterial3: true,
        fontFamily: 'Roboto',
      ),
      routes: {
        '/': (context) => const LoginPage(),
        '/home': (context) => const HomePage(),
      },
      initialRoute: '/home',
    );
  }
}
