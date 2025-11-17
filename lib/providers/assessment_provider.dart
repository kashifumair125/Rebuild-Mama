import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../database/app_database.dart';
import 'auth_provider.dart';
import 'database_provider.dart';
import 'progress_provider.dart';
import 'package:drift/drift.dart' as drift;

part 'assessment_provider.g.dart';

/// Provider for pelvic floor assessments
@riverpod
Stream<List<Assessment>> pelvicFloorAssessments(
  PelvicFloorAssessmentsRef ref,
) {
  final userId = ref.watch(userIdProvider);

  if (userId == null) {
    return Stream.value([]);
  }

  final db = ref.watch(appDatabaseProvider);
  return db.assessmentDao.watchAssessmentsByUserAndType(userId, 'pelvic_floor');
}

/// Provider for latest pelvic floor assessment
@riverpod
Stream<Assessment?> latestPelvicFloorAssessment(
  LatestPelvicFloorAssessmentRef ref,
) {
  final userId = ref.watch(userIdProvider);

  if (userId == null) {
    return Stream.value(null);
  }

  final db = ref.watch(appDatabaseProvider);
  return db.assessmentDao.watchLatestAssessmentByType(userId, 'pelvic_floor');
}

/// Provider for diastasis recti assessments
@riverpod
Stream<List<Assessment>> diastasisAssessments(
  DiastasisAssessmentsRef ref,
) {
  final userId = ref.watch(userIdProvider);

  if (userId == null) {
    return Stream.value([]);
  }

  final db = ref.watch(appDatabaseProvider);
  return db.assessmentDao.watchAssessmentsByUserAndType(userId, 'diastasis_recti');
}

/// Provider for latest diastasis assessment
@riverpod
Stream<Assessment?> latestDiastasisAssessment(
  LatestDiastasisAssessmentRef ref,
) {
  final userId = ref.watch(userIdProvider);

  if (userId == null) {
    return Stream.value(null);
  }

  final db = ref.watch(appDatabaseProvider);
  return db.assessmentDao.watchLatestAssessmentByType(userId, 'diastasis_recti');
}

/// Notifier for submitting pelvic floor assessment
@riverpod
class PelvicFloorAssessmentSubmitter extends _$PelvicFloorAssessmentSubmitter {
  @override
  FutureOr<void> build() {}

  Future<void> submitAssessment(Map<String, dynamic> answers) async {
    state = const AsyncValue.loading();

    state = await AsyncValue.guard(() async {
      final userId = ref.read(userIdProvider);
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      // Calculate classification based on answers
      final classification = _calculatePelvicFloorClassification(answers);

      // Create assessment companion
      final assessment = AssessmentsCompanion(
        userId: drift.Value(userId),
        type: const drift.Value('pelvic_floor'),
        questions: drift.Value(_getPelvicFloorQuestions()),
        answers: drift.Value(answers),
        classification: drift.Value(classification),
        createdAt: drift.Value(DateTime.now()),
      );

      final db = ref.read(appDatabaseProvider);
      await db.assessmentDao.insertAssessment(assessment);
    });
  }

  String _calculatePelvicFloorClassification(Map<String, dynamic> answers) {
    // Count yes answers (excluding strength rating)
    int yesCount = 0;
    answers.forEach((key, value) {
      if (key != 'strength_rating' && value == true) {
        yesCount++;
      }
    });

    // Classification logic:
    // 0-2 yes answers → "strong"
    // 3-4 yes answers → "moderate"
    // 5+ yes answers → "weak"
    if (yesCount <= 2) {
      return 'strong';
    } else if (yesCount <= 4) {
      return 'moderate';
    } else {
      return 'weak';
    }
  }

  Map<String, dynamic> _getPelvicFloorQuestions() {
    return {
      'q1': 'When you cough or sneeze, do you leak urine?',
      'q2': 'Do you feel heaviness or pressure in your pelvic area?',
      'q3': 'Do you have pain or discomfort during intercourse?',
      'q4': 'Can you control the flow of urine once you start?',
      'q5': 'Do you experience persistent pelvic pain?',
      'q6': 'Do you leak when you laugh?',
      'q7': 'Do you have urgent urge to urinate?',
      'q8': 'Do you experience pelvic pain during periods?',
      'q9': 'Do you have anal leakage or urgency?',
      'q10': 'Rate your pelvic floor strength (1-10 scale)',
    };
  }
}

/// Notifier for submitting weekly pelvic floor check-in
@riverpod
class WeeklyPelvicFloorCheckIn extends _$WeeklyPelvicFloorCheckIn {
  @override
  FutureOr<void> build() {}

