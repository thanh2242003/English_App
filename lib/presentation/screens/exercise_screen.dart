import 'package:flutter/material.dart';

class ExerciseScreen extends StatelessWidget {
  const ExerciseScreen({
    super.key,
    required this.progress,
    required this.instruction,
    required this.content,
  });

  final double progress;
  final String instruction;
  final Widget content;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // progress bar
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
              child: LinearProgressIndicator(
                value: progress,
                backgroundColor: const Color(0xFF3A3939),
                valueColor: const AlwaysStoppedAnimation<Color>(Colors.yellow),
                minHeight: 15,
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            // instruction text
            Text(
              instruction,
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 20),
            //Nội dung
            Expanded(child: content),
          ],
        ),
      ),
    );
  }
}
