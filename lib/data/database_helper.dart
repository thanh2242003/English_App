import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:flutter/services.dart';
import 'dart:io';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'english_app.db');
    
    // Kiểm tra xem database đã tồn tại chưa
    if (!await databaseExists(path)) {
      // Copy database từ assets
      await _copyDatabaseFromAssets(path);
    }
    
    return await openDatabase(path);
  }

  Future<void> _copyDatabaseFromAssets(String dbPath) async {
    try {
      // Tạo thư mục nếu chưa tồn tại
      await Directory(dirname(dbPath)).create(recursive: true);
      
      // Copy database từ assets
      ByteData data = await rootBundle.load('assets/database/english_app.db');
      List<int> bytes = data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
      await File(dbPath).writeAsBytes(bytes);
      
      print('Database copied from assets successfully');
    } catch (e) {
      print('Error copying database from assets: $e');
    }
  }


  Future<List<Map<String, dynamic>>> getAllLessons() async {
    final db = await database;
    return await db.query('lessons', orderBy: 'id ASC');
  }

  Future<List<Map<String, dynamic>>> getPartsByLessonId(int lessonId) async {
    final db = await database;
    return await db.query(
      'parts',
      where: 'lesson_id = ?',
      whereArgs: [lessonId],
      orderBy: 'order_index ASC',
    );
  }

  Future<List<Map<String, dynamic>>> getExercisesByPartId(int partId) async {
    final db = await database;
    return await db.query(
      'exercises',
      where: 'part_id = ?',
      whereArgs: [partId],
      orderBy: 'order_index ASC',
    );
  }


  Future<List<Map<String, dynamic>>> getMatchWordsByExerciseId(int exerciseId) async {
    final db = await database;
    return await db.query(
      'match_words',
      where: 'exercise_id = ?',
      whereArgs: [exerciseId],
    );
  }


  Future<Map<String, dynamic>?> getTranslationQuizByExerciseId(int exerciseId) async {
    final db = await database;
    final result = await db.query(
      'translation_quizzes',
      where: 'exercise_id = ?',
      whereArgs: [exerciseId],
      limit: 1,
    );
    return result.isNotEmpty ? result.first : null;
  }

  Future<Map<String, dynamic>?> getTypingQuizByExerciseId(int exerciseId) async {
    final db = await database;
    final result = await db.query(
      'typing_quizzes',
      where: 'exercise_id = ?',
      whereArgs: [exerciseId],
      limit: 1,
    );
    return result.isNotEmpty ? result.first : null;
  }


  Future<Map<String, dynamic>?> getWordOrderQuizByExerciseId(int exerciseId) async {
    final db = await database;
    final result = await db.query(
      'word_order_quizzes',
      where: 'exercise_id = ?',
      whereArgs: [exerciseId],
      limit: 1,
    );
    return result.isNotEmpty ? result.first : null;
  }


  Future<void> close() async {
    final db = await database;
    await db.close();
  }
}
