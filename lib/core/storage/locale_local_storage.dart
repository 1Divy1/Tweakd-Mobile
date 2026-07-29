import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:injectable/injectable.dart';

/// Persists the user's picked app-language code (`en`/`ro`) locally so the
/// app can boot directly into the right locale on the next launch, without
/// waiting on a network round-trip. Deliberately separate from
/// [SecureLocalStorage]: that class implements Supabase's `LocalStorage`
/// interface for session persistence specifically, not a generic key/value
/// store. `flutter_secure_storage` is already a project dependency, so this
/// reuses it directly rather than introducing `shared_preferences`.
@lazySingleton
class LocaleLocalStorage {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  static const _localeKey = 'app_locale';

  Future<String?> getLocale() async {
    return _storage.read(key: _localeKey);
  }

  Future<void> setLocale(String code) async {
    await _storage.write(key: _localeKey, value: code);
  }
}
