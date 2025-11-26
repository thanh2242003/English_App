class UserProgress {
  final String userId;
  final String lessonTitle;
  final int currentPartIndex;
  final int currentExerciseIndex;
  final bool isPartCompleted;
  final DateTime lastUpdated;
  final Map<String, dynamic> completedParts;

  const UserProgress({
    required this.userId,
    required this.lessonTitle,
    required this.currentPartIndex,
    required this.currentExerciseIndex,
    required this.isPartCompleted,
    required this.lastUpdated,
    required this.completedParts,
  });
}



