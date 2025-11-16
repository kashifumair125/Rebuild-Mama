import 'package:drift/drift.dart' as drift;
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../database/app_database.dart';
import 'database_provider.dart';

part 'sos_provider.g.dart';

/// Model for the current SOS session state
class SosSessionState {
  final int sosRoutineId;
  final SosRoutine routine;
  final List<SosExercise> exercises;
  final int currentExerciseIndex;
  final DateTime startedAt;
  final int? sessionRecordId;

  const SosSessionState({
    required this.sosRoutineId,
    required this.routine,
    required this.exercises,
    this.currentExerciseIndex = 0,
    required this.startedAt,
    this.sessionRecordId,
  });

  SosExercise get currentExercise => exercises[currentExerciseIndex];

  bool get isLastExercise => currentExerciseIndex == exercises.length - 1;

  bool get isFirstExercise => currentExerciseIndex == 0;

  int get totalExercises => exercises.length;

  int get exercisesCompleted => currentExerciseIndex + 1;

  double get progressPercentage =>
      totalExercises > 0 ? (exercisesCompleted / totalExercises) : 0.0;

  SosSessionState copyWith({
    int? sosRoutineId,
    SosRoutine? routine,
    List<SosExercise>? exercises,
    int? currentExerciseIndex,
    DateTime? startedAt,
    int? sessionRecordId,
  }) {
    return SosSessionState(
      sosRoutineId: sosRoutineId ?? this.sosRoutineId,
      routine: routine ?? this.routine,
      exercises: exercises ?? this.exercises,
      currentExerciseIndex: currentExerciseIndex ?? this.currentExerciseIndex,
      startedAt: startedAt ?? this.startedAt,
      sessionRecordId: sessionRecordId ?? this.sessionRecordId,
    );
  }
}

// ============================================================================
// PROVIDERS - SOS ROUTINES
// ============================================================================

/// Provider for all SOS routines (reactive)
@riverpod
Stream<List<SosRoutine>> watchAllSosRoutines(WatchAllSosRoutinesRef ref) {
  final db = ref.watch(appDatabaseProvider);
  return db.sosRoutineDao.watchAllSosRoutines();
}

/// Provider for a single SOS routine by ID
@riverpod
Future<SosRoutine?> sosRoutineById(SosRoutineByIdRef ref, int routineId) async {
  final db = ref.watch(appDatabaseProvider);
  return db.sosRoutineDao.getSosRoutineById(routineId);
}

/// Provider for watching a single SOS routine by ID (reactive)
@riverpod
Stream<SosRoutine?> watchSosRoutineById(
  WatchSosRoutineByIdRef ref,
  int routineId,
) {
  final db = ref.watch(appDatabaseProvider);
  return db.sosRoutineDao.watchSosRoutineById(routineId);
}

// ============================================================================
// PROVIDERS - SOS EXERCISES
// ============================================================================

/// Provider for SOS exercises by routine ID
@riverpod
Future<List<SosExercise>> sosExercisesByRoutineId(
  SosExercisesByRoutineIdRef ref,
  int routineId,
) async {
  final db = ref.watch(appDatabaseProvider);
  return db.sosRoutineDao.getSosExercisesByRoutineId(routineId);
}

/// Provider for watching SOS exercises by routine ID (reactive)
@riverpod
Stream<List<SosExercise>> watchSosExercisesByRoutineId(
  WatchSosExercisesByRoutineIdRef ref,
  int routineId,
) {
  final db = ref.watch(appDatabaseProvider);
  return db.sosRoutineDao.watchSosExercisesByRoutineId(routineId);
}

// ============================================================================
// PROVIDERS - SOS SESSIONS
// ============================================================================

/// Provider for SOS session history (reactive)
@riverpod
Stream<List<SosSessionRecord>> watchSosSessionsByUserId(
  WatchSosSessionsByUserIdRef ref,
  int userId,
) {
  final db = ref.watch(appDatabaseProvider);
  return db.sosRoutineDao.watchSosSessionsByUserId(userId);
}

/// Provider for SOS statistics
@riverpod
Future<Map<String, dynamic>> sosStatistics(
  SosStatisticsRef ref,
  int userId,
) async {
  final db = ref.watch(appDatabaseProvider);
  return db.sosRoutineDao.getSosStatistics(userId);
}

