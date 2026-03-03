import 'dart:io';
import 'dart:ui' as ui;

import 'package:dio/dio.dart';
import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../core/database/app_database.dart';
import '../../core/strava/gpx_generator.dart';
import '../../core/strava/strava_api.dart';
import '../../core/strava/token_storage.dart';
import '../../shared/theme/app_colors.dart';
import '../../shared/theme/app_text_styles.dart';
import '../home/home_provider.dart';
import 'activity_detail_provider.dart';

// ── Strava brand colour ────────────────────────────────────────────────────
const _kStrava = Color(0xFFFC4C02);

class ActivityDetailScreen extends ConsumerStatefulWidget {
  const ActivityDetailScreen({super.key, required this.activityId});

  final int activityId;

  @override
  ConsumerState<ActivityDetailScreen> createState() =>
      _ActivityDetailScreenState();
}

class _ActivityDetailScreenState extends ConsumerState<ActivityDetailScreen> {
  void _onSharePressed() {
    final activity =
        ref.read(activityDetailProvider(widget.activityId)).valueOrNull;
    final points =
        ref.read(activityPointsProvider(widget.activityId)).valueOrNull;
    if (activity == null || points == null) return;

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: kSurface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _ShareSheet(activity: activity, points: points),
    );
  }

  @override
  Widget build(BuildContext context) {
    final actAsync = ref.watch(activityDetailProvider(widget.activityId));
    final canShare = actAsync.valueOrNull != null &&
        ref
                .watch(activityPointsProvider(widget.activityId))
                .valueOrNull !=
            null;

    return Scaffold(
      appBar: AppBar(
        title: actAsync.maybeWhen(
          data: (a) => Text(a?.title ?? 'Run'),
          orElse: () => const Text('Activity'),
        ),
        actions: [
          if (canShare)
            IconButton(
              icon: const Icon(Icons.ios_share_rounded),
              tooltip: 'Share',
              onPressed: _onSharePressed,
            ),
          actAsync.maybeWhen(
            data: (activity) => activity != null
                ? _DeleteButton(activity: activity)
                : const SizedBox.shrink(),
            orElse: () => const SizedBox.shrink(),
          ),
        ],
      ),
      body: actAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (activity) {
          if (activity == null) {
            return const Center(child: Text('Not found'));
          }
          final pointsAsync =
              ref.watch(activityPointsProvider(widget.activityId));
          return pointsAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(child: Text('Error: $e')),
            data: (points) => _DetailBody(
              activity: activity,
              points: points,
              ref: ref,
            ),
          );
        },
      ),
    );
  }
}

// ── Delete button (AppBar action) ──────────────────────────────────────────

class _DeleteButton extends ConsumerStatefulWidget {
  const _DeleteButton({required this.activity});

  final Activity activity;

  @override
  ConsumerState<_DeleteButton> createState() => _DeleteButtonState();
}

class _DeleteButtonState extends ConsumerState<_DeleteButton> {
  bool _deleting = false;

  Future<void> _onDelete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete activity?'),
        content: Text(
          widget.activity.stravaId != null
              ? 'This will permanently remove the activity from this device and from Strava.'
              : 'This will permanently remove the activity from this device.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: kError),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    setState(() => _deleting = true);
    try {
      // Delete from Strava (best-effort — ignore 404 if already gone)
      final stravaId = widget.activity.stravaId;
      if (stravaId != null && await TokenStorage.isConnected()) {
        try {
          await StravaApi.deleteActivity(stravaId);
        } on DioException catch (e) {
          if (e.response?.statusCode != 404) rethrow;
        }
      }

      // Delete locally — data points cascade via FK
      await ref
          .read(appDatabaseProvider)
          .activitiesDao
          .deleteById(widget.activity.id);

      if (mounted) context.go('/');
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Delete failed: $e')));
      }
    } finally {
      if (mounted) setState(() => _deleting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_deleting) {
      return const Padding(
        padding: EdgeInsets.all(14),
        child: SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      );
    }
    return IconButton(
      icon: const Icon(Icons.delete_outline),
      tooltip: 'Delete activity',
      color: kError,
      onPressed: _onDelete,
    );
  }
}

// ── Body ───────────────────────────────────────────────────────────────────

class _DetailBody extends StatelessWidget {
  const _DetailBody({
    required this.activity,
    required this.points,
    required this.ref,
  });

