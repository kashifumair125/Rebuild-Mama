import 'package:flutter/foundation.dart';

// TODO: Implement logging utility
// Debug and production logging

class AppLogger {
  static void log(String message, {String? tag}) {
    if (kDebugMode) {
      print('[${tag ?? 'APP'}] $message');
    }
  }

  static void error(String message, {String? tag, Object? error, StackTrace? stackTrace}) {
    if (kDebugMode) {
      print('[ERROR${tag != null ? " - $tag" : ""}] $message');
      if (error != null) print('Error: $error');
      if (stackTrace != null) print('StackTrace: $stackTrace');
    }
  }
}
