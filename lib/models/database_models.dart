import 'dart:convert';
import 'exercise_step.dart';
import 'translation_quiz.dart';
import 'typing_quiz.dart';
import 'word_order_quiz.dart';
import 'match_word_quiz.dart';

// Database model cho Lesson
class DatabaseLesson {
  final int? id;
  final String title;
  final String createdAt;
  final List<DatabasePart> parts;

  DatabaseLesson({
    this.id,
    required this.title,
    required this.createdAt,
    required this.parts,
  });

  factory DatabaseLesson.fromMap(Map<String, dynamic> map) {
    return DatabaseLesson(
      id: map['id'],
      title: map['title'],
      createdAt: map['created_at'],
      parts: [], // Parts sẽ được load riêng
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'created_at': createdAt,
    };
  }

  // Convert từ Lesson model cũ
  factory DatabaseLesson.fromLesson(Lesson lesson) {
    return DatabaseLesson(
      title: lesson.title,
      createdAt: DateTime.now().toIso8601String(),
      parts: lesson.parts.map((part) => DatabasePart.fromPart(part)).toList(),
    );
  }

  // Convert về Lesson model cũ
  Lesson toLesson() {
    return Lesson(
      title: title,
      parts: parts.map((part) => part.toPart()).toList(),
    );
  }
}

// Database model cho Part
class DatabasePart {
  final int? id;
  final int? lessonId;
  final String title;
  final int orderIndex;
  final List<DatabaseExercise> exercises;

  DatabasePart({
    this.id,
    this.lessonId,
    required this.title,
    required this.orderIndex,
    required this.exercises,
  });

  factory DatabasePart.fromMap(Map<String, dynamic> map) {
    return DatabasePart(
      id: map['id'],
      lessonId: map['lesson_id'],
      title: map['title'],
      orderIndex: map['order_index'],
      exercises: [], // Exercises sẽ được load riêng
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'lesson_id': lessonId,
      'title': title,
      'order_index': orderIndex,
    };
  }

  // Convert từ Part model cũ
  factory DatabasePart.fromPart(Part part) {
    return DatabasePart(
      title: part.title,
      orderIndex: 0, // Sẽ được set khi insert
      exercises: part.exercises.map((exercise) => DatabaseExercise.fromExerciseStep(exercise)).toList(),
    );
  }

  // Convert về Part model cũ
  Part toPart() {
    return Part(
      title: title,
      exercises: exercises.map((exercise) => exercise.toExerciseStep()).toList(),
    );
  }
}

// Database model cho Exercise
class DatabaseExercise {
  final int? id;
  final int? partId;
  final ExerciseType type;
  final String instruction;
  final String data;
  final int orderIndex;
  DatabaseExerciseData? exerciseData;

  DatabaseExercise({
    this.id,
    this.partId,
    required this.type,
    required this.instruction,
    required this.data,
    required this.orderIndex,
    this.exerciseData,
  });

