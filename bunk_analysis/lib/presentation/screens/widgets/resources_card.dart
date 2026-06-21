import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../under_development.dart';
import '../materials.dart';
import '../../../data/repositories/attendance_data.dart';
import '/../data/models/course_attendance.dart';

class ResourcesBanner extends StatelessWidget {
  final List<CourseData> courses;
  const ResourcesBanner({super.key, required this.courses});

  @override
  Widget build(BuildContext context) {
    final c = AppColorSchemeExt.of(context);

    return GestureDetector(
      onTap: () {
        final courseNames = courses.map((course) => course.name).toList();
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ResourcesView(courseNames: courseNames),
          ),
        );
      },
      // onTap: () {
      //   Navigator.push(
      //     context,
      //     MaterialPageRoute(builder: (_) => const ResourcesView()),
      //   );
      //   // Navigator.push(
      //   //   context,
      //   //   MaterialPageRoute(builder: (_) => const UnderDevelopmentPage()),
      //   // );
      // },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: c.surfaceBg,
          borderRadius: BorderRadius.circular(AppDimens.radiusLg),
          border: Border.all(color: c.surfaceBorder),
        ),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: c.accentGreen.withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppDimens.radiusMd),
                border: Border.all(color: c.accentGreen.withOpacity(0.25)),
              ),
              child: Icon(
                Icons.menu_book_rounded,
                size: 18,
                color: c.accentGreen,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'PYQs & Resources',
                    style: AppTextStyles.courseName.copyWith(
                      color: c.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Browse materials for your courses',
                    style: AppTextStyles.statLabel.copyWith(color: c.textMuted),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_rounded, size: 16, color: c.textSubtle),
          ],
        ),
      ),
    );
  }
}
