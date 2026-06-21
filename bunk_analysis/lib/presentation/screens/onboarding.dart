// lib/presentation/screens/onboarding_screen.dart

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/constants/app_colors.dart';
import 'login_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _controller = PageController();
  int _currentPage = 0;

  final _pages = const [
    _OnboardingPage1(),
    _OnboardingPage2(),
    _OnboardingPage3(),
    _OnboardingPageResources(),

    _OnboardingPage4(),
  ];

  void _next() {
    if (_currentPage < _pages.length - 1) {
      _controller.nextPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      );
    } else {
      _finish();
    }
  }

  void _skip() => _finish();

  Future<void> _finish() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_done', true);
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = AppColorSchemeExt.of(context);
    final isLast = _currentPage == _pages.length - 1;

    return Scaffold(
      backgroundColor: c.pageBg,
      body: SafeArea(
        child: Column(
          children: [
            // ── Skip button ───────────────────────────────────────────
            Align(
              alignment: Alignment.centerRight,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(0, 12, 20, 0),
                child: isLast
                    ? const SizedBox(height: 36)
                    : GestureDetector(
                        onTap: _skip,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 7,
                          ),
                          decoration: BoxDecoration(
                            color: c.surfaceBg,
                            borderRadius: BorderRadius.circular(
                              AppDimens.radiusPill,
                            ),
                            border: Border.all(color: c.surfaceBorder),
                          ),
                          child: Text(
                            'Skip',
                            style: TextStyle(
                              fontSize: 12,
                              color: c.textMuted,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
              ),
            ),

            // ── Pages ─────────────────────────────────────────────────
            Expanded(
              child: PageView(
                controller: _controller,
                onPageChanged: (i) => setState(() => _currentPage = i),
                children: _pages,
              ),
            ),

            // ── Dots + button ─────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
              child: Row(
                children: [
                  // Dot indicators
                  Row(
                    children: List.generate(
                      _pages.length,
                      (i) => AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        margin: const EdgeInsets.only(right: 6),
                        width: i == _currentPage ? 20 : 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: i == _currentPage
                              ? c.accentGreen
                              : c.surfaceBorder,
                          borderRadius: BorderRadius.circular(99),
                        ),
                      ),
                    ),
                  ),

                  const Spacer(),

                  // Next / Get Started button
                  GestureDetector(
                    onTap: _next,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      padding: EdgeInsets.symmetric(
                        horizontal: isLast ? 28 : 20,
                        vertical: 14,
                      ),
                      decoration: BoxDecoration(
                        color: c.accentGreen,
                        borderRadius: BorderRadius.circular(
                          AppDimens.radiusPill,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            isLast ? 'Get Started' : 'Next',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: c.pageBg,
                            ),
                          ),
                          if (!isLast) ...[
                            const SizedBox(width: 6),
                            Icon(
                              Icons.arrow_forward_rounded,
                              size: 16,
                              color: c.pageBg,
                            ),
                          ],
                        ],
                      ),
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
}

// ─── Page 1 — Welcome ─────────────────────────────────────────────────────────

class _OnboardingPage1 extends StatelessWidget {
  const _OnboardingPage1();

  @override
  Widget build(BuildContext context) {
    final c = AppColorSchemeExt.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 28),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Logo
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: c.accentGreen.withOpacity(0.12),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: c.accentGreen.withOpacity(0.3),
                width: 1.5,
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: Image.asset('assets/images/logo.png', fit: BoxFit.cover),
            ),
          ),

          const SizedBox(height: 32),

          Text(
            'Welcome to\nNSync',
            style: TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.w800,
              color: c.textPrimary,
              height: 1.1,
              letterSpacing: -1,
            ),
          ),

          const SizedBox(height: 16),

          Text(
            'Your attendance, simplified. Know exactly where you stand — before it\'s too late.',
            style: TextStyle(fontSize: 15, color: c.textMuted, height: 1.6),
          ),

          const SizedBox(height: 32),

          // Feature pills
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _Pill(label: '📊 Live attendance', c: c),
              _Pill(label: '🎯 Bunk simulator', c: c),
              _Pill(label: '⚠️ Risk alerts', c: c),
              _Pill(label: '📚 PYQs & notes', c: c),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── Page 2 — The 85/75 rule ──────────────────────────────────────────────────

class _OnboardingPage2 extends StatelessWidget {
  const _OnboardingPage2();

  @override
  Widget build(BuildContext context) {
    final c = AppColorSchemeExt.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 28),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _PageTag(label: 'HOW IT WORKS', c: c),
          const SizedBox(height: 16),

          Text(
            'Know your\nthresholds',
            style: TextStyle(
              fontSize: 34,
              fontWeight: FontWeight.w800,
              color: c.textPrimary,
              height: 1.1,
              letterSpacing: -1,
            ),
          ),

          const SizedBox(height: 12),

          Text(
            'Our college has attendance limits you need to stay above.',
            style: TextStyle(fontSize: 14, color: c.textMuted, height: 1.6),
          ),

          const SizedBox(height: 32),

          // Threshold cards
          _ThresholdCard(
            pct: '85%',
            label: 'Safe zone',
            sublabel: 'No penalty. You\'re good to go.',
            color: c.accentGreen,
            c: c,
          ),
          const SizedBox(height: 10),
          _ThresholdCard(
            pct: '75–85%',
            label: 'Penalty zone',
            sublabel: 'You\'ll be fined. Attend more to clear it.',
            color: Colors.orange,
            c: c,
          ),
          const SizedBox(height: 10),
          _ThresholdCard(
            pct: '< 75%',
            label: 'Detained',
            sublabel: 'You may be barred from exams.',
            color: c.accentRed,
            c: c,
          ),

          const SizedBox(height: 28),

          // Mock progress bar
          _MockProgressBar(c: c),
        ],
      ),
    );
  }
}

