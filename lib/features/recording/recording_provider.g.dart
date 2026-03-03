// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'recording_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$savedBleDeviceIdHash() => r'6c9befe2df30569399b6d671da991dc254e03194';

/// See also [savedBleDeviceId].
@ProviderFor(savedBleDeviceId)
final savedBleDeviceIdProvider = AutoDisposeFutureProvider<String?>.internal(
  savedBleDeviceId,
  name: r'savedBleDeviceIdProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$savedBleDeviceIdHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef SavedBleDeviceIdRef = AutoDisposeFutureProviderRef<String?>;
String _$recordingNotifierHash() => r'ffdd5a69d3dff37b3ad05208593c33a742c31ef1';

/// See also [RecordingNotifier].
@ProviderFor(RecordingNotifier)
final recordingNotifierProvider =
    AutoDisposeNotifierProvider<RecordingNotifier, RunStats>.internal(
  RecordingNotifier.new,
  name: r'recordingNotifierProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$recordingNotifierHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$RecordingNotifier = AutoDisposeNotifier<RunStats>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
