import 'package:english_app/data/offline_data_service.dart'; // <--- SỬA 1: Import service offline
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
  // Nếu sau này bạn có nhiều bài học, hãy truyền ID hoặc Index vào đây
  // final String lessonId;
  const ExerciseScreen({super.key});

  @override
  State<ExerciseScreen> createState() => _ExerciseScreenState();
}

class _ExerciseScreenState extends State<ExerciseScreen> {
  int _currentExerciseIndex = 0;
  ApiLesson? _currentLesson;
  bool _isLoading = true;

  // SỬA 2: Sử dụng OfflineDataService thay vì ApiService
  final OfflineDataService _offlineService = OfflineDataService();

  @override
  void initState() {
    super.initState();
    _loadLesson();
  }

  // SỬA 3: Logic tải dữ liệu từ Local File (đã mã hóa)
  Future<void> _loadLesson() async {
    try {
      // 1. Lấy toàn bộ danh sách bài học đã lưu offline
      final lessons = await _offlineService.getLessons();

      if (lessons.isNotEmpty) {
        // 2. Lấy bài học đầu tiên (Hoặc xử lý logic chọn bài học tại đây)
        // Ví dụ: _currentLesson = lessons.firstWhere((l) => l.id == widget.lessonId);
        _currentLesson = lessons.first;
        _currentExerciseIndex = 0;
      } else {
        debugPrint("File offline trống hoặc chưa tải dữ liệu.");
      }

      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint("Lỗi đọc dữ liệu offline: $e");
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // Lấy danh sách TẤT CẢ các bài tập từ ApiLesson
  List<ExerciseStep> get _allExercises {
    if (_currentLesson == null || _currentLesson!.exercises.isEmpty) return [];
    return _currentLesson!.exercises.map((e) => e.toExerciseStep()).toList();
  }

  // Lấy bài tập hiện tại
  ExerciseStep get _currentExercise {
    // Fix lỗi index out of range nếu danh sách rỗng
    if (_allExercises.isEmpty) {
      // Trả về một dummy data hoặc xử lý riêng để tránh crash
      return ExerciseStep(type: ExerciseType.matchWords, instruction: '', data: MatchWordsQuiz(wordMap: {}));
    }

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
        const SnackBar(
          content: Text("Chúc mừng! Bạn đã hoàn thành bài học!"),
          backgroundColor: Colors.green,
        ),
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
              style: TextStyle(color: Colors.white70),
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
    // Kiểm tra an toàn
    if (_allExercises.isEmpty) return const SizedBox.shrink();

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
      default:
        return Center(child: Text("Dạng bài tập chưa hỗ trợ: ${_currentExercise.type}", style: const TextStyle(color: Colors.white)));
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

    // Xử lý trường hợp không load được bài học nào
    if (_currentLesson == null || _allExercises.isEmpty) {
      return Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Chưa có dữ liệu bài học',
                style: TextStyle(color: Colors.white, fontSize: 18),
              ),
              const SizedBox(height: 10),
              const Text(
                'Vui lòng kết nối mạng và mở lại App\nđể tải dữ liệu lần đầu.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey, fontSize: 14),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                  onPressed: () {
                    setState(() { _isLoading = true; });
                    _loadLesson(); // Thử load lại
                  },
                  child: const Text("Thử lại")
              )
            ],
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
