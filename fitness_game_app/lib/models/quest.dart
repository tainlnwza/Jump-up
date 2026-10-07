class Quest {
  final String id;
  final String title;
  final String? description;
  final String questType; // 'daily', 'weekly', 'special'
  final Map<String, dynamic> requirements;
  final Map<String, dynamic> rewards;
  final DateTime? expiresAt;

  Quest({
    required this.id,
    required this.title,
    this.description,
    required this.questType,
    required this.requirements,
    required this.rewards,
    this.expiresAt,
  });

  factory Quest.fromJson(Map<String, dynamic> json) {
    return Quest(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      questType: json['quest_type'],
      requirements: json['requirements'],
      rewards: json['rewards'],
      expiresAt: json['expires_at'] != null
          ? DateTime.parse(json['expires_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'quest_type': questType,
      'requirements': requirements,
      'rewards': rewards,
      'expires_at': expiresAt?.toIso8601String(),
    };
  }

  bool get isExpired {
    if (expiresAt == null) return false;
    return DateTime.now().isAfter(expiresAt!);
  }

  int? get rewardExp => rewards['exp'] as int?;
  int? get rewardCoins => rewards['coins'] as int?;
}

class UserQuestProgress {
  final String userId;
  final String questId;
  final Quest? quest;
  final Map<String, dynamic>? progress;
  final DateTime? completedAt;

  UserQuestProgress({
    required this.userId,
    required this.questId,
    this.quest,
    this.progress,
    this.completedAt,
  });

  factory UserQuestProgress.fromJson(Map<String, dynamic> json) {
    return UserQuestProgress(
      userId: json['user_id'],
      questId: json['quest_id'],
      quest: json['quests'] != null ? Quest.fromJson(json['quests']) : null,
      progress: json['progress'],
      completedAt: json['completed_at'] != null
          ? DateTime.parse(json['completed_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'quest_id': questId,
      'progress': progress,
      'completed_at': completedAt?.toIso8601String(),
    };
  }

  bool get isCompleted => completedAt != null;

  double getProgressPercentage() {
    if (progress == null || quest == null) return 0.0;

    final requirements = quest!.requirements;
    final type = requirements['type'] as String?;
    final requiredCount = requirements['count'] as int? ?? 1;
    final currentCount = progress!['count'] as int? ?? 0;

    return (currentCount / requiredCount).clamp(0.0, 1.0);
  }
}
