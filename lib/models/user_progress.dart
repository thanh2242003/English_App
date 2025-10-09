import 'package:cloud_firestore/cloud_firestore.dart';

class UserProgress {
  final String userId;
  final String lessonTitle;
  final int currentPartIndex;
  final int currentExerciseIndex;
  final bool isPartCompleted;
  final DateTime lastUpdated;
  final Map<String, dynamic> completedParts; // partIndex -> completion data

  UserProgress({
    required this.userId,
    required this.lessonTitle,
    required this.currentPartIndex,
    required this.currentExerciseIndex,
    required this.isPartCompleted,
    required this.lastUpdated,
    required this.completedParts,
  });

  factory UserProgress.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return UserProgress(
      userId: doc.id,
      lessonTitle: data['lessonTitle'] ?? '',
      currentPartIndex: data['currentPartIndex'] ?? 0,
      currentExerciseIndex: data['currentExerciseIndex'] ?? 0,
      isPartCompleted: data['isPartCompleted'] ?? false,
      lastUpdated: data['lastUpdated'] != null
          ? (data['lastUpdated'] as Timestamp).toDate()
          : DateTime.now(),
      completedParts: Map<String, dynamic>.from(data['completedParts'] ?? {}),
    );
  }
}