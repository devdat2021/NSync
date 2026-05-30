// lib/core/constants/app_theme.dart or a new thresholds file

class AttendanceThresholds {
  AttendanceThresholds._();

  static const double safe = 85.0; // no penalty
  static const double warning = 75.0; // penalty zone
  // below 75 = at risk / detained
}
