// lib/presentation/screens/settings_screen.dart

import 'package:flutter/material.dart';
import '../../main.dart'; // for themeModeNotifier
import '../../core/constants/app_colors.dart';
import 'profile.dart';
import '../../utils/analytics.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    final c = AppColorSchemeExt.of(context);

    return Scaffold(
      backgroundColor: c.pageBg,
      appBar: AppBar(
        backgroundColor: c.surfaceBg,
        foregroundColor: c.textPrimary,
        elevation: 0,
        title: Text(
          'Settings',
          style: AppTextStyles.appBarTitle.copyWith(color: c.textPrimary),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: c.surfaceBorder),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ── Section: Appearance ──────────────────────────────────────
          _SectionHeader(label: 'Appearance', color: c.textMuted),
          const SizedBox(height: 8),

          _SettingsTile(
            icon: Icons.brightness_6_rounded,
            label: 'Dark mode',
            subtitle: 'Switch between light and dark theme',
            trailing: ValueListenableBuilder<ThemeMode>(
              valueListenable: themeModeNotifier,
              builder: (_, mode, __) {
                final isDark = mode == ThemeMode.dark;
                return _ThemeToggle(
                  isDark: isDark,
                  onChanged: (val) {
                    final newMode = val ? ThemeMode.dark : ThemeMode.light;
                    themeModeNotifier.value = newMode;
                    AnalyticsService.logThemeToggle(newMode.name);
                    // themeModeNotifier.value = val
                    //     ? ThemeMode.dark
                    //     : ThemeMode.light;
                    //     AnalyticsService.logThemeToggle(val.name);
                  },
                );
              },
            ),
          ),

          const SizedBox(height: 8),

          // Theme preview card
          ValueListenableBuilder<ThemeMode>(
            valueListenable: themeModeNotifier,
            builder: (_, mode, __) =>
                _ThemePreviewCard(isDark: mode == ThemeMode.dark, c: c),
          ),

          const SizedBox(height: 24),

          // ── Section: Account ─────────────────────────────────────────
          _SectionHeader(label: 'Account', color: c.textMuted),
          const SizedBox(height: 8),

          _SettingsTile(
            icon: Icons.person_outline_rounded,
            label: 'Profile',
            subtitle: 'View your account details',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ProfileScreen()),
              );
            },
          ),

          _SettingsTile(
            icon: Icons.lock_outline_rounded,
            label: 'Security',
            subtitle: 'Manage credentials',
            onTap: () => _showSecurityInfoDialog(context),
          ),

          const SizedBox(height: 24),

          // ── Section: About ───────────────────────────────────────────
          _SectionHeader(label: 'About', color: c.textMuted),
          const SizedBox(height: 8),

          _SettingsTile(
            icon: Icons.info_outline_rounded,
            label: 'App version',
            subtitle: '1.1.0',
            showChevron: false,
          ),
        ],
      ),
    );
  }
}

// ─── Section header ───────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final String label;
  final Color color;

  const _SectionHeader({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 4),
      child: Text(
        label.toUpperCase(),
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          letterSpacing: 1.2,
          color: color,
        ),
      ),
    );
  }
}

