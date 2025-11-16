# Flutter Project Structure - Postpartum Recovery App

## ✅ Project Setup Complete

This document provides an overview of the complete Flutter project structure that has been created.

---

## 📁 Directory Structure

```
Rebuild-Mama/
├── lib/
│   ├── main.dart                          ✅ Entry point with MaterialApp.router
│   ├── firebase_options.dart              ✅ Firebase configuration stub
│   │
│   ├── config/
│   │   ├── app_config.dart               ✅ Environment configuration (dev/staging/prod)
│   │   ├── routes.dart                   ✅ GoRouter setup with all routes
│   │   ├── theme.dart                    ✅ Material 3 theme with pastel colors
│   │   └── constants.dart                ✅ App-wide constants
│   │
│   ├── models/                            ✅ Data models
│   │   ├── workout.dart
│   │   ├── exercise.dart
│   │   ├── user_profile.dart
│   │   ├── progress_data.dart
│   │   └── assessment.dart
│   │
│   ├── database/                          ✅ Drift (SQLite) configuration
│   │   ├── app_database.dart
│   │   ├── migrations/
│   │   └── daos/
│   │       ├── workout_dao.dart
│   │       ├── progress_dao.dart
│   │       ├── exercise_dao.dart
│   │       └── assessment_dao.dart
│   │
│   ├── providers/                         ✅ Riverpod providers
│   │   ├── auth_provider.dart
│   │   ├── database_provider.dart
│   │   ├── workout_provider.dart
│   │   ├── progress_provider.dart
│   │   ├── assessment_provider.dart
│   │   ├── user_preferences_provider.dart
│   │   └── notification_provider.dart
│   │
│   ├── services/                          ✅ Business logic services
│   │   ├── auth_service.dart
│   │   ├── workout_service.dart
│   │   ├── progress_service.dart
│   │   ├── notification_service.dart
│   │   ├── storage_service.dart
│   │   ├── analytics_service.dart
│   │   └── localization_service.dart
│   │
│   ├── ui/
│   │   ├── screens/                       ✅ All screen files
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
│   │   ├── widgets/                       ✅ Reusable widgets
│   │   │   ├── exercise_animation_player.dart
│   │   │   ├── progress_chart_widget.dart
│   │   │   ├── workout_card_widget.dart
│   │   │   ├── timer_widget.dart
│   │   │   ├── kegel_phase_indicator.dart
│   │   │   ├── loading_state_widget.dart
│   │   │   └── error_state_widget.dart
│   │   │
│   │   └── themes/                        ✅ Theme utilities
│   │       ├── app_theme.dart
│   │       ├── colors.dart
│   │       └── typography.dart
│   │
│   ├── l10n/                              ✅ Localization files
│   │   ├── app_en.arb
│   │   └── app_ar.arb
│   │
│   └── utils/                             ✅ Utility functions
│       ├── date_utils.dart
│       ├── formatting_utils.dart
│       ├── validators.dart
│       └── logger.dart
│
├── assets/                                ✅ Asset directories
│   ├── animations/
│   │   ├── level1/
│   │   ├── level2/
│   │   ├── level3/
│   │   └── ui/
│   ├── images/
│   └── translations/
│
├── .env.dev                               ✅ Development environment
├── .env.staging                           ✅ Staging environment
├── .env.prod                              ✅ Production environment
├── pubspec.yaml                           ✅ Dependencies configuration
├── l10n.yaml                              ✅ Localization configuration
├── analysis_options.yaml                  ✅ Linter configuration
├── .gitignore                             ✅ Git ignore rules
└── README.md                              ✅ Project documentation

```

---

## 🎨 Theme System (Material 3)

### Color Palette
- **Primary Pink**: `#FFB6C1`
- **Secondary Peach**: `#FFDAB9`
- **Accent Mint**: `#E0FFF0`
- **Background Soft Gray**: `#F5F5F5`
- **Dark Text**: `#2C3E50`

### Typography
- **Font Family**: Poppins (via Google Fonts)
- **Border Radius**: 16px (rounded corners)
- **Material 3**: Enabled with soft shadows

### Dark Mode
- Warm colors maintained
- Dark background: `#1E1E1E`
- Dark surface: `#2D2D2D`

Location: `lib/config/theme.dart`

---

## 🛣️ Routing (GoRouter)

All routes configured in `lib/config/routes.dart`:

### Authentication
- `/` - Splash Screen
- `/login` - Login
- `/signup` - Sign Up
- `/forgot-password` - Password Reset

### Onboarding
- `/onboarding/delivery-type` - Delivery Type Selection
- `/onboarding/weeks-postpartum` - Weeks Postpartum
- `/onboarding/symptom-assessment` - Symptom Assessment

### Main App
- `/home` - Home Screen
- `/home/level-selection` - Workout Level Selection
- `/home/workout-list` - Workout List

