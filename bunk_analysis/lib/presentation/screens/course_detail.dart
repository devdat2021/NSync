// lib/presentation/screens/course_detail_screen.dart

import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../data/models/course_attendance.dart';
import '../../core/constants/threshold.dart';

class CourseDetailScreen extends StatefulWidget {
  final CourseData course;
  const CourseDetailScreen({super.key, required this.course});

  @override
  State<CourseDetailScreen> createState() => _CourseDetailScreenState();
}

class _CourseDetailScreenState extends State<CourseDetailScreen> {
  late int _simAttended;
  late int _simTotal;

  @override
  void initState() {
    super.initState();
    _simAttended = widget.course.attended;
    _simTotal = widget.course.total;
  }

  double get _simPct => _simTotal == 0 ? 0 : (_simAttended / _simTotal) * 100;
  // bool get _simSafe => _simPct >= 75;
  bool get _simSafe => _simPct >= AttendanceThresholds.safe;
  bool get _simWarning =>
      _simPct >= AttendanceThresholds.warning &&
      _simPct < AttendanceThresholds.safe;
  bool get _simAtRisk => _simPct < AttendanceThresholds.warning;
  bool get _isDirty =>
      _simAttended != widget.course.attended ||
      _simTotal != widget.course.total;

  void _reset() => setState(() {
    _simAttended = widget.course.attended;
    _simTotal = widget.course.total;
  });

  // Attend n future classes
  void _attendMore(int n) => setState(() {
    _simAttended += n;
    _simTotal += n;
  });
  int get _bunkable {
    final max = (_simAttended / 0.85).floor() - _simTotal;
    return max < 0 ? 0 : max;
  }

  int get _mustAttend {
    final needed = ((0.85 * _simTotal) - _simAttended) / 0.15;
    return needed.ceil().clamp(0, 999);
  }

  int get _classesToClearPenalty {
    if (!_simWarning) return 0;
    final needed = ((0.85 * _simTotal) - _simAttended) / 0.15;
    return needed.ceil().clamp(0, 999);
  }

  // Bunk n future classes
  void _bunkMore(int n) => setState(() {
    _simTotal += n;
  });

  // int get _bunkable {
  //   final max = (_simAttended / 0.75).floor() - _simTotal;
  //   return max < 0 ? 0 : max;
  // }

  // int get _mustAttend {
  //   final needed = ((0.75 * _simTotal) - _simAttended) / 0.25;
  //   return needed.ceil().clamp(0, 999);
  // }

