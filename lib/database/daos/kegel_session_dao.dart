import 'package:drift/drift.dart';
import '../app_database.dart';

part 'kegel_session_dao.g.dart';

@DriftAccessor(tables: [KegelSessions])
class KegelSessionDao extends DatabaseAccessor<AppDatabase> with _$KegelSessionDaoMixin {
  KegelSessionDao(AppDatabase db) : super(db);

  // ============================================================================
  // CREATE
  // ============================================================================

  /// Insert a new kegel session
  Future<int> insertKegelSession(KegelSessionsCompanion session) async {
    return await into(kegelSessions).insert(session);
  }

  /// Batch insert multiple kegel sessions
  Future<void> insertMultipleKegelSessions(
    List<KegelSessionsCompanion> sessionList,
  ) async {
    await batch((batch) {
      batch.insertAll(kegelSessions, sessionList);
    });
  }

  // ============================================================================
  // READ
  // ============================================================================

  /// Get kegel session by ID
  Future<KegelSession?> getKegelSessionById(int sessionId) async {
    return await (select(kegelSessions)
          ..where((k) => k.sessionId.equals(sessionId)))
        .getSingleOrNull();
  }

  /// Get all kegel sessions for a user
  Future<List<KegelSession>> getKegelSessionsByUserId(int userId) async {
    return await (select(kegelSessions)
          ..where((k) => k.userId.equals(userId))
          ..orderBy([(k) => OrderingTerm.desc(k.startedAt)]))
        .get();
  }

  /// Get kegel sessions within date range
  Future<List<KegelSession>> getKegelSessionsByDateRange(
    int userId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    return await (select(kegelSessions)
          ..where((k) =>
              k.userId.equals(userId) &
              k.startedAt.isBiggerOrEqualValue(startDate) &
              k.startedAt.isSmallerOrEqualValue(endDate))
          ..orderBy([(k) => OrderingTerm.desc(k.startedAt)]))
        .get();
  }

  /// Get today's kegel sessions
  Future<List<KegelSession>> getTodayKegelSessions(int userId) async {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final endOfDay = DateTime(now.year, now.month, now.day, 23, 59, 59);

    return await getKegelSessionsByDateRange(userId, startOfDay, endOfDay);
  }

  /// Get latest kegel session
  Future<KegelSession?> getLatestKegelSession(int userId) async {
    return await (select(kegelSessions)
          ..where((k) => k.userId.equals(userId))
          ..orderBy([(k) => OrderingTerm.desc(k.startedAt)])
          ..limit(1))
        .getSingleOrNull();
  }

  /// Get recent kegel sessions
  Future<List<KegelSession>> getRecentKegelSessions(
    int userId, {
    int limit = 10,
  }) async {
    return await (select(kegelSessions)
          ..where((k) => k.userId.equals(userId))
          ..orderBy([(k) => OrderingTerm.desc(k.startedAt)])
          ..limit(limit))
        .get();
  }

  /// Watch kegel sessions for a user (reactive stream)
  Stream<List<KegelSession>> watchKegelSessionsByUserId(int userId) {
    return (select(kegelSessions)
          ..where((k) => k.userId.equals(userId))
          ..orderBy([(k) => OrderingTerm.desc(k.startedAt)]))
        .watch();
  }

  /// Watch single kegel session by ID
  Stream<KegelSession?> watchKegelSessionById(int sessionId) {
    return (select(kegelSessions)..where((k) => k.sessionId.equals(sessionId)))
        .watchSingleOrNull();
  }

  /// Watch today's kegel sessions
  Stream<List<KegelSession>> watchTodayKegelSessions(int userId) {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final endOfDay = DateTime(now.year, now.month, now.day, 23, 59, 59);

    return (select(kegelSessions)
          ..where((k) =>
              k.userId.equals(userId) &
              k.startedAt.isBiggerOrEqualValue(startOfDay) &
              k.startedAt.isSmallerOrEqualValue(endOfDay))
          ..orderBy([(k) => OrderingTerm.desc(k.startedAt)]))
        .watch();
  }

  // ============================================================================
  // UPDATE
  // ============================================================================

