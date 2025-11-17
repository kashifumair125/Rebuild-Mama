import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

import 'converters/json_converter.dart';
import 'database_exceptions.dart';
import 'daos/user_dao.dart';
import 'daos/assessment_dao.dart';
import 'daos/workout_dao.dart';
import 'daos/exercise_dao.dart';
import 'daos/progress_dao.dart';
import 'daos/kegel_session_dao.dart';
import 'daos/workout_session_dao.dart';
import 'daos/sos_routine_dao.dart';
import '../utils/logger.dart';

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

/// SOS Routines table - stores emergency relief routine definitions
@DataClassName('SosRoutine')
class SosRoutines extends Table {
  IntColumn get sosRoutineId => integer().autoIncrement()();

  TextColumn get name => text()();
  TextColumn get description => text()();

  /// Icon emoji for display
  TextColumn get iconEmoji => text()();

  /// Total duration in minutes
  IntColumn get durationMinutes => integer()();

  /// Number of exercises in this routine
  IntColumn get exerciseCount => integer()();

  /// Difficulty level: 'easy', 'moderate', 'advanced'
  TextColumn get difficulty => text()();

  /// Safety warning text
  TextColumn get safetyWarning => text().nullable()();

  /// Tips text
  TextColumn get tips => text().nullable()();

  /// Display order
  IntColumn get orderIndex => integer()();

  @override
  Set<Column> get primaryKey => {sosRoutineId};
}

/// SOS Exercises table - stores individual exercises for SOS routines
@DataClassName('SosExercise')
class SosExercises extends Table {
  IntColumn get sosExerciseId => integer().autoIncrement()();

  IntColumn get sosRoutineId => integer().references(SosRoutines, #sosRoutineId, onDelete: KeyAction.cascade)();

  TextColumn get exerciseName => text()();
  TextColumn get description => text()();

  /// Path to Lottie animation JSON file
  TextColumn get animationPath => text()();

  /// Duration in seconds
  IntColumn get durationSeconds => integer()();

  /// Audio guidance text
  TextColumn get audioGuidance => text()();

  /// Order of exercise in the routine
  IntColumn get orderIndex => integer()();

  @override
  Set<Column> get primaryKey => {sosExerciseId};
}

/// SOS Session Records table - tracks completed SOS routine sessions
@DataClassName('SosSessionRecord')
class SosSessionRecords extends Table {
  IntColumn get sosSessionId => integer().autoIncrement()();

  IntColumn get userId => integer().references(Users, #userId, onDelete: KeyAction.cascade)();

  IntColumn get sosRoutineId => integer().references(SosRoutines, #sosRoutineId, onDelete: KeyAction.cascade)();

  DateTimeColumn get startedAt => dateTime()();
  DateTimeColumn get completedAt => dateTime()();

  /// Whether the session was fully completed
  BoolColumn get isCompleted => boolean().withDefault(const Constant(true))();

  @override
  Set<Column> get primaryKey => {sosSessionId};
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
    SosRoutines,
    SosExercises,
    SosSessionRecords,
  ],
  daos: [
    UserDao,
    AssessmentDao,
    WorkoutDao,
    ExerciseDao,
    ProgressDao,
    KegelSessionDao,
    WorkoutSessionDao,
    SosRoutineDao,
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
  int get schemaVersion => 3;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (Migrator m) async {
        try {
          AppLogger.database('Creating database schema v$schemaVersion');

          await m.createAll();

          // Create indexes for performance
          await _createIndexes();

          AppLogger.database('Database schema created successfully');
        } catch (e, stackTrace) {
          AppLogger.database('Database creation failed', error: e, stackTrace: stackTrace);
          throw DatabaseConnectionException(
            'Failed to create database schema',
            originalError: e,
            stackTrace: stackTrace,
          );
        }
      },
      onUpgrade: (Migrator m, int from, int to) async {
        try {
          AppLogger.database('Migrating database from v$from to v$to');

          // Migrate from version 1 to 2
          if (from < 2) {
            try {
              // Add WorkoutSessions table
              await m.createTable(workoutSessions);

              // Create indexes for workout sessions
              await customStatement(
                'CREATE INDEX idx_workout_sessions_user ON workout_sessions(user_id, started_at);',
              );
              await customStatement(
                'CREATE INDEX idx_workout_sessions_workout ON workout_sessions(workout_id, completed_at);',
              );

              AppLogger.database('Migration v1 to v2 completed');
            } catch (e, stackTrace) {
              throw DatabaseMigrationException(
                'Failed to migrate WorkoutSessions table',
                from,
                2,
                originalError: e,
                stackTrace: stackTrace,
              );
            }
          }

          // Migrate from version 2 to 3
          if (from < 3) {
            try {
              // Add SOS tables
              await m.createTable(sosRoutines);
              await m.createTable(sosExercises);
              await m.createTable(sosSessionRecords);

              // Create indexes for SOS tables
              await customStatement(
                'CREATE INDEX idx_sos_exercises_routine ON sos_exercises(sos_routine_id, order_index);',
              );
              await customStatement(
                'CREATE INDEX idx_sos_sessions_user ON sos_session_records(user_id, started_at);',
              );
              await customStatement(
                'CREATE INDEX idx_sos_sessions_routine ON sos_session_records(sos_routine_id, completed_at);',
              );

              AppLogger.database('Migration v2 to v3 completed');
            } catch (e, stackTrace) {
              throw DatabaseMigrationException(
                'Failed to migrate SOS tables',
                from,
                3,
                originalError: e,
                stackTrace: stackTrace,
              );
            }
          }

          AppLogger.database('Database migration completed successfully');
        } catch (e, stackTrace) {
          AppLogger.database(
            'Database migration failed from v$from to v$to',
            error: e,
            stackTrace: stackTrace,
          );
          rethrow;
        }
      },
      beforeOpen: (details) async {
        try {
          // Enable foreign key constraints
          await customStatement('PRAGMA foreign_keys = ON;');

          // Enable Write-Ahead Logging for better performance
          await customStatement('PRAGMA journal_mode = WAL;');

          // Optimize database
          await customStatement('PRAGMA synchronous = NORMAL;');

          AppLogger.database('Database opened successfully (version: ${details.versionNow})');
        } catch (e, stackTrace) {
          AppLogger.database('Database configuration failed', error: e, stackTrace: stackTrace);
          throw DatabaseConnectionException(
            'Failed to configure database',
            originalError: e,
            stackTrace: stackTrace,
          );
        }
      },
    );
  }