// ─── Page 3 — Simulator ───────────────────────────────────────────────────────

class _OnboardingPage3 extends StatelessWidget {
  const _OnboardingPage3();

  @override
  Widget build(BuildContext context) {
    final c = AppColorSchemeExt.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 28),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _PageTag(label: 'SIMULATOR', c: c),
          const SizedBox(height: 16),

          Text(
            'Plan before\nyou skip',
            style: TextStyle(
              fontSize: 34,
              fontWeight: FontWeight.w800,
              color: c.textPrimary,
              height: 1.1,
              letterSpacing: -1,
            ),
          ),

          const SizedBox(height: 12),

          Text(
            'Tap into any subject and simulate what happens if you attend or skip future classes.',
            style: TextStyle(fontSize: 14, color: c.textMuted, height: 1.6),
          ),

          const SizedBox(height: 32),

          // Mock simulator card
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: c.surfaceBg,
              borderRadius: BorderRadius.circular(AppDimens.radiusLg),
              border: Border.all(color: c.surfaceBorder),
            ),
            child: Column(
              children: [
                _MockSimRow(
                  icon: Icons.check_circle_outline_rounded,
                  label: 'Attend future classes',
                  count: '+5',
                  color: c.accentGreen,
                  c: c,
                ),
                const SizedBox(height: 12),
                Divider(height: 1, color: c.divider),
                const SizedBox(height: 12),
                _MockSimRow(
                  icon: Icons.cancel_outlined,
                  label: 'Bunk future classes',
                  count: '+2',
                  color: c.accentRed,
                  c: c,
                ),
                const SizedBox(height: 16),
                // Result preview
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: c.accentGreen.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(AppDimens.radiusMd),
                    border: Border.all(color: c.accentGreen.withOpacity(0.2)),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.check_circle_rounded,
                        size: 16,
                        color: c.accentGreen,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Attendance would be 88.2%',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: c.textPrimary,
                        ),
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
}

// ─── Page — Resources & PYQs ──────────────────────────────────────────────────

class _OnboardingPageResources extends StatelessWidget {
  const _OnboardingPageResources();

  @override
  Widget build(BuildContext context) {
    final c = AppColorSchemeExt.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 28),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _PageTag(label: 'RESOURCES', c: c),
          const SizedBox(height: 16),

          Text(
            'Notes & PYQs,\nsorted for you',
            style: TextStyle(
              fontSize: 34,
              fontWeight: FontWeight.w800,
              color: c.textPrimary,
              height: 1.1,
              letterSpacing: -1,
            ),
          ),

          const SizedBox(height: 12),

          Text(
            'Your required notes are automatically fetched from our cloud storage, avoiding the long searches',
            style: TextStyle(fontSize: 14, color: c.textMuted, height: 1.6),
          ),

          const SizedBox(height: 32),

          // Mock resource cards
          _MockResourceCard(
            title: 'Design and Analysis of Algorithms',
            fileType: 'PYQ · May 2025',
            c: c,
          ),
          const SizedBox(height: 10),
          _MockResourceCard(
            title: 'Database Management Systems',
            fileType: 'Notes · Module 1-5',
            c: c,
          ),
          const SizedBox(height: 10),
          _MockResourceCard(
            title: 'Internet & Web Programming',
            fileType: 'Notes · Full syllabus',
            c: c,
          ),

          const SizedBox(height: 20),

          Row(
            children: [
              Icon(Icons.auto_awesome_rounded, size: 14, color: c.accentGreen),
              const SizedBox(width: 6),
              Text(
                'Less searching, no folders — just your subjects',
                style: TextStyle(
                  fontSize: 12,
                  color: c.accentGreen,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MockResourceCard extends StatelessWidget {
  final String title;
  final String fileType;
  final AppColorSchemeExt c;

  const _MockResourceCard({
    required this.title,
    required this.fileType,
    required this.c,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: c.surfaceBg,
        borderRadius: BorderRadius.circular(AppDimens.radiusLg),
        border: Border.all(color: c.surfaceBorder),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: c.accentRed.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppDimens.radiusMd),
            ),
            child: Icon(
              Icons.picture_as_pdf_rounded,
              size: 17,
              color: c.accentRed,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: c.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  fileType,
                  style: TextStyle(fontSize: 11, color: c.textMuted),
                ),
              ],
            ),
          ),
          Icon(Icons.menu_book_outlined, size: 16, color: c.textSubtle),
        ],
      ),
    );
  }
}
// ─── Page 4 — Privacy ─────────────────────────────────────────────────────────

