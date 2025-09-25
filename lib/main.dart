import 'package:english_app/presentation/screens/login_screen.dart';
import 'package:english_app/presentation/screens/onboarding_screen.dart';
import 'package:english_app/presentation/screens/splash_screen.dart';
import 'package:english_app/presentation/screens/welcome_screen.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home:
          //const SplashScreen(),
          Scaffold(
            body: SafeArea(
              child: const OnboardingScreen(),
            ),
          ),
    );
  }
}
