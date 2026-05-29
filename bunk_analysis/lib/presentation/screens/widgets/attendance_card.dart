import 'package:flutter/material.dart'; // ─── Attendance list view ─────────────────────────────────────────────────────
import '../../../data/models/course_attendance.dart';
import '../../../core/constants/app_colors.dart';

class AttendanceSummaryCard extends StatelessWidget {
  final List<CourseData> courses;

  const AttendanceSummaryCard({super.key, required this.courses});

  @override
  Widget build(BuildContext context) {
    final c = AppColorSchemeExt.of(context);

    // ── Aggregates ──────────────────────────────────────────────────
    final totalAttended = courses.fold(0, (sum, c) => sum + c.attended);
    final totalConducted = courses.fold(0, (sum, c) => sum + c.total);
    final overallPct = totalConducted == 0
        ? 0.0
        : totalAttended / totalConducted * 100;
    final atRisk = courses.where((c) => !c.isSafe).length;
    final progressFraction = (overallPct / 100).clamp(0.0, 1.0);
    final isSafe = overallPct >= 75;

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 16),
      decoration: BoxDecoration(
        color: c.surfaceBg,
        borderRadius: BorderRadius.circular(AppDimens.radiusLg),
        border: Border.all(color: c.surfaceBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Row 1: label + at-risk badge ──────────────────────────
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Left: label + big percentage
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Overall attendance',
                      style: AppTextStyles.statLabel.copyWith(
                        color: c.textMuted,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${overallPct.toStringAsFixed(1)}%',
                      style: TextStyle(
                        fontSize: 38,
                        fontWeight: FontWeight.w800,
                        color: c.textPrimary,
                        height: 1.0,
                        letterSpacing: -1,
                      ),
                    ),
                  ],
                ),
              ),

              // Right: at-risk count
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '$atRisk',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      color: atRisk > 0 ? c.accentRed : c.textMuted,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'courses at risk',
                    style: AppTextStyles.statLabel.copyWith(
                      color: c.textMuted,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 14),

          // ── Progress bar ──────────────────────────────────────────
          LayoutBuilder(
            builder: (context, constraints) {
              final barWidth = constraints.maxWidth;
              return Stack(
                clipBehavior: Clip.none,
                children: [
                  // Track
                  ClipRRect(
                    borderRadius: BorderRadius.circular(99),
                    child: Container(
                      height: 6,
                      color: Colors.white.withOpacity(0.05),
                      child: FractionallySizedBox(
                        alignment: Alignment.centerLeft,
                        widthFactor: progressFraction,
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: isSafe
                                  ? [
                                      c.accentGreen.withOpacity(0.6),
                                      c.accentGreen,
                                    ]
                                  : [c.accentRed, c.accentRed.withOpacity(0.7)],
                            ),
                            borderRadius: BorderRadius.circular(99),
                          ),
                        ),
                      ),
                    ),
                  ),
                  // 75% tick
                  Positioned(
                    left: barWidth * 0.75 - 0.5,
                    top: -3,
                    child: Container(
                      width: 1.5,
                      height: 12,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.35),
                        borderRadius: BorderRadius.circular(1),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),

          const SizedBox(height: 10),

          // ── Row 3: classes count + min label ─────────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '$totalAttended/$totalConducted classes',
                style: AppTextStyles.statLabel.copyWith(color: c.textMuted),
              ),
              Text(
                'min 75%',
                style: AppTextStyles.statLabel.copyWith(color: c.textSubtle),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class AttendanceView extends StatelessWidget {
  final List<CourseData> courses;
  final List<Widget> topChildren;

  const AttendanceView({
    super.key,
    required this.courses,
    this.topChildren = const [],
  });

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        for (final child in topChildren) SliverToBoxAdapter(child: child),
        SliverPadding(
          padding: EdgeInsets.fromLTRB(
            16,
            topChildren.isEmpty ? 16 : 8,
            16,
            32,
          ),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) => CourseTile(
                course: courses[index],
                onTap: () {
                  // TODO: Navigator.push to CourseDetailPage
                },
              ),
              childCount: courses.length,
            ),
          ),
        ),
      ],
    );
  }
}

// ─── Course tile ──────────────────────────────────────────────────────────────

class CourseTile extends StatelessWidget {
  final CourseData course;
  final VoidCallback? onTap;

  const CourseTile({super.key, required this.course, this.onTap});

