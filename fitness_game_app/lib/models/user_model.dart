class UserModel {
  final String id;
  final String firebaseUid;
  final String username;
  final String? email;
  final int level;
  final int exp;
  final int coins;
  final int dailyStreak;
  final DateTime? lastLoginDate;

  // Onboarding/Profile data
  final String? fitnessGoal;
  final int? age;
  final double? weightKg;
  final double? heightCm;
  final String? bodyShape;
  final List<String>? physicalLimitations;
  final List<String>? availableEquipment;
  final DateTime? preferredWorkoutTime;

  // Active program
  final String? followingProgramId;
  final Map<String, dynamic>? personalizedBuild;

  UserModel({
    required this.id,
    required this.firebaseUid,
    required this.username,
    this.email,
    this.level = 1,
    this.exp = 0,
    this.coins = 0,
    this.dailyStreak = 0,
    this.lastLoginDate,
    this.fitnessGoal,
    this.age,
    this.weightKg,
    this.heightCm,
    this.bodyShape,
    this.physicalLimitations,
    this.availableEquipment,
    this.preferredWorkoutTime,
    this.followingProgramId,
    this.personalizedBuild,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      firebaseUid: json['firebase_uid'],
      username: json['username'],
      email: json['email'],
      level: json['level'] ?? 1,
      exp: json['exp'] ?? 0,
      coins: json['coins'] ?? 0,
      dailyStreak: json['daily_streak'] ?? 0,
      lastLoginDate: json['last_login_date'] != null
          ? DateTime.parse(json['last_login_date'])
          : null,
      fitnessGoal: json['fitness_goal'],
      age: json['age'],
      weightKg: json['weight_kg']?.toDouble(),
      heightCm: json['height_cm']?.toDouble(),
      bodyShape: json['body_shape'],
      physicalLimitations: json['physical_limitations'] != null
          ? List<String>.from(json['physical_limitations'])
          : null,
      availableEquipment: json['available_equipment'] != null
          ? List<String>.from(json['available_equipment'])
          : null,
      preferredWorkoutTime: json['preferred_workout_time'] != null
          ? DateTime.parse('1970-01-01 ${json['preferred_workout_time']}')
          : null,
      followingProgramId: json['following_program_id'],
      personalizedBuild: json['personalized_build'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'firebase_uid': firebaseUid,
      'username': username,
      'email': email,
      'level': level,
      'exp': exp,
      'coins': coins,
      'daily_streak': dailyStreak,
      'last_login_date': lastLoginDate?.toIso8601String().split('T')[0],
      'fitness_goal': fitnessGoal,
      'age': age,
      'weight_kg': weightKg,
      'height_cm': heightCm,
      'body_shape': bodyShape,
      'physical_limitations': physicalLimitations,
      'available_equipment': availableEquipment,
      'preferred_workout_time': preferredWorkoutTime != null
          ? '${preferredWorkoutTime!.hour.toString().padLeft(2, '0')}:${preferredWorkoutTime!.minute.toString().padLeft(2, '0')}:00'
          : null,
      'following_program_id': followingProgramId,
      'personalized_build': personalizedBuild,
    };
  }

  UserModel copyWith({
    String? id,
    String? firebaseUid,
    String? username,
    String? email,
    int? level,
    int? exp,
    int? coins,
    int? dailyStreak,
    DateTime? lastLoginDate,
    String? fitnessGoal,
    int? age,
    double? weightKg,
    double? heightCm,
    String? bodyShape,
    List<String>? physicalLimitations,
    List<String>? availableEquipment,
    DateTime? preferredWorkoutTime,
    String? followingProgramId,
    Map<String, dynamic>? personalizedBuild,
  }) {
    return UserModel(
      id: id ?? this.id,
      firebaseUid: firebaseUid ?? this.firebaseUid,
      username: username ?? this.username,
      email: email ?? this.email,
      level: level ?? this.level,
      exp: exp ?? this.exp,
      coins: coins ?? this.coins,
      dailyStreak: dailyStreak ?? this.dailyStreak,
      lastLoginDate: lastLoginDate ?? this.lastLoginDate,
      fitnessGoal: fitnessGoal ?? this.fitnessGoal,
      age: age ?? this.age,
      weightKg: weightKg ?? this.weightKg,
      heightCm: heightCm ?? this.heightCm,
      bodyShape: bodyShape ?? this.bodyShape,
      physicalLimitations: physicalLimitations ?? this.physicalLimitations,
      availableEquipment: availableEquipment ?? this.availableEquipment,
      preferredWorkoutTime: preferredWorkoutTime ?? this.preferredWorkoutTime,
      followingProgramId: followingProgramId ?? this.followingProgramId,
      personalizedBuild: personalizedBuild ?? this.personalizedBuild,
    );
  }

  // Helper methods
  int get expRequiredForNextLevel => 100 * level * level;
  double get expProgress => exp / expRequiredForNextLevel;

  bool shouldLevelUp() => exp >= expRequiredForNextLevel;

  UserModel addExp(int amount) {
    int newExp = exp + amount;
    int newLevel = level;

    while (newExp >= (100 * newLevel * newLevel)) {
      newExp -= (100 * newLevel * newLevel);
      newLevel++;
    }

    return copyWith(exp: newExp, level: newLevel);
  }

  UserModel addCoins(int amount) {
    return copyWith(coins: coins + amount);
  }
}
