import 'package:first_klick/features/recording/recording_provider.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('RunStats', () {
    test('default constructor has sensible zero values', () {
      const s = RunStats();
      expect(s.elapsedS, 0);
      expect(s.distanceM, 0.0);
      expect(s.paceSPerKm, 0.0);
      expect(s.bpm, isNull);
      expect(s.lat, isNull);
      expect(s.lng, isNull);
      expect(s.activityId, isNull);
      expect(s.paused, isFalse);
      expect(s.isRecording, isFalse);
    });

    group('copyWith — non-nullable fields', () {
      test('updates elapsedS', () {
        const s = RunStats(elapsedS: 10);
        expect(s.copyWith(elapsedS: 20).elapsedS, 20);
      });

      test('keeps elapsedS when omitted', () {
        const s = RunStats(elapsedS: 10);
        expect(s.copyWith().elapsedS, 10);
      });

      test('updates distanceM', () {
        const s = RunStats(distanceM: 100);
        expect(s.copyWith(distanceM: 200).distanceM, 200.0);
      });

      test('updates paceSPerKm', () {
        const s = RunStats(paceSPerKm: 300);
        expect(s.copyWith(paceSPerKm: 360).paceSPerKm, 360.0);
      });

      test('updates isRecording', () {
        const s = RunStats();
        expect(s.copyWith(isRecording: true).isRecording, isTrue);
      });

      test('updates paused', () {
        const s = RunStats(isRecording: true);
        expect(s.copyWith(paused: true).paused, isTrue);
        expect(s.copyWith(paused: true).copyWith(paused: false).paused, isFalse);
      });
    });

    group('copyWith — nullable bpm field (_keep sentinel)', () {
      test('keeps existing bpm when omitted', () {
        const s = RunStats(bpm: 142);
        expect(s.copyWith().bpm, 142);
      });

      test('updates bpm to a new value', () {
        const s = RunStats(bpm: 142);
        expect(s.copyWith(bpm: 160).bpm, 160);
      });

      test('clears bpm when explicitly passed null', () {
        const s = RunStats(bpm: 142);
        expect(s.copyWith(bpm: null).bpm, isNull);
      });

      test('keeps null bpm when omitted', () {
        const s = RunStats();
        expect(s.copyWith().bpm, isNull);
      });
    });

    group('copyWith — nullable lat field (_keep sentinel)', () {
      test('keeps existing lat when omitted', () {
        const s = RunStats(lat: 48.85);
        expect(s.copyWith().lat, 48.85);
      });

      test('updates lat to a new value', () {
        const s = RunStats(lat: 48.85);
        expect(s.copyWith(lat: 51.50).lat, 51.50);
      });

      test('clears lat when explicitly passed null', () {
        const s = RunStats(lat: 48.85);
        expect(s.copyWith(lat: null).lat, isNull);
      });
    });

    group('copyWith — nullable lng field (_keep sentinel)', () {
      test('keeps existing lng when omitted', () {
        const s = RunStats(lng: 2.35);
        expect(s.copyWith().lng, 2.35);
      });

      test('clears lng when explicitly passed null', () {
        const s = RunStats(lng: 2.35);
        expect(s.copyWith(lng: null).lng, isNull);
      });
    });

    test('copyWith preserves all other fields when updating one', () {
      const s = RunStats(
        elapsedS: 60,
        distanceM: 300,
        paceSPerKm: 350,
        bpm: 150,
        lat: 1.0,
        lng: 2.0,
        activityId: 7,
        paused: false,
        isRecording: true,
      );
      final updated = s.copyWith(elapsedS: 120);

      expect(updated.elapsedS, 120);
      expect(updated.distanceM, 300);
      expect(updated.paceSPerKm, 350);
      expect(updated.bpm, 150);
      expect(updated.lat, 1.0);
      expect(updated.lng, 2.0);
      expect(updated.activityId, 7);
      expect(updated.paused, isFalse);
      expect(updated.isRecording, isTrue);
    });
  });
}
