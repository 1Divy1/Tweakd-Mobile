import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:injectable/injectable.dart';

/// Persists the user's picked theme so the app boots straight into it instead
/// of flashing the previous one. Mirrors [LocaleLocalStorage] — same reasoning
/// for reusing `flutter_secure_storage` rather than adding
/// `shared_preferences` for one key.
@lazySingleton
class ThemeLocalStorage {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  static const _themeKey = 'app_theme_mode';

  /// `null` when nothing has been picked yet — the app then follows the OS.
  Future<ThemeMode?> getThemeMode() async {
    return switch (await _storage.read(key: _themeKey)) {
      'light' => ThemeMode.light,
      'dark' => ThemeMode.dark,
      'system' => ThemeMode.system,
      _ => null,
    };
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    await _storage.write(key: _themeKey, value: mode.name);
  }
}
