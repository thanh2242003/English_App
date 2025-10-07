import 'package:english_app/core/navigation/app_navigator.dart';
import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  // SplashScreen giờ chỉ hiển thị UI, AppNavigator sẽ xử lý navigation

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.blueAccent,
        image: DecorationImage(
          image: AssetImage("assets/images/splash_image.png"),
        ),
      ),
    );
  }
}
