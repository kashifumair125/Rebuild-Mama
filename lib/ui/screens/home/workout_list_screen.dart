import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../config/routes.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/workout_provider.dart';
import '../../../database/app_database.dart';

class WorkoutListScreen extends ConsumerWidget {
  final int? level;

  const WorkoutListScreen({super.key, this.level});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final userAsync = ref.watch(currentUserProvider);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: Text(_getLevelTitle(level)),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {
              // Show level filter dialog
              _showLevelFilterDialog(context);
            },
            tooltip: 'Filter by level',
          ),
        ],
      ),
      body: userAsync.when(
        data: (user) {
          if (user == null) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              context.go(AppRouter.login);
            });
            return const Center(child: CircularProgressIndicator());
          }

          // If no level specified, show level selection first
          if (level == null) {
            return _NoLevelSelected(
              onLevelSelected: (selectedLevel) {
                context.push('${AppRouter.workoutList}?level=$selectedLevel');
              },
            );
          }

          // Watch workouts for this level
          final workoutsAsync = ref.watch(
            watchWorkoutsByLevelProvider(user.id, level!),
          );

          return workoutsAsync.when(
            data: (workouts) {
              if (workouts.isEmpty) {
                return _EmptyWorkoutList(level: level!);
              }

              return _WorkoutListView(
                workouts: workouts,
                level: level!,
                userId: user.id,
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, stack) => Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.red),
                  const SizedBox(height: 16),
                  Text('Error loading workouts: $error'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => context.pop(),
                    child: const Text('Go Back'),
                  ),
                ],
              ),
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Text('Error loading user: $error'),
        ),
      ),
    );
  }

  String _getLevelTitle(int? level) {
    if (level == null) return 'All Workouts';
    switch (level) {
      case 1:
        return 'Level 1: Repair';
      case 2:
        return 'Level 2: Rebuild';
      case 3:
        return 'Level 3: Strengthen';
      default:
        return 'Workouts';
    }
  }

  void _showLevelFilterDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filter by Level'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.healing_rounded, color: Color(0xFFFFB6C1)),
              title: const Text('Level 1: Repair'),
              onTap: () {
                context.pop();
                context.push('${AppRouter.workoutList}?level=1');
              },
            ),
            ListTile(
              leading: const Icon(Icons.trending_up_rounded, color: Color(0xFFFFDAB9)),
              title: const Text('Level 2: Rebuild'),
              onTap: () {
                context.pop();
                context.push('${AppRouter.workoutList}?level=2');
              },
            ),
            ListTile(
              leading: const Icon(Icons.fitness_center_rounded, color: Color(0xFFE0FFF0)),
              title: const Text('Level 3: Strengthen'),
              onTap: () {
                context.pop();
                context.push('${AppRouter.workoutList}?level=3');
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _NoLevelSelected extends StatelessWidget {
  final Function(int) onLevelSelected;

  const _NoLevelSelected({required this.onLevelSelected});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.fitness_center,
              size: 80,
              color: theme.colorScheme.primary.withOpacity(0.5),
            ),
            const SizedBox(height: 24),
            Text(
              'Select a Workout Level',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Choose a level to see available workouts',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.7),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () => context.push(AppRouter.levelSelection),
              icon: const Icon(Icons.list_alt),
              label: const Text('View Levels'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyWorkoutList extends StatelessWidget {
  final int level;

  const _EmptyWorkoutList({required this.level});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 80,
              color: theme.colorScheme.primary.withOpacity(0.5),
            ),
            const SizedBox(height: 24),
            Text(
              'No Workouts Available',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'There are no workouts for Level $level yet.\nCheck back soon or try another level.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.7),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () => context.pop(),
              icon: const Icon(Icons.arrow_back),
              label: const Text('Go Back'),
            ),
          ],
        ),
      ),
    );
  }
}

class _WorkoutListView extends ConsumerWidget {
  final List<Workout> workouts;
  final int level;
  final int userId;

  const _WorkoutListView({
    required this.workouts,
    required this.level,
    required this.userId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final completionAsync = ref.watch(
      levelCompletionPercentageProvider(userId, level),
    );

    return Column(
      children: [
        // Progress header
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                _getLevelColor(level).withOpacity(0.3),
                _getLevelColor(level).withOpacity(0.1),
              ],
            ),
          ),
          child: Column(
            children: [
              completionAsync.when(
                data: (percentage) => Column(
                  children: [
                    Text(
                      '${(percentage * 100).toInt()}% Complete',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: LinearProgressIndicator(
                        value: percentage,
                        minHeight: 8,
                        backgroundColor: Colors.grey[300],
                        valueColor: AlwaysStoppedAnimation<Color>(
                          _getLevelColor(level),
                        ),
                      ),
                    ),
                  ],
                ),
                loading: () => const SizedBox.shrink(),
                error: (_, __) => const SizedBox.shrink(),
              ),
              const SizedBox(height: 8),
              Text(
                '${workouts.length} workout${workouts.length == 1 ? '' : 's'} available',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.7),
                ),
              ),
            ],
          ),
        ),

        // Workout list
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: workouts.length,
            itemBuilder: (context, index) {
              final workout = workouts[index];
              return _WorkoutCard(
                workout: workout,
                level: level,
                onTap: () => context.push(
                  AppRouter.workoutDetail.replaceFirst(':id', '${workout.id}'),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Color _getLevelColor(int level) {
    switch (level) {
      case 1:
        return const Color(0xFFFFB6C1);
      case 2:
        return const Color(0xFFFFDAB9);
      case 3:
        return const Color(0xFFE0FFF0);
      default:
        return Colors.grey;
    }
  }
}

class _WorkoutCard extends StatelessWidget {
  final Workout workout;
  final int level;
  final VoidCallback onTap;

  const _WorkoutCard({
    required this.workout,
    required this.level,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Workout icon/thumbnail
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: _getLevelColor(level).withOpacity(0.3),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  _getLevelIcon(level),
                  size: 40,
                  color: _getLevelColor(level),
                ),
              ),
              const SizedBox(width: 16),

              // Workout details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      workout.name,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    if (workout.description != null)
                      Text(
                        workout.description!,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface.withOpacity(0.7),
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    const SizedBox(height: 12),

                    // Workout metadata
                    Row(
                      children: [
                        Icon(
                          Icons.timer_outlined,
                          size: 16,
                          color: theme.colorScheme.onSurface.withOpacity(0.6),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${workout.durationMinutes} min',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurface.withOpacity(0.6),
                          ),
                        ),
                        const SizedBox(width: 16),
                        if (workout.isCompleted)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.green.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.check_circle,
                                  size: 14,
                                  color: Colors.green,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  'Completed',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: Colors.green,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),

              // Arrow icon
              Icon(
                Icons.chevron_right,
                color: theme.colorScheme.onSurface.withOpacity(0.4),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getLevelColor(int level) {
    switch (level) {
      case 1:
        return const Color(0xFFFFB6C1);
      case 2:
        return const Color(0xFFFFDAB9);
      case 3:
        return const Color(0xFFE0FFF0);
      default:
        return Colors.grey;
    }
  }

  IconData _getLevelIcon(int level) {
    switch (level) {
      case 1:
        return Icons.healing_rounded;
      case 2:
        return Icons.trending_up_rounded;
      case 3:
        return Icons.fitness_center_rounded;
      default:
        return Icons.fitness_center;
    }
  }
}
