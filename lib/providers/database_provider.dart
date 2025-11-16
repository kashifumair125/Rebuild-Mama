import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../database/app_database.dart';

part 'database_provider.g.dart';

/// Provider for the app database instance
/// Lazy initialized and kept alive for the lifetime of the app
@Riverpod(keepAlive: true)
AppDatabase appDatabase(AppDatabaseRef ref) {
  final database = AppDatabase();

  // Dispose the database when the provider is disposed
  ref.onDispose(() {
    database.close();
  });

  return database;
}

/// Provider for user database queries
@riverpod
AppDatabase userDatabase(UserDatabaseRef ref) {
  return ref.watch(appDatabaseProvider);
}