  Future<void> submitCheckIn(Map<String, dynamic> answers) async {
    state = const AsyncValue.loading();

    state = await AsyncValue.guard(() async {
      final userId = ref.read(userIdProvider);
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      // Calculate classification based on answers
      final classification = _calculateClassification(answers);

      // Create assessment companion (weekly check-ins are also assessments)
      final assessment = AssessmentsCompanion(
        userId: drift.Value(userId),
        type: const drift.Value('pelvic_floor'),
        questions: drift.Value(_getWeeklyQuestions()),
        answers: drift.Value(answers),
        classification: drift.Value(classification),
        createdAt: drift.Value(DateTime.now()),
      );

      final db = ref.read(appDatabaseProvider);
      await db.assessmentDao.insertAssessment(assessment);
    });
  }

  String _calculateClassification(Map<String, dynamic> answers) {
    // Count yes answers
    int yesCount = 0;
    answers.forEach((key, value) {
      if (value == true) {
        yesCount++;
      }
    });

    // Simplified classification for weekly check-in
    if (yesCount <= 1) {
      return 'strong';
    } else if (yesCount <= 2) {
      return 'moderate';
    } else {
      return 'weak';
    }
  }

  Map<String, dynamic> _getWeeklyQuestions() {
    return {
      'q1': 'Did you experience any urine leakage this week?',
      'q2': 'Did you feel heaviness in your pelvic area?',
      'q3': 'Did you have any pelvic pain?',
      'q4': 'Did you have difficulty controlling your bladder?',
      'q5': 'Did you experience any discomfort during exercise?',
    };
  }
}

/// Notifier for submitting diastasis recti measurement
@riverpod
class DiastasisMeasurementSubmitter extends _$DiastasisMeasurementSubmitter {
  @override
  FutureOr<void> build() {}

  Future<void> submitMeasurement({
    required double gapWidth,
    required bool hasDome,
    required String separationVisual,
    bool isInitial = false,
  }) async {
    state = const AsyncValue.loading();

    state = await AsyncValue.guard(() async {
      final userId = ref.read(userIdProvider);
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      final db = ref.read(appDatabaseProvider);

      // Get week number (calculate from first assessment or use 1 for initial)
      int weekNumber = 1;
      if (!isInitial) {
        final firstAssessment = await db.assessmentDao
            .getInitialAssessmentByType(userId, 'diastasis_recti');
        if (firstAssessment != null) {
          final daysDiff = DateTime.now().difference(firstAssessment.createdAt).inDays;
          weekNumber = (daysDiff / 7).ceil() + 1;
        }
      }

      // Store in Progress table for tracking
      final progress = ProgressRecordsCompanion(
        userId: drift.Value(userId),
        type: const drift.Value('diastasis'),
        value: drift.Value({
          'gap': gapWidth,
          'hasDome': hasDome,
          'separationVisual': separationVisual,
        }),
        weekNumber: drift.Value(weekNumber),
        recordedAt: drift.Value(DateTime.now()),
      );

      await db.progressDao.insertProgress(progress);

      // Also create an assessment record for initial test
      if (isInitial) {
        final classification = _calculateDiastasisClassification(gapWidth);
        final assessment = AssessmentsCompanion(
          userId: drift.Value(userId),
          type: const drift.Value('diastasis_recti'),
          questions: drift.Value(_getDiastasisQuestions()),
          answers: drift.Value({
            'gapWidth': gapWidth,
            'hasDome': hasDome,
            'separationVisual': separationVisual,
          }),
          classification: drift.Value(classification),
          createdAt: drift.Value(DateTime.now()),
        );

        await db.assessmentDao.insertAssessment(assessment);
      }
    });
  }

  String _calculateDiastasisClassification(double gapWidth) {
    if (gapWidth <= 2) {
      return 'normal';
    } else if (gapWidth <= 3) {
      return 'mild';
    } else if (gapWidth <= 4) {
      return 'moderate';
    } else {
      return 'severe';
    }
  }

  Map<String, dynamic> _getDiastasisQuestions() {
    return {
      'gapWidth': 'Measure your diastasis gap width in finger widths',
      'hasDome': 'Is there a visible dome when standing?',
      'separationVisual': 'Visual assessment of ab separation',
    };
  }
}

/// Provider for assessment improvement comparison
@riverpod
Future<Map<String, dynamic>> assessmentImprovement(
  AssessmentImprovementRef ref,
  String type,
) async {
  final userId = ref.watch(userIdProvider);

  if (userId == null) {
    return {
      'hasImprovement': false,
      'message': 'User not authenticated',
    };
  }

  final db = ref.read(appDatabaseProvider);
  return await db.assessmentDao.getAssessmentImprovement(userId, type);
}
