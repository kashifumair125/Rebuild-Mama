import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Application Environment Configuration
/// Supports: Development, Staging, Production
enum Environment {
  dev,
  staging,
  prod,
}

class AppConfig {
  final Environment environment;
  final String apiBaseUrl;
  final String appName;
  final bool enableAnalytics;
  final bool enableCrashReporting;
  final bool showDebugBanner;

  AppConfig._({
    required this.environment,
    required this.apiBaseUrl,
    required this.appName,
    required this.enableAnalytics,
    required this.enableCrashReporting,
    required this.showDebugBanner,
  });

  /// Current app configuration instance
  static late AppConfig instance;

  /// Initialize app configuration based on environment
  static Future<void> initialize(Environment env) async {
    // Load environment-specific .env file
    switch (env) {
      case Environment.dev:
        await dotenv.load(fileName: '.env.dev');
        break;
      case Environment.staging:
        await dotenv.load(fileName: '.env.staging');
        break;
      case Environment.prod:
        await dotenv.load(fileName: '.env.prod');
        break;
    }

    instance = AppConfig._(
      environment: env,
      apiBaseUrl: dotenv.get('API_BASE_URL', fallback: 'https://api.postpartumapp.com'),
      appName: dotenv.get('APP_NAME', fallback: 'Postpartum Recovery'),
      enableAnalytics: dotenv.get('ENABLE_ANALYTICS', fallback: 'false') == 'true',
      enableCrashReporting: dotenv.get('ENABLE_CRASH_REPORTING', fallback: 'false') == 'true',
      showDebugBanner: env != Environment.prod,
    );
  }

  /// Development configuration
  static AppConfig get dev => AppConfig._(
        environment: Environment.dev,
        apiBaseUrl: 'https://dev-api.postpartumapp.com',
        appName: 'Postpartum Recovery [DEV]',
        enableAnalytics: false,
        enableCrashReporting: false,
        showDebugBanner: true,
      );

  /// Staging configuration
  static AppConfig get staging => AppConfig._(
        environment: Environment.staging,
        apiBaseUrl: 'https://staging-api.postpartumapp.com',
        appName: 'Postpartum Recovery [STAGING]',
        enableAnalytics: true,
        enableCrashReporting: true,
        showDebugBanner: true,
      );

  /// Production configuration
  static AppConfig get prod => AppConfig._(
        environment: Environment.prod,
        apiBaseUrl: 'https://api.postpartumapp.com',
        appName: 'Postpartum Recovery',
        enableAnalytics: true,
        enableCrashReporting: true,
        showDebugBanner: false,
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
