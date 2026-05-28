import 'package:flutter/material.dart';

import '../../data/providers/portal_scrapper.dart';
import '../../core/security/credential_vault.dart';

import 'login_screen.dart';
import 'dashboard_screen.dart';
import '../../main.dart';

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

  Future<void> checkLogin() async {
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
      goToDashboard();
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

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}
