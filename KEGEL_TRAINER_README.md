# Kegel Exercise Trainer - Implementation Guide

## Overview

The Kegel Exercise Trainer is a comprehensive, voice-guided pelvic floor exercise trainer with real-time feedback, haptic alerts, and achievement tracking. This implementation includes all requested features and more.

## Features Implemented

### 1. Settings Panel (Top)
- ✅ **Duration slider**: 1-10 minutes with real-time calculation of total reps
- ✅ **Contract time slider**: 3-10 seconds
- ✅ **Hold time slider**: 5-15 seconds
- ✅ **Rest time slider**: 5-15 seconds
- ✅ **Save as preset button**: Saves settings and updates session configuration

### 2. Main Display (Center)

#### Large Circular Progress Indicator (300x300px)
- ✅ Shows current phase progress (0-100%)
- ✅ Color changes per phase:
  - Contracting: Red (#FF6B6B)
  - Holding: Yellow (#FFD93D)
  - Releasing: Green (#6BCB77)
  - Resting: Blue (#4D96FF)
- ✅ Animated pulse effect during active sessions
- ✅ Glowing shadow effect matching phase color

#### Phase Information
- ✅ **Phase label**: "CONTRACT NOW" → "HOLD" → "RELEASE" → "REST"
- ✅ Smooth transitions with AnimatedSwitcher
- ✅ Large, bold text in phase-specific colors

#### Time Display
- ✅ Shows remaining seconds in current phase
- ✅ Updates every 100ms for smooth countdown
- ✅ 72pt bold font for easy visibility

#### Rep Counter
- ✅ Displays "Rep X of Y" format
- ✅ Shows "Ready to start" when idle
- ✅ Updates after each complete cycle

### 3. Controls (Bottom)
- ✅ **Large Start button** with play icon
- ✅ **Pause button** (only when running)
- ✅ **Stop button** (when session active)
- ✅ **Haptics toggle** button
- ✅ **Settings gear icon** in app bar
- ✅ **Mute/Unmute button** in app bar

### 4. Text-to-Speech
- ✅ Uses flutter_tts package
- ✅ Voice guidance for all phases:
  - "Contract your pelvic floor now"
  - "Hold"
  - "Release slowly"
  - "Rest"
- ✅ Encouraging messages: "Great job! X more reps to go!"
- ✅ Session completion announcement
- ✅ Mute/unmute option
- ✅ **Multiple voice types**:
  - Female Calm (slower, higher pitch)
  - Female Motivational (normal speed, higher pitch)
  - Robotic (normal speed, lower pitch)
- ✅ **Language support**: English and Arabic

### 5. Haptic Feedback
- ✅ Uses vibration package
- ✅ Short vibration (100ms) on phase change
- ✅ Long vibration (300ms) on rep completion
- ✅ Extra long vibration (500ms) on session completion
- ✅ Toggle to enable/disable haptics

### 6. Data Logging
- ✅ Saves session to Drift database (kegel_sessions table)
- ✅ Logs: sessionId, userId, duration, reps_completed, startedAt, endedAt
- ✅ Auto-updates database on session completion
- ✅ Integrates with existing KegelSessionDao

### 7. Achievement System
- ✅ **Streak tracking**:
  - 3-day streak notification
  - 7-day streak badge
  - 14-day streak
  - 30-day streak
- ✅ **Rep milestones**:
  - 50 total reps
  - 100 reps
  - 500 reps
- ✅ Displays current streak in UI with fire icon
- ✅ Achievement notifications (ready for awesome_notifications integration)

### 8. UI/UX Features
- ✅ Smooth phase transitions with animations
- ✅ Encouraging messages between reps
- ✅ Dark overlay during session (reduces distractions)
- ✅ Pulse animation on circular progress
- ✅ Phase-specific icons in center
- ✅ Beautiful gradient and shadow effects
- ✅ Responsive layout for all screen sizes

### 9. State Management (Riverpod)
- ✅ **kegelSessionProvider**: Main session state management
- ✅ **kegelStreakProvider**: Computed from session history
- ✅ **kegelSessionsHistoryProvider**: Past sessions
- ✅ **kegelStatisticsProvider**: Overall stats
- ✅ **todayKegelSessionsProvider**: Today's sessions (Stream)
- ✅ **weeklyKegelStatsProvider**: Weekly statistics
- ✅ **monthlyKegelStatsProvider**: Monthly statistics

## Architecture

### File Structure

```
lib/
├── models/
│   └── kegel_session_state.dart        # Session state models
├── providers/
│   ├── kegel_providers.dart            # Riverpod providers
│   └── kegel_session_notifier.dart     # State notifier
├── services/
│   └── tts_service.dart                # Text-to-Speech service
├── ui/screens/workout/
│   └── kegel_trainer_screen.dart       # Main UI screen
└── database/
    ├── app_database.dart               # Database (already exists)
    └── daos/
        └── kegel_session_dao.dart      # DAO (already exists)
```

### State Flow

```
User Action → KegelSessionNotifier → Update State → UI Updates
                     ↓
              Database Save → Achievement Check
                     ↓
              TTS Service → Voice Guidance
                     ↓
              Vibration → Haptic Feedback
```

## Setup Instructions

### 1. Install Dependencies

Run the following command to install the new dependency:

```bash
flutter pub get
```

### 2. Generate Database Code

If the database schema was modified, regenerate the code:

```bash
dart run build_runner build --delete-conflicting-outputs
```

### 3. Usage

Navigate to the Kegel Trainer screen from your app's navigation. The screen is located at:

```dart
import 'package:postpartum_recovery_app/ui/screens/workout/kegel_trainer_screen.dart';

// In your router or navigation
Navigator.push(
  context,
  MaterialPageRoute(builder: (context) => const KegelTrainerScreen()),
);
```

## API Reference

### KegelSettings

Configuration for a Kegel exercise session.

```dart
const settings = KegelSettings(
  durationMinutes: 5,      // 1-10 minutes
  contractSeconds: 5,      // 3-10 seconds
  holdSeconds: 10,         // 5-15 seconds
  restSeconds: 10,         // 5-15 seconds
);
```

### TTSService

Text-to-Speech service for voice guidance.

```dart
final ttsService = TTSService();

// Initialize
await ttsService.initialize();

// Speak phases
await ttsService.speakContract();
await ttsService.speakHold();
await ttsService.speakRelease();
await ttsService.speakRest();

// Set voice type
await ttsService.setVoiceType(VoiceType.femalCalm);

// Set language
await ttsService.setLanguage(TTSLanguage.english);

// Toggle mute
await ttsService.toggleMute();
```

### KegelSessionNotifier

Manages the Kegel exercise session.

```dart
// Start session
ref.read(kegelSessionProvider.notifier).startSession();

// Pause session
ref.read(kegelSessionProvider.notifier).pauseSession();

// Stop session
ref.read(kegelSessionProvider.notifier).stopSession();

// Update settings
ref.read(kegelSessionProvider.notifier).updateSettings(settings);

// Toggle haptics
ref.read(kegelSessionProvider.notifier).toggleHaptics();
```

## Database Schema

The Kegel sessions are stored in the `kegel_sessions` table:

```sql
CREATE TABLE kegel_sessions (
  session_id INTEGER PRIMARY KEY AUTOINCREMENT,
  user_id INTEGER NOT NULL,
  duration_minutes INTEGER NOT NULL,
  reps_completed INTEGER NOT NULL,
  started_at DATETIME NOT NULL,
  ended_at DATETIME NOT NULL,
  FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE
);
```

## Statistics & Analytics

The KegelSessionDao provides comprehensive statistics:

- **Total sessions**: Total number of Kegel sessions
- **Total time**: Total minutes spent exercising
- **Total reps**: Total reps completed
- **Average duration**: Average session length
- **Average reps**: Average reps per session
- **Streak**: Consecutive days with sessions
- **Weekly stats**: Sessions, duration, and reps this week
- **Monthly stats**: Sessions, duration, and reps this month

## Customization

### Adding Custom Voice Messages

Edit `lib/services/tts_service.dart` and add new methods:

```dart
Future<void> speakCustomMessage(String message) async {
  final text = _language == TTSLanguage.english
      ? message
      : translateToArabic(message);
  await speak(text);
}
```

### Adding New Achievements

Edit `lib/providers/kegel_session_notifier.dart` in the `_checkAchievements` method:

```dart
// Add new milestone
if (totalReps >= 1000 && totalReps < 1010) {
  await _showAchievement('1000 reps!', '🏆');
}
```

### Customizing Phase Colors

Edit `lib/models/kegel_session_state.dart` in the `getPhaseColor` method:

```dart
Color getPhaseColor() {
  switch (currentPhase) {
    case KegelPhase.contract:
      return const Color(0xFFYOURCOLOR);
    // ...
  }
}
```

## Testing

### Manual Testing Checklist

- [ ] Settings panel opens and closes
- [ ] All sliders adjust correctly
- [ ] Save settings button works
- [ ] Start button begins session
- [ ] Pause button pauses session
- [ ] Resume button continues session
- [ ] Stop button ends session
- [ ] Voice guidance speaks at phase changes
- [ ] Mute/unmute works
- [ ] Haptic feedback vibrates at phase changes
- [ ] Rep counter increments correctly
- [ ] Circular progress updates smoothly
- [ ] Phase colors change correctly
- [ ] Encouraging messages display
- [ ] Session saves to database
- [ ] Streak displays correctly
- [ ] Achievements trigger

### Unit Testing

Create tests in `test/providers/kegel_session_notifier_test.dart`:

```dart
test('Session starts with correct initial state', () {
  // Test implementation
});

test('Phase advances correctly', () {
  // Test implementation
});
```

## Performance Considerations

- **Timer frequency**: Updates every 100ms for smooth UI
- **Database writes**: Only on session start and completion
- **TTS**: Async operations don't block UI
- **Vibration**: Try-catch to handle unsupported devices
- **Animations**: Hardware-accelerated with Transform.scale

## Troubleshoots

### Voice not working
- Check device volume
- Ensure TTS is initialized
- Verify not muted in app
- Check language is supported on device

### Haptics not working
- Some devices don't support vibration
- Check app permissions
- Try toggling haptics off and on

### Database errors
- Run build_runner to regenerate code
- Check userId is valid
- Verify foreign key constraints

## Future Enhancements

1. **Background audio**: Continue session when screen is locked
2. **Notification controls**: Control session from notification
3. **Custom presets**: Save multiple preset configurations
4. **Social sharing**: Share achievements with friends
5. **Calendar view**: Visual calendar of completed sessions
6. **Reminders**: Daily reminder notifications
7. **Progress charts**: Visual charts of progress over time
8. **Export data**: Export session data to CSV/JSON

## Dependencies Added

```yaml
flutter_tts: ^4.0.2  # Text-to-Speech
```

Existing dependencies used:
- `vibration: ^1.8.3` - Haptic feedback
- `flutter_riverpod: ^2.4.9` - State management
- `drift: ^2.14.0` - Database
- `google_fonts: ^6.1.0` - Typography
- `shared_preferences: ^2.2.2` - Settings persistence

## License

This implementation is part of the Postpartum Recovery App project.

## Support

For issues or questions, please refer to the main project documentation.
