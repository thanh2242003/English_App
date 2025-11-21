import '../../domain/entities/lesson.dart';
import '../../domain/repositories/lesson_repository.dart';
import '../models/database_models.dart';
import '../offline_data_service.dart';

class LessonRepositoryImpl implements LessonRepository {
  final OfflineDataService _offlineDataService;

  LessonRepositoryImpl(this._offlineDataService);

  @override
  Future<List<Lesson>> getAllLessons() async {
    final lessons = await _offlineDataService.getAllLessons();
    return lessons.map(_mapLesson).toList();
  }

  @override
  Future<Lesson?> getLessonById(int lessonId) async {
    final lesson = await _offlineDataService.loadLesson(lessonId);
    if (lesson == null) return null;
    return _mapLesson(lesson);
  }

  @override
  Future<void> initializeOfflineData() {
    return _offlineDataService.initializeOfflineData();
  }

  Lesson _mapLesson(DatabaseLesson lesson) {
    final parts = lesson.parts
        .map(
          (part) => LessonPart(
            id: part.id,
            lessonId: part.lessonId,
            title: part.title,
            orderIndex: part.orderIndex,
            exercises: part.exercises.map((exercise) => exercise.toExerciseStep()).toList(),
          ),
        )
        .toList();

    return Lesson(
      id: lesson.id,
      title: lesson.title,
      createdAt: DateTime.tryParse(lesson.createdAt) ?? DateTime.now(),
      parts: parts,
    );
  }
}