### Workouts
- `/workout/detail` - Workout Detail
- `/workout/exercise` - Exercise Screen
- `/workout/complete` - Workout Complete
- `/workout/kegel-trainer` - Kegel Trainer

### Progress
- `/progress` - Progress Dashboard
- `/progress/diastasis-recti` - Diastasis Recti Tracking
- `/progress/pelvic-floor` - Pelvic Floor Tracking
- `/progress/photo` - Photo Progress

### SOS
- `/sos` - SOS Home
- `/sos/routine` - SOS Routine

### Settings
- `/settings` - Settings
- `/settings/language` - Language Selection
- `/settings/privacy` - Privacy Settings
- `/settings/about` - About

---

## ⚙️ Environment Configuration

Three environment files with `flutter_dotenv`:

### .env.dev (Development)
- Debug mode enabled
- No analytics
- Local API endpoints

### .env.staging (Staging)
- Testing environment
- Analytics enabled
- Staging API endpoints

### .env.prod (Production)
- Production API
- Full analytics
- Optimized settings

Configuration managed in `lib/config/app_config.dart`

---

## 📦 Dependencies (pubspec.yaml)

### State Management
- `flutter_riverpod: ^2.4.9`
- `riverpod_annotation: ^2.3.3`

### Animations
- `lottie: ^3.0.0`
- `rive: ^0.12.4`

### Local Database
- `drift: ^2.14.0`
- `sqlite3_flutter_libs: ^0.5.0`
- `hive: ^2.2.3`
- `hive_flutter: ^1.1.0`
- `flutter_secure_storage: ^9.0.0`

### Firebase (Optional)
- `firebase_core: ^2.24.2`
- `firebase_auth: ^4.15.3`
- `firebase_messaging: ^14.6.0`
- `firebase_analytics: ^10.7.4`

### UI & Charts
- `fl_chart: ^0.66.0`
- `percent_indicator: ^4.2.3`

### Media & Files
- `image_picker: ^1.0.5`
- `cached_network_image: ^3.3.0`
- `path_provider: ^2.1.1`

### Audio & Haptics
- `audioplayers: ^5.2.1`
- `vibration: ^1.8.3`
- `just_audio: ^0.9.36`

### Localization
- `intl: ^0.18.1`
- `flutter_localizations` (SDK)

### Routing
- `go_router: ^13.0.0`

### Environment
- `flutter_dotenv: ^5.1.0`

### Monetization
- `in_app_purchase: ^3.1.11`
- `purchases_flutter: ^6.0.0`

### Encryption
- `encrypt: ^5.0.0`
- `cryptography: ^2.1.0`

### Fonts
- `google_fonts: ^6.1.0`

---

## 🚀 Next Steps

1. **Install Dependencies**
   ```bash
   flutter pub get
   ```

2. **Generate Code** (for Drift, Riverpod, l10n)
   ```bash
   dart run build_runner build --delete-conflicting-outputs
   ```

3. **Generate Localization**
   ```bash
   flutter gen-l10n
   ```

4. **Configure Firebase** (Optional)
   ```bash
   flutterfire configure
   ```
   This will update `lib/firebase_options.dart` with actual credentials.

5. **Add Lottie Animations**
   - Download animations from LottieFiles.com
   - Place in `assets/animations/` folders

6. **Add Images**
   - Add logo and onboarding images to `assets/images/`

7. **Run the App**
   ```bash
   flutter run
   ```

---

## 📝 TODO Comments

All files contain `TODO` comments indicating what needs to be implemented:
- Models: Add `fromJson`, `toJson`, `copyWith` methods
- DAOs: Implement CRUD operations
- Providers: Set up state management logic
- Services: Implement business logic
- Screens: Build UI components
- Widgets: Create reusable components

---

## 🔒 Privacy & Security

- All health data stored locally (Drift database)
- Optional Firebase authentication only
- Encrypted secure storage for tokens
- No cloud sync without explicit consent
- GDPR compliant design

---

## 🌍 Localization

Supported languages:
- **English** (`en`) - `lib/l10n/app_en.arb`
- **Arabic** (`ar`) - `lib/l10n/app_ar.arb` with RTL support

Add more languages by creating additional `.arb` files.

---

## 📊 Project Status

**Status**: ✅ Project structure complete and ready for development

**Created**:
- ✅ Complete folder structure
- ✅ All configuration files
- ✅ All starter files with TODO comments
- ✅ Theme system (Material 3 + Pastels)
- ✅ Routing setup (GoRouter)
- ✅ Environment configuration
- ✅ Localization setup
- ✅ Dependencies configured

**Ready For**:
- ⏳ Dependency installation (`flutter pub get`)
- ⏳ Code generation
- ⏳ Business logic implementation
- ⏳ UI development
- ⏳ Testing

---

## 📞 Support

For questions about the structure or next steps, refer to:
- `README.md` - Full project documentation
- Each file's TODO comments - Implementation guidance
- Flutter documentation - https://flutter.dev

---

**Last Updated**: November 16, 2025
**Structure Version**: 1.0
