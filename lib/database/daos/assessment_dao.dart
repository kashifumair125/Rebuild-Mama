import 'package:drift/drift.dart';
import '../app_database.dart';

part 'assessment_dao.g.dart';

@DriftAccessor(tables: [Assessments])
class AssessmentDao extends DatabaseAccessor<AppDatabase> with _$AssessmentDaoMixin {
  AssessmentDao(AppDatabase db) : super(db);

  // ============================================================================
  // CREATE
  // ============================================================================

  /// Insert a new assessment
  Future<int> insertAssessment(AssessmentsCompanion assessment) async {
    return await into(assessments).insert(assessment);
  }

  /// Batch insert multiple assessments
  Future<void> insertMultipleAssessments(
    List<AssessmentsCompanion> assessmentList,
  ) async {
    await batch((batch) {
      batch.insertAll(assessments, assessmentList);
    });
  }

  /// Helper method to create a new assessment with individual parameters
  Future<int> createAssessment({
    required int userId,
    required String type,
    required Map<String, dynamic> questions,
    required Map<String, dynamic> answers,
    required String classification,
  }) async {
    final assessment = AssessmentsCompanion(
      userId: Value(userId),
      type: Value(type),
      questions: Value(questions),
      answers: Value(answers),
      classification: Value(classification),
    );
    return await insertAssessment(assessment);
  }

  // ============================================================================
  // READ
  // ============================================================================

  /// Get assessment by ID
  Future<Assessment?> getAssessmentById(int assessmentId) async {
    return await (select(assessments)
          ..where((a) => a.assessmentId.equals(assessmentId)))
        .getSingleOrNull();
  }

  /// Get all assessments for a user
  Future<List<Assessment>> getAssessmentsByUserId(int userId) async {
    return await (select(assessments)
          ..where((a) => a.userId.equals(userId))
          ..orderBy([(a) => OrderingTerm.desc(a.createdAt)]))
        .get();
  }

  /// Get assessments by user and type
  Future<List<Assessment>> getAssessmentsByUserAndType(
    int userId,
    String type,
  ) async {
    return await (select(assessments)
          ..where((a) => a.userId.equals(userId) & a.type.equals(type))
          ..orderBy([(a) => OrderingTerm.desc(a.createdAt)]))
        .get();
  }

  /// Get latest assessment for a user by type
  Future<Assessment?> getLatestAssessmentByType(
    int userId,
    String type,
  ) async {
    return await (select(assessments)
          ..where((a) => a.userId.equals(userId) & a.type.equals(type))
          ..orderBy([(a) => OrderingTerm.desc(a.createdAt)])
          ..limit(1))
        .getSingleOrNull();
  }

  /// Get initial assessment (first assessment) by type
  Future<Assessment?> getInitialAssessmentByType(
    int userId,
    String type,
  ) async {
    return await (select(assessments)
          ..where((a) => a.userId.equals(userId) & a.type.equals(type))
          ..orderBy([(a) => OrderingTerm.asc(a.createdAt)])
          ..limit(1))
        .getSingleOrNull();
  }

  /// Get assessments by classification
  Future<List<Assessment>> getAssessmentsByClassification(
    int userId,
    String classification,
  ) async {
    return await (select(assessments)
          ..where((a) =>
              a.userId.equals(userId) & a.classification.equals(classification))
          ..orderBy([(a) => OrderingTerm.desc(a.createdAt)]))
        .get();
  }

  /// Get assessment history for a user (all types)
  Future<List<Assessment>> getAssessmentHistory(
    int userId, {
    int? limit,
    int? offset,
  }) async {
    final query = select(assessments)
      ..where((a) => a.userId.equals(userId))
      ..orderBy([(a) => OrderingTerm.desc(a.createdAt)]);

    if (limit != null) query.limit(limit, offset: offset);

    return await query.get();
  }

  /// Get assessments within date range
  Future<List<Assessment>> getAssessmentsByDateRange(
    int userId,
    DateTime startDate,
    DateTime endDate, {
    String? type,
  }) async {
    final query = select(assessments)
      ..where((a) =>
          a.userId.equals(userId) &
          a.createdAt.isBiggerOrEqualValue(startDate) &
          a.createdAt.isSmallerOrEqualValue(endDate));

    if (type != null) {
      query.where((a) => a.type.equals(type));
    }

    query.orderBy([(a) => OrderingTerm.desc(a.createdAt)]);

    return await query.get();
  }

  /// Watch assessments for a user (reactive stream)
  Stream<List<Assessment>> watchAssessmentsByUserId(int userId) {
    return (select(assessments)
          ..where((a) => a.userId.equals(userId))
          ..orderBy([(a) => OrderingTerm.desc(a.createdAt)]))
        .watch();
  }

