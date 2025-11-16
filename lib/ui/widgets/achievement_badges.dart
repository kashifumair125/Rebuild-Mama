import 'package:flutter/material.dart';
import '../../providers/progress_provider.dart';
import '../themes/colors.dart';

/// Achievement badges widget for displaying user milestones
class AchievementBadges extends StatelessWidget {
  final List<Achievement> achievements;

  const AchievementBadges({
    super.key,
    required this.achievements,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final unlockedAchievements =
        achievements.where((a) => a.isUnlocked).toList();
    final lockedAchievements =
        achievements.where((a) => !a.isUnlocked).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Achievements',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        if (unlockedAchievements.isNotEmpty)
          Text(
            '${unlockedAchievements.length} of ${achievements.length} unlocked',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
        const SizedBox(height: 16),
        // Unlocked achievements
        if (unlockedAchievements.isNotEmpty) ...[
          Text(
            'UNLOCKED',
            style: theme.textTheme.labelMedium?.copyWith(
              color: AppColors.success,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: unlockedAchievements
                .map((achievement) => _buildBadge(
                      context,
                      theme,
                      achievement,
                      isLocked: false,
                    ))
                .toList(),
          ),
          const SizedBox(height: 24),
        ],
        // Locked achievements
        if (lockedAchievements.isNotEmpty) ...[
          Text(
            'IN PROGRESS',
            style: theme.textTheme.labelMedium?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.5),
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: lockedAchievements
                .map((achievement) => _buildBadge(
                      context,
                      theme,
                      achievement,
                      isLocked: true,
                    ))
                .toList(),
          ),
        ],
      ],
    );
  }

  Widget _buildBadge(
    BuildContext context,
    ThemeData theme,
    Achievement achievement, {
    required bool isLocked,
  }) {
    return GestureDetector(
      onTap: () => _showAchievementDetails(context, achievement),
      child: Container(
        width: 100,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isLocked
              ? theme.colorScheme.surfaceVariant.withOpacity(0.3)
              : AppColors.success.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isLocked
                ? theme.colorScheme.outline.withOpacity(0.2)
                : AppColors.success.withOpacity(0.3),
            width: 2,
          ),
        ),
        child: Column(
          children: [
            // Icon/Emoji
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: isLocked
                    ? theme.colorScheme.surfaceVariant
                    : AppColors.success.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  achievement.icon,
                  style: TextStyle(
                    fontSize: 24,
                    color: isLocked
                        ? theme.colorScheme.onSurface.withOpacity(0.3)
                        : null,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            // Title
            Text(
              achievement.title,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: isLocked
                    ? theme.colorScheme.onSurface.withOpacity(0.5)
                    : theme.colorScheme.onSurface,
              ),
            ),
            // Progress indicator for locked achievements
            if (isLocked && achievement.progress > 0) ...[
              const SizedBox(height: 8),
              LinearProgressIndicator(
                value: achievement.progress / achievement.target,
                backgroundColor: theme.colorScheme.surfaceVariant,
                valueColor: AlwaysStoppedAnimation<Color>(
                  AppColors.primary.withOpacity(0.7),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${achievement.progress}/${achievement.target}',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.5),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _showAchievementDetails(
    BuildContext context,
    Achievement achievement,
  ) {
    final theme = Theme.of(context);

    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Icon
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: achievement.isUnlocked
                      ? AppColors.success.withOpacity(0.2)
                      : theme.colorScheme.surfaceVariant,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    achievement.icon,
                    style: const TextStyle(fontSize: 40),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Badge if unlocked
              if (achievement.isUnlocked)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.success,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'UNLOCKED',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
              const SizedBox(height: 8),
              // Title
              Text(
                achievement.title,
                textAlign: TextAlign.center,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              // Description
              Text(
                achievement.description,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.7),
                ),
              ),
              // Progress bar for locked achievements
              if (!achievement.isUnlocked) ...[
                const SizedBox(height: 24),
                LinearProgressIndicator(
                  value: achievement.progress / achievement.target,
                  backgroundColor: theme.colorScheme.surfaceVariant,
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                  minHeight: 8,
                ),
                const SizedBox(height: 8),
                Text(
                  '${achievement.progress} / ${achievement.target}',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  '${((achievement.progress / achievement.target) * 100).toStringAsFixed(0)}% complete',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
              ],
              const SizedBox(height: 24),
              // Close button
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Close'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
