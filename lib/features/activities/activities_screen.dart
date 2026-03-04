import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../core/database/app_database.dart';
import '../../shared/theme/app_colors.dart';
import '../../shared/theme/app_text_styles.dart';
import '../home/home_provider.dart';

class ActivitiesScreen extends ConsumerStatefulWidget {
  const ActivitiesScreen({super.key});

  @override
  ConsumerState<ActivitiesScreen> createState() => _ActivitiesScreenState();
}

class _ActivitiesScreenState extends ConsumerState<ActivitiesScreen> {
  Future<void> _refresh() async {
    ref.invalidate(activitiesListProvider);
    await ref.read(activitiesListProvider.future);
  }

  @override
  Widget build(BuildContext context) {
    final activitiesAsync = ref.watch(activitiesListProvider);

    return activitiesAsync.when(
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
    );
  }
}

// ── Empty state ─────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.directions_run_rounded,
              size: 72, color: kAccent.withValues(alpha: 0.3)),
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

// ── Activity list ───────────────────────────────────────────────────────────

class _ActivityList extends StatelessWidget {
  const _ActivityList({required this.activities});

  final List<Activity> activities;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      itemCount: activities.length + 1,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, i) {
        if (i == 0) return _WeeklySummaryCard(activities: activities);
        return _ActivityCard(activity: activities[i - 1]);
      },
    );
  }
}

// ── Weekly summary card ─────────────────────────────────────────────────────

class _WeeklySummaryCard extends StatelessWidget {
  const _WeeklySummaryCard({required this.activities});

  final List<Activity> activities;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    final startOfWeek =
        DateTime(weekStart.year, weekStart.month, weekStart.day);

    final thisWeek =
        activities.where((a) => !a.startedAt.isBefore(startOfWeek)).toList();

    if (thisWeek.isEmpty) return const SizedBox.shrink();

    final totalDistM =
        thisWeek.fold<double>(0, (sum, a) => sum + (a.totalDistanceM ?? 0));
    final totalS =
        thisWeek.fold<int>(0, (sum, a) => sum + (a.totalDurationS ?? 0));

    final distKm = (totalDistM / 1000).toStringAsFixed(1);
    final h = totalS ~/ 3600;
    final m = (totalS % 3600) ~/ 60;
    final timeStr =
        h > 0 ? '${h}h ${m.toString().padLeft(2, '0')}m' : '${m}m';

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

// ── Formatters ──────────────────────────────────────────────────────────────

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
