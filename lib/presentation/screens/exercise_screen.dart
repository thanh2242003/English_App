import 'package:english_app/data/api_service.dart';
import 'package:english_app/models/api_lesson_model.dart';
import 'package:english_app/models/exercise_step.dart';
import 'package:english_app/models/match_word_quiz.dart';
import 'package:english_app/models/translation_quiz.dart';
import 'package:english_app/models/typing_quiz.dart';
import 'package:english_app/presentation/widgets/lesson_match_widget.dart';
import 'package:english_app/presentation/widgets/lesson_translation_widget.dart';
import 'package:english_app/presentation/widgets/lesson_typing_widget.dart';
import 'package:flutter/material.dart';

import '../../models/word_order_quiz.dart';
import '../widgets/word_order_widget.dart';

class ExerciseScreen extends StatefulWidget {
  const ExerciseScreen({super.key});

  @override
  State<ExerciseScreen> createState() => _ExerciseScreenState();
}

class _ExerciseScreenState extends State<ExerciseScreen> {
  int _currentExerciseIndex = 0;
  ApiLesson? _currentLesson;
  bool _isLoading = true;
  final ApiService _apiService = ApiService();

  @override
  void initState() {
    super.initState();
    _loadLesson();
  }

  Future<void> _loadLesson() async {
    try {
      final lesson = await _apiService.fetchLesson();
      if (lesson != null) {
        _currentLesson = lesson;
        _currentExerciseIndex = 0;
      }
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      debugPrint("Error loading lesson: $e");
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Lấy danh sách TẤT CẢ các bài tập từ ApiLesson
  List<ExerciseStep> get _allExercises {
    if (_currentLesson == null || _currentLesson!.exercises.isEmpty) return [];
    return _currentLesson!.exercises.map((e) => e.toExerciseStep()).toList();
  }

  // Lấy bài tập hiện tại
  ExerciseStep get _currentExercise {
    if (_currentExerciseIndex >= _allExercises.length) {
      return _allExercises.last;
    }
    return _allExercises[_currentExerciseIndex];
  }

  // Chuyển sang bài tập tiếp theo
  void _goToNextExercise() {
    setState(() {
      if (_currentExerciseIndex < _allExercises.length - 1) {
        _currentExerciseIndex++;
      } else {
        _handleLessonCompletion();
      }
    });
  }

  // Xử lý khi hoàn thành toàn bộ bài học
  void _handleLessonCompletion() {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Chúc mừng! Bạn đã hoàn thành bài học!")),
      );
      Navigator.of(context).pop();
    }
  }

  // Xử lý khi người dùng muốn thoát lesson
  void _exitLesson() async {
    if (mounted) {
      bool? shouldExit = await showDialog<bool>(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            backgroundColor: Colors.grey[900],
            title: const Text(
              'Thoát bài học',
              style: TextStyle(color: Colors.white),
            ),
            content: const Text(
              'Bạn có chắc chắn muốn thoát?',
              style: TextStyle(color: Colors.white),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text(
                  'Hủy',
                  style: TextStyle(color: Colors.grey),
                ),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text(
                  'Thoát',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          );
        },
      );

      if (shouldExit == true && mounted) {
        Navigator.of(context).pop();
      }
    }
  }

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

    if (_currentLesson == null || _allExercises.isEmpty) {
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

    double progress = _allExercises.isNotEmpty
        ? (_currentExerciseIndex / _allExercises.length)
        : 0;

    if (_currentExerciseIndex >= _allExercises.length) progress = 1.0;

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: _exitLesson,
                  ),
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: LinearProgressIndicator(
                        value: progress,
                        backgroundColor: const Color(0xFF3A3939),
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          Colors.yellow,
                        ),
                        minHeight: 12,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Text(
                _currentExercise.instruction,
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            Expanded(
              child: _buildExerciseContent(),
            ),
          ],
        ),
      ),
    );
  }
}
