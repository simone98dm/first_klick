import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../core/database/app_database.dart';
import '../../core/strava/strava_api.dart';
import '../home/home_provider.dart';

part 'activity_detail_provider.g.dart';

@riverpod
Future<Activity?> activityDetail(Ref ref, int activityId) =>
    ref.watch(appDatabaseProvider).activitiesDao.findById(activityId);

@riverpod
Future<List<DataPoint>> activityPoints(Ref ref, int activityId) =>
    ref.watch(appDatabaseProvider).dataPointsDao.getForActivity(activityId);

// ── Strava online verification ────────────────────────────────────────────

enum StravaStatus { verified, notFound, error }

/// Checks whether the Strava activity with [stravaId] still exists online.
@riverpod
Future<StravaStatus> stravaStatus(Ref ref, int stravaId) async {
  try {
    await StravaApi.fetchActivity(stravaId);
    return StravaStatus.verified;
  } on DioException catch (e) {
    if (e.response?.statusCode == 404) return StravaStatus.notFound;
    return StravaStatus.error;
  } catch (_) {
    return StravaStatus.error;
  }
}
