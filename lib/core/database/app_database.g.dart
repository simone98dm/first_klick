// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $ActivitiesTable extends Activities
    with TableInfo<$ActivitiesTable, Activity> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ActivitiesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _startedAtMeta =
      const VerificationMeta('startedAt');
  @override
  late final GeneratedColumn<DateTime> startedAt = GeneratedColumn<DateTime>(
      'started_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _endedAtMeta =
      const VerificationMeta('endedAt');
  @override
  late final GeneratedColumn<DateTime> endedAt = GeneratedColumn<DateTime>(
      'ended_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
      'title', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
      'status', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('recording'));
  static const VerificationMeta _stravaIdMeta =
      const VerificationMeta('stravaId');
  @override
  late final GeneratedColumn<int> stravaId = GeneratedColumn<int>(
      'strava_id', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _totalDistanceMMeta =
      const VerificationMeta('totalDistanceM');
  @override
  late final GeneratedColumn<double> totalDistanceM = GeneratedColumn<double>(
      'total_distance_m', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _totalDurationSMeta =
      const VerificationMeta('totalDurationS');
  @override
  late final GeneratedColumn<int> totalDurationS = GeneratedColumn<int>(
      'total_duration_s', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _avgBpmMeta = const VerificationMeta('avgBpm');
  @override
  late final GeneratedColumn<double> avgBpm = GeneratedColumn<double>(
      'avg_bpm', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _maxBpmMeta = const VerificationMeta('maxBpm');
  @override
  late final GeneratedColumn<int> maxBpm = GeneratedColumn<int>(
      'max_bpm', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _avgPaceSPerKmMeta =
      const VerificationMeta('avgPaceSPerKm');
  @override
  late final GeneratedColumn<double> avgPaceSPerKm = GeneratedColumn<double>(
      'avg_pace_s_per_km', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _elevationGainMMeta =
      const VerificationMeta('elevationGainM');
  @override
  late final GeneratedColumn<double> elevationGainM = GeneratedColumn<double>(
      'elevation_gain_m', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        startedAt,
        endedAt,
        title,
        status,
        stravaId,
        totalDistanceM,
        totalDurationS,
        avgBpm,
        maxBpm,
        avgPaceSPerKm,
        elevationGainM
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'activities';
  @override
  VerificationContext validateIntegrity(Insertable<Activity> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('started_at')) {
      context.handle(_startedAtMeta,
          startedAt.isAcceptableOrUnknown(data['started_at']!, _startedAtMeta));
    } else if (isInserting) {
      context.missing(_startedAtMeta);
    }
    if (data.containsKey('ended_at')) {
      context.handle(_endedAtMeta,
          endedAt.isAcceptableOrUnknown(data['ended_at']!, _endedAtMeta));
    }
    if (data.containsKey('title')) {
      context.handle(
          _titleMeta, title.isAcceptableOrUnknown(data['title']!, _titleMeta));
    }
    if (data.containsKey('status')) {
      context.handle(_statusMeta,
          status.isAcceptableOrUnknown(data['status']!, _statusMeta));
    }
    if (data.containsKey('strava_id')) {
      context.handle(_stravaIdMeta,
          stravaId.isAcceptableOrUnknown(data['strava_id']!, _stravaIdMeta));
    }
    if (data.containsKey('total_distance_m')) {
      context.handle(
          _totalDistanceMMeta,
          totalDistanceM.isAcceptableOrUnknown(
              data['total_distance_m']!, _totalDistanceMMeta));
    }
    if (data.containsKey('total_duration_s')) {
      context.handle(
          _totalDurationSMeta,
          totalDurationS.isAcceptableOrUnknown(
              data['total_duration_s']!, _totalDurationSMeta));
    }
    if (data.containsKey('avg_bpm')) {
      context.handle(_avgBpmMeta,
          avgBpm.isAcceptableOrUnknown(data['avg_bpm']!, _avgBpmMeta));
    }
    if (data.containsKey('max_bpm')) {
      context.handle(_maxBpmMeta,
          maxBpm.isAcceptableOrUnknown(data['max_bpm']!, _maxBpmMeta));
    }
    if (data.containsKey('avg_pace_s_per_km')) {
      context.handle(
          _avgPaceSPerKmMeta,
          avgPaceSPerKm.isAcceptableOrUnknown(
              data['avg_pace_s_per_km']!, _avgPaceSPerKmMeta));
    }
    if (data.containsKey('elevation_gain_m')) {
      context.handle(
          _elevationGainMMeta,
          elevationGainM.isAcceptableOrUnknown(
              data['elevation_gain_m']!, _elevationGainMMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Activity map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Activity(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      startedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}started_at'])!,
      endedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}ended_at']),
      title: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}title']),
      status: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}status'])!,
      stravaId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}strava_id']),
      totalDistanceM: attachedDatabase.typeMapping.read(
          DriftSqlType.double, data['${effectivePrefix}total_distance_m']),
      totalDurationS: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}total_duration_s']),
      avgBpm: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}avg_bpm']),
      maxBpm: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}max_bpm']),
      avgPaceSPerKm: attachedDatabase.typeMapping.read(
          DriftSqlType.double, data['${effectivePrefix}avg_pace_s_per_km']),
      elevationGainM: attachedDatabase.typeMapping.read(
          DriftSqlType.double, data['${effectivePrefix}elevation_gain_m']),
    );
  }

  @override
  $ActivitiesTable createAlias(String alias) {
    return $ActivitiesTable(attachedDatabase, alias);
  }
}

class Activity extends DataClass implements Insertable<Activity> {
  final int id;
  final DateTime startedAt;
  final DateTime? endedAt;
  final String? title;

  /// 'recording' | 'completed' | 'uploaded'
  final String status;
  final int? stravaId;
  final double? totalDistanceM;
  final int? totalDurationS;
  final double? avgBpm;
  final int? maxBpm;
  final double? avgPaceSPerKm;
  final double? elevationGainM;
  const Activity(
      {required this.id,
      required this.startedAt,
      this.endedAt,
      this.title,
      required this.status,
      this.stravaId,
      this.totalDistanceM,
      this.totalDurationS,
      this.avgBpm,
      this.maxBpm,
      this.avgPaceSPerKm,
      this.elevationGainM});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['started_at'] = Variable<DateTime>(startedAt);
    if (!nullToAbsent || endedAt != null) {
      map['ended_at'] = Variable<DateTime>(endedAt);
    }
    if (!nullToAbsent || title != null) {
      map['title'] = Variable<String>(title);
    }
    map['status'] = Variable<String>(status);
    if (!nullToAbsent || stravaId != null) {
      map['strava_id'] = Variable<int>(stravaId);
    }
    if (!nullToAbsent || totalDistanceM != null) {
      map['total_distance_m'] = Variable<double>(totalDistanceM);
    }
    if (!nullToAbsent || totalDurationS != null) {
      map['total_duration_s'] = Variable<int>(totalDurationS);
    }
    if (!nullToAbsent || avgBpm != null) {
      map['avg_bpm'] = Variable<double>(avgBpm);
    }
    if (!nullToAbsent || maxBpm != null) {
      map['max_bpm'] = Variable<int>(maxBpm);
    }
    if (!nullToAbsent || avgPaceSPerKm != null) {
      map['avg_pace_s_per_km'] = Variable<double>(avgPaceSPerKm);
    }
    if (!nullToAbsent || elevationGainM != null) {
      map['elevation_gain_m'] = Variable<double>(elevationGainM);
    }
    return map;
  }

  ActivitiesCompanion toCompanion(bool nullToAbsent) {
    return ActivitiesCompanion(
      id: Value(id),
      startedAt: Value(startedAt),
      endedAt: endedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(endedAt),
      title:
          title == null && nullToAbsent ? const Value.absent() : Value(title),
      status: Value(status),
      stravaId: stravaId == null && nullToAbsent
          ? const Value.absent()
          : Value(stravaId),
      totalDistanceM: totalDistanceM == null && nullToAbsent
          ? const Value.absent()
          : Value(totalDistanceM),
      totalDurationS: totalDurationS == null && nullToAbsent
          ? const Value.absent()
          : Value(totalDurationS),
      avgBpm:
          avgBpm == null && nullToAbsent ? const Value.absent() : Value(avgBpm),
      maxBpm:
          maxBpm == null && nullToAbsent ? const Value.absent() : Value(maxBpm),
      avgPaceSPerKm: avgPaceSPerKm == null && nullToAbsent
          ? const Value.absent()
          : Value(avgPaceSPerKm),
      elevationGainM: elevationGainM == null && nullToAbsent
          ? const Value.absent()
          : Value(elevationGainM),
    );
  }

  factory Activity.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Activity(
      id: serializer.fromJson<int>(json['id']),
      startedAt: serializer.fromJson<DateTime>(json['startedAt']),
      endedAt: serializer.fromJson<DateTime?>(json['endedAt']),
      title: serializer.fromJson<String?>(json['title']),
      status: serializer.fromJson<String>(json['status']),
      stravaId: serializer.fromJson<int?>(json['stravaId']),
      totalDistanceM: serializer.fromJson<double?>(json['totalDistanceM']),
      totalDurationS: serializer.fromJson<int?>(json['totalDurationS']),
      avgBpm: serializer.fromJson<double?>(json['avgBpm']),
      maxBpm: serializer.fromJson<int?>(json['maxBpm']),
      avgPaceSPerKm: serializer.fromJson<double?>(json['avgPaceSPerKm']),
      elevationGainM: serializer.fromJson<double?>(json['elevationGainM']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'startedAt': serializer.toJson<DateTime>(startedAt),
      'endedAt': serializer.toJson<DateTime?>(endedAt),
      'title': serializer.toJson<String?>(title),
      'status': serializer.toJson<String>(status),
      'stravaId': serializer.toJson<int?>(stravaId),
      'totalDistanceM': serializer.toJson<double?>(totalDistanceM),
      'totalDurationS': serializer.toJson<int?>(totalDurationS),
      'avgBpm': serializer.toJson<double?>(avgBpm),
      'maxBpm': serializer.toJson<int?>(maxBpm),
      'avgPaceSPerKm': serializer.toJson<double?>(avgPaceSPerKm),
      'elevationGainM': serializer.toJson<double?>(elevationGainM),
    };
  }

  Activity copyWith(
          {int? id,
          DateTime? startedAt,
          Value<DateTime?> endedAt = const Value.absent(),
          Value<String?> title = const Value.absent(),
          String? status,
          Value<int?> stravaId = const Value.absent(),
          Value<double?> totalDistanceM = const Value.absent(),
          Value<int?> totalDurationS = const Value.absent(),
          Value<double?> avgBpm = const Value.absent(),
          Value<int?> maxBpm = const Value.absent(),
          Value<double?> avgPaceSPerKm = const Value.absent(),
          Value<double?> elevationGainM = const Value.absent()}) =>
      Activity(
        id: id ?? this.id,
        startedAt: startedAt ?? this.startedAt,
        endedAt: endedAt.present ? endedAt.value : this.endedAt,
        title: title.present ? title.value : this.title,
        status: status ?? this.status,
        stravaId: stravaId.present ? stravaId.value : this.stravaId,
        totalDistanceM:
            totalDistanceM.present ? totalDistanceM.value : this.totalDistanceM,
        totalDurationS:
            totalDurationS.present ? totalDurationS.value : this.totalDurationS,
        avgBpm: avgBpm.present ? avgBpm.value : this.avgBpm,
        maxBpm: maxBpm.present ? maxBpm.value : this.maxBpm,
        avgPaceSPerKm:
            avgPaceSPerKm.present ? avgPaceSPerKm.value : this.avgPaceSPerKm,
        elevationGainM:
            elevationGainM.present ? elevationGainM.value : this.elevationGainM,
      );
  Activity copyWithCompanion(ActivitiesCompanion data) {
    return Activity(
      id: data.id.present ? data.id.value : this.id,
      startedAt: data.startedAt.present ? data.startedAt.value : this.startedAt,
      endedAt: data.endedAt.present ? data.endedAt.value : this.endedAt,
      title: data.title.present ? data.title.value : this.title,
      status: data.status.present ? data.status.value : this.status,
      stravaId: data.stravaId.present ? data.stravaId.value : this.stravaId,
      totalDistanceM: data.totalDistanceM.present
          ? data.totalDistanceM.value
          : this.totalDistanceM,
      totalDurationS: data.totalDurationS.present
          ? data.totalDurationS.value
          : this.totalDurationS,
      avgBpm: data.avgBpm.present ? data.avgBpm.value : this.avgBpm,
      maxBpm: data.maxBpm.present ? data.maxBpm.value : this.maxBpm,
      avgPaceSPerKm: data.avgPaceSPerKm.present
          ? data.avgPaceSPerKm.value
          : this.avgPaceSPerKm,
      elevationGainM: data.elevationGainM.present
          ? data.elevationGainM.value
          : this.elevationGainM,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Activity(')
          ..write('id: $id, ')
          ..write('startedAt: $startedAt, ')
          ..write('endedAt: $endedAt, ')
          ..write('title: $title, ')
          ..write('status: $status, ')
          ..write('stravaId: $stravaId, ')
          ..write('totalDistanceM: $totalDistanceM, ')
          ..write('totalDurationS: $totalDurationS, ')
          ..write('avgBpm: $avgBpm, ')
          ..write('maxBpm: $maxBpm, ')
          ..write('avgPaceSPerKm: $avgPaceSPerKm, ')
          ..write('elevationGainM: $elevationGainM')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      startedAt,
      endedAt,
      title,
      status,
      stravaId,
      totalDistanceM,
      totalDurationS,
      avgBpm,
      maxBpm,
      avgPaceSPerKm,
      elevationGainM);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Activity &&
          other.id == this.id &&
          other.startedAt == this.startedAt &&
          other.endedAt == this.endedAt &&
          other.title == this.title &&
          other.status == this.status &&
          other.stravaId == this.stravaId &&
          other.totalDistanceM == this.totalDistanceM &&
          other.totalDurationS == this.totalDurationS &&
          other.avgBpm == this.avgBpm &&
          other.maxBpm == this.maxBpm &&
          other.avgPaceSPerKm == this.avgPaceSPerKm &&
          other.elevationGainM == this.elevationGainM);
}

class ActivitiesCompanion extends UpdateCompanion<Activity> {
  final Value<int> id;
  final Value<DateTime> startedAt;
  final Value<DateTime?> endedAt;
  final Value<String?> title;
  final Value<String> status;
  final Value<int?> stravaId;
  final Value<double?> totalDistanceM;
  final Value<int?> totalDurationS;
  final Value<double?> avgBpm;
  final Value<int?> maxBpm;
  final Value<double?> avgPaceSPerKm;
  final Value<double?> elevationGainM;
  const ActivitiesCompanion({
    this.id = const Value.absent(),
    this.startedAt = const Value.absent(),
    this.endedAt = const Value.absent(),
    this.title = const Value.absent(),
    this.status = const Value.absent(),
    this.stravaId = const Value.absent(),
    this.totalDistanceM = const Value.absent(),
    this.totalDurationS = const Value.absent(),
    this.avgBpm = const Value.absent(),
    this.maxBpm = const Value.absent(),
    this.avgPaceSPerKm = const Value.absent(),
    this.elevationGainM = const Value.absent(),
  });
  ActivitiesCompanion.insert({
    this.id = const Value.absent(),
    required DateTime startedAt,
    this.endedAt = const Value.absent(),
    this.title = const Value.absent(),
    this.status = const Value.absent(),
    this.stravaId = const Value.absent(),
    this.totalDistanceM = const Value.absent(),
    this.totalDurationS = const Value.absent(),
    this.avgBpm = const Value.absent(),
    this.maxBpm = const Value.absent(),
    this.avgPaceSPerKm = const Value.absent(),
    this.elevationGainM = const Value.absent(),
  }) : startedAt = Value(startedAt);
  static Insertable<Activity> custom({
    Expression<int>? id,
    Expression<DateTime>? startedAt,
    Expression<DateTime>? endedAt,
    Expression<String>? title,
    Expression<String>? status,
    Expression<int>? stravaId,
    Expression<double>? totalDistanceM,
    Expression<int>? totalDurationS,
    Expression<double>? avgBpm,
    Expression<int>? maxBpm,
    Expression<double>? avgPaceSPerKm,
    Expression<double>? elevationGainM,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (startedAt != null) 'started_at': startedAt,
      if (endedAt != null) 'ended_at': endedAt,
      if (title != null) 'title': title,
      if (status != null) 'status': status,
      if (stravaId != null) 'strava_id': stravaId,
      if (totalDistanceM != null) 'total_distance_m': totalDistanceM,
      if (totalDurationS != null) 'total_duration_s': totalDurationS,
      if (avgBpm != null) 'avg_bpm': avgBpm,
      if (maxBpm != null) 'max_bpm': maxBpm,
      if (avgPaceSPerKm != null) 'avg_pace_s_per_km': avgPaceSPerKm,
      if (elevationGainM != null) 'elevation_gain_m': elevationGainM,
    });
  }

  ActivitiesCompanion copyWith(
      {Value<int>? id,
      Value<DateTime>? startedAt,
      Value<DateTime?>? endedAt,
      Value<String?>? title,
      Value<String>? status,
      Value<int?>? stravaId,
      Value<double?>? totalDistanceM,
      Value<int?>? totalDurationS,
      Value<double?>? avgBpm,
      Value<int?>? maxBpm,
      Value<double?>? avgPaceSPerKm,
      Value<double?>? elevationGainM}) {
    return ActivitiesCompanion(
      id: id ?? this.id,
      startedAt: startedAt ?? this.startedAt,
      endedAt: endedAt ?? this.endedAt,
      title: title ?? this.title,
      status: status ?? this.status,
      stravaId: stravaId ?? this.stravaId,
      totalDistanceM: totalDistanceM ?? this.totalDistanceM,
      totalDurationS: totalDurationS ?? this.totalDurationS,
      avgBpm: avgBpm ?? this.avgBpm,
      maxBpm: maxBpm ?? this.maxBpm,
      avgPaceSPerKm: avgPaceSPerKm ?? this.avgPaceSPerKm,
      elevationGainM: elevationGainM ?? this.elevationGainM,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (startedAt.present) {
      map['started_at'] = Variable<DateTime>(startedAt.value);
    }
    if (endedAt.present) {
      map['ended_at'] = Variable<DateTime>(endedAt.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (stravaId.present) {
      map['strava_id'] = Variable<int>(stravaId.value);
    }
    if (totalDistanceM.present) {
      map['total_distance_m'] = Variable<double>(totalDistanceM.value);
    }
    if (totalDurationS.present) {
      map['total_duration_s'] = Variable<int>(totalDurationS.value);
    }
    if (avgBpm.present) {
      map['avg_bpm'] = Variable<double>(avgBpm.value);
    }
    if (maxBpm.present) {
      map['max_bpm'] = Variable<int>(maxBpm.value);
    }
    if (avgPaceSPerKm.present) {
      map['avg_pace_s_per_km'] = Variable<double>(avgPaceSPerKm.value);
    }
    if (elevationGainM.present) {
      map['elevation_gain_m'] = Variable<double>(elevationGainM.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ActivitiesCompanion(')
          ..write('id: $id, ')
          ..write('startedAt: $startedAt, ')
          ..write('endedAt: $endedAt, ')
          ..write('title: $title, ')
          ..write('status: $status, ')
          ..write('stravaId: $stravaId, ')
          ..write('totalDistanceM: $totalDistanceM, ')
          ..write('totalDurationS: $totalDurationS, ')
          ..write('avgBpm: $avgBpm, ')
          ..write('maxBpm: $maxBpm, ')
          ..write('avgPaceSPerKm: $avgPaceSPerKm, ')
          ..write('elevationGainM: $elevationGainM')
          ..write(')'))
        .toString();
  }
}

class $DataPointsTable extends DataPoints
    with TableInfo<$DataPointsTable, DataPoint> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DataPointsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _activityIdMeta =
      const VerificationMeta('activityId');
  @override
  late final GeneratedColumn<int> activityId = GeneratedColumn<int>(
      'activity_id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES activities (id) ON DELETE CASCADE'));
  static const VerificationMeta _recordedAtMeta =
      const VerificationMeta('recordedAt');
  @override
  late final GeneratedColumn<DateTime> recordedAt = GeneratedColumn<DateTime>(
      'recorded_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _latMeta = const VerificationMeta('lat');
  @override
  late final GeneratedColumn<double> lat = GeneratedColumn<double>(
      'lat', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _lngMeta = const VerificationMeta('lng');
  @override
  late final GeneratedColumn<double> lng = GeneratedColumn<double>(
      'lng', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _altitudeMMeta =
      const VerificationMeta('altitudeM');
  @override
  late final GeneratedColumn<double> altitudeM = GeneratedColumn<double>(
      'altitude_m', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _accuracyMMeta =
      const VerificationMeta('accuracyM');
  @override
  late final GeneratedColumn<double> accuracyM = GeneratedColumn<double>(
      'accuracy_m', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _distanceFromPrevMMeta =
      const VerificationMeta('distanceFromPrevM');
  @override
  late final GeneratedColumn<double> distanceFromPrevM =
      GeneratedColumn<double>('distance_from_prev_m', aliasedName, true,
          type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _cumulativeDistanceMMeta =
      const VerificationMeta('cumulativeDistanceM');
  @override
  late final GeneratedColumn<double> cumulativeDistanceM =
      GeneratedColumn<double>('cumulative_distance_m', aliasedName, false,
          type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _speedMsMeta =
      const VerificationMeta('speedMs');
  @override
  late final GeneratedColumn<double> speedMs = GeneratedColumn<double>(
      'speed_ms', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _bpmMeta = const VerificationMeta('bpm');
  @override
  late final GeneratedColumn<int> bpm = GeneratedColumn<int>(
      'bpm', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        activityId,
        recordedAt,
        lat,
        lng,
        altitudeM,
        accuracyM,
        distanceFromPrevM,
        cumulativeDistanceM,
        speedMs,
        bpm
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'data_points';
  @override
  VerificationContext validateIntegrity(Insertable<DataPoint> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('activity_id')) {
      context.handle(
          _activityIdMeta,
          activityId.isAcceptableOrUnknown(
              data['activity_id']!, _activityIdMeta));
    } else if (isInserting) {
      context.missing(_activityIdMeta);
    }
    if (data.containsKey('recorded_at')) {
      context.handle(
          _recordedAtMeta,
          recordedAt.isAcceptableOrUnknown(
              data['recorded_at']!, _recordedAtMeta));
    } else if (isInserting) {
      context.missing(_recordedAtMeta);
    }
    if (data.containsKey('lat')) {
      context.handle(
          _latMeta, lat.isAcceptableOrUnknown(data['lat']!, _latMeta));
    } else if (isInserting) {
      context.missing(_latMeta);
    }
    if (data.containsKey('lng')) {
      context.handle(
          _lngMeta, lng.isAcceptableOrUnknown(data['lng']!, _lngMeta));
    } else if (isInserting) {
      context.missing(_lngMeta);
    }
    if (data.containsKey('altitude_m')) {
      context.handle(_altitudeMMeta,
          altitudeM.isAcceptableOrUnknown(data['altitude_m']!, _altitudeMMeta));
    }
    if (data.containsKey('accuracy_m')) {
      context.handle(_accuracyMMeta,
          accuracyM.isAcceptableOrUnknown(data['accuracy_m']!, _accuracyMMeta));
    }
    if (data.containsKey('distance_from_prev_m')) {
      context.handle(
          _distanceFromPrevMMeta,
          distanceFromPrevM.isAcceptableOrUnknown(
              data['distance_from_prev_m']!, _distanceFromPrevMMeta));
    }
    if (data.containsKey('cumulative_distance_m')) {
      context.handle(
          _cumulativeDistanceMMeta,
          cumulativeDistanceM.isAcceptableOrUnknown(
              data['cumulative_distance_m']!, _cumulativeDistanceMMeta));
    } else if (isInserting) {
      context.missing(_cumulativeDistanceMMeta);
    }
    if (data.containsKey('speed_ms')) {
      context.handle(_speedMsMeta,
          speedMs.isAcceptableOrUnknown(data['speed_ms']!, _speedMsMeta));
    }
    if (data.containsKey('bpm')) {
      context.handle(
          _bpmMeta, bpm.isAcceptableOrUnknown(data['bpm']!, _bpmMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  DataPoint map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DataPoint(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      activityId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}activity_id'])!,
      recordedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}recorded_at'])!,
      lat: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}lat'])!,
      lng: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}lng'])!,
      altitudeM: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}altitude_m']),
      accuracyM: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}accuracy_m']),
      distanceFromPrevM: attachedDatabase.typeMapping.read(
          DriftSqlType.double, data['${effectivePrefix}distance_from_prev_m']),
      cumulativeDistanceM: attachedDatabase.typeMapping.read(
          DriftSqlType.double,
          data['${effectivePrefix}cumulative_distance_m'])!,
      speedMs: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}speed_ms']),
      bpm: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}bpm']),
    );
  }

  @override
  $DataPointsTable createAlias(String alias) {
    return $DataPointsTable(attachedDatabase, alias);
  }
}

class DataPoint extends DataClass implements Insertable<DataPoint> {
  final int id;
  final int activityId;
  final DateTime recordedAt;
  final double lat;
  final double lng;
  final double? altitudeM;
  final double? accuracyM;
  final double? distanceFromPrevM;
  final double cumulativeDistanceM;
  final double? speedMs;
  final int? bpm;
  const DataPoint(
      {required this.id,
      required this.activityId,
      required this.recordedAt,
      required this.lat,
      required this.lng,
      this.altitudeM,
      this.accuracyM,
      this.distanceFromPrevM,
      required this.cumulativeDistanceM,
      this.speedMs,
      this.bpm});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['activity_id'] = Variable<int>(activityId);
    map['recorded_at'] = Variable<DateTime>(recordedAt);
    map['lat'] = Variable<double>(lat);
    map['lng'] = Variable<double>(lng);
    if (!nullToAbsent || altitudeM != null) {
      map['altitude_m'] = Variable<double>(altitudeM);
    }
    if (!nullToAbsent || accuracyM != null) {
      map['accuracy_m'] = Variable<double>(accuracyM);
    }
    if (!nullToAbsent || distanceFromPrevM != null) {
      map['distance_from_prev_m'] = Variable<double>(distanceFromPrevM);
    }
    map['cumulative_distance_m'] = Variable<double>(cumulativeDistanceM);
    if (!nullToAbsent || speedMs != null) {
      map['speed_ms'] = Variable<double>(speedMs);
    }
    if (!nullToAbsent || bpm != null) {
      map['bpm'] = Variable<int>(bpm);
    }
    return map;
  }

  DataPointsCompanion toCompanion(bool nullToAbsent) {
    return DataPointsCompanion(
      id: Value(id),
      activityId: Value(activityId),
      recordedAt: Value(recordedAt),
      lat: Value(lat),
      lng: Value(lng),
      altitudeM: altitudeM == null && nullToAbsent
          ? const Value.absent()
          : Value(altitudeM),
      accuracyM: accuracyM == null && nullToAbsent
          ? const Value.absent()
          : Value(accuracyM),
      distanceFromPrevM: distanceFromPrevM == null && nullToAbsent
          ? const Value.absent()
          : Value(distanceFromPrevM),
      cumulativeDistanceM: Value(cumulativeDistanceM),
      speedMs: speedMs == null && nullToAbsent
          ? const Value.absent()
          : Value(speedMs),
      bpm: bpm == null && nullToAbsent ? const Value.absent() : Value(bpm),
    );
  }

  factory DataPoint.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DataPoint(
      id: serializer.fromJson<int>(json['id']),
      activityId: serializer.fromJson<int>(json['activityId']),
      recordedAt: serializer.fromJson<DateTime>(json['recordedAt']),
      lat: serializer.fromJson<double>(json['lat']),
      lng: serializer.fromJson<double>(json['lng']),
      altitudeM: serializer.fromJson<double?>(json['altitudeM']),
      accuracyM: serializer.fromJson<double?>(json['accuracyM']),
      distanceFromPrevM:
          serializer.fromJson<double?>(json['distanceFromPrevM']),
      cumulativeDistanceM:
          serializer.fromJson<double>(json['cumulativeDistanceM']),
      speedMs: serializer.fromJson<double?>(json['speedMs']),
      bpm: serializer.fromJson<int?>(json['bpm']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'activityId': serializer.toJson<int>(activityId),
      'recordedAt': serializer.toJson<DateTime>(recordedAt),
      'lat': serializer.toJson<double>(lat),
      'lng': serializer.toJson<double>(lng),
      'altitudeM': serializer.toJson<double?>(altitudeM),
      'accuracyM': serializer.toJson<double?>(accuracyM),
      'distanceFromPrevM': serializer.toJson<double?>(distanceFromPrevM),
      'cumulativeDistanceM': serializer.toJson<double>(cumulativeDistanceM),
      'speedMs': serializer.toJson<double?>(speedMs),
      'bpm': serializer.toJson<int?>(bpm),
    };
  }

  DataPoint copyWith(
          {int? id,
          int? activityId,
          DateTime? recordedAt,
          double? lat,
          double? lng,
          Value<double?> altitudeM = const Value.absent(),
          Value<double?> accuracyM = const Value.absent(),
          Value<double?> distanceFromPrevM = const Value.absent(),
          double? cumulativeDistanceM,
          Value<double?> speedMs = const Value.absent(),
          Value<int?> bpm = const Value.absent()}) =>
      DataPoint(
        id: id ?? this.id,
        activityId: activityId ?? this.activityId,
        recordedAt: recordedAt ?? this.recordedAt,
        lat: lat ?? this.lat,
        lng: lng ?? this.lng,
        altitudeM: altitudeM.present ? altitudeM.value : this.altitudeM,
        accuracyM: accuracyM.present ? accuracyM.value : this.accuracyM,
        distanceFromPrevM: distanceFromPrevM.present
            ? distanceFromPrevM.value
            : this.distanceFromPrevM,
        cumulativeDistanceM: cumulativeDistanceM ?? this.cumulativeDistanceM,
        speedMs: speedMs.present ? speedMs.value : this.speedMs,
        bpm: bpm.present ? bpm.value : this.bpm,
      );
  DataPoint copyWithCompanion(DataPointsCompanion data) {
    return DataPoint(
      id: data.id.present ? data.id.value : this.id,
      activityId:
          data.activityId.present ? data.activityId.value : this.activityId,
      recordedAt:
          data.recordedAt.present ? data.recordedAt.value : this.recordedAt,
      lat: data.lat.present ? data.lat.value : this.lat,
      lng: data.lng.present ? data.lng.value : this.lng,
      altitudeM: data.altitudeM.present ? data.altitudeM.value : this.altitudeM,
      accuracyM: data.accuracyM.present ? data.accuracyM.value : this.accuracyM,
      distanceFromPrevM: data.distanceFromPrevM.present
          ? data.distanceFromPrevM.value
          : this.distanceFromPrevM,
      cumulativeDistanceM: data.cumulativeDistanceM.present
          ? data.cumulativeDistanceM.value
          : this.cumulativeDistanceM,
      speedMs: data.speedMs.present ? data.speedMs.value : this.speedMs,
      bpm: data.bpm.present ? data.bpm.value : this.bpm,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DataPoint(')
          ..write('id: $id, ')
          ..write('activityId: $activityId, ')
          ..write('recordedAt: $recordedAt, ')
          ..write('lat: $lat, ')
          ..write('lng: $lng, ')
          ..write('altitudeM: $altitudeM, ')
          ..write('accuracyM: $accuracyM, ')
          ..write('distanceFromPrevM: $distanceFromPrevM, ')
          ..write('cumulativeDistanceM: $cumulativeDistanceM, ')
          ..write('speedMs: $speedMs, ')
          ..write('bpm: $bpm')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      activityId,
      recordedAt,
      lat,
      lng,
      altitudeM,
      accuracyM,
      distanceFromPrevM,
      cumulativeDistanceM,
      speedMs,
      bpm);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DataPoint &&
          other.id == this.id &&
          other.activityId == this.activityId &&
          other.recordedAt == this.recordedAt &&
          other.lat == this.lat &&
          other.lng == this.lng &&
          other.altitudeM == this.altitudeM &&
          other.accuracyM == this.accuracyM &&
          other.distanceFromPrevM == this.distanceFromPrevM &&
          other.cumulativeDistanceM == this.cumulativeDistanceM &&
          other.speedMs == this.speedMs &&
          other.bpm == this.bpm);
}

class DataPointsCompanion extends UpdateCompanion<DataPoint> {
  final Value<int> id;
  final Value<int> activityId;
  final Value<DateTime> recordedAt;
  final Value<double> lat;
  final Value<double> lng;
  final Value<double?> altitudeM;
  final Value<double?> accuracyM;
  final Value<double?> distanceFromPrevM;
  final Value<double> cumulativeDistanceM;
  final Value<double?> speedMs;
  final Value<int?> bpm;
  const DataPointsCompanion({
    this.id = const Value.absent(),
    this.activityId = const Value.absent(),
    this.recordedAt = const Value.absent(),
    this.lat = const Value.absent(),
    this.lng = const Value.absent(),
    this.altitudeM = const Value.absent(),
    this.accuracyM = const Value.absent(),
    this.distanceFromPrevM = const Value.absent(),
    this.cumulativeDistanceM = const Value.absent(),
    this.speedMs = const Value.absent(),
    this.bpm = const Value.absent(),
  });
  DataPointsCompanion.insert({
    this.id = const Value.absent(),
    required int activityId,
    required DateTime recordedAt,
    required double lat,
    required double lng,
    this.altitudeM = const Value.absent(),
    this.accuracyM = const Value.absent(),
    this.distanceFromPrevM = const Value.absent(),
    required double cumulativeDistanceM,
    this.speedMs = const Value.absent(),
    this.bpm = const Value.absent(),
  })  : activityId = Value(activityId),
        recordedAt = Value(recordedAt),
        lat = Value(lat),
        lng = Value(lng),
        cumulativeDistanceM = Value(cumulativeDistanceM);
  static Insertable<DataPoint> custom({
    Expression<int>? id,
    Expression<int>? activityId,
    Expression<DateTime>? recordedAt,
    Expression<double>? lat,
    Expression<double>? lng,
    Expression<double>? altitudeM,
    Expression<double>? accuracyM,
    Expression<double>? distanceFromPrevM,
    Expression<double>? cumulativeDistanceM,
    Expression<double>? speedMs,
    Expression<int>? bpm,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (activityId != null) 'activity_id': activityId,
      if (recordedAt != null) 'recorded_at': recordedAt,
      if (lat != null) 'lat': lat,
      if (lng != null) 'lng': lng,
      if (altitudeM != null) 'altitude_m': altitudeM,
      if (accuracyM != null) 'accuracy_m': accuracyM,
      if (distanceFromPrevM != null) 'distance_from_prev_m': distanceFromPrevM,
      if (cumulativeDistanceM != null)
        'cumulative_distance_m': cumulativeDistanceM,
      if (speedMs != null) 'speed_ms': speedMs,
      if (bpm != null) 'bpm': bpm,
    });
  }

  DataPointsCompanion copyWith(
      {Value<int>? id,
      Value<int>? activityId,
      Value<DateTime>? recordedAt,
      Value<double>? lat,
      Value<double>? lng,
      Value<double?>? altitudeM,
      Value<double?>? accuracyM,
      Value<double?>? distanceFromPrevM,
      Value<double>? cumulativeDistanceM,
      Value<double?>? speedMs,
      Value<int?>? bpm}) {
    return DataPointsCompanion(
      id: id ?? this.id,
      activityId: activityId ?? this.activityId,
      recordedAt: recordedAt ?? this.recordedAt,
      lat: lat ?? this.lat,
      lng: lng ?? this.lng,
      altitudeM: altitudeM ?? this.altitudeM,
      accuracyM: accuracyM ?? this.accuracyM,
      distanceFromPrevM: distanceFromPrevM ?? this.distanceFromPrevM,
      cumulativeDistanceM: cumulativeDistanceM ?? this.cumulativeDistanceM,
      speedMs: speedMs ?? this.speedMs,
      bpm: bpm ?? this.bpm,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (activityId.present) {
      map['activity_id'] = Variable<int>(activityId.value);
    }
    if (recordedAt.present) {
      map['recorded_at'] = Variable<DateTime>(recordedAt.value);
    }
    if (lat.present) {
      map['lat'] = Variable<double>(lat.value);
    }
    if (lng.present) {
      map['lng'] = Variable<double>(lng.value);
    }
    if (altitudeM.present) {
      map['altitude_m'] = Variable<double>(altitudeM.value);
    }
    if (accuracyM.present) {
      map['accuracy_m'] = Variable<double>(accuracyM.value);
    }
    if (distanceFromPrevM.present) {
      map['distance_from_prev_m'] = Variable<double>(distanceFromPrevM.value);
    }
    if (cumulativeDistanceM.present) {
      map['cumulative_distance_m'] =
          Variable<double>(cumulativeDistanceM.value);
    }
    if (speedMs.present) {
      map['speed_ms'] = Variable<double>(speedMs.value);
    }
    if (bpm.present) {
      map['bpm'] = Variable<int>(bpm.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DataPointsCompanion(')
          ..write('id: $id, ')
          ..write('activityId: $activityId, ')
          ..write('recordedAt: $recordedAt, ')
          ..write('lat: $lat, ')
          ..write('lng: $lng, ')
          ..write('altitudeM: $altitudeM, ')
          ..write('accuracyM: $accuracyM, ')
          ..write('distanceFromPrevM: $distanceFromPrevM, ')
          ..write('cumulativeDistanceM: $cumulativeDistanceM, ')
          ..write('speedMs: $speedMs, ')
          ..write('bpm: $bpm')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $ActivitiesTable activities = $ActivitiesTable(this);
  late final $DataPointsTable dataPoints = $DataPointsTable(this);
  late final ActivitiesDao activitiesDao = ActivitiesDao(this as AppDatabase);
  late final DataPointsDao dataPointsDao = DataPointsDao(this as AppDatabase);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [activities, dataPoints];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules(
        [
          WritePropagation(
            on: TableUpdateQuery.onTableName('activities',
                limitUpdateKind: UpdateKind.delete),
            result: [
              TableUpdate('data_points', kind: UpdateKind.delete),
            ],
          ),
        ],
      );
}

typedef $$ActivitiesTableCreateCompanionBuilder = ActivitiesCompanion Function({
  Value<int> id,
  required DateTime startedAt,
  Value<DateTime?> endedAt,
  Value<String?> title,
  Value<String> status,
  Value<int?> stravaId,
  Value<double?> totalDistanceM,
  Value<int?> totalDurationS,
  Value<double?> avgBpm,
  Value<int?> maxBpm,
  Value<double?> avgPaceSPerKm,
  Value<double?> elevationGainM,
});
typedef $$ActivitiesTableUpdateCompanionBuilder = ActivitiesCompanion Function({
  Value<int> id,
  Value<DateTime> startedAt,
  Value<DateTime?> endedAt,
  Value<String?> title,
  Value<String> status,
  Value<int?> stravaId,
  Value<double?> totalDistanceM,
  Value<int?> totalDurationS,
  Value<double?> avgBpm,
  Value<int?> maxBpm,
  Value<double?> avgPaceSPerKm,
  Value<double?> elevationGainM,
});

final class $$ActivitiesTableReferences
    extends BaseReferences<_$AppDatabase, $ActivitiesTable, Activity> {
  $$ActivitiesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$DataPointsTable, List<DataPoint>>
      _dataPointsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
          db.dataPoints,
          aliasName:
              $_aliasNameGenerator(db.activities.id, db.dataPoints.activityId));

  $$DataPointsTableProcessedTableManager get dataPointsRefs {
    final manager = $$DataPointsTableTableManager($_db, $_db.dataPoints)
        .filter((f) => f.activityId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_dataPointsRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$ActivitiesTableFilterComposer
    extends Composer<_$AppDatabase, $ActivitiesTable> {
  $$ActivitiesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get startedAt => $composableBuilder(
      column: $table.startedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get endedAt => $composableBuilder(
      column: $table.endedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get stravaId => $composableBuilder(
      column: $table.stravaId, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get totalDistanceM => $composableBuilder(
      column: $table.totalDistanceM,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get totalDurationS => $composableBuilder(
      column: $table.totalDurationS,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get avgBpm => $composableBuilder(
      column: $table.avgBpm, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get maxBpm => $composableBuilder(
      column: $table.maxBpm, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get avgPaceSPerKm => $composableBuilder(
      column: $table.avgPaceSPerKm, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get elevationGainM => $composableBuilder(
      column: $table.elevationGainM,
      builder: (column) => ColumnFilters(column));

  Expression<bool> dataPointsRefs(
      Expression<bool> Function($$DataPointsTableFilterComposer f) f) {
    final $$DataPointsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.dataPoints,
        getReferencedColumn: (t) => t.activityId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$DataPointsTableFilterComposer(
              $db: $db,
              $table: $db.dataPoints,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$ActivitiesTableOrderingComposer
    extends Composer<_$AppDatabase, $ActivitiesTable> {
  $$ActivitiesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get startedAt => $composableBuilder(
      column: $table.startedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get endedAt => $composableBuilder(
      column: $table.endedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get stravaId => $composableBuilder(
      column: $table.stravaId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get totalDistanceM => $composableBuilder(
      column: $table.totalDistanceM,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get totalDurationS => $composableBuilder(
      column: $table.totalDurationS,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get avgBpm => $composableBuilder(
      column: $table.avgBpm, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get maxBpm => $composableBuilder(
      column: $table.maxBpm, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get avgPaceSPerKm => $composableBuilder(
      column: $table.avgPaceSPerKm,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get elevationGainM => $composableBuilder(
      column: $table.elevationGainM,
      builder: (column) => ColumnOrderings(column));
}

class $$ActivitiesTableAnnotationComposer
    extends Composer<_$AppDatabase, $ActivitiesTable> {
  $$ActivitiesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get startedAt =>
      $composableBuilder(column: $table.startedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get endedAt =>
      $composableBuilder(column: $table.endedAt, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<int> get stravaId =>
      $composableBuilder(column: $table.stravaId, builder: (column) => column);

  GeneratedColumn<double> get totalDistanceM => $composableBuilder(
      column: $table.totalDistanceM, builder: (column) => column);

  GeneratedColumn<int> get totalDurationS => $composableBuilder(
      column: $table.totalDurationS, builder: (column) => column);

  GeneratedColumn<double> get avgBpm =>
      $composableBuilder(column: $table.avgBpm, builder: (column) => column);

  GeneratedColumn<int> get maxBpm =>
      $composableBuilder(column: $table.maxBpm, builder: (column) => column);

  GeneratedColumn<double> get avgPaceSPerKm => $composableBuilder(
      column: $table.avgPaceSPerKm, builder: (column) => column);

  GeneratedColumn<double> get elevationGainM => $composableBuilder(
      column: $table.elevationGainM, builder: (column) => column);

  Expression<T> dataPointsRefs<T extends Object>(
      Expression<T> Function($$DataPointsTableAnnotationComposer a) f) {
    final $$DataPointsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.dataPoints,
        getReferencedColumn: (t) => t.activityId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$DataPointsTableAnnotationComposer(
              $db: $db,
              $table: $db.dataPoints,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$ActivitiesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $ActivitiesTable,
    Activity,
    $$ActivitiesTableFilterComposer,
    $$ActivitiesTableOrderingComposer,
    $$ActivitiesTableAnnotationComposer,
    $$ActivitiesTableCreateCompanionBuilder,
    $$ActivitiesTableUpdateCompanionBuilder,
    (Activity, $$ActivitiesTableReferences),
    Activity,
    PrefetchHooks Function({bool dataPointsRefs})> {
  $$ActivitiesTableTableManager(_$AppDatabase db, $ActivitiesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ActivitiesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ActivitiesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ActivitiesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<DateTime> startedAt = const Value.absent(),
            Value<DateTime?> endedAt = const Value.absent(),
            Value<String?> title = const Value.absent(),
            Value<String> status = const Value.absent(),
            Value<int?> stravaId = const Value.absent(),
            Value<double?> totalDistanceM = const Value.absent(),
            Value<int?> totalDurationS = const Value.absent(),
            Value<double?> avgBpm = const Value.absent(),
            Value<int?> maxBpm = const Value.absent(),
            Value<double?> avgPaceSPerKm = const Value.absent(),
            Value<double?> elevationGainM = const Value.absent(),
          }) =>
              ActivitiesCompanion(
            id: id,
            startedAt: startedAt,
            endedAt: endedAt,
            title: title,
            status: status,
            stravaId: stravaId,
            totalDistanceM: totalDistanceM,
            totalDurationS: totalDurationS,
            avgBpm: avgBpm,
            maxBpm: maxBpm,
            avgPaceSPerKm: avgPaceSPerKm,
            elevationGainM: elevationGainM,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required DateTime startedAt,
            Value<DateTime?> endedAt = const Value.absent(),
            Value<String?> title = const Value.absent(),
            Value<String> status = const Value.absent(),
            Value<int?> stravaId = const Value.absent(),
            Value<double?> totalDistanceM = const Value.absent(),
            Value<int?> totalDurationS = const Value.absent(),
            Value<double?> avgBpm = const Value.absent(),
            Value<int?> maxBpm = const Value.absent(),
            Value<double?> avgPaceSPerKm = const Value.absent(),
            Value<double?> elevationGainM = const Value.absent(),
          }) =>
              ActivitiesCompanion.insert(
            id: id,
            startedAt: startedAt,
            endedAt: endedAt,
            title: title,
            status: status,
            stravaId: stravaId,
            totalDistanceM: totalDistanceM,
            totalDurationS: totalDurationS,
            avgBpm: avgBpm,
            maxBpm: maxBpm,
            avgPaceSPerKm: avgPaceSPerKm,
            elevationGainM: elevationGainM,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$ActivitiesTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({dataPointsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (dataPointsRefs) db.dataPoints],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (dataPointsRefs)
                    await $_getPrefetchedData<Activity, $ActivitiesTable,
                            DataPoint>(
                        currentTable: table,
                        referencedTable: $$ActivitiesTableReferences
                            ._dataPointsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$ActivitiesTableReferences(db, table, p0)
                                .dataPointsRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.activityId == item.id),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$ActivitiesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $ActivitiesTable,
    Activity,
    $$ActivitiesTableFilterComposer,
    $$ActivitiesTableOrderingComposer,
    $$ActivitiesTableAnnotationComposer,
    $$ActivitiesTableCreateCompanionBuilder,
    $$ActivitiesTableUpdateCompanionBuilder,
    (Activity, $$ActivitiesTableReferences),
    Activity,
    PrefetchHooks Function({bool dataPointsRefs})>;
typedef $$DataPointsTableCreateCompanionBuilder = DataPointsCompanion Function({
  Value<int> id,
  required int activityId,
  required DateTime recordedAt,
  required double lat,
  required double lng,
  Value<double?> altitudeM,
  Value<double?> accuracyM,
  Value<double?> distanceFromPrevM,
  required double cumulativeDistanceM,
  Value<double?> speedMs,
  Value<int?> bpm,
});
typedef $$DataPointsTableUpdateCompanionBuilder = DataPointsCompanion Function({
  Value<int> id,
  Value<int> activityId,
  Value<DateTime> recordedAt,
  Value<double> lat,
  Value<double> lng,
  Value<double?> altitudeM,
  Value<double?> accuracyM,
  Value<double?> distanceFromPrevM,
  Value<double> cumulativeDistanceM,
  Value<double?> speedMs,
  Value<int?> bpm,
});

final class $$DataPointsTableReferences
    extends BaseReferences<_$AppDatabase, $DataPointsTable, DataPoint> {
  $$DataPointsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $ActivitiesTable _activityIdTable(_$AppDatabase db) =>
      db.activities.createAlias(
          $_aliasNameGenerator(db.dataPoints.activityId, db.activities.id));

  $$ActivitiesTableProcessedTableManager get activityId {
    final $_column = $_itemColumn<int>('activity_id')!;

    final manager = $$ActivitiesTableTableManager($_db, $_db.activities)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_activityIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$DataPointsTableFilterComposer
    extends Composer<_$AppDatabase, $DataPointsTable> {
  $$DataPointsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get recordedAt => $composableBuilder(
      column: $table.recordedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get lat => $composableBuilder(
      column: $table.lat, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get lng => $composableBuilder(
      column: $table.lng, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get altitudeM => $composableBuilder(
      column: $table.altitudeM, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get accuracyM => $composableBuilder(
      column: $table.accuracyM, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get distanceFromPrevM => $composableBuilder(
      column: $table.distanceFromPrevM,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get cumulativeDistanceM => $composableBuilder(
      column: $table.cumulativeDistanceM,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get speedMs => $composableBuilder(
      column: $table.speedMs, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get bpm => $composableBuilder(
      column: $table.bpm, builder: (column) => ColumnFilters(column));

  $$ActivitiesTableFilterComposer get activityId {
    final $$ActivitiesTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.activityId,
        referencedTable: $db.activities,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ActivitiesTableFilterComposer(
              $db: $db,
              $table: $db.activities,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$DataPointsTableOrderingComposer
    extends Composer<_$AppDatabase, $DataPointsTable> {
  $$DataPointsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get recordedAt => $composableBuilder(
      column: $table.recordedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get lat => $composableBuilder(
      column: $table.lat, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get lng => $composableBuilder(
      column: $table.lng, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get altitudeM => $composableBuilder(
      column: $table.altitudeM, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get accuracyM => $composableBuilder(
      column: $table.accuracyM, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get distanceFromPrevM => $composableBuilder(
      column: $table.distanceFromPrevM,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get cumulativeDistanceM => $composableBuilder(
      column: $table.cumulativeDistanceM,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get speedMs => $composableBuilder(
      column: $table.speedMs, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get bpm => $composableBuilder(
      column: $table.bpm, builder: (column) => ColumnOrderings(column));

  $$ActivitiesTableOrderingComposer get activityId {
    final $$ActivitiesTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.activityId,
        referencedTable: $db.activities,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ActivitiesTableOrderingComposer(
              $db: $db,
              $table: $db.activities,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$DataPointsTableAnnotationComposer
    extends Composer<_$AppDatabase, $DataPointsTable> {
  $$DataPointsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get recordedAt => $composableBuilder(
      column: $table.recordedAt, builder: (column) => column);

  GeneratedColumn<double> get lat =>
      $composableBuilder(column: $table.lat, builder: (column) => column);

  GeneratedColumn<double> get lng =>
      $composableBuilder(column: $table.lng, builder: (column) => column);

  GeneratedColumn<double> get altitudeM =>
      $composableBuilder(column: $table.altitudeM, builder: (column) => column);

  GeneratedColumn<double> get accuracyM =>
      $composableBuilder(column: $table.accuracyM, builder: (column) => column);

  GeneratedColumn<double> get distanceFromPrevM => $composableBuilder(
      column: $table.distanceFromPrevM, builder: (column) => column);

  GeneratedColumn<double> get cumulativeDistanceM => $composableBuilder(
      column: $table.cumulativeDistanceM, builder: (column) => column);

  GeneratedColumn<double> get speedMs =>
      $composableBuilder(column: $table.speedMs, builder: (column) => column);

  GeneratedColumn<int> get bpm =>
      $composableBuilder(column: $table.bpm, builder: (column) => column);

  $$ActivitiesTableAnnotationComposer get activityId {
    final $$ActivitiesTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.activityId,
        referencedTable: $db.activities,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ActivitiesTableAnnotationComposer(
              $db: $db,
              $table: $db.activities,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$DataPointsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $DataPointsTable,
    DataPoint,
    $$DataPointsTableFilterComposer,
    $$DataPointsTableOrderingComposer,
    $$DataPointsTableAnnotationComposer,
    $$DataPointsTableCreateCompanionBuilder,
    $$DataPointsTableUpdateCompanionBuilder,
    (DataPoint, $$DataPointsTableReferences),
    DataPoint,
    PrefetchHooks Function({bool activityId})> {
  $$DataPointsTableTableManager(_$AppDatabase db, $DataPointsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DataPointsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DataPointsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DataPointsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<int> activityId = const Value.absent(),
            Value<DateTime> recordedAt = const Value.absent(),
            Value<double> lat = const Value.absent(),
            Value<double> lng = const Value.absent(),
            Value<double?> altitudeM = const Value.absent(),
            Value<double?> accuracyM = const Value.absent(),
            Value<double?> distanceFromPrevM = const Value.absent(),
            Value<double> cumulativeDistanceM = const Value.absent(),
            Value<double?> speedMs = const Value.absent(),
            Value<int?> bpm = const Value.absent(),
          }) =>
              DataPointsCompanion(
            id: id,
            activityId: activityId,
            recordedAt: recordedAt,
            lat: lat,
            lng: lng,
            altitudeM: altitudeM,
            accuracyM: accuracyM,
            distanceFromPrevM: distanceFromPrevM,
            cumulativeDistanceM: cumulativeDistanceM,
            speedMs: speedMs,
            bpm: bpm,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required int activityId,
            required DateTime recordedAt,
            required double lat,
            required double lng,
            Value<double?> altitudeM = const Value.absent(),
            Value<double?> accuracyM = const Value.absent(),
            Value<double?> distanceFromPrevM = const Value.absent(),
            required double cumulativeDistanceM,
            Value<double?> speedMs = const Value.absent(),
            Value<int?> bpm = const Value.absent(),
          }) =>
              DataPointsCompanion.insert(
            id: id,
            activityId: activityId,
            recordedAt: recordedAt,
            lat: lat,
            lng: lng,
            altitudeM: altitudeM,
            accuracyM: accuracyM,
            distanceFromPrevM: distanceFromPrevM,
            cumulativeDistanceM: cumulativeDistanceM,
            speedMs: speedMs,
            bpm: bpm,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$DataPointsTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({activityId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (activityId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.activityId,
                    referencedTable:
                        $$DataPointsTableReferences._activityIdTable(db),
                    referencedColumn:
                        $$DataPointsTableReferences._activityIdTable(db).id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ));
}

typedef $$DataPointsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $DataPointsTable,
    DataPoint,
    $$DataPointsTableFilterComposer,
    $$DataPointsTableOrderingComposer,
    $$DataPointsTableAnnotationComposer,
    $$DataPointsTableCreateCompanionBuilder,
    $$DataPointsTableUpdateCompanionBuilder,
    (DataPoint, $$DataPointsTableReferences),
    DataPoint,
    PrefetchHooks Function({bool activityId})>;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$ActivitiesTableTableManager get activities =>
      $$ActivitiesTableTableManager(_db, _db.activities);
  $$DataPointsTableTableManager get dataPoints =>
      $$DataPointsTableTableManager(_db, _db.dataPoints);
}
