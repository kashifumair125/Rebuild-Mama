import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../widgets/custom_slider_widget.dart';
import '../../widgets/custom_segmented_button.dart';
import '../../widgets/assessment_question_card.dart';
import '../../../providers/assessment_provider.dart';

/// Pelvic Floor Assessment Screen with full 10-question questionnaire
class PelvicFloorAssessmentScreen extends ConsumerStatefulWidget {
  const PelvicFloorAssessmentScreen({super.key});

  @override
  ConsumerState<PelvicFloorAssessmentScreen> createState() =>
      _PelvicFloorAssessmentScreenState();
}

class _PelvicFloorAssessmentScreenState
    extends ConsumerState<PelvicFloorAssessmentScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  // Answer storage
  final Map<String, dynamic> _answers = {
    'q1': null, // cough/sneeze leak
    'q2': null, // heaviness
    'q3': null, // intercourse pain
    'q4': null, // urine control (inverted: no means yes problem)
    'q5': null, // persistent pain
    'q6': null, // laugh leak
    'q7': null, // urgent urge
    'q8': null, // period pain
    'q9': null, // anal issues
    'strength_rating': 5.0, // 1-10 scale
  };

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < 9) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _submitAssessment();
    }
  }

  void _previousPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  Future<void> _submitAssessment() async {
    // Check if all questions are answered
    final unanswered = _answers.entries.where((e) {
      if (e.key == 'strength_rating') return false;
      return e.value == null;
    }).toList();

    if (unanswered.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please answer all questions'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Submit assessment
    await ref
        .read(pelvicFloorAssessmentSubmitterProvider.notifier)
        .submitAssessment(_answers);

    if (!mounted) return;

    // Show result
    final submitter = ref.read(pelvicFloorAssessmentSubmitterProvider);

    submitter.when(
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
    // Calculate classification
    int yesCount = 0;
    _answers.forEach((key, value) {
      if (key != 'strength_rating' && key != 'q4') {
        if (value == true) yesCount++;
      } else if (key == 'q4') {
        // Q4 is inverted: "Can you control?" - No means problem
        if (value == false) yesCount++;
      }
    });

    String classification;
    String message;
    String recommendation;

    if (yesCount <= 2) {
      classification = 'Strong';
      message = 'Congratulations! Your pelvic floor is strong.';
      recommendation = 'You can safely proceed with Level 3 exercises.';
    } else if (yesCount <= 4) {
      classification = 'Moderate';
      message = 'Your pelvic floor shows moderate weakness.';
      recommendation = 'We recommend starting with Level 2 exercises.';
    } else {
      classification = 'Weak';
      message = 'Your pelvic floor needs strengthening.';
      recommendation = 'Please start with Level 1 exercises and consider consulting a pelvic floor physical therapist.';
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text('Assessment Complete: $classification'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(message),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFFFB6C1).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.lightbulb_outline,
                    color: Color(0xFFFFB6C1),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      recommendation,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
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

  bool _canProceed() {
    // Check if current question is answered
    final currentKey = _getCurrentQuestionKey();
    return _answers[currentKey] != null;
  }

  String _getCurrentQuestionKey() {
    if (_currentPage == 9) {
      return 'strength_rating';
    }
    return 'q${_currentPage + 1}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pelvic Floor Assessment'),
        backgroundColor: const Color(0xFFFFB6C1),
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // Progress indicator
          LinearProgressIndicator(
            value: (_currentPage + 1) / 10,
            backgroundColor: const Color(0xFFFFB6C1).withOpacity(0.2),
            valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFFFB6C1)),
          ),

          // Questions
          Expanded(
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              onPageChanged: (page) {
                setState(() {
                  _currentPage = page;
                });
              },
              children: [
                _buildQuestion1(),
                _buildQuestion2(),
                _buildQuestion3(),
                _buildQuestion4(),
                _buildQuestion5(),
                _buildQuestion6(),
                _buildQuestion7(),
                _buildQuestion8(),
                _buildQuestion9(),
                _buildQuestion10(),
              ],
            ),
          ),

          // Navigation buttons
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
            child: Row(
              children: [
                if (_currentPage > 0)
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _previousPage,
                      child: const Text('Previous'),
                    ),
                  ),
                if (_currentPage > 0) const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _canProceed() ? _nextPage : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFFB6C1),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: Text(
                      _currentPage == 9 ? 'Submit' : 'Next',
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestion1() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: AssessmentQuestionCard(
        questionNumber: 1,
        totalQuestions: 10,
        child: CustomSegmentedButton(
          label: 'When you cough or sneeze, do you leak urine?',
          value: _answers['q1'],
          onChanged: (value) {
            setState(() {
              _answers['q1'] = value;
            });
          },
        ),
      ),
    );
  }

  Widget _buildQuestion2() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: AssessmentQuestionCard(
        questionNumber: 2,
        totalQuestions: 10,
        child: CustomSegmentedButton(
          label: 'Do you feel heaviness or pressure in your pelvic area?',
          value: _answers['q2'],
          onChanged: (value) {
            setState(() {
              _answers['q2'] = value;
            });
          },
        ),
      ),
    );
  }

  Widget _buildQuestion3() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: AssessmentQuestionCard(
        questionNumber: 3,
        totalQuestions: 10,
        child: CustomSegmentedButton(
          label: 'Do you have pain or discomfort during intercourse?',
          value: _answers['q3'],
          onChanged: (value) {
            setState(() {
              _answers['q3'] = value;
            });
          },
        ),
      ),
    );
  }

  Widget _buildQuestion4() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: AssessmentQuestionCard(
        questionNumber: 4,
        totalQuestions: 10,
        child: CustomSegmentedButton(
          label: 'Can you control the flow of urine once you start?',
          hint: 'Yes means good control, No means difficulty controlling',
          value: _answers['q4'],
          onChanged: (value) {
            setState(() {
              _answers['q4'] = value;
            });
          },
        ),
      ),
    );
  }

  Widget _buildQuestion5() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: AssessmentQuestionCard(
        questionNumber: 5,
        totalQuestions: 10,
        child: CustomSegmentedButton(
          label: 'Do you experience persistent pelvic pain?',
          value: _answers['q5'],
          onChanged: (value) {
            setState(() {
              _answers['q5'] = value;
            });
          },
        ),
      ),
    );
  }

  Widget _buildQuestion6() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: AssessmentQuestionCard(
        questionNumber: 6,
        totalQuestions: 10,
        child: CustomSegmentedButton(
          label: 'Do you leak when you laugh?',
          value: _answers['q6'],
          onChanged: (value) {
            setState(() {
              _answers['q6'] = value;
            });
          },
        ),
      ),
    );
  }

  Widget _buildQuestion7() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: AssessmentQuestionCard(
        questionNumber: 7,
        totalQuestions: 10,
        child: CustomSegmentedButton(
          label: 'Do you have urgent urge to urinate?',
          value: _answers['q7'],
          onChanged: (value) {
            setState(() {
              _answers['q7'] = value;
            });
          },
        ),
      ),
    );
  }

  Widget _buildQuestion8() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: AssessmentQuestionCard(
        questionNumber: 8,
        totalQuestions: 10,
        child: CustomSegmentedButton(
          label: 'Do you experience pelvic pain during periods?',
          value: _answers['q8'],
          onChanged: (value) {
            setState(() {
              _answers['q8'] = value;
            });
          },
        ),
      ),
    );
  }

  Widget _buildQuestion9() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: AssessmentQuestionCard(
        questionNumber: 9,
        totalQuestions: 10,
        child: CustomSegmentedButton(
          label: 'Do you have anal leakage or urgency?',
          value: _answers['q9'],
          onChanged: (value) {
            setState(() {
              _answers['q9'] = value;
            });
          },
        ),
      ),
    );
  }

  Widget _buildQuestion10() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: AssessmentQuestionCard(
        questionNumber: 10,
        totalQuestions: 10,
        child: CustomSliderWidget(
          label: 'Rate your pelvic floor strength',
          hint: '1 = Very weak, 10 = Very strong',
          value: _answers['strength_rating'],
          onChanged: (value) {
            setState(() {
              _answers['strength_rating'] = value;
            });
          },
        ),
      ),
    );
  }
}
