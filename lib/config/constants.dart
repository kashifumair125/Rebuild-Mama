/// App-wide constants for Postpartum Recovery App
class AppConstants {
  AppConstants._();

  // App Information
  static const String appVersion = '0.1.0';
  static const String appBuildNumber = '1';

  // API Endpoints (relative to base URL in AppConfig)
  static const String loginEndpoint = '/auth/login';
  static const String signupEndpoint = '/auth/signup';
  static const String refreshTokenEndpoint = '/auth/refresh';
  static const String logoutEndpoint = '/auth/logout';
  static const String userProfileEndpoint = '/user/profile';
  static const String workoutsEndpoint = '/workouts';
  static const String progressEndpoint = '/progress';
  static const String assessmentsEndpoint = '/assessments';

  // Firebase Collections (if using Firestore)
  static const String usersCollection = 'users';
  static const String workoutsCollection = 'workouts';
  static const String exercisesCollection = 'exercises';
  static const String progressCollection = 'progress';

  // Local Storage Keys
  static const String authTokenKey = 'auth_token';
  static const String refreshTokenKey = 'refresh_token';
  static const String userIdKey = 'user_id';
  static const String onboardingCompletedKey = 'onboarding_completed';
  static const String languageKey = 'language';
  static const String themeKey = 'theme_mode';
  static const String notificationsEnabledKey = 'notifications_enabled';
  static const String dailyReminderTimeKey = 'daily_reminder_time';
  static const String kegelReminderIntervalKey = 'kegel_reminder_interval';

  // Workout Levels
  static const int levelRepair = 1; // 0-6 weeks postpartum
  static const int levelRebuild = 2; // 6-12 weeks
  static const int levelStrengthen = 3; // 12+ weeks

  // Exercise Durations (in seconds)
  static const int level1Duration = 600; // 10 minutes
  static const int level2Duration = 900; // 15 minutes
  static const int level3Duration = 1200; // 20 minutes

  // Diastasis Recti Measurements
  static const double diastasisHealthyRange = 2.0; // finger widths
  static const int diastasisCheckInDays = 7; // weekly

  // Pelvic Floor Scale
  static const int pelvicFloorMinScale = 1;
  static const int pelvicFloorMaxScale = 10;

  // Kegel Trainer Defaults
  static const int defaultKegelContractSeconds = 5;
  static const int defaultKegelHoldSeconds = 10;
  static const int defaultKegelRestSeconds = 10;
  static const int defaultKegelDurationMinutes = 5;

  // Notification Channels
  static const String workoutReminderChannel = 'workout_reminder';
  static const String kegelReminderChannel = 'kegel_reminder';
  static const String progressCheckInChannel = 'progress_check_in';
  static const String achievementChannel = 'achievement';

  // Achievement Thresholds
  static const int streakBronze = 7; // 7 days
  static const int streakSilver = 14; // 2 weeks
  static const int streakGold = 30; // 1 month
  static const int workoutCompletionBronze = 10;
  static const int workoutCompletionSilver = 50;
  static const int workoutCompletionGold = 100;

  // Subscription Product IDs
  static const String monthlySubscriptionId = 'monthly_premium';
  static const String yearlySubscriptionId = 'yearly_premium';
  static const String lifetimeSubscriptionId = 'lifetime_premium';

  // Free Trial
  static const int freeTrialDays = 7;

  // External URLs
  static const String privacyPolicyUrl = 'https://postpartumapp.com/privacy';
  static const String termsOfServiceUrl = 'https://postpartumapp.com/terms';
  static const String supportEmail = 'support@postpartumapp.com';
  static const String websiteUrl = 'https://postpartumapp.com';

  // Animation Paths
  static const String animationLevel1Path = 'assets/animations/level1/';
  static const String animationLevel2Path = 'assets/animations/level2/';
  static const String animationLevel3Path = 'assets/animations/level3/';
  static const String animationUIPath = 'assets/animations/ui/';

  // Image Paths
  static const String imagesPath = 'assets/images/';
  static const String logoPath = 'assets/images/logo.png';
  static const String onboarding1Path = 'assets/images/onboarding_1.png';
  static const String onboarding2Path = 'assets/images/onboarding_2.png';
  static const String onboarding3Path = 'assets/images/onboarding_3.png';

  // Database
  static const String databaseName = 'postpartum_app.db';
  static const int databaseVersion = 1;

  // Timeouts
  static const Duration apiTimeout = Duration(seconds: 30);
  static const Duration shortAnimationDuration = Duration(milliseconds: 300);
  static const Duration mediumAnimationDuration = Duration(milliseconds: 500);
  static const Duration longAnimationDuration = Duration(milliseconds: 800);

  // Pagination
  static const int defaultPageSize = 20;
  static const int maxPageSize = 100;

  // Locale Codes
  static const String localeEnglish = 'en';
  static const String localeArabic = 'ar';
  static const String localeHindi = 'hi';
  static const String localeUrdu = 'ur';

  // Error Messages
  static const String genericErrorMessage = 'Something went wrong. Please try again.';
  static const String networkErrorMessage = 'No internet connection. Please check your network.';
  static const String authErrorMessage = 'Authentication failed. Please login again.';
  static const String serverErrorMessage = 'Server error. Please try again later.';

  // Success Messages
  static const String workoutCompletedMessage = 'Great job! Workout completed!';
  static const String progressSavedMessage = 'Progress saved successfully!';
  static const String profileUpdatedMessage = 'Profile updated successfully!';
}
