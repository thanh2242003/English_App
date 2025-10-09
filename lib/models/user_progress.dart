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

  Map<String, dynamic> toFirestore() {
    return {
      'lessonTitle': lessonTitle,
      'currentPartIndex': currentPartIndex,
      'currentExerciseIndex': currentExerciseIndex,
      'isPartCompleted': isPartCompleted,
      'lastUpdated': Timestamp.fromDate(lastUpdated),
      'completedParts': completedParts,
    };
  }

  UserProgress copyWith({
    String? lessonTitle,
    int? currentPartIndex,
    int? currentExerciseIndex,
    bool? isPartCompleted,
    DateTime? lastUpdated,
    Map<String, dynamic>? completedParts,
  }) {
    return UserProgress(
      userId: userId,
      lessonTitle: lessonTitle ?? this.lessonTitle,
      currentPartIndex: currentPartIndex ?? this.currentPartIndex,
      currentExerciseIndex: currentExerciseIndex ?? this.currentExerciseIndex,
      isPartCompleted: isPartCompleted ?? this.isPartCompleted,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      completedParts: completedParts ?? this.completedParts,
    );
  }
}

class PartCompletion {
  final int partIndex;
  final DateTime completedAt;
  final int totalExercises;
  final int correctAnswers;

  PartCompletion({
    required this.partIndex,
    required this.completedAt,
    required this.totalExercises,
    required this.correctAnswers,
  });

  factory PartCompletion.fromMap(Map<String, dynamic> map) {
    return PartCompletion(
      partIndex: map['partIndex'],
      completedAt: (map['completedAt'] as Timestamp).toDate(),
      totalExercises: map['totalExercises'],
      correctAnswers: map['correctAnswers'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'partIndex': partIndex,
      'completedAt': Timestamp.fromDate(completedAt),
      'totalExercises': totalExercises,
      'correctAnswers': correctAnswers,
    };
  }
}
