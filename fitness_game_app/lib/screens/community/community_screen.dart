import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../services/database_service.dart';
import '../../models/expert_program.dart';
import '../../widgets/common_widgets.dart';
import 'program_detail_screen.dart';

final communityProgramsProvider = FutureProvider.family<List<ExpertProgram>, String>(
  (ref, orderBy) async {
    final db = DatabaseService();
    final programs = await db.getExpertPrograms(orderBy: orderBy);
    return programs.map((json) => ExpertProgram.fromJson(json)).toList();
  },
);

class CommunityScreen extends ConsumerStatefulWidget {
  const CommunityScreen({super.key});

  @override
  ConsumerState<CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends ConsumerState<CommunityScreen> {
  String _sortBy = 'created_at';

  @override
  Widget build(BuildContext context) {
    final programsAsync = ref.watch(communityProgramsProvider(_sortBy));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Community Programs'),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              setState(() => _sortBy = value);
              ref.invalidate(communityProgramsProvider);
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'created_at',
                child: Text('Recent'),
              ),
              const PopupMenuItem(
                value: 'followers_count',
                child: Text('Popular'),
              ),
              const PopupMenuItem(
                value: 'difficulty_level',
                child: Text('Difficulty'),
              ),
            ],
          ),
        ],
      ),
      body: programsAsync.when(
        data: (programs) {
          if (programs.isEmpty) {
            return EmptyStateWidget(
              icon: Icons.people_outline,
              title: 'No programs yet',
              subtitle: 'Be the first to share a workout program!',
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(communityProgramsProvider);
            },
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: programs.length,
              itemBuilder: (context, index) {
                final program = programs[index];
                return _ProgramCard(program: program);
              },
            ),
          );
        },
        loading: () => const LoadingWidget(message: 'Loading programs...'),
        error: (error, stack) => CustomErrorWidget(
          message: error.toString(),
          onRetry: () => ref.invalidate(communityProgramsProvider),
        ),
      ),
    );
  }
}

class _ProgramCard extends StatelessWidget {
  final ExpertProgram program;

  const _ProgramCard({required this.program});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ProgramDetailScreen(program: program),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      program.title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  DifficultyBadge(difficulty: program.difficultyLevel),
                ],
              ),
              const SizedBox(height: 8),
              if (program.description != null) ...[
                Text(
                  program.description!,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 8),
              ],
              Row(
                children: [
                  const Icon(Icons.fitness_center, size: 16),
                  const SizedBox(width: 4),
                  Text('${program.exercises.length} exercises'),
                  const SizedBox(width: 16),
                  const Icon(Icons.people, size: 16),
                  const SizedBox(width: 4),
                  Text('${program.followersCount} followers'),
                  if (program.durationWeeks != null) ...[
                    const SizedBox(width: 16),
                    const Icon(Icons.calendar_today, size: 16),
                    const SizedBox(width: 4),
                    Text('${program.durationWeeks} weeks'),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
