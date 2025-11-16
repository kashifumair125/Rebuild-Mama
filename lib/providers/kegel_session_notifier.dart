import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vibration/vibration.dart';
import 'package:drift/drift.dart' as drift;

import '../models/kegel_session_state.dart';
import '../services/tts_service.dart';
import '../database/app_database.dart';
import 'database_provider.dart';

/// Kegel session state notifier
class KegelSessionNotifier extends StateNotifier<KegelSessionState> {
  final TTSService _ttsService;
  final AppDatabase _database;
  Timer? _timer;
  bool _hapticsEnabled = true;

  KegelSessionNotifier(this._ttsService, this._database)
      : super(KegelSessionState.initial());

  /// Update settings
  void updateSettings(KegelSettings settings) {
    if (state.status != KegelSessionStatus.idle) return;

    state = KegelSessionState.initial().copyWith(
      settings: settings,
      totalReps: settings.totalReps,
      remainingSeconds: settings.contractSeconds,
    );
  }

  /// Start session
  Future<void> startSession() async {
    if (state.status == KegelSessionStatus.running) return;

    // Initialize TTS
    await _ttsService.initialize();

    // Create session in database
    final sessionId = await _createDatabaseSession();

    // Start from beginning if idle, resume if paused
    if (state.status == KegelSessionStatus.idle) {
      state = state.copyWith(
        status: KegelSessionStatus.running,
        currentPhase: KegelPhase.contract,
        currentRep: 1,
        remainingSeconds: state.settings.contractSeconds,
        progress: 0.0,
        startedAt: DateTime.now(),
        sessionId: sessionId,
      );

      // Speak initial instruction
      await _ttsService.speakContract();
      await _vibrate(duration: 200);
    } else {
      state = state.copyWith(status: KegelSessionStatus.running);
    }

    // Start timer
    _startTimer();
  }

  /// Pause session
  void pauseSession() {
    if (state.status != KegelSessionStatus.running) return;

    _timer?.cancel();
    state = state.copyWith(status: KegelSessionStatus.paused);
    _ttsService.stop();
  }

  /// Stop session
  Future<void> stopSession() async {
    _timer?.cancel();
    await _ttsService.stop();

    // Update database if session was started
    if (state.sessionId != null) {
      await _updateDatabaseSession();
    }

    state = KegelSessionState.initial().copyWith(
      settings: state.settings,
    );
  }

  /// Toggle haptics
  void toggleHaptics() {
    _hapticsEnabled = !_hapticsEnabled;
  }

