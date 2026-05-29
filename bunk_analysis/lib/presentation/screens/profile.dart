// lib/presentation/screens/profile_screen.dart

import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../core/constants/app_colors.dart';
import '../../data/repositories/attendance_data.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Map<String, dynamic>? _profile;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final profile = await LocalCache.getProfile();
    if (!mounted) return;
    setState(() {
      _profile = profile;
      _loading = false;
    });
  }

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
          'Profile',
          style: AppTextStyles.appBarTitle.copyWith(color: c.textPrimary),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: c.surfaceBorder),
        ),
      ),
      body: _loading
          ? Center(child: CircularProgressIndicator(color: c.accentGreen))
          : _profile == null
          ? Center(
              child: Text(
                'Could not load profile.',
                style: AppTextStyles.statLabel.copyWith(color: c.textMuted),
              ),
            )
          : _ProfileBody(profile: _profile!),
    );
  }
}

// ─── Body ─────────────────────────────────────────────────────────────────────

class _ProfileBody extends StatelessWidget {
  final Map<String, dynamic> profile;
  const _ProfileBody({required this.profile});

  String _get(String key, [String fallback = '—']) =>
      profile[key]?.toString().isNotEmpty == true
      ? profile[key].toString()
      : fallback;

  @override
  Widget build(BuildContext context) {
    final c = AppColorSchemeExt.of(context);

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 32),
      children: [
        // ── Avatar + name hero ─────────────────────────────────────────
        _AvatarHero(
          photoUrl: _get('photopath'),
          name: _get('fname'),
          usn: _get('strRegno'),
          degree: _get('degree'),
          c: c,
        ),

        const SizedBox(height: 24),

        // ── Exam banner ────────────────────────────────────────────────
        // _ExamBanner(
        //   examName: _get('fexamname'),
        //   examDate: _get('fexamdate'),
        //   c: c,
        // ),
        const SizedBox(height: 24),

        // ── Personal details ───────────────────────────────────────────
        _SectionHeader(label: 'Personal', c: c),
        const SizedBox(height: 8),
        _InfoCard(
          rows: [
            _InfoRow(
              icon: Icons.badge_outlined,
              label: 'Full name',
              value: _get('fname'),
            ),
            _InfoRow(
              icon: Icons.person_outline_rounded,
              label: 'Father',
              value: _get('ffatname'),
            ),
            _InfoRow(
              icon: Icons.person_outline_rounded,
              label: 'Mother',
              value: _get('fmotname'),
            ),
            _InfoRow(
              icon: Icons.category_outlined,
              label: 'Category',
              value: _get('category'),
            ),
          ],
        ),

        const SizedBox(height: 20),

        // ── Academic details ───────────────────────────────────────────
        _SectionHeader(label: 'Academic', c: c),
        const SizedBox(height: 8),
        _InfoCard(
          rows: [
            _InfoRow(
              icon: Icons.school_outlined,
              label: 'College',
              value: _get('college'),
            ),
            _InfoRow(
              icon: Icons.numbers_rounded,
              label: 'USN',
              value: _get('strRegno'),
            ),
            _InfoRow(
              icon: Icons.book_outlined,
              label: 'Programme',
              value: _get('degree'),
            ),
            // _InfoRow(
            //   icon: Icons.layers_outlined,
            //   label: 'Semester',
            //   value: _get('strSemester'),
            // ),
            _InfoRow(
              icon: Icons.tag_rounded,
              label: 'Degree code',
              value: _get('fdegree'),
            ),
            _InfoRow(
              icon: Icons.account_balance_outlined,
              label: 'Fee type',
              value: _get('feetype'),
            ),
          ],
        ),

        const SizedBox(height: 20),

        // ── Contact ────────────────────────────────────────────────────
        _SectionHeader(label: 'Contact', c: c),
        const SizedBox(height: 8),
        _InfoCard(
          rows: [
            _InfoRow(
              icon: Icons.email_outlined,
              label: 'Email',
              value: _get('strEmail'),
            ),
            _InfoRow(
              icon: Icons.phone_outlined,
              label: 'Mobile',
              value: _get('strMobile'),
            ),
            _InfoRow(
              icon: Icons.phone_callback_outlined,
              label: 'Parent mobile',
              value: _get('strParentMob'),
            ),
          ],
        ),
      ],
    );
  }
}

