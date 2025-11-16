import 'package:drift/drift.dart';
import '../app_database.dart';

part 'workout_session_dao.g.dart';

@DriftAccessor(tables: [WorkoutSessions, Workouts])
class WorkoutSessionDao extends DatabaseAccessor<AppDatabase> with _$WorkoutSessionDaoMixin {
  WorkoutSessionDao(AppDatabase db) : super(db);

  // ============================================================================
  // CREATE
  // ============================================================================

  /// Insert a new workout session
  Future<int> insertWorkoutSession(WorkoutSessionsCompanion session) async {
    return await into(workoutSessions).insert(session);
  }

  /// Batch insert multiple workout sessions
  Future<void> insertMultipleWorkoutSessions(
    List<WorkoutSessionsCompanion> sessionList,
  ) async {
    await batch((batch) {
      batch.insertAll(workoutSessions, sessionList);
    });
  }

  // ============================================================================
  // READ
  // ============================================================================

  /// Get workout session by ID
  Future<WorkoutSession?> getWorkoutSessionById(int workoutSessionId) async {
    return await (select(workoutSessions)
          ..where((w) => w.workoutSessionId.equals(workoutSessionId)))
        .getSingleOrNull();
  }

  /// Get all workout sessions for a user
  Future<List<WorkoutSession>> getWorkoutSessionsByUserId(int userId) async {
    return await (select(workoutSessions)
          ..where((w) => w.userId.equals(userId))
          ..orderBy([(w) => OrderingTerm.desc(w.startedAt)]))
        .get();
  }

  /// Get workout sessions by workout ID
  Future<List<WorkoutSession>> getWorkoutSessionsByWorkoutId(int workoutId) async {
    return await (select(workoutSessions)
          ..where((w) => w.workoutId.equals(workoutId))
          ..orderBy([(w) => OrderingTerm.desc(w.startedAt)]))
        .get();
  }

  /// Get completed workout sessions for a user
  Future<List<WorkoutSession>> getCompletedWorkoutSessions(int userId) async {
    return await (select(workoutSessions)
          ..where((w) => w.userId.equals(userId) & w.isCompleted.equals(true))
          ..orderBy([(w) => OrderingTerm.desc(w.completedAt)]))
        .get();
  }

  /// Get incomplete workout sessions for a user
  Future<List<WorkoutSession>> getIncompleteWorkoutSessions(int userId) async {
    return await (select(workoutSessions)
          ..where((w) => w.userId.equals(userId) & w.isCompleted.equals(false))
          ..orderBy([(w) => OrderingTerm.desc(w.startedAt)]))
        .get();
  }

  /// Get workout sessions within date range
  Future<List<WorkoutSession>> getWorkoutSessionsByDateRange(
    int userId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    return await (select(workoutSessions)
          ..where((w) =>
              w.userId.equals(userId) &
              w.startedAt.isBiggerOrEqualValue(startDate) &
              w.startedAt.isSmallerOrEqualValue(endDate))
          ..orderBy([(w) => OrderingTerm.desc(w.startedAt)]))
        .get();
  }

  /// Get today's workout sessions
  Future<List<WorkoutSession>> getTodayWorkoutSessions(int userId) async {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final endOfDay = DateTime(now.year, now.month, now.day, 23, 59, 59);

    return await getWorkoutSessionsByDateRange(userId, startOfDay, endOfDay);
  }

  /// Get latest workout session
  Future<WorkoutSession?> getLatestWorkoutSession(int userId) async {
    return await (select(workoutSessions)
          ..where((w) => w.userId.equals(userId))
          ..orderBy([(w) => OrderingTerm.desc(w.startedAt)])
          ..limit(1))
        .getSingleOrNull();
  }

  /// Get recent workout sessions
  Future<List<WorkoutSession>> getRecentWorkoutSessions(
    int userId, {
    int limit = 10,
  }) async {
    return await (select(workoutSessions)
          ..where((w) => w.userId.equals(userId))
          ..orderBy([(w) => OrderingTerm.desc(w.startedAt)])
          ..limit(limit))
        .get();
  }

  /// Get workout sessions by level
  Future<List<WorkoutSession>> getWorkoutSessionsByLevel(
    int userId,
    int level,
  ) async {
    return await (select(workoutSessions)
          ..where((w) => w.userId.equals(userId) & w.level.equals(level))
          ..orderBy([(w) => OrderingTerm.desc(w.startedAt)]))
        .get();
  }

  /// Watch workout sessions for a user (reactive stream)
  Stream<List<WorkoutSession>> watchWorkoutSessionsByUserId(int userId) {
    return (select(workoutSessions)
          ..where((w) => w.userId.equals(userId))
          ..orderBy([(w) => OrderingTerm.desc(w.startedAt)]))
        .watch();
  }

  /// Watch completed workout sessions (reactive stream)
  Stream<List<WorkoutSession>> watchCompletedWorkoutSessions(int userId) {
    return (select(workoutSessions)
          ..where((w) => w.userId.equals(userId) & w.isCompleted.equals(true))
          ..orderBy([(w) => OrderingTerm.desc(w.completedAt)]))
        .watch();
  }

