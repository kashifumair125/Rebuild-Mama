import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lottie/lottie.dart';
import '../../../data/exercise_details.dart';

/// Enhanced exercise detail screen with Lottie animations and detailed instructions
class ExerciseDetailScreen extends ConsumerStatefulWidget {
  final String exerciseKey;

  const ExerciseDetailScreen({
    super.key,
    required this.exerciseKey,
  });

  @override
  ConsumerState<ExerciseDetailScreen> createState() => _ExerciseDetailScreenState();
}

class _ExerciseDetailScreenState extends ConsumerState<ExerciseDetailScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  bool _isAnimationPlaying = true;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(vsync: this);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final exercise = ExerciseDatabase.getExercise(widget.exerciseKey);

    if (exercise == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Exercise')),
        body: const Center(child: Text('Exercise not found')),
      );
    }

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Animated App Bar with Lottie
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  // Background gradient
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          _getLevelColor(exercise.level).withOpacity(0.3),
                          theme.colorScheme.surface,
                        ],
                      ),
                    ),
                  ),
                  // Lottie Animation
                  Center(
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _isAnimationPlaying = !_isAnimationPlaying;
                          if (_isAnimationPlaying) {
                            _animationController.repeat();
                          } else {
                            _animationController.stop();
                          }
                        });
                      },
                      child: Lottie.asset(
                        exercise.animationPath,
                        controller: _animationController,
                        onLoaded: (composition) {
                          _animationController
                            ..duration = composition.duration
                            ..repeat();
                        },
                        width: 200,
                        height: 200,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            width: 200,
                            height: 200,
                            decoration: BoxDecoration(
                              color: _getLevelColor(exercise.level).withOpacity(0.3),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.fitness_center,
                              size: 80,
                              color: _getLevelColor(exercise.level),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  // Play/Pause indicator
                  Positioned(
                    bottom: 16,
                    right: 16,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surface.withOpacity(0.8),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            _isAnimationPlaying ? Icons.pause : Icons.play_arrow,
                            size: 16,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            _isAnimationPlaying ? 'Tap to pause' : 'Tap to play',
                            style: theme.textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Content
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Exercise Name and Meta
                  Text(
                    exercise.name,
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Meta info chips
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _buildChip(
                        Icons.timer_outlined,
                        exercise.duration,
                        theme,
                      ),
                      _buildChip(
                        Icons.signal_cellular_alt,
                        exercise.difficulty,
                        theme,
                      ),
                      if (exercise.sets != null)
                        _buildChip(
                          Icons.repeat,
                          '${exercise.sets} sets',
                          theme,
                        ),
                      if (exercise.reps != null)
                        _buildChip(
                          Icons.numbers,
                          exercise.reps!,
                          theme,
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Description
                  Text(
                    exercise.description,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.8),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Starting Position
                  _buildSection(
                    'Starting Position',
                    Icons.accessibility_new,
                    exercise.startingPosition,
                    theme,
                    isNumbered: false,
                  ),
                  const SizedBox(height: 24),

                  // Step-by-step Instructions
                  _buildStepsSection(exercise.steps, theme),
                  const SizedBox(height: 24),

                  // Breathing Pattern
                  _buildHighlightCard(
                    'Breathing Pattern',
                    Icons.air,
                    exercise.breathingPattern,
                    theme,
                    Colors.blue,
                  ),
                  const SizedBox(height: 16),

                  // Key Points
                  _buildSection(
                    'Key Points',
                    Icons.check_circle_outline,
                    exercise.keyPoints,
                    theme,
                    iconColor: Colors.green,
                  ),
                  const SizedBox(height: 24),

                  // Safety Notes
                  _buildSection(
                    'Safety Notes',
                    Icons.warning_amber_outlined,
                    exercise.safetyNotes,
                    theme,
                    iconColor: Colors.orange,
                  ),
                  const SizedBox(height: 24),

                  // Common Mistakes
                  _buildSection(
                    'Common Mistakes to Avoid',
                    Icons.cancel_outlined,
                    exercise.commonMistakes,
                    theme,
                    iconColor: Colors.red,
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChip(IconData icon, String label, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer.withOpacity(0.5),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: theme.colorScheme.primary),
          const SizedBox(width: 6),
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(
    String title,
    IconData icon,
    List<String> items,
    ThemeData theme, {
    bool isNumbered = false,
    Color? iconColor,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: iconColor ?? theme.colorScheme.primary),
            const SizedBox(width: 8),
            Text(
              title,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...items.asMap().entries.map((entry) {
          final index = entry.key;
          final item = entry.value;
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 24,
                  child: isNumbered
                      ? Text(
                          '${index + 1}.',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        )
                      : Icon(
                          Icons.fiber_manual_record,
                          size: 8,
                          color: iconColor ?? theme.colorScheme.primary,
                        ),
                ),
                Expanded(
                  child: Text(
                    item,
                    style: theme.textTheme.bodyMedium,
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _buildStepsSection(List<ExerciseStep> steps, ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.format_list_numbered, color: theme.colorScheme.primary),
            const SizedBox(width: 8),
            Text(
              'Step-by-Step Instructions',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...steps.asMap().entries.map((entry) {
          final index = entry.key;
          final step = entry.value;
          return Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.5),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: theme.colorScheme.outline.withOpacity(0.2),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          '${index + 1}',
                          style: TextStyle(
                            color: theme.colorScheme.onPrimary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        step.title,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    if (step.duration != null)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.tertiaryContainer,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          step.duration!,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onTertiaryContainer,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                ...step.instructions.map((instruction) => Padding(
                  padding: const EdgeInsets.only(bottom: 4, left: 40),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('• ', style: TextStyle(color: theme.colorScheme.primary)),
                      Expanded(
                        child: Text(
                          instruction,
                          style: theme.textTheme.bodySmall,
                        ),
                      ),
                    ],
                  ),
                )),
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _buildHighlightCard(
    String title,
    IconData icon,
    String content,
    ThemeData theme,
    Color color,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
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
}
