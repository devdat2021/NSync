import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:cookie_jar/cookie_jar.dart';

class PortalApi {
  late Dio dio;

  PortalApi() {
    dio = Dio(
      BaseOptions(
        baseUrl: 'https://studentportal.universitysolutions.in',
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
      ),
    );

    dio.interceptors.add(CookieManager(CookieJar()));
  }

  Future<bool> login({required String regno, required String password}) async {
    try {
      final response = await dio.post(
        '/signin.php',
        data: {'regno': regno, 'passwd': password},
      );

      final dynamic resp = response.data;

      Map<String, dynamic>? map;

      if (resp is Map) {
        map = Map<String, dynamic>.from(resp);
      } else if (resp is String) {
        // Some servers return JSON as a String or return HTML — try to decode JSON
        try {
          final parsed = json.decode(resp);
          if (parsed is Map) map = Map<String, dynamic>.from(parsed);
          if (parsed is List && parsed.isNotEmpty && parsed[0] is Map) {
            map = Map<String, dynamic>.from(parsed[0]);
          }
        } catch (e) {
          // Not JSON - log and return false
          print(
            'PortalApi.login: non-JSON response: ${resp.substring(0, resp.length > 200 ? 200 : resp.length)}',
          );
          return false;
        }
      } else if (resp is List && resp.isNotEmpty && resp[0] is Map) {
        map = Map<String, dynamic>.from(resp[0]);
      }

      if (map == null) {
        print('PortalApi.login: unexpected response type: ${resp.runtimeType}');
        return false;
      }

      // Accept numeric or string error_code, and tolerate alternative keys
      final dynamic errorCode =
          map['error_code'] ?? map['error'] ?? map['status'];
      if (errorCode == null) {
        print('PortalApi.login: no error_code in response: $map');
        return false;
      }

      final codeStr = errorCode.toString();
      return codeStr == '0' ||
          codeStr.toLowerCase() == 'success' ||
          codeStr == '200';
    } catch (e) {
      print(e);
      return false;
    }
  }

  Future<Response> profile() async {
    return await dio.post('/src/profile.php');
  }

  Future<Response> fetchAttendance() async {
    String today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    return await dio.get(
      '/app.php',
      queryParameters: {
        'a': 'viewAttendanceDetsummary',
        'univcode': '049',
        'date': today,
      },
    );
  }
}
