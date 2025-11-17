import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../database/app_database.dart';
import 'auth_provider.dart';
import 'database_provider.dart';

// Temporary provider for userId - maps to local database user
// TODO: Implement proper Firebase UID to local userId mapping
final userIdProvider = Provider<int?>((ref) {
  // For now, return a mock user ID of 1
  // In production, this should look up the local user ID from Firebase UID
  return 1;
});

/// Model for diastasis trend data
class DiastasisTrend {
  final List<Progress> records;
  final double? averageValue;
  final double? improvementPercentage;
  final DateTime? firstRecordDate;
  final DateTime? lastRecordDate;

  const DiastasisTrend({
    required this.records,
    this.averageValue,
    this.improvementPercentage,
    this.firstRecordDate,
    this.lastRecordDate,
  });
}

/// Model for pelvic floor progress
class PelvicFloorProgress {
  final List<Progress> records;
  final double? averageValue;
  final double? improvementPercentage;
  final DateTime? firstRecordDate;
  final DateTime? lastRecordDate;

  const PelvicFloorProgress({
    required this.records,
    this.averageValue,
    this.improvementPercentage,
    this.firstRecordDate,
    this.lastRecordDate,
  });
}

/// Model for progress summary
class ProgressSummary {
  final int totalRecords;
  final int diastasisRecords;
  final int pelvicFloorRecords;
  final double? overallImprovement;
  final DateTime? lastRecordDate;

  const ProgressSummary({
    required this.totalRecords,
    required this.diastasisRecords,
    required this.pelvicFloorRecords,
    this.overallImprovement,
    this.lastRecordDate,
  });
}

/// Provider for diastasis recti trend data
/// Fetches all diastasis records and calculates trends
final diastasisTrendProvider = FutureProvider<DiastasisTrend>((ref) async {
  final userId = ref.watch(userIdProvider);

  if (userId == null) {
    return const DiastasisTrend(records: []);
  }

  final db = ref.read(appDatabaseProvider);
  final records = await db
      .watchUserProgress(userId, 'diastasis')
      .first;

  if (records.isEmpty) {
    return const DiastasisTrend(records: []);
  }

  // Sort by date (oldest first for trend calculation)
  final sortedRecords = records.toList()
    ..sort((a, b) => a.recordedAt.compareTo(b.recordedAt));

  // Extract numeric values from the map (gap width for diastasis)
  final firstValue = sortedRecords.first.value?['gap'] as num?;
  final lastValue = sortedRecords.last.value?['gap'] as num?;

  // Calculate average value
  final averageValue = sortedRecords.fold<double>(
        0.0,
        (sum, record) {
          final value = record.value?['gap'] as num?;
          return sum + (value?.toDouble() ?? 0.0);
        },
      ) /
      sortedRecords.length;

  // Calculate improvement percentage (negative change means improvement)
  final improvementPercentage = (firstValue != null && firstValue != 0 && lastValue != null)
      ? ((firstValue - lastValue) / firstValue) * 100
      : null;

  return DiastasisTrend(
    records: sortedRecords,
    averageValue: averageValue,
    improvementPercentage: improvementPercentage,
    firstRecordDate: sortedRecords.first.recordedAt,
    lastRecordDate: sortedRecords.last.recordedAt,
  );
});

/// Provider for pelvic floor progress data
/// Fetches all pelvic floor records and calculates progress
final pelvicFloorProgressProvider = FutureProvider<PelvicFloorProgress>((ref) async {
  final userId = ref.watch(userIdProvider);

  if (userId == null) {
    return const PelvicFloorProgress(records: []);
  }

  final db = ref.read(appDatabaseProvider);
  final records = await db
      .watchUserProgress(userId, 'pelvic_floor')
      .first;

  if (records.isEmpty) {
    return const PelvicFloorProgress(records: []);
  }

  // Sort by date (oldest first)
  final sortedRecords = records.toList()
    ..sort((a, b) => a.recordedAt.compareTo(b.recordedAt));

  // Extract numeric values from the map (strength for pelvic floor)
  final firstValue = sortedRecords.first.value?['strength'] as num?;
  final lastValue = sortedRecords.last.value?['strength'] as num?;

  // Calculate average value
  final averageValue = sortedRecords.fold<double>(
        0.0,
        (sum, record) {
          final value = record.value?['strength'] as num?;
          return sum + (value?.toDouble() ?? 0.0);
        },
      ) /
      sortedRecords.length;

  // Calculate improvement percentage (positive change means improvement)
  final improvementPercentage = (firstValue != null && firstValue != 0 && lastValue != null)
      ? ((lastValue - firstValue) / firstValue) * 100
      : null;

  return PelvicFloorProgress(
    records: sortedRecords,
    averageValue: averageValue,
    improvementPercentage: improvementPercentage,
    firstRecordDate: sortedRecords.first.recordedAt,
    lastRecordDate: sortedRecords.last.recordedAt,
  );
});

