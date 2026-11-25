import 'package:flutter/foundation.dart';

enum LogLevel { debug, info, warning, error }

/// Logger with redaction (docs/08-SECURITY-PRIVACY.md §3, safety rule 5).
///
/// - Fields named in [sensitiveKeys] are replaced with `[redacted]`.
/// - In release builds only warning+ is printed, and free-text [message]s
///   are the caller's responsibility: never interpolate patient/medication data.
class AppLogger {
  AppLogger({
    void Function(String line)? sink,
    LogLevel? minLevel,
    bool? isRelease,
  }) : _sink = sink ?? debugPrint,
       _isRelease = isRelease ?? kReleaseMode,
       minLevel =
           minLevel ??
           ((isRelease ?? kReleaseMode) ? LogLevel.warning : LogLevel.debug);

  static const sensitiveKeys = {
    'name',
    'notes',
    'conditions',
    'instructions',
    'strength',
    'prescribed_by',
    'display_name',
    'email',
    'photo_path',
    'payload',
    'payload_json',
  };

  static const redacted = '[redacted]';

  final void Function(String line) _sink;
  final bool _isRelease;
  final LogLevel minLevel;

  /// Returns a deep copy of [data] with sensitive keys replaced.
  static Object? redact(Object? data) {
    if (data is Map) {
      return {
        for (final e in data.entries)
          e.key: sensitiveKeys.contains(e.key.toString().toLowerCase())
              ? redacted
              : redact(e.value),
      };
    }
    if (data is Iterable) return data.map(redact).toList();
    return data;
  }

  void debug(String message, {Map<String, Object?>? fields}) =>
      _log(LogLevel.debug, message, fields);
  void info(String message, {Map<String, Object?>? fields}) =>
      _log(LogLevel.info, message, fields);
  void warning(String message, {Map<String, Object?>? fields}) =>
      _log(LogLevel.warning, message, fields);

  /// Only the error type is logged, never its message (may contain data).
  void error(String message, {Object? error, Map<String, Object?>? fields}) =>
      _log(
        LogLevel.error,
        error == null ? message : '$message (${error.runtimeType})',
        fields,
      );

  void _log(LogLevel level, String message, Map<String, Object?>? fields) {
    if (level.index < minLevel.index) return;
    final buf = StringBuffer('[${level.name}] $message');
    if (fields != null && fields.isNotEmpty) {
      buf.write(' ${redact(fields)}');
    }
    _sink(buf.toString());
  }

  bool get isRelease => _isRelease;
}
