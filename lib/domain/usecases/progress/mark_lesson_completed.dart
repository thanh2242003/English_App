import '../../repositories/progress_repository.dart';

class MarkLessonCompleted {
  final ProgressRepository _repository;

  const MarkLessonCompleted(this._repository);

  Future<void> call(String lessonTitle) {
    return _repository.markLessonCompleted(lessonTitle);
  }
}



