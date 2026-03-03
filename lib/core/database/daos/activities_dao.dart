import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables.dart';

part 'activities_dao.g.dart';

@DriftAccessor(tables: [Activities])
class ActivitiesDao extends DatabaseAccessor<AppDatabase>
    with _$ActivitiesDaoMixin {
  ActivitiesDao(super.db);

  /// All completed + uploaded activities, newest first.
  Stream<List<Activity>> watchAll() => (select(activities)
        ..where((a) => a.status.isNotValue('recording'))
        ..orderBy([(a) => OrderingTerm.desc(a.startedAt)]))
      .watch();

  /// Single activity by id.
  Future<Activity?> findById(int id) =>
      (select(activities)..where((a) => a.id.equals(id))).getSingleOrNull();

  /// Insert a new activity; returns the new row id.
  Future<int> insertActivity(ActivitiesCompanion entry) =>
      into(activities).insert(entry);

  /// Patch any fields (e.g. set status, totals).
  Future<bool> updateActivity(ActivitiesCompanion entry) =>
      update(activities).replace(entry);

  /// Convenience: update specific columns by id.
  Future<int> updateById(int id, ActivitiesCompanion entry) =>
      (update(activities)..where((a) => a.id.equals(id))).write(entry);

  Future<Activity?> findActiveRecording() =>
      (select(activities)..where((a) => a.status.equals('recording')))
          .getSingleOrNull();

  /// Delete an activity by id. Data points are removed by cascade FK.
  Future<int> deleteById(int id) =>
      (delete(activities)..where((a) => a.id.equals(id))).go();
}
