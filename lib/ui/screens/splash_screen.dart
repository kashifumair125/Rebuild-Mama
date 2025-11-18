import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../config/routes.dart';
import '../../providers/auth_provider.dart';
import '../../providers/biometric_provider.dart';
import '../../providers/onboarding_provider.dart';
import '../../utils/logger.dart';

/// Splash screen that shows the app logo and handles initial navigation
/// Checks authentication status and onboarding completion
class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  /// Initialize app and determine navigation destination
  Future<void> _initializeApp() async {
    try {
      AppLogger.lifecycle('Splash screen initialization started');

      // Wait for a minimum splash duration (better UX)
      await Future.delayed(const Duration(seconds: 2));

      if (!mounted) return;

      // Check authentication status
      final authState = ref.read(currentUserProvider);
      final user = authState.valueOrNull;

      if (user == null) {
        // User not authenticated, go to login
        AppLogger.info('No authenticated user, navigating to login');
        if (mounted) context.go(AppRouter.login);
        return;
      }

      // User is authenticated, check onboarding status
      AppLogger.info('User authenticated: ${user.email}');

      final onboardingState = await ref.read(onboardingStateProvider.future);

      if (!onboardingState.isOnboardingComplete) {
        // Onboarding not complete, navigate to first onboarding screen
        AppLogger.info('Onboarding not complete, navigating to onboarding');
        if (mounted) context.go(AppRouter.onboardingDeliveryType);
        return;
      }

      // Check if biometric lock is enabled
      final biometricService = ref.read(biometricServiceProvider);
      final biometricEnabled = await biometricService.isBiometricEnabled();

      if (biometricEnabled) {
        // Show biometric lock screen
        AppLogger.info('Biometric lock enabled, navigating to biometric lock');
        if (mounted) context.go(AppRouter.biometricLock);
      } else {
        // Everything is good, navigate to home
        AppLogger.info('User authenticated and onboarded, navigating to home');
        if (mounted) context.go(AppRouter.home);
      }

    } catch (e, stackTrace) {
      AppLogger.error(
        'Error during splash initialization',
        error: e,
        stackTrace: stackTrace,
      );

      // On error, default to login screen
      if (mounted) context.go(AppRouter.login);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // App Logo/Icon
            Icon(
              Icons.favorite_rounded,
              size: 120,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(height: 24),

            // App Name
            Text(
              'Rebuild Mama',
              style: theme.textTheme.headlineLarge?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),

            // Tagline
            Text(
              'Your Postpartum Recovery Journey',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 48),

            // Loading indicator
            CircularProgressIndicator(
              color: theme.colorScheme.primary,
            ),
          ],
        ),
      ),
    );
  }
}
