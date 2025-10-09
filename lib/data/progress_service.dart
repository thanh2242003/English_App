import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_progress.dart';

class ProgressService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;


  // Lưu tiến độ hiện tại của user
  Future<void> saveProgress({
    required String lessonTitle,
    required int currentPartIndex,
    required int currentExerciseIndex,
    required bool isPartCompleted,
    Map<String, dynamic>? completedParts,
  }) async {
    final user = _auth.currentUser;
    if (user == null) {
      return;
    }

    final progressRef = _firestore
        .collection('users')
        .doc(user.uid);

    final progressData = {
      'lessonTitle': lessonTitle,
      'currentPartIndex': currentPartIndex,
      'currentExerciseIndex': currentExerciseIndex,
      'isPartCompleted': isPartCompleted,
      'lastUpdated': FieldValue.serverTimestamp(),
      'completedParts': completedParts ?? {},
    };

    try {
      await progressRef.set(progressData, SetOptions(merge: true));
    } catch (e) {
      // Error saving progress
    }
  }

  // Lưu khi hoàn thành một part
  Future<void> markPartCompleted({
    required String lessonTitle,
    required int partIndex,
    required int totalExercises,
    required int correctAnswers,
  }) async {
    final user = _auth.currentUser;
    if (user == null) return;

    final progressRef = _firestore
        .collection('users')
        .doc(user.uid);

    final partCompletion = {
      'partIndex': partIndex,
      'completedAt': FieldValue.serverTimestamp(),
      'totalExercises': totalExercises,
      'correctAnswers': correctAnswers,
    };

    await progressRef.update({
      'completedParts.$partIndex': partCompletion,
      'lastUpdated': FieldValue.serverTimestamp(),
    });
  }

  // Lấy tiến độ hiện tại của user
  Future<UserProgress?> getCurrentProgress() async {
    final user = _auth.currentUser;
    if (user == null) return null;

    try {
      final doc = await _firestore
          .collection('users')
          .doc(user.uid)
          .get();

      if (doc.exists) {
        return UserProgress.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // Lấy tiến độ cho một lesson cụ thể
  Future<UserProgress?> getProgressForLesson(String lessonTitle) async {
    final user = _auth.currentUser;
    if (user == null) {
      return null;
    }

    try {
      final doc = await _firestore
          .collection('users')
          .doc(user.uid)
          .get();

      if (doc.exists) {
        final progress = UserProgress.fromFirestore(doc);
        
        // Kiểm tra xem có dữ liệu tiến độ không
        if (progress.lessonTitle.isNotEmpty && progress.currentPartIndex >= 0) {
          return progress;
        }
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // Kiểm tra xem part đã được hoàn thành chưa
  bool isPartCompleted(UserProgress? progress, int partIndex) {
    if (progress == null) return false;
    return progress.completedParts.containsKey(partIndex.toString());
  }

  // Lấy part tiếp theo cần học
  int getNextPartIndex(UserProgress? progress, int totalParts) {
    if (progress == null) return 0;

    // Nếu part hiện tại đã hoàn thành, chuyển sang part tiếp theo
    if (progress.isPartCompleted) {
      int nextPart = progress.currentPartIndex + 1;
      return nextPart < totalParts ? nextPart : progress.currentPartIndex;
    }
    
    // Nếu chưa hoàn thành, tiếp tục part hiện tại
    return progress.currentPartIndex;
  }

  // Lấy exercise index tiếp theo trong part
  int getNextExerciseIndex(UserProgress? progress) {
    if (progress == null) return 0;
    
    // Luôn bắt đầu từ exercise đầu tiên của part
    return 0;
  }


  // Reset tiến độ học nhưng giữ lại trạng thái đã hoàn thành lesson
  Future<void> restartLessonProgress(String lessonTitle) async {
    final user = _auth.currentUser;
    if (user == null) return;

    await _firestore
        .collection('users')
        .doc(user.uid)
        .update({
      'lessonTitle': lessonTitle,
      'currentPartIndex': 0,
      'currentExerciseIndex': 0,
      'isPartCompleted': false,
      'completedParts': {},
      'lastUpdated': FieldValue.serverTimestamp(),
      // KHÔNG xóa completedLessons - giữ lại trạng thái đã hoàn thành
    });
  }

  // Lấy danh sách tất cả lesson đã hoàn thành
  Future<List<String>> getCompletedLessons() async {
    final user = _auth.currentUser;
    if (user == null) return [];

    try {
      final doc = await _firestore
          .collection('users')
          .doc(user.uid)
          .get();

      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        final completedLessons = data['completedLessons'] as List<dynamic>? ?? [];
        return completedLessons.cast<String>();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  // Đánh dấu lesson đã hoàn thành
  Future<void> markLessonCompleted(String lessonTitle) async {
    final user = _auth.currentUser;
    if (user == null) return;

    final progressRef = _firestore
        .collection('users')
        .doc(user.uid);

    await progressRef.update({
      'completedLessons': FieldValue.arrayUnion([lessonTitle]),
      'lastUpdated': FieldValue.serverTimestamp(),
    });
  }
}
