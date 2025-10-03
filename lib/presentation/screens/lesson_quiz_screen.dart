import 'package:flutter/material.dart';

class LessonQuizScreen extends StatefulWidget {
  const LessonQuizScreen({super.key});

  @override
  State<LessonQuizScreen> createState() => _LessonQuizState();
}

class _LessonQuizState extends State<LessonQuizScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
              child: LinearProgressIndicator(
                value: 0.5,
                backgroundColor: const Color(0xFF3A3939),
                valueColor: const AlwaysStoppedAnimation<Color>(Colors.yellow),
                minHeight: 15,
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            Text(
              'Chọn bản dịch',
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
