import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:postpartum_recovery_app/config/app_config.dart';
import 'package:postpartum_recovery_app/config/routes.dart';
import 'package:postpartum_recovery_app/config/theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize app configuration (default: dev environment)
  await AppConfig.initialize(Environment.dev);

  // TODO: Initialize Firebase
  // await Firebase.initializeApp(
  //   options: DefaultFirebaseOptions.currentPlatform,
  // );

  // TODO: Initialize Hive for local storage
  // await Hive.initFlutter();

  // TODO: Initialize notifications
  // await AwesomeNotifications().initialize(...);

  runApp(
    const ProviderScope(
      child: PostpartumRecoveryApp(),
    ),
  );
}

class PostpartumRecoveryApp extends StatelessWidget {
  const PostpartumRecoveryApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      // App title
      title: AppConfig.instance.appName,

      // Debug banner
      debugShowCheckedModeBanner: AppConfig.instance.showDebugBanner,

      // Theme configuration
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system, // TODO: Make this dynamic based on user preference

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
