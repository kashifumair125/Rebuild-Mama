import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../database/app_database.dart';
import '../../../providers/sos_provider.dart';
import '../../../providers/auth_provider.dart';
import '../../widgets/exercise_animation_player.dart';

/// SOS Routine Screen - Guides user through SOS exercises
class SosRoutineScreen extends ConsumerStatefulWidget {
  final int routineId;

  const SosRoutineScreen({
    super.key,
    required this.routineId,
  });

  @override
  ConsumerState<SosRoutineScreen> createState() => _SosRoutineScreenState();
}

class _SosRoutineScreenState extends ConsumerState<SosRoutineScreen> {
  Timer? _timer;
  int _secondsRemaining = 0;
  bool _isPaused = false;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeSession();
    });
  }

  Future<void> _initializeSession() async {
    final userId = ref.read(currentUserIdProvider);
    if (userId == null) {
      if (mounted) {
        context.pop();
      }
      return;
    }

    try {
      await ref.read(currentSosSessionProvider.notifier).startSosRoutine(
            userId: int.parse(userId),
            sosRoutineId: widget.routineId,
          );
      setState(() {
        _isInitialized = true;
      });
      _startTimer();
    } catch (e) {
      if (mounted) {
        _showErrorAndExit('Failed to start routine: $e');
      }
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    final session = ref.read(currentSosSessionProvider);
    if (session == null) return;

    final exercise = session.currentExercise;
    setState(() {
      _secondsRemaining = exercise.durationSeconds;
      _isPaused = false;
    });

    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!_isPaused) {
        setState(() {
          if (_secondsRemaining > 0) {
            _secondsRemaining--;

            // Haptic feedback at 3, 2, 1
            if (_secondsRemaining <= 3 && _secondsRemaining > 0) {
              HapticFeedback.mediumImpact();
            }
          } else {
            _timer?.cancel();
            HapticFeedback.heavyImpact();
            // Auto-advance to next exercise
            _handleNext();
          }
        });
      }
    });
  }

  void _pauseTimer() {
    setState(() {
      _isPaused = !_isPaused;
    });
  }

  void _resetTimer() {
    final session = ref.read(currentSosSessionProvider);
    if (session == null) return;

    final exercise = session.currentExercise;
    setState(() {
      _secondsRemaining = exercise.durationSeconds;
      _isPaused = false;
    });
  }

  Future<void> _handleNext() async {
    final session = ref.read(currentSosSessionProvider);
    if (session == null) return;

    if (session.isLastExercise) {
      // Complete the routine
      _timer?.cancel();
      await ref.read(currentSosSessionProvider.notifier).completeSosSession();

      if (mounted && context.mounted) {
        _showCompletionDialog();
      }
    } else {
      // Move to next exercise
      ref.read(currentSosSessionProvider.notifier).nextExercise();
      _startTimer();
    }
  }

  void _handlePrevious() {
    ref.read(currentSosSessionProvider.notifier).previousExercise();
    _startTimer();
  }

  void _handleSkip() {
    _handleNext();
  }

  void _showExitDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('End Routine?'),
        content: const Text(
          'Are you sure you want to end this routine? Your progress will not be saved.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              ref.read(currentSosSessionProvider.notifier).endSession();
              Navigator.pop(context);
              if (mounted) {
                context.pop();
              }
            },
            child: Text(
              'End Routine',
              style: TextStyle(
                color: Theme.of(context).colorScheme.error,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showCompletionDialog() {
    final session = ref.read(currentSosSessionProvider);
    if (session == null) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(
              Icons.check_circle,
              color: Theme.of(context).colorScheme.primary,
              size: 32,
            ),
            const SizedBox(width: 12),
            const Text('Routine Complete!'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'You have completed the "${session.routine.name}" routine.',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 16),
            Text(
              'Take time to rest and notice how you feel.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withOpacity(0.7),
                  ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              ref.read(currentSosSessionProvider.notifier).restartRoutine();
              Navigator.pop(context);
              _startTimer();
            },
            child: const Text('Do Again'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              if (mounted) {
                context.pop();
              }
            },
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }

  void _showErrorAndExit(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              if (mounted) {
                context.pop();
              }
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    final session = ref.watch(currentSosSessionProvider);
    final theme = Theme.of(context);

    if (session == null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('No active SOS session'),
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
        title: Text(session.routine.name),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => _showExitDialog(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.skip_next),
            onPressed: _handleSkip,
            tooltip: 'Skip Exercise',
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Progress bar
            LinearProgressIndicator(
              value: session.progressPercentage,
              backgroundColor: theme.colorScheme.surfaceVariant,
              valueColor: AlwaysStoppedAnimation<Color>(theme.colorScheme.primary),
              minHeight: 6,
            ),
            const SizedBox(height: 8),

            // Exercise counter
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                'Exercise ${session.exercisesCompleted} of ${session.totalExercises}',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Main content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  children: [
                    // Timer circle (large and prominent)
                    _buildTimerCircle(theme),
                    const SizedBox(height: 32),

                    // Exercise animation
                    ExerciseAnimationPlayer(
                      animationPath: exercise.animationPath,
                      size: 240,
                    ),
                    const SizedBox(height: 32),

                    // Exercise name
                    Text(
                      exercise.exerciseName,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),

                    // Exercise description
                    if (exercise.description.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surfaceVariant.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          exercise.description,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurface.withOpacity(0.8),
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    const SizedBox(height: 24),

                    // Audio guidance
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE3F2FD),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: const Color(0xFF2196F3),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(
                            Icons.volume_up,
                            color: Color(0xFF1976D2),
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              exercise.audioGuidance,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: const Color(0xFF1565C0),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Control buttons
            _buildControlButtons(theme, session),
          ],
        ),
      ),
    );
  }

  Widget _buildTimerCircle(ThemeData theme) {
    final minutes = _secondsRemaining ~/ 60;
    final seconds = _secondsRemaining % 60;
    final timeString = '${minutes.toString().padLeft(1, '0')}:${seconds.toString().padLeft(2, '0')}';

    return Container(
      width: 160,
      height: 160,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: theme.colorScheme.primaryContainer,
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.primary.withOpacity(0.3),
            blurRadius: 20,
            spreadRadius: 5,
          ),
        ],
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              timeString,
              style: theme.textTheme.displayMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onPrimaryContainer,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'REMAINING',
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onPrimaryContainer.withOpacity(0.7),
                letterSpacing: 1.2,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildControlButtons(ThemeData theme, SosSessionState session) {
    return Container(
      padding: const EdgeInsets.all(24),
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
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Play/Pause and Reset buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Previous button (disabled if first exercise)
              IconButton(
                onPressed: session.isFirstExercise ? null : _handlePrevious,
                icon: const Icon(Icons.skip_previous),
                iconSize: 32,
                tooltip: 'Previous Exercise',
              ),
              const SizedBox(width: 24),

              // Pause/Play button
              IconButton(
                onPressed: _pauseTimer,
                icon: Icon(_isPaused ? Icons.play_arrow : Icons.pause),
                iconSize: 48,
                style: IconButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary,
                  foregroundColor: theme.colorScheme.onPrimary,
                ),
                tooltip: _isPaused ? 'Resume' : 'Pause',
              ),
              const SizedBox(width: 24),

              // Reset button
              IconButton(
                onPressed: _resetTimer,
                icon: const Icon(Icons.replay),
                iconSize: 32,
                tooltip: 'Reset Timer',
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Next exercise button
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: _handleNext,
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: theme.colorScheme.onPrimary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    session.isLastExercise ? 'Complete Routine' : 'Next Exercise',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: theme.colorScheme.onPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    session.isLastExercise ? Icons.check : Icons.arrow_forward,
                    size: 20,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),

          // End routine button
          TextButton(
            onPressed: () => _showExitDialog(context),
            child: Text(
              'End Routine',
              style: TextStyle(
                color: theme.colorScheme.error,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
