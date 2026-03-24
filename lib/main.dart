import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:velvaere_app/controller/get_lead_controller.dart';
import 'package:velvaere_app/controller/logout_controller.dart';
import 'package:velvaere_app/view/login_page.dart';
import 'package:velvaere_app/view/home_page.dart';
import 'package:velvaere_app/view/splash_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LogoutController()),
        ChangeNotifierProvider(create: (_) => LeadController()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Velvaere',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF1B4FD8)),
          useMaterial3: true,
          fontFamily: 'Roboto',
        ),
        // ✅ SplashScreen decides: HomePage if logged in, LoginPage if not
        home: const SplashScreen(),
        routes: {
          '/login': (context) => const LoginPage(),
          '/home': (context) => const HomePage(),
        },
      ),
    );
  }
}
