import '../database/app_database.dart';

/// Generates a minimal but valid GPX 1.1 string from a list of data points.
String generateGpx({
  required String activityName,
  required List<DataPoint> points,
}) {
  final buf = StringBuffer();

  buf.writeln('<?xml version="1.0" encoding="UTF-8"?>');
  buf.writeln(
    '<gpx version="1.1" creator="First Klick" '
    'xmlns="http://www.topografix.com/GPX/1/1" '
    'xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" '
    'xsi:schemaLocation="http://www.topografix.com/GPX/1/1 '
    'http://www.topografix.com/GPX/1/1/gpx.xsd">',
  );
  buf.writeln('  <trk>');
  buf.writeln('    <name>${_escapeXml(activityName)}</name>');
  buf.writeln('    <type>running</type>');
  buf.writeln('    <trkseg>');

  for (final p in points) {
    buf.write(
        '      <trkpt lat="${p.lat.toStringAsFixed(7)}" lon="${p.lng.toStringAsFixed(7)}">');
    if (p.altitudeM != null) {
      buf.write('<ele>${p.altitudeM!.toStringAsFixed(2)}</ele>');
    }
    buf.write('<time>${_utcIso(p.recordedAt)}</time>');
    buf.writeln('</trkpt>');
  }

  buf.writeln('    </trkseg>');
  buf.writeln('  </trk>');
  buf.writeln('</gpx>');
  return buf.toString();
}

/// Formats a DateTime as UTC ISO 8601 without milliseconds, e.g. 2026-02-21T09:15:30Z
String _utcIso(DateTime dt) =>
    '${dt.toUtc().toIso8601String().split('.').first}Z';

String _escapeXml(String s) => s
    .replaceAll('&', '&amp;')
    .replaceAll('<', '&lt;')
    .replaceAll('>', '&gt;')
    .replaceAll('"', '&quot;')
    .replaceAll("'", '&apos;');
