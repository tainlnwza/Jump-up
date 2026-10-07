class ExpertProgram {
  final String id;
  final String creatorId;
  final String title;
  final String? description;
  final String difficultyLevel; // 'beginner', 'intermediate', 'advanced'
  final int? durationWeeks;
  final List<Exercise> exercises;
  final String? thumbnailUrl;
  final List<String>? videoUrls;
  final List<String>? imageUrls;
  final int followersCount;
  final DateTime createdAt;

  ExpertProgram({
    required this.id,
    required this.creatorId,
    required this.title,
    this.description,
    required this.difficultyLevel,
    this.durationWeeks,
    required this.exercises,
    this.thumbnailUrl,
    this.videoUrls,
    this.imageUrls,
    this.followersCount = 0,
    required this.createdAt,
  });

  factory ExpertProgram.fromJson(Map<String, dynamic> json) {
    return ExpertProgram(
      id: json['id'],
      creatorId: json['creator_id'],
      title: json['title'],
      description: json['description'],
      difficultyLevel: json['difficulty_level'],
      durationWeeks: json['duration_weeks'],
      exercises: (json['exercises'] as List)
          .map((e) => Exercise.fromJson(e))
          .toList(),
      thumbnailUrl: json['thumbnail_url'],
      videoUrls: json['video_urls'] != null
          ? List<String>.from(json['video_urls'])
          : null,
      imageUrls: json['image_urls'] != null
          ? List<String>.from(json['image_urls'])
          : null,
      followersCount: json['followers_count'] ?? 0,
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'creator_id': creatorId,
      'title': title,
      'description': description,
      'difficulty_level': difficultyLevel,
      'duration_weeks': durationWeeks,
      'exercises': exercises.map((e) => e.toJson()).toList(),
      'thumbnail_url': thumbnailUrl,
      'video_urls': videoUrls,
      'image_urls': imageUrls,
      'followers_count': followersCount,
      'created_at': createdAt.toIso8601String(),
    };
  }
}

class Exercise {
  final String name;
  final int? duration; // in seconds
  final int? reps;
  final int? sets;
  final String? videoUrl;
  final String? imageUrl;
  final String? description;

  Exercise({
    required this.name,
    this.duration,
    this.reps,
    this.sets,
    this.videoUrl,
    this.imageUrl,
    this.description,
  });

  factory Exercise.fromJson(Map<String, dynamic> json) {
    return Exercise(
      name: json['name'],
      duration: json['duration'],
      reps: json['reps'],
      sets: json['sets'],
      videoUrl: json['video_url'],
      imageUrl: json['image_url'],
      description: json['description'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'duration': duration,
      'reps': reps,
      'sets': sets,
      'video_url': videoUrl,
      'image_url': imageUrl,
      'description': description,
    };
  }
}
