import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../core/database/app_database.dart';
import '../../core/gps/gps_service.dart';

part 'home_provider.g.dart';

/// Provides the singleton AppDatabase instance.
@riverpod
AppDatabase appDatabase(Ref ref) {
  final db = AppDatabase();
  ref.onDispose(db.close);
  return db;
}

/// Watches all completed/uploaded activities ordered newest-first.
@riverpod
Stream<List<Activity>> activitiesList(Ref ref) {
  return ref.watch(appDatabaseProvider).activitiesDao.watchAll();
}

/// Streams the current GPS position, starting with null until the first fix.
/// Used to gate the Start Run button — it stays disabled until the device
/// has a valid location so the activity starting point is never lost.
@riverpod
Stream<Position?> currentGpsPosition(Ref ref) async* {
  yield null; // no fix yet
  yield* GpsService.positionStream();
}
