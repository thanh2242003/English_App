import '../../entities/user_progress.dart';
import '../../repositories/progress_repository.dart';

class GetProgressForLesson {
  final ProgressRepository _repository;

  const GetProgressForLesson(this._repository);

  Future<UserProgress?> call(String lessonTitle) {
    return _repository.getProgressForLesson(lessonTitle);
  }
}