// ─── Settings tile ────────────────────────────────────────────────────────────

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;
  final bool showChevron;

  const _SettingsTile({
    required this.icon,
    required this.label,
    required this.subtitle,
    this.trailing,
    this.onTap,
    this.showChevron = true,
  });

  @override
  Widget build(BuildContext context) {
    final c = AppColorSchemeExt.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: c.surfaceBg,
        borderRadius: BorderRadius.circular(AppDimens.radiusLg),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppDimens.radiusLg),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppDimens.radiusLg),
              border: Border.all(color: c.surfaceBorder),
            ),
            child: Row(
              children: [
                // Icon container
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: c.surfaceBorder,
                    borderRadius: BorderRadius.circular(AppDimens.radiusMd),
                  ),
                  child: Icon(icon, size: 18, color: c.textMuted),
                ),
                const SizedBox(width: 12),
                // Text
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        label,
                        style: AppTextStyles.courseName.copyWith(
                          color: c.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: AppTextStyles.statLabel.copyWith(
                          color: c.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
                // Trailing widget or chevron
                if (trailing != null)
                  trailing!
                else if (showChevron)
                  Icon(
                    Icons.chevron_right_rounded,
                    size: 18,
                    color: c.textSubtle,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

void _showSecurityInfoDialog(BuildContext context) {
  final c = AppColorSchemeExt.of(context);

  showDialog<void>(
    context: context,
    builder: (dialogContext) {
      return AlertDialog(
        backgroundColor: c.surfaceBg,
        title: Text(
          'Security',
          style: AppTextStyles.appBarTitle.copyWith(color: c.textPrimary),
        ),
        content: Text(
          'Your credentials are securely stored locally with no outisde access and will clear from the device on logout',
          style: AppTextStyles.statLabel.copyWith(color: c.textMuted),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text('OK', style: TextStyle(color: c.accentGreen)),
          ),
        ],
      );
    },
  );
}

// ─── Theme toggle ─────────────────────────────────────────────────────────────

class _ThemeToggle extends StatelessWidget {
  final bool isDark;
  final ValueChanged<bool> onChanged;

  const _ThemeToggle({required this.isDark, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final c = AppColorSchemeExt.of(context);

    return GestureDetector(
      onTap: () => onChanged(!isDark),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        width: 56,
        height: 30,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          color: isDark ? c.accentGreen.withOpacity(0.2) : c.surfaceBorder,
          border: Border.all(
            color: isDark ? c.accentGreen : c.divider,
            width: 1.5,
          ),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Icons
            Positioned(
              left: 7,
              child: Icon(
                Icons.nightlight_round,
                size: 14,
                color: isDark ? c.accentGreen : c.textSubtle,
              ),
            ),
            Positioned(
              right: 7,
              child: Icon(
                Icons.wb_sunny_rounded,
                size: 14,
                color: isDark ? c.textSubtle : c.accentGreen,
              ),
            ),
            // Thumb
            AnimatedAlign(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeInOut,
              alignment: isDark ? Alignment.centerLeft : Alignment.centerRight,
              child: Padding(
                padding: const EdgeInsets.all(3),
                child: Container(
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isDark ? c.accentGreen : c.accentGreen,
                  ),
                  child: Icon(
                    isDark ? Icons.nightlight_round : Icons.wb_sunny_rounded,
                    size: 12,
                    color: c.pageBg,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Theme preview card ───────────────────────────────────────────────────────

class _ThemePreviewCard extends StatelessWidget {
  final bool isDark;
  final AppColorSchemeExt c;

  const _ThemePreviewCard({required this.isDark, required this.c});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: c.surfaceBg,
        borderRadius: BorderRadius.circular(AppDimens.radiusLg),
        border: Border.all(color: c.surfaceBorder),
      ),
      child: Row(
        children: [
          Icon(
            isDark ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
            size: 16,
            color: c.accentGreen,
          ),
          const SizedBox(width: 10),
          Text(
            isDark ? 'Dark theme active' : 'Light theme active',
            style: AppTextStyles.statLabel.copyWith(color: c.textMuted),
          ),
          const Spacer(),
          // Mini color swatches
          Row(
            children: [
              _Swatch(color: c.pageBg, border: c.divider),
              const SizedBox(width: 4),
              _Swatch(color: c.surfaceBg, border: c.divider),
              const SizedBox(width: 4),
              _Swatch(color: c.accentGreen),
              const SizedBox(width: 4),
              _Swatch(color: c.accentRed),
            ],
          ),
        ],
      ),
    );
  }
}

class _Swatch extends StatelessWidget {
  final Color color;
  final Color? border;

  const _Swatch({required this.color, this.border});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 16,
      height: 16,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(color: border ?? Colors.transparent, width: 1),
      ),
    );
  }
}
