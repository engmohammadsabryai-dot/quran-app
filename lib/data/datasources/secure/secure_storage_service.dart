import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageService {
  final FlutterSecureStorage _storage;

  SecureStorageService({FlutterSecureStorage? storage})
      : _storage = storage ??
            const FlutterSecureStorage(
              aOptions: AndroidOptions(encryptedSharedPreferences: true),
              iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
            );

  static const String _keyActiveUserId = 'active_user_id';
  static const String _keyParentalPin = 'parental_gate_pin';

  Future<void> saveActiveUserId(String userId) async {
    await _storage.write(key: _keyActiveUserId, value: userId);
  }

  Future<String?> getActiveUserId() async {
    return await _storage.read(key: _keyActiveUserId);
  }

  Future<void> saveParentalPin(String pin) async {
    await _storage.write(key: _keyParentalPin, value: pin);
  }

  Future<String?> getParentalPin() async {
    return await _storage.read(key: _keyParentalPin);
  }

  Future<bool> verifyParentalPin(String pin) async {
    final saved = await getParentalPin();
    if (saved == null) return pin == '1234'; // Default parental PIN
    return saved == pin;
  }

  Future<void> clearAll() async {
    await _storage.deleteAll();
  }
}
