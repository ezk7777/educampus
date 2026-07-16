class UserProgress {
  final String courseId;
  final List<String> completedLessonIds;
  final Map<String, int> quizScores; // quizId -> score
  final Map<String, Map<String, dynamic>> quizStates; // quizId -> state { 'currentQuestionIndex': int, 'selectedAnswers': List<int> }

  const UserProgress({
    required this.courseId,
    required this.completedLessonIds,
    required this.quizScores,
    required this.quizStates,
  });

  factory UserProgress.empty(String courseId) {
    return UserProgress(
      courseId: courseId,
      completedLessonIds: const [],
      quizScores: const {},
      quizStates: const {},
    );
  }

  double getProgressPercentage(int totalLessonsCount) {
    if (totalLessonsCount == 0) return 0.0;
    return (completedLessonIds.length / totalLessonsCount).clamp(0.0, 1.0);
  }

  UserProgress copyWith({
    List<String>? completedLessonIds,
    Map<String, int>? quizScores,
    Map<String, Map<String, dynamic>>? quizStates,
  }) {
    return UserProgress(
      courseId: courseId,
      completedLessonIds: completedLessonIds ?? this.completedLessonIds,
      quizScores: quizScores ?? this.quizScores,
      quizStates: quizStates ?? this.quizStates,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'courseId': courseId,
      'completedLessonIds': completedLessonIds,
      'quizScores': quizScores,
      'quizStates': quizStates,
    };
  }

  factory UserProgress.fromMap(Map<String, dynamic> map) {
    final completed = List<String>.from(map['completedLessonIds'] ?? const []);
    
    final scoresMap = map['quizScores'] as Map<dynamic, dynamic>? ?? const {};
    final quizScores = scoresMap.map((key, value) => MapEntry(key.toString(), value as int));

    final statesMap = map['quizStates'] as Map<dynamic, dynamic>? ?? const {};
    final quizStates = statesMap.map((key, value) {
      final valueMap = Map<String, dynamic>.from(value as Map<dynamic, dynamic>? ?? const {});
      return MapEntry(key.toString(), valueMap);
    });

    return UserProgress(
      courseId: map['courseId'] as String? ?? '',
      completedLessonIds: completed,
      quizScores: quizScores,
      quizStates: quizStates,
    );
  }
}