  @override
  Widget build(BuildContext context) {
    final c = AppColorSchemeExt.of(context);
    final pct = course.percentage;
    final safe = course.isSafe;
    final borderColor = Border.all(color: c.surfaceBorder);
    // const accentGreen = Color(0xFFC8FF47);
    // const accentRed = Color(0xFFFF4D6A);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: c.surfaceBg,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          splashColor: course.color.withOpacity(0.08),
          highlightColor: course.color.withOpacity(0.04),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: borderColor,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header row
                Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: course.color.withOpacity(0.094),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Center(
                        child: Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            color: course.color,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            course.name,
                            style: AppTextStyles.courseName.copyWith(
                              color: c.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            course.code,
                            style: TextStyle(
                              fontSize: 12,
                              color: c.textMuted,
                              fontFamily: 'monospace',
                            ),
                          ),
                        ],
                      ),
                    ),
                    _AttendancePill(
                      attended: course.attended,
                      total: course.total,
                    ),
                    const SizedBox(width: 6),
                    Icon(
                      Icons.chevron_right_rounded,
                      size: 16,
                      color: c.textSubtle,
                    ),
                  ],
                ),

                const SizedBox(height: 14),

                // Stat row
                Row(
                  children: [
                    _StatCell(
                      value: '${pct.toStringAsFixed(0)}%',
                      label: 'attendance',
                    ),
                    _VerticalDivider(),
                    _StatCell(
                      value: '${course.attended}',
                      valueSuffix: '/${course.total}',
                      label: 'classes',
                    ),
                    _VerticalDivider(),
                    _StatCell(
                      value: safe
                          ? (course.bunkable == 0 ? '0' : '+${course.bunkable}')
                          : '-${course.mustAttend}',
                      label: safe ? 'can bunk' : 'must go',
                      valueColor: safe ? c.accentGreen : c.accentRed,
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // Progress bar
                LayoutBuilder(
                  builder: (context, constraints) {
                    final barWidth = constraints.maxWidth;
                    return Stack(
                      clipBehavior: Clip.none,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(99),
                          child: Container(
                            height: 6,
                            color: c.divider,
                            child: FractionallySizedBox(
                              alignment: Alignment.centerLeft,
                              widthFactor: (pct / 100).clamp(0.0, 1.0),
                              child: Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: safe
                                        ? [course.color, c.accentGreen]
                                        : [c.accentRed, course.color],
                                  ),
                                  borderRadius: BorderRadius.circular(99),
                                ),
                              ),
                            ),
                          ),
                        ),
                        // 75% tick — pixel-perfect via LayoutBuilder
                        Positioned(
                          left: barWidth * 0.75 - 0.5,
                          top: -2,
                          child: Container(width: 1, height: 10, color: c.tick),
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Pill ─────────────────────────────────────────────────────────────────────

class _AttendancePill extends StatelessWidget {
  final int attended;
  final int total;

  const _AttendancePill({required this.attended, required this.total});

  @override
  Widget build(BuildContext context) {
    final pct = total == 0 ? 0.0 : attended / total * 100;
    final c = AppColorSchemeExt.of(context);
    final safe = pct >= 75;
    final color = safe ? c.accentGreen : c.accentRed;
    final sign = safe
        ? pct >= 85
              ? "Safe"
              : "Moderate"
        : "Risky";
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        // '${pct.toStringAsFixed(0)}%',
        '$sign',
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}

// ─── Stat cell ────────────────────────────────────────────────────────────────

class _StatCell extends StatelessWidget {
  final String value;
  final String? valueSuffix;
  final String label;
  final Color? valueColor;

  const _StatCell({
    required this.value,
    this.valueSuffix,
    required this.label,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    final c = AppColorSchemeExt.of(context);

    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: value,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: valueColor ?? c.textPrimary,
                  ),
                ),
                if (valueSuffix != null)
                  TextSpan(
                    text: valueSuffix,
                    style: TextStyle(fontSize: 14, color: c.textMuted),
                  ),
              ],
            ),
          ),
          Text(label, style: TextStyle(fontSize: 11, color: c.textMuted)),
        ],
      ),
    );
  }
}

// ─── Vertical divider ─────────────────────────────────────────────────────────

class _VerticalDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final c = AppColorSchemeExt.of(context);
    return Container(
      width: 1,
      height: 32,
      margin: const EdgeInsets.symmetric(horizontal: 12),
      color: c.divider,
    );
  }
}
