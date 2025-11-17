import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:postpartum_recovery_app/config/app_config.dart';
import 'package:postpartum_recovery_app/config/routes.dart';
import 'package:postpartum_recovery_app/config/theme.dart';
import 'package:postpartum_recovery_app/providers/preferences_provider.dart';
import 'package:postpartum_recovery_app/utils/logger.dart';
import 'firebase_options.dart';

void main() async {
  // Run app with error handling
  await runAppWithErrorHandling();
}

/// Run app with comprehensive error handling
Future<void> runAppWithErrorHandling() async {
  // Capture Flutter framework errors
  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);
    AppLogger.fatal(
      'Flutter framework error',
      tag: 'APP',
      error: details.exception,
      stackTrace: details.stack,
    );
  };

  // Capture errors outside Flutter framework
  runZonedGuarded(
    () async {
      await _initializeApp();
    },
    (error, stackTrace) {
      AppLogger.fatal(
        'Uncaught error in app zone',
        tag: 'APP',
        error: error,
        stackTrace: stackTrace,
      );
    },
  );
}

/// Initialize the app with all required dependencies
Future<void> _initializeApp() async {
  try {
    // Ensure Flutter bindings are initialized
    WidgetsFlutterBinding.ensureInitialized();
    AppLogger.lifecycle('App initialization started');

    // Set preferred orientations (optional - portrait only for better UX)
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    // Initialize app configuration
    await _initializeConfiguration();

    // Initialize Firebase
    await _initializeFirebase();

    // Initialize timezone database
    await _initializeTimezone();

    // Set up logging based on environment
    _setupLogging();

    AppLogger.lifecycle('App initialization completed successfully');

    // Run the app
    runApp(
      const ProviderScope(
        child: PostpartumRecoveryApp(),
      ),
    );
  } catch (error, stackTrace) {
    AppLogger.fatal(
      'Critical error during app initialization',
      tag: 'INIT',
      error: error,
      stackTrace: stackTrace,
    );

    // Show error screen to user
    runApp(
      MaterialApp(
        home: _AppInitializationErrorScreen(
          error: error,
          stackTrace: stackTrace,
        ),
      ),
    );
  }
}

/// Initialize app configuration with error handling
Future<void> _initializeConfiguration() async {
  try {
    AppLogger.info('Initializing app configuration', tag: 'INIT');

    // Determine environment (default: dev)
    // In production, you would set this via build configuration or environment variable
    const environment = Environment.dev;

    await AppConfig.initialize(environment);

    AppLogger.info(
      'Configuration initialized for ${AppConfig.instance.environment.name}',
      tag: 'INIT',
    );
  } catch (e, stackTrace) {
    AppLogger.error(
      'Failed to initialize configuration',
      tag: 'INIT',
      error: e,
      stackTrace: stackTrace,
    );
    rethrow;
  }
}

/// Initialize Firebase with error handling
Future<void> _initializeFirebase() async {
  try {
    AppLogger.info('Initializing Firebase', tag: 'INIT');

    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    AppLogger.info('Firebase initialized successfully', tag: 'INIT');
  } catch (e, stackTrace) {
    // Firebase initialization is not critical for offline-first app
    // Log warning but continue app initialization
    AppLogger.warning(
      'Firebase initialization failed - app will run in offline mode',
      tag: 'INIT',
      error: e,
    );

    // Don't rethrow - app can work without Firebase
  }
}

/// Initialize timezone database with error handling
Future<void> _initializeTimezone() async {
  try {
    AppLogger.info('Initializing timezone database', tag: 'INIT');

    tz.initializeTimeZones();

    AppLogger.info('Timezone database initialized', tag: 'INIT');
  } catch (e, stackTrace) {
    AppLogger.error(
      'Failed to initialize timezone database',
      tag: 'INIT',
      error: e,
      stackTrace: stackTrace,
    );

    // Don't rethrow - app can work with limited timezone support
  }
}

/// Set up logging configuration based on environment
void _setupLogging() {
  if (AppConfig.instance.isProduction) {
    // In production, only log info and above
    AppLogger.setMinLevel(LogLevel.info);

    // TODO: Add crash reporting listener when Firebase Crashlytics is configured
    // AppLogger.addListener((level, message, tag, error, stackTrace) {
    //   if (level == LogLevel.error || level == LogLevel.fatal) {
    //     FirebaseCrashlytics.instance.recordError(error, stackTrace);
    //   }
    // });
  } else {
    // In development, log everything
    AppLogger.setMinLevel(LogLevel.debug);
  }
}

/// Error screen shown when app initialization fails
class _AppInitializationErrorScreen extends StatelessWidget {
  final Object error;
  final StackTrace? stackTrace;

  const _AppInitializationErrorScreen({
    required this.error,
    this.stackTrace,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                color: Colors.red,
                size: 80,
              ),
              const SizedBox(height: 24),
              const Text(
                'App Initialization Failed',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              const Text(
                'The app encountered a critical error during startup. Please try restarting the app.',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black54,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: () {
                  // Restart the app
                  runAppWithErrorHandling();
                },
                icon: const Icon(Icons.refresh),
                label: const Text('Restart App'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              // Show error details in debug mode
              if (!kReleaseMode) ...[
                const Divider(),
                const SizedBox(height: 16),
                const Text(
                  'Error Details (Debug Mode):',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                  ),
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: SingleChildScrollView(
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '$error\n\n${stackTrace ?? ""}',
                        style: const TextStyle(
                          fontSize: 12,
                          fontFamily: 'monospace',
                          color: Colors.black87,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class PostpartumRecoveryApp extends ConsumerWidget {
  const PostpartumRecoveryApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch dark mode preference
    final isDarkMode = ref.watch(isDarkModeEnabledProvider);

    return MaterialApp.router(
      // App title
      title: AppConfig.instance.appName,

      // Debug banner
      debugShowCheckedModeBanner: AppConfig.instance.showDebugBanner,

      // Theme configuration
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: isDarkMode ? ThemeMode.dark : ThemeMode.light,

      // Routing
      routerConfig: AppRouter.router,

      // Localization
      // TODO: Add localization delegates once l10n is set up
      // localizationsDelegates: const [
      //   AppLocalizations.delegate,
      //   GlobalMaterialLocalizations.delegate,
      //   GlobalWidgetsLocalizations.delegate,
      //   GlobalCupertinoLocalizations.delegate,
      // ],
      // supportedLocales: const [
      //   Locale('en', ''), // English
      //   Locale('ar', ''), // Arabic
      // ],
    );
  }
}
