import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class TokenStorage {
  TokenStorage._();

  static const _storage = FlutterSecureStorage();

  static const _kAccessToken = 'strava_access_token';
  static const _kRefreshToken = 'strava_refresh_token';
  static const _kExpiresAt = 'strava_expires_at';
  static const _kAthleteId = 'strava_athlete_id';
  static const _kAthleteName = 'strava_athlete_name';

  static Future<void> save({
    required String accessToken,
    required String refreshToken,
    required int expiresAt,
    required int athleteId,
    required String athleteName,
  }) async {
    await Future.wait([
      _storage.write(key: _kAccessToken, value: accessToken),
      _storage.write(key: _kRefreshToken, value: refreshToken),
      _storage.write(key: _kExpiresAt, value: expiresAt.toString()),
      _storage.write(key: _kAthleteId, value: athleteId.toString()),
      _storage.write(key: _kAthleteName, value: athleteName),
    ]);
  }

  static Future<String?> getAccessToken() =>
      _storage.read(key: _kAccessToken);

  static Future<String?> getRefreshToken() =>
      _storage.read(key: _kRefreshToken);

  static Future<int?> getExpiresAt() async {
    final v = await _storage.read(key: _kExpiresAt);
    return v != null ? int.tryParse(v) : null;
  }

  static Future<String?> getAthleteName() =>
      _storage.read(key: _kAthleteName);

  static Future<bool> isConnected() async {
    final token = await _storage.read(key: _kAccessToken);
    return token != null && token.isNotEmpty;
  }

  static Future<void> clear() => _storage.deleteAll();
}
