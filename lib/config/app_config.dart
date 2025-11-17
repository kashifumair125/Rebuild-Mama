import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:postpartum_recovery_app/utils/logger.dart';

/// Application Environment Configuration
/// Supports: Development, Staging, Production
enum Environment {
  dev,
  staging,
  prod,
}

/// Exception thrown when configuration initialization fails
class ConfigurationException implements Exception {
  final String message;
  final Object? originalError;

  ConfigurationException(this.message, {this.originalError});

  @override
  String toString() {
    if (originalError != null) {
      return 'ConfigurationException: $message (Original: $originalError)';
    }
    return 'ConfigurationException: $message';
  }
}

class AppConfig {
  final Environment environment;
  final String apiBaseUrl;
  final String appName;
  final bool enableAnalytics;
  final bool enableCrashReporting;
  final bool showDebugBanner;
  final int apiTimeout;

  AppConfig._({
    required this.environment,
    required this.apiBaseUrl,
    required this.appName,
    required this.enableAnalytics,
    required this.enableCrashReporting,
    required this.showDebugBanner,
    required this.apiTimeout,
  });

  /// Current app configuration instance
  static late AppConfig instance;

  /// Flag to check if config has been initialized
  static bool _isInitialized = false;

  /// Check if configuration is initialized
  static bool get isInitialized => _isInitialized;

  /// Initialize app configuration based on environment
  static Future<void> initialize(Environment env) async {
    try {
      AppLogger.info('Initializing app configuration for ${env.name}', tag: 'CONFIG');

      // Load environment-specific .env file
      final fileName = _getEnvFileName(env);

      try {
        await dotenv.load(fileName: fileName);
        AppLogger.info('Loaded environment file: $fileName', tag: 'CONFIG');
      } catch (e) {
        AppLogger.warning(
          'Failed to load $fileName, using fallback values',
          tag: 'CONFIG',
          error: e,
        );
        // Continue with fallback values if .env file is missing
      }

      // Validate required configuration
      _validateConfiguration(env);

      instance = AppConfig._(
        environment: env,
        apiBaseUrl: _getValidatedUrl('API_BASE_URL', 'https://api.postpartumapp.com'),
        appName: dotenv.get('APP_NAME', fallback: 'Postpartum Recovery'),
        enableAnalytics: _getBool('ENABLE_ANALYTICS', false),
        enableCrashReporting: _getBool('ENABLE_CRASH_REPORTING', false),
        showDebugBanner: env != Environment.prod,
        apiTimeout: _getInt('API_TIMEOUT', 30000),
      );

      _isInitialized = true;
      AppLogger.info('App configuration initialized successfully', tag: 'CONFIG');
      AppLogger.debug('Config: $instance', tag: 'CONFIG');
    } catch (e, stackTrace) {
      AppLogger.error(
        'Failed to initialize app configuration',
        tag: 'CONFIG',
        error: e,
        stackTrace: stackTrace,
      );
      throw ConfigurationException(
        'Failed to initialize app configuration for ${env.name}',
        originalError: e,
      );
    }
  }

  /// Get environment file name
  static String _getEnvFileName(Environment env) {
    switch (env) {
      case Environment.dev:
        return '.env.dev';
      case Environment.staging:
        return '.env.staging';
      case Environment.prod:
        return '.env.prod';
    }
  }

  /// Validate configuration values
  static void _validateConfiguration(Environment env) {
    // In production, ensure critical features are enabled
    if (env == Environment.prod) {
      final enableAnalytics = _getBool('ENABLE_ANALYTICS', false);
      final enableCrashReporting = _getBool('ENABLE_CRASH_REPORTING', false);

      if (!enableAnalytics) {
        AppLogger.warning(
          'Analytics is disabled in production',
          tag: 'CONFIG',
        );
      }

      if (!enableCrashReporting) {
        AppLogger.warning(
          'Crash reporting is disabled in production',
          tag: 'CONFIG',
        );
      }
    }

    // Validate API URL format
    final apiUrl = dotenv.get('API_BASE_URL', fallback: '');
    if (apiUrl.isNotEmpty && !_isValidUrl(apiUrl)) {
      throw ConfigurationException('Invalid API_BASE_URL format: $apiUrl');
    }

    // Validate API timeout
    final timeout = _getInt('API_TIMEOUT', 30000);
    if (timeout < 1000 || timeout > 120000) {
      throw ConfigurationException(
        'API_TIMEOUT must be between 1000 and 120000 milliseconds, got: $timeout',
      );
    }
  }

  /// Get boolean value from environment
  static bool _getBool(String key, bool fallback) {
    final value = dotenv.get(key, fallback: fallback.toString());
    return value.toLowerCase() == 'true';
  }

  /// Get integer value from environment
  static int _getInt(String key, int fallback) {
    final value = dotenv.get(key, fallback: fallback.toString());
    return int.tryParse(value) ?? fallback;
  }

  /// Get validated URL from environment
  static String _getValidatedUrl(String key, String fallback) {
    final url = dotenv.get(key, fallback: fallback);
    if (!_isValidUrl(url)) {
      AppLogger.warning(
        'Invalid URL for $key: $url, using fallback: $fallback',
        tag: 'CONFIG',
      );
      return fallback;
    }
    return url;
  }

  /// Validate URL format
  static bool _isValidUrl(String url) {
    if (url.isEmpty) return false;
    try {
      final uri = Uri.parse(url);
      return uri.hasScheme && (uri.scheme == 'http' || uri.scheme == 'https');
    } catch (e) {
      return false;
    }
  }

  /// Development configuration
  static AppConfig get dev => AppConfig._(
        environment: Environment.dev,
        apiBaseUrl: 'https://dev-api.postpartumapp.com',
        appName: 'Postpartum Recovery [DEV]',
        enableAnalytics: false,
        enableCrashReporting: false,
        showDebugBanner: true,
        apiTimeout: 30000,
      );

  /// Staging configuration
  static AppConfig get staging => AppConfig._(
        environment: Environment.staging,
        apiBaseUrl: 'https://staging-api.postpartumapp.com',
        appName: 'Postpartum Recovery [STAGING]',
        enableAnalytics: true,
        enableCrashReporting: true,
        showDebugBanner: true,
        apiTimeout: 30000,
      );

  /// Production configuration
  static AppConfig get prod => AppConfig._(
        environment: Environment.prod,
        apiBaseUrl: 'https://api.postpartumapp.com',
        appName: 'Postpartum Recovery',
        enableAnalytics: true,
        enableCrashReporting: true,
        showDebugBanner: false,
        apiTimeout: 30000,
      );

  /// Check if app is in development mode
  bool get isDevelopment => environment == Environment.dev;

  /// Check if app is in staging mode
  bool get isStaging => environment == Environment.staging;

  /// Check if app is in production mode
  bool get isProduction => environment == Environment.prod;

  @override
  String toString() {
    return 'AppConfig(environment: $environment, apiBaseUrl: $apiBaseUrl, appName: $appName)';
  }
}
