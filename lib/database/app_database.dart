import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

import 'converters/json_converter.dart';
import 'daos/user_dao.dart';
import 'daos/assessment_dao.dart';
import 'daos/workout_dao.dart';
import 'daos/exercise_dao.dart';
import 'daos/progress_dao.dart';
import 'daos/kegel_session_dao.dart';
import 'daos/workout_session_dao.dart';

part 'app_database.g.dart';

// ============================================================================
// TABLE DEFINITIONS
// ============================================================================

/// Users table - stores user profile and authentication data
@DataClassName('User')
class Users extends Table {
  IntColumn get userId => integer().autoIncrement()();
  TextColumn get name => text()();
  TextColumn get email => text().unique()();
  TextColumn get passwordHash => text()();

  /// Delivery type: 'vaginal' or 'c_section'
  TextColumn get deliveryType => text()();

  /// Number of weeks postpartum
  IntColumn get weeksPostpartum => integer()();

  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {userId};
}

/// Assessments table - stores pelvic floor and diastasis recti assessments
@DataClassName('Assessment')
class Assessments extends Table {
  IntColumn get assessmentId => integer().autoIncrement()();

  IntColumn get userId => integer().references(Users, #userId, onDelete: KeyAction.cascade)();

  /// Assessment type: 'pelvic_floor' or 'diastasis_recti'
  TextColumn get type => text()();

  /// Questions in JSON format
  TextColumn get questions => text().map(const JsonMapConverter())();

  /// Answers in JSON format
  TextColumn get answers => text().map(const JsonMapConverter())();

  /// Classification: 'weak', 'moderate', or 'strong'
  TextColumn get classification => text()();

  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {assessmentId};

  @override
  List<Set<Column>> get uniqueKeys => [];
}

/// Workouts table - stores workout programs
@DataClassName('Workout')
class Workouts extends Table {
  IntColumn get workoutId => integer().autoIncrement()();

  IntColumn get userId => integer().references(Users, #userId, onDelete: KeyAction.cascade)();

  /// Workout level: 1, 2, or 3
  IntColumn get level => integer()();

  TextColumn get name => text()();
  TextColumn get description => text()();

  /// Duration in minutes
  IntColumn get durationMinutes => integer()();

  BoolColumn get isCompleted => boolean().withDefault(const Constant(false))();
  DateTimeColumn get completedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {workoutId};
}

/// Exercises table - stores individual exercises for workouts
@DataClassName('Exercise')
class Exercises extends Table {
  IntColumn get exerciseId => integer().autoIncrement()();

  IntColumn get workoutId => integer().references(Workouts, #workoutId, onDelete: KeyAction.cascade)();

  TextColumn get exerciseName => text()();
  TextColumn get description => text()();

  /// Path to Lottie animation JSON file
  TextColumn get animationPath => text()();

  /// Sets and reps in format like "3x10" or "3x15"
  TextColumn get setsReps => text()();

  /// Duration in seconds (for timed exercises)
  IntColumn get durationSeconds => integer().nullable()();

  /// Order of exercise in the workout
  IntColumn get orderIndex => integer()();

  @override
  Set<Column> get primaryKey => {exerciseId};
}

/// Progress table - stores user progress tracking data
@DataClassName('Progress')
class ProgressRecords extends Table {
  IntColumn get progressId => integer().autoIncrement()();

  IntColumn get userId => integer().references(Users, #userId, onDelete: KeyAction.cascade)();

  /// Progress type: 'diastasis', 'pelvic_floor', 'weight', or 'photo'
  TextColumn get type => text()();

  /// Value can be numeric or JSON for complex data (e.g., photo paths)
  TextColumn get value => text().map(const NullableJsonMapConverter()).nullable()();

  DateTimeColumn get recordedAt => dateTime().withDefault(currentDateAndTime)();

  /// Week number since starting the program
  IntColumn get weekNumber => integer()();

  @override
  Set<Column> get primaryKey => {progressId};
}

/// Kegel Sessions table - stores kegel exercise tracking data
@DataClassName('KegelSession')
class KegelSessions extends Table {
  IntColumn get sessionId => integer().autoIncrement()();

