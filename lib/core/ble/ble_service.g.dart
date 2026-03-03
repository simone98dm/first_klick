// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ble_service.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$currentBpmHash() => r'bc12f01d3099fdc1da35985719a620c3df8b5a13';

/// Thin provider that exposes just the current BPM value.
///
/// Copied from [currentBpm].
@ProviderFor(currentBpm)
final currentBpmProvider = AutoDisposeProvider<int?>.internal(
  currentBpm,
  name: r'currentBpmProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$currentBpmHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef CurrentBpmRef = AutoDisposeProviderRef<int?>;
String _$bleNotifierHash() => r'5cb0793764118888782c8f55906065767b5b8cc4';

/// See also [BleNotifier].
@ProviderFor(BleNotifier)
final bleNotifierProvider =
    AutoDisposeNotifierProvider<BleNotifier, BleState>.internal(
  BleNotifier.new,
  name: r'bleNotifierProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$bleNotifierHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$BleNotifier = AutoDisposeNotifier<BleState>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
