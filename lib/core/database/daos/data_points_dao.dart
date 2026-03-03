import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables.dart';

part 'data_points_dao.g.dart';

@DriftAccessor(tables: [DataPoints])
class DataPointsDao extends DatabaseAccessor<AppDatabase>
    with _$DataPointsDaoMixin {
  DataPointsDao(super.db);

  Future<void> insertPoint(DataPointsCompanion entry) =>
      into(dataPoints).insert(entry);

  Future<List<DataPoint>> getForActivity(int activityId) =>
      (select(dataPoints)
            ..where((dp) => dp.activityId.equals(activityId))
            ..orderBy([(dp) => OrderingTerm.asc(dp.recordedAt)]))
          .get();

  Stream<List<DataPoint>> watchForActivity(int activityId) =>
      (select(dataPoints)
            ..where((dp) => dp.activityId.equals(activityId))
            ..orderBy([(dp) => OrderingTerm.asc(dp.recordedAt)]))
          .watch();

  /// Latest point for the given activity (for resume).
  Future<DataPoint?> latestForActivity(int activityId) =>
      (select(dataPoints)
            ..where((dp) => dp.activityId.equals(activityId))
            ..orderBy([(dp) => OrderingTerm.desc(dp.recordedAt)])
            ..limit(1))
          .getSingleOrNull();

  Future<void> deleteForActivity(int activityId) =>
      (delete(dataPoints)
            ..where((dp) => dp.activityId.equals(activityId)))
          .go();
}
