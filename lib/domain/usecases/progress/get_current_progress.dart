import '../../entities/user_progress.dart';
import '../../repositories/progress_repository.dart';

class GetCurrentProgress {
  final ProgressRepository _repository;

  const GetCurrentProgress(this._repository);

  Future<UserProgress?> call() {
    return _repository.getCurrentProgress();
  }
}


