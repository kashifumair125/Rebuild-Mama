import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../database/app_database.dart';
import '../themes/colors.dart';

/// Pelvic floor strength indicator widget
class PelvicFloorStrengthIndicator extends StatelessWidget {
  final List<Progress> progressData;
  final int currentLevel;
  final VoidCallback onAssessment;

  const PelvicFloorStrengthIndicator({
    super.key,
    required this.progressData,
    required this.currentLevel,
    required this.onAssessment,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final trend = _calculateTrend();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Pelvic Floor Strength',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            TextButton.icon(
              onPressed: onAssessment,
              icon: const Icon(Icons.assessment, size: 18),
              label: const Text('Assess'),
            ),
          ],
        ),
        const SizedBox(height: 16),
        // Current level display
        Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Current Level',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurface.withOpacity(0.7),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.baseline,
                          textBaseline: TextBaseline.alphabetic,
                          children: [
                            Text(
                              currentLevel.toString(),
                              style: theme.textTheme.displayMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: _getLevelColor(currentLevel),
                              ),
                            ),
                            Text(
                              '/10',
                              style: theme.textTheme.titleLarge?.copyWith(
                                color: theme.colorScheme.onSurface.withOpacity(0.5),
                              ),
                            ),
                          ],
                        ),
                        Text(
                          _getLevelDescription(currentLevel),
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: _getLevelColor(currentLevel),
                          ),
                        ),
                      ],
                    ),
                    // Mini gauge
                    _buildMiniGauge(theme, currentLevel),
                  ],
                ),
                const SizedBox(height: 20),
                // Strength bar
                _buildStrengthBar(theme, currentLevel),
                const SizedBox(height: 16),
                // Trend indicator
                if (trend != null) _buildTrendIndicator(theme, trend),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        // Weekly assessment history
        if (progressData.isNotEmpty) _buildWeeklyHistory(theme),
      ],
    );
  }

  Widget _buildMiniGauge(ThemeData theme, int level) {
    return SizedBox(
      width: 100,
      height: 100,
      child: Stack(
        children: [
          // Background arc
          CustomPaint(
            size: const Size(100, 100),
            painter: _GaugePainter(
              progress: level / 10,
              color: _getLevelColor(level),
              backgroundColor: theme.colorScheme.surfaceVariant,
            ),
          ),
          // Center text
          Center(
            child: Text(
              '${(level * 10).toInt()}%',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: _getLevelColor(level),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStrengthBar(ThemeData theme, int level) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: List.generate(10, (index) {
            final isActive = index < level;
            return Expanded(
              child: Container(
                height: 8,
                margin: EdgeInsets.only(
                  right: index < 9 ? 4 : 0,
                ),
                decoration: BoxDecoration(
                  color: isActive
                      ? _getBarColor(index + 1)
                      : theme.colorScheme.surfaceVariant,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            );
          }),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Weak',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.5),
              ),
            ),
            Text(
              'Strong',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.5),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTrendIndicator(ThemeData theme, String trend) {
    IconData icon;
    Color color;
    String message;

    switch (trend) {
      case 'improving':
        icon = Icons.trending_up;
        color = AppColors.success;
        message = 'Improving';
        break;
      case 'stable':
        icon = Icons.trending_flat;
        color = AppColors.warning;
        message = 'Stable';
        break;
      case 'declining':
        icon = Icons.trending_down;
        color = AppColors.danger;
        message = 'Needs attention';
        break;
      default:
        return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 8),
          Text(
            'Trend: $message',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeeklyHistory(ThemeData theme) {
    // Get last 4 weeks
    final sortedData = progressData.toList()
      ..sort((a, b) => b.recordedAt.compareTo(a.recordedAt));
    final recentData = sortedData.take(4).toList().reversed.toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Recent Assessments',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        ...recentData.map((data) {
          final strength = (data.value?['strength'] as num?)?.toInt() ?? currentLevel;
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                Container(
                  width: 60,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceVariant,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'Wk ${data.weekNumber}',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Row(
                    children: List.generate(10, (index) {
                      final isActive = index < strength;
                      return Expanded(
                        child: Container(
                          height: 6,
                          margin: EdgeInsets.only(
                            right: index < 9 ? 2 : 0,
                          ),
                          decoration: BoxDecoration(
                            color: isActive
                                ? _getBarColor(index + 1)
                                : theme.colorScheme.surfaceVariant.withOpacity(0.5),
                            borderRadius: BorderRadius.circular(3),
                          ),
                        ),
                      );
                    }),
                  ),
                ),
                const SizedBox(width: 12),
                SizedBox(
                  width: 30,
                  child: Text(
                    '$strength/10',
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: _getLevelColor(strength),
                    ),
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  Color _getLevelColor(int level) {
    if (level >= 8) return AppColors.success;
    if (level >= 5) return AppColors.warning;
    return AppColors.danger;
  }

  Color _getBarColor(int position) {
    if (position >= 8) return AppColors.success;
    if (position >= 5) return AppColors.warning;
    return AppColors.danger;
  }

  String _getLevelDescription(int level) {
    if (level >= 8) return 'Strong';
    if (level >= 5) return 'Moderate';
    return 'Weak';
  }

  String? _calculateTrend() {
    if (progressData.length < 2) return null;

    final sortedData = progressData.toList()
      ..sort((a, b) => a.recordedAt.compareTo(b.recordedAt));

    final recent = sortedData.sublist(sortedData.length ~/ 2);
    final earlier = sortedData.sublist(0, sortedData.length ~/ 2);

    final recentAvg = recent.fold<double>(
          0,
          (sum, p) => sum + ((p.value?['strength'] as num?)?.toDouble() ?? 0),
        ) /
        recent.length;

    final earlierAvg = earlier.fold<double>(
          0,
          (sum, p) => sum + ((p.value?['strength'] as num?)?.toDouble() ?? 0),
        ) /
        earlier.length;

    if (recentAvg > earlierAvg + 0.5) return 'improving';
    if (recentAvg < earlierAvg - 0.5) return 'declining';
    return 'stable';
  }
}

class _GaugePainter extends CustomPainter {
  final double progress;
  final Color color;
  final Color backgroundColor;

  _GaugePainter({
    required this.progress,
    required this.color,
    required this.backgroundColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 8;
    const startAngle = -3.14 * 0.75;
    const sweepAngle = 3.14 * 1.5;

    // Background arc
    final bgPaint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 12
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
      false,
      bgPaint,
    );

    // Progress arc
    final progressPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 12
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle * progress,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
