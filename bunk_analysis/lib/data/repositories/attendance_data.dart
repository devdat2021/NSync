import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/models/course_attendance.dart';

class LocalCache {
  // PROFILE ----------------------------

  static Future<void> saveProfile(dynamic profileData) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('profile_cache', profileData.toString());
  }

  static Future<dynamic> getProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString('profile_cache');

    if (data == null) return null;

    return jsonDecode(data);
  }

  static Future<String> getUSN() async {
    final profile = await getProfile();
    String _get(String key, [String fallback = '—']) =>
        profile[key]?.toString().isNotEmpty == true
        ? profile[key].toString()
        : fallback;
    return _get('strRegno');
  }

  // ATTENDANCE ----------------------------

  static Future<void> saveAttendance(dynamic attendanceData) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('attendance_cache', jsonEncode(attendanceData));

    // SAVE TIMESTAMP
    await prefs.setInt(
      'attendance_last_updated',
      DateTime.now().millisecondsSinceEpoch,
    );
  }

  static Future<dynamic> getAttendance() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString('attendance_cache');

    if (data == null) return null;

    var decoded = jsonDecode(data);

    if (decoded is String) {
      decoded = jsonDecode(decoded);
    }

    return decoded;
  }

  static Future<DateTime?> getAttendanceLastUpdated() async {
    final prefs = await SharedPreferences.getInstance();
    final timestamp = prefs.getInt('attendance_last_updated');

    if (timestamp == null) return null;

    return DateTime.fromMillisecondsSinceEpoch(timestamp);
  }

  static Future<void> clearCache() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.clear();
  }

  Future<bool> shouldRefreshAttendance() async {
    final lastUpdated = await LocalCache.getAttendanceLastUpdated();

    if (lastUpdated == null) {
      return true;
    }

    final difference = DateTime.now().difference(lastUpdated);
    return difference.inMinutes >= 60;
  }

  // Add this to your LocalCache class
  static Future<List<CourseData>> getParsedCourses() async {
    final raw = await getAttendance();

    if (raw == null) return [];

    print(raw.runtimeType); // should be Map<String, dynamic>

    final list = raw['data'] as List<dynamic>? ?? [];

    return CourseData.parseCourses(list);
  }
}
