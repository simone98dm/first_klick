// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'activity_detail_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$activityDetailHash() => r'2c169ce64336a9ea9da20bfcbe6616b56c515d7f';

/// Copied from Dart SDK
class _SystemHash {
  _SystemHash._();

  static int combine(int hash, int value) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + value);
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    return hash ^ (hash >> 6);
  }

  static int finish(int hash) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    // ignore: parameter_assignments
    hash = hash ^ (hash >> 11);
    return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
  }
}

/// See also [activityDetail].
@ProviderFor(activityDetail)
const activityDetailProvider = ActivityDetailFamily();

/// See also [activityDetail].
class ActivityDetailFamily extends Family<AsyncValue<Activity?>> {
  /// See also [activityDetail].
  const ActivityDetailFamily();

  /// See also [activityDetail].
  ActivityDetailProvider call(
    int activityId,
  ) {
    return ActivityDetailProvider(
      activityId,
    );
  }

  @override
  ActivityDetailProvider getProviderOverride(
    covariant ActivityDetailProvider provider,
  ) {
    return call(
      provider.activityId,
    );
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'activityDetailProvider';
}

/// See also [activityDetail].
class ActivityDetailProvider extends AutoDisposeFutureProvider<Activity?> {
  /// See also [activityDetail].
  ActivityDetailProvider(
    int activityId,
  ) : this._internal(
          (ref) => activityDetail(
            ref as ActivityDetailRef,
            activityId,
          ),
          from: activityDetailProvider,
          name: r'activityDetailProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$activityDetailHash,
          dependencies: ActivityDetailFamily._dependencies,
          allTransitiveDependencies:
              ActivityDetailFamily._allTransitiveDependencies,
          activityId: activityId,
        );

  ActivityDetailProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.activityId,
  }) : super.internal();

  final int activityId;

  @override
  Override overrideWith(
    FutureOr<Activity?> Function(ActivityDetailRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: ActivityDetailProvider._internal(
        (ref) => create(ref as ActivityDetailRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        activityId: activityId,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<Activity?> createElement() {
    return _ActivityDetailProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is ActivityDetailProvider && other.activityId == activityId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, activityId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin ActivityDetailRef on AutoDisposeFutureProviderRef<Activity?> {
  /// The parameter `activityId` of this provider.
  int get activityId;
}

class _ActivityDetailProviderElement
    extends AutoDisposeFutureProviderElement<Activity?> with ActivityDetailRef {
  _ActivityDetailProviderElement(super.provider);

  @override
  int get activityId => (origin as ActivityDetailProvider).activityId;
}

String _$activityPointsHash() => r'40271e4cd82b1833c564dd9ad3d93a5db3a704a4';

/// See also [activityPoints].
@ProviderFor(activityPoints)
const activityPointsProvider = ActivityPointsFamily();

/// See also [activityPoints].
class ActivityPointsFamily extends Family<AsyncValue<List<DataPoint>>> {
  /// See also [activityPoints].
  const ActivityPointsFamily();

  /// See also [activityPoints].
  ActivityPointsProvider call(
    int activityId,
  ) {
    return ActivityPointsProvider(
      activityId,
    );
  }

  @override
  ActivityPointsProvider getProviderOverride(
    covariant ActivityPointsProvider provider,
  ) {
    return call(
      provider.activityId,
    );
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'activityPointsProvider';
}

/// See also [activityPoints].
class ActivityPointsProvider
    extends AutoDisposeFutureProvider<List<DataPoint>> {
  /// See also [activityPoints].
  ActivityPointsProvider(
    int activityId,
  ) : this._internal(
          (ref) => activityPoints(
            ref as ActivityPointsRef,
            activityId,
          ),
          from: activityPointsProvider,
          name: r'activityPointsProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$activityPointsHash,
          dependencies: ActivityPointsFamily._dependencies,
          allTransitiveDependencies:
              ActivityPointsFamily._allTransitiveDependencies,
          activityId: activityId,
        );

  ActivityPointsProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.activityId,
  }) : super.internal();

  final int activityId;

  @override
  Override overrideWith(
    FutureOr<List<DataPoint>> Function(ActivityPointsRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: ActivityPointsProvider._internal(
        (ref) => create(ref as ActivityPointsRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        activityId: activityId,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<List<DataPoint>> createElement() {
    return _ActivityPointsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is ActivityPointsProvider && other.activityId == activityId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, activityId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin ActivityPointsRef on AutoDisposeFutureProviderRef<List<DataPoint>> {
  /// The parameter `activityId` of this provider.
  int get activityId;
}

class _ActivityPointsProviderElement
    extends AutoDisposeFutureProviderElement<List<DataPoint>>
    with ActivityPointsRef {
  _ActivityPointsProviderElement(super.provider);

  @override
  int get activityId => (origin as ActivityPointsProvider).activityId;
}

String _$stravaStatusHash() => r'3a819c096321931740f8c6f7a3817cf0d1eccb42';

/// Checks whether the Strava activity with [stravaId] still exists online.
///
/// Copied from [stravaStatus].
@ProviderFor(stravaStatus)
const stravaStatusProvider = StravaStatusFamily();

/// Checks whether the Strava activity with [stravaId] still exists online.
///
/// Copied from [stravaStatus].
class StravaStatusFamily extends Family<AsyncValue<StravaStatus>> {
  /// Checks whether the Strava activity with [stravaId] still exists online.
  ///
  /// Copied from [stravaStatus].
  const StravaStatusFamily();

  /// Checks whether the Strava activity with [stravaId] still exists online.
  ///
  /// Copied from [stravaStatus].
  StravaStatusProvider call(
    int stravaId,
  ) {
    return StravaStatusProvider(
      stravaId,
    );
  }

  @override
  StravaStatusProvider getProviderOverride(
    covariant StravaStatusProvider provider,
  ) {
    return call(
      provider.stravaId,
    );
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'stravaStatusProvider';
}

/// Checks whether the Strava activity with [stravaId] still exists online.
///
/// Copied from [stravaStatus].
class StravaStatusProvider extends AutoDisposeFutureProvider<StravaStatus> {
  /// Checks whether the Strava activity with [stravaId] still exists online.
  ///
  /// Copied from [stravaStatus].
  StravaStatusProvider(
    int stravaId,
  ) : this._internal(
          (ref) => stravaStatus(
            ref as StravaStatusRef,
            stravaId,
          ),
          from: stravaStatusProvider,
          name: r'stravaStatusProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$stravaStatusHash,
          dependencies: StravaStatusFamily._dependencies,
          allTransitiveDependencies:
              StravaStatusFamily._allTransitiveDependencies,
          stravaId: stravaId,
        );

  StravaStatusProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.stravaId,
  }) : super.internal();

  final int stravaId;

  @override
  Override overrideWith(
    FutureOr<StravaStatus> Function(StravaStatusRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: StravaStatusProvider._internal(
        (ref) => create(ref as StravaStatusRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        stravaId: stravaId,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<StravaStatus> createElement() {
    return _StravaStatusProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is StravaStatusProvider && other.stravaId == stravaId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, stravaId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin StravaStatusRef on AutoDisposeFutureProviderRef<StravaStatus> {
  /// The parameter `stravaId` of this provider.
  int get stravaId;
}

class _StravaStatusProviderElement
    extends AutoDisposeFutureProviderElement<StravaStatus>
    with StravaStatusRef {
  _StravaStatusProviderElement(super.provider);

  @override
  int get stravaId => (origin as StravaStatusProvider).stravaId;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
