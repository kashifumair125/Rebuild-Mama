import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../database/app_database.dart';
import '../themes/colors.dart';

/// Calendar heat map widget for displaying workout completion
class WorkoutCalendarHeatmap extends StatelessWidget {
  final List<WorkoutSession> sessions;
  final int monthsToShow;

  const WorkoutCalendarHeatmap({
    super.key,
    required this.sessions,
    this.monthsToShow = 3,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final now = DateTime.now();

    // Get the last N months
    final months = List.generate(monthsToShow, (index) {
      final month = DateTime(now.year, now.month - index, 1);
      return month;
    }).reversed.toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Workout Calendar',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        ...months.map((month) => _buildMonthCalendar(context, month)),
        const SizedBox(height: 16),
        _buildLegend(theme),
      ],
    );
  }

  Widget _buildMonthCalendar(BuildContext context, DateTime month) {
    final theme = Theme.of(context);
    final daysInMonth = DateTime(month.year, month.month + 1, 0).day;
    final firstDayOfMonth = DateTime(month.year, month.month, 1);
    final firstWeekday = firstDayOfMonth.weekday;

    // Get sessions for this month
    final monthStart = DateTime(month.year, month.month, 1);
    final monthEnd = DateTime(month.year, month.month, daysInMonth, 23, 59, 59);
    final monthSessions = sessions.where((session) {
      final sessionDate = session.completedAt ?? session.startedAt;
      return sessionDate.isAfter(monthStart.subtract(const Duration(days: 1))) &&
          sessionDate.isBefore(monthEnd.add(const Duration(days: 1)));
    }).toList();

    // Create a map of day -> has workout
    final workoutDays = <int, bool>{};
    for (final session in monthSessions) {
      if (session.isCompleted) {
        final sessionDate = session.completedAt ?? session.startedAt;
        workoutDays[sessionDate.day] = true;
      }
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            DateFormat('MMMM yyyy').format(month),
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          // Weekday headers
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: ['M', 'T', 'W', 'T', 'F', 'S', 'S'].map((day) {
              return SizedBox(
                width: 32,
                child: Text(
                  day,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 8),
          // Calendar grid
          _buildCalendarGrid(
            context,
            daysInMonth,
            firstWeekday,
            workoutDays,
            month,
          ),
        ],
      ),
    );
  }

  Widget _buildCalendarGrid(
    BuildContext context,
    int daysInMonth,
    int firstWeekday,
    Map<int, bool> workoutDays,
    DateTime month,
  ) {
    final theme = Theme.of(context);
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    // Monday = 1, Sunday = 7 in Dart
    // We want Monday as 0, Sunday as 6
    int startOffset = firstWeekday - 1;

    final totalCells = daysInMonth + startOffset;
    final rows = (totalCells / 7).ceil();

    return Column(
      children: List.generate(rows, (weekIndex) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(7, (dayIndex) {
              final cellIndex = weekIndex * 7 + dayIndex;
              final day = cellIndex - startOffset + 1;

              if (cellIndex < startOffset || day > daysInMonth) {
                // Empty cell
                return const SizedBox(width: 32, height: 32);
              }

              final cellDate = DateTime(month.year, month.month, day);
              final isToday = cellDate.year == today.year &&
                  cellDate.month == today.month &&
                  cellDate.day == today.day;
              final hasWorkout = workoutDays[day] ?? false;
              final isFuture = cellDate.isAfter(today);

              return _buildDayCell(
                theme,
                day,
                hasWorkout,
                isToday,
                isFuture,
              );
            }),
          ),
        );
      }),
    );
  }

  Widget _buildDayCell(
    ThemeData theme,
    int day,
    bool hasWorkout,
    bool isToday,
    bool isFuture,
  ) {
    Color backgroundColor;
    Color? textColor;
    Color? borderColor;

    if (isFuture) {
      // Future dates - light gray
      backgroundColor = theme.colorScheme.surfaceVariant.withOpacity(0.3);
      textColor = theme.colorScheme.onSurface.withOpacity(0.3);
    } else if (hasWorkout) {
      // Completed workout - green
      backgroundColor = AppColors.success;
      textColor = Colors.white;
    } else {
      // Missed workout - light gray
      backgroundColor = theme.colorScheme.surfaceVariant.withOpacity(0.5);
      textColor = theme.colorScheme.onSurface.withOpacity(0.4);
    }

    if (isToday) {
      borderColor = theme.colorScheme.primary;
    }

    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(8),
        border: borderColor != null
            ? Border.all(color: borderColor, width: 2)
            : null,
      ),
      child: Center(
        child: Text(
          day.toString(),
          style: theme.textTheme.bodySmall?.copyWith(
            color: textColor,
            fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
          ),
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
          label: 'Completed',
          theme: theme,
        ),
        const SizedBox(width: 16),
        _LegendItem(
          color: theme.colorScheme.surfaceVariant.withOpacity(0.5),
          label: 'Missed',
          theme: theme,
        ),
      ],
    );
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
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: theme.textTheme.bodySmall,
        ),
      ],
    );
  }
}
