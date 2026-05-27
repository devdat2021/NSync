import 'package:flutter/material.dart';

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
    final colorScheme = Theme.of(context).colorScheme;

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
              child: _buildProfileSection(context, colorScheme),
            ),

            const SizedBox(height: 8),
            const Divider(height: 1),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 8),
                children: [
                  _buildNavTile(
                    context,
                    icon: Icons.settings_outlined,
                    title: 'Settings',
                    onTap: () => onSectionSelected('Settings'),
                  ),
                  const SizedBox(height: 8),
                  _buildNavTile(
                    context,
                    icon: Icons.logout,
                    title: 'Logout',
                    iconColor: Colors.red,
                    onTap: onLogout,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileSection(BuildContext context, ColorScheme colorScheme) {
    final textTheme = Theme.of(context).textTheme;
    String? profileImageUrl =
        "https://university-student-photos.s3.ap-south-1.amazonaws.com/049/student_photos/$usn.JPG";

    return Card(
      elevation: 2,
      color: colorScheme.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 40,
              backgroundColor: colorScheme.surface,
              backgroundImage: NetworkImage(profileImageUrl),
            ),
            const SizedBox(height: 16),
            Text(
              userName,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: textTheme.titleMedium?.copyWith(
                fontSize: 19,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 10),
            _buildCredentialRow(
              icon: Icons.email_outlined,
              label: userEmail,
              colorScheme: colorScheme,
              context: context,
            ),
            const SizedBox(height: 6),
            _buildCredentialRow(
              icon: Icons.phone_outlined,
              label: userMobile,
              colorScheme: colorScheme,
              context: context,
            ),
            const SizedBox(height: 6),
            _buildCredentialRow(
              icon: Icons.badge,
              label: usn,
              colorScheme: colorScheme,
              context: context,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCredentialRow({
    required BuildContext context,
    required ColorScheme colorScheme,
    required IconData icon,
    required String label,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: colorScheme.surface.withOpacity(0.7),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: colorScheme.primary),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: Colors.grey[800],
              ),
            ),
          ),
        ],
      ),
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
