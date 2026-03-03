import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../core/database/app_database.dart';
import '../../shared/theme/app_colors.dart';
import '../../shared/theme/app_text_styles.dart';
import '../home/home_provider.dart';
import '../recording/recording_provider.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  Future<void> _refresh() async {
    ref.invalidate(activitiesListProvider);
    await ref.read(activitiesListProvider.future);
  }

  @override
  Widget build(BuildContext context) {
    final activitiesAsync = ref.watch(activitiesListProvider);
    final runStats = ref.watch(recordingNotifierProvider);
    final gpsReady =
        ref.watch(currentGpsPositionProvider).valueOrNull != null;

    return Scaffold(
      appBar: AppBar(
        title: const Text('First Klick'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => context.push('/settings'),
          ),
        ],
      ),
      body: Column(
        children: [
          // Live run banner — shown only when background service is active
          if (runStats.isRecording)
            _LiveRunBanner(stats: runStats),

          // Activity list or empty state
          Expanded(
            child: activitiesAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Error: $e')),
              data: (activities) => RefreshIndicator(
                onRefresh: _refresh,
                child: activities.isEmpty
                    ? const CustomScrollView(
                        physics: AlwaysScrollableScrollPhysics(),
                        slivers: [
                          SliverFillRemaining(child: _EmptyState()),
                        ],
                      )
                    : _ActivityList(activities: activities),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: runStats.isRecording
          ? null // hide FAB while a run is in progress
          : FloatingActionButton.extended(
              heroTag: null,
              onPressed: gpsReady ? () => context.push('/recording') : null,
              icon: gpsReady
                  ? const Icon(Icons.play_arrow_rounded)
                  : const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2.5),
                    ),
              label: Text(gpsReady ? 'Start Run' : 'Acquiring GPS…'),
            ),
    );
  }
}

// ── Live run banner ────────────────────────────────────────────────────────

class _LiveRunBanner extends StatelessWidget {
  const _LiveRunBanner({required this.stats});

  final RunStats stats;

  @override
  Widget build(BuildContext context) {
    final hasGps = stats.lat != null && stats.lng != null;

    return GestureDetector(
      onTap: () => context.push('/recording'),
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
        padding: const EdgeInsets.fromLTRB(20, 14, 20, 16),
        decoration: BoxDecoration(
          color: kAccent.withValues(alpha: 0.07),
          border: Border.all(color: kAccent.withValues(alpha: 0.35)),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Status row ───────────────────────────────────────────
            Row(
              children: [
                _PulsingDot(),
                const SizedBox(width: 8),
                Text(
                  'RECORDING',
                  style: AppTextStyles.metricLabel
                      .copyWith(color: kAccent, letterSpacing: 1.5),
                ),
                const SizedBox(width: 10),
                // GPS badge
                _StatusBadge(
                  icon: Icons.location_on_rounded,
                  label: hasGps ? 'GPS' : 'No GPS',
                  active: hasGps,
                ),
                const Spacer(),
                const Icon(Icons.chevron_right_rounded,
                    color: kAccent, size: 18),
              ],
            ),

            const SizedBox(height: 10),

            // ── Elapsed time (hero) ───────────────────────────────────
            Text(
              _fmtElapsed(stats.elapsedS),
              style: const TextStyle(
                fontSize: 44,
                fontWeight: FontWeight.w200,
                color: kTextPrimary,
                letterSpacing: -1.5,
                height: 1,
              ),
            ),

            const SizedBox(height: 12),

            // ── Three metrics row ────────────────────────────────────
            Row(
              children: [
                _BannerMetric(
                  label: 'PACE',
                  value: _fmtPace(stats.paceSPerKm),
                ),
                const _Divider(),
                _BannerMetric(
                  label: 'DISTANCE',
                  value: _fmtDist(stats.distanceM),
                ),
                const _Divider(),
                _BannerMetric(
                  label: 'BPM',
                  value: stats.bpm?.toString() ?? '--',
                  valueColor: stats.bpm != null ? kError : kTextDisabled,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ── Banner sub-widgets ─────────────────────────────────────────────────────

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({
    required this.icon,
    required this.label,
    required this.active,
  });

  final IconData icon;
  final String label;
  final bool active;

  @override
  Widget build(BuildContext context) {
    final color = active ? kSuccess : kTextDisabled;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 11, color: color),
          const SizedBox(width: 3),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: color,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _BannerMetric extends StatelessWidget {
  const _BannerMetric({
    required this.label,
    required this.value,
    this.valueColor = kTextPrimary,
  });

  final String label;
  final String value;
  final Color valueColor;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: AppTextStyles.metricLabel),
          const SizedBox(height: 2),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w300,
              color: valueColor,
              height: 1.1,
            ),
          ),
        ],
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  const _Divider();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 32,
      margin: const EdgeInsets.symmetric(horizontal: 12),
      color: kDivider,
    );
  }
}

class _PulsingDot extends StatefulWidget {
  @override
  State<_PulsingDot> createState() => _PulsingDotState();
}

class _PulsingDotState extends State<_PulsingDot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _ctrl,
      child: Container(
        width: 8,
        height: 8,
        decoration: const BoxDecoration(
          color: kError,
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}

// ── Empty state ────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.directions_run_rounded, size: 72, color: kAccent.withValues(alpha: 0.3)),
          const SizedBox(height: 24),
          const Text('No runs yet', style: AppTextStyles.bodyLarge),
          const SizedBox(height: 8),
          Text(
            'Tap the button below to start recording',
            style: AppTextStyles.bodySmall.copyWith(color: kTextSecondary),
          ),
        ],
      ),
    );
  }
}

