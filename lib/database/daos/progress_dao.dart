import 'package:drift/drift.dart';
import '../app_database.dart';

part 'progress_dao.g.dart';

@DriftAccessor(tables: [ProgressRecords])
class ProgressDao extends DatabaseAccessor<AppDatabase> with _$ProgressDaoMixin {
  ProgressDao(AppDatabase db) : super(db);

  // ============================================================================
  // CREATE
  // ============================================================================

  /// Insert a new progress record
  Future<int> insertProgress(ProgressRecordsCompanion progress) async {
    return await into(progressRecords).insert(progress);
  }

  /// Batch insert multiple progress records
  Future<void> insertMultipleProgress(
    List<ProgressRecordsCompanion> progressList,
  ) async {
    await batch((batch) {
      batch.insertAll(progressRecords, progressList);
    });
  }

  // ============================================================================
  // READ
  // ============================================================================

  /// Get progress record by ID
  Future<Progress?> getProgressById(int progressId) async {
    return await (select(progressRecords)
          ..where((p) => p.progressId.equals(progressId)))
        .getSingleOrNull();
  }

  /// Get all progress records for a user
  Future<List<Progress>> getProgressByUserId(int userId) async {
    return await (select(progressRecords)
          ..where((p) => p.userId.equals(userId))
          ..orderBy([(p) => OrderingTerm.desc(p.recordedAt)]))
        .get();
  }

  /// Get progress records by user and type
  Future<List<Progress>> getProgressByUserAndType(
    int userId,
    String type,
  ) async {
    return await (select(progressRecords)
          ..where((p) => p.userId.equals(userId) & p.type.equals(type))
          ..orderBy([(p) => OrderingTerm.desc(p.recordedAt)]))
        .get();
  }

  /// Get diastasis recti progress
  Future<List<Progress>> getDiastasisProgress(int userId) async {
    return await getProgressByUserAndType(userId, 'diastasis');
  }

  /// Get pelvic floor progress
  Future<List<Progress>> getPelvicFloorProgress(int userId) async {
    return await getProgressByUserAndType(userId, 'pelvic_floor');
  }

  /// Get weight progress
  Future<List<Progress>> getWeightProgress(int userId) async {
    return await getProgressByUserAndType(userId, 'weight');
  }

  /// Get photo progress
  Future<List<Progress>> getPhotoProgress(int userId) async {
    return await getProgressByUserAndType(userId, 'photo');
  }

  /// Get progress records by week number
  Future<List<Progress>> getProgressByWeek(int userId, int weekNumber) async {
    return await (select(progressRecords)
          ..where(
            (p) => p.userId.equals(userId) & p.weekNumber.equals(weekNumber),
          )
          ..orderBy([(p) => OrderingTerm.desc(p.recordedAt)]))
        .get();
  }

  /// Get progress records within date range
  Future<List<Progress>> getProgressByDateRange(
    int userId,
    DateTime startDate,
    DateTime endDate, {
    String? type,
  }) async {
    final query = select(progressRecords)
      ..where((p) =>
          p.userId.equals(userId) &
          p.recordedAt.isBiggerOrEqualValue(startDate) &
          p.recordedAt.isSmallerOrEqualValue(endDate));

    if (type != null) {
      query.where((p) => p.type.equals(type));
    }

    query.orderBy([(p) => OrderingTerm.asc(p.recordedAt)]);

    return await query.get();
  }

  /// Get latest progress by type
  Future<Progress?> getLatestProgressByType(int userId, String type) async {
    return await (select(progressRecords)
          ..where((p) => p.userId.equals(userId) & p.type.equals(type))
          ..orderBy([(p) => OrderingTerm.desc(p.recordedAt)])
          ..limit(1))
        .getSingleOrNull();
  }

