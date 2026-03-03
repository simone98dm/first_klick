import 'dart:math';

/// Returns the great-circle distance in metres between two GPS coordinates.
double haversineDistance({
  required double lat1,
  required double lon1,
  required double lat2,
  required double lon2,
}) {
  const double earthRadius = 6371000; // metres
  final double dLat = _toRad(lat2 - lat1);
  final double dLon = _toRad(lon2 - lon1);
  final double a = sin(dLat / 2) * sin(dLat / 2) +
      cos(_toRad(lat1)) * cos(_toRad(lat2)) * sin(dLon / 2) * sin(dLon / 2);
  final double c = 2 * atan2(sqrt(a), sqrt(1 - a));
  return earthRadius * c;
}

double _toRad(double deg) => deg * pi / 180;
