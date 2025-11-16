import 'package:drift/drift.dart';
import '../app_database.dart';

part 'workout_dao.g.dart';

@DriftAccessor(tables: [Workouts])
class WorkoutDao extends DatabaseAccessor<AppDatabase> with _$WorkoutDaoMixin {
  WorkoutDao(AppDatabase db) : super(db);

  // ============================================================================
  // CREATE
  // ============================================================================

  /// Insert a new workout
  Future<int> insertWorkout(WorkoutsCompanion workout) async {
    return await into(workouts).insert(workout);
  }

  /// Batch insert multiple workouts
  Future<void> insertMultipleWorkouts(
    List<WorkoutsCompanion> workoutList,
  ) async {
    await batch((batch) {
      batch.insertAll(workouts, workoutList);
    });
  }

  // ============================================================================
  // READ
  // ============================================================================

  /// Get workout by ID
  Future<Workout?> getWorkoutById(int workoutId) async {
    return await (select(workouts)
          ..where((w) => w.workoutId.equals(workoutId)))
        .getSingleOrNull();
  }

  /// Get all workouts for a user
  Future<List<Workout>> getWorkoutsByUserId(int userId) async {
    return await (select(workouts)
          ..where((w) => w.userId.equals(userId))
          ..orderBy([(w) => OrderingTerm.desc(w.workoutId)]))
        .get();
  }

  /// Get workouts by level for a user
  Future<List<Workout>> getWorkoutsByLevel(int userId, int level) async {
    return await (select(workouts)
          ..where((w) => w.userId.equals(userId) & w.level.equals(level))
          ..orderBy([(w) => OrderingTerm.asc(w.workoutId)]))
        .get();
  }

  /// Get completed workouts for a user
  Future<List<Workout>> getCompletedWorkouts(int userId) async {
    return await (select(workouts)
          ..where((w) => w.userId.equals(userId) & w.isCompleted.equals(true))
          ..orderBy([(w) => OrderingTerm.desc(w.completedAt)]))
        .get();
  }

  /// Get incomplete workouts for a user
  Future<List<Workout>> getIncompleteWorkouts(int userId) async {
    return await (select(workouts)
          ..where((w) => w.userId.equals(userId) & w.isCompleted.equals(false))
          ..orderBy([(w) => OrderingTerm.asc(w.workoutId)]))
        .get();
  }

  /// Get workouts completed within date range
  Future<List<Workout>> getWorkoutsCompletedBetween(
    int userId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    return await (select(workouts)
          ..where((w) =>
              w.userId.equals(userId) &
              w.isCompleted.equals(true) &
              w.completedAt.isBiggerOrEqualValue(startDate) &
              w.completedAt.isSmallerOrEqualValue(endDate))
          ..orderBy([(w) => OrderingTerm.desc(w.completedAt)]))
        .get();
  }

  /// Get next workout for user (next incomplete workout)
  Future<Workout?> getNextWorkout(int userId, int currentLevel) async {
    return await (select(workouts)
          ..where((w) =>
              w.userId.equals(userId) &
              w.level.equals(currentLevel) &
              w.isCompleted.equals(false))
          ..orderBy([(w) => OrderingTerm.asc(w.workoutId)])
          ..limit(1))
        .getSingleOrNull();
  }

  /// Watch workouts for a user (reactive stream)
  Stream<List<Workout>> watchWorkoutsByUserId(int userId) {
    return (select(workouts)
          ..where((w) => w.userId.equals(userId))
          ..orderBy([(w) => OrderingTerm.desc(w.workoutId)]))
        .watch();
  }

  /// Watch workouts by level (reactive stream)
  Stream<List<Workout>> watchWorkoutsByLevel(int userId, int level) {
    return (select(workouts)
          ..where((w) => w.userId.equals(userId) & w.level.equals(level))
          ..orderBy([(w) => OrderingTerm.asc(w.workoutId)]))
        .watch();
  }

  /// Watch completed workouts (reactive stream)
  Stream<List<Workout>> watchCompletedWorkouts(int userId) {
    return (select(workouts)
          ..where((w) => w.userId.equals(userId) & w.isCompleted.equals(true))
          ..orderBy([(w) => OrderingTerm.desc(w.completedAt)]))
        .watch();
  }

  /// Watch single workout by ID
  Stream<Workout?> watchWorkoutById(int workoutId) {
    return (select(workouts)..where((w) => w.workoutId.equals(workoutId)))
        .watchSingleOrNull();
  }

  // ============================================================================
  // UPDATE
  // ============================================================================

  /// Update a workout
  Future<bool> updateWorkout(Workout workout) async {
    return await update(workouts).replace(workout);
  }

  /// Mark workout as completed
  Future<int> markWorkoutAsCompleted(int workoutId) async {
    return await (update(workouts)..where((w) => w.workoutId.equals(workoutId)))
        .write(
      WorkoutsCompanion(
        isCompleted: const Value(true),
        completedAt: Value(DateTime.now()),
      ),
    );
  }

  /// Mark workout as incomplete
  Future<int> markWorkoutAsIncomplete(int workoutId) async {
    return await (update(workouts)..where((w) => w.workoutId.equals(workoutId)))
        .write(
      const WorkoutsCompanion(
        isCompleted: Value(false),
        completedAt: Value(null),
      ),
    );
  }