  /// Start the timer
  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(milliseconds: 100), (_) {
      _tick();
    });
  }

  /// Timer tick (every 100ms)
  void _tick() {
    if (state.status != KegelSessionStatus.running) return;

    final newRemainingSeconds = state.remainingSeconds - 0.1;

    // Update progress within current phase
    final phaseDuration = state.getPhaseDuration(state.currentPhase);
    final phaseProgress = 1.0 - (newRemainingSeconds / phaseDuration);

    state = state.copyWith(
      remainingSeconds: newRemainingSeconds.clamp(0, double.infinity).toInt(),
      progress: phaseProgress.clamp(0.0, 1.0),
    );

    // Check if phase is complete
    if (newRemainingSeconds <= 0) {
      _advancePhase();
    }
  }

  /// Advance to next phase
  Future<void> _advancePhase() async {
    KegelPhase nextPhase;
    int nextRep = state.currentRep;

    switch (state.currentPhase) {
      case KegelPhase.contract:
        nextPhase = KegelPhase.hold;
        await _ttsService.speakHold();
        await _vibrate(duration: 100);
        break;
      case KegelPhase.hold:
        nextPhase = KegelPhase.release;
        await _ttsService.speakRelease();
        await _vibrate(duration: 100);
        break;
      case KegelPhase.release:
        nextPhase = KegelPhase.rest;
        await _ttsService.speakRest();
        await _vibrate(duration: 100);
        break;
      case KegelPhase.rest:
        // Complete rep
        nextRep = state.currentRep + 1;

        // Check if session is complete
        if (nextRep > state.totalReps) {
          await _completeSession();
          return;
        }

        // Vibrate longer on rep completion
        await _vibrate(duration: 300);

        // Speak encouragement every 5 reps
        if (nextRep % 5 == 0) {
          final remaining = state.totalReps - nextRep + 1;
          await _ttsService.speakEncouragement(
            'Great job! $remaining more reps to go!',
          );
        }

        // Start next rep
        nextPhase = KegelPhase.contract;
        await _ttsService.speakContract();
        break;
    }

    final nextDuration = state.getPhaseDuration(nextPhase);

    state = state.copyWith(
      currentPhase: nextPhase,
      currentRep: nextRep,
      remainingSeconds: nextDuration,
      progress: 0.0,
    );
  }

  /// Complete session
  Future<void> _completeSession() async {
    _timer?.cancel();

    state = state.copyWith(status: KegelSessionStatus.completed);

    // Speak completion message
    await _ttsService.speakSessionComplete();
    await _vibrate(duration: 500);

    // Update database
    await _updateDatabaseSession();

    // Check for achievements
    await _checkAchievements();
  }

  /// Vibrate device
  Future<void> _vibrate({required int duration}) async {
    if (!_hapticsEnabled) return;

    try {
      final hasVibrator = await Vibration.hasVibrator();
      if (hasVibrator == true) {
        await Vibration.vibrate(duration: duration);
      }
    } catch (e) {
      // Ignore vibration errors
    }
  }

  /// Create session in database
  Future<int> _createDatabaseSession() async {
    try {
      // Get current user (you may need to pass userId from auth provider)
      // For now, using userId 1 as placeholder
      final userId = 1;

      final sessionId = await _database.kegelSessionDao.insertKegelSession(
        KegelSessionsCompanion(
          userId: drift.Value(userId),
          durationMinutes: drift.Value(state.settings.durationMinutes),
          repsCompleted: const drift.Value(0),
          startedAt: drift.Value(DateTime.now()),
          endedAt: drift.Value(DateTime.now()), // Will update on completion
        ),
      );

      return sessionId;
    } catch (e) {
      print('Error creating session: $e');
      return 0;
    }
  }

  /// Update session in database
  Future<void> _updateDatabaseSession() async {
    if (state.sessionId == null) return;

    try {
      await _database.kegelSessionDao.updateRepsCompleted(
        state.sessionId!,
        state.currentRep - 1, // Subtract 1 because currentRep is 1-indexed
      );

      await _database.kegelSessionDao.updateEndTime(
        state.sessionId!,
        DateTime.now(),
      );
    } catch (e) {
      print('Error updating session: $e');
    }
  }

  /// Check for achievements
  Future<void> _checkAchievements() async {
    try {
      // Get current user (placeholder)
      final userId = 1;

      // Get streak
      final streak = await _database.kegelSessionDao.getKegelStreak(userId);

      // Get total reps
      final totalReps =
          await _database.kegelSessionDao.getTotalRepsCompleted(userId);

      // Check streak achievements
      if (streak == 3) {
        await _showAchievement('3-day streak!', '🔥');
      } else if (streak == 7) {
        await _showAchievement('7-day streak!', '🏆');
      } else if (streak == 14) {
        await _showAchievement('2-week streak!', '⭐');
      } else if (streak == 30) {
        await _showAchievement('30-day streak!', '👑');
      }

      // Check rep milestones
      if (totalReps >= 50 && totalReps < 60) {
        await _showAchievement('50 total reps!', '🎯');
      } else if (totalReps >= 100 && totalReps < 110) {
        await _showAchievement('100 reps!', '💪');
      } else if (totalReps >= 500 && totalReps < 510) {
        await _showAchievement('500 reps!', '🌟');
      }
    } catch (e) {
      print('Error checking achievements: $e');
    }
  }

  /// Show achievement (this would integrate with notification service)
  Future<void> _showAchievement(String title, String emoji) async {
    // TODO: Integrate with awesome_notifications
    print('Achievement unlocked: $emoji $title');
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