  /// Create all database indexes
  Future<void> _createIndexes() async {
    try {
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
      await customStatement(
        'CREATE INDEX idx_sos_exercises_routine ON sos_exercises(sos_routine_id, order_index);',
      );
      await customStatement(
        'CREATE INDEX idx_sos_sessions_user ON sos_session_records(user_id, started_at);',
      );
      await customStatement(
        'CREATE INDEX idx_sos_sessions_routine ON sos_session_records(sos_routine_id, completed_at);',
      );

      AppLogger.database('Database indexes created successfully');
    } catch (e, stackTrace) {
      AppLogger.database('Failed to create indexes', error: e, stackTrace: stackTrace);
      throw DatabaseConnectionException(
        'Failed to create database indexes',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// Close the database connection
  Future<void> closeDatabase() async {
    try {
      AppLogger.database('Closing database connection');
      await close();
      AppLogger.database('Database connection closed');
    } catch (e, stackTrace) {
      AppLogger.database('Failed to close database', error: e, stackTrace: stackTrace);
      throw DatabaseConnectionException(
        'Failed to close database connection',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// Delete the database file (useful for testing or reset)
  static Future<void> deleteDatabase() async {
    try {
      AppLogger.database('Deleting database file');

      final dbFolder = await getApplicationDocumentsDirectory();
      final file = File(p.join(dbFolder.path, 'postpartum_recovery.sqlite'));

      if (await file.exists()) {
        await file.delete();
        AppLogger.database('Database file deleted successfully');
      } else {
        AppLogger.database('Database file does not exist');
      }
    } catch (e, stackTrace) {
      AppLogger.database('Failed to delete database', error: e, stackTrace: stackTrace);
      throw DatabaseConnectionException(
        'Failed to delete database file',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// Verify database integrity
  Future<bool> verifyIntegrity() async {
    try {
      AppLogger.database('Verifying database integrity');

      final result = await customSelect('PRAGMA integrity_check;').get();
      final isOk = result.isNotEmpty && result.first.data['integrity_check'] == 'ok';

      if (isOk) {
        AppLogger.database('Database integrity check passed');
      } else {
        AppLogger.database('Database integrity check failed');
      }

      return isOk;
    } catch (e, stackTrace) {
      AppLogger.database('Database integrity check failed', error: e, stackTrace: stackTrace);
      return false;
    }
  }

  /// Optimize database (run VACUUM and ANALYZE)
  Future<void> optimizeDatabase() async {
    try {
      AppLogger.database('Optimizing database');

      await customStatement('VACUUM;');
      await customStatement('ANALYZE;');

      AppLogger.database('Database optimized successfully');
    } catch (e, stackTrace) {
      AppLogger.database('Database optimization failed', error: e, stackTrace: stackTrace);
      throw DatabaseConnectionException(
        'Failed to optimize database',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }
}

/// Opens a connection to the database
LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    try {
      AppLogger.database('Opening database connection');

      final dbFolder = await getApplicationDocumentsDirectory();
      final file = File(p.join(dbFolder.path, 'postpartum_recovery.sqlite'));

      AppLogger.database('Database path: ${file.path}');

      return NativeDatabase(file);
    } catch (e, stackTrace) {
      AppLogger.database('Failed to open database connection', error: e, stackTrace: stackTrace);
      throw DatabaseConnectionException(
        'Failed to open database connection',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  });
}
