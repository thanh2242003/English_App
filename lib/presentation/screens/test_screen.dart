import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:english_app/data/offline_data_service.dart';
import 'package:english_app/models/database_models.dart';
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
  DatabaseLesson? _currentLesson;
  bool _isLoading = true;
  final OfflineDataService _dataService = OfflineDataService();

  @override
  void initState() {
    super.initState();
    _loadLesson();
  }

  Future<void> _loadLesson() async {
    try {
      final lessons = await _dataService.getAllLessons();
      if (lessons.isNotEmpty) {
        setState(() {
          _currentLesson = lessons.first;
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading lesson: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Lấy danh sách các bài tập của phần hiện tại
  List<ExerciseStep> get _currentExercises {
    if (_currentLesson == null || _currentLesson!.parts.isEmpty) return [];
    return _currentLesson!.parts[_currentPartIndex].exercises
        .map((exercise) => exercise.toExerciseStep())
        .toList();
  }

  // Lấy bài tập hiện tại
  ExerciseStep get _currentExercise => _currentExercises[_currentExerciseIndex];

  // Hàm lưu tiến trình lên Firebase
  Future<void> saveProgress() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null || _currentLesson == null) return;

    final userDocRef = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid);
    await userDocRef.set({
      'currentLesson': _currentLesson!.title,
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
      if (_currentLesson != null && _currentPartIndex < _currentLesson!.parts.length - 1) {
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
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: CircularProgressIndicator(color: Colors.white),
        ),
      );
    }

    if (_currentLesson == null || _currentLesson!.parts.isEmpty) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: Text(
            'Không có dữ liệu bài học',
            style: TextStyle(color: Colors.white, fontSize: 18),
          ),
        ),
      );
    }

    // Tính toán tiến trình tổng thể của toàn bộ bài học
    int totalExercisesInLesson = _currentLesson!.parts.fold(
      0,
      (prev, part) => prev + part.exercises.length,
    );
    int completedExercisesInLesson = 0;
    for (int i = 0; i < _currentPartIndex; i++) {
      completedExercisesInLesson += _currentLesson!.parts[i].exercises.length;
    }
    // Thêm +1 nếu chưa hoàn thành phần, để thanh tiến trình không bị lùi lại khi bắt đầu phần mới
    completedExercisesInLesson += _isPartCompleted
        ? _currentExercises.length
        : _currentExerciseIndex;

    double progress = totalExercisesInLesson > 0
        ? completedExercisesInLesson / totalExercisesInLesson
        : 0;

    // Lấy hướng dẫn từ bài tập hiện tại
    final String instruction = _currentExercise.instruction;

    // Lấy tên phần hiện tại
    final String currentPartTitle = _currentLesson!.parts[_currentPartIndex].title;

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
                      "Hoàn thành $currentPartTitle!",
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
