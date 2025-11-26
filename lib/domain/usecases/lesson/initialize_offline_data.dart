import '../../repositories/lesson_repository.dart';

class InitializeOfflineData {
  final LessonRepository _repository;

  const InitializeOfflineData(this._repository);

  Future<void> call() {
    return _repository.initializeOfflineData();
  }
}



