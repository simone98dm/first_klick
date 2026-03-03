import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

import 'tables.dart';
import 'daos/activities_dao.dart';
import 'daos/data_points_dao.dart';

part 'app_database.g.dart';

@DriftDatabase(
  tables: [Activities, DataPoints],
  daos: [ActivitiesDao, DataPointsDao],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) => m.createAll(),
      );
}

QueryExecutor _openConnection() {
  return driftDatabase(name: 'first_klick');
}
