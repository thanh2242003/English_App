import '../entities/user_progress.dart';

abstract class ProgressRepository {
  Future<void> saveProgress({
    required String lessonTitle,
    required int currentPartIndex,
    required int currentExerciseIndex,
    required bool isPartCompleted,
    Map<String, dynamic>? completedParts,
  });

  Future<void> markPartCompleted({
    required String lessonTitle,
    required int partIndex,
    required int totalExercises,
    required int correctAnswers,
  });

  Future<UserProgress?> getCurrentProgress();

  Future<UserProgress?> getProgressForLesson(String lessonTitle);

  Future<void> restartLessonProgress(String lessonTitle);

  Future<void> markLessonCompleted(String lessonTitle);

  Future<List<String>> getCompletedLessons();
}

