import '../../repositories/progress_repository.dart';

class MarkPartCompleted {
  final ProgressRepository _repository;

  const MarkPartCompleted(this._repository);

  Future<void> call({
    required String lessonTitle,
    required int partIndex,
    required int totalExercises,
    required int correctAnswers,
  }) {
    return _repository.markPartCompleted(
      lessonTitle: lessonTitle,
      partIndex: partIndex,
      totalExercises: totalExercises,
      correctAnswers: correctAnswers,
    );
  }
}



