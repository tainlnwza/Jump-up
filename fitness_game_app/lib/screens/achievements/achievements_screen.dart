import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../services/database_service.dart';
import '../../providers/auth_provider.dart';
import '../../models/achievement.dart';
import '../../widgets/common_widgets.dart';

final achievementsProvider = FutureProvider<List<Achievement>>((ref) async {
  final db = DatabaseService();
  final achievements = await db.getAchievements();
  return achievements.map((json) => Achievement.fromJson(json)).toList();
});

final userAchievementsProvider = FutureProvider<List<UserAchievement>>((ref) async {
  final user = ref.watch(userDataProvider).value;
  if (user == null) return [];

  final db = DatabaseService();
  final userAchievements = await db.getUserAchievements(user.id);
  return userAchievements.map((json) => UserAchievement.fromJson(json)).toList();
});

class AchievementsScreen extends ConsumerWidget {
  const AchievementsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final achievementsAsync = ref.watch(achievementsProvider);
    final userAchievementsAsync = ref.watch(userAchievementsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Achievements'),
      ),
      body: achievementsAsync.when(
        data: (achievements) {
          return userAchievementsAsync.when(
            data: (userAchievements) {
              final unlockedIds = userAchievements
                  .map((ua) => ua.achievementId)
                  .toSet();

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: achievements.length,
                itemBuilder: (context, index) {
                  final achievement = achievements[index];
                  final isUnlocked = unlockedIds.contains(achievement.id);

                  return _AchievementCard(
                    achievement: achievement,
                    isUnlocked: isUnlocked,
                  );
                },
              );
            },
            loading: () => const LoadingWidget(),
            error: (error, stack) => CustomErrorWidget(
          message: error.toString(),
          onRetry: () => ref.invalidate(userAchievementsProvider),
        ),
          );
        },
        loading: () => const LoadingWidget(message: 'Loading achievements...'),
        error: (error, stack) => CustomErrorWidget(
          message: error.toString(),
          onRetry: () => ref.invalidate(achievementsProvider),
        ),
      ),
    );
  }
}

class _AchievementCard extends StatelessWidget {
  final Achievement achievement;
  final bool isUnlocked;

  const _AchievementCard({
    required this.achievement,
    required this.isUnlocked,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: isUnlocked ? null : Colors.grey.withOpacity(0.1),
      child: ListTile(
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isUnlocked
                ? Colors.amber.withOpacity(0.2)
                : Colors.grey.withOpacity(0.2),
          ),
          child: Icon(
            isUnlocked ? Icons.emoji_events : Icons.lock,
            color: isUnlocked ? Colors.amber : Colors.grey,
            size: 28,
          ),
        ),
        title: Text(
          achievement.name,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: isUnlocked ? null : Colors.grey,
          ),
        ),
        subtitle: Text(
          achievement.description ?? '',
          style: TextStyle(
            color: isUnlocked ? Colors.grey[600] : Colors.grey,
          ),
        ),
        trailing: isUnlocked
            ? const Icon(Icons.check_circle, color: Colors.green)
            : null,
      ),
    );
  }
}
