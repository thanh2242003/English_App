import 'package:english_app/data/offline_data_service.dart';
import 'package:english_app/data/progress_service.dart';
import 'package:english_app/models/database_models.dart';
import 'package:english_app/models/exercise_step.dart';
import 'package:english_app/models/match_word_quiz.dart';
import 'package:english_app/models/translation_quiz.dart';
import 'package:english_app/models/typing_quiz.dart';
import 'package:english_app/models/user_progress.dart';
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
  int _currentPartIndex = 0;
  int _currentExerciseIndex = 0;
  bool _isPartCompleted = false;
  DatabaseLesson? _currentLesson;
  bool _isLoading = true;
  final OfflineDataService _dataService = OfflineDataService();
  final ProgressService _progressService = ProgressService();
  UserProgress? _userProgress;

  @override
  void initState() {
    super.initState();
    _loadLesson();
  }

  Future<void> _loadLesson() async {
    try {
      final lessons = await _dataService.getAllLessons();
      if (lessons.isNotEmpty) {
        _currentLesson = lessons.first;
        
        // Load tiến độ từ Firebase
        _userProgress = await _progressService.getProgressForLesson(_currentLesson!.title);
        
        if (_userProgress != null) {
          // Kiểm tra xem có phải lesson khác không
          if (_userProgress!.lessonTitle != _currentLesson!.title) {
            _showLessonChoiceDialog();
            return;
          }
          
          // Nếu có tiến độ đã lưu, tiếp tục từ đó
          _currentPartIndex = _progressService.getNextPartIndex(_userProgress, _currentLesson!.parts.length);
          _currentExerciseIndex = _progressService.getNextExerciseIndex(_userProgress);
          _isPartCompleted = _progressService.isPartCompleted(_userProgress, _currentPartIndex);
        } else {
          // Nếu chưa có tiến độ, bắt đầu từ đầu
          _currentPartIndex = 0;
          _currentExerciseIndex = 0;
          _isPartCompleted = false;
        }
        
        setState(() {
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
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
    if (_currentLesson == null) return;
    
    await _progressService.saveProgress(
      lessonTitle: _currentLesson!.title,
      currentPartIndex: _currentPartIndex,
      currentExerciseIndex: _currentExerciseIndex,
      isPartCompleted: _isPartCompleted,
      completedParts: _userProgress?.completedParts ?? {},
    );
  }

  // Chuyển sang bài tập tiếp theo
  void _goToNextExercise() {
    setState(() {
      if (_currentExerciseIndex < _currentExercises.length - 1) {
        _currentExerciseIndex++;
        // Không lưu tiến độ sau mỗi exercise
      } else {
        // Đã hoàn thành tất cả các bài tập trong phần này
        // Kiểm tra nếu đang ở part 2 (index = 1) thì hoàn thành bài học luôn
        if (_currentPartIndex == 1) {
          _markPartCompleted();
        } else {
          _isPartCompleted = true;
          _markPartCompleted();
        }
      }
    });
  }

  // Đánh dấu part đã hoàn thành
  Future<void> _markPartCompleted() async {
    if (_currentLesson == null) return;
    
    // Đánh dấu part đã hoàn thành
    await _progressService.markPartCompleted(
      lessonTitle: _currentLesson!.title,
      partIndex: _currentPartIndex,
      totalExercises: _currentExercises.length,
      correctAnswers: _currentExercises.length, // Giả sử tất cả đều đúng
    );
    
    // Lưu tiến độ với trạng thái part đã hoàn thành
    await saveProgress();
    
    // Cập nhật userProgress local
    _userProgress = await _progressService.getProgressForLesson(_currentLesson!.title);
    
    // Kiểm tra nếu đang ở part 2 (index = 1) thì hoàn thành bài học luôn
    if (_currentPartIndex == 1) {
      _handleLessonCompletion();
    }
  }

  // Chuyển sang phần tiếp theo
  void _goToNextPart() {
    setState(() {
      if (_currentLesson != null && _currentPartIndex < _currentLesson!.parts.length - 1) {
        _currentPartIndex++;
        _currentExerciseIndex = 0;
        _isPartCompleted = false;
        // Không cần lưu tiến độ ở đây vì đã lưu trong _markPartCompleted
      } else {
        // Đã hoàn thành tất cả các phần, kết thúc bài học
        _handleLessonCompletion();
      }
    });
  }

  // Xử lý khi hoàn thành toàn bộ bài học
  void _handleLessonCompletion() async {
    if (_currentLesson != null) {
      // Đánh dấu lesson đã hoàn thành
      await _progressService.markLessonCompleted(_currentLesson!.title);
    }
    
    saveProgress();
    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Hoàn thành bài học!")));
      Navigator.of(context).pop();
    }
  }

  // Hiển thị dialog chọn lesson
  void _showLessonChoiceDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.grey[900],
          title: const Text(
            'Tiếp tục bài học',
            style: TextStyle(color: Colors.white),
          ),
          content: Text(
            'Bạn đang có tiến độ của "${_userProgress?.lessonTitle}". Bạn muốn tiếp tục bài học đó hay bắt đầu "${_currentLesson?.title}"?',
            style: const TextStyle(color: Colors.white),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                // Tiếp tục bài học cũ
                _currentLesson = DatabaseLesson(
                  title: _userProgress!.lessonTitle,
                  createdAt: DateTime.now().toIso8601String(),
                  parts: [], // Sẽ load từ database
                );
                _loadLesson();
              },
              child: const Text(
                'Tiếp tục bài cũ',
                style: TextStyle(color: Colors.green),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                // Bắt đầu bài học mới
                _progressService.restartLessonProgress(_currentLesson!.title);
                _currentPartIndex = 0;
                _currentExerciseIndex = 0;
                _isPartCompleted = false;
                setState(() {
                  _isLoading = false;
                });
              },
              child: const Text(
                'Bắt đầu bài mới',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }

  // Xử lý khi người dùng muốn thoát lesson
  void _exitLesson() async {
    try {
      // Chỉ lưu tiến độ nếu đang trong part (chưa hoàn thành)
      if (!_isPartCompleted) {
        await saveProgress();
      }
      
      if (mounted) {
        // Hiển thị dialog xác nhận
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
                'Bạn có chắc chắn muốn thoát? Tiến độ sẽ được lưu và bạn có thể tiếp tục sau.',
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
    } catch (e) {
      if (mounted) {
        Navigator.of(context).pop();
      }
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
    // default:
    //   return const Center(child: Text("Loại bài tập không xác định."));
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

    // Lấy hướng dẫn từ bài tập hiện tại, trừ khi phần đã hoàn thành
    final String instruction = _isPartCompleted
        ? "Làm tốt lắm!"
        : _currentExercise.instruction;

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
            //crossAxisAlignment: CrossAxisAlignment.start,
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
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: _goToNextPart,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    ),
                    child: const Text("Tiếp tục"),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton(
                    onPressed: _exitLesson,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    ),
                    child: const Text("Thoát"),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
