import 'package:english_app/presentation/screens/home_screen.dart';
import 'package:english_app/presentation/screens/login_screen.dart';
import 'package:english_app/presentation/screens/test_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
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
              child: const LoginScreen(),
            ),
          ),
    );
  }
}
