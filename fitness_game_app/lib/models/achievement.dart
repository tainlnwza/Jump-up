class Achievement {
  final String id;
  final String name;
  final String? description;
  final String? iconUrl;
  final Map<String, dynamic> unlockCriteria;

  Achievement({
    required this.id,
    required this.name,
    this.description,
    this.iconUrl,
    required this.unlockCriteria,
  });

  factory Achievement.fromJson(Map<String, dynamic> json) {
    return Achievement(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      iconUrl: json['icon_url'],
      unlockCriteria: json['unlock_criteria'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'icon_url': iconUrl,
      'unlock_criteria': unlockCriteria,
    };
  }
}

class UserAchievement {
  final String userId;
  final String achievementId;
  final Achievement? achievement;
  final DateTime unlockedAt;

  UserAchievement({
    required this.userId,
    required this.achievementId,
    this.achievement,
    required this.unlockedAt,
  });

  factory UserAchievement.fromJson(Map<String, dynamic> json) {
    return UserAchievement(
      userId: json['user_id'],
      achievementId: json['achievement_id'],
      achievement: json['achievements'] != null
          ? Achievement.fromJson(json['achievements'])
          : null,
      unlockedAt: DateTime.parse(json['unlocked_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'achievement_id': achievementId,
      'unlocked_at': unlockedAt.toIso8601String(),
    };
  }
}
