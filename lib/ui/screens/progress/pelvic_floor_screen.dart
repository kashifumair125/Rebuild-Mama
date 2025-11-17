import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../widgets/pelvic_floor_chart_widget.dart';
import '../../widgets/progress_card.dart';
import '../../../providers/assessment_provider.dart';
import '../../../config/routes.dart';
import '../../../database/app_database.dart';

/// Pelvic Floor Progress tracking screen
/// Shows assessment history, trends, and charts
class PelvicFloorScreen extends ConsumerWidget {
  const PelvicFloorScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final assessmentsAsync = ref.watch(pelvicFloorAssessmentsProvider);
    final latestAssessmentAsync = ref.watch(latestPelvicFloorAssessmentProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pelvic Floor Progress'),
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
      body: assessmentsAsync.when(
        data: (List<Assessment> assessments) {
          return latestAssessmentAsync.when(
            data: (Assessment? latestAssessment) {
              if (assessments.isEmpty) {
                return _buildEmptyState(context);
              }

              return _buildContent(
                context,
                theme,
                assessments,
                latestAssessment,
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, stack) => Center(child: Text('Error: $error')),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: $error')),
      ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton.extended(
            heroTag: 'weekly_checkin',
            onPressed: () {
              context.push('/pelvic-floor-checkin');
            },
            backgroundColor: const Color(0xFFFFB6C1),
            foregroundColor: Colors.white,
            label: const Text('Weekly Check-In'),
            icon: const Icon(Icons.assignment_outlined),
          ),
          const SizedBox(height: 12),
          FloatingActionButton.extended(
            heroTag: 'full_assessment',
            onPressed: () {
              context.push('/pelvic-floor-assessment');
            },
            backgroundColor: Colors.white,
            foregroundColor: const Color(0xFFFFB6C1),
            label: const Text('Full Assessment'),
            icon: const Icon(Icons.assessment),
          ),
        ],
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
              Icons.favorite_border,
              size: 80,
              color: Color(0xFFFFB6C1),
            ),
            const SizedBox(height: 24),
            Text(
              'No Assessments Yet',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),
            Text(
              'Start tracking your pelvic floor health by completing your first assessment.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                  ),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () {
                context.push('/pelvic-floor-assessment');
              },
              icon: const Icon(Icons.assessment),
              label: const Text('Start First Assessment'),
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
    List<Assessment> assessments,
    Assessment? latestAssessment,
  ) {
    // Calculate current status
    String currentStatus = 'Unknown';
    ProgressTrend trend = ProgressTrend.stable;
    List<String> tips = [];

    if (latestAssessment != null) {
      currentStatus = _getStatusLabel(latestAssessment.classification);

      // Calculate trend
      if (assessments.length >= 2) {
        final previousAssessment = assessments[1];
        trend = _calculateTrend(
          previousAssessment.classification,
          latestAssessment.classification,
        );
      }

      // Get tips based on classification
      tips = _getTips(latestAssessment.classification);
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Progress Card
        ProgressCard(
          title: 'Pelvic Floor Health',
          currentStatus: currentStatus,
          trend: trend,
          tips: tips,
          statusColor: _getStatusColor(latestAssessment?.classification),
        ),
        const SizedBox(height: 20),

        // Chart
        PelvicFloorChartWidget(assessmentData: assessments),
        const SizedBox(height: 20),

        // Assessment History
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
                  'Assessment History',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                ...assessments.take(5).map((assessment) {
                  return _buildHistoryItem(theme, assessment);
                }),
                if (assessments.length > 5) ...[
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: () {
                      // Navigate to full history
                    },
                    child: const Text('View All'),
                  ),
                ],
              ],
            ),
          ),
        ),
        const SizedBox(height: 100), // Space for FABs
      ],
    );
  }

  Widget _buildHistoryItem(ThemeData theme, dynamic assessment) {
    final date = assessment.createdAt;
    final classification = assessment.classification;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(
          color: theme.colorScheme.outline.withOpacity(0.2),
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(
            Icons.assignment_turned_in,
            color: _getStatusColor(classification),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _getStatusLabel(classification),
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: _getStatusColor(classification),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${date.day}/${date.month}/${date.year}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getStatusLabel(String classification) {
    switch (classification.toLowerCase()) {
      case 'strong':
        return 'Strong - Level 3 Ready';
      case 'moderate':
        return 'Moderate - Level 2 Recommended';
      case 'weak':
        return 'Weak - Level 1 Recommended';
      default:
        return classification;
    }
  }

  Color _getStatusColor(String? classification) {
    if (classification == null) return const Color(0xFFFFB6C1);

    switch (classification.toLowerCase()) {
      case 'strong':
        return const Color(0xFF6BCF7F); // Green
      case 'moderate':
        return const Color(0xFFFFC837); // Yellow
      case 'weak':
        return const Color(0xFFFF6B6B); // Red
      default:
        return const Color(0xFFFFB6C1);
    }
  }

  ProgressTrend _calculateTrend(String previous, String current) {
    const classificationOrder = {'weak': 1, 'moderate': 2, 'strong': 3};

    final previousLevel = classificationOrder[previous.toLowerCase()] ?? 0;
    final currentLevel = classificationOrder[current.toLowerCase()] ?? 0;

    if (currentLevel > previousLevel) {
      return ProgressTrend.improving;
    } else if (currentLevel < previousLevel) {
      return ProgressTrend.worsening;
    } else {
      return ProgressTrend.stable;
    }
  }

  List<String> _getTips(String classification) {
    switch (classification.toLowerCase()) {
      case 'weak':
        return [
          'Practice kegel exercises 3 times daily',
          'Start with Level 1 workouts',
          'Avoid heavy lifting',
          'Consider consulting a pelvic floor physical therapist',
        ];
      case 'moderate':
        return [
          'Continue with regular kegel exercises',
          'Progress to Level 2 workouts',
          'Focus on proper breathing techniques',
          'Stay hydrated',
        ];
      case 'strong':
        return [
          'Maintain your exercise routine',
          'Challenge yourself with Level 3 workouts',
          'Continue monitoring your symptoms',
          'Share your success with the community',
        ];
      default:
        return [];
    }
  }

  void _showInfoDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('About Pelvic Floor Tracking'),
        content: const SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Regular assessment helps you:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text('• Track your recovery progress'),
              Text('• Identify improvements or issues early'),
              Text('• Adjust your workout level appropriately'),
              Text('• Make informed decisions about your health'),
              SizedBox(height: 16),
              Text(
                'Recommendations:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text('• Complete a full assessment every 4 weeks'),
              Text('• Do weekly check-ins between full assessments'),
              Text('• Be honest with your answers'),
              Text('• Consult a healthcare provider if concerned'),
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
}