  /// Watch single workout session by ID
  Stream<WorkoutSession?> watchWorkoutSessionById(int workoutSessionId) {
    return (select(workoutSessions)
          ..where((w) => w.workoutSessionId.equals(workoutSessionId)))
        .watchSingleOrNull();
  }

  // ============================================================================
  // UPDATE
  // ============================================================================

  /// Update a workout session
  Future<bool> updateWorkoutSession(WorkoutSession session) async {
    return await update(workoutSessions).replace(session);
  }

  /// Mark workout session as completed
  Future<int> markWorkoutSessionAsCompleted(
    int workoutSessionId, {
    int? caloriesBurned,
  }) async {
    return await (update(workoutSessions)
          ..where((w) => w.workoutSessionId.equals(workoutSessionId)))
        .write(
      WorkoutSessionsCompanion(
        isCompleted: const Value(true),
        completedAt: Value(DateTime.now()),
        caloriesBurned: Value(caloriesBurned),
      ),
    );
  }

  /// Update exercises completed
  Future<int> updateExercisesCompleted(
    int workoutSessionId,
    int exercisesCompleted,
  ) async {
    return await (update(workoutSessions)
          ..where((w) => w.workoutSessionId.equals(workoutSessionId)))
        .write(
      WorkoutSessionsCompanion(
        exercisesCompleted: Value(exercisesCompleted),
      ),
    );
  }

  /// Update calories burned
  Future<int> updateCaloriesBurned(
    int workoutSessionId,
    int caloriesBurned,
  ) async {
    return await (update(workoutSessions)
          ..where((w) => w.workoutSessionId.equals(workoutSessionId)))
        .write(
      WorkoutSessionsCompanion(
        caloriesBurned: Value(caloriesBurned),
      ),
    );
  }

  // ============================================================================
  // DELETE
  // ============================================================================

  /// Delete a workout session
  Future<int> deleteWorkoutSession(int workoutSessionId) async {
    return await (delete(workoutSessions)
          ..where((w) => w.workoutSessionId.equals(workoutSessionId)))
        .go();
  }

  /// Delete all workout sessions for a user
  Future<int> deleteWorkoutSessionsByUserId(int userId) async {
    return await (delete(workoutSessions)
          ..where((w) => w.userId.equals(userId)))
        .go();
  }

  /// Delete workout sessions by workout ID
  Future<int> deleteWorkoutSessionsByWorkoutId(int workoutId) async {
    return await (delete(workoutSessions)
          ..where((w) => w.workoutId.equals(workoutId)))
        .go();
  }

  /// Delete incomplete workout sessions
  Future<int> deleteIncompleteWorkoutSessions(int userId) async {
    return await (delete(workoutSessions)
          ..where((w) => w.userId.equals(userId) & w.isCompleted.equals(false)))
        .go();
  }

  // ============================================================================
  // UTILITY & STATISTICS
  // ============================================================================

  /// Get workout session count for a user
  Future<int> getWorkoutSessionCount(
    int userId, {
    int? level,
    bool? completed,
  }) async {
    final countExp = workoutSessions.workoutSessionId.count();
    final query = selectOnly(workoutSessions)..addColumns([countExp]);

    query.where(workoutSessions.userId.equals(userId));

    if (level != null) {
      query.where(workoutSessions.level.equals(level));
    }

    if (completed != null) {
      query.where(workoutSessions.isCompleted.equals(completed));
    }

    final result = await query.getSingle();
    return result.read(countExp) ?? 0;
  }

  /// Get total calories burned
  Future<int> getTotalCaloriesBurned(int userId) async {
    final sumExp = workoutSessions.caloriesBurned.sum();
    final query = selectOnly(workoutSessions)
      ..addColumns([sumExp])
      ..where(
        workoutSessions.userId.equals(userId) &
            workoutSessions.isCompleted.equals(true) &
            workoutSessions.caloriesBurned.isNotNull(),
      );

    final result = await query.getSingle();
    return result.read(sumExp)?.toInt() ?? 0;
  }

  /// Get total workout time from sessions (completed sessions)
  Future<int> getTotalWorkoutTime(int userId) async {
    final sumExp = workoutSessions.durationMinutes.sum();
    final query = selectOnly(workoutSessions)
      ..addColumns([sumExp])
      ..where(
        workoutSessions.userId.equals(userId) &
            workoutSessions.isCompleted.equals(true),
      );

    final result = await query.getSingle();
    return result.read(sumExp)?.toInt() ?? 0;
  }

  /// Get average workout duration
  Future<double> getAverageWorkoutDuration(int userId) async {
    final avgExp = workoutSessions.durationMinutes.avg();
    final query = selectOnly(workoutSessions)
      ..addColumns([avgExp])
      ..where(
        workoutSessions.userId.equals(userId) &
            workoutSessions.isCompleted.equals(true),
      );

    final result = await query.getSingle();
    return result.read(avgExp) ?? 0.0;
  }

