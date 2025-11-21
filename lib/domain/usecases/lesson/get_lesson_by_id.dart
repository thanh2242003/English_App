import '../../entities/lesson.dart';
import '../../repositories/lesson_repository.dart';

class GetLessonById {
  final LessonRepository _repository;

  const GetLessonById(this._repository);

  Future<Lesson?> call(int lessonId) {
    return _repository.getLessonById(lessonId);
  }
}


