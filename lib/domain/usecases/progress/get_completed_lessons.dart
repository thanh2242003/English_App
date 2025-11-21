import '../../repositories/progress_repository.dart';

class GetCompletedLessons {
  final ProgressRepository _repository;

  const GetCompletedLessons(this._repository);

  Future<List<String>> call() {
    return _repository.getCompletedLessons();
  }
}


