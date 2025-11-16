import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

/// A widget that plays Lottie animations for exercises
/// Provides error handling, customizable size, and auto-loop functionality
class ExerciseAnimationPlayer extends StatelessWidget {
  /// Path to the Lottie animation JSON file (e.g., 'assets/animations/level1/breathing.json')
  final String animationPath;

  /// Width and height of the animation
  final double size;

  /// Speed multiplier for the animation (1.0 = normal speed)
  final double speed;

  /// Whether to loop the animation continuously
  final bool repeat;

  /// Whether to reverse the animation after completion
  final bool reverse;

  /// Fit mode for the animation
  final BoxFit fit;

  /// Background color behind the animation
  final Color? backgroundColor;

  /// Border radius for the animation container
  final double borderRadius;

  /// Shadow elevation
  final double elevation;

  const ExerciseAnimationPlayer({
    super.key,
    required this.animationPath,
    this.size = 300.0,
    this.speed = 1.0,
    this.repeat = true,
    this.reverse = false,
    this.fit = BoxFit.contain,
    this.backgroundColor,
    this.borderRadius = 16.0,
    this.elevation = 4.0,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bgColor = backgroundColor ?? theme.colorScheme.surface;

    return Material(
      elevation: elevation,
      borderRadius: BorderRadius.circular(borderRadius),
      color: bgColor,
      child: Container(
        width: size,
        height: size,
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(borderRadius),
        ),
        child: _buildAnimation(context),
      ),
    );
  }

  Widget _buildAnimation(BuildContext context) {
    final theme = Theme.of(context);

    // Check if the animation path is valid
    if (animationPath.isEmpty) {
      return _buildErrorWidget(
        context,
        'No animation available',
        Icons.animation,
      );
    }

    try {
      return Lottie.asset(
        animationPath,
        width: size - 32, // Account for padding
        height: size - 32,
        fit: fit,
        repeat: repeat,
        reverse: reverse,
        options: LottieOptions(
          enableMergePaths: true,
        ),
        frameRate: FrameRate(60),
        errorBuilder: (context, error, stackTrace) {
          return _buildErrorWidget(
            context,
            'Animation not found',
            Icons.broken_image,
          );
        },
        // Add a placeholder while loading
        frameBuilder: (context, child, composition) {
          if (composition == null) {
            return Center(
              child: CircularProgressIndicator(
                color: theme.colorScheme.primary,
              ),
            );
          }
          return child;
        },
      );
    } catch (e) {
      return _buildErrorWidget(
        context,
        'Failed to load animation',
        Icons.error_outline,
      );
    }
  }

  Widget _buildErrorWidget(BuildContext context, String message, IconData icon) {
    final theme = Theme.of(context);

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 64,
            color: theme.colorScheme.onSurface.withOpacity(0.3),
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.6),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

/// A compact version of the exercise animation player for list items
class CompactExerciseAnimation extends StatelessWidget {
  final String animationPath;
  final double size;

  const CompactExerciseAnimation({
    super.key,
    required this.animationPath,
    this.size = 80.0,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (animationPath.isEmpty) {
      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceVariant,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(
          Icons.fitness_center,
          size: size * 0.5,
          color: theme.colorScheme.onSurfaceVariant,
        ),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Lottie.asset(
        animationPath,
        width: size,
        height: size,
        fit: BoxFit.cover,
        repeat: true,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceVariant,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.fitness_center,
              size: size * 0.5,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          );
        },
      ),
    );
  }
}

/// A hero animation wrapper for exercise animations
class HeroExerciseAnimation extends StatelessWidget {
  final String heroTag;
  final String animationPath;
  final double size;

  const HeroExerciseAnimation({
    super.key,
    required this.heroTag,
    required this.animationPath,
    this.size = 300.0,
  });

  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: heroTag,
      child: ExerciseAnimationPlayer(
        animationPath: animationPath,
        size: size,
      ),
    );
  }
}