  IntColumn get userId => integer().references(Users, #userId, onDelete: KeyAction.cascade)();

  /// Duration in minutes
  IntColumn get durationMinutes => integer()();

  /// Number of reps completed
  IntColumn get repsCompleted => integer()();

  DateTimeColumn get startedAt => dateTime()();
  DateTimeColumn get endedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {sessionId};
}

/// Workout Sessions table - stores individual workout session tracking
@DataClassName('WorkoutSession')
class WorkoutSessions extends Table {
  IntColumn get workoutSessionId => integer().autoIncrement()();

  IntColumn get userId => integer().references(Users, #userId, onDelete: KeyAction.cascade)();

  IntColumn get workoutId => integer().references(Workouts, #workoutId, onDelete: KeyAction.cascade)();

  /// Workout level at time of session
  IntColumn get level => integer()();

  /// Number of exercises completed in this session
  IntColumn get exercisesCompleted => integer()();

  /// Total exercises in the workout
  IntColumn get totalExercises => integer()();

  /// Estimated calories burned
  IntColumn get caloriesBurned => integer().nullable()();

  /// Duration in minutes
  IntColumn get durationMinutes => integer()();

  DateTimeColumn get startedAt => dateTime()();
  DateTimeColumn get completedAt => dateTime().nullable()();

  /// Whether the session was fully completed
  BoolColumn get isCompleted => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {workoutSessionId};
}

// ============================================================================
// DATABASE CONFIGURATION
// ============================================================================

@DriftDatabase(
  tables: [
    Users,
    Assessments,
    Workouts,
    Exercises,
    ProgressRecords,
    KegelSessions,
    WorkoutSessions,
  ],
  daos: [
    UserDao,
    AssessmentDao,
    WorkoutDao,
    ExerciseDao,
    ProgressDao,
    KegelSessionDao,
    WorkoutSessionDao,
  ],
)
class AppDatabase extends _$AppDatabase {
  // Private constructor for singleton pattern
  AppDatabase._internal() : super(_openConnection());

  // Singleton instance
  static final AppDatabase _instance = AppDatabase._internal();

  // Factory constructor to return singleton instance
  factory AppDatabase() => _instance;

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (Migrator m) async {
        await m.createAll();

        // Create indexes for performance
        await customStatement(
          'CREATE INDEX idx_assessments_user_type ON assessments(user_id, type);',
        );
        await customStatement(
          'CREATE INDEX idx_workouts_user_level ON workouts(user_id, level);',
        );
        await customStatement(
          'CREATE INDEX idx_exercises_workout ON exercises(workout_id, order_index);',
        );
        await customStatement(
          'CREATE INDEX idx_progress_user_type ON progress_records(user_id, type);',
        );
        await customStatement(
          'CREATE INDEX idx_progress_week ON progress_records(user_id, week_number);',
        );
        await customStatement(
          'CREATE INDEX idx_kegel_user ON kegel_sessions(user_id, started_at);',
        );
        await customStatement(
          'CREATE INDEX idx_workout_sessions_user ON workout_sessions(user_id, started_at);',
        );
        await customStatement(
          'CREATE INDEX idx_workout_sessions_workout ON workout_sessions(workout_id, completed_at);',
        );
      },
      onUpgrade: (Migrator m, int from, int to) async {
        // Migrate from version 1 to 2
        if (from < 2) {
          // Add WorkoutSessions table
          await m.createTable(workoutSessions);

          // Create indexes for workout sessions
          await customStatement(
            'CREATE INDEX idx_workout_sessions_user ON workout_sessions(user_id, started_at);',
          );
          await customStatement(
            'CREATE INDEX idx_workout_sessions_workout ON workout_sessions(workout_id, completed_at);',
          );
        }
      },
      beforeOpen: (details) async {
        // Enable foreign key constraints
        await customStatement('PRAGMA foreign_keys = ON;');
      },
    );
  }

  /// Close the database connection
  Future<void> closeDatabase() async {
    await close();
  }

  /// Delete the database file (useful for testing or reset)
  static Future<void> deleteDatabase() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'postpartum_recovery.sqlite'));
    if (await file.exists()) {
      await file.delete();
    }
  }
}

/// Opens a connection to the database
LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'postpartum_recovery.sqlite'));
    return NativeDatabase(file);
  });
}