  /// Watch assessments by user and type (reactive stream)
  Stream<List<Assessment>> watchAssessmentsByUserAndType(
    int userId,
    String type,
  ) {
    return (select(assessments)
          ..where((a) => a.userId.equals(userId) & a.type.equals(type))
          ..orderBy([(a) => OrderingTerm.desc(a.createdAt)]))
        .watch();
  }

  /// Watch latest assessment by type
  Stream<Assessment?> watchLatestAssessmentByType(
    int userId,
    String type,
  ) {
    return (select(assessments)
          ..where((a) => a.userId.equals(userId) & a.type.equals(type))
          ..orderBy([(a) => OrderingTerm.desc(a.createdAt)])
          ..limit(1))
        .watchSingleOrNull();
  }

  // ============================================================================
  // UPDATE
  // ============================================================================

  /// Update an assessment
  Future<bool> updateAssessment(Assessment assessment) async {
    return await update(assessments).replace(assessment);
  }

  /// Update assessment classification
  Future<int> updateClassification(
    int assessmentId,
    String classification,
  ) async {
    return await (update(assessments)
          ..where((a) => a.assessmentId.equals(assessmentId)))
        .write(
      AssessmentsCompanion(
        classification: Value(classification),
      ),
    );
  }

  /// Update assessment answers
  Future<int> updateAnswers(
    int assessmentId,
    Map<String, dynamic> answers,
  ) async {
    return await (update(assessments)
          ..where((a) => a.assessmentId.equals(assessmentId)))
        .write(
      AssessmentsCompanion(
        answers: Value(answers),
      ),
    );
  }

  // ============================================================================
  // DELETE
  // ============================================================================

  /// Delete an assessment
  Future<int> deleteAssessment(int assessmentId) async {
    return await (delete(assessments)
          ..where((a) => a.assessmentId.equals(assessmentId)))
        .go();
  }

  /// Delete all assessments for a user
  Future<int> deleteAssessmentsByUserId(int userId) async {
    return await (delete(assessments)..where((a) => a.userId.equals(userId)))
        .go();
  }

  /// Delete assessments by type for a user
  Future<int> deleteAssessmentsByType(int userId, String type) async {
    return await (delete(assessments)
          ..where((a) => a.userId.equals(userId) & a.type.equals(type)))
        .go();
  }

  // ============================================================================
  // UTILITY
  // ============================================================================

  /// Get assessment count for a user
  Future<int> getAssessmentCount(int userId, {String? type}) async {
    final countExp = assessments.assessmentId.count();
    final query = selectOnly(assessments)..addColumns([countExp]);

    query.where(assessments.userId.equals(userId));

    if (type != null) {
      query.where(assessments.type.equals(type));
    }

    final result = await query.getSingle();
    return result.read(countExp) ?? 0;
  }

  /// Check if user has completed initial assessment of a type
  Future<bool> hasCompletedInitialAssessment(
    int userId,
    String type,
  ) async {
    final count = await getAssessmentCount(userId, type: type);
    return count > 0;
  }

  /// Get assessment improvement (compare first and latest)
  Future<Map<String, dynamic>> getAssessmentImprovement(
    int userId,
    String type,
  ) async {
    final initial = await getInitialAssessmentByType(userId, type);
    final latest = await getLatestAssessmentByType(userId, type);

    if (initial == null || latest == null) {
      return {
        'hasImprovement': false,
        'initialClassification': null,
        'latestClassification': null,
        'message': 'Not enough assessments to compare',
      };
    }

    final classificationLevels = {'weak': 1, 'moderate': 2, 'strong': 3};
    final initialLevel = classificationLevels[initial.classification] ?? 0;
    final latestLevel = classificationLevels[latest.classification] ?? 0;

    return {
      'hasImprovement': latestLevel > initialLevel,
      'initialClassification': initial.classification,
      'latestClassification': latest.classification,
      'improvementLevel': latestLevel - initialLevel,
      'initialDate': initial.createdAt,
      'latestDate': latest.createdAt,
    };
  }

  /// Get assessments with pagination
  Future<List<Assessment>> getAssessmentsPaginated(
    int userId, {
    int page = 0,
    int pageSize = 10,
    String? type,
  }) async {
    final query = select(assessments)
      ..where((a) => a.userId.equals(userId))
      ..orderBy([(a) => OrderingTerm.desc(a.createdAt)])
      ..limit(pageSize, offset: page * pageSize);

    if (type != null) {
      query.where((a) => a.type.equals(type));
    }

    return await query.get();
  }
}
