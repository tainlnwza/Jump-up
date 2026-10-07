class WorkoutSession {
  final String id;
  final String userId;
  final String sessionType; // 'game' or 'workout'
  final DateTime startedAt;
  final DateTime? completedAt;
  final int expEarned;
  final int coinsEarned;
  final Map<String, dynamic>? posesCompleted;
  final bool? bossDefeated;
  final String? programId;
  final Map<String, dynamic>? exercisesCompleted;

  WorkoutSession({
    required this.id,
    required this.userId,
    required this.sessionType,
    required this.startedAt,
    this.completedAt,
    this.expEarned = 0,
    this.coinsEarned = 0,
    this.posesCompleted,
    this.bossDefeated,
    this.programId,
    this.exercisesCompleted,
  });

  factory WorkoutSession.fromJson(Map<String, dynamic> json) {
    return WorkoutSession(
      id: json['id'],
      userId: json['user_id'],
      sessionType: json['session_type'],
      startedAt: DateTime.parse(json['started_at']),
      completedAt: json['completed_at'] != null
          ? DateTime.parse(json['completed_at'])
          : null,
      expEarned: json['exp_earned'] ?? 0,
      coinsEarned: json['coins_earned'] ?? 0,
      posesCompleted: json['poses_completed'],
      bossDefeated: json['boss_defeated'],
      programId: json['program_id'],
      exercisesCompleted: json['exercises_completed'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'session_type': sessionType,
      'started_at': startedAt.toIso8601String(),
      'completed_at': completedAt?.toIso8601String(),
      'exp_earned': expEarned,
      'coins_earned': coinsEarned,
      'poses_completed': posesCompleted,
      'boss_defeated': bossDefeated,
      'program_id': programId,
      'exercises_completed': exercisesCompleted,
    };
  }

  Duration? get duration {
    if (completedAt == null) return null;
    return completedAt!.difference(startedAt);
  }

  bool get isCompleted => completedAt != null;
}
