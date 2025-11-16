import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:postpartum_recovery_app/config/app_config.dart';
import 'package:postpartum_recovery_app/config/routes.dart';
import 'package:postpartum_recovery_app/config/theme.dart';
import 'package:postpartum_recovery_app/providers/preferences_provider.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize app configuration (default: dev environment)
  await AppConfig.initialize(Environment.dev);

  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Initialize timezone database for notifications
  tz.initializeTimeZones();

  runApp(
    const ProviderScope(
      child: PostpartumRecoveryApp(),
    ),
  );
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
