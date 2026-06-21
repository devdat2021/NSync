// lib/core/services/resource_service.dart

import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/resources.dart';

class ResourceService {
  static final _supabase = Supabase.instance.client;
  static Future<List<ResourceData>> fetchForCourseName(
    String courseName,
  ) async {
    final response = await _supabase.rpc(
      'match_notes',
      params: {'course_name': courseName},
    );
    print('Response: $response');

    return (response as List).map((e) => ResourceData.fromJson(e)).toList();
  }

  static Future<List<ResourceData>> fetchForAllCourses(
    List<String> courseNames,
  ) async {
    final results = <ResourceData>[];
    for (final name in courseNames) {
      final matches = await fetchForCourseName(name);
      results.addAll(matches);
    }
    final seen = <String>{};
    return results.where((r) => seen.add(r.id)).toList();
  }

  static Future<String?> getSignedUrl(String filePath) async {
    try {
      final response = await _supabase.functions.invoke(
        'get-signed-url',
        body: {'file_path': filePath},
      );
      return response.data['url'] as String?;
    } catch (e) {
      return null;
    }
  }
}
