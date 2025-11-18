import 'package:drift/drift.dart' as drift;
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../database/app_database.dart';
import 'database_provider.dart';
import 'progress_provider.dart';

part 'workout_provider.g.dart';

/// Model for the current workout session state
class WorkoutSessionState {
  final int workoutId;
  final int workoutSessionId;
  final int level;
  final List<Exercise> exercises;
  final int currentExerciseIndex;
  final DateTime startedAt;

  const WorkoutSessionState({
    required this.workoutId,
    required this.workoutSessionId,
    required this.level,
    required this.exercises,
    this.currentExerciseIndex = 0,
    required this.startedAt,
  });

  Exercise get currentExercise => exercises[currentExerciseIndex];

  bool get isLastExercise => currentExerciseIndex == exercises.length - 1;

  bool get isFirstExercise => currentExerciseIndex == 0;

  int get totalExercises => exercises.length;

  int get exercisesCompleted => currentExerciseIndex + 1;

  WorkoutSessionState copyWith({
    int? workoutId,
    int? workoutSessionId,
    int? level,
    List<Exercise>? exercises,
    int? currentExerciseIndex,
    DateTime? startedAt,
  }) {
    return WorkoutSessionState(
      workoutId: workoutId ?? this.workoutId,
      workoutSessionId: workoutSessionId ?? this.workoutSessionId,
      level: level ?? this.level,
      exercises: exercises ?? this.exercises,
      currentExerciseIndex: currentExerciseIndex ?? this.currentExerciseIndex,
      startedAt: startedAt ?? this.startedAt,
    );
  }
}

/// State notifier for managing the current workout session
@riverpod
class CurrentWorkoutSession extends _$CurrentWorkoutSession {
  @override
  WorkoutSessionState? build() {
    return null;
  }

  /// Start a new workout session
  Future<void> startWorkout({
    required int userId,
    required int workoutId,
    required int level,
  }) async {
    final db = ref.read(appDatabaseProvider);

    // Get exercises for this workout
    final exercises = await db.exerciseDao.getExercisesByWorkoutId(workoutId);

    if (exercises.isEmpty) {
      throw Exception('No exercises found for this workout');
    }

    // Create a workout session in the database
    final sessionId = await db.workoutSessionDao.insertWorkoutSession(
      WorkoutSessionsCompanion(
        userId: drift.Value(userId),
        workoutId: drift.Value(workoutId),
        level: drift.Value(level),
        exercisesCompleted: const drift.Value(0),
        totalExercises: drift.Value(exercises.length),
        durationMinutes: const drift.Value(0),
        startedAt: drift.Value(DateTime.now()),
        isCompleted: const drift.Value(false),
      ),
    );

    state = WorkoutSessionState(
      workoutId: workoutId,
      workoutSessionId: sessionId,
      level: level,
      exercises: exercises,
      currentExerciseIndex: 0,
      startedAt: DateTime.now(),
    );
  }

  /// Move to the next exercise
  Future<void> nextExercise() async {
    if (state == null || state!.isLastExercise) return;

    final newIndex = state!.currentExerciseIndex + 1;
    state = state!.copyWith(currentExerciseIndex: newIndex);

    // Update exercises completed in database
    final db = ref.read(appDatabaseProvider);
    await db.workoutSessionDao.updateExercisesCompleted(
      state!.workoutSessionId,
      newIndex + 1,
    );
  }

  /// Move to the previous exercise
  void previousExercise() {
    if (state == null || state!.isFirstExercise) return;

    final newIndex = state!.currentExerciseIndex - 1;
    state = state!.copyWith(currentExerciseIndex: newIndex);
  }

  /// Skip to a specific exercise
  void skipToExercise(int index) {
    if (state == null || index < 0 || index >= state!.totalExercises) return;
    state = state!.copyWith(currentExerciseIndex: index);
  }

  /// Complete the current workout session
  Future<void> completeWorkout({int? caloriesBurned}) async {
    if (state == null) return;

    final db = ref.read(appDatabaseProvider);
    final duration = DateTime.now().difference(state!.startedAt).inMinutes;

    // Mark workout session as completed
    await db.workoutSessionDao.markWorkoutSessionAsCompleted(
      state!.workoutSessionId,
      caloriesBurned: caloriesBurned,
    );

    // Update the workout session duration
    final session = await db.workoutSessionDao.getWorkoutSessionById(
      state!.workoutSessionId,
    );

    if (session != null) {
      await db.workoutSessionDao.updateWorkoutSession(
        session.copyWith(
          durationMinutes: duration > 0 ? duration : 1,
          exercisesCompleted: state!.totalExercises,
        ),
      );
    }

    // Mark the workout as completed if not already
    await db.workoutDao.markWorkoutAsCompleted(state!.workoutId);

    // Invalidate progress providers to refresh the dashboard
    ref.invalidate(workoutStreakProvider);
    ref.invalidate(weeklyWorkoutStatsProvider);
    ref.invalidate(achievementsProvider);

    // Clear the current workout state
    state = null;
  }

