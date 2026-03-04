import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../core/database/app_database.dart';
import '../../shared/theme/app_colors.dart';
import '../../shared/theme/app_text_styles.dart';
import '../activities/activities_screen.dart';
import '../home/home_provider.dart';
import '../recording/recording_provider.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _tab = 0;

  @override
  Widget build(BuildContext context) {
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
          if (runStats.isRecording) _LiveRunBanner(stats: runStats),
          Expanded(
            child: IndexedStack(
              index: _tab,
              children: const [
                _CalendarTab(),
                ActivitiesScreen(),
              ],
            ),
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingActionButton(
        heroTag: null,
        backgroundColor: runStats.isRecording
            ? kError
            : gpsReady
                ? kAccent
                : kTextDisabled,
        onPressed: (runStats.isRecording || gpsReady)
            ? () => context.push('/recording')
            : null,
        child: runStats.isRecording
            ? const Icon(Icons.fiber_manual_record, color: kTextPrimary)
            : gpsReady
                ? const Icon(Icons.play_arrow_rounded, color: kBackground)
                : const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: kTextPrimary,
                    ),
                  ),
      ),
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 6,
        color: kSurface,
        child: Row(
          children: [
            Expanded(
              child: _NavItem(
                icon: Icons.calendar_month_outlined,
                label: 'Calendar',
                active: _tab == 0,
                onTap: () => setState(() => _tab = 0),
              ),
            ),
            const SizedBox(width: 80),
            Expanded(
              child: _NavItem(
                icon: Icons.list_rounded,
                label: 'Activities',
                active: _tab == 1,
                onTap: () => setState(() => _tab = 1),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Bottom nav item ─────────────────────────────────────────────────────────

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.label,
    required this.active,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = active ? kAccent : kTextSecondary;
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color: color,
                fontWeight: active ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Calendar tab ────────────────────────────────────────────────────────────

class _CalendarTab extends ConsumerStatefulWidget {
  const _CalendarTab();

  @override
  ConsumerState<_CalendarTab> createState() => _CalendarTabState();
}

class _CalendarTabState extends ConsumerState<_CalendarTab> {
  late DateTime _month;
  int? _selectedDay;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _month = DateTime(now.year, now.month);
  }

  @override
  Widget build(BuildContext context) {
    final activitiesAsync = ref.watch(activitiesListProvider);
    final allActivities = activitiesAsync.valueOrNull ?? [];

    final monthActivities = allActivities
        .where((a) =>
            a.startedAt.year == _month.year &&
            a.startedAt.month == _month.month)
        .toList();

    final activeDays = monthActivities.map((a) => a.startedAt.day).toSet();

    final selectedActivities = _selectedDay == null
        ? <Activity>[]
        : monthActivities
            .where((a) => a.startedAt.day == _selectedDay)
            .toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _CalendarCard(
            month: _month,
            activeDays: activeDays,
            selectedDay: _selectedDay,
            onDayTap: (day) => setState(() {
              _selectedDay = _selectedDay == day ? null : day;
            }),
            onPrev: () => setState(() {
              _month = DateTime(_month.year, _month.month - 1);
              _selectedDay = null;
            }),
            onNext: () => setState(() {
              _month = DateTime(_month.year, _month.month + 1);
              _selectedDay = null;
            }),
          ),
          if (selectedActivities.isNotEmpty) ...[
            const SizedBox(height: 12),
            ...selectedActivities.map((a) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _SelectedDayCard(activity: a),
                )),
          ],
        ],
      ),
    );
  }
}

// ── Calendar card ───────────────────────────────────────────────────────────

class _CalendarCard extends StatelessWidget {
  const _CalendarCard({
    required this.month,
    required this.activeDays,
    required this.selectedDay,
    required this.onDayTap,
    required this.onPrev,
    required this.onNext,
  });

  final DateTime month;
  final Set<int> activeDays;
  final int? selectedDay;
  final ValueChanged<int> onDayTap;
  final VoidCallback onPrev;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();
    final daysInMonth = DateTime(month.year, month.month + 1, 0).day;
    final firstWeekday =
        DateTime(month.year, month.month, 1).weekday; // 1=Mon, 7=Sun
    final offset = firstWeekday - 1;

