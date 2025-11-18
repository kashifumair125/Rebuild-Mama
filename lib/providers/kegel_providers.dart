import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/kegel_session_state.dart';
import '../services/tts_service.dart';
import '../database/app_database.dart';
import 'kegel_session_notifier.dart';
import 'database_provider.dart';

/// TTS Service provider
final ttsServiceProvider = Provider<TTSService>((ref) {
  return TTSService();
});

/// Current Kegel session provider
final kegelSessionProvider =
    StateNotifierProvider<KegelSessionNotifier, KegelSessionState>((ref) {
  final ttsService = ref.watch(ttsServiceProvider);
  final database = ref.watch(appDatabaseProvider);

  return KegelSessionNotifier(ttsService, database);
});

/// Kegel sessions history provider
final kegelSessionsHistoryProvider = FutureProvider<List<KegelSession>>((ref) async {
  final database = ref.watch(appDatabaseProvider);
  // Using placeholder userId 1
  final userId = 1;

  return await database.kegelSessionDao.getRecentKegelSessions(userId, limit: 20);
});

/// Kegel streak provider
final kegelStreakProvider = FutureProvider<int>((ref) async {
  final database = ref.watch(appDatabaseProvider);
  // Using placeholder userId 1
  final userId = 1;

  return await database.kegelSessionDao.getKegelStreak(userId);
});

/// Kegel statistics provider
final kegelStatisticsProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final database = ref.watch(appDatabaseProvider);
  // Using placeholder userId 1
  final userId = 1;

  return await database.kegelSessionDao.getKegelStatistics(userId);
});

/// Today's sessions provider
final todayKegelSessionsProvider = StreamProvider<List<KegelSession>>((ref) {
  final database = ref.watch(appDatabaseProvider);
  // Using placeholder userId 1
  final userId = 1;

  return database.kegelSessionDao.watchTodayKegelSessions(userId);
});

/// Weekly statistics provider
final weeklyKegelStatsProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final database = ref.watch(appDatabaseProvider);
  // Using placeholder userId 1
  final userId = 1;

  return await database.kegelSessionDao.getWeeklyKegelStatistics(userId);
});

/// Monthly statistics provider
final monthlyKegelStatsProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final database = ref.watch(appDatabaseProvider);
  // Using placeholder userId 1
  final userId = 1;

  return await database.kegelSessionDao.getMonthlyKegelStatistics(userId);
});
