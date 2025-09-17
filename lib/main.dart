import 'package:english_app/splash_screen.dart';
import 'package:english_app/welcome_screen.dart';
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
              child: const SplashScreen(),
            ),
          ),
    );
  }
}