  final Activity activity;
  final List<DataPoint> points;
  final WidgetRef ref;

  @override
  Widget build(BuildContext context) {
    final polyline = points.map((p) => LatLng(p.lat, p.lng)).toList();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // ── Map ────────────────────────────────────────────────────────
        ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: SizedBox(height: 240, child: _RouteMap(polyline: polyline)),
        ),
        const SizedBox(height: 16),

        // ── Strava status card (only when synced) ──────────────────────
        if (activity.stravaId != null) ...[
          _StravaStatusCard(stravaId: activity.stravaId!),
          const SizedBox(height: 16),
        ],

        // ── Summary stats ──────────────────────────────────────────────
        _SummaryCard(activity: activity),
        const SizedBox(height: 16),

        // ── Splits ────────────────────────────────────────────────────
        if (points.isNotEmpty) _SplitsCard(points: points),
        const SizedBox(height: 24),

        // ── Upload button (hidden once uploaded) ───────────────────────
        if (activity.status != 'uploaded')
          _UploadButton(activity: activity, points: points, ref: ref),

        const SizedBox(height: 16),
      ],
    );
  }
}

// ── Strava status card ─────────────────────────────────────────────────────

class _StravaStatusCard extends ConsumerWidget {
  const _StravaStatusCard({required this.stravaId});

  final int stravaId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statusAsync = ref.watch(stravaStatusProvider(stravaId));

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: kSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: kDivider),
      ),
      child: Row(
        children: [
          // Strava "S" badge
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: _kStrava,
              borderRadius: BorderRadius.circular(8),
            ),
            alignment: Alignment.center,
            child: const Text(
              'S',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ),
          const SizedBox(width: 14),

          // Status label
          Expanded(
            child: statusAsync.when(
              loading: () => Row(
                children: [
                  const SizedBox(
                    width: 14,
                    height: 14,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  const SizedBox(width: 10),
                  Text('Checking Strava…',
                      style: AppTextStyles.bodySmall
                          .copyWith(color: kTextSecondary)),
                ],
              ),
              error: (_, __) => _StatusRow(
                icon: Icons.cloud_off_rounded,
                color: kTextDisabled,
                label: 'Could not connect to Strava',
              ),
              data: (status) => switch (status) {
                StravaStatus.verified => _StatusRow(
                    icon: Icons.check_circle_rounded,
                    color: kSuccess,
                    label: 'Verified online',
                  ),
                StravaStatus.notFound => _StatusRow(
                    icon: Icons.warning_amber_rounded,
                    color: kWarning,
                    label: 'Removed from Strava',
                  ),
                StravaStatus.error => _StatusRow(
                    icon: Icons.cloud_off_rounded,
                    color: kTextDisabled,
                    label: 'Could not connect to Strava',
                  ),
              },
            ),
          ),

          // Manual re-check button
          IconButton(
            icon: const Icon(Icons.refresh_rounded, size: 20),
            color: kTextSecondary,
            tooltip: 'Re-check',
            onPressed: () => ref.invalidate(stravaStatusProvider(stravaId)),
          ),
        ],
      ),
    );
  }
}

class _StatusRow extends StatelessWidget {
  const _StatusRow({
    required this.icon,
    required this.color,
    required this.label,
  });

  final IconData icon;
  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: color, size: 18),
        const SizedBox(width: 8),
        Text(label,
            style: AppTextStyles.bodySmall.copyWith(color: kTextPrimary)),
      ],
    );
  }
}

// ── Route map ──────────────────────────────────────────────────────────────

class _RouteMap extends StatelessWidget {
  const _RouteMap({required this.polyline});

  final List<LatLng> polyline;

  @override
  Widget build(BuildContext context) {
    final center = polyline.isNotEmpty
        ? polyline[polyline.length ~/ 2]
        : const LatLng(0, 0);

    return FlutterMap(
      options: MapOptions(
        // Fit all route points with padding when available; fall back to a
        // fixed centre + zoom for empty or single-point routes.
        initialCameraFit: polyline.length > 1
            ? CameraFit.coordinates(
                coordinates: polyline,
                padding: const EdgeInsets.all(40),
              )
            : null,
        initialCenter: center,
        initialZoom: 14,
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.firstklick.app',
        ),
        if (polyline.length > 1)
          PolylineLayer(
            polylines: [
              Polyline(points: polyline, color: kAccent, strokeWidth: 3),
            ],
          ),
      ],
    );
  }
}

