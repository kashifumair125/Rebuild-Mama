import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../widgets/custom_segmented_button.dart';
import '../../widgets/assessment_question_card.dart';
import '../../../providers/assessment_provider.dart';

/// Weekly Pelvic Floor Check-in Screen (simplified 5-question version)
class PelvicFloorCheckinScreen extends ConsumerStatefulWidget {
  const PelvicFloorCheckinScreen({super.key});

  @override
  ConsumerState<PelvicFloorCheckinScreen> createState() =>
      _PelvicFloorCheckinScreenState();
}

class _PelvicFloorCheckinScreenState
    extends ConsumerState<PelvicFloorCheckinScreen> {
  // Answer storage - simplified to 5 questions
  final Map<String, dynamic> _answers = {
    'q1': null, // urine leakage
    'q2': null, // heaviness
    'q3': null, // pelvic pain
    'q4': null, // bladder control
    'q5': null, // discomfort during exercise
  };

  Future<void> _submitCheckIn() async {
    // Check if all questions are answered
    final unanswered = _answers.entries.where((e) => e.value == null).toList();

    if (unanswered.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please answer all questions'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Submit weekly check-in
    await ref
        .read(weeklyPelvicFloorCheckInProvider.notifier)
        .submitCheckIn(_answers);

    if (!mounted) return;

    // Show result
    final checkInState = ref.read(weeklyPelvicFloorCheckInProvider);

    checkInState.when(
      data: (_) {
        _showResultDialog();
      },
      error: (error, stack) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $error'),
            backgroundColor: Colors.red,
          ),
        );
      },
      loading: () {},
    );
  }

  void _showResultDialog() {
    // Calculate result
    int yesCount = 0;
    _answers.forEach((key, value) {
      if (value == true) yesCount++;
    });

    String status;
    String message;
    Color statusColor;

    if (yesCount <= 1) {
      status = 'Great Progress!';
      message = 'Your pelvic floor is doing well. Keep up the good work!';
      statusColor = Colors.green;
    } else if (yesCount <= 2) {
      status = 'Moderate Progress';
      message = 'You\'re making progress, but continue with your exercises.';
      statusColor = Colors.orange;
    } else {
      status = 'Keep Working';
      message = 'Continue with your exercises and consider consulting a specialist.';
      statusColor = Colors.red;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.check_circle, color: statusColor),
            const SizedBox(width: 8),
            Expanded(child: Text(status)),
          ],
        ),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              context.pop(); // Close dialog
              context.pop(); // Go back to previous screen
            },
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }

  bool _allAnswered() {
    return _answers.values.every((value) => value != null);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Weekly Check-In'),
        backgroundColor: const Color(0xFFFFB6C1),
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFFFFB6C1).withOpacity(0.1),
            ),
            child: Column(
              children: [
                const Icon(
                  Icons.assignment_outlined,
                  size: 48,
                  color: Color(0xFFFFB6C1),
                ),
                const SizedBox(height: 12),
                Text(
                  'Quick Weekly Assessment',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Answer 5 quick questions about your week',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.6),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.access_time,
                      size: 16,
                      color: Color(0xFFFFB6C1),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Takes about 2 minutes',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: const Color(0xFFFFB6C1),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Questions
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                AssessmentQuestionCard(
                  questionNumber: 1,
                  totalQuestions: 5,
                  child: CustomSegmentedButton(
                    label: 'Did you experience any urine leakage this week?',
                    value: _answers['q1'],
                    onChanged: (value) {
                      setState(() {
                        _answers['q1'] = value;
                      });
                    },
                  ),
                ),
                const SizedBox(height: 16),
                AssessmentQuestionCard(
                  questionNumber: 2,
                  totalQuestions: 5,
                  child: CustomSegmentedButton(
                    label: 'Did you feel heaviness in your pelvic area?',
                    value: _answers['q2'],
                    onChanged: (value) {
                      setState(() {
                        _answers['q2'] = value;
                      });
                    },
                  ),
                ),
                const SizedBox(height: 16),
                AssessmentQuestionCard(
                  questionNumber: 3,
                  totalQuestions: 5,
                  child: CustomSegmentedButton(
                    label: 'Did you have any pelvic pain?',
                    value: _answers['q3'],
                    onChanged: (value) {
                      setState(() {
                        _answers['q3'] = value;
                      });
                    },
                  ),
                ),
                const SizedBox(height: 16),
                AssessmentQuestionCard(
                  questionNumber: 4,
                  totalQuestions: 5,
                  child: CustomSegmentedButton(
                    label: 'Did you have difficulty controlling your bladder?',
                    value: _answers['q4'],
                    onChanged: (value) {
                      setState(() {
                        _answers['q4'] = value;
                      });
                    },
                  ),
                ),
                const SizedBox(height: 16),
                AssessmentQuestionCard(
                  questionNumber: 5,
                  totalQuestions: 5,
                  child: CustomSegmentedButton(
                    label: 'Did you experience any discomfort during exercise?',
                    value: _answers['q5'],
                    onChanged: (value) {
                      setState(() {
                        _answers['q5'] = value;
                      });
                    },
                  ),
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),

          // Submit button
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.scaffoldBackgroundColor,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _allAnswered() ? _submitCheckIn : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFFB6C1),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text(
                  'Submit Check-In',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
