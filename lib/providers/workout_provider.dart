import 'package:drift/drift.dart' as drift;
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../database/app_database.dart';
import 'auth_provider.dart';
import 'database_provider.dart';

part 'workout_provider.g.dart';

/// Workout model for current workout state
class CurrentWorkout {
  final int level;
  final DateTime startedAt;
  final List<String> exerciseIds;
  final int currentExerciseIndex;

  const CurrentWorkout({
    required this.level,
    required this.startedAt,
    required this.exerciseIds,
    this.currentExerciseIndex = 0,
  });

  CurrentWorkout copyWith({
    int? level,
    DateTime? startedAt,
    List<String>? exerciseIds,
    int? currentExerciseIndex,
  }) {
    return CurrentWorkout(
      level: level ?? this.level,
      startedAt: startedAt ?? this.startedAt,
      exerciseIds: exerciseIds ?? this.exerciseIds,
      currentExerciseIndex: currentExerciseIndex ?? this.currentExerciseIndex,
    );
  }
}

/// Stream provider for user's current workout level (0-3)
/// Watches the database for changes
@riverpod
Stream<int> userCurrentLevel(UserCurrentLevelRef ref) async* {
  final userId = ref.watch(userIdProvider);

  if (userId == null) {
    yield 0;
    return;
  }

  final db = ref.watch(appDatabaseProvider);
  final user = await db.getUserByFirebaseUid(userId);

  if (user == null) {
    yield 0;
    return;
  }

  yield user.currentLevel;

  // Watch for changes
  await for (final _ in Stream.periodic(const Duration(seconds: 1))) {
    final updatedUser = await db.getUserByFirebaseUid(userId);
    if (updatedUser != null) {
      yield updatedUser.currentLevel;
    }
  }
}

/// State provider for current workout session
@riverpod
class CurrentWorkoutSession extends _$CurrentWorkoutSession {
  @override
  CurrentWorkout? build() {
    return null;
  }

  /// Start a new workout session
  void startWorkout({
    required int level,
    required List<String> exerciseIds,
  }) {
    state = CurrentWorkout(
      level: level,
      startedAt: DateTime.now(),
      exerciseIds: exerciseIds,
      currentExerciseIndex: 0,
    );
  }

  /// Move to next exercise
  void nextExercise() {
    if (state == null) return;

    final newIndex = state!.currentExerciseIndex + 1;
    if (newIndex < state!.exerciseIds.length) {
      state = state!.copyWith(currentExerciseIndex: newIndex);
    }
  }

  /// Move to previous exercise
  void previousExercise() {
    if (state == null) return;

    final newIndex = state!.currentExerciseIndex - 1;
    if (newIndex >= 0) {
      state = state!.copyWith(currentExerciseIndex: newIndex);
    }
  }

  /// Complete the current workout
  Future<void> completeWorkout() async {
    if (state == null) return;

    final userId = ref.read(userIdProvider);
    if (userId == null) return;

    final db = ref.read(appDatabaseProvider);
    final duration = DateTime.now().difference(state!.startedAt).inSeconds;

    // Save workout session to database
    await db.insertWorkoutSession(
      WorkoutSessionsCompanion(
        userId: drift.Value(userId),
        level: drift.Value(state!.level),
        duration: drift.Value(duration),
        completed: const drift.Value(true),
        startedAt: drift.Value(state!.startedAt),
        completedAt: drift.Value(DateTime.now()),
      ),
    );

    // Clear current workout
    state = null;
  }

  /// Cancel the current workout
  void cancelWorkout() {
    state = null;
  }
}

/// Stream provider for user's workout progress
/// Returns list of completed workout sessions
@riverpod
Stream<List<WorkoutSession>> workoutProgress(WorkoutProgressRef ref) async* {
  final userId = ref.watch(userIdProvider);

  if (userId == null) {
    yield [];
    return;
  }

  final db = ref.watch(appDatabaseProvider);
  yield* db.watchUserWorkouts(userId);
}

