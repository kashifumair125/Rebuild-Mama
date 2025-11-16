import 'package:flutter/material.dart';
import '../themes/colors.dart';

/// Card widget for displaying progress status
class ProgressCard extends StatelessWidget {
  final String title;
  final String currentStatus;
  final ProgressTrend trend;
  final String? weeksToGoal;
  final List<String> tips;
  final Color? statusColor;

  const ProgressCard({
    super.key,
    required this.title,
    required this.currentStatus,
    required this.trend,
    this.weeksToGoal,
    this.tips = const [],
    this.statusColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title
            Text(
              title,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            // Current Status
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: (statusColor ?? const Color(0xFFFFB6C1)).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.favorite,
                    color: statusColor ?? const Color(0xFFFFB6C1),
                    size: 32,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Current Status',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurface.withOpacity(0.6),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          currentStatus,
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: statusColor ?? const Color(0xFFFFB6C1),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Trend
            Row(
              children: [
                Icon(
                  _getTrendIcon(trend),
                  color: _getTrendColor(trend),
                  size: 24,
                ),
                const SizedBox(width: 8),
                Text(
                  _getTrendText(trend),
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: _getTrendColor(trend),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),

            if (weeksToGoal != null) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  const Icon(
                    Icons.flag,
                    size: 20,
                    color: AppColors.info,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Est. $weeksToGoal to goal',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: AppColors.info,
                    ),
                  ),
                ],
              ),
            ],

            if (tips.isNotEmpty) ...[
              const SizedBox(height: 20),
              const Divider(),
              const SizedBox(height: 12),
              Text(
                'Tips for Improvement',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              ...tips.map((tip) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(top: 6),
                      child: Icon(
                        Icons.check_circle,
                        size: 16,
                        color: AppColors.success,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        tip,
                        style: theme.textTheme.bodyMedium,
                      ),
                    ),
                  ],
                ),
              )),
            ],
          ],
        ),
      ),
    );
  }

  IconData _getTrendIcon(ProgressTrend trend) {
    switch (trend) {
      case ProgressTrend.improving:
        return Icons.trending_down; // Down is good for gap reduction
      case ProgressTrend.stable:
        return Icons.trending_flat;
      case ProgressTrend.worsening:
        return Icons.trending_up; // Up is bad for gap width
    }
  }

  Color _getTrendColor(ProgressTrend trend) {
    switch (trend) {
      case ProgressTrend.improving:
        return AppColors.success;
      case ProgressTrend.stable:
        return AppColors.warning;
      case ProgressTrend.worsening:
        return AppColors.danger;
    }
  }

  String _getTrendText(ProgressTrend trend) {
    switch (trend) {
      case ProgressTrend.improving:
        return 'Improving';
      case ProgressTrend.stable:
        return 'Stable';
      case ProgressTrend.worsening:
        return 'Worsening';
    }
  }
}

enum ProgressTrend {
  improving,
  stable,
  worsening,
}
