import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../providers/workout_provider.dart';
import '../../widgets/exercise_animation_player.dart';

/// Screen that displays the current exercise with animation and timer
class ExerciseScreen extends ConsumerStatefulWidget {
  final int workoutId;

  const ExerciseScreen({
    super.key,
    required this.workoutId,
  });

  @override
  ConsumerState<ExerciseScreen> createState() => _ExerciseScreenState();
}

class _ExerciseScreenState extends ConsumerState<ExerciseScreen> {
  Timer? _timer;
  int _secondsRemaining = 0;
  bool _isPaused = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startTimer();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    final session = ref.read(currentWorkoutSessionProvider);
    if (session == null) return;

    final exercise = session.currentExercise;
    if (exercise.durationSeconds != null) {
      setState(() {
        _secondsRemaining = exercise.durationSeconds!;
        _isPaused = false;
      });

      _timer?.cancel();
      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (!_isPaused) {
          setState(() {
            if (_secondsRemaining > 0) {
              _secondsRemaining--;
            } else {
              _timer?.cancel();
              // Auto-advance to next exercise when timer completes
              _handleNext();
            }
          });
        }
      });
    }
  }

  void _pauseTimer() {
    setState(() {
      _isPaused = !_isPaused;
    });
  }

  void _resetTimer() {
    final session = ref.read(currentWorkoutSessionProvider);
    if (session == null) return;

    final exercise = session.currentExercise;
    if (exercise.durationSeconds != null) {
      setState(() {
        _secondsRemaining = exercise.durationSeconds!;
        _isPaused = false;
      });
    }
  }

  Future<void> _handleNext() async {
    final session = ref.read(currentWorkoutSessionProvider);
    if (session == null) return;

    if (session.isLastExercise) {
      // Complete the workout
      _timer?.cancel();
      await ref.read(currentWorkoutSessionProvider.notifier).completeWorkout(
            caloriesBurned: _calculateCalories(session),
          );

      if (mounted && context.mounted) {
        context.go('/workout/complete');
      }
    } else {
      // Move to next exercise
      await ref.read(currentWorkoutSessionProvider.notifier).nextExercise();
      _startTimer();
    }
  }

  void _handlePrevious() {
    ref.read(currentWorkoutSessionProvider.notifier).previousExercise();
    _startTimer();
  }

  void _handleSkip() {
    _handleNext();
  }

  int _calculateCalories(WorkoutSessionState session) {
    // Simple calorie calculation: ~5 calories per minute
    final duration = DateTime.now().difference(session.startedAt).inMinutes;
    return duration * 5;
  }

  @override
  Widget build(BuildContext context) {
    final session = ref.watch(currentWorkoutSessionProvider);
    final theme = Theme.of(context);

    if (session == null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('No active workout session'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => context.pop(),
                child: const Text('Go Back'),
              ),
            ],
          ),
        ),
      );
    }

    final exercise = session.currentExercise;

    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      appBar: AppBar(
        title: Text('Exercise ${session.exercisesCompleted} of ${session.totalExercises}'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => _showExitDialog(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.skip_next),
            onPressed: _handleSkip,
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Progress bar
            LinearProgressIndicator(
              value: ref.read(currentWorkoutSessionProvider.notifier).progress,
              backgroundColor: theme.colorScheme.surfaceVariant,
              valueColor: AlwaysStoppedAnimation<Color>(theme.colorScheme.primary),
              minHeight: 6,
            ),
            const SizedBox(height: 16),

            // Main content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  children: [
                    // Exercise animation
                    ExerciseAnimationPlayer(
                      animationPath: exercise.animationPath,
                      size: 300,
                    ),
                    const SizedBox(height: 32),

                    // Exercise name
                    Text(
                      exercise.exerciseName,
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),

                    // Exercise description
                    if (exercise.description.isNotEmpty)
                      Text(
                        exercise.description,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: theme.colorScheme.onSurface.withOpacity(0.7),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    const SizedBox(height: 32),

                    // Timer or sets/reps
                    if (exercise.durationSeconds != null)
                      _buildTimer(theme)
                    else
                      _buildSetsReps(theme, exercise.setsReps),
                    const SizedBox(height: 48),
                  ],
                ),
              ),
            ),

            // Bottom navigation
            _buildBottomNav(theme, session),
          ],
        ),
      ),
    );
  }

  Widget _buildTimer(ThemeData theme) {
    final minutes = _secondsRemaining ~/ 60;
    final seconds = _secondsRemaining % 60;

    return Column(
      children: [
        // Timer circle
        Container(
          width: 200,
          height: 200,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: theme.colorScheme.primaryContainer.withOpacity(0.2),
            border: Border.all(
              color: theme.colorScheme.primary,
              width: 8,
            ),
          ),
          child: Center(
            child: Text(
              '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}',
              style: theme.textTheme.displayLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.primary,
              ),
            ),
          ),
        ),
        const SizedBox(height: 24),

        // Timer controls
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              onPressed: _resetTimer,
              icon: const Icon(Icons.refresh),
              iconSize: 32,
            ),
            const SizedBox(width: 24),
            IconButton(
              onPressed: _pauseTimer,
              icon: Icon(_isPaused ? Icons.play_arrow : Icons.pause),
              iconSize: 48,
              style: IconButton.styleFrom(
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: theme.colorScheme.onPrimary,
              ),
            ),
            const SizedBox(width: 24),
            IconButton(
              onPressed: _handleNext,
              icon: const Icon(Icons.skip_next),
              iconSize: 32,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSetsReps(ThemeData theme, String setsReps) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer.withOpacity(0.3),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Icon(
            Icons.repeat,
            size: 48,
            color: theme.colorScheme.primary,
          ),
          const SizedBox(height: 16),
          Text(
            setsReps,
            style: theme.textTheme.displaySmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Sets x Reps',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNav(ThemeData theme, WorkoutSessionState session) {
    return Container(
      padding: const EdgeInsets.all(24.0),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Row(
        children: [
          // Previous button
          Expanded(
            child: OutlinedButton(
              onPressed: session.isFirstExercise ? null : _handlePrevious,
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.arrow_back),
                  const SizedBox(width: 8),
                  Text(
                    'Previous',
                    style: theme.textTheme.titleMedium,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 16),

          // Next/Finish button
          Expanded(
            child: ElevatedButton(
              onPressed: _handleNext,
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: theme.colorScheme.onPrimary,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    session.isLastExercise ? 'Finish' : 'Next',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: theme.colorScheme.onPrimary,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    session.isLastExercise ? Icons.check : Icons.arrow_forward,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showExitDialog(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Exit Workout?'),
        content: const Text(
          'Are you sure you want to exit? Your progress will not be saved.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Exit'),
          ),
        ],
      ),
    );

    if (result == true && mounted) {
      _timer?.cancel();
      ref.read(currentWorkoutSessionProvider.notifier).cancelWorkout();
      context.pop();
    }
  }
}