    final dayLabels = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
    final totalCells = offset + daysInMonth;
    final rows = (totalCells / 7).ceil();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: kSurface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          // Month/year header
          Row(
            children: [
              IconButton(
                onPressed: onPrev,
                icon: const Icon(Icons.chevron_left_rounded,
                    color: kTextSecondary),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                iconSize: 24,
              ),
              Expanded(
                child: Text(
                  DateFormat('MMMM yyyy').format(month),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: kTextPrimary,
                  ),
                ),
              ),
              IconButton(
                onPressed: onNext,
                icon: const Icon(Icons.chevron_right_rounded,
                    color: kTextSecondary),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                iconSize: 24,
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Day-of-week labels
          Row(
            children: dayLabels
                .map((d) => Expanded(
                      child: Center(
                        child: Text(
                          d,
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: kTextSecondary,
                          ),
                        ),
                      ),
                    ))
                .toList(),
          ),
          const SizedBox(height: 8),

          // Calendar grid
          for (int row = 0; row < rows; row++)
            Row(
              children: List.generate(7, (col) {
                final cellIndex = row * 7 + col;
                final day = cellIndex - offset + 1;
                if (day < 1 || day > daysInMonth) {
                  return const Expanded(child: SizedBox(height: 44));
                }
                final isToday = today.year == month.year &&
                    today.month == month.month &&
                    today.day == day;
                return Expanded(
                  child: _DayCell(
                    day: day,
                    isToday: isToday,
                    hasActivity: activeDays.contains(day),
                    isSelected: selectedDay == day,
                    onTap: () => onDayTap(day),
                  ),
                );
              }),
            ),
        ],
      ),
    );
  }
}

// ── Day cell ────────────────────────────────────────────────────────────────

class _DayCell extends StatelessWidget {
  const _DayCell({
    required this.day,
    required this.isToday,
    required this.hasActivity,
    required this.isSelected,
    required this.onTap,
  });

  final int day;
  final bool isToday;
  final bool hasActivity;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final Color circleColor;
    final Color textColor;
    final Border? border;

    if (isSelected) {
      circleColor = kAccent;
      textColor = kBackground;
      border = null;
    } else if (isToday) {
      circleColor = kAccent.withValues(alpha: 0.15);
      textColor = kAccent;
      border = Border.all(color: kAccent, width: 1.5);
    } else {
      circleColor = Colors.transparent;
      textColor = kTextPrimary;
      border = null;
    }

    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: circleColor,
                border: border,
              ),
              child: Center(
                child: Text(
                  '$day',
                  style: TextStyle(
                    fontSize: 13,
                    color: textColor,
                    fontWeight: (isToday || isSelected)
                        ? FontWeight.w600
                        : FontWeight.w400,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 2),
            Container(
              width: 5,
              height: 5,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: hasActivity
                    ? (isSelected ? kBackground : kAccent)
                    : Colors.transparent,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Selected day activity card ──────────────────────────────────────────────

class _SelectedDayCard extends StatelessWidget {
  const _SelectedDayCard({required this.activity});

  final Activity activity;

  @override
  Widget build(BuildContext context) {
    final distKm = activity.totalDistanceM != null
        ? '${(activity.totalDistanceM! / 1000).toStringAsFixed(2)} km'
        : '--';
    final duration = activity.totalDurationS != null
        ? _fmtDuration(activity.totalDurationS!)
        : '--:--';
    final pace = activity.avgPaceSPerKm != null
        ? _fmtActivityPace(activity.avgPaceSPerKm!)
        : '--:--';
    final time = DateFormat('HH:mm').format(activity.startedAt);

    return GestureDetector(
      onTap: () => context.push('/activity/${activity.id}'),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: kSurfaceElevated,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: kAccent.withValues(alpha: 0.25)),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: kAccent.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.directions_run_rounded,
                  color: kAccent, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    activity.title ?? 'Run',
                    style: AppTextStyles.bodyLarge
                        .copyWith(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 2),
                  Text(time, style: AppTextStyles.bodySmall),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(distKm,
                    style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: kTextPrimary)),
                const SizedBox(height: 2),
                Text('$duration  ·  $pace',
                    style: AppTextStyles.bodySmall),
              ],
            ),
            const SizedBox(width: 8),
            const Icon(Icons.chevron_right_rounded,
                color: kTextSecondary, size: 18),
          ],
        ),
      ),
    );
  }
}

String _fmtDuration(int totalS) {
  final h = totalS ~/ 3600;
  final m = (totalS % 3600) ~/ 60;
  final s = totalS % 60;
  if (h > 0) return '${h}h ${m.toString().padLeft(2, '0')}m';
  return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
}

String _fmtActivityPace(double paceSecPerKm) {
  final m = paceSecPerKm ~/ 60;
  final s = (paceSecPerKm % 60).round();
  return "$m'${s.toString().padLeft(2, '0')}\"/km";
}

// ── Live run banner ─────────────────────────────────────────────────────────

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
            Row(
              children: [
                _BannerMetric(
                  label: 'PACE',
                  value: _fmtPace(stats.paceSPerKm),
                ),
                const _BannerDivider(),
                _BannerMetric(
                  label: 'DISTANCE',
                  value: _fmtDist(stats.distanceM),
                ),
                const _BannerDivider(),
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

// ── Banner sub-widgets ──────────────────────────────────────────────────────

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

class _BannerDivider extends StatelessWidget {
  const _BannerDivider();

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

// ── Banner formatters ───────────────────────────────────────────────────────

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
