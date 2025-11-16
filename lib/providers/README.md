# Riverpod Providers Documentation

This directory contains all the Riverpod providers for the Postpartum Recovery App. The providers use Riverpod code generation for type safety and better developer experience.

## Provider Files

### 1. `auth_provider.dart`
Manages user authentication state using Firebase Auth.

**Providers:**
- `firebaseAuthProvider` - Firebase Auth instance
- `currentUserProvider` (StreamProvider) - Stream of current user state
- `isUserLoggedInProvider` - Boolean indicating if user is logged in
- `userIdProvider` - Current user's ID (null if not logged in)
- `authServiceProvider` - Authentication service for sign in/up/out operations

**Usage Example:**
```dart
// Watch authentication state
final isLoggedIn = ref.watch(isUserLoggedInProvider);

// Get current user ID
final userId = ref.watch(userIdProvider);

// Sign in
final authService = ref.read(authServiceProvider);
await authService.signInWithEmail(
  email: 'user@example.com',
  password: 'password',
);
```

### 2. `database_provider.dart`
Provides access to the Drift database instance.

**Providers:**
- `appDatabaseProvider` (keepAlive) - Single instance of AppDatabase
- `userDatabaseProvider` - Access to database queries

**Usage Example:**
```dart
// Get database instance
final db = ref.read(appDatabaseProvider);

// Watch user workouts
final workouts = await db.watchUserWorkouts(userId).first;
```

### 3. `preferences_provider.dart`
Manages app preferences using SharedPreferences.

**Providers:**
- `sharedPreferencesProvider` - SharedPreferences instance
- `languageProvider` - User's language preference
- `notificationsEnabledProvider` - Notifications enabled state
- `darkModeProvider` - Dark mode enabled state
- Helper providers for synchronous access

**Usage Example:**
```dart
// Watch dark mode state
final isDarkMode = ref.watch(isDarkModeEnabledProvider);

// Toggle dark mode
final darkModeNotifier = ref.read(darkModeProvider.notifier);
await darkModeNotifier.toggle();

// Set language
final languageNotifier = ref.read(languageProvider.notifier);
await languageNotifier.setLanguage('ar');
```

### 4. `workout_provider.dart`
Manages workout state and statistics.

**Providers:**
- `userCurrentLevelProvider` (StreamProvider) - User's workout level (0-3)
- `currentWorkoutSessionProvider` - Current workout session state
- `workoutProgressProvider` (StreamProvider) - User's workout history
- `workoutStatsProvider` - Workout statistics (streaks, totals)
- `userLevelProvider` - Update user's workout level

**Usage Example:**
```dart
// Watch current level
final level = ref.watch(userCurrentLevelProvider);

// Start a workout
final workoutSession = ref.read(currentWorkoutSessionProvider.notifier);
workoutSession.startWorkout(
  level: 1,
  exerciseIds: ['exercise1', 'exercise2'],
);

// Complete workout
await workoutSession.completeWorkout();

// Get statistics
final stats = await ref.read(workoutStatsProvider.future);
print('Total workouts: ${stats.totalWorkouts}');
print('Current streak: ${stats.currentStreak} days');
```

### 5. `progress_provider.dart`
Tracks user progress for diastasis and pelvic floor recovery.

**Providers:**
- `diastasisTrendProvider` - Diastasis recti trend data
- `pelvicFloorProgressProvider` - Pelvic floor progress data
- `progressSummaryProvider` - Overall progress summary
- `progressByDateRangeProvider` - Get progress within date range
- Stream providers for real-time updates

**Usage Example:**
```dart
// Watch diastasis trend
final diastasisTrend = ref.watch(diastasisTrendProvider);

diastasisTrend.when(
  data: (trend) {
    print('Average: ${trend.averageValue}');
    print('Improvement: ${trend.improvementPercentage}%');
  },
  loading: () => CircularProgressIndicator(),
  error: (error, stack) => Text('Error: $error'),
);

// Get progress by date range
final progress = await ref.read(
  progressByDateRangeProvider(
    type: 'diastasis',
    startDate: DateTime(2024, 1, 1),
    endDate: DateTime.now(),
  ).future,
);
```

