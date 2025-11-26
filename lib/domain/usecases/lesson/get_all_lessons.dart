import '../../entities/lesson.dart';
import '../../repositories/lesson_repository.dart';

class GetAllLessons {
  final LessonRepository _repository;

  const GetAllLessons(this._repository);

  Future<List<Lesson>> call() {
    return _repository.getAllLessons();
  }
}



