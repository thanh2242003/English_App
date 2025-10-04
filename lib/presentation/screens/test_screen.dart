import 'package:english_app/models/match_word.dart';
import 'package:english_app/models/typing_quiz.dart';
import 'package:english_app/presentation/widgets/lesson_match_widget.dart';
import 'package:english_app/presentation/widgets/lesson_typing_widget.dart';
import 'package:flutter/material.dart';
import 'package:english_app/data/exercise_data.dart';
import 'package:english_app/models/exercise_step.dart';
import 'package:english_app/models/translation_quiz.dart';
import 'package:english_app/presentation/widgets/lesson_translation_widget.dart';

class TestScreen extends StatefulWidget {
  const TestScreen({super.key});

  @override
  State<TestScreen> createState() => _TestScreenState();
}

class _TestScreenState extends State<TestScreen> {
  int currentStep = 0;

  void _goToNextStep() {
    if (currentStep < step.length - 1) {
      setState(() {
        currentStep++;
      });
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("🎉 Hoàn thành bài học!")));
    }
  }

  @override
  Widget build(BuildContext context) {
    final exercise = step[currentStep];
    final String instruction = exercise.instruction;
    Widget content;

    switch (exercise.type) {
      case ExerciseType.matchWords:
        final data = exercise.data as MatchWords;
        content = LessonMatchWidget(data: data, onNext: _goToNextStep);
        break;
      case ExerciseType.chooseTranslation:
        final data = exercise.data as TranslationQuiz;
        content = LessonTranslationWidget(
          question: data,
          onNext: _goToNextStep,
        );
        break;
      case ExerciseType.typingQuiz:
        final data = exercise.data as TypingQuiz;
        content = LessonTypingWidget(
          question: data.vietnamese,
          answer: data.english,
          onNext: _goToNextStep, // callback chuyển sang câu tiếp theo
        );
        break;
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            // Thanh tiến trình
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
              child: LinearProgressIndicator(
                value: (currentStep + 1) / step.length,
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