  /// Update a kegel session
  Future<bool> updateKegelSession(KegelSession session) async {
    return await update(kegelSessions).replace(session);
  }

  /// Update session duration
  Future<int> updateSessionDuration(int sessionId, int durationMinutes) async {
    return await (update(kegelSessions)
          ..where((k) => k.sessionId.equals(sessionId)))
        .write(
      KegelSessionsCompanion(
        durationMinutes: Value(durationMinutes),
      ),
    );
  }

  /// Update reps completed
  Future<int> updateRepsCompleted(int sessionId, int repsCompleted) async {
    return await (update(kegelSessions)
          ..where((k) => k.sessionId.equals(sessionId)))
        .write(
      KegelSessionsCompanion(
        repsCompleted: Value(repsCompleted),
      ),
    );
  }

  /// Update session end time
  Future<int> updateEndTime(int sessionId, DateTime endedAt) async {
    return await (update(kegelSessions)
          ..where((k) => k.sessionId.equals(sessionId)))
        .write(
      KegelSessionsCompanion(
        endedAt: Value(endedAt),
      ),
    );
  }

  // ============================================================================
  // DELETE
  // ============================================================================

  /// Delete a kegel session
  Future<int> deleteKegelSession(int sessionId) async {
    return await (delete(kegelSessions)
          ..where((k) => k.sessionId.equals(sessionId)))
        .go();
  }

  /// Delete all kegel sessions for a user
  Future<int> deleteKegelSessionsByUserId(int userId) async {
    return await (delete(kegelSessions)
          ..where((k) => k.userId.equals(userId)))
        .go();
  }

  /// Delete kegel sessions within date range
  Future<int> deleteKegelSessionsByDateRange(
    int userId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    return await (delete(kegelSessions)
          ..where((k) =>
              k.userId.equals(userId) &
              k.startedAt.isBiggerOrEqualValue(startDate) &
              k.startedAt.isSmallerOrEqualValue(endDate)))
        .go();
  }

  // ============================================================================
  // UTILITY
  // ============================================================================

  /// Get kegel session count for a user
  Future<int> getKegelSessionCount(int userId) async {
    final countExp = kegelSessions.sessionId.count();
    final query = selectOnly(kegelSessions)
      ..addColumns([countExp])
      ..where(kegelSessions.userId.equals(userId));

    final result = await query.getSingle();
    return result.read(countExp) ?? 0;
  }

  /// Get total kegel time (in minutes)
  Future<int> getTotalKegelTime(int userId) async {
    final sumExp = kegelSessions.durationMinutes.sum();
    final query = selectOnly(kegelSessions)
      ..addColumns([sumExp])
      ..where(kegelSessions.userId.equals(userId));

    final result = await query.getSingle();
    return result.read(sumExp)?.toInt() ?? 0;
  }

  /// Get total reps completed
  Future<int> getTotalRepsCompleted(int userId) async {
    final sumExp = kegelSessions.repsCompleted.sum();
    final query = selectOnly(kegelSessions)
      ..addColumns([sumExp])
      ..where(kegelSessions.userId.equals(userId));

    final result = await query.getSingle();
    return result.read(sumExp)?.toInt() ?? 0;
  }

  /// Get average session duration
  Future<double> getAverageSessionDuration(int userId) async {
    final avgExp = kegelSessions.durationMinutes.avg();
    final query = selectOnly(kegelSessions)
      ..addColumns([avgExp])
      ..where(kegelSessions.userId.equals(userId));

    final result = await query.getSingle();
    return result.read(avgExp) ?? 0.0;
  }

  /// Get average reps per session
  Future<double> getAverageRepsPerSession(int userId) async {
    final avgExp = kegelSessions.repsCompleted.avg();
    final query = selectOnly(kegelSessions)
      ..addColumns([avgExp])
      ..where(kegelSessions.userId.equals(userId));

    final result = await query.getSingle();
    return result.read(avgExp) ?? 0.0;
  }

  /// Get kegel sessions with pagination
  Future<List<KegelSession>> getKegelSessionsPaginated(
    int userId, {
    int page = 0,
    int pageSize = 10,
  }) async {
    return await (select(kegelSessions)
          ..where((k) => k.userId.equals(userId))
          ..orderBy([(k) => OrderingTerm.desc(k.startedAt)])
          ..limit(pageSize, offset: page * pageSize))
        .get();
  }

