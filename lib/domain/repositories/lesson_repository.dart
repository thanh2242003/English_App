import '../entities/lesson.dart';

abstract class LessonRepository {
  Future<List<Lesson>> getAllLessons();

  Future<Lesson?> getLessonById(int lessonId);

  Future<void> initializeOfflineData();
}


