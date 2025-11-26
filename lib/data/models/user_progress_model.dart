import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/user_progress.dart';

class UserProgressModel {
  final String userId;
  final String lessonTitle;
  final int currentPartIndex;
  final int currentExerciseIndex;
  final bool isPartCompleted;
  final Timestamp? lastUpdated;
  final Map<String, dynamic> completedParts;

  const UserProgressModel({
    required this.userId,
    required this.lessonTitle,
    required this.currentPartIndex,
    required this.currentExerciseIndex,
    required this.isPartCompleted,
    required this.lastUpdated,
    required this.completedParts,
  });

  factory UserProgressModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return UserProgressModel(
      userId: doc.id,
      lessonTitle: data['lessonTitle'] ?? '',
      currentPartIndex: data['currentPartIndex'] ?? 0,
      currentExerciseIndex: data['currentExerciseIndex'] ?? 0,
      isPartCompleted: data['isPartCompleted'] ?? false,
      lastUpdated: data['lastUpdated'] as Timestamp?,
      completedParts: Map<String, dynamic>.from(data['completedParts'] ?? {}),
    );
  }

  UserProgress toDomain() {
    return UserProgress(
      userId: userId,
      lessonTitle: lessonTitle,
      currentPartIndex: currentPartIndex,
      currentExerciseIndex: currentExerciseIndex,
      isPartCompleted: isPartCompleted,
      lastUpdated: lastUpdated?.toDate() ?? DateTime.now(),
      completedParts: completedParts,
    );
  }
}



