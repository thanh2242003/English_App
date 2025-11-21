import 'package:english_app/core/di/app_dependencies.dart';
import 'package:english_app/presentation/screens/login_screen.dart';
import 'package:english_app/core/widgets/my_button.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/entities/onboarding_question.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  int currentStep = 0;
  final AppDependencies _dependencies = AppDependencies();
  List<OnboardingQuestion> _questions = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadQuestions();
  }

  Future<void> _loadQuestions() async {
    try {
      final questions = await _dependencies.getOnboardingQuestions();
      setState(() {
        _questions = questions;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }


  void answerQuestion() async {
    // Kiểm tra nếu chưa phải bước cuối cùng
    final totalSteps = _questions.length;
    if (currentStep < totalSteps - 1) {
      setState(() {
        currentStep++;
      });
    }
    // Nếu là bước cuối cùng
    else {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('onboarding_completed', true);

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const LoginScreen(),
          ),
        );
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_questions.isEmpty) {
      return const Scaffold(
        body: Center(child: Text('Không có câu hỏi onboarding')),
      );
    }

    final currentQuestion = _questions[currentStep];
    final totalStep = _questions.length;
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
