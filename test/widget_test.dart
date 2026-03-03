import 'package:first_klick/core/database/app_database.dart';
import 'package:first_klick/features/home/home_provider.dart';
import 'package:first_klick/features/home/home_screen.dart';
import 'package:first_klick/features/recording/recording_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geolocator/geolocator.dart';

// ── Fake notifier — no platform-channel calls ─────────────────────────────

class _FakeRecordingNotifier extends RecordingNotifier {
  final RunStats _initial;
  _FakeRecordingNotifier([this._initial = const RunStats()]);

  @override
  RunStats build() => _initial; // skip _listenToService()
}

// ── Helpers ───────────────────────────────────────────────────────────────

Activity _activity({
  int id = 1,
  String title = 'Morning Run',
  String status = 'done',
  double distanceM = 5123,
  int durationS = 1800,
  double paceSPerKm = 352,
}) =>
    Activity(
      id: id,
      startedAt: DateTime(2026, 2, 21, 8, 0),
      title: title,
      status: status,
      totalDistanceM: distanceM,
      totalDurationS: durationS,
      avgPaceSPerKm: paceSPerKm,
    );

Position _fakePosition() => Position(
      latitude: 51.5,
      longitude: -0.1,
      timestamp: DateTime(2026, 2, 21),
      accuracy: 5.0,
      altitude: 0.0,
      altitudeAccuracy: 0.0,
      heading: 0.0,
      headingAccuracy: 0.0,
      speed: 0.0,
      speedAccuracy: 0.0,
    );

Widget _buildHome({
  List<Activity> activities = const [],
  RunStats stats = const RunStats(),
  bool gpsReady = false,
}) {
  return ProviderScope(
    overrides: [
      activitiesListProvider.overrideWith((_) => Stream.value(activities)),
      recordingNotifierProvider
          .overrideWith(() => _FakeRecordingNotifier(stats)),
      // Provide a controllable GPS stream so tests don't depend on the real
      // platform channel. Pass gpsReady: true to simulate a GPS fix.
      currentGpsPositionProvider.overrideWith(
        (_) => gpsReady
            ? Stream.value(_fakePosition())
            : Stream.value(null),
      ),
    ],
    child: const MaterialApp(home: HomeScreen()),
  );
}

// ── Tests ─────────────────────────────────────────────────────────────────

void main() {
  group('HomeScreen', () {
    testWidgets('shows empty state when there are no activities',
        (tester) async {
      await tester.pumpWidget(_buildHome());
      await tester.pump(); // let the stream emit

      expect(find.text('No runs yet'), findsOneWidget);
      expect(find.text('Tap the button below to start recording'),
          findsOneWidget);
    });

    testWidgets('FAB is visible when not recording', (tester) async {
      await tester.pumpWidget(_buildHome(gpsReady: true));
      await tester.pump();

      expect(find.byType(FloatingActionButton), findsOneWidget);
      expect(find.text('Start Run'), findsOneWidget);
    });

    testWidgets('FAB shows acquiring state when GPS not ready', (tester) async {
      await tester.pumpWidget(_buildHome());
      await tester.pump();

      expect(find.byType(FloatingActionButton), findsOneWidget);
      expect(find.text('Acquiring GPS…'), findsOneWidget);
    });

    testWidgets('FAB is hidden while recording', (tester) async {
      await tester.pumpWidget(
        _buildHome(stats: const RunStats(isRecording: true, elapsedS: 10)),
      );
      await tester.pump();

      expect(find.byType(FloatingActionButton), findsNothing);
    });

    testWidgets('live banner is shown when recording', (tester) async {
      await tester.pumpWidget(
        _buildHome(
          stats: const RunStats(
            isRecording: true,
            elapsedS: 125,
            distanceM: 500,
            paceSPerKm: 360,
            bpm: 142,
          ),
        ),
      );
      await tester.pump();

      expect(find.text('RECORDING'), findsOneWidget);
      expect(find.text('02:05'), findsOneWidget); // elapsed 125 s → 02:05
      expect(find.text('PACE'), findsOneWidget);
      expect(find.text('DISTANCE'), findsOneWidget);
      expect(find.text('BPM'), findsOneWidget);
      expect(find.text('142'), findsOneWidget);
    });

    testWidgets('live banner shows No GPS badge when lat/lng are null',
        (tester) async {
      await tester.pumpWidget(
        _buildHome(
          stats: const RunStats(isRecording: true),
        ),
      );
      await tester.pump();

      expect(find.text('No GPS'), findsOneWidget);
    });

    testWidgets('live banner shows GPS badge when position is available',
        (tester) async {
      await tester.pumpWidget(
        _buildHome(
          stats: const RunStats(
            isRecording: true,
            lat: 48.8566,
            lng: 2.3522,
          ),
        ),
      );
      await tester.pump();

      expect(find.text('GPS'), findsOneWidget);
    });

    testWidgets('activity list renders cards', (tester) async {
      await tester.pumpWidget(
        _buildHome(activities: [_activity(), _activity(id: 2, title: 'Run 2')]),
      );
      await tester.pump();

      expect(find.text('Morning Run'), findsOneWidget);
      expect(find.text('Run 2'), findsOneWidget);
    });
  });
}
