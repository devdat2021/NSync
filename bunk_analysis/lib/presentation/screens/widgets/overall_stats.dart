import 'package:flutter/material.dart';
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
    // In AttendanceSummaryCard

    final atRisk = courses.where((c) => c.isAtRisk).length;
    final inPenalty = courses.where((c) => c.isWarning).length;
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
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 5),
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
              // Right side of summary card
              // Column(
              //   crossAxisAlignment: CrossAxisAlignment.end,
              //   children: [
              //     // At risk row
              //     Row(
              //       mainAxisSize: MainAxisSize.min,
              //       crossAxisAlignment: CrossAxisAlignment.baseline,
              //       textBaseline: TextBaseline.alphabetic,
              //       children: [
              //         Text(
              //           '$atRisk',
              //           style: TextStyle(
              //             fontSize: 24,
              //             fontWeight: FontWeight.w800,
              //             color: atRisk > 0 ? c.accentRed : c.textMuted,
              //             height: 1.0,
              //           ),
              //         ),
              //         const SizedBox(width: 4),
              //         Text(
              //           'at risk',
              //           style: TextStyle(fontSize: 11, color: c.textMuted),
              //         ),
              //       ],
              //     ),
              //     const SizedBox(height: 4),
              //     // Penalty row
              //     Row(
              //       mainAxisSize: MainAxisSize.min,
              //       crossAxisAlignment: CrossAxisAlignment.baseline,
              //       textBaseline: TextBaseline.alphabetic,
              //       children: [
              //         Text(
              //           '$inPenalty',
              //           style: TextStyle(
              //             fontSize: 24,
              //             fontWeight: FontWeight.w800,
              //             color: inPenalty > 0 ? Colors.orange : c.textMuted,
              //             height: 1.0,
              //           ),
              //         ),
              //         const SizedBox(width: 4),
              //         Text(
              //           'penalty',
              //           style: TextStyle(fontSize: 11, color: c.textMuted),
              //         ),
              //       ],
              //     ),
              //   ],
              // ),
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
                  // 75% tick (danger)
                  Positioned(
                    left: barWidth * 0.75 - 0.75,
                    top: -4,
                    child: Container(
                      width: 1.5,
                      height: 16,
                      color: c.accentRed.withOpacity(0.5),
                    ),
                  ),
                  // 85% tick (safe)
                  Positioned(
                    left: barWidth * 0.85 - 0.75,
                    top: -4,
                    child: Container(
                      width: 1.5,
                      height: 16,
                      color: c.accentGreen.withOpacity(0.6),
                    ),
                  ),
                  // 75% tick
                  // Positioned(
                  //   left: barWidth * 0.75 - 0.5,
                  //   top: -3,
                  //   child: Container(
                  //     width: 1.5,
                  //     height: 12,
                  //     decoration: BoxDecoration(
                  //       color: Colors.white.withOpacity(0.35),
                  //       borderRadius: BorderRadius.circular(1),
                  //     ),
                  //   ),
                  // ),
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
