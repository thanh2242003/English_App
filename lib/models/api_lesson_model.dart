import 'package:english_app/models/exercise_step.dart';
import 'package:english_app/models/match_word_quiz.dart';
import 'package:english_app/models/translation_quiz.dart';
import 'package:english_app/models/typing_quiz.dart';
import 'package:english_app/models/word_order_quiz.dart';

class ApiLesson {
  final String id;
  final String title;
  final String createdAt;
  final List<ApiExercise> exercises;

  ApiLesson({
    required this.id,
    required this.title,
    required this.createdAt,
    required this.exercises,
  });

  factory ApiLesson.fromJson(Map<String, dynamic> json) {
    var exerciseList = json['exercises'] as List;
    List<ApiExercise> exercises = exerciseList.map((i) => ApiExercise.fromJson(i)).toList();

    return ApiLesson(
      id: json['_id'],
      title: json['title'],
      createdAt: json['createdAt'],
      exercises: exercises,
    );
  }
}

class ApiExercise {
  final ExerciseType type;
  final String instruction;
  final int order;
  final dynamic data;

  ApiExercise({
    required this.type,
    required this.instruction,
    required this.order,
    required this.data,
  });

  factory ApiExercise.fromJson(Map<String, dynamic> json) {
    return ApiExercise(
      type: ExerciseType.values.firstWhere(
            (e) => e.toString().split('.').last == json['type'],
        orElse: () => ExerciseType.matchWords, // Default fallback
      ),
      instruction: json['instruction'],
      order: json['order'],
      data: json['data'],
    );
  }

  ExerciseStep toExerciseStep() {
    Object stepData;
    switch (type) {
      case ExerciseType.matchWords:
        final listData = data as List;
        Map<String, String> wordMap = {};
        for (var item in listData) {
          wordMap[item['english']] = item['vietnamese'];
        }
        stepData = MatchWordsQuiz(wordMap: wordMap);
        break;

      case ExerciseType.chooseTranslation:
        final mapData = data as Map<String, dynamic>;
        stepData = TranslationQuiz(
          imagePath: mapData['imagePath'],
          meaning: mapData['meaning'],
          englishWord: mapData['englishWord'],
          options: List<String>.from(mapData['options']),
        );
        break;

      case ExerciseType.typingQuiz:
        final mapData = data as Map<String, dynamic>;
        stepData = TypingQuiz(
          vietnamese: mapData['vietnamese'],
          english: mapData['english'],
        );
        break;

      case ExerciseType.wordOrder:
        final mapData = data as Map<String, dynamic>;
        stepData = WordOrderQuiz(
          vietnamese: mapData['vietnamese'],
          words: List<String>.from(mapData['words']),
          correctOrder: List<String>.from(mapData['correctOrder']),
        );
        break;
      default:
        stepData = MatchWordsQuiz(wordMap: {});
    }

    return ExerciseStep(
      type: type,
      instruction: instruction,
      data: stepData,
    );
  }
}