/// Provider for overall progress summary
/// Combines data from all progress types
final progressSummaryProvider = FutureProvider<ProgressSummary>((ref) async {
  final userId = ref.watch(userIdProvider);

  if (userId == null) {
    return const ProgressSummary(
      totalRecords: 0,
      diastasisRecords: 0,
      pelvicFloorRecords: 0,
    );
  }

  final diastasisTrendAsync = await ref.watch(diastasisTrendProvider.future);
  final pelvicFloorProgressAsync =
      await ref.watch(pelvicFloorProgressProvider.future);

  final diastasisCount = diastasisTrendAsync.records.length;
  final pelvicFloorCount = pelvicFloorProgressAsync.records.length;
  final totalRecords = diastasisCount + pelvicFloorCount;

  // Calculate overall improvement
  double? overallImprovement;
  if (diastasisTrendAsync.improvementPercentage != null &&
      pelvicFloorProgressAsync.improvementPercentage != null) {
    overallImprovement =
        (diastasisTrendAsync.improvementPercentage! +
            pelvicFloorProgressAsync.improvementPercentage!) /
            2;
  } else if (diastasisTrendAsync.improvementPercentage != null) {
    overallImprovement = diastasisTrendAsync.improvementPercentage;
  } else if (pelvicFloorProgressAsync.improvementPercentage != null) {
    overallImprovement = pelvicFloorProgressAsync.improvementPercentage;
  }

  // Find most recent record date
  DateTime? lastRecordDate;
  final diastasisLast = diastasisTrendAsync.lastRecordDate;
  final pelvicFloorLast = pelvicFloorProgressAsync.lastRecordDate;

  if (diastasisLast != null && pelvicFloorLast != null) {
    lastRecordDate = diastasisLast.isAfter(pelvicFloorLast)
        ? diastasisLast
        : pelvicFloorLast;
  } else if (diastasisLast != null) {
    lastRecordDate = diastasisLast;
  } else if (pelvicFloorLast != null) {
    lastRecordDate = pelvicFloorLast;
  }

  return ProgressSummary(
    totalRecords: totalRecords,
    diastasisRecords: diastasisCount,
    pelvicFloorRecords: pelvicFloorCount,
    overallImprovement: overallImprovement,
    lastRecordDate: lastRecordDate,
  );
});

/// Parameter class for progress by date range provider
class ProgressByDateRangeParams {
  final String type;
  final DateTime startDate;
  final DateTime endDate;

