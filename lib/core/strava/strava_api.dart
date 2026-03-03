import 'dart:convert';

import 'package:dio/dio.dart';

import '../../shared/logging_service.dart';
import 'strava_auth.dart';

class StravaApi {
  StravaApi._();

  static final _dio =
      Dio(BaseOptions(baseUrl: 'https://www.strava.com/api/v3'));

  static Future<Options> _authOptions() async {
    final token = await StravaAuth.validAccessToken();
    return Options(headers: {'Authorization': 'Bearer $token'});
  }

  /// Upload a GPX file and return the Strava upload id.
  static Future<int> uploadActivity({
    required String gpxContent,
    required String name,
  }) async {
    try {
      LoggingService.info('Uploading activity to Strava: $name');
      final opts = await _authOptions();
      final formData = FormData.fromMap({
        'file': MultipartFile.fromBytes(
          utf8.encode(gpxContent),
          filename: 'activity.gpx',
        ),
        'data_type': 'gpx',
        'name': name,
        'sport_type': 'Run',
      });

      final response = await _dio.post<Map<String, dynamic>>(
        '/uploads',
        data: formData,
        options: opts,
      );
      final uploadId = response.data!['id'] as int;
      LoggingService.info(
          'Activity uploaded successfully, upload ID: $uploadId');
      return uploadId;
    } catch (e, stackTrace) {
      LoggingService.error(
          'Failed to upload activity to Strava', e, stackTrace);
      rethrow;
    }
  }

  /// Fetch a Strava activity by id. Throws [DioException] (status 404) if deleted.
  static Future<Map<String, dynamic>> fetchActivity(int stravaId) async {
    try {
      LoggingService.debug('Fetching Strava activity: $stravaId');
      final opts = await _authOptions();
      final res = await _dio.get<Map<String, dynamic>>(
        '/activities/$stravaId',
        options: opts,
      );
      LoggingService.debug('Activity fetched successfully: $stravaId');
      return res.data!;
    } catch (e, stackTrace) {
      LoggingService.error(
          'Failed to fetch Strava activity: $stravaId', e, stackTrace);
      rethrow;
    }
  }

  /// Permanently delete a Strava activity.
  static Future<void> deleteActivity(int stravaId) async {
    try {
      LoggingService.info('Deleting Strava activity: $stravaId');
      final opts = await _authOptions();
      await _dio.delete<void>('/activities/$stravaId', options: opts);
      LoggingService.info('Activity deleted successfully: $stravaId');
    } catch (e, stackTrace) {
      LoggingService.error(
          'Failed to delete Strava activity: $stravaId', e, stackTrace);
      rethrow;
    }
  }

  /// Poll until the upload is processed. Returns the Strava activity id.
  static Future<int> pollUpload(int uploadId) async {
    try {
      LoggingService.info('Polling Strava upload: $uploadId');
      while (true) {
        await Future<void>.delayed(const Duration(seconds: 2));
        final opts = await _authOptions();
        final res = await _dio.get<Map<String, dynamic>>(
          '/uploads/$uploadId',
          options: opts,
        );
        final data = res.data!;
        final status = data['status'] as String?;
        if (status == 'Your activity is ready.') {
          final activityId = data['activity_id'] as int;
          LoggingService.info(
              'Upload processed successfully, activity ID: $activityId');
          return activityId;
        }
        final error = data['error'];
        if (error != null && (error as String).isNotEmpty) {
          LoggingService.error('Strava upload error: $error');
          throw Exception('Strava upload error: $error');
        }
        // status is still 'processing' — loop
      }
    } catch (e, stackTrace) {
      LoggingService.error(
          'Error polling Strava upload: $uploadId', e, stackTrace);
      rethrow;
    }
  }
}
