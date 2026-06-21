import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../screens/login_screen.dart';
import '../../core/security/credential_vault.dart';
import '../../navbar.dart';
import '../../data/repositories/attendance_data.dart';
import '../../core/constants/app_colors.dart';
import '../../data/models/course_attendance.dart';
import '../../presentation/screens/widgets/attendance_card.dart';
import '../../data/providers/portal_scrapper.dart';
import '../../presentation/screens/widgets/overall_stats.dart';
// import '../../presentation/screens/widgets/appbar.dart';
import '../../presentation/screens/widgets/resources_card.dart';
import '../../utils/analytics.dart';
import '../../utils/update_alert.dart';

// ─── Placeholder courses ──────────────────────────────────────────────────────

List<CourseData> _Courses = [];

class HomePage extends StatefulWidget {
  const HomePage({super.key, required this.title});
  final String title;

  @override
  State<HomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<HomePage> {
  String _selectedSection = 'Home';
  String regno = '';
  String userName = '';
  String email = '';
  String usn = '';
  bool _loading = true;
  DateTime? lastUpdate;

  @override
  void initState() {
    super.initState();
    _loadprofile();
    _loadAttendance();
    _checkForUpdates();
  }

  Future<void> _checkForUpdates() async {
    final update = await UpdateService.checkForUpdates();

    if (!mounted || update == null) return;

    _showUpdateDialog(update);
  }

  Future<void> _loadAttendance() async {
    final cache = LocalCache();
    final shouldRefresh = await cache.shouldRefreshAttendance();
    final update = await LocalCache.getAttendanceLastUpdated();

    if (shouldRefresh) {
      // your existing API call that saves via LocalCache.saveAttendance(...)
      await _fetchAndSaveAttendance();
      await AnalyticsService.logAttendanceRefresh(forced: false);
    }

    final courses = await LocalCache.getParsedCourses();
    if (!mounted) return;
    setState(() {
      _Courses = courses;
      _loading = false;
      lastUpdate = update;
    });
  }

  void _showUpdateDialog(Map<String, dynamic> update) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('NSync ${update["latestVersion"]} Available'),

        content: SingleChildScrollView(child: Text(update["releaseNotes"])),

        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('Later'),
          ),

          TextButton(
            onPressed: () async {
              final uri = Uri.parse(update["releaseUrl"]);

              await launchUrl(uri, mode: LaunchMode.externalApplication);
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }

  Future<void> _loadprofile() async {
    final value = await CredentialVault.getRegno();
    final profile = await LocalCache.getProfile();
    if (!mounted) return;
    setState(() {
      regno = value ?? '';
      userName = profile != null ? profile["fname"] ?? 'XXX' : 'XXX';
      email = profile != null
          ? profile["strEmail"] ?? 'Error'
          : 'Not Displayed';
      usn = profile != null ? profile["strRegno"] ?? 'Error' : 'Not Displayed';
    });
  }

  Future<void> _fetchAndSaveAttendance() async {
    final reg = await CredentialVault.getRegno();
    final pass = await CredentialVault.getPassword();
    final api = PortalApi();
    bool success = false;
    try {
      success = await api.login(regno: reg ?? '', password: pass ?? '');
    } catch (e) {
      success = false;
    }
    if (success) {
      final attendance = await api.fetchAttendance();
      await LocalCache.saveAttendance(attendance.data);
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Error refreshing data')));
    }
  }

  void _selectSection(String section) {
    setState(() {
      _selectedSection = section;
    });
    Navigator.of(context).pop();
  }

  void _handleLogout() async {
    await AnalyticsService.logLogout();
    Navigator.of(context).pop();
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Logging off..')));
    CredentialVault.clearCredentials();
    LocalCache.clearCache();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  String _lastUpdatedLabel() {
    if (lastUpdate == null) return 'never synced';
    final diff = DateTime.now().difference(lastUpdate!).inMinutes;
    if (diff < 1) return 'updated just now';
    if (diff == 1) return 'updated 1 min ago';
    return 'updated $diff mins ago';
  }

  @override
  Widget build(BuildContext context) {
    final c = AppColorSchemeExt.of(context);
    return Scaffold(
      backgroundColor: c.pageBg,
      drawer: CustomSideBar(
        userName: userName,
        userEmail: email,
        userMobile: regno,
        usn: usn,
        onSectionSelected: _selectSection,
        onLogout: _handleLogout,
      ),
      appBar: AppBar(
        backgroundColor: c.surfaceBg,
        foregroundColor: c.textPrimary,

        title: Text(
          widget.title,
          style: AppTextStyles.appBarTitle.copyWith(color: c.textPrimary),
        ),
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: c.surfaceBorder),
        ),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    final c = AppColorSchemeExt.of(context);

    // Swap content based on selected sidebar section
    switch (_selectedSection) {
      case 'Home':
        return AttendanceView(
          onRefresh: () async {
            await AnalyticsService.logAttendanceRefresh(forced: true);
            await _loadAttendance();
          },
          courses: _Courses,
          topChildren: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
              child: Text(
                'Hey, $userName 👋',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: AppColorSchemeExt.of(context).textPrimary,
                  letterSpacing: -0.3,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: AttendanceSummaryCard(courses: _Courses),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
              child: ResourcesBanner(courses: _Courses),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'YOUR COURSES',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1.4,
                      color: c.textPrimary,
                    ),
                  ),
                  Text(
                    _lastUpdatedLabel(),
                    style: AppTextStyles.statLabel.copyWith(color: c.textMuted),
                  ),
                ],
              ),
            ),
          ],
        );
      default:
        return Center(
          child: Text(
            _selectedSection,
            style: TextStyle(color: c.textMuted, fontSize: 18),
          ),
        );
    }
  }
}
