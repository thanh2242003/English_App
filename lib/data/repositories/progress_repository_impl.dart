import '../../domain/entities/user_progress.dart';
import '../../domain/repositories/progress_repository.dart';
import '../models/user_progress_model.dart';
import '../progress_service.dart';

class ProgressRepositoryImpl implements ProgressRepository {
  final ProgressService _progressService;

  ProgressRepositoryImpl(this._progressService);

  @override
  Future<UserProgress?> getCurrentProgress() async {
    final UserProgressModel? progress = await _progressService.getCurrentProgress();
    return progress?.toDomain();
  }

  @override
  Future<UserProgress?> getProgressForLesson(String lessonTitle) async {
    final UserProgressModel? progress = await _progressService.getProgressForLesson(lessonTitle);
    return progress?.toDomain();
  }

  @override
  Future<List<String>> getCompletedLessons() {
    return _progressService.getCompletedLessons();
  }

  @override
  Future<void> markLessonCompleted(String lessonTitle) {
    return _progressService.markLessonCompleted(lessonTitle);
  }

  @override
  Future<void> markPartCompleted({
    required String lessonTitle,
    required int partIndex,
    required int totalExercises,
    required int correctAnswers,
  }) {
    return _progressService.markPartCompleted(
      lessonTitle: lessonTitle,
      partIndex: partIndex,
      totalExercises: totalExercises,
      correctAnswers: correctAnswers,
    );
  }

  @override
  Future<void> restartLessonProgress(String lessonTitle) {
    return _progressService.restartLessonProgress(lessonTitle);
  }

  @override
  Future<void> saveProgress({
    required String lessonTitle,
    required int currentPartIndex,
    required int currentExerciseIndex,
    required bool isPartCompleted,
    Map<String, dynamic>? completedParts,
  }) {
    return _progressService.saveProgress(
      lessonTitle: lessonTitle,
      currentPartIndex: currentPartIndex,
      currentExerciseIndex: currentExerciseIndex,
      isPartCompleted: isPartCompleted,
      completedParts: completedParts,
    );
  }
}

