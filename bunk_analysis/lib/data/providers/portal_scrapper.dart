import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:cookie_jar/cookie_jar.dart';
import '../models/result_model.dart';
import '../repositories/result_data.dart';
import '../../core/security/credential_vault.dart';

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
        try {
          final parsed = json.decode(resp);
          if (parsed is Map) map = Map<String, dynamic>.from(parsed);
          if (parsed is List && parsed.isNotEmpty && parsed[0] is Map) {
            map = Map<String, dynamic>.from(parsed[0]);
          }
        } catch (e) {
          // Not JSON: log and return false
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

  // Future<List<SemesterSummary>> fetchAllResults(String usn) async {
  //   final response = await dio.get(
  //     '/src/results_new.php',
  //     queryParameters: {'a': 'getResAll', 'UNIVCODE': '049', 'REGNO': usn},
  //   );

  //   print('REQUEST URL: ${response.requestOptions.uri}'); // ← add this
  //   print('RAW RESPONSE: ${response.data}');

  //   final raw = response.data;
  //   final json = raw is String ? jsonDecode(raw) : raw;

  //   final data = json['data'] as List<dynamic>;
  //   return data.map((e) => SemesterSummary.fromJson(e)).toList();
  // }
  Future<List<SemesterSummary>> fetchAllResults() async {
    // final response = await dio.get('/src/results_new.php?a=getResAll');

    // print(response.data);
    // print(response.data.runtimeType);
    final response = await dio.get(
      'https://studentportal.universitysolutions.in/src/results_new.php',
      queryParameters: {
        'a': 'getResAll',
        'UNIVCODE': '049',
        'REGNO': 'NNM24IS145',
      },
    );

    print(response.requestOptions.uri);
    print(response.data);
    final json = response.data is String
        ? jsonDecode(response.data)
        : response.data;

    print(json.runtimeType);
    print(json['data'].runtimeType);

    final data = json['data'] as List<dynamic>;
    return data.map((e) => SemesterSummary.fromJson(e)).toList();
  }
  // Future<List<SemesterSummary>> fetchAllResults() async {
  //   final response = await dio.get('/src/results_new.php?a=getResAll');
  //   final data = response.data['data'] as List<dynamic>;
  //   return data.map((e) => SemesterSummary.fromJson(e)).toList();
  // }

  Future<List<SubjectResult>> fetchSemesterDetail(
    String examNo,
    String regno,
  ) async {
    final response = await dio.get(
      '/src/results_new.php?a=getResDet&examno=$examNo&regno=$regno',
    );
    final json = response.data is String
        ? jsonDecode(response.data)
        : response.data;

    final data = json['data'] as Map<String, dynamic>;
    return parseSubjectResults(data);
  }
}
