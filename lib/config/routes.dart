import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

// Onboarding screens
import '../ui/screens/onboarding/delivery_type_screen.dart';
import '../ui/screens/onboarding/weeks_postpartum_screen.dart';
import '../ui/screens/onboarding/symptom_assessment_screen.dart';

// TODO: Import other screens once they are implemented
// import 'package:postpartum_recovery_app/ui/screens/splash_screen.dart';
// import 'package:postpartum_recovery_app/ui/screens/home/home_screen.dart';
// import 'package:postpartum_recovery_app/ui/screens/home/level_selection_screen.dart';
// import 'package:postpartum_recovery_app/ui/screens/home/workout_list_screen.dart';
// import 'package:postpartum_recovery_app/ui/screens/workout/workout_detail_screen.dart';
// import 'package:postpartum_recovery_app/ui/screens/workout/exercise_screen.dart';
// import 'package:postpartum_recovery_app/ui/screens/workout/workout_complete_screen.dart';
// import 'package:postpartum_recovery_app/ui/screens/workout/kegel_trainer_screen.dart';
// import 'package:postpartum_recovery_app/ui/screens/progress/progress_dashboard_screen.dart';
// import 'package:postpartum_recovery_app/ui/screens/progress/diastasis_recti_screen.dart';
// import 'package:postpartum_recovery_app/ui/screens/progress/pelvic_floor_screen.dart';
// import 'package:postpartum_recovery_app/ui/screens/progress/photo_progress_screen.dart';
// import 'package:postpartum_recovery_app/ui/screens/sos/sos_home_screen.dart';
// import 'package:postpartum_recovery_app/ui/screens/sos/sos_routine_screen.dart';
// import 'package:postpartum_recovery_app/ui/screens/settings/settings_screen.dart';
// import 'package:postpartum_recovery_app/ui/screens/settings/language_screen.dart';
// import 'package:postpartum_recovery_app/ui/screens/settings/privacy_screen.dart';
// import 'package:postpartum_recovery_app/ui/screens/settings/about_screen.dart';
// import 'package:postpartum_recovery_app/ui/screens/auth/login_screen.dart';
// import 'package:postpartum_recovery_app/ui/screens/auth/signup_screen.dart';
// import 'package:postpartum_recovery_app/ui/screens/auth/forgot_password_screen.dart';

/// App Router Configuration using GoRouter
class AppRouter {
  // Route names
  static const String splash = '/';
  static const String login = '/login';
  static const String signup = '/signup';
  static const String forgotPassword = '/forgot-password';

  // Onboarding routes
  static const String onboardingDeliveryType = '/onboarding/delivery-type';
  static const String onboardingWeeksPostpartum = '/onboarding/weeks-postpartum';
  static const String onboardingSymptomAssessment = '/onboarding/symptom-assessment';

  // Home routes
  static const String home = '/home';
  static const String levelSelection = '/home/level-selection';
  static const String workoutList = '/home/workout-list';

  // Workout routes
  static const String workoutDetail = '/workout/detail';
  static const String exercise = '/workout/exercise';
  static const String workoutComplete = '/workout/complete';
  static const String kegelTrainer = '/workout/kegel-trainer';

  // Progress routes
  static const String progressDashboard = '/progress';
  static const String diastasisRecti = '/progress/diastasis-recti';
  static const String pelvicFloor = '/progress/pelvic-floor';
  static const String photoProgress = '/progress/photo';

  // SOS routes
  static const String sosHome = '/sos';
  static const String sosRoutine = '/sos/routine';

  // Settings routes
  static const String settings = '/settings';
  static const String language = '/settings/language';
  static const String privacy = '/settings/privacy';
  static const String about = '/settings/about';