// ── Summary card ───────────────────────────────────────────────────────────

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({required this.activity});

  final Activity activity;

  @override
  Widget build(BuildContext context) {
    final distKm = activity.totalDistanceM != null
        ? '${(activity.totalDistanceM! / 1000).toStringAsFixed(2)} km'
        : '--';
    final time = activity.totalDurationS != null
        ? _fmtDuration(activity.totalDurationS!)
        : '--';
    final pace = activity.avgPaceSPerKm != null
        ? _fmtPace(activity.avgPaceSPerKm!)
        : '--';
    final avgBpm =
        activity.avgBpm != null ? activity.avgBpm!.round().toString() : '--';
    final maxBpm = activity.maxBpm?.toString() ?? '--';
    final elevGain = activity.elevationGainM != null
        ? '${activity.elevationGainM!.round()} m'
        : '--';

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: kSurface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('SUMMARY', style: AppTextStyles.sectionTitle),
          const SizedBox(height: 16),
          _Row2('Distance', distKm, 'Time', time),
          const SizedBox(height: 12),
          _Row2('Avg Pace', pace, 'Elevation', elevGain),
          const SizedBox(height: 12),
          _Row2('Avg BPM', avgBpm, 'Max BPM', maxBpm),
        ],
      ),
    );
  }
}

class _Row2 extends StatelessWidget {
  const _Row2(this.l1, this.v1, this.l2, this.v2);

  final String l1, v1, l2, v2;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: _StatCell(label: l1, value: v1)),
        Expanded(child: _StatCell(label: l2, value: v2)),
      ],
    );
  }
}

class _StatCell extends StatelessWidget {
  const _StatCell({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label.toUpperCase(), style: AppTextStyles.metricLabel),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w300,
            color: kTextPrimary,
          ),
        ),
      ],
    );
  }
}

// ── Splits ─────────────────────────────────────────────────────────────────

class _SplitsCard extends StatelessWidget {
  const _SplitsCard({required this.points});

  final List<DataPoint> points;

  List<_Split> _buildSplits() {
    final splits = <_Split>[];
    double kmBucket = 0;
    DateTime? bucketStart;
    int bpmSum = 0;
    int bpmCount = 0;
    int kmIndex = 1;

    for (final p in points) {
      bucketStart ??= p.recordedAt;
      kmBucket += p.distanceFromPrevM ?? 0;
      if (p.bpm != null) {
        bpmSum += p.bpm!;
        bpmCount++;
      }
      if (kmBucket >= 1000) {
        final splitS = p.recordedAt.difference(bucketStart).inSeconds;
        splits.add(_Split(
          km: kmIndex++,
          timeS: splitS,
          avgBpm: bpmCount > 0 ? (bpmSum / bpmCount).round() : null,
        ));
        kmBucket -= 1000;
        bucketStart = p.recordedAt;
        bpmSum = 0;
        bpmCount = 0;
      }
    }
    return splits;
  }

