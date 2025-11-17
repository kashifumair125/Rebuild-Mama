import 'package:flutter/foundation.dart';
import 'dart:developer' as developer;

/// Log levels for different types of messages
enum LogLevel {
  debug,
  info,
  warning,
  error,
  fatal,
}

/// Production-ready logging utility with multiple log levels and formats
/// Supports both debug console logging and production logging
class AppLogger {
  /// Flag to enable/disable logging
  static bool _enabled = true;

  /// Minimum log level to display (in production, set to info or warning)
  static LogLevel _minLevel = kDebugMode ? LogLevel.debug : LogLevel.info;

  /// List of log listeners for custom handling (e.g., crash reporting)
  static final List<void Function(LogLevel, String, String?, Object?, StackTrace?)> _listeners = [];

  /// Enable or disable logging
  static void setEnabled(bool enabled) {
    _enabled = enabled;
  }

  /// Set minimum log level
  static void setMinLevel(LogLevel level) {
    _minLevel = level;
  }

  /// Add a log listener (e.g., for Firebase Crashlytics)
  static void addListener(void Function(LogLevel, String, String?, Object?, StackTrace?) listener) {
    _listeners.add(listener);
  }

  /// Clear all listeners
  static void clearListeners() {
    _listeners.clear();
  }

  /// Debug-level logging (development only)
  static void debug(String message, {String? tag}) {
    _log(LogLevel.debug, message, tag: tag);
  }

  /// Info-level logging (general information)
  static void info(String message, {String? tag}) {
    _log(LogLevel.info, message, tag: tag);
  }

  /// Warning-level logging
  static void warning(String message, {String? tag, Object? error}) {
    _log(LogLevel.warning, message, tag: tag, error: error);
  }

  /// Error-level logging
  static void error(
    String message, {
    String? tag,
    Object? error,
    StackTrace? stackTrace,
  }) {
    _log(LogLevel.error, message, tag: tag, error: error, stackTrace: stackTrace);
  }

  /// Fatal error logging (critical errors that crash the app)
  static void fatal(
    String message, {
    String? tag,
    Object? error,
    StackTrace? stackTrace,
  }) {
    _log(LogLevel.fatal, message, tag: tag, error: error, stackTrace: stackTrace);
  }

  /// General log method (backward compatibility)
  static void log(String message, {String? tag}) {
    info(message, tag: tag);
  }

  /// Core logging method
  static void _log(
    LogLevel level,
    String message, {
    String? tag,
    Object? error,
    StackTrace? stackTrace,
  }) {
    if (!_enabled || level.index < _minLevel.index) {
      return;
    }

    final timestamp = DateTime.now().toIso8601String();
    final levelStr = level.name.toUpperCase();
    final tagStr = tag ?? 'APP';
    final logMessage = '[$timestamp] [$levelStr] [$tagStr] $message';

    // Console logging in debug mode
    if (kDebugMode) {
      print(logMessage);
      if (error != null) {
        print('└─ Error: $error');
      }
      if (stackTrace != null) {
        print('└─ StackTrace:');
        print(stackTrace.toString().split('\n').map((line) => '   $line').join('\n'));
      }
    } else {
      // Production logging using dart:developer
      developer.log(
        message,
        time: DateTime.now(),
        level: _getLevelValue(level),
        name: tagStr,
        error: error,
        stackTrace: stackTrace,
      );
    }

    // Notify listeners (e.g., for crash reporting services)
    for (final listener in _listeners) {
      try {
        listener(level, message, tag, error, stackTrace);
      } catch (e) {
        // Prevent listener errors from breaking logging
        if (kDebugMode) {
          print('Error in log listener: $e');
        }
      }
    }
  }

  /// Convert LogLevel to developer.log level value
  static int _getLevelValue(LogLevel level) {
    switch (level) {
      case LogLevel.debug:
        return 500;
      case LogLevel.info:
        return 800;
      case LogLevel.warning:
        return 900;
      case LogLevel.error:
        return 1000;
      case LogLevel.fatal:
        return 1200;
    }
  }

  /// Log a database operation
  static void database(String operation, {Object? error, StackTrace? stackTrace}) {
    if (error != null) {
      _log(
        LogLevel.error,
        'Database operation failed: $operation',
        tag: 'DATABASE',
        error: error,
        stackTrace: stackTrace,
      );
    } else {
      _log(LogLevel.debug, 'Database operation: $operation', tag: 'DATABASE');
    }
  }

  /// Log a network operation
  static void network(String operation, {Object? error, StackTrace? stackTrace}) {
    if (error != null) {
      _log(
        LogLevel.error,
        'Network operation failed: $operation',
        tag: 'NETWORK',
        error: error,
        stackTrace: stackTrace,
      );
    } else {
      _log(LogLevel.debug, 'Network operation: $operation', tag: 'NETWORK');
    }
  }

  /// Log an authentication event
  static void auth(String event, {Object? error, StackTrace? stackTrace}) {
    if (error != null) {
      _log(
        LogLevel.error,
        'Auth event failed: $event',
        tag: 'AUTH',
        error: error,
        stackTrace: stackTrace,
      );
    } else {
      _log(LogLevel.info, 'Auth event: $event', tag: 'AUTH');
    }
  }

  /// Log app lifecycle events
  static void lifecycle(String event) {
    _log(LogLevel.info, 'Lifecycle event: $event', tag: 'LIFECYCLE');
  }

  /// Log performance metrics
  static void performance(String metric, {dynamic value}) {
    final message = value != null ? '$metric: $value' : metric;
    _log(LogLevel.info, message, tag: 'PERFORMANCE');
  }
}
