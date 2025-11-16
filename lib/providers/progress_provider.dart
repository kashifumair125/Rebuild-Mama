import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../database/app_database.dart';
import 'auth_provider.dart';
import 'database_provider.dart';

part 'progress_provider.g.dart';

/// Model for diastasis trend data
class DiastasisTrend {
  final List<ProgressRecord> records;
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
  final List<ProgressRecord> records;
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
@riverpod
Future<DiastasisTrend> diastasisTrend(DiastasisTrendRef ref) async {
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

  final firstValue = sortedRecords.first.value;
  final lastValue = sortedRecords.last.value;

  // Calculate average value
  final averageValue = sortedRecords.fold<double>(
        0.0,
        (sum, record) => sum + record.value,
      ) /
      sortedRecords.length;

  // Calculate improvement percentage (negative change means improvement)
  final improvementPercentage = firstValue != 0
      ? ((firstValue - lastValue) / firstValue) * 100
      : null;

  return DiastasisTrend(
    records: sortedRecords,
    averageValue: averageValue,
    improvementPercentage: improvementPercentage,
    firstRecordDate: sortedRecords.first.recordedAt,
    lastRecordDate: sortedRecords.last.recordedAt,
  );
}

/// Provider for pelvic floor progress data
/// Fetches all pelvic floor records and calculates progress
@riverpod
Future<PelvicFloorProgress> pelvicFloorProgress(
  PelvicFloorProgressRef ref,
) async {
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

  final firstValue = sortedRecords.first.value;
  final lastValue = sortedRecords.last.value;

  // Calculate average value
  final averageValue = sortedRecords.fold<double>(
        0.0,
        (sum, record) => sum + record.value,
      ) /
      sortedRecords.length;

  // Calculate improvement percentage (positive change means improvement)
  final improvementPercentage = firstValue != 0
      ? ((lastValue - firstValue) / firstValue) * 100
      : null;

  return PelvicFloorProgress(
    records: sortedRecords,
    averageValue: averageValue,
    improvementPercentage: improvementPercentage,
    firstRecordDate: sortedRecords.first.recordedAt,
    lastRecordDate: sortedRecords.last.recordedAt,
  );
}

/// Provider for overall progress summary
/// Combines data from all progress types
@riverpod
Future<ProgressSummary> progressSummary(ProgressSummaryRef ref) async {
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
}

/// Provider to get progress by date range
@riverpod
Future<List<ProgressRecord>> progressByDateRange(
  ProgressByDateRangeRef ref, {
  required String type,
  required DateTime startDate,
  required DateTime endDate,
}) async {
  final userId = ref.watch(userIdProvider);

  if (userId == null) {
    return [];
  }

  final db = ref.read(appDatabaseProvider);
  return await db.getUserProgressByDateRange(
    userId: userId,
    type: type,
    startDate: startDate,
    endDate: endDate,
  );
}

/// Stream provider for real-time diastasis progress
@riverpod
Stream<List<ProgressRecord>> diastasisProgressStream(
  DiastasisProgressStreamRef ref,
) {
  final userId = ref.watch(userIdProvider);

  if (userId == null) {
    return Stream.value([]);
  }

  final db = ref.watch(appDatabaseProvider);
  return db.watchUserProgress(userId, 'diastasis');
}

/// Stream provider for real-time pelvic floor progress
@riverpod
Stream<List<ProgressRecord>> pelvicFloorProgressStream(
  PelvicFloorProgressStreamRef ref,
) {
  final userId = ref.watch(userIdProvider);

  if (userId == null) {
    return Stream.value([]);
  }

  final db = ref.watch(appDatabaseProvider);
  return db.watchUserProgress(userId, 'pelvic_floor');
}
