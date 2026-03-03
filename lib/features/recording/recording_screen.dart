import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';

import '../../shared/theme/app_colors.dart';
import '../../shared/theme/app_text_styles.dart';
import '../home/home_provider.dart';
import 'recording_provider.dart';

class RecordingScreen extends ConsumerStatefulWidget {
  const RecordingScreen({super.key});

  @override
  ConsumerState<RecordingScreen> createState() => _RecordingScreenState();
}

class _RecordingScreenState extends ConsumerState<RecordingScreen> {
  final _mapController = MapController();
  bool _mapReady = false;
  bool _startRequested = false; // guard: only call startRun once per screen instance
  bool _stopping = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _maybeStart());
  }

  Future<void> _maybeStart() async {
    if (_startRequested) return;
    final stats = ref.read(recordingNotifierProvider);
    // If the service is already broadcasting (app re-opened mid-run), skip.
    if (stats.isRecording) return;
    _startRequested = true;
    final db = ref.read(appDatabaseProvider);
    final bleId = await ref.read(savedBleDeviceIdProvider.future);
    if (!mounted) return;
    await ref.read(recordingNotifierProvider.notifier).startRun(db, bleDeviceId: bleId);
  }

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final stats = ref.watch(recordingNotifierProvider);

    // Follow GPS on map
    if (_mapReady && stats.lat != null && stats.lng != null) {
      _mapController.move(LatLng(stats.lat!, stats.lng!), 16);
    }

    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: kBackground,
        body: SafeArea(
          child: Column(
            children: [
              // ── Top bar ────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                child: Row(
                  children: [
                    _BleIndicator(stats: stats),
                    const Spacer(),
                    if (stats.autoPaused)
                      const _AutoPausedChip()
                    else if (stats.activityId != null)
                      Text('ID ${stats.activityId}',
                          style: AppTextStyles.bodySmall),
                  ],
                ),
              ),

              // ── Elapsed time ───────────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  _formatElapsed(stats.elapsedS),
                  style: AppTextStyles.heroNumber,
                ),
              ),

              // ── Three metrics ──────────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _MetricBox(
                      label: 'DISTANCE',
                      value: _formatDist(stats.distanceM),
                    ),
                    _MetricBox(
                      label: 'PACE',
                      value: _formatPace(stats.paceSPerKm),
                    ),
                    _BpmBox(bpm: stats.bpm),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // ── Live map ───────────────────────────────────────────
              Expanded(
                child: _LiveMap(
                  stats: stats,
                  mapController: _mapController,
                  onMapReady: () => setState(() => _mapReady = true),
                ),
              ),

              // ── Bottom controls ────────────────────────────────────
              _BottomControls(
                stats: stats,
                stopping: _stopping,
                onPause: () =>
                    ref.read(recordingNotifierProvider.notifier).pause(),
                onResume: () =>
                    ref.read(recordingNotifierProvider.notifier).resumeRun(),
                onStop: () async {
                  setState(() => _stopping = true);
                  await ref
                      .read(recordingNotifierProvider.notifier)
                      .stopRun();
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Activity saved')),
                    );
                    context.go('/');
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Sub-widgets ────────────────────────────────────────────────────────────

class _AutoPausedChip extends StatelessWidget {
  const _AutoPausedChip();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: kWarning.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: kWarning.withValues(alpha: 0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.pause_circle_outline_rounded, size: 11, color: kWarning),
          const SizedBox(width: 4),
          Text(
            'AUTO-PAUSED',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: kWarning,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _BleIndicator extends StatelessWidget {
  const _BleIndicator({required this.stats});

  final RunStats stats;

  @override
  Widget build(BuildContext context) {
    final hasBpm = stats.bpm != null;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.bluetooth_rounded,
          size: 16,
          color: hasBpm ? kAccent : kTextDisabled,
        ),
        const SizedBox(width: 4),
        Text(
          hasBpm ? 'HR connected' : 'HR searching…',
          style: AppTextStyles.bodySmall.copyWith(
            color: hasBpm ? kAccent : kTextDisabled,
          ),
        ),
      ],
    );
  }
}

class _MetricBox extends StatelessWidget {
  const _MetricBox({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value, style: AppTextStyles.metricLarge),
        const SizedBox(height: 4),
        Text(label, style: AppTextStyles.metricLabel),
      ],
    );
  }
}

class _BpmBox extends StatefulWidget {
  const _BpmBox({required this.bpm});

  final int? bpm;

  @override
  State<_BpmBox> createState() => _BpmBoxState();
}

