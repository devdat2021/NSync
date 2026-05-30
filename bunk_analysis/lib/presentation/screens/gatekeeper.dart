import 'package:flutter/material.dart';
import '../../data/providers/portal_scrapper.dart';
import '../../core/security/credential_vault.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'login_screen.dart';
import 'dashboard_screen.dart';
import 'block_access.dart';
import '../../main.dart';
import 'onboarding.dart';

class SplashGatekeeper extends StatefulWidget {
  const SplashGatekeeper({super.key});

  @override
  State<SplashGatekeeper> createState() => _SplashGatekeeperState();
}

class _SplashGatekeeperState extends State<SplashGatekeeper> {
  @override
  void initState() {
    super.initState();

    checkLogin();
  }

  void goToOnboarding() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const OnboardingScreen()),
    );
  }

  Future<void> checkLogin() async {
    final prefs = await SharedPreferences.getInstance();
    final onboardingDone = prefs.getBool('onboarding_done') ?? false;
    if (!onboardingDone) {
      goToOnboarding();
      return;
    }
    final regno = await CredentialVault.getRegno();

    final password = await CredentialVault.getPassword();

    // NO SAVED LOGIN
    if (regno == null || password == null) {
      goToLogin();
      return;
    }

    // TRY SILENT LOGIN
    final api = PortalApi();

    final success = await api.login(regno: regno, password: password);

    // LOGIN SUCCESS
    if (success) {
      if (regno != '8660550205') {
        // if (regno.trim() != '9902471137' && regno.trim() != '8762926081') {
        goToDashboard();
      } else {
        CredentialVault.clearCredentials();
        goToBlockAccess();
      }
    }
    // LOGIN FAILED
    else {
      goToLogin();
    }
  }

  void goToLogin() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  void goToDashboard() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const HomePage(title: 'NSync')),
    );
  }

  void goToBlockAccess() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const BlockAccessScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}
