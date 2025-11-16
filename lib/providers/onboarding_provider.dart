import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user_profile.dart';

// ============================================================================
// ONBOARDING STATE PROVIDERS
// ============================================================================

/// Current step in onboarding (1-3)
final onboardingStepProvider = StateProvider<int>((ref) => 1);

/// Selected delivery type (null if not yet selected)
final deliveryTypeProvider = StateProvider<DeliveryType?>((ref) => null);

/// Selected delivery date (defaults to today)
final deliveryDateProvider = StateProvider<DateTime>((ref) => DateTime.now());

/// Calculated weeks postpartum (derived from delivery date)
final weeksPostpartumProvider = Provider<int>((ref) {
  final deliveryDate = ref.watch(deliveryDateProvider);
  final now = DateTime.now();
  final difference = now.difference(deliveryDate);
  return (difference.inDays / 7).floor();
});

// ============================================================================
// SYMPTOM ASSESSMENT STATE
// ============================================================================

/// Assessment answers storage
class AssessmentAnswers {
  // Pelvic floor questions (5)
  bool? leaksUrine; // "Do you leak urine when coughing/sneezing?"
  bool? pelvicHeaviness; // "Do you feel heaviness in pelvic area?"
  bool? painDuringIntercourse; // "Do you have pain during intercourse?"
  bool? canControlUrination; // "Can you control urination?"
  bool? hasPelvicPain; // "Do you experience pelvic pain?"

  // Diastasis recti questions (3)
  bool? visibleAbSeparation; // "Do you have visible ab separation?"
  bool? bellyDoming; // "Does your belly dome when standing?"
  bool? hasBackPain; // "Do you have back pain?"

  // General questions (2)
  double recoveryDifficulty; // "Overall recovery difficulty (1-5)"
  double painLevel; // "Current pain level (1-10)"

  AssessmentAnswers({
    this.leaksUrine,
    this.pelvicHeaviness,
    this.painDuringIntercourse,
    this.canControlUrination,
    this.hasPelvicPain,
    this.visibleAbSeparation,
    this.bellyDoming,
    this.hasBackPain,
    this.recoveryDifficulty = 3.0,
    this.painLevel = 5.0,
  });

  AssessmentAnswers copyWith({
    bool? leaksUrine,
    bool? pelvicHeaviness,
    bool? painDuringIntercourse,
    bool? canControlUrination,
    bool? hasPelvicPain,
    bool? visibleAbSeparation,
    bool? bellyDoming,
    bool? hasBackPain,
    double? recoveryDifficulty,
    double? painLevel,
  }) {
    return AssessmentAnswers(
      leaksUrine: leaksUrine ?? this.leaksUrine,
      pelvicHeaviness: pelvicHeaviness ?? this.pelvicHeaviness,
      painDuringIntercourse: painDuringIntercourse ?? this.painDuringIntercourse,
      canControlUrination: canControlUrination ?? this.canControlUrination,
      hasPelvicPain: hasPelvicPain ?? this.hasPelvicPain,
      visibleAbSeparation: visibleAbSeparation ?? this.visibleAbSeparation,
      bellyDoming: bellyDoming ?? this.bellyDoming,
      hasBackPain: hasBackPain ?? this.hasBackPain,
      recoveryDifficulty: recoveryDifficulty ?? this.recoveryDifficulty,
      painLevel: painLevel ?? this.painLevel,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'leaksUrine': leaksUrine,
      'pelvicHeaviness': pelvicHeaviness,
      'painDuringIntercourse': painDuringIntercourse,
      'canControlUrination': canControlUrination,
      'hasPelvicPain': hasPelvicPain,
      'visibleAbSeparation': visibleAbSeparation,
      'bellyDoming': bellyDoming,
      'hasBackPain': hasBackPain,
      'recoveryDifficulty': recoveryDifficulty,
      'painLevel': painLevel,
    };
  }

  /// Validation: Check if all required questions are answered
  bool get isComplete {
    return leaksUrine != null &&
        pelvicHeaviness != null &&
        painDuringIntercourse != null &&
        canControlUrination != null &&
        hasPelvicPain != null &&
        visibleAbSeparation != null &&
        bellyDoming != null &&
        hasBackPain != null;
  }
}

