import 'exercise.dart';

class Lesson {
  final int? id;
  final String title;
  final DateTime createdAt;
  final List<LessonPart> parts;

  const Lesson({
    required this.id,
    required this.title,
    required this.createdAt,
    required this.parts,
  });
}

class LessonPart {
  final int? id;
  final int? lessonId;
  final String title;
  final int orderIndex;
  final List<ExerciseStep> exercises;

  const LessonPart({
    required this.id,
    required this.lessonId,
    required this.title,
    required this.orderIndex,
    required this.exercises,
  });
}


