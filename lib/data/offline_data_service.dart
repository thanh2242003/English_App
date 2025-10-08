import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'database_helper.dart';
import '../models/database_models.dart';
import '../models/exercise_step.dart';

class OfflineDataService {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  
  // Getter for testing
  DatabaseHelper get dbHelper => _dbHelper;

  // Initialize preloaded SQLite database
  Future<void> initializeOfflineData() async {
    try {
      // Database sẽ được copy từ assets tự động trong DatabaseHelper
      // Chỉ cần kiểm tra xem có dữ liệu không
      final hasDataResult = await hasData();
      if (!hasDataResult) {
        print('Warning: No data found in preloaded database');
      } else {
        print('Preloaded database initialized successfully');
      }
    } catch (e) {
      print('Error initializing preloaded database: $e');
      rethrow;
    }
  }


  // Load lesson from database
  Future<DatabaseLesson?> loadLesson(int lessonId) async {
    try {
      final lessonMaps = await _dbHelper.getAllLessons();
      if (lessonMaps.isEmpty) return null;
      
      final lessonMap = lessonMaps.firstWhere(
        (map) => map['id'] == lessonId,
        orElse: () => lessonMaps.first,
      );
      
      final lesson = DatabaseLesson.fromMap(lessonMap);
      
      // Load parts
      final partMaps = await _dbHelper.getPartsByLessonId(lesson.id!);
      final parts = <DatabasePart>[];
      
      for (final partMap in partMaps) {
        final part = DatabasePart.fromMap(partMap);
        
        // Load exercises for this part
        final exerciseMaps = await _dbHelper.getExercisesByPartId(part.id!);
        final exercises = <DatabaseExercise>[];
        
        for (final exerciseMap in exerciseMaps) {
          final exercise = DatabaseExercise.fromMap(exerciseMap);
          
          // Load specific exercise data
          await _loadExerciseData(exercise);
          exercises.add(exercise);
        }
        
        parts.add(DatabasePart(
          id: part.id,
          lessonId: part.lessonId,
          title: part.title,
          orderIndex: part.orderIndex,
          exercises: exercises,
        ));
      }
      
      return DatabaseLesson(
        id: lesson.id,
        title: lesson.title,
        createdAt: lesson.createdAt,
        parts: parts,
      );
    } catch (e) {
      print('Error loading lesson: $e');
      return null;
    }
  }

  // Load specific exercise data based on type
  Future<void> _loadExerciseData(DatabaseExercise exercise) async {
    if (exercise.type == ExerciseType.matchWords) {
      final matchWords = await _dbHelper.getMatchWordsByExerciseId(exercise.id!);
      final wordMap = <String, String>{};
      for (final match in matchWords) {
        wordMap[match['english_word']] = match['vietnamese_word'];
      }
      exercise.exerciseData = DatabaseMatchWords(
        exerciseId: exercise.id,
        wordMap: wordMap,
      );
    } else if (exercise.type == ExerciseType.chooseTranslation) {
      final translationData = await _dbHelper.getTranslationQuizByExerciseId(exercise.id!);
      if (translationData != null) {
        exercise.exerciseData = DatabaseTranslationQuiz(
          exerciseId: exercise.id,
          imagePath: translationData['image_path'],
          meaning: translationData['meaning'],
          englishWord: translationData['english_word'],
          options: List<String>.from(jsonDecode(translationData['options'])),
        );
      }
    } else if (exercise.type == ExerciseType.typingQuiz) {
      final typingData = await _dbHelper.getTypingQuizByExerciseId(exercise.id!);
      if (typingData != null) {
        exercise.exerciseData = DatabaseTypingQuiz(
          exerciseId: exercise.id,
          vietnamese: typingData['vietnamese'],
          english: typingData['english'],
        );
      }
    } else if (exercise.type == ExerciseType.wordOrder) {
      final wordOrderData = await _dbHelper.getWordOrderQuizByExerciseId(exercise.id!);
      if (wordOrderData != null) {
        exercise.exerciseData = DatabaseWordOrderQuiz(
          exerciseId: exercise.id,
          vietnamese: wordOrderData['vietnamese'],
          words: List<String>.from(jsonDecode(wordOrderData['words'])),
          correctOrder: List<String>.from(jsonDecode(wordOrderData['correct_order'])),
        );
      }
    }
  }

  // Get all lessons
  Future<List<DatabaseLesson>> getAllLessons() async {
    try {
      final lessonMaps = await _dbHelper.getAllLessons();
      final lessons = <DatabaseLesson>[];
      
      for (final lessonMap in lessonMaps) {
        final lesson = await loadLesson(lessonMap['id']);
        if (lesson != null) {
          lessons.add(lesson);
        }
      }
      
      return lessons;
    } catch (e) {
      print('Error getting all lessons: $e');
      return [];
    }
  }

  // Check if data exists
  Future<bool> hasData() async {
    try {
      final lessons = await _dbHelper.getAllLessons();
      return lessons.isNotEmpty;
    } catch (e) {
      print('Error checking data existence: $e');
      return false;
    }
  }

  // Initialize data if not exists
  Future<void> initializeDataIfNeeded() async {
    final hasExistingData = await hasData();
    if (!hasExistingData) {
      await initializeOfflineData();
    }
  }
}