  @override
  Widget build(BuildContext context) {
    final splits = _buildSplits();
    if (splits.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: kSurface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('KM SPLITS', style: AppTextStyles.sectionTitle),
          const SizedBox(height: 12),
          const Row(
            children: [
              SizedBox(
                  width: 36,
                  child: Text('KM', style: AppTextStyles.metricLabel)),
              Expanded(
                  child: Text('PACE', style: AppTextStyles.metricLabel)),
              Expanded(
                  child: Text('TIME', style: AppTextStyles.metricLabel)),
              Expanded(
                  child:
                      Text('AVG BPM', style: AppTextStyles.metricLabel)),
            ],
          ),
          const Divider(height: 16),
          ...splits.map(
            (s) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                children: [
                  SizedBox(
                    width: 36,
                    child: Text('${s.km}',
                        style: AppTextStyles.bodyMedium
                            .copyWith(color: kAccent)),
                  ),
                  Expanded(
                      child: Text(_fmtPace(s.timeS.toDouble()),
                          style: AppTextStyles.bodyMedium)),
                  Expanded(
                      child: Text(_fmtDuration(s.timeS),
                          style: AppTextStyles.bodyMedium)),
                  Expanded(
                      child: Text(s.avgBpm?.toString() ?? '--',
                          style: AppTextStyles.bodyMedium)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Split {
  const _Split({required this.km, required this.timeS, this.avgBpm});

  final int km;
  final int timeS;
  final int? avgBpm;
}

// ── Upload button ──────────────────────────────────────────────────────────

class _UploadButton extends StatefulWidget {
  const _UploadButton({
    required this.activity,
    required this.points,
    required this.ref,
  });

  final Activity activity;
  final List<DataPoint> points;
  final WidgetRef ref;

  @override
  State<_UploadButton> createState() => _UploadButtonState();
}

class _UploadButtonState extends State<_UploadButton> {
  bool _loading = false;

  Future<void> _upload() async {
    setState(() => _loading = true);
    try {
      final connected = await TokenStorage.isConnected();
      if (!connected) {
        _show('Connect Strava first in Settings');
        return;
      }

      final gpx = generateGpx(
        activityName: widget.activity.title ?? 'Run',
        points: widget.points,
      );

      final uploadId = await StravaApi.uploadActivity(
        gpxContent: gpx,
        name: widget.activity.title ?? 'Run',
      );

      final stravaActivityId = await StravaApi.pollUpload(uploadId);

      final db = widget.ref.read(appDatabaseProvider);
      await db.activitiesDao.updateById(
        widget.activity.id,
        ActivitiesCompanion(
          id: Value(widget.activity.id),
          startedAt: Value(widget.activity.startedAt),
          status: const Value('uploaded'),
          stravaId: Value(stravaActivityId),
        ),
      );

      widget.ref.invalidate(activityDetailProvider(widget.activity.id));
      _show('Uploaded to Strava!');
    } on DioException catch (e) {
      final body = e.response?.data;
      final msg = (body is Map && body['message'] != null)
          ? body['message'] as String
          : 'HTTP ${e.response?.statusCode}';
      _show('Upload failed: $msg');
    } catch (e) {
      _show('Upload failed: $e');
    } finally {
      setState(() => _loading = false);
    }
  }

  void _show(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    return ElevatedButton.icon(
      onPressed: _upload,
      icon: const Icon(Icons.upload_rounded),
      label: const Text('Upload to Strava'),
    );
  }
}

// ── Formatters ─────────────────────────────────────────────────────────────

String _fmtDuration(int totalS) {
  final h = totalS ~/ 3600;
  final m = (totalS % 3600) ~/ 60;
  final s = totalS % 60;
  if (h > 0) return '${h}h ${m.toString().padLeft(2, '0')}m';
  return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
}

String _fmtPace(double secPerKm) {
  if (secPerKm <= 0) return '--:--';
  final m = secPerKm ~/ 60;
  final s = (secPerKm % 60).round();
  return "$m'${s.toString().padLeft(2, '0')}\"";
}

// ── Share sheet ─────────────────────────────────────────────────────────────

class _ShareSheet extends StatefulWidget {
  const _ShareSheet({required this.activity, required this.points});

  final Activity activity;
  final List<DataPoint> points;

  @override
  State<_ShareSheet> createState() => _ShareSheetState();
}

class _ShareSheetState extends State<_ShareSheet> {
  final _cardKey = GlobalKey();
  bool _sharing = false;

  Future<void> _share() async {
    setState(() => _sharing = true);
    try {
      final boundary = _cardKey.currentContext!.findRenderObject()
          as RenderRepaintBoundary;
      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData =
          await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) return;
      final pngBytes = byteData.buffer.asUint8List();
      final tmpDir = await getTemporaryDirectory();
      final file = File('${tmpDir.path}/run_share.png');
      await file.writeAsBytes(pngBytes);
      await Share.shareXFiles(
        [XFile(file.path)],
        text: 'My run with First Klick',
      );
    } finally {
      if (mounted) setState(() => _sharing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            width: 36,
            height: 4,
            margin: const EdgeInsets.only(bottom: 20),
            decoration: BoxDecoration(
              color: kDivider,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Card preview
          RepaintBoundary(
            key: _cardKey,
            child: _ShareCard(
              activity: widget.activity,
              points: widget.points,
            ),
          ),

          const SizedBox(height: 20),

          // Share button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _sharing ? null : _share,
              icon: _sharing
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.share_rounded),
              label: Text(_sharing ? 'Preparing…' : 'Share'),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Share card ──────────────────────────────────────────────────────────────

class _ShareCard extends StatelessWidget {
  const _ShareCard({required this.activity, required this.points});

  final Activity activity;
  final List<DataPoint> points;

  @override
  Widget build(BuildContext context) {
    final polyline = points.map((p) => LatLng(p.lat, p.lng)).toList();
    final distKm = activity.totalDistanceM != null
        ? '${(activity.totalDistanceM! / 1000).toStringAsFixed(2)} km'
        : '--';
    final time = activity.totalDurationS != null
        ? _fmtDuration(activity.totalDurationS!)
        : '--';
    final pace = activity.avgPaceSPerKm != null
        ? _fmtPace(activity.avgPaceSPerKm!)
        : '--';

    return Container(
      width: 320,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: kBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: kDivider),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Branding
          Row(
            children: [
              const Icon(Icons.directions_run_rounded,
                  color: kAccent, size: 14),
              const SizedBox(width: 5),
              Text(
                'FIRST KLICK',
                style: AppTextStyles.metricLabel
                    .copyWith(color: kAccent, letterSpacing: 1.5),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            activity.title ?? 'Run',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: kTextPrimary,
            ),
          ),

          const SizedBox(height: 14),

          // Route drawing
          if (polyline.length > 1) ...[
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Container(
                height: 180,
                color: kSurface,
                child: CustomPaint(
                  painter: _RoutePainter(polyline),
                  child: const SizedBox.expand(),
                ),
              ),
            ),
            const SizedBox(height: 14),
          ],

          // Stats row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _ShareStat(label: 'DISTANCE', value: distKm),
              _ShareStat(label: 'TIME', value: time),
              _ShareStat(label: 'PACE', value: pace),
            ],
          ),
        ],
      ),
    );
  }
}

class _ShareStat extends StatelessWidget {
  const _ShareStat({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.metricLabel),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w300,
            color: kTextPrimary,
          ),
        ),
      ],
    );
  }
}

