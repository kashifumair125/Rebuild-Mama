# Production Readiness TODO - Rebuild Mama

## ✅ Completed Tasks

### Build Errors Fixed
- ✅ Fixed `databaseProvider` undefined errors (changed to `appDatabaseProvider`)
- ✅ Fixed `User.id` errors (changed to `User.uid` with proper Firebase auth integration)
- ✅ Fixed `Workout.id` errors (changed to `Workout.workoutId`)
- ✅ Fixed `AppColors.primary` missing errors (added primary color constant)

### Settings Pages Implemented
- ✅ Privacy Policy page with comprehensive privacy information
- ✅ About page with app information, mission, and contact details
- ✅ Language settings page (UI ready, currently English only)
- ✅ Edit Profile page with name and email editing
- ✅ Change Password page with validation
- ✅ Send Feedback page with email integration (kashifumair1011@gmail.com)

### Dependencies Added
- ✅ `google_sign_in: ^6.2.1` - For Google authentication
- ✅ `local_auth: ^2.3.0` - For biometric/fingerprint authentication

## 🔨 Remaining Implementation Tasks

### 1. Google Sign-In Implementation

#### A. Configure Firebase Console
1. Go to Firebase Console (https://console.firebase.google.com)
2. Select your project "Rebuild Mama"
3. Navigate to Authentication > Sign-in method
4. Enable Google Sign-In provider
5. Download the updated `google-services.json` (Android) and `GoogleService-Info.plist` (iOS)
6. Place these files in the correct locations:
   - Android: `android/app/google-services.json`
   - iOS: `ios/Runner/GoogleService-Info.plist`

#### B. Update Android Configuration
Add to `android/app/build.gradle`:
```gradle
dependencies {
    // Add this line
    implementation 'com.google.android.gms:play-services-auth:20.7.0'
}
```

#### C. Implement Google Sign-In in AuthService
Add to `lib/services/auth_service.dart`:

```dart
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  
  /// Sign in with Google
  Future<User> signInWithGoogle() async {
    try {
      // Trigger Google Sign-In flow
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      
      if (googleUser == null) {
        throw Exception('Google sign-in was cancelled');
      }

      // Obtain auth details
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      // Create credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase with credential
      final UserCredential userCredential = 
          await _auth.signInWithCredential(credential);

      if (userCredential.user == null) {
        throw Exception('Failed to sign in with Google');
      }

      // Create or update user in Firestore
      await _createOrUpdateUserDocument(userCredential.user!);

      return userCredential.user!;
    } catch (e) {
      throw Exception('Google sign-in failed: $e');
    }
  }

  /// Sign out from Google
  Future<void> signOutGoogle() async {
    await _googleSignIn.signOut();
  }
}
```

#### D. Add Google Sign-In Button to Login Screen
Add after the "OR" divider in `lib/ui/screens/auth/login_screen.dart`:

```dart
// Google Sign-In Button
OutlinedButton.icon(
  onPressed: _isLoading ? null : _handleGoogleSignIn,
  icon: Image.asset(
    'assets/images/google_logo.png',
    height: 24,
  ),
  label: const Text('Continue with Google'),
  style: OutlinedButton.styleFrom(
    padding: const EdgeInsets.symmetric(vertical: 16),
  ),
),
```

Add the handler method:
```dart
Future<void> _handleGoogleSignIn() async {
  setState(() => _isLoading = true);

  try {
    final authService = ref.read(authServiceProvider);
    await authService.signInWithGoogle();

    if (!mounted) return;
    context.go(AppRouter.home);
  } catch (e) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Google sign-in failed: ${e.toString()}'),
        backgroundColor: Theme.of(context).colorScheme.error,
      ),
    );
  } finally {
    if (mounted) {
      setState(() => _isLoading = false);
    }
  }
}
```

#### E. Add Google Logo Asset
1. Download Google logo from official brand resources
2. Place in `assets/images/google_logo.png`
3. Update `pubspec.yaml`:
```yaml
flutter:
  assets:
    - assets/images/google_logo.png
```

### 2. Biometric Authentication Implementation

#### A. Configure Platform Permissions

**Android** - Add to `android/app/src/main/AndroidManifest.xml`:
```xml
<manifest>
    <uses-permission android:name="android.permission.USE_BIOMETRIC"/>
    <uses-permission android:name="android.permission.USE_FINGERPRINT"/>
</manifest>
```

**iOS** - Add to `ios/Runner/Info.plist`:
```xml
<key>NSFaceIDUsageDescription</key>
<string>We need Face ID/Touch ID to secure your account</string>
```

#### B. Create Biometric Auth Service
Create `lib/services/biometric_service.dart`:

```dart
import 'package:local_auth/local_auth.dart';
import 'package:local_auth_android/local_auth_android.dart';
import 'package:local_auth_ios/local_auth_ios.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class BiometricService {
  final LocalAuthentication _localAuth = LocalAuthentication();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  
  static const String _biometricEnabledKey = 'biometric_enabled';
  
  /// Check if biometric authentication is available
  Future<bool> isBiometricAvailable() async {
    try {
      return await _localAuth.canCheckBiometrics;
    } catch (e) {
      return false;
    }
  }
  
  /// Get available biometric types
  Future<List<BiometricType>> getAvailableBiometrics() async {
    try {
      return await _localAuth.getAvailableBiometrics();
    } catch (e) {
      return [];
    }
  }
  
  /// Authenticate with biometrics
  Future<bool> authenticate() async {
    try {
      return await _localAuth.authenticate(
        localizedReason: 'Please authenticate to access your account',
        authMessages: const <AuthMessages>[
          AndroidAuthMessages(
            signInTitle: 'Biometric Authentication',
            cancelButton: 'Cancel',
          ),
          IOSAuthMessages(
            cancelButton: 'Cancel',
          ),
        ],
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: true,
        ),
      );
    } catch (e) {
      return false;
    }
  }
  
  /// Check if biometric is enabled
  Future<bool> isBiometricEnabled() async {
    final enabled = await _storage.read(key: _biometricEnabledKey);
    return enabled == 'true';
  }
  
  /// Enable biometric authentication
  Future<void> enableBiometric() async {
    await _storage.write(key: _biometricEnabledKey, value: 'true');
  }
  
  /// Disable biometric authentication
  Future<void> disableBiometric() async {
    await _storage.delete(key: _biometricEnabledKey);
  }
}
```

#### C. Create Biometric Provider
Create `lib/providers/biometric_provider.dart`:

```dart
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../services/biometric_service.dart';

part 'biometric_provider.g.dart';

@riverpod
BiometricService biometricService(BiometricServiceRef ref) {
  return BiometricService();
}

@riverpod
Future<bool> isBiometricAvailable(IsBiometricAvailableRef ref) async {
  final service = ref.watch(biometricServiceProvider);
  return service.isBiometricAvailable();
}

@riverpod
Future<bool> isBiometricEnabled(IsBiometricEnabledRef ref) async {
  final service = ref.watch(biometricServiceProvider);
  return service.isBiometricEnabled();
}
```

#### D. Add Biometric Lock Screen
Create `lib/ui/screens/auth/biometric_lock_screen.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../config/routes.dart';
import '../../../providers/biometric_provider.dart';

class BiometricLockScreen extends ConsumerStatefulWidget {
  const BiometricLockScreen({super.key});

  @override
  ConsumerState<BiometricLockScreen> createState() => _BiometricLockScreenState();
}

class _BiometricLockScreenState extends ConsumerState<BiometricLockScreen> {
  @override
  void initState() {
    super.initState();
    _authenticateWithBiometric();
  }

  Future<void> _authenticateWithBiometric() async {
    final service = ref.read(biometricServiceProvider);
    
    final authenticated = await service.authenticate();
    
    if (authenticated && mounted) {
      context.go(AppRouter.home);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.fingerprint,
              size: 80,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(height: 24),
            Text(
              'Unlock with Biometrics',
              style: theme.textTheme.headlineSmall,
            ),
            const SizedBox(height: 48),
            ElevatedButton.icon(
              onPressed: _authenticateWithBiometric,
              icon: const Icon(Icons.fingerprint),
              label: const Text('Authenticate'),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () => context.go(AppRouter.login),
              child: const Text('Use Password Instead'),
            ),
          ],
        ),
      ),
    );
  }
}
```

#### E. Add Biometric Settings Option
Add to Settings screen in `lib/ui/screens/settings/settings_screen.dart`:

```dart
// Add this in the Account section, after Change Password
final biometricAvailable = ref.watch(isBiometricAvailableProvider);
final biometricEnabled = ref.watch(isBiometricEnabledProvider);

biometricAvailable.when(
  data: (available) {
    if (available) {
      return SwitchListTile(
        title: const Text('Biometric Lock'),
        subtitle: const Text('Use fingerprint/face ID to unlock app'),
        secondary: Icon(
          Icons.fingerprint,
          color: theme.colorScheme.primary,
        ),
        value: biometricEnabled.value ?? false,
        onChanged: (value) async {
          final service = ref.read(biometricServiceProvider);
          if (value) {
            final authenticated = await service.authenticate();
            if (authenticated) {
              await service.enableBiometric();
              ref.invalidate(isBiometricEnabledProvider);
            }
          } else {
            await service.disableBiometric();
            ref.invalidate(isBiometricEnabledProvider);
          }
        },
      );
    }
    return const SizedBox.shrink();
  },
  loading: () => const SizedBox.shrink(),
  error: (_, __) => const SizedBox.shrink(),
),
```

#### F. Update App Initialization
Modify `lib/ui/screens/splash_screen.dart` to check biometric status:

```dart
Future<void> _initializeApp() async {
  // ... existing initialization
  
  // Check if biometric is enabled
  final biometricService = ref.read(biometricServiceProvider);
  final biometricEnabled = await biometricService.isBiometricEnabled();
  
  if (user != null && biometricEnabled) {
    // Show biometric lock screen
    context.go('/biometric-lock');
  } else if (user != null) {
    context.go(AppRouter.home);
  } else {
    context.go(AppRouter.login);
  }
}
```

### 3. Additional Production Tasks

#### A. Run Code Generation
```bash
flutter pub get
flutter pub run build_runner build --delete-conflicting-outputs
```

#### B. Test the Application
```bash
flutter test
flutter run --release
```

#### C. Update App Icons and Splash Screen
- Use `flutter_launcher_icons` package to generate app icons
- Use `flutter_native_splash` package for splash screens

#### D. Configure App Signing (Android)
1. Create keystore for release builds
2. Update `android/key.properties`
3. Configure `android/app/build.gradle`

#### E. Configure App Store Metadata
- Prepare app screenshots
- Write app description
- Add privacy policy URL

## 📝 Notes

### Important Considerations
1. **User ID Mapping**: The app currently uses a hash of Firebase UID to map to database integer IDs. For production, consider:
   - Using Firebase UID directly (change database schema to use String)
   - Or implement a proper user mapping table

2. **Email Verification**: Implement email verification flow for new users

3. **Password Reset**: Complete the forgot password screen implementation

4. **Offline Support**: Test and ensure offline functionality works correctly

5. **Error Handling**: Add comprehensive error handling and user-friendly error messages

6. **Analytics**: Configure Firebase Analytics events for key user actions

7. **Crash Reporting**: Set up Firebase Crashlytics

### Testing Checklist
- [ ] Test all navigation flows
- [ ] Test form validations
- [ ] Test Google Sign-In on both Android and iOS
- [ ] Test biometric authentication on physical devices
- [ ] Test offline mode
- [ ] Test on different screen sizes
- [ ] Test with different Android/iOS versions
- [ ] Performance testing
- [ ] Security audit

## 🚀 Deployment

### Android
```bash
flutter build appbundle --release
```
Upload to Google Play Console

### iOS
```bash
flutter build ipa --release
```
Upload to App Store Connect

## 📧 Support Contact
For questions or issues: kashifumair1011@gmail.com
