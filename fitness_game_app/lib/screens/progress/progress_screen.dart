import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../services/database_service.dart';
import '../../providers/auth_provider.dart';
import '../../models/workout_session.dart';
import '../../widgets/common_widgets.dart';

final workoutHistoryProvider = FutureProvider<List<WorkoutSession>>((ref) async {
  final user = ref.watch(userDataProvider).value;
  if (user == null) return [];

  final db = DatabaseService();
  final sessions = await db.getWorkoutHistory(user.id);
  return sessions.map((json) => WorkoutSession.fromJson(json)).toList();
});

class ProgressScreen extends ConsumerWidget {
  const ProgressScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userData = ref.watch(userDataProvider);
    final historyAsync = ref.watch(workoutHistoryProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Progress'),
      ),
      body: userData.when(
        data: (user) {
          if (user == null) {
            return const Center(child: Text('Not logged in'));
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Overview stats
                const Text(
                  'Overview',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),

                Row(
                  children: [
                    Expanded(
                      child: _StatCard(
                        icon: Icons.emoji_events,
                        label: 'Level',
                        value: '${user.level}',
                        color: Colors.amber,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _StatCard(
                        icon: Icons.local_fire_department,
                        label: 'Streak',
                        value: '${user.dailyStreak}',
                        color: Colors.orange,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                Row(
                  children: [
                    Expanded(
                      child: _StatCard(
                        icon: Icons.stars,
                        label: 'Total XP',
                        value: '${user.exp}',
                        color: Colors.purple,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _StatCard(
                        icon: Icons.monetization_on,
                        label: 'Coins',
                        value: '${user.coins}',
                        color: Colors.amber,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),

                // Workout history
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Workout History',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextButton(
                      onPressed: () => ref.invalidate(workoutHistoryProvider),
                      child: const Text('Refresh'),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                historyAsync.when(
                  data: (sessions) {
                    if (sessions.isEmpty) {
                      return const EmptyStateWidget(
                        icon: Icons.fitness_center,
                        title: 'No workouts yet',
                        subtitle: 'Start exercising to see your progress!',
                      );
                    }

                    return Column(
                      children: sessions.map((session) {
                        return _SessionCard(session: session);
                      }).toList(),
                    );
                  },
                  loading: () => const LoadingWidget(),
                  error: (error, stack) => CustomErrorWidget(
                    message: error.toString(),
                  ),
                ),
              ],
            ),
          );
        },
        loading: () => const LoadingWidget(),
        error: (error, stack) => CustomErrorWidget(message: error.toString()),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              label,
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SessionCard extends StatelessWidget {
  final WorkoutSession session;

  const _SessionCard({required this.session});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: session.sessionType == 'game'
              ? Colors.purple.withOpacity(0.2)
              : Colors.green.withOpacity(0.2),
          child: Icon(
            session.sessionType == 'game'
                ? Icons.sports_kabaddi
                : Icons.fitness_center,
            color: session.sessionType == 'game' ? Colors.purple : Colors.green,
          ),
        ),
        title: Text(
          session.sessionType == 'game' ? 'Boss Battle' : 'Workout',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          session.completedAt != null
              ? _formatDate(session.completedAt!)
              : 'In progress',
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.stars, size: 16, color: Colors.amber),
                const SizedBox(width: 4),
                Text('+${session.expEarned}'),
              ],
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.monetization_on, size: 16, color: Colors.amber),
                const SizedBox(width: 4),
                Text('+${session.coinsEarned}'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inDays == 0) {
      return 'Today';
    } else if (diff.inDays == 1) {
      return 'Yesterday';
    } else if (diff.inDays < 7) {
      return '${diff.inDays} days ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}
