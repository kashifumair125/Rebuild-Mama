import 'package:drift/drift.dart';
import '../app_database.dart';

part 'exercise_dao.g.dart';

@DriftAccessor(tables: [Exercises, Workouts])
class ExerciseDao extends DatabaseAccessor<AppDatabase> with _$ExerciseDaoMixin {
  ExerciseDao(AppDatabase db) : super(db);

  // ============================================================================
  // CREATE
  // ============================================================================

  /// Insert a new exercise
  Future<int> insertExercise(ExercisesCompanion exercise) async {
    return await into(exercises).insert(exercise);
  }

  /// Batch insert multiple exercises
  Future<void> insertMultipleExercises(
    List<ExercisesCompanion> exerciseList,
  ) async {
    await batch((batch) {
      batch.insertAll(exercises, exerciseList);
    });
  }

  // ============================================================================
  // READ
  // ============================================================================

  /// Get exercise by ID
  Future<Exercise?> getExerciseById(int exerciseId) async {
    return await (select(exercises)
          ..where((e) => e.exerciseId.equals(exerciseId)))
        .getSingleOrNull();
  }

  /// Get all exercises for a workout
  Future<List<Exercise>> getExercisesByWorkoutId(int workoutId) async {
    return await (select(exercises)
          ..where((e) => e.workoutId.equals(workoutId))
          ..orderBy([(e) => OrderingTerm.asc(e.orderIndex)]))
        .get();
  }

  /// Get exercises for a workout by name pattern
  Future<List<Exercise>> searchExercisesByName(
    int workoutId,
    String namePattern,
  ) async {
    return await (select(exercises)
          ..where((e) =>
              e.workoutId.equals(workoutId) & e.exerciseName.like('%$namePattern%'))
          ..orderBy([(e) => OrderingTerm.asc(e.orderIndex)]))
        .get();
  }

  /// Get next exercise in workout (by order)
  Future<Exercise?> getNextExercise(int workoutId, int currentOrderIndex) async {
    return await (select(exercises)
          ..where((e) =>
              e.workoutId.equals(workoutId) &
              e.orderIndex.isBiggerThanValue(currentOrderIndex))
          ..orderBy([(e) => OrderingTerm.asc(e.orderIndex)])
          ..limit(1))
        .getSingleOrNull();
  }

  /// Get previous exercise in workout (by order)
  Future<Exercise?> getPreviousExercise(
    int workoutId,
    int currentOrderIndex,
  ) async {
    return await (select(exercises)
          ..where((e) =>
              e.workoutId.equals(workoutId) &
              e.orderIndex.isSmallerThanValue(currentOrderIndex))
          ..orderBy([(e) => OrderingTerm.desc(e.orderIndex)])
          ..limit(1))
        .getSingleOrNull();
  }

  /// Get first exercise in workout
  Future<Exercise?> getFirstExercise(int workoutId) async {
    return await (select(exercises)
          ..where((e) => e.workoutId.equals(workoutId))
          ..orderBy([(e) => OrderingTerm.asc(e.orderIndex)])
          ..limit(1))
        .getSingleOrNull();
  }

  /// Get last exercise in workout
  Future<Exercise?> getLastExercise(int workoutId) async {
    return await (select(exercises)
          ..where((e) => e.workoutId.equals(workoutId))
          ..orderBy([(e) => OrderingTerm.desc(e.orderIndex)])
          ..limit(1))
        .getSingleOrNull();
  }

  /// Get timed exercises (exercises with duration)
  Future<List<Exercise>> getTimedExercises(int workoutId) async {
    return await (select(exercises)
          ..where((e) =>
              e.workoutId.equals(workoutId) & e.durationSeconds.isNotNull())
          ..orderBy([(e) => OrderingTerm.asc(e.orderIndex)]))
        .get();
  }

