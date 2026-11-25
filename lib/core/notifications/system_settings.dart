import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'system_settings.g.dart';

/// Android-only permissions the notification plugin does not expose
/// (implemented in `MainActivity.kt`). Elsewhere everything counts as granted.
class SystemSettings {
  const SystemSettings();

  static const _channel = MethodChannel('kizuvia/system');

  bool get _android => defaultTargetPlatform == TargetPlatform.android;

  Future<bool> _bool(String method) async {
    if (!_android) return true;
    try {
      return await _channel.invokeMethod<bool>(method) ?? true;
    } on PlatformException {
      return true;
    } on MissingPluginException {
      return true;
    }
  }

  Future<void> _open(String method) async {
    if (!_android) return;
    try {
      await _channel.invokeMethod<void>(method);
    } on PlatformException {
      // Settings screen unavailable on this device: nothing else to do.
    } on MissingPluginException {
      // Not running on a real Android host (tests).
    }
  }

  /// "Do Not Disturb access": the alarm channel may then ring in DND.
  Future<bool> dndAccessGranted() => _bool('dndAccessGranted');
  Future<void> openDndAccess() => _open('openDndAccess');

  /// Full-screen alarm over the lock screen (Android 14+ needs a grant).
  Future<bool> fullScreenIntentAllowed() => _bool('fullScreenIntentAllowed');
  Future<void> openFullScreenIntentSettings() =>
      _open('openFullScreenIntentSettings');
}

@Riverpod(keepAlive: true)
SystemSettings systemSettings(Ref ref) => const SystemSettings();
