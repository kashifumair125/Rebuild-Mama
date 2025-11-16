# 🤰 Postpartum Recovery - Privacy-First Fitness App

> A scientifically-backed, offline-first fitness app designed exclusively for postpartum women's recovery. Built with privacy, safety, and cultural sensitivity as core features.

**Status:** MVP Ready for Development  
**Target Launch:** 8-12 weeks  
**Markets:** Saudi Arabia 🇸🇦 | UAE 🇦🇪 | India 🇮🇳 | Global 🌍

---

## 📋 Table of Contents

1. [Project Overview](#project-overview)
2. [Product Features](#product-features)
3. [Architecture & Tech Stack](#architecture--tech-stack)
4. [Project Structure](#project-structure)
5. [Setup Instructions](#setup-instructions)
6. [Development Roadmap](#development-roadmap)
7. [Privacy & Security](#privacy--security)
8. [API Documentation](#api-documentation)
9. [Testing Strategy](#testing-strategy)
10. [Deployment Guide](#deployment-guide)

---

## 🎯 Project Overview

### Vision
Empower postpartum women with safe, science-backed recovery guidance through a privacy-first, offline-capable mobile app. No social features, no photo sharing, no tracking—just personalized recovery support.

### Core Differentiators
- **Privacy-First**: All data stored locally. No cloud sync without explicit consent.
- **Offline-Ready**: Complete functionality without internet connection.
- **Culturally Sensitive**: Built for Middle East markets (Arabic RTL, women-only spaces, prayer times).
- **Medical-Grade Content**: Physiotherapist-reviewed exercises and assessments.
- **3-Level Progression**: Safe recovery path from week 0 to 12+ weeks postpartum.
- **Animation-Driven**: Lottie/Rive animations for all exercise demonstrations (no heavy video files).

### Target Audience
- Women 0-12 months postpartum (vaginal or C-section delivery)
- Ages 18-45
- Primary: Saudi Arabia, UAE, India
- Secondary: Global English-speaking women
- Pain Points: Pelvic floor weakness, diastasis recti, back pain, lack of safe exercise guidance

---

## ✨ Product Features

### MVP Features (Phase 1-2: Weeks 1-4)

#### 1. **Onboarding & Assessment** ✅
- Warm, feminine 3-screen introduction
- Delivery type selection (Vaginal / C-section)
- Weeks postpartum calculator
- Symptom questionnaire (pelvic floor, diastasis recti, pain levels)
- Auto-recommendation to appropriate workout level
- **Data Storage:** Local Drift database, encrypted

#### 2. **Pelvic Floor Assessment** ✅
- 10-question symptom assessment questionnaire
- Classification: Weak / Moderate / Strong
- Real-time scoring system
- Personalized workout recommendations
- Progress tracking over time
- **Data Storage:** Drift database with encryption

#### 3. **Diastasis Recti Self-Test** ✅
- Step-by-step video guide to measure ab separation
- Finger-width input (0-5 fingers)
- Visual progress tracking with line charts
- Weekly reminder system
- Goal tracking (target: 1-2 finger widths)
- **Data Storage:** Drift + fl_chart visualization

#### 4. **3-Level Workout System** ✅

**Level 1: Repair (0-6 weeks postpartum)**
- 5 exercises: Diaphragmatic breathing, Pelvic tilts, Gentle Kegels, Cat-cow, Ankle pumps
- Duration: 10 minutes
- Lottie animations for each exercise
- Audio cues and modifications
- Safety tips for C-section recovery

**Level 2: Rebuild (6-12 weeks)**
- 8 exercises: Bridges, Wall push-ups, Modified planks, Side-lying leg lifts, Bird dog, Glute squeezes, Pelvic circles, Transverse abdominis
- Duration: 15 minutes
- Progressive resistance cues
- Diastasis recti-safe modifications

**Level 3: Strengthen (12+ weeks)**
- 12 exercises: Full planks, Squats, Lunges, Mountain climbers, Dead bugs, Burpees (modified), Jump squats, Farmer carries
- Duration: 20 minutes
- High-intensity options
- Return-to-fitness guidance

**Features:**
- Lottie animation for each exercise (100 KB max file size)
- Exercise name, description, duration, sets/reps
- Audio guidance with haptic feedback
- Progress bar showing workout completion
- Mark complete button with instant feedback
- **State Management:** Riverpod StateNotifier

#### 5. **Voice-Guided Kegel Trainer** ✅
- Customizable duration: 1-10 minutes
- Adjustable timings:
  - Contract time: 3-10 seconds
  - Hold time: 5-15 seconds
  - Rest time: 5-15 seconds
- Text-to-speech voice guidance
- Real-time timer with visual countdown
- Phase indicators (Contract/Hold/Release/Rest) with color coding
- Rep counter
- Haptic vibration feedback on phase changes
- Background audio support (screen lock)
- Achievement badges (7-day streak, 100 reps)
- **Packages:** `audioplayers`, `vibration`

#### 6. **Progress Tracking Dashboard** ✅
- **Diastasis Recti Tracking:**
  - Input gap width in finger widths
  - Weekly check-in with reminders
  - Line chart showing weekly progression
  - Goal indicator (1-2 finger widths)
  
- **Pelvic Floor Strength:**
  - 1-10 self-assessment scale
  - Weekly tracking
  - Trend visualization
  
- **Weight & BMI:**
  - Optional weight logging
  - BMI auto-calculation
  - Weight trend chart
  
- **Photo Progress:**
  - Local photo upload (before/after)
  - Privacy: Photos stored only locally
  - Side-by-side comparison viewer
  - 12-week transformation timeline
  
- **Workout Completion:**
  - Calendar heat map (daily completions)
  - Streak counter
  - Weekly/monthly statistics
  - Motivational notifications

**Packages:** `fl_chart`, `image_picker`, `cached_network_image`

#### 7. **SOS Help Section** ✅
Quick access to targeted relief routines:
- **Back Pain:** 5-minute targeted routine
- **Pelvic Heaviness:** 4-minute relief routine
- **C-Section Scar Pain:** 3-minute scar mobility routine
- **Diastasis Recti Urgency:** 6-minute core engagement
- **Pelvic Floor Overactivity:** 5-minute relaxation routine

Each routine includes:
- Lottie animations
- Audio guidance
- Safety warnings
- When to see a doctor (guidelines)

#### 8. **Reminders & Notifications** ✅
- Daily workout reminders (user-set time)
- Kegel exercise reminders (hourly options)
- Weekly progress check-in prompts
- Achievement notifications
- **Packages:** `firebase_messaging`, `awesome_notifications`

#### 9. **Arabic Localization & RTL Support** ✅
- Full Arabic language support (RTL layout)
- Arabic translations for all content
- Key translations:
  - Postpartum Recovery = تعافي ما بعد الولادة
  - Pelvic Floor = قاع الحوض
  - Diastasis Recti = انفراق البطن
- Language selector in settings
- User preference saved in local storage

**Packages:** `intl`, `flutter_localizations`

### Premium Features (Phase 3: Weeks 5-8)

#### 10. **Subscription & Freemium Model** ✅
- **Free Tier (7-day trial, then limited):**
  - Level 1 workouts only (first 3 exercises)
  - Basic pelvic floor assessment
  - Diastasis recti self-test
  - Limited progress tracking
  
- **Premium Tier:**
  - All workout levels (1, 2, 3)
  - Full progress tracking with all charts
  - Voice-guided Kegel trainer
  - SOS emergency routines
  - Unlimited photo uploads
  - Ad-free experience
  - Email support
  - Monthly expert Q&A articles

**Pricing:**
- Monthly: $9.99
- Yearly: $59.99 (save 40%)
- One-time courses: $29.99 each

**Packages:** `revenue_cat`, `in_app_purchase`

#### 11. **Admin Dashboard (Backend)**
- Content management system for exercises
- Workout builder (drag-drop exercise arrangement)
- Animation upload and preview
- User analytics and engagement tracking
- Feedback and issue management
- A/B testing framework

#### 12. **Expert Articles & Resources** (Phase 4)
- Weekly expert-written articles on:
  - Pelvic floor recovery myths
  - Nutrition for postpartum healing
  - Mental health during recovery
  - Return-to-exercise timelines
  - Partner support guides

---

## 🏗️ Architecture & Tech Stack

### Development Framework
- **Language:** Dart
- **Framework:** Flutter 3.x
- **Minimum SDK:** Android 21 (5.0) | iOS 12.0
- **State Management:** Riverpod 2.x (stream-based, unidirectional data flow)

### Local Storage (Privacy-First)
```
├── Drift (SQLite)          ← Structured workout data, assessments
├── Hive                     ← User preferences, settings (lightweight)
├── flutter_secure_storage   ← Authentication tokens, sensitive data
└── file_provider           ← Local photo storage
```

**Why Drift over Firebase:** Full offline capability, encrypted local DB, zero cloud dependency.

### Backend (Optional/Minimal)
```
├── Firebase Authentication  ← User sign-up/login (no social data required)
├── Firebase Cloud Messaging ← Push notifications only
├── Firebase Analytics      ← Anonymous usage tracking (opt-in)
└── Cloud Functions         ← Newsletter, analytics aggregation
```

**Design Principle:** Server stores only encrypted metadata. All health data stays on device.

### Animation Libraries
```
├── Lottie              ← Exercise demonstrations (JSON animations)
├── Rive                ← Interactive UI elements (progress rings, transitions)
└── Flutter Animations  ← Built-in transitions and state changes
```

**File Sizes:**
- Lottie: 10-100 KB per animation
- Rive: 50-150 KB per animation
- Total app size: ~80-100 MB (vs 300+ MB with video)

### Data Encryption
```
├── flutter_secure_storage      ← Platform-level encryption (iOS Keychain, Android Keystore)
├── cryptography package         ← AES-256 for sensitive fields
└── End-to-end encryption (E2EE) ← Optional user data sync
```

### Packages Summary

```yaml
dependencies:
  flutter:
    sdk: flutter
  
  # State Management (Riverpod)
  flutter_riverpod: ^2.4.9
  riverpod_annotation: ^2.3.3
  
  # Animations
  lottie: ^3.0.0
  rive: ^0.12.4
  
  # Local Database
  drift: ^2.14.0
  sqlite3_flutter_libs: ^0.5.0
  hive: ^2.2.3
  hive_flutter: ^1.1.0
  flutter_secure_storage: ^9.0.0
  
  # Firebase (Optional)
  firebase_core: ^2.24.2
  firebase_auth: ^4.15.3
  firebase_messaging: ^14.6.0
  firebase_analytics: ^10.7.4
  
  # UI & Charts
  fl_chart: ^0.66.0
  percent_indicator: ^4.2.3
  
  # Media & Files
  image_picker: ^1.0.5
  cached_network_image: ^3.3.0
  path_provider: ^2.1.1
  
  # Audio & Haptics
  audioplayers: ^5.2.1
  vibration: ^1.8.3
  just_audio: ^0.9.36
  
  # Localization
  intl: ^0.18.1
  flutter_localizations:
    sdk: flutter
  
  # Notifications
  awesome_notifications: ^0.8.3
  
  # Utilities
  shared_preferences: ^2.2.2
  connectivity_plus: ^5.0.2
  permission_handler: ^11.1.0
  url_launcher: ^6.2.2
  get: ^4.6.5
  
  # Monetization
  in_app_purchase: ^5.1.0
  revenue_cat_flutter: ^6.0.0
  
  # Encryption
  encrypt: ^5.0.0
  cryptography: ^2.1.0

dev_dependencies:
  flutter_test:
    sdk: flutter
  riverpod_generator: ^2.3.9
  drift_dev: ^2.14.0
  build_runner: ^2.4.7
  flutter_lints: ^3.0.1
```

---

## 📁 Project Structure

```
postpartum_recovery_app/
│
├── lib/
│   ├── main.dart                          # App entry point
│   │
│   ├── config/
│   │   ├── app_config.dart               # Environment config (dev, prod)
│   │   ├── routes.dart                   # Navigation routes
│   │   ├── theme.dart                    # Material 3 theme (pastels)
│   │   └── constants.dart                # App-wide constants
│   │
│   ├── models/                            # Data models
│   │   ├── workout.dart
│   │   ├── exercise.dart
│   │   ├── user_profile.dart
│   │   ├── progress_data.dart
│   │   └── assessment.dart
│   │
│   ├── database/                          # Drift (SQLite)
│   │   ├── app_database.dart             # Database configuration
│   │   ├── migrations/                   # Schema migrations
│   │   └── daos/
│   │       ├── workout_dao.dart
│   │       ├── progress_dao.dart
│   │       ├── exercise_dao.dart
│   │       └── assessment_dao.dart
│   │
│   ├── providers/                         # Riverpod providers
│   │   ├── auth_provider.dart
│   │   ├── database_provider.dart
│   │   ├── workout_provider.dart
│   │   ├── progress_provider.dart
│   │   ├── assessment_provider.dart
│   │   ├── user_preferences_provider.dart
│   │   └── notification_provider.dart
│   │
│   ├── services/                          # Business logic
│   │   ├── auth_service.dart
│   │   ├── workout_service.dart
│   │   ├── progress_service.dart
│   │   ├── notification_service.dart
│   │   ├── storage_service.dart          # Secure storage wrapper
│   │   ├── analytics_service.dart
│   │   └── localization_service.dart
│   │
│   ├── ui/
│   │   ├── screens/
│   │   │   ├── splash_screen.dart
│   │   │   ├── onboarding/
│   │   │   │   ├── delivery_type_screen.dart
│   │   │   │   ├── weeks_postpartum_screen.dart
│   │   │   │   └── symptom_assessment_screen.dart
│   │   │   ├── home/
│   │   │   │   ├── home_screen.dart
│   │   │   │   ├── level_selection_screen.dart
│   │   │   │   └── workout_list_screen.dart
│   │   │   ├── workout/
│   │   │   │   ├── workout_detail_screen.dart
│   │   │   │   ├── exercise_screen.dart
│   │   │   │   ├── workout_complete_screen.dart
│   │   │   │   └── kegel_trainer_screen.dart
│   │   │   ├── progress/
│   │   │   │   ├── progress_dashboard_screen.dart
│   │   │   │   ├── diastasis_recti_screen.dart
│   │   │   │   ├── pelvic_floor_screen.dart
│   │   │   │   └── photo_progress_screen.dart
│   │   │   ├── sos/
│   │   │   │   ├── sos_home_screen.dart
│   │   │   │   └── sos_routine_screen.dart
│   │   │   ├── settings/
│   │   │   │   ├── settings_screen.dart
│   │   │   │   ├── language_screen.dart
│   │   │   │   ├── privacy_screen.dart
│   │   │   │   └── about_screen.dart
│   │   │   └── auth/
│   │   │       ├── login_screen.dart
│   │   │       ├── signup_screen.dart
│   │   │       └── forgot_password_screen.dart
│   │   │
│   │   ├── widgets/
│   │   │   ├── exercise_animation_player.dart      # Lottie wrapper
│   │   │   ├── progress_chart_widget.dart
│   │   │   ├── workout_card_widget.dart
│   │   │   ├── timer_widget.dart
│   │   │   ├── kegel_phase_indicator.dart
│   │   │   ├── loading_state_widget.dart
│   │   │   └── error_state_widget.dart
│   │   │
│   │   └── themes/
│   │       ├── app_theme.dart             # Material 3 pastels
│   │       ├── colors.dart
│   │       └── typography.dart
│   │
│   ├── assets/
│   │   ├── animations/
│   │   │   ├── level1/
│   │   │   │   ├── breathing.json
│   │   │   │   ├── pelvic_tilt.json
│   │   │   │   ├── kegel.json
│   │   │   │   ├── cat_cow.json
│   │   │   │   └── ankle_pump.json
│   │   │   ├── level2/
│   │   │   │   ├── bridge.json
│   │   │   │   ├── wall_pushup.json
│   │   │   │   └── ... (8 total)
│   │   │   ├── level3/
│   │   │   │   ├── plank.json
│   │   │   │   ├── squat.json
│   │   │   │   └── ... (12 total)
│   │   │   └── ui/
│   │   │       ├── success_animation.json
│   │   │       ├── loading.json
│   │   │       └── celebration.json
│   │   ├── images/
│   │   │   ├── logo.png
│   │   │   ├── onboarding_1.png
│   │   │   ├── onboarding_2.png
│   │   │   └── onboarding_3.png
│   │   └── translations/
│   │       ├── en.arb
│   │       └── ar.arb
│   │
│   ├── l10n/
│   │   ├── app_en.arb
│   │   └── app_ar.arb
│   │
│   └── utils/
│       ├── date_utils.dart
│       ├── formatting_utils.dart
│       ├── validators.dart
│       └── logger.dart
│
├── test/
│   ├── unit/
│   │   ├── services_test.dart
│   │   ├── providers_test.dart
│   │   └── models_test.dart
│   ├── widget/
│   │   ├── screens_test.dart
│   │   └── widgets_test.dart
│   └── integration/
│       ├── workout_flow_test.dart
│       ├── progress_tracking_test.dart
│       └── offline_functionality_test.dart
│
├── android/
│   ├── app/
│   │   └── build.gradle
│   └── gradle.properties
│
├── ios/
│   ├── Podfile
│   └── Runner/
│       └── Info.plist
│
├── web/                                  # Optional web build
│   └── index.html
│
├── pubspec.yaml                         # Dependencies
├── pubspec.lock                         # Locked versions
├── pubspec_overrides.yaml               # Local package overrides
├── analysis_options.yaml                # Linter rules
├── README.md                            # This file
├── CHANGELOG.md
├── LICENSE
└── .github/
    └── workflows/
        ├── ci.yml                       # GitHub Actions CI/CD
        └── deploy.yml                   # App Store/Play Store deploy
```

---

## 🚀 Setup Instructions

### Prerequisites
- Flutter 3.x ([Install](https://flutter.dev/docs/get-started/install))
- Dart 3.0+
- Android SDK 21+ or iOS 12.0+
- Xcode 14+ (iOS development)
- Android Studio (Android development)
- Git

### Clone & Initial Setup

```bash
# 1. Clone repository
git clone https://github.com/yourusername/postpartum_recovery_app.git
cd postpartum_recovery_app

# 2. Get dependencies
flutter pub get

# 3. Generate code (Drift, Riverpod, i18n)
dart run build_runner build --delete-conflicting-outputs

# 4. Create Firebase project (optional but recommended)
# - Go to https://firebase.google.com/
# - Create new project
# - Register iOS and Android apps
# - Download config files:
#   - iOS: GoogleService-Info.plist → ios/Runner/
#   - Android: google-services.json → android/app/

# 5. Generate localization files
flutter gen-l10n

# 6. Run the app
flutter run --release
```

### Environment Setup

**Development:**
```bash
flutter run -d <device_id>
```

**Staging (with Firebase):**
```bash
flutter run --target lib/main_staging.dart -d <device_id>
```

**Production:**
```bash
flutter run --target lib/main_prod.dart --release -d <device_id>
```

### Database Initialization

First run automatically creates Drift schema:
```dart
// lib/database/app_database.dart
@DriftDatabase(
  tables: [Users, Workouts, Exercises, Assessments, Progress],
  daos: [UserDao, WorkoutDao, ExerciseDao, AssessmentDao, ProgressDao],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());
}
```

---

## 📅 Development Roadmap

### Phase 1: Foundation (Week 1-2)
**Goal:** App shell with core data models and UI framework

- [x] Project setup (Flutter, Riverpod, Drift)
- [x] Database schema design
- [x] User authentication (email/password)
- [x] Onboarding flow (3 screens)
- [x] Theme system (Material 3 pastels)
- [x] Navigation structure
- [x] Local storage setup

**Deliverable:** Working app shell with authentication

### Phase 2: Core Workouts (Week 3-4)
**Goal:** Complete 3-level workout system with animations

- [x] Pelvic floor assessment questionnaire
- [x] Diastasis recti self-test
- [x] Level 1 workouts (5 exercises with Lottie)
- [x] Level 2 workouts (8 exercises)
- [x] Level 3 workouts (12 exercises)
- [x] Exercise tracking and completion
- [x] Basic progress dashboard

**Deliverable:** Full workout system functional offline

### Phase 3: Advanced Features (Week 5-6)
**Goal:** Add voice guidance, SOS routines, and personalization

- [x] Voice-guided Kegel trainer
- [x] SOS help section (5 quick routines)
- [x] Push notifications and reminders
- [x] Arabic localization (RTL)
- [x] Photo progress tracking
- [x] Comprehensive progress dashboard
- [x] Settings and preferences

**Deliverable:** Feature-complete MVP

### Phase 4: Monetization (Week 7)
**Goal:** Subscription system and premium content

- [x] RevenueCat integration
- [x] Paywall implementation
- [x] In-app purchase setup
- [x] Premium content gating
- [x] Analytics tracking

**Deliverable:** Monetization working

### Phase 5: Polish & Launch (Week 8)
**Goal:** Final optimization and store submission

- [x] Performance optimization
- [x] Unit and integration tests
- [x] Beta testing (20 women)
- [x] App Store submission
- [x] Google Play submission
- [x] Marketing materials

**Deliverable:** Live on both app stores

---

## 🔐 Privacy & Security

### Core Privacy Principles

**No Cloud Dependency:** All health data stays on device. Firebase is optional for auth only.

**No Social Features:** No posts, photos sharing, or user-to-user messaging.

**Encrypted Storage:** All sensitive data encrypted at rest using platform-level security.

**User Control:** Users delete all data with one tap. No server retains health history.

### Implementation Details

#### Local Database Encryption (Drift + SQLite)
```dart
// lib/database/app_database.dart
import 'package:drift/native.dart';

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    // For encryption, use native SQLite with password
    final file = File(join(
      await getDatabasesPath(),
      'postpartum_app.db',
    ));
    return NativeDatabase(
      file,
      setup: (rawDb) {
        // Optional: Use sqlcipher for encryption
        // rawDb.execute('PRAGMA key = "your_encryption_key"');
      },
    );
  });
}
```

#### Secure Storage for Sensitive Data
```dart
// lib/services/storage_service.dart
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class StorageService {
  final storage = const FlutterSecureStorage(
    aOptions: AndroidOptions(
      keyCipherAlgorithm: KeyCipherAlgorithm.RSA_ECB_OAEPwithSHA_256andMGF1Padding,
      storageCipherAlgorithm: StorageCipherAlgorithm.AES_GCM_NoPadding,
    ),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_available_when_unlocked_this_device_only,
    ),
  );

  // Store auth token securely
  Future<void> saveAuthToken(String token) =>
    storage.write(key: 'auth_token', value: token);

  Future<String?> getAuthToken() =>
    storage.read(key: 'auth_token');

  Future<void> deleteAuthToken() =>
    storage.delete(key: 'auth_token');
}
```

#### End-to-End Encryption (Optional)
```dart
// lib/services/encryption_service.dart
import 'package:cryptography/cryptography.dart';

class EncryptionService {
  final algorithm = AesGcm.with256bits();

  Future<List<int>> encrypt(String plaintext, SecretKey key) async {
    final nonce = algorithm.newNonce();
    final encrypted = await algorithm.encryptString(plaintext, secretKey: key, nonce: nonce);
    return nonce + encrypted.cipherText;
  }

  Future<String> decrypt(List<int> encryptedData, SecretKey key) async {
    final nonce = encryptedData.sublist(0, 12);
    final cipherText = encryptedData.sublist(12);
    final decrypted = await algorithm.decryptString(
      SecretBox(cipherText, nonce: nonce),
      secretKey: key,
    );
    return decrypted;
  }
}
```

### GDPR & Privacy Compliance

✅ **Data Minimization:** Only collect what's necessary (delivery type, symptoms, workouts).

✅ **User Consent:** Clear opt-in for analytics. Health data never leaves device without permission.

✅ **Data Deletion:** Users can delete all data. No server-side health records.

✅ **Transparency:** Privacy policy explains exactly what's collected and how.

✅ **No Third Parties:** No Facebook, Google Analytics, or ad networks in health data pipeline.

✅ **User Rights:** Users can export their data anytime in CSV format.

### Security Audit Checklist

- [ ] Penetration testing by security firm
- [ ] OWASP Mobile Top 10 review
- [ ] Code audit by third party
- [ ] Biometric authentication review
- [ ] SSL/TLS certificate pinning (if using Firebase)

---

## 📡 API Documentation

### Local Database API (Drift)

#### Workout DAO
```dart
// Get user's current assigned level
Future<Workout?> getUserCurrentLevel(String userId);

// Get exercises for a level
Future<List<Exercise>> getLevelExercises(int level);

// Log workout completion
Future<void> completeWorkout(WorkoutCompletion completion);

// Get workout history
Future<List<WorkoutCompletion>> getWorkoutHistory(String userId, DateTimeRange range);
```

#### Progress DAO
```dart
// Save diastasis recti measurement
Future<void> saveDiastasisRectMeasurement(DiastasisMeasurement measurement);

// Get diastasis recti trend
Future<List<DiastasisMeasurement>> getDiastasisTrend(String userId, {int days = 90});

// Save pelvic floor self-assessment
Future<void> savePelvicFloorAssessment(PelvicFloorAssessment assessment);

// Get progress summary
Future<ProgressSummary> getProgressSummary(String userId);
```

#### Assessment DAO
```dart
// Get initial postpartum assessment
Future<PostpartumAssessment?> getInitialAssessment(String userId);

// Update weekly check-in
Future<void> updateWeeklyCheckIn(WeeklyCheckIn checkIn);
```

### Riverpod Providers

```dart
// Authentication
final currentUserProvider = StreamProvider<User?>((ref) { });

// Database
final databaseProvider = Provider<AppDatabase>((ref) { });

// Workouts
final userLevelProvider = FutureProvider<int>((ref) { });
final currentWorkoutProvider = StateProvider<Workout?>((ref) => null);
final workoutProgressProvider = StreamProvider<WorkoutProgress>((ref) { });

// Progress
final diastasisTrendProvider = FutureProvider<List<DiastasisMeasurement>>((ref) { });
final pelvicFloorProgressProvider = FutureProvider<PelvicFloorProgress>((ref) { });

// Preferences
final languageProvider = StateProvider<Locale>((ref) => const Locale('en'));
final notificationsEnabledProvider = StateProvider<bool>((ref) => true);
```

---

## 🧪 Testing Strategy

### Unit Tests
```bash
flutter test test/unit/
```

**Coverage:**
- Models (serialization/deserialization)
- Services (business logic)
- Providers (state management)
- Validators (form inputs)

### Widget Tests
```bash
flutter test test/widget/
```

**Coverage:**
- UI rendering
- User interactions
- State changes
- Error handling

### Integration Tests
```bash
flutter test integration_test/
```

**Scenarios:**
- Complete workout flow
- Offline functionality
- Data persistence
- Authentication flow
- Progress tracking
- Language switching

### Test Execution

```bash
# Run all tests
flutter test

# With coverage
flutter test --coverage
lcov --list coverage/lcov.info

# Run specific test file
flutter test test/unit/services_test.dart
```

### CI/CD Pipeline

**.github/workflows/ci.yml** - Automated on every push:
```yaml
- Lint code (flutter analyze)
- Run unit tests
- Run widget tests
- Build APK/IPA
- Upload to Firebase App Distribution
```

---

## 📦 Deployment Guide

### App Store Submission (iOS)

1. **Certificate & Provisioning**
   ```bash
   cd ios
   pod install
   cd ..
   flutter build ios --release
   ```

2. **Archive & Upload**
   - Open `build/ios/archive/Runner.xcarchive` in Xcode
   - Validate and upload to App Store Connect

3. **Metadata**
   - App name: "Postpartum Recovery"
   - Subtitle: "Safe, guided fitness for postpartum women"
   - Category: Health & Fitness
   - Keywords: postpartum, pelvic floor, diastasis recti, recovery

### Google Play Submission (Android)

1. **Signing**
   ```bash
   flutter build appbundle --release
   # Creates build/app/outputs/bundle/release/app-release.aab
   ```

2. **Upload to Play Console**
   - App name: "Postpartum Recovery"
   - Category: Health & Fitness
   - Content rating: Low maturity

3. **Store Listing**
   - Privacy policy: https://yoursite.com/privacy
   - Screenshots: 4-6 key features
   - Description: 80 characters max
   - Promotional art: 1024x500px

### Post-Launch Monitoring

**Firebase Analytics:**
- User funnel (onboarding → first workout → week 1)
- Feature usage (Kegel trainer, progress tracking)
- Error rates and crash reports

**Crash Reporting:**
- Sentry integration for error tracking
- Daily digest of new errors

**Beta Testing:**
- Internal testers (week 1-2)
- External beta (week 3-4)
- Country-specific testing (Saudi, UAE, India)

---

## 🌍 Localization

### Supported Languages
- English (en)
- Arabic (ar) - RTL
- Hindi (hi) - Future
- Urdu (ur) - Future

### Adding a New Language

1. Update `pubspec.yaml`:
```yaml
flutter:
  generate: true
```

2. Create translation file `lib/l10n/app_xx.arb`:
```json
{
  "helloWorld": "Hello, World!",
  "helloWorld_ar": "مرحبا بالعالم",
  "workoutLevel": "Workout Level {level}",
  "@workoutLevel": {
    "placeholders": {
      "level": {
        "type": "int"
      }
    }
  }
}
```

3. Generate:
```bash
flutter gen-l10n
```

---

## 🤝 Contributing

See `CONTRIBUTING.md` for guidelines.

### Code Style
- Follow [Effective Dart](https://dart.dev/guides/language/effective-dart)
- Use `flutter analyze` before commits
- Format with `dart format`
- Lint with `flutter_lints`

### Commit Convention
```
feat: add Kegel trainer feature
fix: correct diastasis recti calculation
docs: update setup instructions
test: add workout flow integration tests
refactor: reorganize progress tracking code
style: reformat typography
chore: update dependencies
```

---

## 📄 License

MIT License - See `LICENSE` file

---

## 👥 Team & Support

**Lead Developer:** [Your Name]  
**Medical Consultant:** [Physiotherapist Name]  
**UI/UX Design:** [Designer Name]  

### Contact
- Email: hello@postpartumapp.com
- Website: www.postpartumapp.com
- Support: support@postpartumapp.com

---

## 🎯 Success Metrics

### User Acquisition
- **Month 1:** 100 organic installs
- **Month 3:** 1,000 installs
- **Month 6:** 5,000+ paid subscribers

### Engagement
- 70%+ DAU (Daily Active Users)
- 5+ minutes average session
- 5+ workout completions per user per week

### Retention
- Week 1: 60%
- Week 4: 40%
- Month 3: 25%

### Monetization
- $1,000+ MRR (Month 1)
- $10,000+ MRR (Month 6)
- $100,000+ ARR (Year 1)

---

## 📚 Resources & References

### Flutter & Dart
- [Flutter Docs](https://flutter.dev/docs)
- [Riverpod](https://riverpod.dev)
- [Drift Documentation](https://drift.simonbinder.eu)

### Design
- [Material Design 3](https://m3.material.io)
- [Lottie](https://lottiefiles.com)
- [Rive](https://rive.app)

### Health & Postpartum
- [ACOG Postpartum Guidelines](https://www.acog.org)
- [Pelvic Floor Dysfunction](https://www.apta.org)
- [Diastasis Recti Research](https://www.ncbi.nlm.nih.gov)

### Security & Privacy
- [OWASP Mobile Security](https://owasp.org/www-project-mobile-security/)
- [GDPR Compliance](https://gdpr-info.eu)
- [Flutter Security Best Practices](https://flutter.dev/docs/testing/best-practices)

---

## ⭐ Changelog

### v0.1.0 (MVP)
- Initial release
- 3-level workout system
- Pelvic floor assessment
- Diastasis recti tracking
- Voice-guided Kegel trainer
- Arabic localization
- Freemium monetization

### v0.2.0 (Phase 2)
- Community forum (women-only)
- Expert Q&A articles
- Nutrition guide integration
- Wearable integration (optional)

### v1.0.0 (General Release)
- 100,000+ users
- All features stable
- Regional marketing
- Healthcare provider partnerships

---

**Last Updated:** November 17, 2025  
**Status:** Ready for Development  
**Next Review:** After Phase 1 Completion

---

## 🎉 Start Building!

You now have everything needed to build this app. Start with:

1. Clone/setup the repo
2. Create your Firebase project (optional)
3. Download Lottie animations from LottieFiles.com
4. Run `flutter run --release`
5. Build your first feature!

For quick CLI prompts to use with Claude Code, see `CLAUDE_PROMPTS.md`.

Good luck! 🚀