  /// Get rep-based exercises (exercises without duration)
  Future<List<Exercise>> getRepBasedExercises(int workoutId) async {
    return await (select(exercises)
          ..where((e) => e.workoutId.equals(workoutId) & e.durationSeconds.isNull())
          ..orderBy([(e) => OrderingTerm.asc(e.orderIndex)]))
        .get();
  }

  /// Watch exercises for a workout (reactive stream)
  Stream<List<Exercise>> watchExercisesByWorkoutId(int workoutId) {
    return (select(exercises)
          ..where((e) => e.workoutId.equals(workoutId))
          ..orderBy([(e) => OrderingTerm.asc(e.orderIndex)]))
        .watch();
  }

  /// Watch single exercise by ID
  Stream<Exercise?> watchExerciseById(int exerciseId) {
    return (select(exercises)..where((e) => e.exerciseId.equals(exerciseId)))
        .watchSingleOrNull();
  }

  // ============================================================================
  // JOIN QUERIES
  // ============================================================================

  /// Get exercises for a user's workouts of a specific level
  Future<List<Exercise>> getExercisesForUserLevel(int userId, int level) async {
    final query = select(exercises).join([
      innerJoin(
        workouts,
        workouts.workoutId.equalsExp(exercises.workoutId),
      ),
    ])
      ..where(workouts.userId.equals(userId) & workouts.level.equals(level))
      ..orderBy([
        OrderingTerm.asc(workouts.workoutId),
        OrderingTerm.asc(exercises.orderIndex),
      ]);

    final results = await query.get();
    return results.map((row) => row.readTable(exercises)).toList();
  }

  /// Get all exercises for a user across all workouts
  Future<List<Exercise>> getAllExercisesForUser(int userId) async {
    final query = select(exercises).join([
      innerJoin(
        workouts,
        workouts.workoutId.equalsExp(exercises.workoutId),
      ),
    ])
      ..where(workouts.userId.equals(userId))
      ..orderBy([
        OrderingTerm.asc(workouts.level),
        OrderingTerm.asc(workouts.workoutId),
        OrderingTerm.asc(exercises.orderIndex),
      ]);

    final results = await query.get();
    return results.map((row) => row.readTable(exercises)).toList();
  }

  // ============================================================================
  // UPDATE
  // ============================================================================

  /// Update an exercise
  Future<bool> updateExercise(Exercise exercise) async {
    return await update(exercises).replace(exercise);
  }

  /// Update exercise order
  Future<int> updateExerciseOrder(int exerciseId, int newOrderIndex) async {
    return await (update(exercises)
          ..where((e) => e.exerciseId.equals(exerciseId)))
        .write(
      ExercisesCompanion(
        orderIndex: Value(newOrderIndex),
      ),
    );
  }

  /// Update exercise name
  Future<int> updateExerciseName(int exerciseId, String name) async {
    return await (update(exercises)
          ..where((e) => e.exerciseId.equals(exerciseId)))
        .write(
      ExercisesCompanion(
        exerciseName: Value(name),
      ),
    );
  }

  /// Update exercise description
  Future<int> updateExerciseDescription(
    int exerciseId,
    String description,
  ) async {
    return await (update(exercises)
          ..where((e) => e.exerciseId.equals(exerciseId)))
        .write(
      ExercisesCompanion(
        description: Value(description),
      ),
    );
  }

  /// Update exercise duration
  Future<int> updateExerciseDuration(int exerciseId, int? durationSeconds) async {
    return await (update(exercises)
          ..where((e) => e.exerciseId.equals(exerciseId)))
        .write(
      ExercisesCompanion(
        durationSeconds: Value(durationSeconds),
      ),
    );
  }

  /// Update exercise sets and reps
  Future<int> updateSetsReps(int exerciseId, String setsReps) async {
    return await (update(exercises)
          ..where((e) => e.exerciseId.equals(exerciseId)))
        .write(
      ExercisesCompanion(
        setsReps: Value(setsReps),
      ),
    );
  }

