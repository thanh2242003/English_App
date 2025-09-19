import 'package:english_app/data/questions.dart';
import 'package:english_app/my_button.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  int currentStep = 0;
  final int totalStep = 3;
  final currentQuestion = questions[0];

  @override
  Widget build(BuildContext context) {
    double progress = (currentStep + 1) / totalStep;
    return Scaffold(
      body: Column(
        children: [
          Container(
            margin: EdgeInsets.symmetric(horizontal: 8, vertical: 10),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.grey,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.yellow),
              minHeight: 15,
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          const SizedBox(height: 50),
          Text(
            currentQuestion.text,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          SizedBox(height: 100,),
          MyButton(data: currentQuestion.answers[0], onTap: () {}),
          MyButton(data: currentQuestion.answers[1], onTap: () {}),
          MyButton(data: currentQuestion.answers[2], onTap: () {}),
        ],
      ),
    );
  }
}
