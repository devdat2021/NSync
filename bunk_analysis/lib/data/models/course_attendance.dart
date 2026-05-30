import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/threshold.dart';

class CourseData {
  final String id;
  final String name;
  final String code;
  final Color color;
  final int attended;
  final int total;

  const CourseData({
    required this.id,
    required this.name,
    required this.code,
    required this.color,
    required this.attended,
    required this.total,
  });

  double get percentage => total == 0 ? 0 : (attended / total) * 100;
  bool get isSafe => percentage >= AttendanceThresholds.safe;
  bool get isWarning =>
      percentage >= AttendanceThresholds.warning &&
      percentage < AttendanceThresholds.safe;
  bool get isAtRisk => percentage < AttendanceThresholds.warning;

  factory CourseData.fromJson(Map<String, dynamic> json, Color color) {
    final raw = json['fsubname'] as String;

    // "Design and Analysis of Algorithms - CS3004-1 - Practical"
    //  → name: "Design and Analysis of Algorithms"
    //  → code: "CS3004-1 · Practical"  (or just "CS3004-1")
    final parts = raw.split(' - ');
    final name = parts[0].trim();
    final codePart = parts.length > 1 ? parts[1].trim() : '';
    final suffix = parts.length > 2 ? parts[2].trim() : null;
    final code = suffix != null ? '$codePart · $suffix' : codePart;

    return CourseData(
      id: '${json['fsubcode']}_${code}', // unique even for lab duplicates
      name: name,
      code: code,
      color: color,
      attended: int.tryParse(json['attended'].toString()) ?? 0,
      total: int.tryParse(json['conducted'].toString()) ?? 0,
    );
  }
  int get bunkable {
    final max = (attended / 0.85).floor() - total;
    return max < 0 ? 0 : max;
  }

  int get mustAttend {
    final needed = ((0.85 * total) - attended) / 0.15;
    return needed.ceil().clamp(0, 999);
  }

  int get classesToClearPenalty {
    if (!isWarning) return 0;
    final needed = ((0.85 * total) - attended) / 0.15;
    return needed.ceil().clamp(0, 999);
  }

  static List<CourseData> parseCourses(List<dynamic> data) {
    // 1. Collect unique base codes in order of first appearance
    final seen = <String>[];
    for (final item in data) {
      final code = item['fsubcode'] as String;
      if (!seen.contains(code)) seen.add(code);
    }

    // 2. Build code → color map
    final palette = AppColors.courseColors;
    final colorMap = <String, Color>{};
    for (int i = 0; i < seen.length; i++) {
      colorMap[seen[i]] = palette[i % palette.length];
    }

    // 3. Map each entry
    return data
        .map(
          (item) => CourseData.fromJson(
            item as Map<String, dynamic>,
            colorMap[item['fsubcode']] ?? palette[0],
          ),
        )
        .toList();
  }
}
