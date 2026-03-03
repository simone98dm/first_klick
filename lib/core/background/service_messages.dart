/// Keys used in the IPC messages between the background service and the UI.
class ServiceMsg {
  ServiceMsg._();

  // UI → Service
  static const String start = 'start';
  static const String stop = 'stop';
  static const String pause = 'pause';
  static const String resume = 'resume';
  static const String setActivityId = 'set_activity_id';
  static const String setBleDevice = 'set_ble_device';

  // Service → UI  (broadcast every second)
  static const String stats = 'stats';
  static const String stopped = 'stopped';

  // Stats payload keys
  static const String keyElapsedS = 'elapsed_s';
  static const String keyDistanceM = 'distance_m';
  static const String keyPaceSPerKm = 'pace_s_per_km';
  static const String keyBpm = 'bpm';
  static const String keyLat = 'lat';
  static const String keyLng = 'lng';
  static const String keyActivityId = 'activity_id';
  static const String keyPaused = 'paused';
  // True when the run was paused automatically due to low speed.
  static const String keyAutoPaused = 'auto_paused';
}
