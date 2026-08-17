import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';
import 'package:share_plus/share_plus.dart';

class AppLogger {
  AppLogger._();

  static const int _maxLogs = 500;
  static final List<String> _logs = [];

  static List<String> get logs => List.unmodifiable(_logs);

  static void _addLog(
    String level,
    String message, [
    dynamic error,
    StackTrace? stackTrace,
  ]) {
    final now = DateTime.now().toIso8601String();
    final logEntry = StringBuffer('[$now] [$level] $message');
    if (error != null) {
      logEntry.write('\n   Error: $error');
    }
    if (stackTrace != null) {
      logEntry.write('\n   StackTrace:\n$stackTrace');
    }

    final formattedStr = logEntry.toString();

    // Log to console / developer output
    if (kDebugMode) {
      print(formattedStr);
    } else {
      developer.log(formattedStr, name: 'SteelBuildingApp');
    }

    // Keep in memory log buffer for release debugging
    _logs.add(formattedStr);
    if (_logs.length > _maxLogs) {
      _logs.removeAt(0);
    }
  }

  static void debug(String message) {
    _addLog('DEBUG', message);
  }

  static void info(String message) {
    _addLog('INFO', message);
  }

  static void warning(String message) {
    _addLog('WARN', message);
  }

  static void error(String message, [dynamic error, StackTrace? stackTrace]) {
    _addLog('ERROR', message, error, stackTrace);
  }

  static String getFormattedLogs() {
    if (_logs.isEmpty) {
      return 'No logs recorded yet.';
    }
    return _logs.join('\n----------------------------------------\n');
  }

  static void clearLogs() {
    _logs.clear();
    info('Logs cleared.');
  }

  static Future<void> exportLogs() async {
    final text = getFormattedLogs();
    // ignore: deprecated_member_use
    await Share.share(
      text,
      subject: 'Steel Building App Logs - ${DateTime.now()}',
    );
  }
}

