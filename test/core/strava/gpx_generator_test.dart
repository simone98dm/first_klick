import 'package:first_klick/core/database/app_database.dart';
import 'package:first_klick/core/strava/gpx_generator.dart';
import 'package:flutter_test/flutter_test.dart';

// Helper to build a minimal DataPoint for tests.
DataPoint _point({
  int id = 1,
  int activityId = 1,
  DateTime? recordedAt,
  double lat = 48.8566,
  double lng = 2.3522,
  double? altitudeM,
  int? bpm,
}) =>
    DataPoint(
      id: id,
      activityId: activityId,
      recordedAt: recordedAt ?? DateTime.utc(2026, 2, 21, 9, 0, 0),
      lat: lat,
      lng: lng,
      altitudeM: altitudeM,
      accuracyM: null,
      distanceFromPrevM: null,
      cumulativeDistanceM: 0,
      speedMs: null,
      bpm: bpm,
    );

void main() {
  group('generateGpx', () {
    test('produces valid GPX 1.1 XML declaration and root element', () {
      final gpx = generateGpx(activityName: 'Test Run', points: []);

      expect(gpx, contains('<?xml version="1.0" encoding="UTF-8"?>'));
      expect(gpx, contains('gpx version="1.1"'));
      expect(gpx, contains('xmlns="http://www.topografix.com/GPX/1/1"'));
    });

    test('includes activity name in <name> element', () {
      final gpx = generateGpx(activityName: 'My Run', points: []);
      expect(gpx, contains('<name>My Run</name>'));
    });

    test('sets track type to running', () {
      final gpx = generateGpx(activityName: 'Run', points: []);
      expect(gpx, contains('<type>running</type>'));
    });

    test('empty points produces empty <trkseg>', () {
      final gpx = generateGpx(activityName: 'Run', points: []);
      expect(gpx, contains('<trkseg>'));
      expect(gpx, contains('</trkseg>'));
      expect(gpx, isNot(contains('<trkpt')));
    });

    test('single point appears with correct lat/lon attributes', () {
      final gpx = generateGpx(
        activityName: 'Run',
        points: [_point(lat: 48.8566000, lng: 2.3522000)],
      );

      expect(gpx, contains('lat="48.8566000"'));
      expect(gpx, contains('lon="2.3522000"'));
    });

    test('point with altitude includes <ele> element', () {
      final gpx = generateGpx(
        activityName: 'Run',
        points: [_point(altitudeM: 325.75)],
      );
      expect(gpx, contains('<ele>325.75</ele>'));
    });

    test('point without altitude omits <ele> element', () {
      final gpx = generateGpx(
        activityName: 'Run',
        points: [_point()],
      );
      expect(gpx, isNot(contains('<ele>')));
    });

    test('timestamp is formatted in UTC ISO 8601', () {
      final gpx = generateGpx(
        activityName: 'Run',
        points: [
          _point(recordedAt: DateTime.utc(2026, 2, 21, 9, 15, 30)),
        ],
      );
      expect(gpx, contains('<time>2026-02-21T09:15:30Z</time>'));
    });

    test('multiple points all appear in output', () {
      final gpx = generateGpx(
        activityName: 'Run',
        points: [
          _point(id: 1, lat: 10.0, lng: 20.0),
          _point(id: 2, lat: 10.001, lng: 20.001),
          _point(id: 3, lat: 10.002, lng: 20.002),
        ],
      );
      expect(RegExp(r'<trkpt').allMatches(gpx).length, 3);
    });

    group('XML escaping in activity name', () {
      test('escapes ampersand', () {
        final gpx = generateGpx(activityName: 'Rock & Roll', points: []);
        expect(gpx, contains('<name>Rock &amp; Roll</name>'));
      });

      test('escapes less-than', () {
        final gpx = generateGpx(activityName: 'Run<10km', points: []);
        expect(gpx, contains('<name>Run&lt;10km</name>'));
      });

      test('escapes greater-than', () {
        final gpx = generateGpx(activityName: 'Run>5km', points: []);
        expect(gpx, contains('<name>Run&gt;5km</name>'));
      });

      test('escapes double quote', () {
        final gpx = generateGpx(activityName: 'The "Run"', points: []);
        expect(gpx, contains('<name>The &quot;Run&quot;</name>'));
      });

      test("escapes single quote", () {
        final gpx = generateGpx(activityName: "Runner's High", points: []);
        expect(gpx, contains('<name>Runner&apos;s High</name>'));
      });
    });
  });
}
