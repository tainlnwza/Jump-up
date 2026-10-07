import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/expert_program.dart';
import '../../services/gemini_service.dart';
import '../../services/database_service.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/common_widgets.dart';

class ProgramDetailScreen extends ConsumerStatefulWidget {
  final ExpertProgram program;

  const ProgramDetailScreen({super.key, required this.program});

  @override
  ConsumerState<ProgramDetailScreen> createState() => _ProgramDetailScreenState();
}

class _ProgramDetailScreenState extends ConsumerState<ProgramDetailScreen> {
  bool _isPersonalizing = false;

  Future<void> _followProgram() async {
    final user = ref.read(userDataProvider).value;
    if (user == null) return;

    setState(() => _isPersonalizing = true);

    try {
      // Call Gemini API to personalize
      final gemini = GeminiService();
      final personalized = await gemini.personalizeWorkoutProgram(
        user: user,
        program: widget.program,
      );

      // Update user's following program
      final db = DatabaseService();
      await db.updateUser(user.id, {
        'following_program_id': widget.program.id,
        'personalized_build': personalized,
      });

      // Refresh user data
      await ref.read(userDataProvider.notifier).loadUserData(user.firebaseUid);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Program personalized! Ready to start?'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to personalize: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isPersonalizing = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Program Details'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title and difficulty
            Row(
              children: [
                Expanded(
                  child: Text(
                    widget.program.title,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                DifficultyBadge(difficulty: widget.program.difficultyLevel),
              ],
            ),
            const SizedBox(height: 16),

            // Description
            if (widget.program.description != null) ...[
              Text(
                widget.program.description!,
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 24),
            ],

            // Stats
            Row(
              children: [
                const Icon(Icons.fitness_center),
                const SizedBox(width: 8),
                Text('${widget.program.exercises.length} exercises'),
                const SizedBox(width: 24),
                const Icon(Icons.people),
                const SizedBox(width: 8),
                Text('${widget.program.followersCount} followers'),
              ],
            ),
            const SizedBox(height: 24),

            // Exercises list
            const Text(
              'Exercises',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            ...widget.program.exercises.map((exercise) => Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: ListTile(
                leading: const CircleAvatar(
                  child: Icon(Icons.fitness_center),
                ),
                title: Text(exercise.name),
                subtitle: Text(
                  exercise.duration != null
                      ? '${exercise.duration}s'
                      : exercise.reps != null
                          ? '${exercise.reps} reps'
                          : '',
                ),
                trailing: exercise.sets != null
                    ? Text('${exercise.sets} sets')
                    : null,
              ),
            )),

            const SizedBox(height: 24),

            // Follow button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isPersonalizing ? null : _followProgram,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: _isPersonalizing
                    ? const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                          SizedBox(width: 12),
                          Text('Personalizing for you...'),
                        ],
                      )
                    : const Text(
                        'FOLLOW PROGRAM',
                        style: TextStyle(fontSize: 16),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
