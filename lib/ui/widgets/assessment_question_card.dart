import 'package:flutter/material.dart';

/// Card widget for wrapping assessment questions
class AssessmentQuestionCard extends StatelessWidget {
  final int questionNumber;
  final int totalQuestions;
  final Widget child;

  const AssessmentQuestionCard({
    super.key,
    required this.questionNumber,
    required this.totalQuestions,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFB6C1).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'Question $questionNumber/$totalQuestions',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: const Color(0xFFFFB6C1),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            child,
          ],
        ),
      ),
    );
  }
}