// ── Activity list ──────────────────────────────────────────────────────────

class _ActivityList extends StatelessWidget {
  const _ActivityList({required this.activities});

  final List<Activity> activities;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      // +1 for the weekly summary card at index 0
      itemCount: activities.length + 1,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, i) {
        if (i == 0) return _WeeklySummaryCard(activities: activities);
        return _ActivityCard(activity: activities[i - 1]);
      },
    );
  }
}

// ── Weekly summary card ────────────────────────────────────────────────────

class _WeeklySummaryCard extends StatelessWidget {
  const _WeeklySummaryCard({required this.activities});

  final List<Activity> activities;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    // ISO week starts on Monday
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    final startOfWeek =
        DateTime(weekStart.year, weekStart.month, weekStart.day);

    final thisWeek = activities
        .where((a) => !a.startedAt.isBefore(startOfWeek))
        .toList();

    if (thisWeek.isEmpty) return const SizedBox.shrink();

    final totalDistM = thisWeek.fold<double>(
        0, (sum, a) => sum + (a.totalDistanceM ?? 0));
    final totalS =
        thisWeek.fold<int>(0, (sum, a) => sum + (a.totalDurationS ?? 0));

    final distKm = (totalDistM / 1000).toStringAsFixed(1);
    final h = totalS ~/ 3600;
    final m = (totalS % 3600) ~/ 60;
    final timeStr = h > 0 ? '${h}h ${m.toString().padLeft(2, '0')}m' : '${m}m';

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: kSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: kAccent.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'THIS WEEK',
            style: AppTextStyles.metricLabel.copyWith(color: kAccent),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _WeeklyStat(label: 'RUNS', value: '${thisWeek.length}'),
              const SizedBox(width: 24),
              _WeeklyStat(label: 'DISTANCE', value: '${distKm}km'),
              const SizedBox(width: 24),
              _WeeklyStat(label: 'TIME', value: timeStr),
            ],
          ),
        ],
      ),
    );
  }
}

class _WeeklyStat extends StatelessWidget {
  const _WeeklyStat({required this.label, required this.value});

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
            fontSize: 22,
            fontWeight: FontWeight.w300,
            color: kTextPrimary,
          ),
        ),
      ],
    );
  }
}

// ── Activity card ───────────────────────────────────────────────────────────

class _ActivityCard extends StatelessWidget {
  const _ActivityCard({required this.activity});

  final Activity activity;

  @override
  Widget build(BuildContext context) {
    final distKm = activity.totalDistanceM != null
        ? (activity.totalDistanceM! / 1000).toStringAsFixed(2)
        : '--';
    final duration = activity.totalDurationS != null
        ? _formatDuration(activity.totalDurationS!)
        : '--:--';
    final pace = activity.avgPaceSPerKm != null
        ? _formatPace(activity.avgPaceSPerKm!)
        : '--:--';
    final date = DateFormat('EEE d MMM, HH:mm').format(activity.startedAt);

    return GestureDetector(
      onTap: () => context.push('/activity/${activity.id}'),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: kSurface,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    activity.title ?? 'Run',
                    style: AppTextStyles.bodyLarge
                        .copyWith(fontWeight: FontWeight.w600),
                  ),
                ),
                if (activity.status == 'uploaded')
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: kAccent.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Text('Uploaded',
                        style: TextStyle(
                            fontSize: 11,
                            color: kAccent,
                            fontWeight: FontWeight.w600)),
                  )
                else
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: kTextSecondary.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Text('Not uploaded',
                        style: TextStyle(
                            fontSize: 11,
                            color: kTextSecondary,
                            fontWeight: FontWeight.w500)),
                  ),
              ],
            ),
            const SizedBox(height: 4),
            Text(date, style: AppTextStyles.bodySmall),
            const SizedBox(height: 16),
            Row(
              children: [
                _Stat(label: 'DISTANCE', value: '${distKm}km'),
                const SizedBox(width: 24),
                _Stat(label: 'TIME', value: duration),
                const SizedBox(width: 24),
                _Stat(label: 'AVG PACE', value: pace),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.metricLabel),
        const SizedBox(height: 2),
        Text(value,
            style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w300,
                color: kTextPrimary)),
      ],
    );
  }
}

// ── Live banner formatters ─────────────────────────────────────────────────

String _fmtElapsed(int s) {
  final h = s ~/ 3600;
  final m = (s % 3600) ~/ 60;
  final sec = s % 60;
  if (h > 0) {
    return '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}:${sec.toString().padLeft(2, '0')}';
  }
  return '${m.toString().padLeft(2, '0')}:${sec.toString().padLeft(2, '0')}';
}

String _fmtDist(double metres) {
  if (metres >= 1000) return '${(metres / 1000).toStringAsFixed(2)} km';
  return '${metres.round()} m';
}

String _fmtPace(double secPerKm) {
  if (secPerKm <= 0) return "--'--\"";
  final m = secPerKm ~/ 60;
  final s = (secPerKm % 60).round();
  return "$m'${s.toString().padLeft(2, '0')}\"";
}

// ── Activity card formatters ───────────────────────────────────────────────

String _formatDuration(int totalS) {
  final h = totalS ~/ 3600;
  final m = (totalS % 3600) ~/ 60;
  final s = totalS % 60;
  if (h > 0) {
    return '${h}h ${m.toString().padLeft(2, '0')}m';
  }
  return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
}

String _formatPace(double paceSecPerKm) {
  final m = paceSecPerKm ~/ 60;
  final s = (paceSecPerKm % 60).round();
  return "$m'${s.toString().padLeft(2, '0')}\"/km";
}