// ── Route painter ───────────────────────────────────────────────────────────

class _RoutePainter extends CustomPainter {
  final List<LatLng> points;
  const _RoutePainter(this.points);

  @override
  void paint(Canvas canvas, Size size) {
    if (points.length < 2) return;

    var minLat = points.first.latitude;
    var maxLat = points.first.latitude;
    var minLng = points.first.longitude;
    var maxLng = points.first.longitude;

    for (final p in points) {
      if (p.latitude < minLat) minLat = p.latitude;
      if (p.latitude > maxLat) maxLat = p.latitude;
      if (p.longitude < minLng) minLng = p.longitude;
      if (p.longitude > maxLng) maxLng = p.longitude;
    }

    const padding = 16.0;
    final availW = size.width - 2 * padding;
    final availH = size.height - 2 * padding;
    final latRange = maxLat - minLat;
    final lngRange = maxLng - minLng;

    if (latRange == 0 && lngRange == 0) return;

    // Uniform scale to preserve route shape
    final scaleX = lngRange > 0 ? availW / lngRange : double.infinity;
    final scaleY = latRange > 0 ? availH / latRange : double.infinity;
    final scale = scaleX < scaleY ? scaleX : scaleY;

    final routeW = lngRange * scale;
    final routeH = latRange * scale;
    final ox = padding + (availW - routeW) / 2;
    final oy = padding + (availH - routeH) / 2;

    Offset toOffset(LatLng p) => Offset(
          ox + (p.longitude - minLng) * scale,
          oy + (maxLat - p.latitude) * scale, // y-axis is inverted
        );

    final linePaint = Paint()
      ..color = kAccent
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final path = ui.Path()
      ..moveTo(toOffset(points.first).dx, toOffset(points.first).dy);
    for (final p in points.skip(1)) {
      final o = toOffset(p);
      path.lineTo(o.dx, o.dy);
    }
    canvas.drawPath(path, linePaint);

    // Start dot
    canvas.drawCircle(
        toOffset(points.first), 4, Paint()..color = kSuccess);
    // End dot
    canvas.drawCircle(
        toOffset(points.last), 4, Paint()..color = kError);
  }

  @override
  bool shouldRepaint(_RoutePainter old) => points != old.points;
}
