import 'package:flutter/material.dart'; // ─── Attendance list view ─────────────────────────────────────────────────────
import '../../../data/models/course_attendance.dart';
import '../../../core/constants/app_colors.dart';
import '../course_detail.dart';
import '../../../utils/analytics.dart';

class AttendanceView extends StatelessWidget {
  final List<CourseData> courses;
  final List<Widget> topChildren;
  final Future<void> Function() onRefresh;

  const AttendanceView({
    super.key,
    required this.courses,
    required this.onRefresh,
    this.topChildren = const [],
  });

  @override
  Widget build(BuildContext context) {
    final c = AppColorSchemeExt.of(context);
    return RefreshIndicator(
      onRefresh: onRefresh,
      color: c.accentGreen,
      backgroundColor: c.surfaceBg,
      child: CustomScrollView(
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
                    AnalyticsService.logCourseDetailView(courses[index].code);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            CourseDetailScreen(course: courses[index]),
                      ),
                    );
                  },
                ),
                childCount: courses.length,
              ),
            ),
          ),
        ],
      ),
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
                      label: safe ? 'can skip' : 'must go',
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
                                    colors: course.isSafe
                                        ? [course.color, c.accentGreen]
                                        : course.isWarning
                                        ? [Colors.orange, course.color]
                                        : [c.accentRed, course.color],
                                    // colors: safe
                                    //     ? [course.color, c.accentGreen]
                                    //     : [c.accentRed, course.color],
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
    final sign = pct >= 75 ? (pct >= 85 ? 'Safe' : 'Moderate') : 'Risky';
    final color = pct >= 85
        ? c.accentGreen
        : pct >= 75
        ? Colors.orange
        : c.accentRed;
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
