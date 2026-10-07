import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user_model.dart';

final databaseServiceProvider = Provider((ref) => DatabaseService());

class DatabaseService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // Get user by Firebase UID
  Future<UserModel?> getUserByFirebaseUid(String firebaseUid) async {
    try {
      final response = await _supabase
          .from('users')
          .select()
          .eq('firebase_uid', firebaseUid)
          .single();

      return UserModel.fromJson(response);
    } catch (e) {
      print('Error fetching user: $e');
      return null;
    }
  }

  // Create or update user
  Future<void> createOrUpdateUser({
    required String firebaseUid,
    required String email,
    required String username,
  }) async {
    try {
      // Check if user exists
      final existingUser = await getUserByFirebaseUid(firebaseUid);

      if (existingUser == null) {
        // Create new user
        await _supabase.from('users').insert({
          'firebase_uid': firebaseUid,
          'email': email,
          'username': username,
          'created_at': DateTime.now().toIso8601String(),
        });
      } else {
        // Update existing user
        await _supabase
            .from('users')
            .update({
              'email': email,
              'last_login_date': DateTime.now().toIso8601String(),
            })
            .eq('firebase_uid', firebaseUid);
      }
    } catch (e) {
      print('Error creating/updating user: $e');
      rethrow;
    }
  }

  // Update user profile (onboarding)
  Future<void> updateUserProfile({
    required String userId,
    required Map<String, dynamic> profileData,
  }) async {
    try {
      await _supabase
          .from('users')
          .update(profileData)
          .eq('id', userId);
    } catch (e) {
      print('Error updating profile: $e');
      rethrow;
    }
  }

  // Update daily streak
  Future<void> updateDailyStreak(String userId) async {
    try {
      final user = await _supabase
          .from('users')
          .select('last_login_date, daily_streak')
          .eq('id', userId)
          .single();

      final lastLogin = user['last_login_date'] != null
          ? DateTime.parse(user['last_login_date'])
          : null;
      final today = DateTime.now();
      final currentStreak = user['daily_streak'] ?? 0;

      int newStreak;
      if (lastLogin == null) {
        newStreak = 1;
      } else {
        final daysSinceLastLogin = today.difference(lastLogin).inDays;
        if (daysSinceLastLogin == 0) {
          // Same day, no change
          return;
        } else if (daysSinceLastLogin == 1) {
          // Consecutive day
          newStreak = currentStreak + 1;
        } else {
          // Streak broken
          newStreak = 1;
        }
      }

      await _supabase.from('users').update({
        'daily_streak': newStreak,
        'last_login_date': today.toIso8601String().split('T')[0],
      }).eq('id', userId);
    } catch (e) {
      print('Error updating streak: $e');
    }
  }

  // Save workout session
  Future<void> saveWorkoutSession({
    required String userId,
    required String sessionType,
    required int expEarned,
    required int coinsEarned,
    Map<String, dynamic>? posesCompleted,
    bool? bossDefeated,
    String? programId,
  }) async {
    try {
      await _supabase.from('workout_sessions').insert({
        'user_id': userId,
        'session_type': sessionType,
        'completed_at': DateTime.now().toIso8601String(),
        'exp_earned': expEarned,
        'coins_earned': coinsEarned,
        'poses_completed': posesCompleted,
        'boss_defeated': bossDefeated,
        'program_id': programId,
      });

      // Update user exp and coins
      await _updateUserStats(userId, expEarned, coinsEarned);
    } catch (e) {
      print('Error saving session: $e');
      rethrow;
    }
  }

  // Update user stats (exp, coins, level)
  Future<void> _updateUserStats(String userId, int expEarned, int coinsEarned) async {
    try {
      final user = await _supabase
          .from('users')
          .select('exp, coins, level')
          .eq('id', userId)
          .single();

      int currentExp = user['exp'] ?? 0;
      int currentCoins = user['coins'] ?? 0;
      int currentLevel = user['level'] ?? 1;

      int newExp = currentExp + expEarned;
      int newCoins = currentCoins + coinsEarned;
      int newLevel = currentLevel;

      // Check for level up (exp = 100 * level^2)
      int expRequired = 100 * newLevel * newLevel;
      while (newExp >= expRequired) {
        newExp -= expRequired;
        newLevel++;
        expRequired = 100 * newLevel * newLevel;
      }

      await _supabase.from('users').update({
        'exp': newExp,
        'coins': newCoins,
        'level': newLevel,
      }).eq('id', userId);
    } catch (e) {
      print('Error updating user stats: $e');
      rethrow;
    }
  }

  // Get expert programs (paginated)
  Future<List<Map<String, dynamic>>> getExpertPrograms({
    int page = 0,
    int limit = 20,
    String sortBy = 'created_at',
  }) async {
    try {
      final response = await _supabase
          .from('expert_programs')
          .select()
          .order(sortBy, ascending: false)
          .range(page * limit, (page + 1) * limit - 1);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('Error fetching programs: $e');
      return [];
    }
  }

  // Follow program
  Future<void> followProgram(String userId, String programId) async {
    try {
      await _supabase.from('users').update({
        'following_program_id': programId,
      }).eq('id', userId);
    } catch (e) {
      print('Error following program: $e');
      rethrow;
    }
  }

  // Save personalized build
  Future<void> savePersonalizedBuild(
    String userId,
    Map<String, dynamic> personalizedBuild,
  ) async {
    try {
      await _supabase.from('users').update({
        'personalized_build': personalizedBuild,
      }).eq('id', userId);
    } catch (e) {
      print('Error saving personalized build: $e');
      rethrow;
    }
  }

  // Get achievements
  Future<List<Map<String, dynamic>>> getAchievements() async {
    try {
      final response = await _supabase.from('achievements').select();
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('Error fetching achievements: $e');
      return [];
    }
  }

  // Check and unlock achievements
  Future<List<String>> checkAndUnlockAchievements(String userId) async {
    try {
      // Get user stats
      final user = await _supabase
          .from('users')
          .select()
          .eq('id', userId)
          .single();

      // Get all achievements
      final achievements = await getAchievements();

      // Get already unlocked achievements
      final unlockedResponse = await _supabase
          .from('user_achievements')
          .select('achievement_id')
          .eq('user_id', userId);

      final unlockedIds = unlockedResponse.map((e) => e['achievement_id']).toSet();

      List<String> newlyUnlocked = [];

      for (var achievement in achievements) {
        if (unlockedIds.contains(achievement['id'])) continue;

        // Check unlock criteria
        final criteria = achievement['unlock_criteria'];
        bool shouldUnlock = _checkAchievementCriteria(user, criteria);

        if (shouldUnlock) {
          await _supabase.from('user_achievements').insert({
            'user_id': userId,
            'achievement_id': achievement['id'],
          });
          newlyUnlocked.add(achievement['name']);
        }
      }

      return newlyUnlocked;
    } catch (e) {
      print('Error checking achievements: $e');
      return [];
    }
  }

  bool _checkAchievementCriteria(Map<String, dynamic> user, Map<String, dynamic> criteria) {
    final type = criteria['type'];

    switch (type) {
      case 'level':
        return (user['level'] ?? 1) >= (criteria['value'] ?? 0);
      case 'daily_streak':
        return (user['daily_streak'] ?? 0) >= (criteria['count'] ?? 0);
      // Add more criteria checks as needed
      default:
        return false;
    }
  }
}
