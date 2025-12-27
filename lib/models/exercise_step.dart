enum ExerciseType {matchWords, chooseTranslation, typingQuiz, wordOrder}

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

class Part {
  final String title; // Tên phần
  final List<ExerciseStep> exercises; // 3 dạng bài
  Part({required this.title, required this.exercises});
}

class Lesson {
  final String title; // Tên bài học
  final List<Part> parts; // 3 phần
  Lesson({required this.title, required this.parts});
}