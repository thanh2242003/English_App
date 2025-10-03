enum ExerciseType {matchWords, chooseTranslation}

class ExerciseStep {
  final ExerciseType type;
  final String instruction;
  final Object data;

  const ExerciseStep({
   required this.type,
    required this.instruction,
    required this.data,
});
}