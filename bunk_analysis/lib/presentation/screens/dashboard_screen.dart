import 'package:flutter/material.dart';
import '../screens/login_screen.dart';
import '../../core/security/credential_vault.dart';
import '../../navbar.dart';
import '../../data/repositories/attendance_data.dart';
import '../../core/constants/app_colors.dart';
import '../../data/models/course_attendance.dart';
import '../../presentation/screens/widgets/attendance_card.dart';
import '../../data/providers/portal_scrapper.dart';
// ─── Placeholder courses ──────────────────────────────────────────────────────

List<CourseData> _placeholderCourses = [];

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

  @override
  void initState() {
    super.initState();
    _loadprofile();
    _loadAttendance();
  }

  Future<void> _loadAttendance() async {
    final cache = LocalCache();
    final shouldRefresh = await cache.shouldRefreshAttendance();

    if (shouldRefresh) {
      // your existing API call that saves via LocalCache.saveAttendance(...)
      await _fetchAndSaveAttendance();
    }

    final courses = await LocalCache.getParsedCourses();
    if (!mounted) return;
    setState(() {
      _placeholderCourses = courses;
      _loading = false;
    });
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

  void _handleLogout() {
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
          courses: _placeholderCourses,
          topChildren: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: AttendanceSummaryCard(courses: _placeholderCourses),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Text(
                'YOUR COURSES',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.4,
                ),
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