/// Assessment answers provider
final assessmentAnswersProvider = StateProvider<AssessmentAnswers>(
  (ref) => AssessmentAnswers(),
);

// ============================================================================
// SCORING LOGIC
// ============================================================================

/// Assessment results with calculated scores and recommendations
class AssessmentResults {
  final int pelvicFloorScore; // 0-5
  final String pelvicFloorClassification; // "Strong", "Moderate", "Weak"
  final int diastasisRectiScore; // 0-3
  final String diastasisRectiClassification; // "None", "Mild", "Severe"
  final int recommendedLevel; // 1-3

  AssessmentResults({
    required this.pelvicFloorScore,
    required this.pelvicFloorClassification,
    required this.diastasisRectiScore,
    required this.diastasisRectiClassification,
    required this.recommendedLevel,
  });
}

/// Calculate assessment results based on answers
final assessmentResultsProvider = Provider<AssessmentResults?>((ref) {
  final answers = ref.watch(assessmentAnswersProvider);

  // Only calculate if assessment is complete
  if (!answers.isComplete) {
    return null;
  }

  // Pelvic floor scoring (count problematic answers)
  int pelvicFloorScore = 0;
  if (answers.leaksUrine == true) pelvicFloorScore++;
  if (answers.pelvicHeaviness == true) pelvicFloorScore++;
  if (answers.painDuringIntercourse == true) pelvicFloorScore++;
  if (answers.canControlUrination == false) pelvicFloorScore++; // Reversed: false is bad
  if (answers.hasPelvicPain == true) pelvicFloorScore++;

  // Pelvic floor classification
  String pelvicFloorClassification;
  if (pelvicFloorScore <= 2) {
    pelvicFloorClassification = 'Strong';
  } else if (pelvicFloorScore <= 4) {
    pelvicFloorClassification = 'Moderate';
  } else {
    pelvicFloorClassification = 'Weak';
  }

  // Diastasis recti scoring
  int diastasisRectiScore = 0;
  if (answers.visibleAbSeparation == true) diastasisRectiScore++;
  if (answers.bellyDoming == true) diastasisRectiScore++;
  if (answers.hasBackPain == true) diastasisRectiScore++;

  // Diastasis recti classification
  String diastasisRectiClassification;
  if (diastasisRectiScore <= 1) {
    diastasisRectiClassification = 'None';
  } else if (diastasisRectiScore == 2) {
    diastasisRectiClassification = 'Mild';
  } else {
    diastasisRectiClassification = 'Severe';
  }

  // Level assignment logic
  int recommendedLevel;
  if (pelvicFloorClassification == 'Weak' || diastasisRectiClassification == 'Severe') {
    recommendedLevel = 1; // Start with basics
  } else if (pelvicFloorClassification == 'Moderate' || diastasisRectiClassification == 'Mild') {
    recommendedLevel = answers.recoveryDifficulty <= 2.5 ? 2 : 1;
  } else {
    // Strong pelvic floor and no diastasis
    recommendedLevel = answers.painLevel <= 3 ? 3 : 2;
  }

  return AssessmentResults(
    pelvicFloorScore: pelvicFloorScore,
    pelvicFloorClassification: pelvicFloorClassification,
    diastasisRectiScore: diastasisRectiScore,
    diastasisRectiClassification: diastasisRectiClassification,
    recommendedLevel: recommendedLevel,
  );
});

// ============================================================================
// ONBOARDING COMPLETION ACTIONS
// ============================================================================

/// Reset all onboarding state (useful for testing or re-starting)
void resetOnboarding(WidgetRef ref) {
  ref.read(onboardingStepProvider.notifier).state = 1;
  ref.read(deliveryTypeProvider.notifier).state = null;
  ref.read(deliveryDateProvider.notifier).state = DateTime.now();
  ref.read(assessmentAnswersProvider.notifier).state = AssessmentAnswers();
}

/// Check if onboarding can proceed to next step
bool canProceedFromStep(int step, WidgetRef ref) {
  switch (step) {
    case 1:
      return ref.read(deliveryTypeProvider) != null;
    case 2:
      return true; // Date always has default value
    case 3:
      return ref.read(assessmentAnswersProvider).isComplete;
    default:
      return false;
  }
}
