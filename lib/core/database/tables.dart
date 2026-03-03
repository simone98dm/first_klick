import 'package:drift/drift.dart';

/// Activities table – one row per recorded run.
class Activities extends Table {
  IntColumn get id => integer().autoIncrement()();
  DateTimeColumn get startedAt => dateTime()();
  DateTimeColumn get endedAt => dateTime().nullable()();
  TextColumn get title => text().nullable()();

  /// 'recording' | 'completed' | 'uploaded'
  TextColumn get status => text().withDefault(const Constant('recording'))();
  IntColumn get stravaId => integer().nullable()();
  RealColumn get totalDistanceM => real().nullable()();
  IntColumn get totalDurationS => integer().nullable()();
  RealColumn get avgBpm => real().nullable()();
  IntColumn get maxBpm => integer().nullable()();
  RealColumn get avgPaceSPerKm => real().nullable()();
  RealColumn get elevationGainM => real().nullable()();
}

/// Individual GPS + BPM samples, written every ~3 s.
class DataPoints extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get activityId =>
      integer().references(Activities, #id, onDelete: KeyAction.cascade)();
  DateTimeColumn get recordedAt => dateTime()();
  RealColumn get lat => real()();
  RealColumn get lng => real()();
  RealColumn get altitudeM => real().nullable()();
  RealColumn get accuracyM => real().nullable()();
  RealColumn get distanceFromPrevM => real().nullable()();
  RealColumn get cumulativeDistanceM => real()();
  RealColumn get speedMs => real().nullable()();
  IntColumn get bpm => integer().nullable()();
}
