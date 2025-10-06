import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:english_app/data/exercise_data.dart';
import 'package:english_app/models/exercise_step.dart';
import 'package:english_app/models/match_word_quiz.dart';
import 'package:english_app/models/translation_quiz.dart';
import 'package:english_app/models/typing_quiz.dart';
import 'package:english_app/presentation/widgets/lesson_match_widget.dart';
import 'package:english_app/presentation/widgets/lesson_translation_widget.dart';
import 'package:english_app/presentation/widgets/lesson_typing_widget.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../models/word_order_quiz.dart';
import '../widgets/word_order_widget.dart';
import 'home_screen.dart';

class TestScreen extends StatefulWidget {
  const TestScreen({super.key});

  @override
  State<TestScreen> createState() => _TestScreenState();
}

class _TestScreenState extends State<TestScreen> {
  int _currentPartIndex = 0;
  int _currentExerciseIndex = 0;
  bool _isPartCompleted = false;

  // Lấy danh sách các bài tập của phần hiện tại
  List<ExerciseStep> get _currentExercises =>
      lesson1.parts[_currentPartIndex].exercises;

  // Lấy bài tập hiện tại
  ExerciseStep get _currentExercise => _currentExercises[_currentExerciseIndex];

  // Hàm lưu tiến trình lên Firebase
  Future<void> saveProgress() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final userDocRef = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid);
    await userDocRef.set({
      'currentLesson': lesson1.title,
      'currentPart': _currentPartIndex + 1,
      'lastCompletedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  // Chuyển sang bài tập tiếp theo
  void _goToNextExercise() {
    setState(() {
      if (_currentExerciseIndex < _currentExercises.length - 1) {
        _currentExerciseIndex++;
      } else {
        // Đã hoàn thành tất cả các bài tập trong phần này
        _isPartCompleted = true;
      }
    });
  }

  // Chuyển sang phần tiếp theo
  void _goToNextPart() {
    setState(() {
      if (_currentPartIndex < lesson1.parts.length - 1) {
        _currentPartIndex++;
        _currentExerciseIndex = 0;
        _isPartCompleted = false;
      } else {
        // Đã hoàn thành tất cả các phần, kết thúc bài học
        _handleLessonCompletion();
      }
    });
  }

  // Xử lý khi hoàn thành toàn bộ bài học
  void _handleLessonCompletion() {
    saveProgress();
    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Hoàn thành bài học!")));
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const HomeScreen()),
        (route) => false,
      );
    }
  }

  // Widget hiển thị nội dung bài tập tương ứng
  Widget _buildExerciseContent() {
    final exerciseData = _currentExercise.data;

    switch (_currentExercise.type) {
      case ExerciseType.matchWords:
        return LessonMatchWidget(
          data: exerciseData as MatchWordsQuiz,
          onNext: _goToNextExercise,
        );
      case ExerciseType.chooseTranslation:
        return LessonTranslationWidget(
          question: exerciseData as TranslationQuiz,
          onNext: _goToNextExercise,
        );
      case ExerciseType.typingQuiz:
        final data = exerciseData as TypingQuiz;
        return LessonTypingWidget(
          question: data.vietnamese,
          answer: data.english,
          onNext: _goToNextExercise,
        );
      case ExerciseType.wordOrder:
        return WordOrderWidget(
          quizData: exerciseData as WordOrderQuiz,
          onNext: _goToNextExercise,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Tính toán tiến trình tổng thể của toàn bộ bài học
    int totalExercisesInLesson = lesson1.parts.fold(
      0,
      (prev, part) => prev + part.exercises.length,
    );
    int completedExercisesInLesson = 0;
    for (int i = 0; i < _currentPartIndex; i++) {
      completedExercisesInLesson += lesson1.parts[i].exercises.length;
    }
    // Thêm +1 nếu chưa hoàn thành phần, để thanh tiến trình không bị lùi lại khi bắt đầu phần mới
    completedExercisesInLesson += _isPartCompleted
        ? _currentExercises.length
        : _currentExerciseIndex;

    //completedExercisesInLesson += _currentExerciseIndex;

    double progress = totalExercisesInLesson > 0
        ? completedExercisesInLesson / totalExercisesInLesson
        : 0;

    // Lấy hướng dẫn từ bài tập hiện tại
    final String instruction = _currentExercise.instruction;

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: !_isPartCompleted
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Thanh tiến trình
                  Container(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 15,
                      vertical: 10,
                    ),
                    child: LinearProgressIndicator(
                      value: progress,
                      backgroundColor: const Color(0xFF3A3939),
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        Colors.yellow,
                      ),
                      minHeight: 15,
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  // instruction text
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Text(
                      instruction,
                      style: const TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Nội dung
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: _buildExerciseContent(),
                    ),
                  ),
                ],
              )
            // báo hoàn thành phần
            : Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Hoàn thành ${lesson1.parts[_currentPartIndex].title}!",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _goToNextPart,
                      child: const Text("Tiếp tục"),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