class _OnboardingPage4 extends StatelessWidget {
  const _OnboardingPage4();

  @override
  Widget build(BuildContext context) {
    final c = AppColorSchemeExt.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 28),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _PageTag(label: 'PRIVACY', c: c),
          const SizedBox(height: 16),

          Text(
            'Your data,\nyour device',
            style: TextStyle(
              fontSize: 34,
              fontWeight: FontWeight.w800,
              color: c.textPrimary,
              height: 1.1,
              letterSpacing: -1,
            ),
          ),

          const SizedBox(height: 12),

          Text(
            'NSync only talks to your college portal — nothing else.',
            style: TextStyle(fontSize: 14, color: c.textMuted, height: 1.6),
          ),

          const SizedBox(height: 32),

          _PrivacyRow(
            icon: Icons.lock_outline_rounded,
            label: 'Credentials stored locally',
            sublabel: 'Encrypted on your device, never uploaded.',
            c: c,
          ),
          const SizedBox(height: 12),
          _PrivacyRow(
            icon: Icons.cloud_off_rounded,
            label: 'No third-party servers',
            sublabel: 'Data flows only between you and your college portal.',
            c: c,
          ),
          const SizedBox(height: 12),
          // _PrivacyRow(
          //   icon: Icons.person_off_outlined,
          //   label: 'Anonymous analytics',
          //   sublabel: 'Usage stats are fully anonymous. No personal data.',
          //   c: c,
          // ),
        ],
      ),
    );
  }
}

// ─── Small shared widgets ─────────────────────────────────────────────────────

class _PageTag extends StatelessWidget {
  final String label;
  final AppColorSchemeExt c;
  const _PageTag({required this.label, required this.c});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: c.accentGreen.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppDimens.radiusPill),
        border: Border.all(color: c.accentGreen.withOpacity(0.25)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.4,
          color: c.accentGreen,
        ),
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  final String label;
  final AppColorSchemeExt c;
  const _Pill({required this.label, required this.c});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: c.surfaceBg,
        borderRadius: BorderRadius.circular(AppDimens.radiusPill),
        border: Border.all(color: c.surfaceBorder),
      ),
      child: Text(label, style: TextStyle(fontSize: 12, color: c.textMuted)),
    );
  }
}

class _ThresholdCard extends StatelessWidget {
  final String pct;
  final String label;
  final String sublabel;
  final Color color;
  final AppColorSchemeExt c;

  const _ThresholdCard({
    required this.pct,
    required this.label,
    required this.sublabel,
    required this.color,
    required this.c,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.07),
        borderRadius: BorderRadius.circular(AppDimens.radiusMd),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Text(
            pct,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
          const SizedBox(width: 14),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: c.textPrimary,
                ),
              ),
              Text(
                sublabel,
                style: TextStyle(fontSize: 11, color: c.textMuted),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MockProgressBar extends StatelessWidget {
  final AppColorSchemeExt c;
  const _MockProgressBar({required this.c});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final w = constraints.maxWidth;
        return Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              height: 8,
              width: w,
              decoration: BoxDecoration(
                color: c.accentRed.withOpacity(0.3),
                borderRadius: BorderRadius.circular(99),
              ),
            ),
            Container(
              height: 8,
              width: w * 0.82,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.orange, c.accentGreen],
                ),
                borderRadius: BorderRadius.circular(99),
              ),
            ),
            Positioned(
              left: w * 0.75 - 0.75,
              top: -4,
              child: Container(
                width: 1.5,
                height: 16,
                color: c.accentRed.withOpacity(0.6),
              ),
            ),
            Positioned(
              left: w * 0.85 - 0.75,
              top: -4,
              child: Container(
                width: 1.5,
                height: 16,
                color: c.accentGreen.withOpacity(0.7),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _MockSimRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String count;
  final Color color;
  final AppColorSchemeExt c;

  const _MockSimRow({
    required this.icon,
    required this.label,
    required this.count,
    required this.color,
    required this.c,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: color),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: c.textPrimary,
            ),
          ),
        ),
        Text(
          count,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
      ],
    );
  }
}

class _PrivacyRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String sublabel;
  final AppColorSchemeExt c;

  const _PrivacyRow({
    required this.icon,
    required this.label,
    required this.sublabel,
    required this.c,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: c.surfaceBg,
            borderRadius: BorderRadius.circular(AppDimens.radiusMd),
            border: Border.all(color: c.surfaceBorder),
          ),
          child: Icon(icon, size: 18, color: c.accentGreen),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: c.textPrimary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                sublabel,
                style: TextStyle(fontSize: 12, color: c.textMuted),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
