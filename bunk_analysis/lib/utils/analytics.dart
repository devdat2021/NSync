// lib/core/services/analytics_service.dart

import 'package:firebase_analytics/firebase_analytics.dart';

class AnalyticsService {
  AnalyticsService._();
  static final _a = FirebaseAnalytics.instance;

  // ── Screen tracking ──────────────────────────────────────────────
  static Future<void> logScreen(String screenName) =>
      _a.logScreenView(screenName: screenName);

  // ── Auth events ──────────────────────────────────────────────────
  static Future<void> logLogin() =>
      _a.logLogin(loginMethod: 'portal_credentials');

  static Future<void> logLogout() => _a.logEvent(name: 'logout');

  // ── Attendance events ────────────────────────────────────────────
  static Future<void> logAttendanceRefresh({required bool forced}) =>
      _a.logEvent(
        name: 'attendance_refresh',
        parameters: {'forced': forced.toString()},
      );

  static Future<void> logCourseDetailView(String courseCode) => _a.logEvent(
    name: 'course_detail_view',
    parameters: {'course_code': courseCode},
  );

  static Future<void> logSimulatorUsed({
    required String courseCode,
    required int attendDelta,
    required int bunkDelta,
  }) => _a.logEvent(
    name: 'simulator_used',
    parameters: {
      'course_code': courseCode,
      'attend_delta': attendDelta,
      'bunk_delta': bunkDelta,
    },
  );

  // ── Theme ────────────────────────────────────────────────────────
  static Future<void> logThemeToggle(String mode) =>
      _a.logEvent(name: 'theme_toggle', parameters: {'mode': mode});
}
