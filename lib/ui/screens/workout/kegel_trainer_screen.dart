import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:math' as math;

import '../../../models/kegel_session_state.dart';
import '../../../providers/kegel_providers.dart';
import '../../../services/tts_service.dart';

class KegelTrainerScreen extends ConsumerStatefulWidget {
  const KegelTrainerScreen({super.key});

  @override
  ConsumerState<KegelTrainerScreen> createState() => _KegelTrainerScreenState();
}

class _KegelTrainerScreenState extends ConsumerState<KegelTrainerScreen>
    with SingleTickerProviderStateMixin {
  bool _showSettings = false;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  // Settings
  double _durationMinutes = 5;
  double _contractSeconds = 5;
  double _holdSeconds = 10;
  double _restSeconds = 10;

  @override
  void initState() {
    super.initState();

    // Initialize pulse animation
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  void _saveSettings() {
    final settings = KegelSettings(
      durationMinutes: _durationMinutes.toInt(),
      contractSeconds: _contractSeconds.toInt(),
      holdSeconds: _holdSeconds.toInt(),
      restSeconds: _restSeconds.toInt(),
    );

    ref.read(kegelSessionProvider.notifier).updateSettings(settings);

    setState(() {
      _showSettings = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Settings saved!'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final sessionState = ref.watch(kegelSessionProvider);
    final ttsService = ref.watch(ttsServiceProvider);

    return Scaffold(
      backgroundColor: Colors.grey[900],
      appBar: AppBar(
        title: Text(
          'Kegel Exercise Trainer',
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: Colors.grey[850],
        elevation: 0,
        actions: [
          // Mute/Unmute button
          IconButton(
            icon: Icon(
              ttsService.isMuted ? Icons.volume_off : Icons.volume_up,
              color: Colors.white,
            ),
            onPressed: () {
              ttsService.toggleMute();
              setState(() {});
            },
          ),
          // Settings button
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.white),
            onPressed: () {
              setState(() {
                _showSettings = !_showSettings;
              });
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          // Main content
          Column(
            children: [
              // Settings panel
              if (_showSettings) _buildSettingsPanel(),

              // Main display area
              Expanded(
                child: Center(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Streak indicator
                        _buildStreakIndicator(),

                        const SizedBox(height: 32),

                        // Circular progress indicator
                        _buildCircularProgress(sessionState),

                        const SizedBox(height: 32),

                        // Phase label
                        _buildPhaseLabel(sessionState),

                        const SizedBox(height: 16),

                        // Time display
                        _buildTimeDisplay(sessionState),

                        const SizedBox(height: 24),

                        // Rep counter
                        _buildRepCounter(sessionState),

                        const SizedBox(height: 32),

                        // Encouraging message
                        if (sessionState.status == KegelSessionStatus.running)
                          _buildEncouragingMessage(sessionState),
                      ],
                    ),
                  ),
                ),
              ),

              // Controls
              _buildControls(sessionState),
            ],
          ),

          // Dark overlay during session
          if (sessionState.status == KegelSessionStatus.running)
            Positioned.fill(
              child: IgnorePointer(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: RadialGradient(
                      colors: [
                        Colors.transparent,
                        Colors.black.withOpacity(0.3),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSettingsPanel() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.grey[850],
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Session Settings',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 24),

          // Duration slider
          _buildSlider(
            label: 'Duration',
            value: _durationMinutes,
            min: 1,
            max: 10,
            divisions: 9,
            unit: 'min',
            onChanged: (value) {
              setState(() {
                _durationMinutes = value;
              });
            },
          ),

          const SizedBox(height: 16),

          // Contract time slider
          _buildSlider(
            label: 'Contract Time',
            value: _contractSeconds,
            min: 3,
            max: 10,
            divisions: 7,
            unit: 'sec',
            onChanged: (value) {
              setState(() {
                _contractSeconds = value;
              });
            },
          ),

          const SizedBox(height: 16),

          // Hold time slider
          _buildSlider(
            label: 'Hold Time',
            value: _holdSeconds,
            min: 5,
            max: 15,
            divisions: 10,
            unit: 'sec',
            onChanged: (value) {
              setState(() {
                _holdSeconds = value;
              });
            },
          ),

          const SizedBox(height: 16),

          // Rest time slider
          _buildSlider(
            label: 'Rest Time',
            value: _restSeconds,
            min: 5,
            max: 15,
            divisions: 10,
            unit: 'sec',
            onChanged: (value) {
              setState(() {
                _restSeconds = value;
              });
            },
          ),

          const SizedBox(height: 24),

          // Save button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _saveSettings,
              icon: const Icon(Icons.save),
              label: const Text('Save as Preset'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6BCB77),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSlider({
    required String label,
    required double value,
    required double min,
    required double max,
    required int divisions,
    required String unit,
    required ValueChanged<double> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: Colors.grey[400],
              ),
            ),
            Text(
              '${value.toInt()} $unit',
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ],
        ),
        Slider(
          value: value,
          min: min,
          max: max,
          divisions: divisions,
          activeColor: const Color(0xFF4D96FF),
          inactiveColor: Colors.grey[700],
          onChanged: onChanged,
        ),
      ],
    );
  }

  Widget _buildStreakIndicator() {
    final streakAsync = ref.watch(kegelStreakProvider);

    return streakAsync.when(
      data: (streak) {
        if (streak == 0) return const SizedBox.shrink();

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.orange.withOpacity(0.2),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.orange, width: 2),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.local_fire_department, color: Colors.orange, size: 20),
              const SizedBox(width: 8),
              Text(
                '$streak Day Streak!',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.orange,
                ),
              ),
            ],
          ),
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }

  Widget _buildCircularProgress(KegelSessionState state) {
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        final scale = state.status == KegelSessionStatus.running
            ? _pulseAnimation.value
            : 1.0;

        return Transform.scale(
          scale: scale,
          child: SizedBox(
            width: 300,
            height: 300,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Background circle
                Container(
                  width: 300,
                  height: 300,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.grey[800],
                    boxShadow: [
                      BoxShadow(
                        color: state.getPhaseColor().withOpacity(0.3),
                        blurRadius: 30,
                        spreadRadius: 10,
                      ),
                    ],
                  ),
                ),

                // Progress indicator
                SizedBox(
                  width: 300,
                  height: 300,
                  child: CircularProgressIndicator(
                    value: state.progress,
                    strokeWidth: 12,
                    backgroundColor: Colors.grey[700],
                    valueColor: AlwaysStoppedAnimation<Color>(
                      state.getPhaseColor(),
                    ),
                  ),
                ),

                // Center content
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      _getPhaseIcon(state.currentPhase),
                      size: 64,
                      color: state.getPhaseColor(),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  IconData _getPhaseIcon(KegelPhase phase) {
    switch (phase) {
      case KegelPhase.contract:
        return Icons.arrow_upward;
      case KegelPhase.hold:
        return Icons.pause;
      case KegelPhase.release:
        return Icons.arrow_downward;
      case KegelPhase.rest:
        return Icons.self_improvement;
    }
  }

  Widget _buildPhaseLabel(KegelSessionState state) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      child: Text(
        state.getPhaseLabel(),
        key: ValueKey(state.currentPhase),
        style: GoogleFonts.poppins(
          fontSize: 36,
          fontWeight: FontWeight.w700,
          color: state.getPhaseColor(),
          letterSpacing: 2,
        ),
      ),
    );
  }

  Widget _buildTimeDisplay(KegelSessionState state) {
    return Text(
      '${state.remainingSeconds}s',
      style: GoogleFonts.poppins(
        fontSize: 72,
        fontWeight: FontWeight.w800,
        color: Colors.white,
        height: 1,
      ),
    );
  }

  Widget _buildRepCounter(KegelSessionState state) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.grey[800],
        borderRadius: BorderRadius.circular(24),
      ),
      child: Text(
        state.status == KegelSessionStatus.idle
            ? 'Ready to start'
            : 'Rep ${state.currentRep} of ${state.totalReps}',
        style: GoogleFonts.poppins(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildEncouragingMessage(KegelSessionState state) {
    final messages = [
      "You're doing great!",
      "Keep up the excellent work!",
      "Stay focused!",
      "You've got this!",
      "Almost there!",
    ];

    final messageIndex = state.currentRep % messages.length;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Text(
        messages[messageIndex],
        style: GoogleFonts.poppins(
          fontSize: 18,
          fontWeight: FontWeight.w500,
          color: Colors.grey[400],
          fontStyle: FontStyle.italic,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildControls(KegelSessionState state) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.grey[850],
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            // Start/Resume button
            if (state.status == KegelSessionStatus.idle ||
                state.status == KegelSessionStatus.paused)
              _buildControlButton(
                icon: Icons.play_arrow,
                label: state.status == KegelSessionStatus.idle ? 'Start' : 'Resume',
                color: const Color(0xFF6BCB77),
                onPressed: () {
                  ref.read(kegelSessionProvider.notifier).startSession();
                },
              ),

            // Pause button
            if (state.status == KegelSessionStatus.running)
              _buildControlButton(
                icon: Icons.pause,
                label: 'Pause',
                color: const Color(0xFFFFD93D),
                onPressed: () {
                  ref.read(kegelSessionProvider.notifier).pauseSession();
                },
              ),

            // Stop button
            if (state.status != KegelSessionStatus.idle)
              _buildControlButton(
                icon: Icons.stop,
                label: 'Stop',
                color: const Color(0xFFFF6B6B),
                onPressed: () {
                  ref.read(kegelSessionProvider.notifier).stopSession();
                },
              ),

            // Haptics toggle
            _buildControlButton(
              icon: Icons.vibration,
              label: 'Haptics',
              color: Colors.grey[600]!,
              onPressed: () {
                ref.read(kegelSessionProvider.notifier).toggleHaptics();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Haptics toggled'),
                    duration: Duration(seconds: 1),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.4),
                blurRadius: 10,
                spreadRadius: 2,
              ),
            ],
          ),
          child: IconButton(
            icon: Icon(icon, color: Colors.white, size: 32),
            onPressed: onPressed,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: Colors.grey[400],
          ),
        ),
      ],
    );
  }
}
