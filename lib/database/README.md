# Drift Database Implementation

This directory contains the complete Drift database implementation for the Postpartum Recovery App.

## Overview

The database uses Drift (formerly Moor) for offline-first data persistence with SQLite. It includes comprehensive CRUD operations, reactive streams, and optimized queries.

## Database Schema

### Tables

1. **users** - User profile and authentication data
   - `userId` (PRIMARY KEY)
   - `name`, `email`, `passwordHash`
   - `deliveryType` (vaginal/c_section)
   - `weeksPostpartum`
   - `createdAt`, `updatedAt`

2. **assessments** - Pelvic floor and diastasis recti assessments
   - `assessmentId` (PRIMARY KEY)
   - `userId` (FOREIGN KEY → users)
   - `type` (pelvic_floor/diastasis_recti)
   - `questions` (JSON)
   - `answers` (JSON)
   - `classification` (weak/moderate/strong)
   - `createdAt`

3. **workouts** - Workout programs
   - `workoutId` (PRIMARY KEY)
   - `userId` (FOREIGN KEY → users)
   - `level` (1/2/3)
   - `name`, `description`
   - `durationMinutes`
   - `isCompleted`, `completedAt`

4. **exercises** - Individual exercises for workouts
   - `exerciseId` (PRIMARY KEY)
   - `workoutId` (FOREIGN KEY → workouts)
   - `exerciseName`, `description`
   - `animationPath` (Lottie JSON file path)
   - `setsReps` (e.g., "3x10")
   - `durationSeconds`
   - `orderIndex`

5. **progress_records** - User progress tracking
   - `progressId` (PRIMARY KEY)
   - `userId` (FOREIGN KEY → users)
   - `type` (diastasis/pelvic_floor/weight/photo)
   - `value` (JSON for complex data)
   - `recordedAt`
   - `weekNumber`

6. **kegel_sessions** - Kegel exercise tracking
   - `sessionId` (PRIMARY KEY)
   - `userId` (FOREIGN KEY → users)
   - `durationMinutes`
   - `repsCompleted`
   - `startedAt`, `endedAt`

## Data Access Objects (DAOs)

Each table has a dedicated DAO with comprehensive methods:

### UserDao (`lib/database/daos/user_dao.dart`)
- CRUD operations for users
- Email validation and lookup
- User statistics and filtering
- Reactive streams with `.watch()`

### AssessmentDao (`lib/database/daos/assessment_dao.dart`)
- Assessment management
- Classification tracking
- Assessment history and comparison
- Improvement calculation

### WorkoutDao (`lib/database/daos/workout_dao.dart`)
- Workout management by level
- Completion tracking
- Workout statistics and analytics
- Next workout suggestions

### ExerciseDao (`lib/database/daos/exercise_dao.dart`)
- Exercise CRUD operations
- Order management and reordering
- Exercise navigation (next/previous)
- Join queries with workouts

### ProgressDao (`lib/database/daos/progress_dao.dart`)
- Progress tracking by type
- Trend analysis
- Weekly summaries
- Progress statistics

### KegelSessionDao (`lib/database/daos/kegel_session_dao.dart`)
- Session tracking
- Daily/weekly/monthly statistics
- Streak calculation
- Average metrics

## Setup Instructions

### 1. Generate Database Code

Run the following command to generate Drift code:

```bash
dart run build_runner build --delete-conflicting-outputs
```

Or for continuous generation during development:

```bash
dart run build_runner watch --delete-conflicting-outputs
```

### 2. Initialize Database

The database uses a singleton pattern and is automatically initialized on first use:

```dart
final database = AppDatabase();
```

### 3. Access DAOs

Access DAOs through the database instance:

```dart
final database = AppDatabase();

// Example: Insert a user
await database.userDao.insertUser(
  UsersCompanion.insert(
    name: 'Jane Doe',
    email: 'jane@example.com',
    passwordHash: hashedPassword,
    deliveryType: 'vaginal',
    weeksPostpartum: 6,
  ),
);

// Example: Watch workouts
database.workoutDao.watchWorkoutsByLevel(userId, 1).listen((workouts) {
  print('Level 1 workouts: ${workouts.length}');
});
```

