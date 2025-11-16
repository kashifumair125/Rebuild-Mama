import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mockito/mockito.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:rebuild_mama/database/app_database.dart';
import 'package:rebuild_mama/providers/auth_provider.dart';
import 'package:rebuild_mama/providers/database_provider.dart';
import 'package:rebuild_mama/providers/preferences_provider.dart';
import 'package:rebuild_mama/providers/notification_provider.dart';

// Mock classes for testing
class MockFirebaseAuth extends Mock implements FirebaseAuth {}

class MockUser extends Mock implements User {}

class MockAppDatabase extends Mock implements AppDatabase {}

class MockSharedPreferences extends Mock implements SharedPreferences {}

class MockFlutterLocalNotificationsPlugin extends Mock
    implements FlutterLocalNotificationsPlugin {}

/// Create a ProviderContainer for testing with mock providers
ProviderContainer createTestProviderContainer({
  FirebaseAuth? firebaseAuth,
  AppDatabase? database,
  SharedPreferences? sharedPreferences,
  FlutterLocalNotificationsPlugin? notificationPlugin,
  User? currentUser,
}) {
  final container = ProviderContainer(
    overrides: [
      // Override Firebase Auth
      if (firebaseAuth != null)
        firebaseAuthProvider.overrideWithValue(firebaseAuth),

      // Override current user stream
      if (currentUser != null)
        currentUserProvider.overrideWith((ref) => Stream.value(currentUser)),

      // Override database
      if (database != null)
        appDatabaseProvider.overrideWithValue(database),

      // Override shared preferences
      if (sharedPreferences != null)
        sharedPreferencesProvider.overrideWith((ref) async => sharedPreferences),

      // Override notification plugin
      if (notificationPlugin != null)
        notificationPluginProvider.overrideWithValue(notificationPlugin),
    ],
  );

  return container;
}

/// Create a mock Firebase user for testing
User createMockUser({
  String uid = 'test-user-id',
  String email = 'test@example.com',
  String? displayName,
}) {
  final mockUser = MockUser();

  when(mockUser.uid).thenReturn(uid);
  when(mockUser.email).thenReturn(email);
  when(mockUser.displayName).thenReturn(displayName);

  return mockUser;
}

/// Create a mock SharedPreferences for testing
SharedPreferences createMockSharedPreferences({
  String language = 'en',
  bool notificationsEnabled = true,
  bool darkMode = false,
}) {
  final mockPrefs = MockSharedPreferences();

  when(mockPrefs.getString('language')).thenReturn(language);
  when(mockPrefs.getBool('notifications_enabled')).thenReturn(notificationsEnabled);
  when(mockPrefs.getBool('dark_mode')).thenReturn(darkMode);

  // Mock setters
  when(mockPrefs.setString(any, any)).thenAnswer((_) async => true);
  when(mockPrefs.setBool(any, any)).thenAnswer((_) async => true);

  return mockPrefs;
}

/// Helper to wait for provider to settle
Future<void> waitForProvider(ProviderContainer container) async {
  await Future.delayed(Duration.zero);
}

/// Helper to dispose provider container properly
void disposeTestContainer(ProviderContainer container) {
  container.dispose();
}
