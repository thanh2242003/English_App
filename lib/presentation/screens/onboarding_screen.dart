import 'package:english_app/presentation/screens/login_screen.dart';
import 'package:english_app/core/widgets/my_button.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../data/questions_data.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  int currentStep = 0;
  final int totalStep = 3;

  void answerQuestion() {
    if (currentStep < totalStep - 1) {
      setState(() {
        currentStep++;
      });
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) {
            return LoginScreen();
          },
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentQuestion = questions[currentStep];
    double progress = (currentStep + 1) / totalStep;
    return Scaffold(
      backgroundColor: Colors.white,
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
          SizedBox(height: 100),
          ...currentQuestion.answers.map((answer) {
            return Column(
              children: [
                Container(
                  margin: EdgeInsets.symmetric(horizontal: 20),
                  child: SizedBox(
                    width: double.infinity,
                    child: MyButton(data: answer, onTap: answerQuestion),
                  ),
                ),
                SizedBox(height: 15),
              ],
            );
          }),
        ],
      ),
    );
  }
}