## Features

### 1. Foreign Key Constraints
- All foreign keys are properly defined
- Cascade deletion enabled where appropriate
- Foreign key constraints enforced via PRAGMA

### 2. Indexes
Performance indexes created for:
- `assessments(user_id, type)`
- `workouts(user_id, level)`
- `exercises(workout_id, order_index)`
- `progress_records(user_id, type)`
- `progress_records(user_id, week_number)`
- `kegel_sessions(user_id, started_at)`

### 3. JSON Type Converters
Custom converters for storing complex data:
- `JsonMapConverter` - for Map<String, dynamic>
- `JsonListConverter` - for List<dynamic>
- `NullableJsonMapConverter` - for nullable maps

### 4. Reactive Streams
All DAOs support reactive programming with `.watch()` methods that return streams:
- Real-time UI updates
- Automatic data synchronization
- No manual refresh needed

### 5. Pagination
Most query methods support pagination:
- `page` and `pageSize` parameters
- Efficient data loading
- Memory optimization

### 6. Statistics and Analytics
Comprehensive analytics methods:
- Workout completion percentages
- Progress trends
- Kegel streaks
- Weekly/monthly summaries

## Migration Strategy

### Current Version: 1

The database is set up to support migrations:

```dart
onUpgrade: (Migrator m, int from, int to) async {
  // Example migration from v1 to v2:
  // if (from < 2) {
  //   await m.addColumn(users, users.newColumn);
  // }
}
```

### Adding Migrations

1. Update `schemaVersion` in `AppDatabase`
2. Add migration logic in `onUpgrade`
3. Test thoroughly before deploying

## Database Utilities

### Delete Database
```dart
await AppDatabase.deleteDatabase();
```

### Close Connection
```dart
await database.closeDatabase();
```

## Best Practices

1. **Always use Companions for inserts/updates**
   ```dart
   UsersCompanion.insert(/* fields */)
   ```

2. **Use streams for reactive UI**
   ```dart
   StreamBuilder(
     stream: database.workoutDao.watchWorkoutsByLevel(userId, 1),
     builder: (context, snapshot) { /* UI */ },
   )
   ```

3. **Leverage transactions for related operations**
   ```dart
   await database.transaction(() async {
     await database.userDao.insertUser(user);
     await database.assessmentDao.insertAssessment(assessment);
   });
   ```

4. **Use pagination for large datasets**
   ```dart
   final workouts = await database.workoutDao.getWorkoutsPaginated(
     userId,
     page: 0,
     pageSize: 20,
   );
   ```

## Testing

Create a test database for unit tests:

```dart
AppDatabase createTestDatabase() {
  return AppDatabase.testConstructor(
    NativeDatabase.memory(),
  );
}
```

## Troubleshooting

### Build Runner Issues
```bash
# Clean build cache
dart run build_runner clean

# Rebuild with delete conflicting outputs
dart run build_runner build --delete-conflicting-outputs
```

### Database Locked
Ensure proper connection closing:
```dart
await database.closeDatabase();
```

### Foreign Key Violations
Check that parent records exist before inserting child records.

## Performance Tips

1. Use indexes for frequently queried columns
2. Leverage batch operations for bulk inserts
3. Use `select().get()` for one-time queries
4. Use `select().watch()` for reactive UI
5. Implement pagination for long lists
6. Close database connections when not needed

## Security Considerations

1. **Password Hashing**: Always hash passwords before storing
2. **Sensitive Data**: Consider using `flutter_secure_storage` for tokens
3. **SQL Injection**: Drift protects against SQL injection automatically
4. **Encryption**: For production, consider encrypting the database file

## Additional Resources

- [Drift Documentation](https://drift.simonbinder.eu/)
- [SQLite Documentation](https://www.sqlite.org/docs.html)
- [Riverpod Integration](https://riverpod.dev/)
