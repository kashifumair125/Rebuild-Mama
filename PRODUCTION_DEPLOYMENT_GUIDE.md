# Production Deployment Guide - Rebuild-Mama App

## Table of Contents
1. [Prerequisites](#prerequisites)
2. [Pre-Deployment Checklist](#pre-deployment-checklist)
3. [Environment Setup](#environment-setup)
4. [Firebase Configuration](#firebase-configuration)
5. [Code Signing & Certificates](#code-signing--certificates)
6. [Building for Production](#building-for-production)
7. [Testing](#testing)
8. [App Store Submission](#app-store-submission)
9. [Google Play Store Submission](#google-play-store-submission)
10. [Post-Deployment](#post-deployment)
11. [Monitoring & Maintenance](#monitoring--maintenance)

---

## Prerequisites

### Required Tools
- Flutter SDK 3.0+ installed and configured
- Xcode 14+ (for iOS deployment)
- Android Studio with Android SDK 33+ (for Android deployment)
- Firebase account and project
- Apple Developer Account ($99/year)
- Google Play Developer Account ($25 one-time)

### Development Environment
```bash
# Verify Flutter installation
flutter doctor -v

# Check Flutter version
flutter --version

# Ensure all dependencies are installed
flutter pub get

# Run code generation
dart run build_runner build --delete-conflicting-outputs
```

---

## Pre-Deployment Checklist

### ✅ Code Quality
- [ ] All TODOs resolved or documented
- [ ] No debug print statements (use AppLogger instead)
- [ ] All tests passing
- [ ] Code linted and formatted (`flutter analyze`)
- [ ] No security vulnerabilities (API keys, secrets)
- [ ] Error handling implemented for all critical paths
- [ ] Proper logging configured

### ✅ Configuration
- [ ] Environment variables configured (`.env.prod`)
- [ ] Firebase project created and configured
- [ ] Analytics enabled
- [ ] Crash reporting enabled
- [ ] Debug banner disabled in production

### ✅ Assets
- [ ] All required images optimized
- [ ] Lottie animations compressed
- [ ] App icons generated (1024x1024 for iOS, various for Android)
- [ ] Splash screen configured
- [ ] Localization files complete

### ✅ Compliance
- [ ] Privacy Policy written and hosted
- [ ] Terms of Service written and hosted
- [ ] GDPR compliance (if applicable)
- [ ] HIPAA compliance reviewed (health app)
- [ ] Age rating determined
- [ ] App Store guidelines reviewed

---

## Environment Setup

### 1. Configure Production Environment

Edit `.env.prod`:

```env
# App Configuration
APP_NAME=Postpartum Recovery
ENVIRONMENT=production

# API Configuration (update with your actual API URL)
API_BASE_URL=https://api.rebuildmama.com
API_TIMEOUT=30000

# Firebase Configuration
ENABLE_FIREBASE=true
ENABLE_ANALYTICS=true
ENABLE_CRASH_REPORTING=true

# RevenueCat Configuration (if using subscriptions)
REVENUECAT_API_KEY=your_production_revenuecat_key

# Debug (MUST be false in production)
DEBUG_MODE=false
SHOW_DEBUG_BANNER=false
```

### 2. Update main.dart for Production

In `lib/main.dart`, change the environment:

```dart
// Change from:
const environment = Environment.dev;

// To:
const environment = Environment.prod;
```

Or use build flavors (recommended):

```bash
flutter run --flavor prod
```

---

## Firebase Configuration

### 1. Create Firebase Project

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Create a new project: "Rebuild-Mama-Production"
3. Enable Analytics
4. Add iOS and Android apps

### 2. Configure Firebase CLI

```bash
# Install Firebase CLI
npm install -g firebase-tools

# Login to Firebase
firebase login

# Install FlutterFire CLI
dart pub global activate flutterfire_cli

# Configure Firebase for your Flutter project
flutterfire configure --project=rebuild-mama-production
```

This will generate `lib/firebase_options.dart` with actual credentials.

### 3. Enable Firebase Services

Enable these services in Firebase Console:

- **Authentication**
  - Email/Password
  - Google Sign-In
  - Apple Sign-In (for iOS)

- **Firestore** (optional, for cloud sync)
  - Create indexes
  - Set security rules

- **Cloud Messaging** (for push notifications)
  - Generate APNs certificates (iOS)
  - Configure FCM (Android)

- **Analytics**
  - Enable events tracking
  - Set up conversion tracking

- **Crashlytics**
  - Enable crash reporting
  - Configure symbolication

### 4. Security Rules (Firestore)

If using Firestore, set secure rules:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // User data - only readable/writable by the user
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }

    // Progress data - only readable/writable by the user
    match /progress/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
  }
}
```

---

## Code Signing & Certificates

### iOS Code Signing

1. **Apple Developer Account**
   - Sign up at [developer.apple.com](https://developer.apple.com)
   - Pay $99/year fee

2. **Create App ID**
   - Bundle ID: `com.rebuildmama.recovery`
   - Enable capabilities:
     - Push Notifications
     - Sign in with Apple
     - HealthKit (if needed)

3. **Create Certificates**
   - Development Certificate
   - Distribution Certificate
   - Push Notification Certificate

4. **Create Provisioning Profiles**
   - Development Profile
   - App Store Distribution Profile

5. **Configure Xcode**
   ```bash
   cd ios
   open Runner.xcworkspace
   ```
   - Select your team
   - Enable automatic signing
   - Configure signing certificates

### Android Code Signing

1. **Create Keystore**
   ```bash
   keytool -genkey -v -keystore ~/upload-keystore.jks \
     -keyalg RSA -keysize 2048 -validity 10000 \
     -alias upload
   ```

2. **Create key.properties**

   Create `android/key.properties`:
   ```properties
   storePassword=<password>
   keyPassword=<password>
   keyAlias=upload
   storeFile=<path-to-upload-keystore.jks>
   ```

3. **Configure build.gradle**

   Edit `android/app/build.gradle`:
   ```gradle
   def keystoreProperties = new Properties()
   def keystorePropertiesFile = rootProject.file('key.properties')
   if (keystorePropertiesFile.exists()) {
       keystoreProperties.load(new FileInputStream(keystorePropertiesFile))
   }

   android {
       ...
       signingConfigs {
           release {
               keyAlias keystoreProperties['keyAlias']
               keyPassword keystoreProperties['keyPassword']
               storeFile keystoreProperties['storeFile'] ? file(keystoreProperties['storeFile']) : null
               storePassword keystoreProperties['storePassword']
           }
       }
       buildTypes {
           release {
               signingConfig signingConfigs.release
           }
       }
   }
   ```

4. **IMPORTANT**: Add to `.gitignore`:
   ```
   android/key.properties
   *.jks
   *.keystore
   ```

---

## Building for Production

### iOS Build

```bash
# Clean build
flutter clean
flutter pub get
dart run build_runner build --delete-conflicting-outputs

# Build iOS app
flutter build ios --release --no-codesign

# OR build IPA directly
flutter build ipa --release

# The IPA will be in: build/ios/ipa/
```

### Android Build

```bash
# Clean build
flutter clean
flutter pub get
dart run build_runner build --delete-conflicting-outputs

# Build APK (for testing)
flutter build apk --release

# Build App Bundle (for Play Store - RECOMMENDED)
flutter build appbundle --release

# The AAB will be in: build/app/outputs/bundle/release/
```

### Build Size Optimization

To reduce app size:

```bash
# Build with tree-shake-icons (removes unused icons)
flutter build apk --release --tree-shake-icons

# Build with split-per-abi (separate APKs per architecture)
flutter build apk --release --split-per-abi
```

---

## Testing

### Pre-Release Testing Checklist

#### Functional Testing
- [ ] User registration and login
- [ ] Onboarding flow
- [ ] All workout levels (1, 2, 3)
- [ ] Exercise animations play correctly
- [ ] Kegel trainer with voice guidance
- [ ] SOS emergency routines
- [ ] Progress tracking and charts
- [ ] Database operations (CRUD)
- [ ] Offline functionality
- [ ] Push notifications
- [ ] Deep linking (if implemented)

#### Performance Testing
- [ ] App launches in < 3 seconds
- [ ] No memory leaks
- [ ] Database queries optimized
- [ ] Smooth 60fps animations
- [ ] Battery consumption acceptable
- [ ] Network usage minimal

#### Platform Testing
- [ ] iOS 13+ (various versions)
- [ ] Android 8.0+ (various versions)
- [ ] iPhone SE, iPhone 14, iPhone 14 Pro Max
- [ ] Various Android devices (Samsung, Pixel, etc.)
- [ ] Tablet support (if applicable)

#### Error Handling Testing
- [ ] Network connectivity loss
- [ ] Database corruption
- [ ] Invalid user input
- [ ] App backgrounding/foregrounding
- [ ] Low memory situations
- [ ] Permission denials

### Beta Testing

#### iOS TestFlight

```bash
# Upload to App Store Connect
flutter build ipa --release

# Then use Transporter app or Application Loader
```

1. Go to App Store Connect
2. Create app record
3. Upload build via Transporter
4. Add to TestFlight
5. Invite beta testers
6. Collect feedback

#### Android Internal Testing

```bash
# Upload to Play Console
flutter build appbundle --release
```

1. Go to Play Console
2. Create app
3. Upload AAB to Internal Testing track
4. Add testers
5. Share testing link
6. Collect feedback

---

## App Store Submission

### App Store Connect Setup

1. **App Information**
   - Name: Postpartum Recovery - Rebuild Mama
   - Subtitle: Evidence-Based Postpartum Fitness
   - Category: Health & Fitness
   - Age Rating: 12+ (Medical/Treatment info)

2. **Privacy Policy**
   - Host on your website
   - Include:
     - Data collection practices
     - Firebase usage
     - HealthKit data (if used)
     - User rights (GDPR)

3. **App Description**

   Example:
   ```
   Rebuild Mama is your scientifically-backed companion for postpartum recovery.

   Features:
   • 3 progressive workout levels tailored to your recovery stage
   • Pelvic floor strengthening with guided Kegel exercises
   • Diastasis recti assessment and tracking
   • SOS emergency relief routines
   • Offline-first: works without internet
   • Privacy-focused: your data stays on your device

   Designed for:
   • Women recovering from vaginal delivery
   • C-section recovery (consult your doctor)
   • 6+ weeks postpartum (or per doctor's clearance)

   IMPORTANT: Always consult your healthcare provider before starting any postpartum exercise program.
   ```

4. **Screenshots** (Required sizes)
   - iPhone 6.7": 1290 x 2796 pixels (iPhone 14 Pro Max)
   - iPhone 6.5": 1242 x 2688 pixels (iPhone 11 Pro Max)
   - iPhone 5.5": 1242 x 2208 pixels (iPhone 8 Plus)
   - iPad Pro 12.9": 2048 x 2732 pixels

5. **App Preview Videos** (Optional but recommended)
   - 15-30 seconds
   - Show key features
   - No third-party trademarks

### Submission Process

1. Upload build via Transporter
2. Select build in App Store Connect
3. Fill all required information
4. Submit for review
5. Wait 1-3 days for review
6. Address any issues
7. App goes live!

### App Review Guidelines

**Common Rejection Reasons:**
- Missing privacy policy
- HealthKit data misuse
- Incomplete app information
- Crashes on launch
- Misleading medical claims

**Tips for Approval:**
- Test thoroughly on real devices
- Provide demo account if login required
- Include clear disclaimers for health advice
- Ensure all links work
- Follow Human Interface Guidelines

---

## Google Play Store Submission

### Play Console Setup

1. **Create App**
   - App name: Postpartum Recovery - Rebuild Mama
   - Default language: English
   - App or game: App
   - Free or paid: Free (or Paid)

2. **Store Listing**

   **Short description (80 chars):**
   ```
   Evidence-based postpartum recovery program for new mothers
   ```

   **Full description (4000 chars):**
   ```
   Rebuild Mama is your comprehensive postpartum recovery companion, designed
   by fitness experts and validated by healthcare professionals.

   FEATURES:
   ✓ 3 Progressive Workout Levels
   ✓ Pelvic Floor Strengthening
   ✓ Diastasis Recti Assessment
   ✓ Emergency Relief Routines
   ✓ Offline-First Design
   ✓ Privacy-Focused

   [More details...]

   DISCLAIMER: This app is not a substitute for professional medical advice.
   Always consult your healthcare provider before beginning any exercise program.
   ```

3. **Graphics**

   **Icon:** 512 x 512 pixels (PNG)
   **Feature Graphic:** 1024 x 500 pixels
   **Screenshots:**
   - Phone: 16:9 or 9:16 aspect ratio
   - Tablet (optional): 16:9 or 9:16 aspect ratio
   - Minimum 2, maximum 8 screenshots

4. **Categorization**
   - Category: Health & Fitness
   - Tags: postpartum, recovery, fitness, pelvic floor

5. **Contact Details**
   - Email: support@rebuildmama.com
   - Website: https://rebuildmama.com
   - Privacy policy: https://rebuildmama.com/privacy

### Content Rating

Complete questionnaire honestly:
- Violence: None
- Sexual Content: None (or Educational)
- Language: None
- Controlled Substances: None
- Health/Medical: Yes (fitness and health tracking)

Likely rating: **Everyone** or **Teen**

### Submission Process

1. Complete all store listing sections
2. Upload AAB to Production track
3. Set release name and notes
4. Review and roll out
5. Wait for review (usually 1-2 days)
6. Address any issues
7. App goes live!

---

## Post-Deployment

### Immediate Actions

- [ ] Test production app on real devices
- [ ] Verify analytics tracking
- [ ] Test push notifications
- [ ] Monitor crash reports
- [ ] Check user reviews
- [ ] Monitor server logs (if applicable)

### First Week

- [ ] Respond to user reviews
- [ ] Fix critical bugs
- [ ] Monitor performance metrics
- [ ] Track user acquisition
- [ ] Gather user feedback

### Ongoing

- [ ] Weekly analytics review
- [ ] Monthly performance review
- [ ] Quarterly feature updates
- [ ] Address user feedback
- [ ] Security updates

---

## Monitoring & Maintenance

### Analytics (Firebase Analytics)

Key metrics to track:
- Daily Active Users (DAU)
- Monthly Active Users (MAU)
- Session duration
- Retention rate (Day 1, Day 7, Day 30)
- Workout completion rate
- Feature usage (Kegel trainer, SOS routines, etc.)
- Crash-free users percentage

### Crash Reporting (Firebase Crashlytics)

- Monitor crash-free users (target: >99%)
- Fix critical crashes within 24 hours
- Prioritize crashes affecting >1% of users
- Track crash trends over time

### Performance Monitoring

- App startup time (target: <3s)
- Screen rendering (target: 60fps)
- Network request latency
- Database query performance

### User Feedback

- Monitor app store reviews
- Respond to all reviews within 48 hours
- Create feedback loop
- Implement most requested features

### Regular Updates

**Monthly:**
- Bug fixes
- Performance improvements
- Minor feature updates

**Quarterly:**
- Major feature releases
- UI/UX improvements
- New workout content

**Yearly:**
- Platform updates (new iOS/Android versions)
- Dependency updates
- Security audits

---

## Troubleshooting Common Issues

### Build Failures

**Problem:** Gradle build fails
```bash
# Solution: Clean and rebuild
cd android
./gradlew clean
cd ..
flutter clean
flutter pub get
flutter build appbundle --release
```

**Problem:** iOS build fails
```bash
# Solution: Clean Xcode build
cd ios
rm -rf Pods
rm Podfile.lock
pod install
cd ..
flutter clean
flutter pub get
flutter build ios --release
```

### App Store Rejection

**Problem:** "App crashes on launch"
- Test on all required device sizes
- Check for missing assets
- Review error logs

**Problem:** "Privacy policy missing or incomplete"
- Ensure policy is accessible
- Include all required disclosures
- Update app description

### Google Play Rejection

**Problem:** "Missing required permissions declaration"
- Review AndroidManifest.xml
- Add permission descriptions
- Remove unused permissions

**Problem:** "Target SDK version too low"
```xml
<!-- In android/app/build.gradle -->
android {
    compileSdkVersion 33
    ...
    defaultConfig {
        targetSdkVersion 33
    }
}
```

---

## Emergency Procedures

### Critical Bug in Production

1. **Assess severity**
   - Crashes affecting >5% of users: CRITICAL
   - Data loss: CRITICAL
   - Security vulnerability: CRITICAL

2. **Immediate actions**
   - Create hotfix branch
   - Fix and test thoroughly
   - Build new version
   - Submit expedited review (if available)

3. **Communication**
   - Notify users via in-app message
   - Post on social media
   - Update app store description
   - Email affected users (if possible)

### Rollback Procedure

**iOS:**
- Can't rollback (old versions are removed)
- Must submit new build

**Android:**
- Can promote previous version
- Go to Play Console → Production → Releases
- Select previous version and promote

---

## Checklist: Final Pre-Launch Review

### Code
- [ ] All error handling in place
- [ ] Logging configured for production
- [ ] No debug code
- [ ] Environment set to production
- [ ] API endpoints correct

### Assets
- [ ] App icons (all sizes)
- [ ] Screenshots (all required sizes)
- [ ] Feature graphics
- [ ] Promotional materials

### Legal
- [ ] Privacy Policy live
- [ ] Terms of Service live
- [ ] Disclaimers in app
- [ ] Compliance reviews complete

### Services
- [ ] Firebase configured
- [ ] Analytics working
- [ ] Crashlytics working
- [ ] Push notifications working
- [ ] Deep linking working (if applicable)

### Stores
- [ ] App Store listing complete
- [ ] Play Store listing complete
- [ ] Screenshots uploaded
- [ ] Descriptions finalized
- [ ] Categories selected
- [ ] Content rating obtained

### Testing
- [ ] All features tested
- [ ] Performance acceptable
- [ ] Battery usage acceptable
- [ ] Beta testing complete
- [ ] Feedback addressed

---

## Support & Resources

### Documentation
- [Flutter Deployment Docs](https://docs.flutter.dev/deployment)
- [Firebase Setup](https://firebase.google.com/docs/flutter/setup)
- [App Store Review Guidelines](https://developer.apple.com/app-store/review/guidelines/)
- [Google Play Policies](https://play.google.com/about/developer-content-policy/)

### Community
- Flutter Discord
- Stack Overflow (tag: flutter)
- Reddit r/FlutterDev

### Professional Help
- Consider hiring:
  - App Store Optimization (ASO) expert
  - Marketing consultant
  - Legal counsel for compliance

---

## Congratulations!

You're ready to deploy Rebuild-Mama to production! 🎉

Remember:
- Test thoroughly
- Monitor closely
- Iterate quickly
- Listen to users
- Stay compliant

Good luck with your launch! 🚀
