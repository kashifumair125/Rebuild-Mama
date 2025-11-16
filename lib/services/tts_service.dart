import 'package:flutter_tts/flutter_tts.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Voice types for TTS
enum VoiceType {
  femalCalm,
  femaleMotivational,
  robotic,
}

/// Language options
enum TTSLanguage {
  english,
  arabic,
}

/// Text-to-Speech service for Kegel exercise guidance
class TTSService {
  static final TTSService _instance = TTSService._internal();
  factory TTSService() => _instance;
  TTSService._internal();

  final FlutterTts _flutterTts = FlutterTts();
  bool _isInitialized = false;
  bool _isMuted = false;
  VoiceType _voiceType = VoiceType.femalCalm;
  TTSLanguage _language = TTSLanguage.english;

  // Preferences keys
  static const String _mutedKey = 'tts_muted';
  static const String _voiceTypeKey = 'tts_voice_type';
  static const String _languageKey = 'tts_language';

  /// Initialize the TTS service
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // Load preferences
      await _loadPreferences();

      // Configure TTS
      await _configureTTS();

      _isInitialized = true;
    } catch (e) {
      print('Error initializing TTS: $e');
    }
  }

  /// Load user preferences
  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    _isMuted = prefs.getBool(_mutedKey) ?? false;

    final voiceIndex = prefs.getInt(_voiceTypeKey) ?? 0;
    _voiceType = VoiceType.values[voiceIndex];

    final langIndex = prefs.getInt(_languageKey) ?? 0;
    _language = TTSLanguage.values[langIndex];
  }

  /// Configure TTS settings
  Future<void> _configureTTS() async {
    // Set language
    final languageCode = _language == TTSLanguage.english ? 'en-US' : 'ar-SA';
    await _flutterTts.setLanguage(languageCode);

    // Set voice parameters based on voice type
    switch (_voiceType) {
      case VoiceType.femalCalm:
        await _flutterTts.setSpeechRate(0.4); // Slower, calmer
        await _flutterTts.setPitch(1.1); // Slightly higher pitch
        break;
      case VoiceType.femaleMotivational:
        await _flutterTts.setSpeechRate(0.5); // Normal speed
        await _flutterTts.setPitch(1.2); // Higher pitch
        break;
      case VoiceType.robotic:
        await _flutterTts.setSpeechRate(0.45);
        await _flutterTts.setPitch(0.9); // Lower pitch
        break;
    }

    await _flutterTts.setVolume(1.0);
  }

  /// Speak text
  Future<void> speak(String text) async {
    if (!_isInitialized) {
      await initialize();
    }

    if (_isMuted) return;

    try {
      await _flutterTts.speak(text);
    } catch (e) {
      print('Error speaking: $e');
    }
  }

  /// Stop speaking
  Future<void> stop() async {
    try {
      await _flutterTts.stop();
    } catch (e) {
      print('Error stopping TTS: $e');
    }
  }

  /// Speak contract phase instruction
  Future<void> speakContract() async {
    final text = _language == TTSLanguage.english
        ? 'Contract your pelvic floor now'
        : 'اضغطي على عضلات قاع الحوض الآن';
    await speak(text);
  }

  /// Speak hold phase instruction
  Future<void> speakHold() async {
    final text = _language == TTSLanguage.english ? 'Hold' : 'حافظي';
    await speak(text);
  }

  /// Speak release phase instruction
  Future<void> speakRelease() async {
    final text = _language == TTSLanguage.english
        ? 'Release slowly'
        : 'حرري ببطء';
    await speak(text);
  }

  /// Speak rest phase instruction
  Future<void> speakRest() async {
    final text = _language == TTSLanguage.english ? 'Rest' : 'استريحي';
    await speak(text);
  }

  /// Speak encouraging message
  Future<void> speakEncouragement(String message) async {
    await speak(message);
  }

  /// Speak rep completion
  Future<void> speakRepComplete(int repNumber, int totalReps) async {
    final text = _language == TTSLanguage.english
        ? 'Great job! Rep $repNumber of $totalReps complete'
        : 'عمل رائع! التكرار $repNumber من $totalReps مكتمل';
    await speak(text);
  }

  /// Speak countdown
  Future<void> speakCountdown(int seconds) async {
    final text = _language == TTSLanguage.english
        ? 'Next rep in $seconds'
        : 'التكرار التالي في $seconds';
    await speak(text);
  }

  /// Speak session complete
  Future<void> speakSessionComplete() async {
    final text = _language == TTSLanguage.english
        ? 'Excellent work! Session complete'
        : 'عمل ممتاز! الجلسة مكتملة';
    await speak(text);
  }

  /// Toggle mute
  Future<void> toggleMute() async {
    _isMuted = !_isMuted;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_mutedKey, _isMuted);
  }

  /// Set voice type
  Future<void> setVoiceType(VoiceType voiceType) async {
    _voiceType = voiceType;
    await _configureTTS();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_voiceTypeKey, voiceType.index);
  }

  /// Set language
  Future<void> setLanguage(TTSLanguage language) async {
    _language = language;
    await _configureTTS();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_languageKey, language.index);
  }

  /// Get current mute status
  bool get isMuted => _isMuted;

  /// Get current voice type
  VoiceType get voiceType => _voiceType;

  /// Get current language
  TTSLanguage get language => _language;

  /// Dispose resources
  Future<void> dispose() async {
    await _flutterTts.stop();
  }
}