  /// Update workout name
  Future<int> updateWorkoutName(int workoutId, String name) async {
    return await (update(workouts)..where((w) => w.workoutId.equals(workoutId)))
        .write(
      WorkoutsCompanion(
        name: Value(name),
      ),
    );
  }

  /// Update workout description
  Future<int> updateWorkoutDescription(
    int workoutId,
    String description,
  ) async {
    return await (update(workouts)..where((w) => w.workoutId.equals(workoutId)))
        .write(
      WorkoutsCompanion(
        description: Value(description),
      ),
    );
  }

  /// Update workout duration
  Future<int> updateWorkoutDuration(int workoutId, int durationMinutes) async {
    return await (update(workouts)..where((w) => w.workoutId.equals(workoutId)))
        .write(
      WorkoutsCompanion(
        durationMinutes: Value(durationMinutes),
      ),
    );
  }

  // ============================================================================
  // DELETE
  // ============================================================================

  /// Delete a workout
  Future<int> deleteWorkout(int workoutId) async {
    return await (delete(workouts)..where((w) => w.workoutId.equals(workoutId)))
        .go();
  }

  /// Delete all workouts for a user
  Future<int> deleteWorkoutsByUserId(int userId) async {
    return await (delete(workouts)..where((w) => w.userId.equals(userId))).go();
  }

  /// Delete workouts by level for a user
  Future<int> deleteWorkoutsByLevel(int userId, int level) async {
    return await (delete(workouts)
          ..where((w) => w.userId.equals(userId) & w.level.equals(level)))
        .go();
  }

  /// Delete completed workouts
  Future<int> deleteCompletedWorkouts(int userId) async {
    return await (delete(workouts)
          ..where((w) => w.userId.equals(userId) & w.isCompleted.equals(true)))
        .go();
  }

  // ============================================================================
  // UTILITY
  // ============================================================================

  /// Get workout count for a user
  Future<int> getWorkoutCount(int userId, {int? level, bool? completed}) async {
    final countExp = workouts.workoutId.count();
    final query = selectOnly(workouts)..addColumns([countExp]);

    query.where(workouts.userId.equals(userId));

    if (level != null) {
      query.where(workouts.level.equals(level));
    }

    if (completed != null) {
      query.where(workouts.isCompleted.equals(completed));
    }

    final result = await query.getSingle();
    return result.read(countExp) ?? 0;
  }

  /// Get completion percentage for a level
  Future<double> getLevelCompletionPercentage(int userId, int level) async {
    final totalCount = await getWorkoutCount(userId, level: level);
    if (totalCount == 0) return 0.0;

    final completedCount =
        await getWorkoutCount(userId, level: level, completed: true);

    return (completedCount / totalCount) * 100;
  }

  /// Get total workout time (completed workouts)
  Future<int> getTotalWorkoutTime(int userId) async {
    final sumExp = workouts.durationMinutes.sum();
    final query = selectOnly(workouts)
      ..addColumns([sumExp])
      ..where(workouts.userId.equals(userId) & workouts.isCompleted.equals(true));

    final result = await query.getSingle();
    return result.read(sumExp)?.toInt() ?? 0;
  }

  /// Get workouts with pagination
  Future<List<Workout>> getWorkoutsPaginated(
    int userId, {
    int page = 0,
    int pageSize = 10,
    int? level,
    bool? completed,
  }) async {
    final query = select(workouts)
      ..where((w) => w.userId.equals(userId))
      ..orderBy([(w) => OrderingTerm.desc(w.workoutId)])
      ..limit(pageSize, offset: page * pageSize);

    if (level != null) {
      query.where((w) => w.level.equals(level));
    }

    if (completed != null) {
      query.where((w) => w.isCompleted.equals(completed));
    }

    return await query.get();
  }

  /// Get workout statistics for a user
  Future<Map<String, dynamic>> getWorkoutStatistics(int userId) async {
    final totalWorkouts = await getWorkoutCount(userId);
    final completedWorkouts = await getWorkoutCount(userId, completed: true);
    final incompleteWorkouts = await getWorkoutCount(userId, completed: false);
    final totalTime = await getTotalWorkoutTime(userId);

    final level1Completion = await getLevelCompletionPercentage(userId, 1);
    final level2Completion = await getLevelCompletionPercentage(userId, 2);
    final level3Completion = await getLevelCompletionPercentage(userId, 3);

    return {
      'totalWorkouts': totalWorkouts,
      'completedWorkouts': completedWorkouts,
      'incompleteWorkouts': incompleteWorkouts,
      'totalWorkoutTime': totalTime,
      'completionPercentage':
          totalWorkouts > 0 ? (completedWorkouts / totalWorkouts) * 100 : 0,
      'level1Completion': level1Completion,
      'level2Completion': level2Completion,
      'level3Completion': level3Completion,
    };
  }

  /// Get recent workouts
  Future<List<Workout>> getRecentWorkouts(int userId, {int limit = 5}) async {
    return await (select(workouts)
          ..where((w) => w.userId.equals(userId) & w.isCompleted.equals(true))
          ..orderBy([(w) => OrderingTerm.desc(w.completedAt)])
          ..limit(limit))
        .get();
  }
}