  @override
  Widget build(BuildContext context) {
    final c = AppColorSchemeExt.of(context);
    final course = widget.course;

    return Scaffold(
      backgroundColor: c.pageBg,
      body: CustomScrollView(
        slivers: [
          // ── App bar ───────────────────────────────────────────────
          SliverAppBar(
            backgroundColor: c.pageBg,
            foregroundColor: c.textPrimary,
            pinned: true,
            elevation: 0,
            leading: IconButton(
              icon: Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: c.surfaceBg,
                  borderRadius: BorderRadius.circular(AppDimens.radiusMd),
                  border: Border.all(color: c.surfaceBorder),
                ),
                child: Icon(
                  Icons.arrow_back_rounded,
                  size: 16,
                  color: c.textPrimary,
                ),
              ),
              onPressed: () => Navigator.pop(context),
            ),
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  course.code,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1.2,
                    color: c.textMuted,
                  ),
                ),
                Text(
                  course.name,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: c.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
            actions: [
              if (_isDirty)
                Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: GestureDetector(
                    onTap: _reset,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: c.surfaceBg,
                        borderRadius: BorderRadius.circular(
                          AppDimens.radiusPill,
                        ),
                        border: Border.all(color: c.surfaceBorder),
                      ),
                      child: Text(
                        'Reset',
                        style: TextStyle(
                          fontSize: 12,
                          color: c.textMuted,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(1),
              child: Container(height: 1, color: c.surfaceBorder),
            ),
          ),

          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 40),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // ── Big stat card ─────────────────────────────────
                _StatCard(
                  course: course,
                  simAttended: _simAttended,
                  simTotal: _simTotal,
                  simPct: _simPct,
                  simSafe: _simSafe,
                  isDirty: _isDirty,
                  c: c,
                ),

                const SizedBox(height: 12),

                // ── Status banner ─────────────────────────────────
                _StatusBanner(
                  simSafe: _simSafe,
                  bunkable: _bunkable,
                  mustAttend: _mustAttend,
                  c: c,
                  simWarning: _simWarning, // ← add
                  simAtRisk: _simAtRisk,
                  classesToClearPenalty: _classesToClearPenalty,
                ),

                const SizedBox(height: 24),

                // ── Simulator ─────────────────────────────────────
                _SectionLabel(label: 'SIMULATE', c: c),
                const SizedBox(height: 10),

                _SimCard(
                  label: 'Attend future classes',
                  sublabel: 'You show up — what happens?',
                  icon: Icons.check_circle_outline_rounded,
                  iconColor: c.accentGreen,
                  onAdd: () => _attendMore(1),
                  onSubtract: () {
                    if (_simAttended > widget.course.attended &&
                        _simTotal > widget.course.total) {
                      _attendMore(-1);
                    }
                  },
                  count: _simAttended - widget.course.attended,
                  c: c,
                ),

                const SizedBox(height: 10),

                _SimCard(
                  label: 'Bunk future classes',
                  sublabel: 'You skip — how bad does it get?',
                  icon: Icons.cancel_outlined,
                  iconColor: c.accentRed,
                  onAdd: () => _bunkMore(1),
                  onSubtract: () {
                    if (_simTotal - _simAttended >
                        widget.course.total - widget.course.attended) {
                      _bunkMore(-1);
                    }
                  },
                  count:
                      (_simTotal - _simAttended) -
                      (widget.course.total - widget.course.attended),
                  c: c,
                ),

                const SizedBox(height: 24),

                // ── Quick sim chips ───────────────────────────────
                _SectionLabel(label: 'QUICK SIMULATE', c: c),
                const SizedBox(height: 10),
                _QuickChips(onAttend: _attendMore, onBunk: _bunkMore, c: c),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Big stat card ────────────────────────────────────────────────────────────

class _StatCard extends StatelessWidget {
  final CourseData course;
  final int simAttended;
  final int simTotal;
  final double simPct;
  final bool simSafe;
  final bool isDirty;
  final AppColorSchemeExt c;

  const _StatCard({
    required this.course,
    required this.simAttended,
    required this.simTotal,
    required this.simPct,
    required this.simSafe,
    required this.isDirty,
    required this.c,
  });

  @override
  Widget build(BuildContext context) {
    final origPct = course.total == 0
        ? 0.0
        : course.attended / course.total * 100;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: c.surfaceBg,
        borderRadius: BorderRadius.circular(AppDimens.radiusLg),
        border: Border.all(color: c.surfaceBorder),
      ),
      child: Column(
        children: [
          // Big percentage
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${simPct.toStringAsFixed(1)}%',
                style: TextStyle(
                  fontSize: 56,
                  fontWeight: FontWeight.w800,
                  color: course.color,
                  height: 1.0,
                  letterSpacing: -2,
                ),
              ),
              if (isDirty) ...[
                const SizedBox(width: 10),
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      Icon(
                        simPct >= origPct
                            ? Icons.arrow_upward_rounded
                            : Icons.arrow_downward_rounded,
                        size: 14,
                        color: simPct >= origPct ? c.accentGreen : c.accentRed,
                      ),
                      const SizedBox(width: 2),
                      Text(
                        '${(simPct - origPct).abs().toStringAsFixed(1)}%',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: simPct >= origPct
                              ? c.accentGreen
                              : c.accentRed,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),

          const SizedBox(height: 8),

          // Sub-label
          Text(
            '$simAttended attended · ${simTotal - simAttended} missed · $simTotal total',
            style: TextStyle(fontSize: 13, color: c.textMuted),
          ),

          const SizedBox(height: 16),

          // Progress bar with markers
          LayoutBuilder(
            builder: (context, constraints) {
              final w = constraints.maxWidth;
              return Stack(
                clipBehavior: Clip.none,
                children: [
                  // Track
                  Container(
                    height: 8,
                    width: w,
                    decoration: BoxDecoration(
                      color: c.surfaceBorder,
                      borderRadius: BorderRadius.circular(99),
                    ),
                  ),
                  // Fill
                  Container(
                    height: 8,
                    width: w * (simPct / 100).clamp(0.0, 1.0),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: simSafe
                            ? [course.color, c.accentGreen]
                            : [c.accentRed, course.color],
                      ),
                      borderRadius: BorderRadius.circular(99),
                    ),
                  ),
                  // Original position marker
                  if (isDirty)
                    Positioned(
                      left: w * (origPct / 100).clamp(0.0, 1.0) - 1,
                      top: -3,
                      child: Container(
                        width: 2,
                        height: 14,
                        decoration: BoxDecoration(
                          color: c.textSubtle,
                          borderRadius: BorderRadius.circular(1),
                        ),
                      ),
                    ),
                  Positioned(
                    left: w * 0.85 - 0.85,
                    top: -4,
                    child: Container(width: 1.5, height: 17, color: c.tick),
                  ),
                  // 75% tick
                  Positioned(
                    left: w * 0.75 - 0.75,
                    top: -4,
                    child: Container(width: 1.5, height: 17, color: c.tick),
                  ),
                ],
              );
            },
          ),

          const SizedBox(height: 8),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('0%', style: TextStyle(fontSize: 11, color: c.textSubtle)),
              Text(
                '75% min',
                style: TextStyle(fontSize: 11, color: c.textSubtle),
              ),
              Text('100%', style: TextStyle(fontSize: 11, color: c.textSubtle)),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── Status banner ────────────────────────────────────────────────────────────

class _StatusBanner extends StatelessWidget {
  final bool simSafe;
  final int bunkable;
  final int mustAttend;
  final int classesToClearPenalty;
  final AppColorSchemeExt c;
  final bool simWarning;
  final bool simAtRisk;

  const _StatusBanner({
    required this.simSafe,
    required this.bunkable,
    required this.mustAttend,
    required this.c,
    required this.simWarning, // ← add
    required this.simAtRisk,
    required this.classesToClearPenalty,
  });

  @override
  Widget build(BuildContext context) {
    // final color = simSafe ? c.accentGreen : c.accentRed;
    // final icon = simSafe
    //     ? Icons.check_circle_rounded
    //     : Icons.warning_amber_rounded;
    // final title = simSafe
    //     ? bunkable == 0
    //           ? 'Right at the limit — don\'t miss any more'
    //           : 'You can bunk $bunkable more class${bunkable == 1 ? '' : 'es'}'
    //     : 'You must attend $mustAttend more class${mustAttend == 1 ? '' : 'es'}';
    // final sub = simSafe
    //     ? bunkable == 0
    //           ? 'Attending more will give you breathing room.'
    //           : 'Skipping ${bunkable + 1} would drop you below 75%.'
    //     : 'Your attendance is currently below the 75% threshold.';
    final color = simSafe
        ? c.accentGreen
        : simWarning
        ? Colors.orange
        : c.accentRed;

    final icon = simSafe
        ? Icons.check_circle_rounded
        : simWarning
        ? Icons.warning_amber_rounded
        : Icons.dangerous_rounded;

    final title = simSafe
        ? bunkable == 0
              ? 'Right at the limit — don\'t miss any more'
              : 'You can bunk $bunkable more class${bunkable == 1 ? '' : 'es'}'
        : simWarning
        ? 'Penalty zone — attend $classesToClearPenalty more to clear it'
        : 'Detained risk — attend $mustAttend classes immediately';

    final sub = simSafe
        ? 'Above 85% — no penalty applies.'
        : simWarning
        ? 'Between 75–85%: you\'ll face a fee penalty this semester.'
        : 'Below 75%: you may be detained from exams.';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(AppDimens.radiusLg),
        border: Border.all(color: color.withOpacity(0.25)),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 18, color: color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: c.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(sub, style: TextStyle(fontSize: 12, color: c.textMuted)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Sim card ─────────────────────────────────────────────────────────────────

class _SimCard extends StatelessWidget {
  final String label;
  final String sublabel;
  final IconData icon;
  final Color iconColor;
  final VoidCallback onAdd;
  final VoidCallback onSubtract;
  final int count;
  final AppColorSchemeExt c;

  const _SimCard({
    required this.label,
    required this.sublabel,
    required this.icon,
    required this.iconColor,
    required this.onAdd,
    required this.onSubtract,
    required this.count,
    required this.c,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 12, 14),
      decoration: BoxDecoration(
        color: c.surfaceBg,
        borderRadius: BorderRadius.circular(AppDimens.radiusLg),
        border: Border.all(color: c.surfaceBorder),
      ),
      child: Row(
        children: [
          Icon(icon, size: 20, color: iconColor),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: c.textPrimary,
                  ),
                ),
                Text(
                  sublabel,
                  style: TextStyle(fontSize: 11, color: c.textMuted),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          // Counter
          Row(
            children: [
              _CircleButton(
                icon: Icons.remove_rounded,
                onTap: onSubtract,
                enabled: count > 0,
                c: c,
              ),
              SizedBox(
                width: 32,
                child: Text(
                  '$count',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: count > 0 ? iconColor : c.textMuted,
                  ),
                ),
              ),
              _CircleButton(
                icon: Icons.add_rounded,
                onTap: onAdd,
                enabled: true,
                c: c,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CircleButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final bool enabled;
  final AppColorSchemeExt c;

  const _CircleButton({
    required this.icon,
    required this.onTap,
    required this.enabled,
    required this.c,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: enabled ? c.surfaceBorder : c.surfaceBorder.withOpacity(0.4),
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          size: 16,
          color: enabled ? c.textPrimary : c.textSubtle,
        ),
      ),
    );
  }
}

// ─── Quick sim chips ──────────────────────────────────────────────────────────

class _QuickChips extends StatelessWidget {
  final void Function(int) onAttend;
  final void Function(int) onBunk;
  final AppColorSchemeExt c;

  const _QuickChips({
    required this.onAttend,
    required this.onBunk,
    required this.c,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        _chip(context, 'Attend 5', c.accentGreen, () => onAttend(5)),
        _chip(context, 'Attend 10', c.accentGreen, () => onAttend(10)),
        _chip(context, 'Attend 20', c.accentGreen, () => onAttend(20)),
        _chip(context, 'Bunk 5', c.accentRed, () => onBunk(5)),
        _chip(context, 'Bunk 10', c.accentRed, () => onBunk(10)),
        _chip(context, 'Bunk 20', c.accentRed, () => onBunk(20)),
        _chip(context, 'Bunk 2', c.accentRed, () => onBunk(2)),
      ],
    );
  }

  Widget _chip(
    BuildContext context,
    String label,
    Color color,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(AppDimens.radiusPill),
          border: Border.all(color: color.withOpacity(0.25)),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
      ),
    );
  }
}

// ─── Section label ────────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  final String label;
  final AppColorSchemeExt c;

  const _SectionLabel({required this.label, required this.c});

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        letterSpacing: 1.4,
        color: c.textMuted,
      ),
    );
  }
}
