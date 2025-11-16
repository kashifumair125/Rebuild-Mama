import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

part 'app_database.g.dart';

// User table for storing user profile data
class Users extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get firebaseUid => text().unique()();
  TextColumn get email => text()();
  TextColumn get name => text().nullable()();
  IntColumn get currentLevel => integer().withDefault(const Constant(0))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
}

// Workout sessions table
class WorkoutSessions extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get userId => text()();
  IntColumn get level => integer()();
  IntColumn get duration => integer()(); // in seconds
  BoolColumn get completed => boolean().withDefault(const Constant(false))();
  DateTimeColumn get startedAt => dateTime()();
  DateTimeColumn get completedAt => dateTime().nullable()();
}

// Progress tracking table
class ProgressRecords extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get userId => text()();
  TextColumn get type => text()(); // 'diastasis' or 'pelvic_floor'
  RealColumn get value => real()();
  TextColumn get notes => text().nullable()();
  DateTimeColumn get recordedAt => dateTime().withDefault(currentDateAndTime)();
}

// Exercise completion tracking
class ExerciseCompletions extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get userId => text()();
  TextColumn get exerciseId => text()();
  IntColumn get repetitions => integer()();
  IntColumn get duration => integer()(); // in seconds
  DateTimeColumn get completedAt => dateTime().withDefault(currentDateAndTime)();
}

@DriftDatabase(tables: [
  Users,
  WorkoutSessions,
  ProgressRecords,
  ExerciseCompletions,
])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (Migrator m) async {
        await m.createAll();
      },
      onUpgrade: (Migrator m, int from, int to) async {
        // Add migration logic here when schema changes
      },
    );
  }

  // User queries
  Future<User?> getUserByFirebaseUid(String firebaseUid) {
    return (select(users)..where((u) => u.firebaseUid.equals(firebaseUid)))
        .getSingleOrNull();
  }

  Future<int> insertUser(UsersCompanion user) {
    return into(users).insert(user);
  }

  Future<bool> updateUser(User user) {
    return update(users).replace(user);
  }

  // Workout queries
  Stream<List<WorkoutSession>> watchUserWorkouts(String userId) {
    return (select(workoutSessions)
          ..where((w) => w.userId.equals(userId))
          ..orderBy([(w) => OrderingTerm.desc(w.startedAt)]))
        .watch();
  }

  Future<int> insertWorkoutSession(WorkoutSessionsCompanion session) {
    return into(workoutSessions).insert(session);
  }

  Future<bool> updateWorkoutSession(WorkoutSession session) {
    return update(workoutSessions).replace(session);
  }

  // Progress queries
  Stream<List<ProgressRecord>> watchUserProgress(String userId, String type) {
    return (select(progressRecords)
          ..where((p) => p.userId.equals(userId) & p.type.equals(type))
          ..orderBy([(p) => OrderingTerm.desc(p.recordedAt)]))
        .watch();
  }

  Future<List<ProgressRecord>> getUserProgressByDateRange({
    required String userId,
    required String type,
    required DateTime startDate,
    required DateTime endDate,
  }) {
    return (select(progressRecords)
          ..where((p) =>
              p.userId.equals(userId) &
              p.type.equals(type) &
              p.recordedAt.isBiggerOrEqualValue(startDate) &
              p.recordedAt.isSmallerOrEqualValue(endDate))
          ..orderBy([(p) => OrderingTerm.asc(p.recordedAt)]))
        .get();
  }

  Future<int> insertProgressRecord(ProgressRecordsCompanion record) {
    return into(progressRecords).insert(record);
  }

  // Exercise completion queries
  Future<int> insertExerciseCompletion(ExerciseCompletionsCompanion completion) {
    return into(exerciseCompletions).insert(completion);
  }

  Stream<List<ExerciseCompletion>> watchUserExerciseCompletions(String userId) {
    return (select(exerciseCompletions)
          ..where((e) => e.userId.equals(userId))
          ..orderBy([(e) => OrderingTerm.desc(e.completedAt)]))
        .watch();
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'postpartum_app.sqlite'));
    return NativeDatabase(file);
  });
}