  /// Get kegel statistics for a user
  Future<Map<String, dynamic>> getKegelStatistics(int userId) async {
    final totalSessions = await getKegelSessionCount(userId);
    final totalTime = await getTotalKegelTime(userId);
    final totalReps = await getTotalRepsCompleted(userId);
    final avgDuration = await getAverageSessionDuration(userId);
    final avgReps = await getAverageRepsPerSession(userId);

    return {
      'totalSessions': totalSessions,
      'totalTimeMinutes': totalTime,
      'totalReps': totalReps,
      'averageDurationMinutes': avgDuration,
      'averageRepsPerSession': avgReps,
    };
  }

  /// Get sessions count for today
  Future<int> getTodaySessionCount(int userId) async {
    final todaySessions = await getTodayKegelSessions(userId);
    return todaySessions.length;
  }

  /// Get sessions count for a specific date range
  Future<int> getSessionCountByDateRange(
    int userId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    final sessions = await getKegelSessionsByDateRange(
      userId,
      startDate,
      endDate,
    );
    return sessions.length;
  }

  /// Get weekly kegel statistics
  Future<Map<String, dynamic>> getWeeklyKegelStatistics(int userId) async {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final startOfWeekDay = DateTime(
      startOfWeek.year,
      startOfWeek.month,
      startOfWeek.day,
    );
    final endOfWeek = startOfWeekDay.add(const Duration(days: 7));

    final sessions = await getKegelSessionsByDateRange(
      userId,
      startOfWeekDay,
      endOfWeek,
    );

    final totalDuration = sessions.fold<int>(
      0,
      (sum, session) => sum + session.durationMinutes,
    );

    final totalReps = sessions.fold<int>(
      0,
      (sum, session) => sum + session.repsCompleted,
    );

    return {
      'weekStartDate': startOfWeekDay,
      'weekEndDate': endOfWeek,
      'sessionsThisWeek': sessions.length,
      'totalDurationMinutes': totalDuration,
      'totalReps': totalReps,
      'averageDurationMinutes':
          sessions.isNotEmpty ? totalDuration / sessions.length : 0,
      'averageRepsPerSession':
          sessions.isNotEmpty ? totalReps / sessions.length : 0,
    };
  }

  /// Get monthly kegel statistics
  Future<Map<String, dynamic>> getMonthlyKegelStatistics(int userId) async {
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    final endOfMonth = DateTime(now.year, now.month + 1, 0, 23, 59, 59);

    final sessions = await getKegelSessionsByDateRange(
      userId,
      startOfMonth,
      endOfMonth,
    );

    final totalDuration = sessions.fold<int>(
      0,
      (sum, session) => sum + session.durationMinutes,
    );

    final totalReps = sessions.fold<int>(
      0,
      (sum, session) => sum + session.repsCompleted,
    );

    return {
      'monthStartDate': startOfMonth,
      'monthEndDate': endOfMonth,
      'sessionsThisMonth': sessions.length,
      'totalDurationMinutes': totalDuration,
      'totalReps': totalReps,
      'averageDurationMinutes':
          sessions.isNotEmpty ? totalDuration / sessions.length : 0,
      'averageRepsPerSession':
          sessions.isNotEmpty ? totalReps / sessions.length : 0,
    };
  }

  /// Get kegel streak (consecutive days with sessions)
  Future<int> getKegelStreak(int userId) async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    int streak = 0;
    DateTime checkDate = today;

    while (true) {
      final startOfDay = checkDate;
      final endOfDay = DateTime(
        checkDate.year,
        checkDate.month,
        checkDate.day,
        23,
        59,
        59,
      );

      final sessionsForDay = await getKegelSessionsByDateRange(
        userId,
        startOfDay,
        endOfDay,
      );

      if (sessionsForDay.isEmpty) {
        break;
      }

      streak++;
      checkDate = checkDate.subtract(const Duration(days: 1));

      // Limit streak calculation to 365 days to avoid infinite loops
      if (streak >= 365) break;
    }

    return streak;
  }
}
