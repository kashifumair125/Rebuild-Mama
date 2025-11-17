import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../providers/onboarding_provider.dart';
import '../../../providers/database_provider.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/progress_provider.dart';
import '../../../models/user_profile.dart';
import 'package:drift/drift.dart' as drift;

class SymptomAssessmentScreen extends ConsumerStatefulWidget {
  const SymptomAssessmentScreen({super.key});

  @override
  ConsumerState<SymptomAssessmentScreen> createState() =>
      _SymptomAssessmentScreenState();
}

class _SymptomAssessmentScreenState
    extends ConsumerState<SymptomAssessmentScreen> {
  bool _isSubmitting = false;

  Future<void> _completeOnboarding() async {
    final answers = ref.read(assessmentAnswersProvider);
    final results = ref.read(assessmentResultsProvider);
    final deliveryType = ref.read(deliveryTypeProvider);
    final deliveryDate = ref.read(deliveryDateProvider);
    final weeksPostpartum = ref.read(weeksPostpartumProvider);
    final userId = ref.read(userIdProvider);

    if (results == null || deliveryType == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please answer all questions before continuing'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final database = ref.read(appDatabaseProvider);

      // Create or update user profile
      // Note: In a real app, you'd get the actual userId from Firebase Auth
      final userDao = database.userDao;

      // For now, create a demo user or update existing
      // In production, you'd use the actual Firebase user ID
      await userDao.createUser(
        name: 'User', // You can collect this in signup
        email: userId ?? 'demo@example.com',
        passwordHash: '', // Handled by Firebase
        deliveryType: deliveryType == DeliveryType.vaginal ? 'vaginal' : 'c_section',
        weeksPostpartum: weeksPostpartum,
      );

      // Get the created user (for demo, we'll use ID 1)
      // In production, you'd get the actual user ID
      final demoUserId = 1;

      // Save pelvic floor assessment
      final assessmentDao = database.assessmentDao;
      await assessmentDao.createAssessment(
        userId: demoUserId,
        type: 'pelvic_floor',
        questions: {
          'q1': 'Do you leak urine when coughing/sneezing?',
          'q2': 'Do you feel heaviness in pelvic area?',
          'q3': 'Do you have pain during intercourse?',
          'q4': 'Can you control urination?',
          'q5': 'Do you experience pelvic pain?',
        },
        answers: {
          'q1': answers.leaksUrine,
          'q2': answers.pelvicHeaviness,
          'q3': answers.painDuringIntercourse,
          'q4': answers.canControlUrination,
          'q5': answers.hasPelvicPain,
        },
        classification: results.pelvicFloorClassification.toLowerCase(),
      );

      // Save diastasis recti assessment
      await assessmentDao.createAssessment(
        userId: demoUserId,
        type: 'diastasis_recti',
        questions: {
          'q1': 'Do you have visible ab separation?',
          'q2': 'Does your belly dome when standing?',
          'q3': 'Do you have back pain?',
        },
        answers: {
          'q1': answers.visibleAbSeparation,
          'q2': answers.bellyDoming,
          'q3': answers.hasBackPain,
          'recovery_difficulty': answers.recoveryDifficulty,
          'pain_level': answers.painLevel,
        },
        classification: results.diastasisRectiClassification.toLowerCase(),
      );

      // Show results dialog before navigating
      if (mounted) {
        await _showResultsDialog(results);
      }

      // Navigate to home screen
      if (mounted) {
        context.go('/home');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving assessment: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  Future<void> _showResultsDialog(results) async {
    final theme = Theme.of(context);
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Row(
          children: [
            Icon(Icons.check_circle, color: theme.colorScheme.primary, size: 32),
            const SizedBox(width: 12),
            const Text('Assessment Complete!'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Based on your responses:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _ResultRow(
              label: 'Pelvic Floor',
              value: results.pelvicFloorClassification,
            ),
            const SizedBox(height: 8),
            _ResultRow(
              label: 'Diastasis Recti',
              value: results.diastasisRectiClassification,
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.fitness_center,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Recommended Level: ${results.recommendedLevel}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.primary,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          FilledButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('Get Started'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final answers = ref.watch(assessmentAnswersProvider);
    final results = ref.watch(assessmentResultsProvider);
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: theme.colorScheme.onBackground),
          onPressed: () {
            ref.read(onboardingStepProvider.notifier).state = 2;
            context.go('/onboarding/weeks-postpartum');
          },
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  // Progress indicator
                  _buildProgressIndicator(context, 3, 3),
                  const SizedBox(height: 24),

                  // Title
                  Text(
                    'Symptom Assessment',
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onBackground,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Help us understand your current condition',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: theme.colorScheme.onBackground.withOpacity(0.7),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),

            // Scrollable questions
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Pelvic Floor Section
                    _SectionHeader(
                      icon: Icons.favorite_border,
                      title: 'Pelvic Floor Health',
                      subtitle: '5 questions',
                    ),
                    const SizedBox(height: 16),
                    _YesNoQuestion(
                      question: 'Do you leak urine when coughing/sneezing?',
                      value: answers.leaksUrine,
                      onChanged: (value) {
                        ref.read(assessmentAnswersProvider.notifier).state =
                            answers.copyWith(leaksUrine: value);
                      },
                    ),
                    _YesNoQuestion(
                      question: 'Do you feel heaviness in pelvic area?',
                      value: answers.pelvicHeaviness,
                      onChanged: (value) {
                        ref.read(assessmentAnswersProvider.notifier).state =
                            answers.copyWith(pelvicHeaviness: value);
                      },
                    ),
                    _YesNoQuestion(
                      question: 'Do you have pain during intercourse?',
                      value: answers.painDuringIntercourse,
                      onChanged: (value) {
                        ref.read(assessmentAnswersProvider.notifier).state =
                            answers.copyWith(painDuringIntercourse: value);
                      },
                    ),
                    _YesNoQuestion(
                      question: 'Can you control urination?',
                      value: answers.canControlUrination,
                      onChanged: (value) {
                        ref.read(assessmentAnswersProvider.notifier).state =
                            answers.copyWith(canControlUrination: value);
                      },
                    ),
                    _YesNoQuestion(
                      question: 'Do you experience pelvic pain?',
                      value: answers.hasPelvicPain,
                      onChanged: (value) {
                        ref.read(assessmentAnswersProvider.notifier).state =
                            answers.copyWith(hasPelvicPain: value);
                      },
                    ),

                    const SizedBox(height: 32),

                    // Diastasis Recti Section
                    _SectionHeader(
                      icon: Icons.accessibility_new,
                      title: 'Diastasis Recti',
                      subtitle: '3 questions',
                    ),
                    const SizedBox(height: 16),
                    _YesNoQuestion(
                      question: 'Do you have visible ab separation?',
                      value: answers.visibleAbSeparation,
                      onChanged: (value) {
                        ref.read(assessmentAnswersProvider.notifier).state =
                            answers.copyWith(visibleAbSeparation: value);
                      },
                    ),
                    _YesNoQuestion(
                      question: 'Does your belly dome when standing?',
                      value: answers.bellyDoming,
                      onChanged: (value) {
                        ref.read(assessmentAnswersProvider.notifier).state =
                            answers.copyWith(bellyDoming: value);
                      },
                    ),
                    _YesNoQuestion(
                      question: 'Do you have back pain?',
                      value: answers.hasBackPain,
                      onChanged: (value) {
                        ref.read(assessmentAnswersProvider.notifier).state =
                            answers.copyWith(hasBackPain: value);
                      },
                    ),

                    const SizedBox(height: 32),

                    // General Section
                    _SectionHeader(
                      icon: Icons.assessment,
                      title: 'General Assessment',
                      subtitle: '2 questions',
                    ),
                    const SizedBox(height: 16),
                    _SliderQuestion(
                      question: 'Overall recovery difficulty',
                      min: 1,
                      max: 5,
                      divisions: 4,
                      value: answers.recoveryDifficulty,
                      minLabel: 'Easy',
                      maxLabel: 'Very Hard',
                      onChanged: (value) {
                        ref.read(assessmentAnswersProvider.notifier).state =
                            answers.copyWith(recoveryDifficulty: value);
                      },
                    ),
                    _SliderQuestion(
                      question: 'Current pain level',
                      min: 1,
                      max: 10,
                      divisions: 9,
                      value: answers.painLevel,
                      minLabel: 'No Pain',
                      maxLabel: 'Severe',
                      onChanged: (value) {
                        ref.read(assessmentAnswersProvider.notifier).state =
                            answers.copyWith(painLevel: value);
                      },
                    ),

                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),

            // Bottom navigation
            Container(
              padding: const EdgeInsets.all(24.0),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _isSubmitting
                          ? null
                          : () {
                              ref.read(onboardingStepProvider.notifier).state = 2;
                              context.go('/onboarding/weeks-postpartum');
                            },
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: const Text(
                        'Back',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    flex: 2,
                    child: FilledButton(
                      onPressed: _isSubmitting || !answers.isComplete
                          ? null
                          : _completeOnboarding,
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: _isSubmitting
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text(
                              'Complete',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
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

  Widget _buildProgressIndicator(BuildContext context, int current, int total) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Row(
          children: List.generate(total, (index) {
            final isActive = index < current;
            return Expanded(
              child: Container(
                height: 4,
                margin: EdgeInsets.only(right: index < total - 1 ? 8 : 0),
                decoration: BoxDecoration(
                  color: isActive
                      ? theme.colorScheme.primary
                      : theme.colorScheme.primary.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            );
          }),
        ),
        const SizedBox(height: 8),
        Text(
          'Step $current of $total',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onBackground.withOpacity(0.6),
          ),
        ),
      ],
    );
  }
}

// Section Header Widget
class _SectionHeader extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _SectionHeader({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: theme.colorScheme.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: theme.colorScheme.primary,
            size: 24,
          ),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              subtitle,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onBackground.withOpacity(0.6),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// Yes/No Question Widget
class _YesNoQuestion extends StatelessWidget {
  final String question;
  final bool? value;
  final ValueChanged<bool> onChanged;

  const _YesNoQuestion({
    required this.question,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: value != null
              ? theme.colorScheme.primary.withOpacity(0.3)
              : theme.colorScheme.outline.withOpacity(0.2),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            question,
            style: theme.textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _ChoiceButton(
                  label: 'Yes',
                  isSelected: value == true,
                  onTap: () => onChanged(true),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _ChoiceButton(
                  label: 'No',
                  isSelected: value == false,
                  onTap: () => onChanged(false),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// Choice Button Widget
class _ChoiceButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _ChoiceButton({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? theme.colorScheme.primary
              : theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? theme.colorScheme.primary
                : theme.colorScheme.outline.withOpacity(0.3),
            width: 1.5,
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: isSelected
                  ? theme.colorScheme.onPrimary
                  : theme.colorScheme.onSurface,
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
          ),
        ),
      ),
    );
  }
}

// Slider Question Widget
class _SliderQuestion extends StatelessWidget {
  final String question;
  final double min;
  final double max;
  final int divisions;
  final double value;
  final String minLabel;
  final String maxLabel;
  final ValueChanged<double> onChanged;

  const _SliderQuestion({
    required this.question,
    required this.min,
    required this.max,
    required this.divisions,
    required this.value,
    required this.minLabel,
    required this.maxLabel,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.primary.withOpacity(0.3),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  question,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  value.toInt().toString(),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: theme.colorScheme.primary,
              inactiveTrackColor: theme.colorScheme.primary.withOpacity(0.2),
              thumbColor: theme.colorScheme.primary,
              overlayColor: theme.colorScheme.primary.withOpacity(0.2),
              trackHeight: 4,
            ),
            child: Slider(
              value: value,
              min: min,
              max: max,
              divisions: divisions,
              onChanged: onChanged,
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                minLabel,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onBackground.withOpacity(0.6),
                ),
              ),
              Text(
                maxLabel,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onBackground.withOpacity(0.6),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// Result Row Widget for Dialog
class _ResultRow extends StatelessWidget {
  final String label;
  final String value;

  const _ResultRow({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          '$label:',
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        Chip(
          label: Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          backgroundColor: _getColorForValue(context, value),
        ),
      ],
    );
  }

  Color _getColorForValue(BuildContext context, String value) {
    final theme = Theme.of(context);
    switch (value.toLowerCase()) {
      case 'strong':
      case 'none':
        return Colors.green.withOpacity(0.2);
      case 'moderate':
      case 'mild':
        return Colors.orange.withOpacity(0.2);
      case 'weak':
      case 'severe':
        return Colors.red.withOpacity(0.2);
      default:
        return theme.colorScheme.primary.withOpacity(0.2);
    }
  }
}
