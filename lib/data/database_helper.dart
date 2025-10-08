import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
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
      // Fallback: tạo database mới nếu không copy được
      await _createNewDatabase(dbPath);
    }
  }

  Future<void> _createNewDatabase(String dbPath) async {
    final db = await openDatabase(
      dbPath,
      version: 1,
      onCreate: _onCreate,
    );
    await db.close();
  }

  Future<void> _onCreate(Database db, int version) async {
    // Tạo bảng lessons
    await db.execute('''
      CREATE TABLE lessons (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        created_at TEXT NOT NULL
      )
    ''');

    // Tạo bảng parts
    await db.execute('''
      CREATE TABLE parts (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        lesson_id INTEGER NOT NULL,
        title TEXT NOT NULL,
        order_index INTEGER NOT NULL,
        FOREIGN KEY (lesson_id) REFERENCES lessons (id) ON DELETE CASCADE
      )
    ''');

    // Tạo bảng exercises
    await db.execute('''
      CREATE TABLE exercises (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        part_id INTEGER NOT NULL,
        type TEXT NOT NULL,
        instruction TEXT NOT NULL,
        data TEXT NOT NULL,
        order_index INTEGER NOT NULL,
        FOREIGN KEY (part_id) REFERENCES parts (id) ON DELETE CASCADE
      )
    ''');

    // Tạo bảng match_words
    await db.execute('''
      CREATE TABLE match_words (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        exercise_id INTEGER NOT NULL,
        english_word TEXT NOT NULL,
        vietnamese_word TEXT NOT NULL,
        FOREIGN KEY (exercise_id) REFERENCES exercises (id) ON DELETE CASCADE
      )
    ''');

    // Tạo bảng translation_quizzes
    await db.execute('''
      CREATE TABLE translation_quizzes (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        exercise_id INTEGER NOT NULL,
        image_path TEXT NOT NULL,
        meaning TEXT NOT NULL,
        english_word TEXT NOT NULL,
        options TEXT NOT NULL,
        FOREIGN KEY (exercise_id) REFERENCES exercises (id) ON DELETE CASCADE
      )
    ''');

    // Tạo bảng typing_quizzes
    await db.execute('''
      CREATE TABLE typing_quizzes (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        exercise_id INTEGER NOT NULL,
        vietnamese TEXT NOT NULL,
        english TEXT NOT NULL,
        FOREIGN KEY (exercise_id) REFERENCES exercises (id) ON DELETE CASCADE
      )
    ''');

    // Tạo bảng word_order_quizzes
    await db.execute('''
      CREATE TABLE word_order_quizzes (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        exercise_id INTEGER NOT NULL,
        vietnamese TEXT NOT NULL,
        words TEXT NOT NULL,
        correct_order TEXT NOT NULL,
        FOREIGN KEY (exercise_id) REFERENCES exercises (id) ON DELETE CASCADE
      )
    ''');
  }

  // Lesson operations
  Future<int> insertLesson(String title) async {
    final db = await database;
    return await db.insert('lessons', {
      'title': title,
      'created_at': DateTime.now().toIso8601String(),
    });
  }

  Future<List<Map<String, dynamic>>> getAllLessons() async {
    final db = await database;
    return await db.query('lessons', orderBy: 'id ASC');
  }

  // Part operations
  Future<int> insertPart(int lessonId, String title, int orderIndex) async {
    final db = await database;
    return await db.insert('parts', {
      'lesson_id': lessonId,
      'title': title,
      'order_index': orderIndex,
    });
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

  // Exercise operations
  Future<int> insertExercise(
    int partId,
    String type,
    String instruction,
    String data,
    int orderIndex,
  ) async {
    final db = await database;
    return await db.insert('exercises', {
      'part_id': partId,
      'type': type,
      'instruction': instruction,
      'data': data,
      'order_index': orderIndex,
    });
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

  // Match words operations
  Future<int> insertMatchWord(int exerciseId, String englishWord, String vietnameseWord) async {
    final db = await database;
    return await db.insert('match_words', {
      'exercise_id': exerciseId,
      'english_word': englishWord,
      'vietnamese_word': vietnameseWord,
    });
  }

  Future<List<Map<String, dynamic>>> getMatchWordsByExerciseId(int exerciseId) async {
    final db = await database;
    return await db.query(
      'match_words',
      where: 'exercise_id = ?',
      whereArgs: [exerciseId],
    );
  }

  // Translation quiz operations
  Future<int> insertTranslationQuiz(
    int exerciseId,
    String imagePath,
    String meaning,
    String englishWord,
    List<String> options,
  ) async {
    final db = await database;
    return await db.insert('translation_quizzes', {
      'exercise_id': exerciseId,
      'image_path': imagePath,
      'meaning': meaning,
      'english_word': englishWord,
      'options': jsonEncode(options),
    });
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

  // Typing quiz operations
  Future<int> insertTypingQuiz(int exerciseId, String vietnamese, String english) async {
    final db = await database;
    return await db.insert('typing_quizzes', {
      'exercise_id': exerciseId,
      'vietnamese': vietnamese,
      'english': english,
    });
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

  // Word order quiz operations
  Future<int> insertWordOrderQuiz(
    int exerciseId,
    String vietnamese,
    List<String> words,
    List<String> correctOrder,
  ) async {
    final db = await database;
    return await db.insert('word_order_quizzes', {
      'exercise_id': exerciseId,
      'vietnamese': vietnamese,
      'words': jsonEncode(words),
      'correct_order': jsonEncode(correctOrder),
    });
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

  // Utility methods
  Future<void> clearAllData() async {
    final db = await database;
    await db.delete('word_order_quizzes');
    await db.delete('typing_quizzes');
    await db.delete('translation_quizzes');
    await db.delete('match_words');
    await db.delete('exercises');
    await db.delete('parts');
    await db.delete('lessons');
  }

  Future<void> close() async {
    final db = await database;
    await db.close();
  }
}
