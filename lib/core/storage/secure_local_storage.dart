import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SecureLocalStorage extends LocalStorage {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  static const _authKey = 'supabase_secure_session';

  @override
  Future<void> initialize() async {}

  @override
  Future<String?> accessToken() async {
    return await _storage.read(key: _authKey);
  }

  @override
  Future<bool> hasAccessToken() async {
    return await _storage.containsKey(key: _authKey);
  }

  @override
  Future<void> persistSession(String persistSessionString) async {
    await _storage.write(key: _authKey, value: persistSessionString);
  }

  @override
  Future<void> removePersistedSession() async {
    await _storage.delete(key: _authKey);
  }
}