  /// Update animation path
  Future<int> updateAnimationPath(int exerciseId, String animationPath) async {
    return await (update(exercises)
          ..where((e) => e.exerciseId.equals(exerciseId)))
        .write(
      ExercisesCompanion(
        animationPath: Value(animationPath),
      ),
    );
  }

  /// Reorder exercises in a workout
  Future<void> reorderExercises(
    List<int> exerciseIds,
    List<int> newOrderIndices,
  ) async {
    if (exerciseIds.length != newOrderIndices.length) {
      throw ArgumentError('exerciseIds and newOrderIndices must have the same length');
    }

    await batch((batch) {
      for (var i = 0; i < exerciseIds.length; i++) {
        batch.update(
          exercises,
          ExercisesCompanion(
            orderIndex: Value(newOrderIndices[i]),
          ),
          where: (e) => e.exerciseId.equals(exerciseIds[i]),
        );
      }
    });
  }

  // ============================================================================
  // DELETE
  // ============================================================================

  /// Delete an exercise
  Future<int> deleteExercise(int exerciseId) async {
    return await (delete(exercises)
          ..where((e) => e.exerciseId.equals(exerciseId)))
        .go();
  }

  /// Delete all exercises for a workout
  Future<int> deleteExercisesByWorkoutId(int workoutId) async {
    return await (delete(exercises)..where((e) => e.workoutId.equals(workoutId)))
        .go();
  }

  /// Delete exercises by IDs
  Future<int> deleteExercisesByIds(List<int> exerciseIds) async {
    return await (delete(exercises)
          ..where((e) => e.exerciseId.isIn(exerciseIds)))
        .go();
  }

  // ============================================================================
  // UTILITY
  // ============================================================================

  /// Get exercise count for a workout
  Future<int> getExerciseCount(int workoutId) async {
    final countExp = exercises.exerciseId.count();
    final query = selectOnly(exercises)
      ..addColumns([countExp])
      ..where(exercises.workoutId.equals(workoutId));

    final result = await query.getSingle();
    return result.read(countExp) ?? 0;
  }

  /// Get total duration for all timed exercises in a workout
  Future<int> getTotalWorkoutDuration(int workoutId) async {
    final sumExp = exercises.durationSeconds.sum();
    final query = selectOnly(exercises)
      ..addColumns([sumExp])
      ..where(
        exercises.workoutId.equals(workoutId) & exercises.durationSeconds.isNotNull(),
      );

    final result = await query.getSingle();
    return result.read(sumExp)?.toInt() ?? 0;
  }

  /// Check if exercise exists
  Future<bool> exerciseExists(int exerciseId) async {
    final exercise = await getExerciseById(exerciseId);
    return exercise != null;
  }

  /// Get exercises with pagination
  Future<List<Exercise>> getExercisesPaginated(
    int workoutId, {
    int page = 0,
    int pageSize = 10,
  }) async {
    return await (select(exercises)
          ..where((e) => e.workoutId.equals(workoutId))
          ..orderBy([(e) => OrderingTerm.asc(e.orderIndex)])
          ..limit(pageSize, offset: page * pageSize))
        .get();
  }

  /// Get exercise by order index
  Future<Exercise?> getExerciseByOrderIndex(
    int workoutId,
    int orderIndex,
  ) async {
    return await (select(exercises)
          ..where(
            (e) => e.workoutId.equals(workoutId) & e.orderIndex.equals(orderIndex),
          ))
        .getSingleOrNull();
  }

  /// Swap exercise order
  Future<void> swapExerciseOrder(int exerciseId1, int exerciseId2) async {
    final exercise1 = await getExerciseById(exerciseId1);
    final exercise2 = await getExerciseById(exerciseId2);

    if (exercise1 == null || exercise2 == null) {
      throw ArgumentError('One or both exercises not found');
    }

    await transaction(() async {
      await updateExerciseOrder(exerciseId1, exercise2.orderIndex);
      await updateExerciseOrder(exerciseId2, exercise1.orderIndex);
    });
  }
}