  /// Cancel the current workout session
  void cancelWorkout() {
    state = null;
  }

  /// Get current exercise progress (0.0 to 1.0)
  double get progress {
    if (state == null) return 0.0;
    return (state!.currentExerciseIndex + 1) / state!.totalExercises;
  }
}

/// Provider to get all workouts for a specific level
@riverpod
Future<List<Workout>> workoutsByLevel(
  WorkoutsByLevelRef ref,
  int userId,
  int level,
) async {
  final db = ref.watch(appDatabaseProvider);
  return await db.workoutDao.getWorkoutsByLevel(userId, level);
}

/// Provider to watch workouts for a specific level (reactive)
@riverpod
Stream<List<Workout>> watchWorkoutsByLevel(
  WatchWorkoutsByLevelRef ref,
  int userId,
  int level,
) {
  final db = ref.watch(appDatabaseProvider);
  return db.workoutDao.watchWorkoutsByLevel(userId, level);
}

/// Provider to get workout by ID
@riverpod
Future<Workout?> workoutById(WorkoutByIdRef ref, int workoutId) async {
  final db = ref.watch(appDatabaseProvider);
  return await db.workoutDao.getWorkoutById(workoutId);
}

/// Provider to watch a specific workout (reactive)
@riverpod
Stream<Workout?> watchWorkout(WatchWorkoutRef ref, int workoutId) {
  final db = ref.watch(appDatabaseProvider);
  return db.workoutDao.watchWorkoutById(workoutId);
}

/// Provider to get exercises for a workout
@riverpod
Future<List<Exercise>> exercisesForWorkout(
  ExercisesForWorkoutRef ref,
  int workoutId,
) async {
  final db = ref.watch(appDatabaseProvider);
  return await db.exerciseDao.getExercisesByWorkoutId(workoutId);
}

/// Provider to watch exercises for a workout (reactive)
@riverpod
Stream<List<Exercise>> watchExercisesForWorkout(
  WatchExercisesForWorkoutRef ref,
  int workoutId,
) {
  final db = ref.watch(appDatabaseProvider);
  return db.exerciseDao.watchExercisesByWorkoutId(workoutId);
}

/// Provider to get workout session statistics
@riverpod
Future<Map<String, dynamic>> workoutSessionStats(
  WorkoutSessionStatsRef ref,
  int userId,
) async {
  final db = ref.watch(appDatabaseProvider);
  return await db.workoutSessionDao.getWorkoutSessionStatistics(userId);
}

/// Provider to watch workout sessions for a user (reactive)
@riverpod
Stream<List<WorkoutSession>> watchWorkoutSessions(
  WatchWorkoutSessionsRef ref,
  int userId,
) {
  final db = ref.watch(appDatabaseProvider);
  return db.workoutSessionDao.watchWorkoutSessionsByUserId(userId);
}

/// Provider to get workout streak
@riverpod
Future<int> workoutStreak(WorkoutStreakRef ref, int userId) async {
  final db = ref.watch(appDatabaseProvider);
  return await db.workoutSessionDao.calculateWorkoutStreak(userId);
}

/// Provider to get longest workout streak
@riverpod
Future<int> longestWorkoutStreak(LongestWorkoutStreakRef ref, int userId) async {
  final db = ref.watch(appDatabaseProvider);
  return await db.workoutSessionDao.getLongestStreak(userId);
}

/// Provider to check if user worked out today
@riverpod
Future<bool> workedOutToday(WorkedOutTodayRef ref, int userId) async {
  final db = ref.watch(appDatabaseProvider);
  return await db.workoutSessionDao.hasWorkedOutToday(userId);
}

/// Provider to get recent workout sessions
@riverpod
Future<List<WorkoutSession>> recentWorkoutSessions(
  RecentWorkoutSessionsRef ref,
  int userId, {
  int limit = 10,
}) async {
  final db = ref.watch(appDatabaseProvider);
  return await db.workoutSessionDao.getRecentWorkoutSessions(userId, limit: limit);
}

/// Provider to get completed workouts count
@riverpod
Future<int> completedWorkoutsCount(
  CompletedWorkoutsCountRef ref,
  int userId,
  int level,
) async {
  final db = ref.watch(appDatabaseProvider);
  return await db.workoutDao.getWorkoutCount(userId, level: level, completed: true);
}

/// Provider to get total workouts count
@riverpod
Future<int> totalWorkoutsCount(
  TotalWorkoutsCountRef ref,
  int userId,
  int level,
) async {
  final db = ref.watch(appDatabaseProvider);
  return await db.workoutDao.getWorkoutCount(userId, level: level);
}

/// Provider to get level completion percentage
@riverpod
Future<double> levelCompletionPercentage(
  LevelCompletionPercentageRef ref,
  int userId,
  int level,
) async {
  final db = ref.watch(appDatabaseProvider);
  return await db.workoutDao.getLevelCompletionPercentage(userId, level);
}
