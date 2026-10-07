import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class GameResultsScreen extends StatelessWidget {
  final bool victory;
  final int expEarned;
  final int coinsEarned;
  final Duration duration;
  final Map<String, int> posesUsed;

  const GameResultsScreen({
    super.key,
    required this.victory,
    required this.expEarned,
    required this.coinsEarned,
    required this.duration,
    required this.posesUsed,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Victory/Defeat icon
              Icon(
                victory ? Icons.emoji_events : Icons.close,
                size: 120,
                color: victory ? Colors.amber : Colors.grey,
              ).animate().scale(
                duration: 500.ms,
                curve: Curves.elasticOut,
              ),
              const SizedBox(height: 24),

              // Title
              Text(
                victory ? 'VICTORY!' : 'DEFEATED',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                  color: victory ? Colors.amber : Colors.grey,
                ),
              ).animate().fadeIn(delay: 200.ms),
              const SizedBox(height: 32),

              // Stats cards
              _buildStatCard(
                context,
                icon: Icons.stars,
                label: 'EXP Earned',
                value: '+$expEarned',
                color: Colors.purple,
              ).animate().slideX(delay: 300.ms),
              const SizedBox(height: 16),

              _buildStatCard(
                context,
                icon: Icons.monetization_on,
                label: 'Coins Earned',
                value: '+$coinsEarned',
                color: Colors.amber,
              ).animate().slideX(delay: 400.ms),
              const SizedBox(height: 16),

              _buildStatCard(
                context,
                icon: Icons.timer,
                label: 'Duration',
                value: _formatDuration(duration),
                color: Colors.blue,
              ).animate().slideX(delay: 500.ms),
              const SizedBox(height: 16),

              _buildStatCard(
                context,
                icon: Icons.fitness_center,
                label: 'Total Poses',
                value: '${posesUsed.values.fold(0, (sum, count) => sum + count)}',
                color: Colors.green,
              ).animate().slideX(delay: 600.ms),
              const SizedBox(height: 32),

              // Continue button
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).popUntil((route) => route.isFirst);
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text(
                  'CONTINUE',
                  style: TextStyle(fontSize: 18),
                ),
              ).animate().fadeIn(delay: 800.ms),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '${minutes}m ${seconds}s';
  }
}