  /// Calculate workout streak (consecutive days with completed workouts)
  Future<int> calculateWorkoutStreak(int userId) async {
    final sessions = await getCompletedWorkoutSessions(userId);

    if (sessions.isEmpty) return 0;

    // Sort sessions by completion date (most recent first)
    sessions.sort((a, b) {
      final dateA = a.completedAt ?? a.startedAt;
      final dateB = b.completedAt ?? b.startedAt;
      return dateB.compareTo(dateA);
    });

    int streak = 0;
    DateTime? previousDate;
    final today = DateTime.now();
    final todayDate = DateTime(today.year, today.month, today.day);

    for (final session in sessions) {
      final sessionDate = session.completedAt ?? session.startedAt;
      final date = DateTime(sessionDate.year, sessionDate.month, sessionDate.day);

      if (previousDate == null) {
        // First session - check if it's today or yesterday
        final daysDiff = todayDate.difference(date).inDays;
        if (daysDiff <= 1) {
          streak = 1;
          previousDate = date;
        } else {
          // Streak is broken if first session is more than 1 day ago
          break;
        }
      } else {
        // Check if this session is consecutive with the previous one
        final daysDiff = previousDate.difference(date).inDays;
        if (daysDiff == 1) {
          streak++;
          previousDate = date;
        } else if (daysDiff == 0) {
          // Same day, don't increment streak but continue
          continue;
        } else {
          // Streak is broken
          break;
        }
      }
    }

    return streak;
  }

  /// Get workout session statistics for a user
  Future<Map<String, dynamic>> getWorkoutSessionStatistics(int userId) async {
    final totalSessions = await getWorkoutSessionCount(userId);
    final completedSessions = await getWorkoutSessionCount(userId, completed: true);
    final incompleteSessions = await getWorkoutSessionCount(userId, completed: false);
    final totalTime = await getTotalWorkoutTime(userId);
    final totalCalories = await getTotalCaloriesBurned(userId);
    final avgDuration = await getAverageWorkoutDuration(userId);
    final streak = await calculateWorkoutStreak(userId);

    final level1Sessions = await getWorkoutSessionCount(userId, level: 1, completed: true);
    final level2Sessions = await getWorkoutSessionCount(userId, level: 2, completed: true);
    final level3Sessions = await getWorkoutSessionCount(userId, level: 3, completed: true);

    return {
      'totalSessions': totalSessions,
      'completedSessions': completedSessions,
      'incompleteSessions': incompleteSessions,
      'totalWorkoutTime': totalTime,
      'totalCaloriesBurned': totalCalories,
      'averageWorkoutDuration': avgDuration,
      'currentStreak': streak,
      'level1Sessions': level1Sessions,
      'level2Sessions': level2Sessions,
      'level3Sessions': level3Sessions,
      'completionRate': totalSessions > 0 ? (completedSessions / totalSessions) * 100 : 0,
    };
  }

  /// Get workout sessions with pagination
  Future<List<WorkoutSession>> getWorkoutSessionsPaginated(
    int userId, {
    int page = 0,
    int pageSize = 10,
    int? level,
    bool? completed,
  }) async {
    final query = select(workoutSessions)
      ..where((w) => w.userId.equals(userId))
      ..orderBy([(w) => OrderingTerm.desc(w.startedAt)])
      ..limit(pageSize, offset: page * pageSize);

    if (level != null) {
      query.where((w) => w.level.equals(level));
    }

    if (completed != null) {
      query.where((w) => w.isCompleted.equals(completed));
    }

    return await query.get();
  }

  /// Check if user worked out today
  Future<bool> hasWorkedOutToday(int userId) async {
    final todaySessions = await getTodayWorkoutSessions(userId);
    return todaySessions.any((session) => session.isCompleted);
  }

  /// Get longest workout streak ever
  Future<int> getLongestStreak(int userId) async {
    final sessions = await getCompletedWorkoutSessions(userId);

    if (sessions.isEmpty) return 0;

    // Sort sessions by completion date (oldest first)
    sessions.sort((a, b) {
      final dateA = a.completedAt ?? a.startedAt;
      final dateB = b.completedAt ?? b.startedAt;
      return dateA.compareTo(dateB);
    });

    int currentStreak = 1;
    int longestStreak = 1;
    DateTime? previousDate;

    for (final session in sessions) {
      final sessionDate = session.completedAt ?? session.startedAt;
      final date = DateTime(sessionDate.year, sessionDate.month, sessionDate.day);

      if (previousDate == null) {
        previousDate = date;
      } else {
        final daysDiff = date.difference(previousDate).inDays;
        if (daysDiff == 1) {
          currentStreak++;
          if (currentStreak > longestStreak) {
            longestStreak = currentStreak;
          }
        } else if (daysDiff > 1) {
          currentStreak = 1;
        }
        previousDate = date;
      }
    }

    return longestStreak;
  }
}
