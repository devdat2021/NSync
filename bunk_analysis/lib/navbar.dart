import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/gestures.dart';
import 'presentation/screens/settings.dart';
import 'presentation/screens/results.dart';
import 'presentation/screens/profile.dart';
import 'core/constants/app_colors.dart';

class CustomSideBar extends StatelessWidget {
  final String userName;
  final String userEmail;
  final String userMobile;
  final String usn;
  final ValueChanged<String> onSectionSelected;
  final VoidCallback onLogout;

  const CustomSideBar({
    super.key,
    required this.userName,
    required this.userEmail,
    required this.userMobile,
    required this.onSectionSelected,
    required this.usn,
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    // final colorScheme = Theme.of(context).colorScheme;

    return Drawer(
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(width: 10),
            Padding(
              padding: const EdgeInsets.fromLTRB(110, 16, 16, 0),
              child: Text(
                'Profile',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
              child: _buildProfileSection(context),
            ),
            const SizedBox(height: 8),
            const Divider(height: 0.5),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 8),
                children: [
                  _buildNavTile(
                    context,
                    icon: Icons.assessment_outlined,
                    title: 'Results',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const ResultsScreen(),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 8),
                  _buildNavTile(
                    context,
                    icon: Icons.settings_outlined,
                    title: 'Settings',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const SettingsScreen(),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 8),
                  _buildNavTile(
                    context,
                    icon: Icons.logout,
                    title: 'Logout',
                    iconColor: Colors.red,
                    onTap: onLogout,
                  ),
                  const SizedBox(height: 30),
                  const Divider(height: 0.5),
                  ListTile(
                    leading: const Icon(Icons.info_outline),
                    title: const Text('About'),
                    onTap: () {
                      Navigator.pop(context);
                      showAboutDialog(
                        context: context,
                        applicationName: 'NSync',
                        applicationVersion: '1.1.0',
                        children: [
                          Text.rich(
                            TextSpan(
                              style: Theme.of(context).textTheme.bodyMedium,
                              children: [
                                const TextSpan(text: 'Creators: '),
                                TextSpan(
                                  text: 'P Devdat ,',
                                  style: const TextStyle(
                                    color: Colors.blue,
                                    // decoration: TextDecoration.underline,
                                  ),
                                  recognizer: TapGestureRecognizer()
                                    ..onTap = () => launchUrl(
                                      Uri.parse(
                                        'https://github.com/devdat2021',
                                      ),
                                    ),
                                ),
                                TextSpan(
                                  text: ' Pramukh A Nayak',
                                  style: const TextStyle(
                                    color: Colors.blue,
                                    // decoration: TextDecoration.underline,
                                  ),
                                  recognizer: TapGestureRecognizer()
                                    ..onTap = () => launchUrl(
                                      Uri.parse(
                                        'https://github.com/pramukhnayak7',
                                      ),
                                    ),
                                ),
                                const TextSpan(text: '\nSource Code: '),
                                TextSpan(
                                  text: 'github.com/devdat2021/NSync/',
                                  style: const TextStyle(
                                    color: Colors.blue,
                                    decoration: TextDecoration.underline,
                                  ),
                                  recognizer: TapGestureRecognizer()
                                    ..onTap = () => launchUrl(
                                      Uri.parse(
                                        'https://github.com/devdat2021/NSync',
                                      ),
                                    ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 10),
                  _buildNavTile(
                    context,
                    icon: Icons.feedback_outlined,
                    title: 'Help & Feedback',
                    // iconColor: const Color.fromARGB(255, 0, 0, 0),
                    onTap: () => launchUrl(
                      Uri.parse('https://forms.gle/3HFozoqR4GytyTVU8'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileSection(BuildContext context) {
    final c = AppColorSchemeExt.of(context);

    final profileImageUrl =
        "https://university-student-photos.s3.ap-south-1.amazonaws.com/049/student_photos/$usn.JPG";

    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: c.surfaceBg,
        borderRadius: BorderRadius.circular(AppDimens.radiusLg),
        border: Border.all(color: c.surfaceBorder),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          // ── Header band ────────────────────────────────────────────────
          Container(
            height: 72,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  c.accentGreen.withOpacity(0.35),
                  c.accentGreen.withOpacity(0.05),
                ],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  // Decorative accent bar
                  Container(
                    width: 3,
                    height: 32,
                    decoration: BoxDecoration(
                      color: c.accentGreen,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'STUDENT',
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 2.5,
                          color: c.accentGreen,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'NMAMIT, Nitte',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: c.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // ── Photo + name ───────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 20),
            child: Column(
              children: [
                // Pull photo up to overlap the header band
                Transform.translate(
                  offset: const Offset(0, -28),
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: c.accentGreen, width: 2.5),
                      boxShadow: [
                        BoxShadow(
                          color: c.accentGreen.withOpacity(0.25),
                          blurRadius: 16,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(13.5),
                      child: Image.network(
                        profileImageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          color: c.surfaceBorder,
                          child: Icon(
                            Icons.person_rounded,
                            color: c.textMuted,
                            size: 36,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                // Compensate for the translate offset
                Transform.translate(
                  offset: const Offset(0, -20),
                  child: Column(
                    children: [
                      // Name
                      Text(
                        userName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                          color: c.textPrimary,
                          letterSpacing: -0.3,
                        ),
                      ),

                      const SizedBox(height: 6),

                      // USN pill
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: c.accentGreen.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(
                            AppDimens.radiusPill,
                          ),
                          border: Border.all(
                            color: c.accentGreen.withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                        child: Text(
                          usn,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: c.accentGreen,
                            letterSpacing: 0.8,
                            fontFamily: 'monospace',
                          ),
                        ),
                      ),

                      const SizedBox(height: 18),

                      // ── Credential rows ────────────────────────────────
                      _buildCredentialRow(
                        icon: Icons.email_outlined,
                        label: userEmail,
                        c: c,
                      ),
                      const SizedBox(height: 10),
                      _buildCredentialRow(
                        icon: Icons.phone_outlined,
                        label: userMobile,
                        c: c,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCredentialRow({
    required IconData icon,
    required String label,
    required AppColorSchemeExt c,
  }) {
    return Row(
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: c.surfaceBorder,
            borderRadius: BorderRadius.circular(AppDimens.radiusSm),
          ),
          child: Icon(icon, size: 14, color: c.textMuted),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            label,
            style: AppTextStyles.statLabel.copyWith(
              color: c.textMuted,
              fontSize: 12,
            ),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        ),
      ],
    );
  }

  Widget _buildNavTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color? iconColor,
  }) {
    return ListTile(
      leading: Icon(icon, color: iconColor),
      title: Text(title),
      onTap: onTap,
    );
  }
}
