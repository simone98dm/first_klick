import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_web_auth_2/flutter_web_auth_2.dart';

import 'token_storage.dart';

class StravaAuth {
  StravaAuth._();

  static String get _clientId => dotenv.env['STRAVA_CLIENT_ID'] ?? '';
  static String get _clientSecret => dotenv.env['STRAVA_CLIENT_SECRET'] ?? '';
  static String get _redirectScheme =>
      dotenv.env['STRAVA_REDIRECT_SCHEME'] ?? 'firstklick';

  static String get _redirectUri => '$_redirectScheme://callback';

  static final _dio = Dio();

  /// Opens the Strava OAuth page and completes the full token exchange.
  static Future<void> authenticate() async {
    final authUrl = Uri.https('www.strava.com', '/oauth/authorize', {
      'client_id': _clientId,
      'response_type': 'code',
      'redirect_uri': _redirectUri,
      'approval_prompt': 'auto',
      'scope': 'activity:write,read',
    }).toString();

    final result = await FlutterWebAuth2.authenticate(
      url: authUrl,
      callbackUrlScheme: _redirectScheme,
    );

    final code = Uri.parse(result).queryParameters['code'];
    if (code == null) throw Exception('No code in OAuth callback');

    await _exchangeCode(code);
  }

  static Future<void> _exchangeCode(String code) async {
    final response = await _dio.post<Map<String, dynamic>>(
      'https://www.strava.com/oauth/token',
      data: {
        'client_id': _clientId,
        'client_secret': _clientSecret,
        'code': code,
        'grant_type': 'authorization_code',
      },
      options: Options(contentType: Headers.formUrlEncodedContentType),
    );

    final data = response.data!;
    await TokenStorage.save(
      accessToken: data['access_token'] as String,
      refreshToken: data['refresh_token'] as String,
      expiresAt: data['expires_at'] as int,
      athleteId: (data['athlete'] as Map<String, dynamic>)['id'] as int,
      athleteName:
          '${(data['athlete'] as Map<String, dynamic>)['firstname']} ${(data['athlete'] as Map<String, dynamic>)['lastname']}',
    );
  }

  /// Returns a valid (possibly refreshed) access token.
  static Future<String> validAccessToken() async {
    final expiresAt = await TokenStorage.getExpiresAt();
    final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;

    if (expiresAt != null && expiresAt > now + 60) {
      return (await TokenStorage.getAccessToken())!;
    }
    return _refresh();
  }

  static Future<String> _refresh() async {
    final refreshToken = await TokenStorage.getRefreshToken();
    if (refreshToken == null) throw Exception('No refresh token stored');

    final response = await _dio.post<Map<String, dynamic>>(
      'https://www.strava.com/oauth/token',
      data: {
        'client_id': _clientId,
        'client_secret': _clientSecret,
        'grant_type': 'refresh_token',
        'refresh_token': refreshToken,
      },
      options: Options(contentType: Headers.formUrlEncodedContentType),
    );

    final data = response.data!;
    await TokenStorage.save(
      accessToken: data['access_token'] as String,
      refreshToken: data['refresh_token'] as String,
      expiresAt: data['expires_at'] as int,
      athleteId: 0,
      athleteName: (await TokenStorage.getAthleteName()) ?? '',
    );

    return data['access_token'] as String;
  }

  static Future<void> disconnect() => TokenStorage.clear();
}
