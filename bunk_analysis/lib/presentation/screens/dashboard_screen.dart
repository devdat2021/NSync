import 'package:flutter/material.dart';
import '../screens/login_screen.dart';
import '../../core/security/credential_vault.dart';
import '../../navbar.dart';
import '../../data/repositories/attendance_data.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key, required this.title});
  final String title;

  @override
  State<HomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<HomePage> {
  String _selectedSection = 'Home';
  String regno = '';
  String Name = '';
  String email = '';
  String usn = '';

  @override
  void initState() {
    super.initState();
    _loadprofile();
  }

  Future<void> _loadprofile() async {
    final value = await CredentialVault.getRegno();
    final profile = await LocalCache.getProfile();
    if (!mounted) return;
    print(profile);
    print(profile.runtimeType);
    setState(() {
      regno = value ?? '';
      Name = profile != null ? profile["fname"] ?? 'XXX' : 'XXX';
      email = profile != null
          ? profile["strEmail"] ?? 'Error'
          : 'Not Displayed';
      usn = profile != null ? profile["strRegno"] ?? 'Error' : 'Not Displayed';
    });
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
    return Scaffold(
      drawer: CustomSideBar(
        userName: Name,
        userEmail: email,
        userMobile: regno,
        usn: usn,
        onSectionSelected: _selectSection,
        onLogout: _handleLogout,
      ),
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              _selectedSection,
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 12),
            const Text('Use the hamburger menu to open the sidebar.'),
          ],
        ),
      ),
    );
  }
}