/// Provider to get workout statistics
@riverpod
Future<WorkoutStats> workoutStats(WorkoutStatsRef ref) async {
  final userId = ref.watch(userIdProvider);

  if (userId == null) {
    return const WorkoutStats(
      totalWorkouts: 0,
      totalDuration: 0,
      currentStreak: 0,
      longestStreak: 0,
    );
  }

  final db = ref.read(appDatabaseProvider);
  final workouts = await db.watchUserWorkouts(userId).first;

  final completedWorkouts = workouts.where((w) => w.completed).toList();
  final totalWorkouts = completedWorkouts.length;
  final totalDuration = completedWorkouts.fold<int>(
    0,
    (sum, workout) => sum + workout.duration,
  );

  // Calculate streaks
  final streaks = _calculateStreaks(completedWorkouts);

  return WorkoutStats(
    totalWorkouts: totalWorkouts,
    totalDuration: totalDuration,
    currentStreak: streaks.currentStreak,
    longestStreak: streaks.longestStreak,
  );
}

/// Workout statistics model
class WorkoutStats {
  final int totalWorkouts;
  final int totalDuration; // in seconds
  final int currentStreak; // in days
  final int longestStreak; // in days

  const WorkoutStats({
    required this.totalWorkouts,
    required this.totalDuration,
    required this.currentStreak,
    required this.longestStreak,
  });
}

/// Helper class for streak calculation
class _StreakResult {
  final int currentStreak;
  final int longestStreak;

  const _StreakResult({
    required this.currentStreak,
    required this.longestStreak,
  });
}

/// Calculate workout streaks
_StreakResult _calculateStreaks(List<WorkoutSession> workouts) {
  if (workouts.isEmpty) {
    return const _StreakResult(currentStreak: 0, longestStreak: 0);
  }

  // Sort by date (most recent first)
  final sortedWorkouts = workouts.toList()
    ..sort((a, b) => b.startedAt.compareTo(a.startedAt));

  int currentStreak = 0;
  int longestStreak = 0;
  int tempStreak = 0;

  DateTime? lastDate;

  for (final workout in sortedWorkouts) {
    final workoutDate = DateTime(
      workout.startedAt.year,
      workout.startedAt.month,
      workout.startedAt.day,
    );

    if (lastDate == null) {
      tempStreak = 1;
      lastDate = workoutDate;
      continue;
    }

    final daysDifference = lastDate.difference(workoutDate).inDays;

    if (daysDifference == 1) {
      tempStreak++;
    } else if (daysDifference > 1) {
      longestStreak = tempStreak > longestStreak ? tempStreak : longestStreak;
      tempStreak = 1;
    }

    lastDate = workoutDate;
  }

  longestStreak = tempStreak > longestStreak ? tempStreak : longestStreak;

  // Check if current streak is still active
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final mostRecentWorkout = DateTime(
    sortedWorkouts.first.startedAt.year,
    sortedWorkouts.first.startedAt.month,
    sortedWorkouts.first.startedAt.day,
  );

  final daysSinceLastWorkout = today.difference(mostRecentWorkout).inDays;
  currentStreak = daysSinceLastWorkout <= 1 ? tempStreak : 0;

  return _StreakResult(
    currentStreak: currentStreak,
    longestStreak: longestStreak,
  );
}

/// Provider to update user level
@riverpod
class UserLevel extends _$UserLevel {
  @override
  FutureOr<void> build() {
    // No initial state needed
  }

  /// Update user's workout level
  Future<void> updateLevel(int newLevel) async {
    if (newLevel < 0 || newLevel > 3) {
      throw ArgumentError('Level must be between 0 and 3');
    }

    state = const AsyncValue.loading();

    try {
      final userId = ref.read(userIdProvider);
      if (userId == null) {
        throw Exception('User not logged in');
      }

      final db = ref.read(appDatabaseProvider);
      final user = await db.getUserByFirebaseUid(userId);

      if (user == null) {
        throw Exception('User not found in database');
      }

      await db.updateUser(
        user.copyWith(
          currentLevel: newLevel,
          updatedAt: DateTime.now(),
        ),
      );

      state = const AsyncValue.data(null);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }
}