  /// Get initial progress by type (first record)
  Future<Progress?> getInitialProgressByType(int userId, String type) async {
    return await (select(progressRecords)
          ..where((p) => p.userId.equals(userId) & p.type.equals(type))
          ..orderBy([(p) => OrderingTerm.asc(p.recordedAt)])
          ..limit(1))
        .getSingleOrNull();
  }

  /// Watch progress for a user (reactive stream)
  Stream<List<Progress>> watchProgressByUserId(int userId) {
    return (select(progressRecords)
          ..where((p) => p.userId.equals(userId))
          ..orderBy([(p) => OrderingTerm.desc(p.recordedAt)]))
        .watch();
  }

  /// Watch progress by user and type (reactive stream)
  Stream<List<Progress>> watchProgressByUserAndType(
    int userId,
    String type,
  ) {
    return (select(progressRecords)
          ..where((p) => p.userId.equals(userId) & p.type.equals(type))
          ..orderBy([(p) => OrderingTerm.desc(p.recordedAt)]))
        .watch();
  }

  /// Watch latest progress by type
  Stream<Progress?> watchLatestProgressByType(int userId, String type) {
    return (select(progressRecords)
          ..where((p) => p.userId.equals(userId) & p.type.equals(type))
          ..orderBy([(p) => OrderingTerm.desc(p.recordedAt)])
          ..limit(1))
        .watchSingleOrNull();
  }

  /// Watch progress by week
  Stream<List<Progress>> watchProgressByWeek(int userId, int weekNumber) {
    return (select(progressRecords)
          ..where(
            (p) => p.userId.equals(userId) & p.weekNumber.equals(weekNumber),
          )
          ..orderBy([(p) => OrderingTerm.desc(p.recordedAt)]))
        .watch();
  }

  // ============================================================================
  // UPDATE
  // ============================================================================

  /// Update a progress record
  Future<bool> updateProgress(Progress progress) async {
    return await update(progressRecords).replace(progress);
  }

  /// Update progress value
  Future<int> updateProgressValue(
    int progressId,
    Map<String, dynamic>? value,
  ) async {
    return await (update(progressRecords)
          ..where((p) => p.progressId.equals(progressId)))
        .write(
      ProgressRecordsCompanion(
        value: Value(value),
      ),
    );
  }

  /// Update progress week number
  Future<int> updateWeekNumber(int progressId, int weekNumber) async {
    return await (update(progressRecords)
          ..where((p) => p.progressId.equals(progressId)))
        .write(
      ProgressRecordsCompanion(
        weekNumber: Value(weekNumber),
      ),
    );
  }

  // ============================================================================
  // DELETE
  // ============================================================================

  /// Delete a progress record
  Future<int> deleteProgress(int progressId) async {
    return await (delete(progressRecords)
          ..where((p) => p.progressId.equals(progressId)))
        .go();
  }

  /// Delete all progress for a user
  Future<int> deleteProgressByUserId(int userId) async {
    return await (delete(progressRecords)
          ..where((p) => p.userId.equals(userId)))
        .go();
  }

  /// Delete progress by type for a user
  Future<int> deleteProgressByType(int userId, String type) async {
    return await (delete(progressRecords)
          ..where((p) => p.userId.equals(userId) & p.type.equals(type)))
        .go();
  }

  /// Delete progress by week
  Future<int> deleteProgressByWeek(int userId, int weekNumber) async {
    return await (delete(progressRecords)
          ..where(
            (p) => p.userId.equals(userId) & p.weekNumber.equals(weekNumber),
          ))
        .go();
  }

  // ============================================================================
  // UTILITY
  // ============================================================================

  /// Get progress count for a user
  Future<int> getProgressCount(int userId, {String? type}) async {
    final countExp = progressRecords.progressId.count();
    final query = selectOnly(progressRecords)..addColumns([countExp]);

    query.where(progressRecords.userId.equals(userId));

    if (type != null) {
      query.where(progressRecords.type.equals(type));
    }

    final result = await query.getSingle();
    return result.read(countExp) ?? 0;
  }

