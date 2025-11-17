import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../widgets/diastasis_chart_widget.dart';
import '../../widgets/progress_card.dart';
import '../../widgets/gap_width_selector.dart';
import '../../widgets/custom_segmented_button.dart';
import '../../../providers/assessment_provider.dart';
import '../../../providers/progress_provider.dart';
import '../../../database/app_database.dart';

/// Diastasis Recti tracking screen
/// Shows progress chart, measurements, and allows weekly tracking
class DiastasisRectiScreen extends ConsumerWidget {
  const DiastasisRectiScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final progressAsync = ref.watch(diastasisProgressStreamProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Diastasis Recti Tracking'),
        backgroundColor: const Color(0xFFFFB6C1),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () {
              _showInfoDialog(context);
            },
          ),
        ],
      ),
      body: progressAsync.when(
        data: (List<Progress> progressData) {
          if (progressData.isEmpty) {
            return _buildEmptyState(context);
          }

          return _buildContent(context, theme, progressData);
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: $error')),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          _showMeasurementDialog(context, ref, progressAsync.value?.isNotEmpty ?? false);
        },
        backgroundColor: const Color(0xFFFFB6C1),
        foregroundColor: Colors.white,
        label: Text(progressAsync.value?.isEmpty ?? true
            ? 'Initial Test'
            : 'Weekly Update'),
        icon: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.straighten,
              size: 80,
              color: Color(0xFFFFB6C1),
            ),
            const SizedBox(height: 24),
            Text(
              'Start Tracking Diastasis Recti',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),
            Text(
              'Begin by completing your initial measurement test.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                  ),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () {
                _showMeasurementDialog(context, null, true);
              },
              icon: const Icon(Icons.assignment),
              label: const Text('Start Initial Test'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFFB6C1),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 16,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    ThemeData theme,
    List<Progress> progressData,
  ) {
    // Get latest measurement
    final latest = progressData.first;
    final latestGap = (latest.value?['gap'] as num?)?.toDouble() ?? 0.0;
    final hasDome = latest.value?['hasDome'] as bool? ?? false;
    final separationVisual = latest.value?['separationVisual'] as String? ?? 'unknown';

    // Calculate trend
    ProgressTrend trend = ProgressTrend.stable;
    if (progressData.length >= 2) {
      final previous = progressData[1];
      final previousGap = (previous.value?['gap'] as num?)?.toDouble() ?? 0.0;

      if (latestGap < previousGap) {
        trend = ProgressTrend.improving;
      } else if (latestGap > previousGap) {
        trend = ProgressTrend.worsening;
      }
    }

    // Calculate weeks to goal (estimate)
    String? weeksToGoal;
    if (progressData.length >= 2 && trend == ProgressTrend.improving) {
      final first = progressData.last;
      final firstGap = (first.value?['gap'] as num?)?.toDouble() ?? latestGap;
      final gapReduction = firstGap - latestGap;
      final weeksElapsed = latest.weekNumber - first.weekNumber;

      if (gapReduction > 0 && weeksElapsed > 0) {
        final reductionPerWeek = gapReduction / weeksElapsed;
        final remainingGap = latestGap - 2.0; // Target is 2 fingers
        if (remainingGap > 0) {
          final estimatedWeeks = (remainingGap / reductionPerWeek).ceil();
          weeksToGoal = '$estimatedWeeks weeks';
        }
      }
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Progress Card
        ProgressCard(
          title: 'Diastasis Recti Gap',
          currentStatus: '$latestGap finger${latestGap != 1 ? 's' : ''}',
          trend: trend,
          weeksToGoal: weeksToGoal,
          tips: _getTips(latestGap, hasDome),
          statusColor: _getGapColor(latestGap),
        ),
        const SizedBox(height: 20),

        // Chart
        DiastasisChartWidget(
          progressData: progressData,
          targetGap: 2.0,
        ),
        const SizedBox(height: 20),

        // Current Measurement Card
        Card(
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
                  'Latest Measurement',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                _buildMeasurementRow(
                  theme,
                  'Gap Width',
                  '$latestGap finger${latestGap != 1 ? 's' : ''}',
                  Icons.straighten,
                ),
                const Divider(height: 24),
                _buildMeasurementRow(
                  theme,
                  'Visible Dome',
                  hasDome ? 'Yes' : 'No',
                  Icons.fitness_center,
                ),
                const Divider(height: 24),
                _buildMeasurementRow(
                  theme,
                  'Separation',
                  separationVisual.toUpperCase(),
                  Icons.info_outline,
                ),
                const Divider(height: 24),
                _buildMeasurementRow(
                  theme,
                  'Last Updated',
                  '${latest.recordedAt.day}/${latest.recordedAt.month}/${latest.recordedAt.year}',
                  Icons.calendar_today,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),

        // How to Measure Card
        Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.help_outline,
                      color: Color(0xFFFFB6C1),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'How to Measure',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                const Text('1. Lie on your back with knees bent'),
                const SizedBox(height: 8),
                const Text('2. Lift your head slightly off the floor'),
                const SizedBox(height: 8),
                const Text('3. Feel along your midline above your belly button'),
                const SizedBox(height: 8),
                const Text('4. Count how many fingers fit in the gap'),
                const SizedBox(height: 8),
                const Text('5. Note if there\'s a dome when standing'),
              ],
            ),
          ),
        ),
        const SizedBox(height: 100), // Space for FAB
      ],
    );
  }

  Widget _buildMeasurementRow(
    ThemeData theme,
    String label,
    String value,
    IconData icon,
  ) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFFFFB6C1), size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
        ),
        Text(
          value,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Color _getGapColor(double gap) {
    if (gap <= 2) {
      return const Color(0xFF6BCF7F); // Green - Normal
    } else if (gap <= 3) {
      return const Color(0xFF5DADE2); // Blue - Mild
    } else if (gap <= 4) {
      return const Color(0xFFFFC837); // Yellow - Moderate
    } else {
      return const Color(0xFFFF6B6B); // Red - Severe
    }
  }

  List<String> _getTips(double gap, bool hasDome) {
    List<String> tips = [];

    if (gap <= 2) {
      tips = [
        'Your gap is within normal range!',
        'Continue core strengthening exercises',
        'Maintain proper posture',
        'Avoid exercises that cause doming',
      ];
    } else if (gap <= 3) {
      tips = [
        'Focus on gentle core exercises',
        'Practice diaphragmatic breathing',
        'Avoid heavy lifting',
        'Consider physical therapy',
      ];
    } else {
      tips = [
        'Consult a pelvic floor physical therapist',
        'Start with very gentle exercises',
        'Focus on transverse abdominis activation',
        'Avoid traditional crunches and planks',
      ];
    }

    if (hasDome) {
      tips.add('Visible doming - modify exercises to prevent this');
    }

    return tips;
  }

  void _showInfoDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('About Diastasis Recti'),
        content: const SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'What is it?',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(
                'Diastasis recti is the separation of your abdominal muscles, common after pregnancy.',
              ),
              SizedBox(height: 16),
              Text(
                'Normal Range:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text('• 0-2 fingers: Normal'),
              Text('• 2-3 fingers: Mild'),
              Text('• 3-4 fingers: Moderate'),
              Text('• 4+ fingers: Severe'),
              SizedBox(height: 16),
              Text(
                'Tracking Tips:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text('• Measure weekly at the same time'),
              Text('• Be consistent with your measurement technique'),
              Text('• Don\'t compare yourself to others'),
              Text('• Progress takes time - be patient'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => context.pop(),
            child: const Text('Got it'),
          ),
        ],
      ),
    );
  }

  void _showMeasurementDialog(BuildContext context, WidgetRef? ref, bool isInitial) {
    showDialog(
      context: context,
      builder: (dialogContext) => _MeasurementDialog(
        isInitial: isInitial,
        onSubmit: (gapWidth, hasDome, separation) {
          if (ref != null) {
            ref.read(diastasisMeasurementSubmitterProvider.notifier).submitMeasurement(
                  gapWidth: gapWidth,
                  hasDome: hasDome,
                  separationVisual: separation,
                  isInitial: isInitial,
                );
          }
          Navigator.of(dialogContext).pop();
        },
      ),
    );
  }
}