  /// Router instance
  static GoRouter router = GoRouter(
    initialLocation: splash,
    routes: [
      // Splash Screen
      GoRoute(
        path: splash,
        name: 'splash',
        builder: (context, state) => const Scaffold(
          body: Center(
            child: Text('Splash Screen - TODO: Implement'),
          ),
        ),
      ),

      // Auth Routes
      GoRoute(
        path: login,
        name: 'login',
        builder: (context, state) => const Scaffold(
          body: Center(
            child: Text('Login Screen - TODO: Implement'),
          ),
        ),
      ),
      GoRoute(
        path: signup,
        name: 'signup',
        builder: (context, state) => const Scaffold(
          body: Center(
            child: Text('Signup Screen - TODO: Implement'),
          ),
        ),
      ),
      GoRoute(
        path: forgotPassword,
        name: 'forgotPassword',
        builder: (context, state) => const Scaffold(
          body: Center(
            child: Text('Forgot Password Screen - TODO: Implement'),
          ),
        ),
      ),

      // Onboarding Routes
      GoRoute(
        path: onboardingDeliveryType,
        name: 'onboardingDeliveryType',
        builder: (context, state) => const DeliveryTypeScreen(),
      ),
      GoRoute(
        path: onboardingWeeksPostpartum,
        name: 'onboardingWeeksPostpartum',
        builder: (context, state) => const WeeksPostpartumScreen(),
      ),
      GoRoute(
        path: onboardingSymptomAssessment,
        name: 'onboardingSymptomAssessment',
        builder: (context, state) => const SymptomAssessmentScreen(),
      ),

      // Home Routes
      GoRoute(
        path: home,
        name: 'home',
        builder: (context, state) => const Scaffold(
          body: Center(
            child: Text('Home Screen - TODO: Implement'),
          ),
        ),
      ),
      GoRoute(
        path: levelSelection,
        name: 'levelSelection',
        builder: (context, state) => const Scaffold(
          body: Center(
            child: Text('Level Selection Screen - TODO: Implement'),
          ),
        ),
      ),
      GoRoute(
        path: workoutList,
        name: 'workoutList',
        builder: (context, state) => const Scaffold(
          body: Center(
            child: Text('Workout List Screen - TODO: Implement'),
          ),
        ),
      ),

      // Workout Routes
      GoRoute(
        path: workoutDetail,
        name: 'workoutDetail',
        builder: (context, state) => const Scaffold(
          body: Center(
            child: Text('Workout Detail Screen - TODO: Implement'),
          ),
        ),
      ),
      GoRoute(
        path: exercise,
        name: 'exercise',
        builder: (context, state) => const Scaffold(
          body: Center(
            child: Text('Exercise Screen - TODO: Implement'),
          ),
        ),
      ),
      GoRoute(
        path: workoutComplete,
        name: 'workoutComplete',
        builder: (context, state) => const Scaffold(
          body: Center(
            child: Text('Workout Complete Screen - TODO: Implement'),
          ),
        ),
      ),
      GoRoute(
        path: kegelTrainer,
        name: 'kegelTrainer',
        builder: (context, state) => const Scaffold(
          body: Center(
            child: Text('Kegel Trainer Screen - TODO: Implement'),
          ),
        ),
      ),

      // Progress Routes
      GoRoute(
        path: progressDashboard,
        name: 'progressDashboard',
        builder: (context, state) => const Scaffold(
          body: Center(
            child: Text('Progress Dashboard Screen - TODO: Implement'),
          ),
        ),
      ),
      GoRoute(
        path: diastasisRecti,
        name: 'diastasisRecti',
        builder: (context, state) => const Scaffold(
          body: Center(
            child: Text('Diastasis Recti Screen - TODO: Implement'),
          ),
        ),
      ),
      GoRoute(
        path: pelvicFloor,
        name: 'pelvicFloor',
        builder: (context, state) => const Scaffold(
          body: Center(
            child: Text('Pelvic Floor Screen - TODO: Implement'),
          ),
        ),
      ),
      GoRoute(
        path: photoProgress,
        name: 'photoProgress',
        builder: (context, state) => const Scaffold(
          body: Center(
            child: Text('Photo Progress Screen - TODO: Implement'),
          ),
        ),
      ),

      // SOS Routes
      GoRoute(
        path: sosHome,
        name: 'sosHome',
        builder: (context, state) => const Scaffold(
          body: Center(
            child: Text('SOS Home Screen - TODO: Implement'),
          ),
        ),
      ),
      GoRoute(
        path: sosRoutine,
        name: 'sosRoutine',
        builder: (context, state) => const Scaffold(
          body: Center(
            child: Text('SOS Routine Screen - TODO: Implement'),
          ),
        ),
      ),

      // Settings Routes
      GoRoute(
        path: settings,
        name: 'settings',
        builder: (context, state) => const Scaffold(
          body: Center(
            child: Text('Settings Screen - TODO: Implement'),
          ),
        ),
      ),
      GoRoute(
        path: language,
        name: 'language',
        builder: (context, state) => const Scaffold(
          body: Center(
            child: Text('Language Screen - TODO: Implement'),
          ),
        ),
      ),
      GoRoute(
        path: privacy,
        name: 'privacy',
        builder: (context, state) => const Scaffold(
          body: Center(
            child: Text('Privacy Screen - TODO: Implement'),
          ),
        ),
      ),
      GoRoute(
        path: about,
        name: 'about',
        builder: (context, state) => const Scaffold(
          body: Center(
            child: Text('About Screen - TODO: Implement'),
          ),
        ),
      ),
    ],

    // Error handling
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Text('Page not found: ${state.uri.path}'),
      ),
    ),

    // Optional: Redirect logic
    // redirect: (context, state) {
    //   // Add authentication and onboarding redirect logic here
    //   return null;
    // },
  );
}
