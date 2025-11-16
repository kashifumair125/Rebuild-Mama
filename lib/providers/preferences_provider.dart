import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'preferences_provider.g.dart';

// Preference keys
class PreferenceKeys {
  static const String language = 'language';
  static const String notificationsEnabled = 'notifications_enabled';
  static const String darkMode = 'dark_mode';
}

/// Provider for SharedPreferences instance
/// Kept alive for the lifetime of the app
@Riverpod(keepAlive: true)
Future<SharedPreferences> sharedPreferences(SharedPreferencesRef ref) async {
  return await SharedPreferences.getInstance();
}

/// Provider for language preference
/// Default: 'en'
@riverpod
class Language extends _$Language {
  @override
  Future<String> build() async {
    final prefs = await ref.watch(sharedPreferencesProvider.future);
    return prefs.getString(PreferenceKeys.language) ?? 'en';
  }

  /// Set the language preference
  Future<void> setLanguage(String language) async {
    final prefs = await ref.read(sharedPreferencesProvider.future);
    await prefs.setString(PreferenceKeys.language, language);
    state = AsyncValue.data(language);
  }
}

/// Provider for notifications enabled preference
/// Default: true
@riverpod
class NotificationsEnabled extends _$NotificationsEnabled {
  @override
  Future<bool> build() async {
    final prefs = await ref.watch(sharedPreferencesProvider.future);
    return prefs.getBool(PreferenceKeys.notificationsEnabled) ?? true;
  }

  /// Toggle notifications
  Future<void> toggle() async {
    final current = state.value ?? true;
    await setEnabled(!current);
  }

  /// Set notifications enabled state
  Future<void> setEnabled(bool enabled) async {
    final prefs = await ref.read(sharedPreferencesProvider.future);
    await prefs.setBool(PreferenceKeys.notificationsEnabled, enabled);
    state = AsyncValue.data(enabled);
  }
}

/// Provider for dark mode preference
/// Default: false (light mode)
@riverpod
class DarkMode extends _$DarkMode {
  @override
  Future<bool> build() async {
    final prefs = await ref.watch(sharedPreferencesProvider.future);
    return prefs.getBool(PreferenceKeys.darkMode) ?? false;
  }

  /// Toggle dark mode
  Future<void> toggle() async {
    final current = state.value ?? false;
    await setEnabled(!current);
  }

  /// Set dark mode enabled state
  Future<void> setEnabled(bool enabled) async {
    final prefs = await ref.read(sharedPreferencesProvider.future);
    await prefs.setBool(PreferenceKeys.darkMode, enabled);
    state = AsyncValue.data(enabled);
  }
}

/// Helper provider to get current language synchronously
@riverpod
String currentLanguage(CurrentLanguageRef ref) {
  final languageAsync = ref.watch(languageProvider);
  return languageAsync.when(
    data: (language) => language,
    loading: () => 'en',
    error: (_, __) => 'en',
  );
}

/// Helper provider to check if notifications are enabled synchronously
@riverpod
bool areNotificationsEnabled(AreNotificationsEnabledRef ref) {
  final notificationsAsync = ref.watch(notificationsEnabledProvider);
  return notificationsAsync.when(
    data: (enabled) => enabled,
    loading: () => true,
    error: (_, __) => true,
  );
}

/// Helper provider to check if dark mode is enabled synchronously
@riverpod
bool isDarkModeEnabled(IsDarkModeEnabledRef ref) {
  final darkModeAsync = ref.watch(darkModeProvider);
  return darkModeAsync.when(
    data: (enabled) => enabled,
    loading: () => false,
    error: (_, __) => false,
  );
}
