import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_model.dart';

class DatabaseService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // =============================================
  // USER OPERATIONS
  // =============================================

  /// Create new user in database
  Future<UserModel> createUser({
    required String firebaseUid,
    required String username,
    required String email,
  }) async {
    final response = await _supabase.from('users').insert({
      'firebase_uid': firebaseUid,
      'username': username,
      'email': email,
    }).select().single();

    return UserModel.fromJson(response);
  }

  /// Get user by Firebase UID
  Future<UserModel?> getUserByFirebaseUid(String firebaseUid) async {
    final response = await _supabase
        .from('users')
        .select()
        .eq('firebase_uid', firebaseUid)
        .maybeSingle();

    if (response == null) return null;
    return UserModel.fromJson(response);
  }

  /// Update user profile
  Future<UserModel> updateUser(String userId, Map<String, dynamic> updates) async {
    final response = await _supabase
        .from('users')
        .update(updates)
        .eq('id', userId)
        .select()
        .single();

    return UserModel.fromJson(response);
  }

  /// Update daily streak
  Future<UserModel> updateDailyStreak(String userId) async {
    final user = await _supabase
        .from('users')
        .select()
        .eq('id', userId)
        .single();

    final now = DateTime.now();
    final lastLogin = user['last_login_date'] != null
        ? DateTime.parse(user['last_login_date'])
        : null;

    int newStreak = user['daily_streak'] ?? 0;

    if (lastLogin == null) {
      newStreak = 1;
    } else {
      final daysSinceLastLogin = now.difference(lastLogin).inDays;

      if (daysSinceLastLogin == 0) {
        // Same day, no change
      } else if (daysSinceLastLogin == 1) {
        // Consecutive day
        newStreak++;
      } else {
        // Streak broken
        newStreak = 1;
      }
    }

    final response = await _supabase
        .from('users')
        .update({
          'daily_streak': newStreak,
          'last_login_date': now.toIso8601String().split('T')[0],
        })
        .eq('id', userId)
        .select()
        .single();

    return UserModel.fromJson(response);
  }

  // =============================================
  // WORKOUT SESSION OPERATIONS
  // =============================================

  /// Save workout session
  Future<void> saveWorkoutSession({
    required String userId,
    required String sessionType,
    required int expEarned,
    required int coinsEarned,
    Map<String, dynamic>? posesCompleted,
    bool? bossDefeated,
    String? programId,
    Map<String, dynamic>? exercisesCompleted,
  }) async {
    await _supabase.from('workout_sessions').insert({
      'user_id': userId,
      'session_type': sessionType,
      'completed_at': DateTime.now().toIso8601String(),
      'exp_earned': expEarned,
      'coins_earned': coinsEarned,
      'poses_completed': posesCompleted,
      'boss_defeated': bossDefeated,
      'program_id': programId,
      'exercises_completed': exercisesCompleted,
    });

    // Update user stats
    await _supabase.rpc('add_exp_and_coins', params: {
      'user_id_param': userId,
      'exp_amount': expEarned,
      'coins_amount': coinsEarned,
    });
  }

  /// Get user's workout history
  Future<List<Map<String, dynamic>>> getWorkoutHistory(
    String userId, {
    int limit = 20,
  }) async {
    final response = await _supabase
        .from('workout_sessions')
        .select()
        .eq('user_id', userId)
        .order('completed_at', ascending: false)
        .limit(limit);

    return List<Map<String, dynamic>>.from(response);
  }

  // =============================================
  // EXPERT PROGRAMS OPERATIONS
  // =============================================

  /// Get expert programs (community feed)
  Future<List<Map<String, dynamic>>> getExpertPrograms({
    int limit = 20,
    int offset = 0,
    String orderBy = 'created_at',
  }) async {
    final response = await _supabase
        .from('expert_programs')
        .select()
        .order(orderBy, ascending: false)
        .range(offset, offset + limit - 1);

    return List<Map<String, dynamic>>.from(response);
  }

  /// Get program by ID
  Future<Map<String, dynamic>?> getProgramById(String programId) async {
    final response = await _supabase
        .from('expert_programs')
        .select()
        .eq('id', programId)
        .maybeSingle();

    return response;
  }

  // =============================================
  // ACHIEVEMENTS OPERATIONS
  // =============================================

  /// Get all achievements
  Future<List<Map<String, dynamic>>> getAchievements() async {
    final response = await _supabase.from('achievements').select();
    return List<Map<String, dynamic>>.from(response);
  }

  /// Check and unlock achievements
  Future<List<Map<String, dynamic>>> checkAchievements(String userId) async {
    // Get user stats
    final user = await _supabase
        .from('users')
        .select()
        .eq('id', userId)
        .single();

    // Get user's current achievements
    final currentAchievements = await _supabase
        .from('user_achievements')
        .select('achievement_id')
        .eq('user_id', userId);

    final unlockedIds =
        currentAchievements.map((a) => a['achievement_id']).toSet();

    // Get all achievements
    final allAchievements = await getAchievements();

    final newlyUnlocked = <Map<String, dynamic>>[];

    for (final achievement in allAchievements) {
      if (unlockedIds.contains(achievement['id'])) continue;

      final criteria = achievement['unlock_criteria'] as Map<String, dynamic>;
      final type = criteria['type'] as String;

      bool shouldUnlock = false;

      switch (type) {
        case 'level':
          shouldUnlock = user['level'] >= (criteria['value'] as int);
          break;
        case 'daily_streak':
          shouldUnlock = user['daily_streak'] >= (criteria['count'] as int);
          break;
        case 'boss_victories':
          final sessions = await _supabase
              .from('workout_sessions')
              .select()
              .eq('user_id', userId)
              .eq('session_type', 'game')
              .eq('boss_defeated', true);
          shouldUnlock = sessions.length >= (criteria['count'] as int);
          break;
        case 'workouts_completed':
          final sessions = await _supabase
              .from('workout_sessions')
              .select()
              .eq('user_id', userId)
              .eq('session_type', 'workout');
          shouldUnlock = sessions.length >= (criteria['count'] as int);
          break;
        case 'boss_battles':
          final sessions = await _supabase
              .from('workout_sessions')
              .select()
              .eq('user_id', userId)
              .eq('session_type', 'game');
          shouldUnlock = sessions.length >= (criteria['count'] as int);
          break;
      }

      if (shouldUnlock) {
        await _supabase.from('user_achievements').insert({
          'user_id': userId,
          'achievement_id': achievement['id'],
        });
        newlyUnlocked.add(achievement);
      }
    }

    return newlyUnlocked;
  }

  /// Get user's achievements
  Future<List<Map<String, dynamic>>> getUserAchievements(String userId) async {
    final response = await _supabase
        .from('user_achievements')
        .select('*, achievements(*)')
        .eq('user_id', userId);

    return List<Map<String, dynamic>>.from(response);
  }

  // =============================================
  // SHOP OPERATIONS
  // =============================================

  /// Get shop items
  Future<List<Map<String, dynamic>>> getShopItems({
    String? itemType,
    int limit = 20,
  }) async {
    var query = _supabase.from('shop_items').select().eq('is_available', true);

    if (itemType != null) {
      query = query.eq('item_type', itemType);
    }

    final response = await query.limit(limit);
    return List<Map<String, dynamic>>.from(response);
  }

  /// Purchase item
  Future<void> purchaseItem({
    required String userId,
    required String itemId,
    required int price,
  }) async {
    // Start transaction-like operation
    // 1. Check user has enough coins
    final user = await _supabase
        .from('users')
        .select('coins')
        .eq('id', userId)
        .single();

    if (user['coins'] < price) {
      throw Exception('Insufficient coins');
    }

    // 2. Deduct coins
    await _supabase
        .from('users')
        .update({'coins': user['coins'] - price})
        .eq('id', userId);

    // 3. Add to inventory
    await _supabase.from('user_inventory').insert({
      'user_id': userId,
      'item_id': itemId,
    });
  }

  // =============================================
  // QUEST OPERATIONS
  // =============================================

  /// Get active quests
  Future<List<Map<String, dynamic>>> getActiveQuests() async {
    final now = DateTime.now().toIso8601String();
    final response = await _supabase
        .from('quests')
        .select()
        .or('expires_at.is.null,expires_at.gt.$now');

    return List<Map<String, dynamic>>.from(response);
  }

  /// Update quest progress
  Future<void> updateQuestProgress({
    required String userId,
    required String questId,
    required Map<String, dynamic> progress,
  }) async {
    await _supabase.from('user_quest_progress').upsert({
      'user_id': userId,
      'quest_id': questId,
      'progress': progress,
    });
  }
}
