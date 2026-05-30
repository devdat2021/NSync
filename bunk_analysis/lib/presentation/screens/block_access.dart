import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import 'login_screen.dart';

class BlockAccessScreen extends StatelessWidget {
  const BlockAccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final c = AppColorSchemeExt.of(context);

    return Scaffold(
      backgroundColor: c.pageBg,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 460),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 84,
                    height: 84,
                    decoration: BoxDecoration(
                      color: c.accentRed.withOpacity(0.12),
                      shape: BoxShape.circle,
                      border: Border.all(color: c.accentRed.withOpacity(0.25)),
                    ),
                    child: Icon(
                      Icons.block_rounded,
                      size: 40,
                      color: c.accentRed,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Access denied',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.w800,
                      color: c.textPrimary,
                      letterSpacing: -0.6,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Your account is not permitted to use this app at the moment. If you think this is a mistake, please contact support.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      height: 1.5,
                      color: c.textMuted,
                    ),
                  ),
                  const SizedBox(height: 28),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: c.surfaceBg,
                      borderRadius: BorderRadius.circular(AppDimens.radiusLg),
                      border: Border.all(color: c.surfaceBorder),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _InfoRow(
                          icon: Icons.verified_user_outlined,
                          text: 'Only approved accounts can continue.',
                          c: c,
                        ),
                        const SizedBox(height: 12),
                        _InfoRow(
                          icon: Icons.support_agent_rounded,
                          text:
                              'Reach out to the app administrator for help. Devdat or Pramukh',
                          c: c,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const LoginScreen(),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: c.accentGreen,
                        foregroundColor: c.pageBg,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            AppDimens.radiusMd,
                          ),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        'Back to sign in',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.icon, required this.text, required this.c});

  final IconData icon;
  final String text;
  final AppColorSchemeExt c;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: c.accentRed),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: TextStyle(fontSize: 13, color: c.textPrimary, height: 1.4),
          ),
        ),
      ],
    );
  }
}
