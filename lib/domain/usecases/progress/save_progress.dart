import '../../repositories/progress_repository.dart';

class SaveProgress {
  final ProgressRepository _repository;

  const SaveProgress(this._repository);

  Future<void> call({
    required String lessonTitle,
    required int currentPartIndex,
    required int currentExerciseIndex,
    required bool isPartCompleted,
    Map<String, dynamic>? completedParts,
  }) {
    return _repository.saveProgress(
      lessonTitle: lessonTitle,
      currentPartIndex: currentPartIndex,
      currentExerciseIndex: currentExerciseIndex,
      isPartCompleted: isPartCompleted,
      completedParts: completedParts,
    );
  }
}



