import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../database/app_database.dart';
import '../themes/colors.dart';

/// Chart widget for displaying pelvic floor strength over time
class PelvicFloorChartWidget extends StatelessWidget {
  final List<Assessment> assessmentData;

  const PelvicFloorChartWidget({
    super.key,
    required this.assessmentData,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (assessmentData.isEmpty) {
      return Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Container(
          height: 300,
          padding: const EdgeInsets.all(24),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.insert_chart_outlined,
                  size: 64,
                  color: theme.colorScheme.onSurface.withOpacity(0.3),
                ),
                const SizedBox(height: 16),
                Text(
                  'No assessments yet',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Complete your first assessment to track your progress',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.5),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    // Sort by creation date and assign week numbers
    final sortedData = assessmentData.toList()
      ..sort((a, b) => a.createdAt.compareTo(b.createdAt));

    // Calculate weeks from first assessment
    final firstDate = sortedData.first.createdAt;
    final List<FlSpot> spots = sortedData.asMap().entries.map((entry) {
      final index = entry.key;
      final assessment = entry.value;

      // Get score from answers
      final yesCount = _countYesAnswers(assessment.answers);

      // Week number (0-based index + 1, or calculate from date)
      final weekNumber = index + 1;

      return FlSpot(
        weekNumber.toDouble(),
        yesCount.toDouble(),
      );
    }).toList();

    final maxScore = spots.map((s) => s.y).reduce((a, b) => a > b ? a : b);
    final maxWeek = spots.last.x;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Pelvic Floor Assessment Trend',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Number of "yes" answers over time (lower is better)',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 250,
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: true,
                    horizontalInterval: 1,
                    verticalInterval: 1,
                    getDrawingHorizontalLine: (value) {
                      return FlLine(
                        color: theme.colorScheme.outline.withOpacity(0.1),
                        strokeWidth: 1,
                      );
                    },
                    getDrawingVerticalLine: (value) {
                      return FlLine(
                        color: theme.colorScheme.outline.withOpacity(0.1),
                        strokeWidth: 1,
                      );
                    },
                  ),
                  titlesData: FlTitlesData(
                    show: true,
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    bottomTitles: AxisTitles(
                      axisNameWidget: Text(
                        'Assessment #',
                        style: theme.textTheme.bodySmall,
                      ),
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 30,
                        interval: 1,
                        getTitlesWidget: (value, meta) {
                          if (value == value.toInt().toDouble()) {
                            return Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Text(
                                value.toInt().toString(),
                                style: theme.textTheme.bodySmall,
                              ),
                            );
                          }
                          return const SizedBox.shrink();
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      axisNameWidget: Text(
                        'Issues',
                        style: theme.textTheme.bodySmall,
                      ),
                      sideTitles: SideTitles(
                        showTitles: true,
                        interval: 1,
                        reservedSize: 40,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            value.toInt().toString(),
                            style: theme.textTheme.bodySmall,
                          );
                        },
                      ),
                    ),
                  ),
                  borderData: FlBorderData(
                    show: true,
                    border: Border.all(
                      color: theme.colorScheme.outline.withOpacity(0.2),
                    ),
                  ),
                  minX: 0.5,
                  maxX: maxWeek + 0.5,
                  minY: 0,
                  maxY: (maxScore + 1).ceilToDouble().clamp(10, double.infinity),
                  lineBarsData: [
                    LineChartBarData(
                      spots: spots,
                      isCurved: true,
                      color: _getLineColor(spots.last.y),
                      barWidth: 4,
                      isStrokeCapRound: true,
                      dotData: FlDotData(
                        show: true,
                        getDotPainter: (spot, percent, barData, index) {
                          return FlDotCirclePainter(
                            radius: 6,
                            color: _getLineColor(spot.y),
                            strokeWidth: 2,
                            strokeColor: Colors.white,
                          );
                        },
                      ),
                      belowBarData: BarAreaData(
                        show: true,
                        color: _getLineColor(spots.last.y).withOpacity(0.1),
                      ),
                    ),
                  ],
                  lineTouchData: LineTouchData(
                    enabled: true,
                    touchTooltipData: LineTouchTooltipData(
                      getTooltipItems: (List<LineBarSpot> touchedSpots) {
                        return touchedSpots.map((spot) {
                          return LineTooltipItem(
                            'Assessment ${spot.x.toInt()}\n${spot.y.toInt()} issues',
                            const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          );
                        }).toList();
                      },
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            _buildLegend(theme),
          ],
        ),
      ),
    );
  }

  Widget _buildLegend(ThemeData theme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _LegendItem(
          color: AppColors.success,
          label: 'Strong (0-2)',
          theme: theme,
        ),
        const SizedBox(width: 16),
        _LegendItem(
          color: AppColors.warning,
          label: 'Moderate (3-4)',
          theme: theme,
        ),
        const SizedBox(width: 16),
        _LegendItem(
          color: AppColors.danger,
          label: 'Weak (5+)',
          theme: theme,
        ),
      ],
    );
  }

  Color _getLineColor(double score) {
    if (score <= 2) {
      return AppColors.success;
    } else if (score <= 4) {
      return AppColors.warning;
    } else {
      return AppColors.danger;
    }
  }

  int _countYesAnswers(Map<String, dynamic> answers) {
    int count = 0;
    answers.forEach((key, value) {
      // Skip the strength rating question (it's not yes/no)
      if (key != 'strength_rating' && value == true) {
        count++;
      }
    });
    return count;
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;
  final ThemeData theme;

  const _LegendItem({
    required this.color,
    required this.label,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: theme.textTheme.bodySmall,
        ),
      ],
    );
  }
}
