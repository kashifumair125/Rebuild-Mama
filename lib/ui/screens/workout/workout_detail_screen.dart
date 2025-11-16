import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../database/app_database.dart';
import '../../../providers/workout_provider.dart';
import '../../../providers/auth_provider.dart';
import '../../widgets/exercise_animation_player.dart';

/// Screen that displays workout details and allows starting the workout
class WorkoutDetailScreen extends ConsumerWidget {
  final int workoutId;

  const WorkoutDetailScreen({
    super.key,
    required this.workoutId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final workoutAsync = ref.watch(workoutByIdProvider(workoutId));
    final exercisesAsync = ref.watch(exercisesForWorkoutProvider(workoutId));

    return Scaffold(
      body: workoutAsync.when(
        data: (workout) {
          if (workout == null) {
            return _buildErrorView(context, 'Workout not found');
          }

          return exercisesAsync.when(
            data: (exercises) => _buildContent(context, ref, workout, exercises),
            loading: () => _buildLoadingView(),
            error: (error, stack) => _buildErrorView(context, error.toString()),
          );
        },
        loading: () => _buildLoadingView(),
        error: (error, stack) => _buildErrorView(context, error.toString()),
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    WidgetRef ref,
    Workout workout,
    List<Exercise> exercises,
  ) {
    final theme = Theme.of(context);

    return CustomScrollView(
      slivers: [
        _buildAppBar(context, theme, workout),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildWorkoutInfo(theme, workout, exercises),
                const SizedBox(height: 32),
                _buildExercisesList(theme, exercises),
                const SizedBox(height: 32),
                _buildStartButton(context, ref, workout),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAppBar(BuildContext context, ThemeData theme, Workout workout) {
    return SliverAppBar(
      expandedHeight: 200,
      pinned: true,
      backgroundColor: theme.colorScheme.primary,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => context.pop(),
      ),
      flexibleSpace: FlexibleSpaceBar(
        title: Text(
          workout.name,
          style: theme.textTheme.titleLarge?.copyWith(
            color: theme.colorScheme.onPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                theme.colorScheme.primary,
                theme.colorScheme.primaryContainer,
              ],
            ),
          ),
          child: Center(
            child: Icon(
              Icons.fitness_center,
              size: 80,
              color: theme.colorScheme.onPrimary.withOpacity(0.3),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWorkoutInfo(
    ThemeData theme,
    Workout workout,
    List<Exercise> exercises,
  ) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Workout Details',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildInfoRow(
              theme,
              Icons.timer,
              'Duration',
              '${workout.durationMinutes} minutes',
            ),
            const SizedBox(height: 12),
            _buildInfoRow(
              theme,
              Icons.fitness_center,
              'Exercises',
              '${exercises.length} exercises',
            ),
            const SizedBox(height: 12),
            _buildInfoRow(
              theme,
              Icons.trending_up,
              'Level',
              _getLevelName(workout.level),
            ),
            if (workout.description.isNotEmpty) ...[
              const SizedBox(height: 16),
              Text(
                workout.description,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.7),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(
    ThemeData theme,
    IconData icon,
    String label,
    String value,
  ) {
    return Row(
      children: [
        Icon(
          icon,
          size: 20,
          color: theme.colorScheme.primary,
        ),
        const SizedBox(width: 12),
        Text(
          '$label: ',
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        Text(
          value,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.7),
          ),
        ),
      ],
    );
  }

  Widget _buildExercisesList(ThemeData theme, List<Exercise> exercises) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Exercises',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        ...exercises.asMap().entries.map((entry) {
          final index = entry.key;
          final exercise = entry.value;
          return _buildExerciseItem(theme, index + 1, exercise);
        }),
      ],
    );
  }

  Widget _buildExerciseItem(ThemeData theme, int number, Exercise exercise) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            // Exercise number
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  '$number',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onPrimaryContainer,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            // Exercise animation thumbnail
            if (exercise.animationPath.isNotEmpty)
              CompactExerciseAnimation(
                animationPath: exercise.animationPath,
                size: 60,
              ),
            if (exercise.animationPath.isNotEmpty) const SizedBox(width: 16),
            // Exercise info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    exercise.exerciseName,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      if (exercise.durationSeconds != null) ...[
                        Icon(
                          Icons.timer,
                          size: 14,
                          color: theme.colorScheme.onSurface.withOpacity(0.6),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${exercise.durationSeconds}s',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurface.withOpacity(0.6),
                          ),
                        ),
                      ] else ...[
                        Icon(
                          Icons.repeat,
                          size: 14,
                          color: theme.colorScheme.onSurface.withOpacity(0.6),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          exercise.setsReps,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurface.withOpacity(0.6),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStartButton(BuildContext context, WidgetRef ref, Workout workout) {
    final theme = Theme.of(context);
    final userId = ref.watch(currentUserIdProvider);

    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: userId == null
            ? null
            : () => _startWorkout(context, ref, workout, userId),
        style: ElevatedButton.styleFrom(
          backgroundColor: theme.colorScheme.primary,
          foregroundColor: theme.colorScheme.onPrimary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 4,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.play_arrow, size: 28),
            const SizedBox(width: 12),
            Text(
              'Start Workout',
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.onPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _startWorkout(
    BuildContext context,
    WidgetRef ref,
    Workout workout,
    String userId,
  ) async {
    try {
      // Start the workout session
      await ref.read(currentWorkoutSessionProvider.notifier).startWorkout(
            userId: int.parse(userId),
            workoutId: workout.workoutId,
            level: workout.level,
          );

      // Navigate to exercise screen
      if (context.mounted) {
        context.push('/workout/exercise/${workout.workoutId}');
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to start workout: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  Widget _buildLoadingView() {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }

  Widget _buildErrorView(BuildContext context, String message) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: theme.colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              'Error',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: theme.textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => context.pop(),
              child: const Text('Go Back'),
            ),
          ],
        ),
      ),
    );
  }

  String _getLevelName(int level) {
    switch (level) {
      case 1:
        return 'Level 1: Repair (0-6 weeks)';
      case 2:
        return 'Level 2: Rebuild (6-12 weeks)';
      case 3:
        return 'Level 3: Strengthen (12+ weeks)';
      default:
        return 'Unknown Level';
    }
  }
}