  factory DatabaseExercise.fromMap(Map<String, dynamic> map) {
    return DatabaseExercise(
      id: map['id'],
      partId: map['part_id'],
      type: ExerciseType.values.firstWhere(
        (e) => e.toString().split('.').last == map['type'],
      ),
      instruction: map['instruction'],
      data: map['data'],
      orderIndex: map['order_index'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'part_id': partId,
      'type': type.toString().split('.').last,
      'instruction': instruction,
      'data': data,
      'order_index': orderIndex,
    };
  }

  // Convert từ ExerciseStep model cũ
  factory DatabaseExercise.fromExerciseStep(ExerciseStep exerciseStep) {
    String data = '';
    DatabaseExerciseData? exerciseData;

    switch (exerciseStep.type) {
      case ExerciseType.matchWords:
        final matchQuiz = exerciseStep.data as MatchWordsQuiz;
        data = jsonEncode(matchQuiz.wordMap);
        exerciseData = DatabaseMatchWords.fromMatchWordsQuiz(matchQuiz);
        break;
      case ExerciseType.chooseTranslation:
        final translationQuiz = exerciseStep.data as TranslationQuiz;
        data = jsonEncode({
          'imagePath': translationQuiz.imagePath,
          'meaning': translationQuiz.meaning,
          'englishWord': translationQuiz.englishWord,
          'options': translationQuiz.options,
        });
        exerciseData = DatabaseTranslationQuiz.fromTranslationQuiz(translationQuiz);
        break;
      case ExerciseType.typingQuiz:
        final typingQuiz = exerciseStep.data as TypingQuiz;
        data = jsonEncode({
          'vietnamese': typingQuiz.vietnamese,
          'english': typingQuiz.english,
        });
        exerciseData = DatabaseTypingQuiz.fromTypingQuiz(typingQuiz);
        break;
      case ExerciseType.wordOrder:
        final wordOrderQuiz = exerciseStep.data as WordOrderQuiz;
        data = jsonEncode({
          'vietnamese': wordOrderQuiz.vietnamese,
          'words': wordOrderQuiz.words,
          'correctOrder': wordOrderQuiz.correctOrder,
        });
        exerciseData = DatabaseWordOrderQuiz.fromWordOrderQuiz(wordOrderQuiz);
        break;
    }

    return DatabaseExercise(
      type: exerciseStep.type,
      instruction: exerciseStep.instruction,
      data: data,
      orderIndex: 0, // Sẽ được set khi insert
      exerciseData: exerciseData,
    );
  }

  // Convert về ExerciseStep model cũ
  ExerciseStep toExerciseStep() {
    Object data;

    switch (type) {
      case ExerciseType.matchWords:
        final matchData = exerciseData as DatabaseMatchWords?;
        data = matchData?.toMatchWordsQuiz() ?? MatchWordsQuiz(wordMap: {});
        break;
      case ExerciseType.chooseTranslation:
        final translationData = exerciseData as DatabaseTranslationQuiz?;
        data = translationData?.toTranslationQuiz() ?? TranslationQuiz(
          imagePath: '',
          meaning: '',
          englishWord: '',
          options: [],
        );
        break;
      case ExerciseType.typingQuiz:
        final typingData = exerciseData as DatabaseTypingQuiz?;
        data = typingData?.toTypingQuiz() ?? TypingQuiz(
          vietnamese: '',
          english: '',
        );
        break;
      case ExerciseType.wordOrder:
        final wordOrderData = exerciseData as DatabaseWordOrderQuiz?;
        data = wordOrderData?.toWordOrderQuiz() ?? WordOrderQuiz(
          vietnamese: '',
          words: [],
          correctOrder: [],
        );
        break;
    }

    return ExerciseStep(
      type: type,
      instruction: instruction,
      data: data,
    );
  }
}

// Abstract class cho exercise data
abstract class DatabaseExerciseData {}

// Database model cho MatchWords
class DatabaseMatchWords extends DatabaseExerciseData {
  final int? exerciseId;
  final Map<String, String> wordMap;

  DatabaseMatchWords({
    this.exerciseId,
    required this.wordMap,
  });

  factory DatabaseMatchWords.fromMatchWordsQuiz(MatchWordsQuiz quiz) {
    return DatabaseMatchWords(wordMap: quiz.wordMap);
  }

  MatchWordsQuiz toMatchWordsQuiz() {
    return MatchWordsQuiz(wordMap: wordMap);
  }
}

// Database model cho TranslationQuiz
class DatabaseTranslationQuiz extends DatabaseExerciseData {
  final int? exerciseId;
  final String imagePath;
  final String meaning;
  final String englishWord;
  final List<String> options;

  DatabaseTranslationQuiz({
    this.exerciseId,
    required this.imagePath,
    required this.meaning,
    required this.englishWord,
    required this.options,
  });

  factory DatabaseTranslationQuiz.fromTranslationQuiz(TranslationQuiz quiz) {
    return DatabaseTranslationQuiz(
      imagePath: quiz.imagePath,
      meaning: quiz.meaning,
      englishWord: quiz.englishWord,
      options: quiz.options,
    );
  }

  TranslationQuiz toTranslationQuiz() {
    return TranslationQuiz(
      imagePath: imagePath,
      meaning: meaning,
      englishWord: englishWord,
      options: options,
    );
  }
}

// Database model cho TypingQuiz
class DatabaseTypingQuiz extends DatabaseExerciseData {
  final int? exerciseId;
  final String vietnamese;
  final String english;

  DatabaseTypingQuiz({
    this.exerciseId,
    required this.vietnamese,
    required this.english,
  });

  factory DatabaseTypingQuiz.fromTypingQuiz(TypingQuiz quiz) {
    return DatabaseTypingQuiz(
      vietnamese: quiz.vietnamese,
      english: quiz.english,
    );
  }

  TypingQuiz toTypingQuiz() {
    return TypingQuiz(
      vietnamese: vietnamese,
      english: english,
    );
  }
}

// Database model cho WordOrderQuiz
class DatabaseWordOrderQuiz extends DatabaseExerciseData {
  final int? exerciseId;
  final String vietnamese;
  final List<String> words;
  final List<String> correctOrder;

  DatabaseWordOrderQuiz({
    this.exerciseId,
    required this.vietnamese,
    required this.words,
    required this.correctOrder,
  });

  factory DatabaseWordOrderQuiz.fromWordOrderQuiz(WordOrderQuiz quiz) {
    return DatabaseWordOrderQuiz(
      vietnamese: quiz.vietnamese,
      words: quiz.words,
      correctOrder: quiz.correctOrder,
    );
  }

  WordOrderQuiz toWordOrderQuiz() {
    return WordOrderQuiz(
      vietnamese: vietnamese,
      words: words,
      correctOrder: correctOrder,
    );
  }
}
