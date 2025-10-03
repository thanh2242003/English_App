import 'package:english_app/data/exercise_data.dart';
import 'package:english_app/data/match_words_data.dart';
import 'package:english_app/models/translation_quiz.dart';
import 'package:english_app/presentation/widgets/lesson_match_widget.dart';
import 'package:english_app/presentation/widgets/lesson_translation_widget.dart';
import 'package:flutter/material.dart';

class TestScreen extends StatefulWidget {
  const TestScreen({super.key});

  @override
  State<TestScreen> createState() => _TestState();
}

class _TestState extends State<TestScreen> {
  int currentStep = 1;

  @override
  Widget build(BuildContext context) {
    final exercise = step[currentStep];
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // progress bar
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
              child: LinearProgressIndicator(
                value: 0.4,
                backgroundColor: const Color(0xFF3A3939),
                valueColor: const AlwaysStoppedAnimation<Color>(Colors.yellow),
                minHeight: 15,
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            // instruction text
            Container(
              margin: EdgeInsets.only(left: 40),
              child: Text(
                exercise.instruction,
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            //const SizedBox(height: 20),
            //Nội dung
            Expanded(child: LessonTranslationWidget(
                question: exercise.data as TranslationQuiz,),),
          ],
        ),
      ),
    );
  }
}