class _MeasurementDialog extends StatefulWidget {
  final bool isInitial;
  final Function(double, bool, String) onSubmit;

  const _MeasurementDialog({
    required this.isInitial,
    required this.onSubmit,
  });

  @override
  State<_MeasurementDialog> createState() => _MeasurementDialogState();
}

class _MeasurementDialogState extends State<_MeasurementDialog> {
  double? _gapWidth;
  bool? _hasDome;
  String? _separation;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AlertDialog(
      title: Text(widget.isInitial ? 'Initial Measurement' : 'Weekly Update'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (widget.isInitial) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFB6C1).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.info_outline, color: Color(0xFFFFB6C1)),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Follow the measurement guide to get accurate results.',
                        style: TextStyle(fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],
            GapWidthSelector(
              selectedGap: _gapWidth,
              onGapSelected: (gap) {
                setState(() {
                  _gapWidth = gap;
                });
              },
            ),
            const SizedBox(height: 20),
            CustomSegmentedButton(
              label: 'Is there a visible dome when standing?',
              value: _hasDome,
              onChanged: (value) {
                setState(() {
                  _hasDome = value;
                });
              },
            ),
            const SizedBox(height: 20),
            Text(
              'Visual Separation Assessment',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            _SeparationOption(
              label: 'Slight',
              isSelected: _separation == 'slight',
              onTap: () => setState(() => _separation = 'slight'),
            ),
            const SizedBox(height: 8),
            _SeparationOption(
              label: 'Moderate',
              isSelected: _separation == 'moderate',
              onTap: () => setState(() => _separation = 'moderate'),
            ),
            const SizedBox(height: 8),
            _SeparationOption(
              label: 'Severe',
              isSelected: _separation == 'severe',
              onTap: () => setState(() => _separation = 'severe'),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _canSubmit()
              ? () {
                  widget.onSubmit(_gapWidth!, _hasDome!, _separation!);
                }
              : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFFFB6C1),
            foregroundColor: Colors.white,
          ),
          child: const Text('Save'),
        ),
      ],
    );
  }

  bool _canSubmit() {
    return _gapWidth != null && _hasDome != null && _separation != null;
  }
}

class _SeparationOption extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _SeparationOption({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFFFFB6C1).withOpacity(0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected
                ? const Color(0xFFFFB6C1)
                : Colors.grey.withOpacity(0.3),
            width: 2,
          ),
        ),
        child: Row(
          children: [
            Icon(
              isSelected ? Icons.check_circle : Icons.circle_outlined,
              color: isSelected ? const Color(0xFFFFB6C1) : Colors.grey,
            ),
            const SizedBox(width: 12),
            Text(
              label,
              style: TextStyle(
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? const Color(0xFFFFB6C1) : null,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