  const ProgressByDateRangeParams({
    required this.type,
    required this.startDate,
    required this.endDate,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProgressByDateRangeParams &&
          runtimeType == other.runtimeType &&
          type == other.type &&
          startDate == other.startDate &&
          endDate == other.endDate;

  @override
  int get hashCode => type.hashCode ^ startDate.hashCode ^ endDate.hashCode;
}

/// Provider to get progress by date range
final progressByDateRangeProvider = FutureProvider.family<List<Progress>, ProgressByDateRangeParams>((ref, params) async {
  final userId = ref.watch(userIdProvider);

  if (userId == null) {
    return [];
  }

  final db = ref.read(appDatabaseProvider);
  return await db.getUserProgressByDateRange(
    userId: userId,
    type: params.type,
    startDate: params.startDate,
    endDate: params.endDate,
  );
});

/// Stream provider for real-time diastasis progress
final diastasisProgressStreamProvider = StreamProvider<List<Progress>>((ref) {
  final userId = ref.watch(userIdProvider);

  if (userId == null) {
    return Stream.value([]);
  }

  final db = ref.watch(appDatabaseProvider);
  return db.watchUserProgress(userId, 'diastasis');
});

/// Stream provider for real-time pelvic floor progress
final pelvicFloorProgressStreamProvider = StreamProvider<List<Progress>>((ref) {
  final userId = ref.watch(userIdProvider);

  if (userId == null) {
    return Stream.value([]);
  }

  final db = ref.watch(appDatabaseProvider);
  return db.watchUserProgress(userId, 'pelvic_floor');
});

/// Model for workout streak data
class WorkoutStreak {
  final int currentStreak;
  final int longestStreak;
  final bool workedOutToday;

  const WorkoutStreak({
    required this.currentStreak,
    required this.longestStreak,
    required this.workedOutToday,
  });
}

/// Provider for workout streak calculation
final workoutStreakProvider = FutureProvider<WorkoutStreak>((ref) async {
  final userId = ref.watch(userIdProvider);

  if (userId == null) {
    return const WorkoutStreak(
      currentStreak: 0,
      longestStreak: 0,
      workedOutToday: false,
    );
  }

  final db = ref.read(appDatabaseProvider);
  final currentStreak = await db.workoutSessionDao.calculateWorkoutStreak(userId);
  final longestStreak = await db.workoutSessionDao.getLongestStreak(userId);
  final workedOutToday = await db.workoutSessionDao.hasWorkedOutToday(userId);

  return WorkoutStreak(
    currentStreak: currentStreak,
    longestStreak: longestStreak,
    workedOutToday: workedOutToday,
  );
});

/// Model for weekly workout statistics
class WeeklyWorkoutStats {
  final int workoutsThisWeek;
  final int totalTime;
  final int caloriesBurned;
  final int totalWorkouts;

  const WeeklyWorkoutStats({
    required this.workoutsThisWeek,
    required this.totalTime,
    required this.caloriesBurned,
    required this.totalWorkouts,
  });
}

/// Provider for weekly workout completion statistics
final weeklyWorkoutStatsProvider = FutureProvider<WeeklyWorkoutStats>((ref) async {
  final userId = ref.watch(userIdProvider);

  if (userId == null) {
    return const WeeklyWorkoutStats(
      workoutsThisWeek: 0,
      totalTime: 0,
      caloriesBurned: 0,
      totalWorkouts: 0,
    );
  }

  final db = ref.read(appDatabaseProvider);

  // Get this week's sessions
  final now = DateTime.now();
  final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
  final startOfWeekDate = DateTime(startOfWeek.year, startOfWeek.month, startOfWeek.day);
  final endOfWeek = DateTime(now.year, now.month, now.day, 23, 59, 59);

  final weekSessions = await db.workoutSessionDao.getWorkoutSessionsByDateRange(
    userId,
    startOfWeekDate,
    endOfWeek,
  );

  final completedThisWeek = weekSessions.where((s) => s.isCompleted).length;
  final timeThisWeek = weekSessions
      .where((s) => s.isCompleted)
      .fold<int>(0, (sum, s) => sum + s.durationMinutes);
  final caloriesThisWeek = weekSessions
      .where((s) => s.isCompleted && s.caloriesBurned != null)
      .fold<int>(0, (sum, s) => sum + (s.caloriesBurned ?? 0));

  final stats = await db.workoutSessionDao.getWorkoutSessionStatistics(userId);
  final totalWorkouts = stats['completedSessions'] as int;

  return WeeklyWorkoutStats(
    workoutsThisWeek: completedThisWeek,
    totalTime: timeThisWeek,
    caloriesBurned: caloriesThisWeek,
    totalWorkouts: totalWorkouts,
  );
});

/// Model for achievements
class Achievement {
  final String id;
  final String title;
  final String description;
  final String icon;
  final bool isUnlocked;
  final int progress;
  final int target;

  const Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.isUnlocked,
    required this.progress,
    required this.target,
  });
}

/// Provider for user achievements
final achievementsProvider = FutureProvider<List<Achievement>>((ref) async {
  final userId = ref.watch(userIdProvider);

  if (userId == null) {
    return [];
  }

  final db = ref.read(appDatabaseProvider);
  final stats = await db.workoutSessionDao.getWorkoutSessionStatistics(userId);
  final streak = await db.workoutSessionDao.calculateWorkoutStreak(userId);

  final completedSessions = stats['completedSessions'] as int;
  final totalTime = stats['totalWorkoutTime'] as int;

  return [
    Achievement(
      id: 'first_workout',
      title: 'First Workout',
      description: 'Complete your first workout',
      icon: '🎯',
      isUnlocked: completedSessions >= 1,
      progress: completedSessions >= 1 ? 1 : 0,
      target: 1,
    ),
    Achievement(
      id: '1_week_streak',
      title: '1-Week Streak',
      description: 'Workout for 7 days in a row',
      icon: '🔥',
      isUnlocked: streak >= 7,
      progress: streak >= 7 ? 7 : streak,
      target: 7,
    ),
    Achievement(
      id: '50_total_workouts',
      title: '50 Total Workouts',
      description: 'Complete 50 workout sessions',
      icon: '💪',
      isUnlocked: completedSessions >= 50,
      progress: completedSessions >= 50 ? 50 : completedSessions,
      target: 50,
    ),
    Achievement(
      id: '100_workouts',
      title: '100 Workouts',
      description: 'Complete 100 workout sessions',
      icon: '🏆',
      isUnlocked: completedSessions >= 100,
      progress: completedSessions >= 100 ? 100 : completedSessions,
      target: 100,
    ),
    Achievement(
      id: '10_hours',
      title: '10 Hours Strong',
      description: 'Complete 10 hours of workouts',
      icon: '⏱️',
      isUnlocked: totalTime >= 600,
      progress: totalTime >= 600 ? 600 : totalTime,
      target: 600,
    ),
  ];
});

/// Provider for photo progress
final photoProgressProvider = FutureProvider<List<Progress>>((ref) async {
  final userId = ref.watch(userIdProvider);

  if (userId == null) {
    return [];
  }

  final db = ref.read(appDatabaseProvider);
  return await db.progressDao.getPhotoProgress(userId);
});