// ─── Avatar hero ──────────────────────────────────────────────────────────────

class _AvatarHero extends StatelessWidget {
  final String photoUrl;
  final String name;
  final String usn;
  final String degree;
  final AppColorSchemeExt c;

  const _AvatarHero({
    required this.photoUrl,
    required this.name,
    required this.usn,
    required this.degree,
    required this.c,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: c.surfaceBg,
        borderRadius: BorderRadius.circular(AppDimens.radiusLg),
        border: Border.all(color: c.surfaceBorder),
      ),
      child: Row(
        children: [
          // Photo
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppDimens.radiusMd),
              border: Border.all(
                color: c.accentGreen.withOpacity(0.4),
                width: 2,
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(AppDimens.radiusMd - 2),
              child: CachedNetworkImage(
                imageUrl: photoUrl,
                fit: BoxFit.cover,
                placeholder: (_, __) => Container(
                  color: c.surfaceBorder,
                  child: Icon(
                    Icons.person_rounded,
                    color: c.textMuted,
                    size: 32,
                  ),
                ),
                errorWidget: (_, __, ___) => Container(
                  color: c.surfaceBorder,
                  child: Icon(
                    Icons.person_rounded,
                    color: c.textMuted,
                    size: 32,
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(width: 16),

          // Name + USN
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: AppTextStyles.courseName.copyWith(
                    color: c.textPrimary,
                    fontSize: 17,
                  ),
                ),
                const SizedBox(height: 4),
                // USN pill
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: c.accentGreen.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(AppDimens.radiusPill),
                    border: Border.all(
                      color: c.accentGreen.withOpacity(0.25),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    usn,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: c.accentGreen,
                      fontFamily: 'monospace',
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  degree,
                  style: AppTextStyles.statLabel.copyWith(color: c.textMuted),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Exam banner ──────────────────────────────────────────────────────────────

class _ExamBanner extends StatelessWidget {
  final String examName;
  final String examDate;
  final AppColorSchemeExt c;

  const _ExamBanner({
    required this.examName,
    required this.examDate,
    required this.c,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: c.accentGreen.withOpacity(0.07),
        borderRadius: BorderRadius.circular(AppDimens.radiusLg),
        border: Border.all(color: c.accentGreen.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Icon(Icons.event_note_rounded, size: 18, color: c.accentGreen),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  examName,
                  style: AppTextStyles.courseName.copyWith(
                    color: c.textPrimary,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  examDate,
                  style: AppTextStyles.statLabel.copyWith(color: c.textMuted),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Info card ────────────────────────────────────────────────────────────────

class _InfoCard extends StatelessWidget {
  final List<_InfoRow> rows;
  const _InfoCard({required this.rows});

  @override
  Widget build(BuildContext context) {
    final c = AppColorSchemeExt.of(context);

    return Container(
      decoration: BoxDecoration(
        color: c.surfaceBg,
        borderRadius: BorderRadius.circular(AppDimens.radiusLg),
        border: Border.all(color: c.surfaceBorder),
      ),
      child: Column(
        children: rows.asMap().entries.map((entry) {
          final isLast = entry.key == rows.length - 1;
          return Column(
            children: [
              entry.value,
              if (!isLast)
                Divider(
                  height: 1,
                  thickness: 1,
                  indent: 52,
                  endIndent: 0,
                  color: c.divider,
                ),
            ],
          );
        }).toList(),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final c = AppColorSchemeExt.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
      child: Row(
        children: [
          Icon(icon, size: 18, color: c.textMuted),
          const SizedBox(width: 14),
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: AppTextStyles.statLabel.copyWith(color: c.textMuted),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: AppTextStyles.courseName.copyWith(
                color: c.textPrimary,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.right,
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Section header ───────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final String label;
  final AppColorSchemeExt c;

  const _SectionHeader({required this.label, required this.c});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        label.toUpperCase(),
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          letterSpacing: 1.2,
          color: c.textMuted,
        ),
      ),
    );
  }
}
