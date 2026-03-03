import 'package:geolocator/geolocator.dart';

import '../../shared/logging_service.dart';

class GpsService {
  static const LocationSettings _settings = LocationSettings(
    accuracy: LocationAccuracy.high,
    distanceFilter: 0,
    // Platform-specific interval handled via AndroidSettings / AppleSettings
    // when called from background; here we use the defaults for foreground use.
  );

  /// Request the required permissions. Returns true if granted.
  static Future<bool> requestPermission() async {
    try {
      LoggingService.debug('Requesting GPS permission...');
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      final granted = permission == LocationPermission.always ||
          permission == LocationPermission.whileInUse;
      LoggingService.info('GPS permission ${granted ? 'granted' : 'denied'}');
      return granted;
    } catch (e, stackTrace) {
      LoggingService.error('Error requesting GPS permission', e, stackTrace);
      return false;
    }
  }

  /// Single current position — used to initialise the map.
  static Future<Position?> currentPosition() async {
    try {
      LoggingService.debug('Getting current GPS position...');
      final position = await Geolocator.getCurrentPosition(
        locationSettings: _settings,
      );
      LoggingService.debug(
          'Current position: ${position.latitude}, ${position.longitude}');
      return position;
    } catch (e, stackTrace) {
      LoggingService.error('Error getting current GPS position', e, stackTrace);
      return null;
    }
  }

  /// Continuous stream of positions at high accuracy.
  static Stream<Position> positionStream() {
    try {
      LoggingService.info('Starting GPS position stream');
      return Geolocator.getPositionStream(locationSettings: _settings);
    } catch (e, stackTrace) {
      LoggingService.error('Error starting GPS position stream', e, stackTrace);
      // Return empty stream if failed to start
      return Stream.empty();
    }
  }

  /// Android-specific settings for background use (called from service).
  static AndroidSettings get androidBackgroundSettings => AndroidSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 0,
        intervalDuration: const Duration(seconds: 3),
        foregroundNotificationConfig: ForegroundNotificationConfig(
          notificationTitle: 'First Klick',
          notificationText: 'Recording your run…',
          enableWakeLock: true,
        ),
      );

  static AppleSettings get appleBackgroundSettings => AppleSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 0,
        activityType: ActivityType.fitness,
        pauseLocationUpdatesAutomatically: false,
        showBackgroundLocationIndicator: true,
      );
}