  /// Get progress summary for a user
  Future<Map<String, dynamic>> getProgressSummary(int userId) async {
    final diastasisCount = await getProgressCount(userId, type: 'diastasis');
    final pelvicFloorCount = await getProgressCount(userId, type: 'pelvic_floor');
    final weightCount = await getProgressCount(userId, type: 'weight');
    final photoCount = await getProgressCount(userId, type: 'photo');

    final latestDiastasis = await getLatestProgressByType(userId, 'diastasis');
    final latestPelvicFloor = await getLatestProgressByType(userId, 'pelvic_floor');
    final latestWeight = await getLatestProgressByType(userId, 'weight');

    return {
      'diastasisRecords': diastasisCount,
      'pelvicFloorRecords': pelvicFloorCount,
      'weightRecords': weightCount,
      'photoRecords': photoCount,
      'totalRecords': diastasisCount + pelvicFloorCount + weightCount + photoCount,
      'latestDiastasis': latestDiastasis?.toJson(),
      'latestPelvicFloor': latestPelvicFloor?.toJson(),
      'latestWeight': latestWeight?.toJson(),
    };
  }

  /// Get progress trend (improvement or regression)
  Future<Map<String, dynamic>> getProgressTrend(
    int userId,
    String type,
  ) async {
    final initial = await getInitialProgressByType(userId, type);
    final latest = await getLatestProgressByType(userId, type);

    if (initial == null || latest == null) {
      return {
        'hasTrend': false,
        'message': 'Not enough data to calculate trend',
      };
    }

    return {
      'hasTrend': true,
      'initialValue': initial.value,
      'latestValue': latest.value,
      'initialDate': initial.recordedAt,
      'latestDate': latest.recordedAt,
      'initialWeek': initial.weekNumber,
      'latestWeek': latest.weekNumber,
      'weeksDifference': latest.weekNumber - initial.weekNumber,
    };
  }

  /// Get progress with pagination
  Future<List<Progress>> getProgressPaginated(
    int userId, {
    int page = 0,
    int pageSize = 10,
    String? type,
  }) async {
    final query = select(progressRecords)
      ..where((p) => p.userId.equals(userId))
      ..orderBy([(p) => OrderingTerm.desc(p.recordedAt)])
      ..limit(pageSize, offset: page * pageSize);

    if (type != null) {
      query.where((p) => p.type.equals(type));
    }

    return await query.get();
  }

  /// Get weekly progress summary
  Future<Map<int, List<Progress>>> getWeeklyProgressSummary(
    int userId, {
    String? type,
  }) async {
    List<Progress> records;
    if (type != null) {
      records = await getProgressByUserAndType(userId, type);
    } else {
      records = await getProgressByUserId(userId);
    }

    final weeklyMap = <int, List<Progress>>{};
    for (final record in records) {
      if (!weeklyMap.containsKey(record.weekNumber)) {
        weeklyMap[record.weekNumber] = [];
      }
      weeklyMap[record.weekNumber]!.add(record);
    }

    return weeklyMap;
  }

  /// Get progress statistics by type
  Future<Map<String, dynamic>> getProgressStatisticsByType(
    int userId,
    String type,
  ) async {
    final allProgress = await getProgressByUserAndType(userId, type);

    if (allProgress.isEmpty) {
      return {
        'count': 0,
        'hasData': false,
      };
    }

    final weeks = allProgress.map((p) => p.weekNumber).toSet().toList()..sort();
    final minWeek = weeks.first;
    final maxWeek = weeks.last;

    return {
      'count': allProgress.length,
      'hasData': true,
      'minWeek': minWeek,
      'maxWeek': maxWeek,
      'weeksTracked': weeks.length,
      'firstRecordDate': allProgress.last.recordedAt,
      'latestRecordDate': allProgress.first.recordedAt,
    };
  }
}
