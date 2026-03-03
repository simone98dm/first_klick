// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'home_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$appDatabaseHash() => r'4db1c5efe1a73afafa926c6e91d12e49a68b1abc';

/// Provides the singleton AppDatabase instance.
///
/// Copied from [appDatabase].
@ProviderFor(appDatabase)
final appDatabaseProvider = AutoDisposeProvider<AppDatabase>.internal(
  appDatabase,
  name: r'appDatabaseProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$appDatabaseHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef AppDatabaseRef = AutoDisposeProviderRef<AppDatabase>;
String _$activitiesListHash() => r'5327ece3815c22c29ac28c7a6d1a55adfee25344';

/// Watches all completed/uploaded activities ordered newest-first.
///
/// Copied from [activitiesList].
@ProviderFor(activitiesList)
final activitiesListProvider =
    AutoDisposeStreamProvider<List<Activity>>.internal(
  activitiesList,
  name: r'activitiesListProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$activitiesListHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef ActivitiesListRef = AutoDisposeStreamProviderRef<List<Activity>>;
String _$currentGpsPositionHash() =>
    r'c4558c4e41776f92d9053ac4161235a17e1f291c';

/// Streams the current GPS position, starting with null until the first fix.
/// Used to gate the Start Run button — it stays disabled until the device
/// has a valid location so the activity starting point is never lost.
///
/// Copied from [currentGpsPosition].
@ProviderFor(currentGpsPosition)
final currentGpsPositionProvider =
    AutoDisposeStreamProvider<Position?>.internal(
  currentGpsPosition,
  name: r'currentGpsPositionProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$currentGpsPositionHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef CurrentGpsPositionRef = AutoDisposeStreamProviderRef<Position?>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
