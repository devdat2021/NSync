import 'package:dio/dio.dart';
import 'package:package_info_plus/package_info_plus.dart';

class UpdateService {
  static Future<Map<String, dynamic>?> checkForUpdates() async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();

      final currentVersion = packageInfo.version;

      final response = await Dio().get(
        'https://api.github.com/repos/devdat2021/NSync/releases/latest',
      );

      final latestVersion = response.data['tag_name'].toString().replaceFirst(
        'v',
        '',
      );

      final releaseNotes = response.data['body'] ?? '';

      final releaseUrl = response.data['html_url'];

      if (latestVersion != currentVersion) {
        return {
          'latestVersion': latestVersion,
          'releaseNotes': releaseNotes,
          'releaseUrl': releaseUrl,
        };
      }

      return null;
    } catch (e) {
      print(e);
      return null;
    }
  }
}
