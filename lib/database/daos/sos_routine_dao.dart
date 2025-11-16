import 'package:drift/drift.dart';
import '../app_database.dart';

part 'sos_routine_dao.g.dart';

@DriftAccessor(tables: [SosRoutines, SosExercises, SosSessionRecords])
class SosRoutineDao extends DatabaseAccessor<AppDatabase>
    with _$SosRoutineDaoMixin {
  SosRoutineDao(AppDatabase db) : super(db);

  // ============================================================================
  // SOS ROUTINES - CREATE
  // ============================================================================

  /// Insert a new SOS routine
  Future<int> insertSosRoutine(SosRoutinesCompanion routine) async {
    return await into(sosRoutines).insert(routine);
  }

  /// Batch insert multiple SOS routines
  Future<void> insertMultipleSosRoutines(
    List<SosRoutinesCompanion> routineList,
  ) async {
    await batch((batch) {
      batch.insertAll(sosRoutines, routineList);
    });
  }

  // ============================================================================
  // SOS ROUTINES - READ
  // ============================================================================

  /// Get all SOS routines ordered by display order
  Future<List<SosRoutine>> getAllSosRoutines() async {
    return await (select(sosRoutines)
          ..orderBy([(r) => OrderingTerm.asc(r.orderIndex)]))
        .get();
  }

  /// Get SOS routine by ID
  Future<SosRoutine?> getSosRoutineById(int sosRoutineId) async {
    return await (select(sosRoutines)
          ..where((r) => r.sosRoutineId.equals(sosRoutineId)))
        .getSingleOrNull();
  }

  /// Watch all SOS routines (reactive stream)
  Stream<List<SosRoutine>> watchAllSosRoutines() {
    return (select(sosRoutines)
          ..orderBy([(r) => OrderingTerm.asc(r.orderIndex)]))
        .watch();
  }

  /// Watch single SOS routine by ID
  Stream<SosRoutine?> watchSosRoutineById(int sosRoutineId) {
    return (select(sosRoutines)
          ..where((r) => r.sosRoutineId.equals(sosRoutineId)))
        .watchSingleOrNull();
  }

  // ============================================================================
  // SOS EXERCISES - CREATE
  // ============================================================================

  /// Insert a new SOS exercise
  Future<int> insertSosExercise(SosExercisesCompanion exercise) async {
    return await into(sosExercises).insert(exercise);
  }

  /// Batch insert multiple SOS exercises
  Future<void> insertMultipleSosExercises(
    List<SosExercisesCompanion> exerciseList,
  ) async {
    await batch((batch) {
      batch.insertAll(sosExercises, exerciseList);
    });
  }

  // ============================================================================
  // SOS EXERCISES - READ
  // ============================================================================

  /// Get exercises for a specific SOS routine
  Future<List<SosExercise>> getSosExercisesByRoutineId(
    int sosRoutineId,
  ) async {
    return await (select(sosExercises)
          ..where((e) => e.sosRoutineId.equals(sosRoutineId))
          ..orderBy([(e) => OrderingTerm.asc(e.orderIndex)]))
        .get();
  }

  /// Get SOS exercise by ID
  Future<SosExercise?> getSosExerciseById(int sosExerciseId) async {
    return await (select(sosExercises)
          ..where((e) => e.sosExerciseId.equals(sosExerciseId)))
        .getSingleOrNull();
  }

  /// Watch exercises for a routine (reactive stream)
  Stream<List<SosExercise>> watchSosExercisesByRoutineId(
    int sosRoutineId,
  ) {
    return (select(sosExercises)
          ..where((e) => e.sosRoutineId.equals(sosRoutineId))
          ..orderBy([(e) => OrderingTerm.asc(e.orderIndex)]))
        .watch();
  }

  // ============================================================================
  // SOS SESSION RECORDS - CREATE
  // ============================================================================

  /// Record a new SOS session
  Future<int> insertSosSessionRecord(
    SosSessionRecordsCompanion session,
  ) async {
    return await into(sosSessionRecords).insert(session);
  }

  /// Record a completed SOS session
  Future<int> recordCompletedSosSession({
    required int userId,
    required int sosRoutineId,
    required DateTime startedAt,
    DateTime? completedAt,
  }) async {
    return await into(sosSessionRecords).insert(
      SosSessionRecordsCompanion(
        userId: Value(userId),
        sosRoutineId: Value(sosRoutineId),
        startedAt: Value(startedAt),
        completedAt: Value(completedAt ?? DateTime.now()),
        isCompleted: const Value(true),
      ),
    );
  }

  // ============================================================================
  // SOS SESSION RECORDS - READ
  // ============================================================================

  /// Get all SOS sessions for a user
  Future<List<SosSessionRecord>> getSosSessionsByUserId(int userId) async {
    return await (select(sosSessionRecords)
          ..where((s) => s.userId.equals(userId))
          ..orderBy([(s) => OrderingTerm.desc(s.startedAt)]))
        .get();
  }

  /// Get SOS sessions for a specific routine
  Future<List<SosSessionRecord>> getSosSessionsByRoutineId(
    int userId,
    int sosRoutineId,
  ) async {
    return await (select(sosSessionRecords)
          ..where((s) =>
              s.userId.equals(userId) & s.sosRoutineId.equals(sosRoutineId))
          ..orderBy([(s) => OrderingTerm.desc(s.startedAt)]))
        .get();
  }

  /// Get recent SOS sessions
  Future<List<SosSessionRecord>> getRecentSosSessions(
    int userId, {
    int limit = 10,
  }) async {
    return await (select(sosSessionRecords)
          ..where((s) => s.userId.equals(userId))
          ..orderBy([(s) => OrderingTerm.desc(s.completedAt)])
          ..limit(limit))
        .get();
  }

  /// Get SOS sessions within date range
  Future<List<SosSessionRecord>> getSosSessionsBetween(
    int userId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    return await (select(sosSessionRecords)
          ..where((s) =>
              s.userId.equals(userId) &
              s.startedAt.isBiggerOrEqualValue(startDate) &
              s.startedAt.isSmallerOrEqualValue(endDate))
          ..orderBy([(s) => OrderingTerm.desc(s.startedAt)]))
        .get();
  }

  /// Watch SOS sessions for a user (reactive stream)
  Stream<List<SosSessionRecord>> watchSosSessionsByUserId(int userId) {
    return (select(sosSessionRecords)
          ..where((s) => s.userId.equals(userId))
          ..orderBy([(s) => OrderingTerm.desc(s.startedAt)]))
        .watch();
  }

  // ============================================================================
  // ANALYTICS & STATISTICS
  // ============================================================================

  /// Get total number of SOS sessions for a user
  Future<int> getTotalSosSessionCount(int userId) async {
    final countExp = sosSessionRecords.sosSessionId.count();
    final query = selectOnly(sosSessionRecords)
      ..addColumns([countExp])
      ..where(sosSessionRecords.userId.equals(userId) &
          sosSessionRecords.isCompleted.equals(true));

    final result = await query.getSingle();
    return result.read(countExp) ?? 0;
  }

  /// Get usage count for a specific SOS routine
  Future<int> getRoutineUsageCount(int userId, int sosRoutineId) async {
    final countExp = sosSessionRecords.sosSessionId.count();
    final query = selectOnly(sosSessionRecords)
      ..addColumns([countExp])
      ..where(sosSessionRecords.userId.equals(userId) &
          sosSessionRecords.sosRoutineId.equals(sosRoutineId) &
          sosSessionRecords.isCompleted.equals(true));

    final result = await query.getSingle();
    return result.read(countExp) ?? 0;
  }

  /// Get most used SOS routine for a user
  Future<Map<String, dynamic>?> getMostUsedSosRoutine(int userId) async {
    // Get all session records for the user
    final sessions = await getSosSessionsByUserId(userId);

    if (sessions.isEmpty) return null;

    // Count usage per routine
    final routineUsage = <int, int>{};
    for (final session in sessions) {
      routineUsage[session.sosRoutineId] =
          (routineUsage[session.sosRoutineId] ?? 0) + 1;
    }

    // Find most used routine ID
    final mostUsedRoutineId = routineUsage.entries
        .reduce((a, b) => a.value > b.value ? a : b)
        .key;

    final routine = await getSosRoutineById(mostUsedRoutineId);
    if (routine == null) return null;

    return {
      'routine': routine,
      'usageCount': routineUsage[mostUsedRoutineId],
    };
  }

  /// Get SOS usage statistics
  Future<Map<String, dynamic>> getSosStatistics(int userId) async {
    final totalSessions = await getTotalSosSessionCount(userId);
    final recentSessions = await getRecentSosSessions(userId, limit: 5);

    // Get usage count per routine
    final allRoutines = await getAllSosRoutines();
    final routineStats = <Map<String, dynamic>>[];

    for (final routine in allRoutines) {
      final usageCount = await getRoutineUsageCount(userId, routine.sosRoutineId);
      routineStats.add({
        'routineId': routine.sosRoutineId,
        'routineName': routine.name,
        'usageCount': usageCount,
      });
    }

    // Sort by usage count descending
    routineStats.sort((a, b) => (b['usageCount'] as int).compareTo(a['usageCount'] as int));

    return {
      'totalSessions': totalSessions,
      'recentSessions': recentSessions,
      'routineStats': routineStats,
      'mostUsedRoutine': routineStats.isNotEmpty ? routineStats.first : null,
    };
  }

  /// Get last used date for a routine
  Future<DateTime?> getLastUsedDate(int userId, int sosRoutineId) async {
    final result = await (select(sosSessionRecords)
          ..where((s) =>
              s.userId.equals(userId) & s.sosRoutineId.equals(sosRoutineId))
          ..orderBy([(s) => OrderingTerm.desc(s.completedAt)])
          ..limit(1))
        .getSingleOrNull();

    return result?.completedAt;
  }

  // ============================================================================
  // UTILITY - DELETE
  // ============================================================================

  /// Delete a SOS session record
  Future<int> deleteSosSessionRecord(int sosSessionId) async {
    return await (delete(sosSessionRecords)
          ..where((s) => s.sosSessionId.equals(sosSessionId)))
        .go();
  }

  /// Delete all SOS sessions for a user
  Future<int> deleteSosSessionsByUserId(int userId) async {
    return await (delete(sosSessionRecords)
          ..where((s) => s.userId.equals(userId)))
        .go();
  }

  /// Delete a SOS routine (will cascade delete exercises and sessions)
  Future<int> deleteSosRoutine(int sosRoutineId) async {
    return await (delete(sosRoutines)
          ..where((r) => r.sosRoutineId.equals(sosRoutineId)))
        .go();
  }
}