/// Provider for usage count of a specific routine
@riverpod
Future<int> routineUsageCount(
  RoutineUsageCountRef ref,
  int userId,
  int routineId,
) async {
  final db = ref.watch(appDatabaseProvider);
  return db.sosRoutineDao.getRoutineUsageCount(userId, routineId);
}

/// Provider for most used SOS routine
@riverpod
Future<Map<String, dynamic>?> mostUsedSosRoutine(
  MostUsedSosRoutineRef ref,
  int userId,
) async {
  final db = ref.watch(appDatabaseProvider);
  return db.sosRoutineDao.getMostUsedSosRoutine(userId);
}

/// Provider for last used date of a routine
@riverpod
Future<DateTime?> routineLastUsedDate(
  RoutineLastUsedDateRef ref,
  int userId,
  int routineId,
) async {
  final db = ref.watch(appDatabaseProvider);
  return db.sosRoutineDao.getLastUsedDate(userId, routineId);
}

// ============================================================================
// STATE NOTIFIER - CURRENT SOS SESSION
// ============================================================================

/// State notifier for managing the current SOS session
@riverpod
class CurrentSosSession extends _$CurrentSosSession {
  @override
  SosSessionState? build() {
    return null;
  }

  /// Start a new SOS session
  Future<void> startSosRoutine({
    required int userId,
    required int sosRoutineId,
  }) async {
    final db = ref.read(appDatabaseProvider);

    // Get the routine
    final routine = await db.sosRoutineDao.getSosRoutineById(sosRoutineId);
    if (routine == null) {
      throw Exception('SOS routine not found');
    }

    // Get exercises for this routine
    final exercises =
        await db.sosRoutineDao.getSosExercisesByRoutineId(sosRoutineId);

    if (exercises.isEmpty) {
      throw Exception('No exercises found for this SOS routine');
    }

    // Create a session record in the database
    final sessionId = await db.sosRoutineDao.insertSosSessionRecord(
      SosSessionRecordsCompanion(
        userId: drift.Value(userId),
        sosRoutineId: drift.Value(sosRoutineId),
        startedAt: drift.Value(DateTime.now()),
        completedAt: drift.Value(DateTime.now()), // Will update on completion
        isCompleted: const drift.Value(false),
      ),
    );

    state = SosSessionState(
      sosRoutineId: sosRoutineId,
      routine: routine,
      exercises: exercises,
      currentExerciseIndex: 0,
      startedAt: DateTime.now(),
      sessionRecordId: sessionId,
    );
  }

  /// Move to the next exercise
  void nextExercise() {
    if (state == null || state!.isLastExercise) return;

    final newIndex = state!.currentExerciseIndex + 1;
    state = state!.copyWith(currentExerciseIndex: newIndex);
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

  /// Complete the current SOS session
  Future<void> completeSosSession() async {
    if (state == null) return;

    final db = ref.read(appDatabaseProvider);

    // Update the session record to mark as completed
    if (state!.sessionRecordId != null) {
      final session = await db.sosRoutineDao
          .getSosSessionsByUserId(1); // Get user ID from auth

      // Since we need to update the session, we'll delete and recreate
      // In a real app, you'd have an update method in the DAO
      await db.sosRoutineDao.deleteSosSessionRecord(state!.sessionRecordId!);

      // Create a new completed session record
      await db.sosRoutineDao.recordCompletedSosSession(
        userId: 1, // Replace with actual user ID from auth
        sosRoutineId: state!.sosRoutineId,
        startedAt: state!.startedAt,
        completedAt: DateTime.now(),
      );
    }

    // Clear the current session state
    state = null;
  }

  /// End the session without completing
  void endSession() {
    if (state == null) return;

    // Delete the session record since it wasn't completed
    final db = ref.read(appDatabaseProvider);
    if (state!.sessionRecordId != null) {
      db.sosRoutineDao.deleteSosSessionRecord(state!.sessionRecordId!);
    }

    // Clear the session state
    state = null;
  }

  /// Restart the current routine from the beginning
  void restartRoutine() {
    if (state == null) return;
    state = state!.copyWith(currentExerciseIndex: 0);
  }
}
