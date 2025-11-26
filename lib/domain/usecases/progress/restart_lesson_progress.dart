import '../../repositories/progress_repository.dart';

class RestartLessonProgress {
  final ProgressRepository _repository;

  const RestartLessonProgress(this._repository);

  Future<void> call(String lessonTitle) {
    return _repository.restartLessonProgress(lessonTitle);
  }
}



