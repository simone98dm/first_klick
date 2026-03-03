import 'package:first_klick/core/gps/haversine.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('haversineDistance', () {
    test('returns 0 for the same point', () {
      final d = haversineDistance(
        lat1: 51.5074, lon1: -0.1278,
        lat2: 51.5074, lon2: -0.1278,
      );
      expect(d, 0.0);
    });

    test('London to Paris is approximately 343 km', () {
      final d = haversineDistance(
        lat1: 51.5074, lon1: -0.1278, // London
        lat2: 48.8566, lon2: 2.3522,  // Paris
      );
      // Accepted real-world value: 343 km ± 2 km
      expect(d, closeTo(343000, 2000));
    });

    test('1 degree of latitude is approximately 111.19 km', () {
      final d = haversineDistance(
        lat1: 0.0, lon1: 0.0,
        lat2: 1.0, lon2: 0.0,
      );
      expect(d, closeTo(111195, 10));
    });

    test('1 degree of longitude at equator equals 1 degree of latitude (~111.19 km)', () {
      // Haversine uses a perfect sphere, so 1° lon at equator == 1° lat
      final d = haversineDistance(
        lat1: 0.0, lon1: 0.0,
        lat2: 0.0, lon2: 1.0,
      );
      expect(d, closeTo(111195, 10));
    });

    test('short distance of ~10 m is within 1 m accuracy', () {
      // Move ~9 m north from origin (0.0001 degrees ≈ 11 m)
      final d = haversineDistance(
        lat1: 48.0, lon1: 11.0,
        lat2: 48.0001, lon2: 11.0,
      );
      expect(d, closeTo(11.1, 0.5));
    });

    test('is symmetric (swapping points gives the same distance)', () {
      final d1 = haversineDistance(
        lat1: 40.7128, lon1: -74.0060,
        lat2: 34.0522, lon2: -118.2437,
      );
      final d2 = haversineDistance(
        lat1: 34.0522, lon1: -118.2437,
        lat2: 40.7128, lon2: -74.0060,
      );
      expect(d1, closeTo(d2, 0.001));
    });
  });
}