class _BpmBoxState extends State<_BpmBox>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulse = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 400),
    lowerBound: 0.85,
    upperBound: 1.0,
  );

  @override
  void initState() {
    super.initState();
    _pulse.addStatusListener((s) {
      if (s == AnimationStatus.completed) _pulse.reverse();
      if (s == AnimationStatus.dismissed && widget.bpm != null) _pulse.forward();
    });
    if (widget.bpm != null) _pulse.forward();
  }

  @override
  void didUpdateWidget(_BpmBox old) {
    super.didUpdateWidget(old);
    if (widget.bpm != null && !_pulse.isAnimating) _pulse.forward();
    if (widget.bpm == null) _pulse.stop();
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ScaleTransition(
          scale: _pulse,
          child: Text(
            widget.bpm?.toString() ?? '--',
            style: AppTextStyles.metricLarge.copyWith(
              color: widget.bpm != null ? kError : kTextDisabled,
            ),
          ),
        ),
        const SizedBox(height: 4),
        const Text('BPM', style: AppTextStyles.metricLabel),
      ],
    );
  }
}

class _LiveMap extends StatelessWidget {
  const _LiveMap({
    required this.stats,
    required this.mapController,
    required this.onMapReady,
  });

  final RunStats stats;
  final MapController mapController;
  final VoidCallback onMapReady;

  @override
  Widget build(BuildContext context) {
    final center = (stats.lat != null && stats.lng != null)
        ? LatLng(stats.lat!, stats.lng!)
        : const LatLng(0, 0);

    return FlutterMap(
      mapController: mapController,
      options: MapOptions(
        initialCenter: center,
        initialZoom: 16,
        onMapReady: onMapReady,
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.firstklick.app',
        ),
        if (stats.routePoints.length > 1)
          PolylineLayer(
            polylines: [
              Polyline(
                points: stats.routePoints,
                color: kAccent,
                strokeWidth: 3,
              ),
            ],
          ),
        if (stats.lat != null && stats.lng != null)
          MarkerLayer(
            markers: [
              Marker(
                point: LatLng(stats.lat!, stats.lng!),
                width: 16,
                height: 16,
                child: Container(
                  decoration: BoxDecoration(
                    color: kAccent,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                ),
              ),
            ],
          ),
      ],
    );
  }
}

class _BottomControls extends StatelessWidget {
  const _BottomControls({
    required this.stats,
    required this.stopping,
    required this.onPause,
    required this.onResume,
    required this.onStop,
  });

  final RunStats stats;
  final bool stopping;
  final VoidCallback onPause;
  final VoidCallback onResume;
  final VoidCallback onStop;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
      color: kSurface,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (stats.autoPaused) ...[
            Text(
              'Waiting for movement…',
              style: TextStyle(
                fontSize: 11,
                color: kWarning,
                fontWeight: FontWeight.w500,
                letterSpacing: 0.3,
              ),
            ),
            const SizedBox(height: 12),
          ],
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // When auto-paused the play button lets the user force-resume.
              _CircleButton(
                icon: stats.paused
                    ? Icons.play_arrow_rounded
                    : Icons.pause_rounded,
                color: kSurfaceElevated,
                onTap: stopping ? null : (stats.paused ? onResume : onPause),
              ),
              const SizedBox(width: 24),
              _CircleButton(
                icon: Icons.stop_rounded,
                color: kError,
                onTap: stopping ? null : onStop,
                loading: stopping,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CircleButton extends StatelessWidget {
  const _CircleButton({
    required this.icon,
    required this.color,
    required this.onTap,
    this.loading = false,
  });

  final IconData icon;
  final Color color;
  final VoidCallback? onTap;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 64,
        height: 64,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        child: loading
            ? const Padding(
                padding: EdgeInsets.all(18),
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Icon(icon, color: Colors.white, size: 28),
      ),
    );
  }
}

// ── Formatters ─────────────────────────────────────────────────────────────

String _formatElapsed(int s) {
  final h = s ~/ 3600;
  final m = (s % 3600) ~/ 60;
  final sec = s % 60;
  if (h > 0) {
    return '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}:${sec.toString().padLeft(2, '0')}';
  }
  return '${m.toString().padLeft(2, '0')}:${sec.toString().padLeft(2, '0')}';
}

String _formatDist(double m) {
  if (m >= 1000) return '${(m / 1000).toStringAsFixed(2)}km';
  return '${m.round()}m';
}

String _formatPace(double secPerKm) {
  if (secPerKm <= 0) return '--:--';
  final m = secPerKm ~/ 60;
  final s = (secPerKm % 60).round();
  return "$m'${s.toString().padLeft(2, '0')}\"";
}
