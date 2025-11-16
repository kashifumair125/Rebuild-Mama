import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../themes/colors.dart';

/// Progress summary card widget displaying overall progress
class ProgressSummaryCard extends StatelessWidget {
  final DateTime startDate;
  final int weekNumber;
  final int healthScore;
  final String motivationalMessage;

  const ProgressSummaryCard({
    super.key,
    required this.startDate,
    required this.weekNumber,
    required this.healthScore,
    required this.motivationalMessage,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.primary,
              AppColors.primary.withOpacity(0.8),
            ],
          ),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Your Recovery Journey',
                        style: theme.textTheme.titleLarge?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Started ${DateFormat('MMM d, yyyy').format(startDate)}',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: Colors.white.withOpacity(0.9),
                        ),
                      ),
                    ],
                  ),
                ),
                // Health score circle
                _buildHealthScoreCircle(theme),
              ],
            ),
            const SizedBox(height: 20),
            // Week progress
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.calendar_today,
                    color: Colors.white,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Week $weekNumber of recovery',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // Motivational message
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.lightbulb_outline,
                    color: AppColors.warning,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      motivationalMessage,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurface,
                        fontWeight: FontWeight.w500,
                      ),
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

  Widget _buildHealthScoreCircle(ThemeData theme) {
    final scoreColor = _getScoreColor(healthScore);

    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            healthScore.toString(),
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: scoreColor,
            ),
          ),
          Text(
            'SCORE',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: scoreColor,
              letterSpacing: 1,
            ),
          ),
        ],
      ),
    );
  }

  Color _getScoreColor(int score) {
    if (score >= 80) return AppColors.success;
    if (score >= 60) return AppColors.warning;
    return AppColors.danger;
  }

  static String getMotivationalMessage(int healthScore, int weekNumber) {
    if (healthScore >= 80) {
      return "Outstanding progress! You're crushing it! 💪";
    } else if (healthScore >= 60) {
      return "Great work! Keep up the consistency. 🌟";
    } else if (weekNumber <= 2) {
      return "Every journey starts with a single step. You've got this! 🎯";
    } else {
      return "Progress takes time. Stay consistent and trust the process. 🌱";
    }
  }

  static int calculateHealthScore({
    required double? diastasisImprovement,
    required double? pelvicFloorImprovement,
    required int workoutStreak,
    required int completedWorkouts,
  }) {
    int score = 50; // Base score

    // Diastasis improvement (max 20 points)
    if (diastasisImprovement != null) {
      score += (diastasisImprovement.clamp(0, 100) * 0.2).round();
    }

    // Pelvic floor improvement (max 20 points)
    if (pelvicFloorImprovement != null) {
      score += (pelvicFloorImprovement.clamp(0, 100) * 0.2).round();
    }

    // Workout streak (max 15 points)
    if (workoutStreak > 0) {
      score += (workoutStreak.clamp(0, 30) * 0.5).round();
    }

    // Completed workouts (max 15 points)
    if (completedWorkouts > 0) {
      score += (completedWorkouts.clamp(0, 30) * 0.5).round();
    }

    return score.clamp(0, 100);
  }
}
