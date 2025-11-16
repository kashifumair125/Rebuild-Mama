import 'package:flutter/material.dart';

/// Kegel exercise phase
enum KegelPhase {
  contract,
  hold,
  release,
  rest,
}

/// Kegel session status
enum KegelSessionStatus {
  idle,
  running,
  paused,
  completed,
}

/// Kegel exercise settings
@immutable
class KegelSettings {
  final int durationMinutes;
  final int contractSeconds;
  final int holdSeconds;
  final int restSeconds;

  const KegelSettings({
    required this.durationMinutes,
    required this.contractSeconds,
    required this.holdSeconds,
    required this.restSeconds,
  });

  /// Default settings
  factory KegelSettings.defaultSettings() {
    return const KegelSettings(
      durationMinutes: 5,
      contractSeconds: 5,
      holdSeconds: 10,
      restSeconds: 10,
    );
  }

  /// Calculate total reps based on duration
  int get totalReps {
    final secondsPerRep = contractSeconds + holdSeconds + contractSeconds + restSeconds;
    final totalSeconds = durationMinutes * 60;
    return (totalSeconds / secondsPerRep).floor();
  }

  /// Calculate seconds per rep
  int get secondsPerRep {
    return contractSeconds + holdSeconds + contractSeconds + restSeconds;
  }

  KegelSettings copyWith({
    int? durationMinutes,
    int? contractSeconds,
    int? holdSeconds,
    int? restSeconds,
  }) {
    return KegelSettings(
      durationMinutes: durationMinutes ?? this.durationMinutes,
      contractSeconds: contractSeconds ?? this.contractSeconds,
      holdSeconds: holdSeconds ?? this.holdSeconds,
      restSeconds: restSeconds ?? this.restSeconds,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'durationMinutes': durationMinutes,
      'contractSeconds': contractSeconds,
      'holdSeconds': holdSeconds,
      'restSeconds': restSeconds,
    };
  }

  factory KegelSettings.fromJson(Map<String, dynamic> json) {
    return KegelSettings(
      durationMinutes: json['durationMinutes'] as int,
      contractSeconds: json['contractSeconds'] as int,
      holdSeconds: json['holdSeconds'] as int,
      restSeconds: json['restSeconds'] as int,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is KegelSettings &&
          runtimeType == other.runtimeType &&
          durationMinutes == other.durationMinutes &&
          contractSeconds == other.contractSeconds &&
          holdSeconds == other.holdSeconds &&
          restSeconds == other.restSeconds;

  @override
  int get hashCode =>
      durationMinutes.hashCode ^
      contractSeconds.hashCode ^
      holdSeconds.hashCode ^
      restSeconds.hashCode;
}

/// Current Kegel session state
@immutable
class KegelSessionState {
  final KegelSessionStatus status;
  final KegelPhase currentPhase;
  final int currentRep;
  final int totalReps;
  final int remainingSeconds;
  final double progress; // 0.0 to 1.0
  final KegelSettings settings;
  final DateTime? startedAt;
  final int? sessionId;

  const KegelSessionState({
    required this.status,
    required this.currentPhase,
    required this.currentRep,
    required this.totalReps,
    required this.remainingSeconds,
    required this.progress,
    required this.settings,
    this.startedAt,
    this.sessionId,
  });

  /// Initial state
  factory KegelSessionState.initial() {
    final settings = KegelSettings.defaultSettings();
    return KegelSessionState(
      status: KegelSessionStatus.idle,
      currentPhase: KegelPhase.contract,
      currentRep: 0,
      totalReps: settings.totalReps,
      remainingSeconds: settings.contractSeconds,
      progress: 0.0,
      settings: settings,
    );
  }

  /// Get phase duration in seconds
  int getPhaseDuration(KegelPhase phase) {
    switch (phase) {
      case KegelPhase.contract:
        return settings.contractSeconds;
      case KegelPhase.hold:
        return settings.holdSeconds;
      case KegelPhase.release:
        return settings.contractSeconds; // Same as contract
      case KegelPhase.rest:
        return settings.restSeconds;
    }
  }

  /// Get phase color
  Color getPhaseColor() {
    switch (currentPhase) {
      case KegelPhase.contract:
        return const Color(0xFFFF6B6B); // Red
      case KegelPhase.hold:
        return const Color(0xFFFFD93D); // Yellow
      case KegelPhase.release:
        return const Color(0xFF6BCB77); // Green
      case KegelPhase.rest:
        return const Color(0xFF4D96FF); // Blue
    }
  }

  /// Get phase label
  String getPhaseLabel() {
    switch (currentPhase) {
      case KegelPhase.contract:
        return 'CONTRACT NOW';
      case KegelPhase.hold:
        return 'HOLD';
      case KegelPhase.release:
        return 'RELEASE';
      case KegelPhase.rest:
        return 'REST';
    }
  }

  KegelSessionState copyWith({
    KegelSessionStatus? status,
    KegelPhase? currentPhase,
    int? currentRep,
    int? totalReps,
    int? remainingSeconds,
    double? progress,
    KegelSettings? settings,
    DateTime? startedAt,
    int? sessionId,
  }) {
    return KegelSessionState(
      status: status ?? this.status,
      currentPhase: currentPhase ?? this.currentPhase,
      currentRep: currentRep ?? this.currentRep,
      totalReps: totalReps ?? this.totalReps,
      remainingSeconds: remainingSeconds ?? this.remainingSeconds,
      progress: progress ?? this.progress,
      settings: settings ?? this.settings,
      startedAt: startedAt ?? this.startedAt,
      sessionId: sessionId ?? this.sessionId,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is KegelSessionState &&
          runtimeType == other.runtimeType &&
          status == other.status &&
          currentPhase == other.currentPhase &&
          currentRep == other.currentRep &&
          totalReps == other.totalReps &&
          remainingSeconds == other.remainingSeconds &&
          progress == other.progress &&
          settings == other.settings &&
          startedAt == other.startedAt &&
          sessionId == other.sessionId;

  @override
  int get hashCode =>
      status.hashCode ^
      currentPhase.hashCode ^
      currentRep.hashCode ^
      totalReps.hashCode ^
      remainingSeconds.hashCode ^
      progress.hashCode ^
      settings.hashCode ^
      startedAt.hashCode ^
      sessionId.hashCode;
}