### 6. `notification_provider.dart`
Handles local notifications and reminders.

**Providers:**
- `notificationPluginProvider` - FlutterLocalNotificationsPlugin instance
- `notificationServiceProvider` - Notification service
- `workoutReminderSchedulerProvider` - Schedule workout reminders
- `progressReminderSchedulerProvider` - Schedule progress check reminders

**Usage Example:**
```dart
// Schedule daily workout reminder
final reminderScheduler = ref.read(
  workoutReminderSchedulerProvider.notifier,
);

await reminderScheduler.scheduleDailyReminder(
  hour: 9,
  minute: 0,
);

// Schedule weekly progress check
final progressScheduler = ref.read(
  progressReminderSchedulerProvider.notifier,
);

await progressScheduler.scheduleWeeklyReminder(
  day: Day.sunday,
  hour: 10,
  minute: 0,
);

// Show immediate notification
final notificationService = ref.read(notificationServiceProvider);
await notificationService.showNotification(
  id: 100,
  title: 'Great Job!',
  body: 'You completed your workout!',
  type: NotificationType.workout,
);
```

## Code Generation

This project uses Riverpod code generation. After making changes to provider files, run:

```bash
# Watch for changes and regenerate automatically
flutter pub run build_runner watch --delete-conflicting-outputs

# Or generate once
flutter pub run build_runner build --delete-conflicting-outputs
```

## Testing

All providers can be easily overridden in tests using `ProviderContainer`. See `test/providers/provider_test_utils.dart` for helper functions.

**Example Test:**
```dart
import 'package:flutter_test/flutter_test.dart';
import 'provider_test_utils.dart';

void main() {
  test('example provider test', () async {
    final mockUser = createMockUser(uid: 'test-123');

    final container = createTestProviderContainer(
      currentUser: mockUser,
    );

    final userId = container.read(userIdProvider);
    expect(userId, 'test-123');

    disposeTestContainer(container);
  });
}
```

## Best Practices

1. **Use `ref.watch()` for reactive updates** - When you want the widget to rebuild on state changes
2. **Use `ref.read()` for one-time reads** - When you just need the current value
3. **Use `ref.listen()` for side effects** - When you want to show a snackbar, navigate, etc.
4. **Implement `.autoDispose`** - Providers are auto-disposed by default in generated code
5. **Handle AsyncValue states** - Always use `.when()` or check `.hasValue`, `.isLoading`, `.hasError`
6. **Keep providers focused** - Each provider should have a single responsibility
7. **Use code generation** - Always use `@riverpod` annotation for type safety

## Provider Dependencies

Providers can watch other providers to create derived state:

```dart
@riverpod
Future<WorkoutStats> workoutStats(WorkoutStatsRef ref) async {
  final userId = ref.watch(userIdProvider);
  // ... use userId to fetch stats
}
```

## Error Handling

All async providers use `AsyncValue` which provides built-in error handling:

```dart
final progressAsync = ref.watch(progressSummaryProvider);

progressAsync.when(
  data: (summary) => Text('${summary.totalRecords} records'),
  loading: () => CircularProgressIndicator(),
  error: (error, stack) => Text('Error: $error'),
);
```

## Memory Management

- Use `@Riverpod(keepAlive: true)` for providers that should never be disposed (like database)
- Most providers auto-dispose when no longer used
- Manually dispose resources in `ref.onDispose()`

## Further Reading

- [Riverpod Documentation](https://riverpod.dev)
- [Code Generation Guide](https://riverpod.dev/docs/concepts/about_code_generation)
- [Testing Providers](https://riverpod.dev/docs/cookbooks/testing)
