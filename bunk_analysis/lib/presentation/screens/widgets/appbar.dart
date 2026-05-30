// lib/presentation/widgets/home_app_bar.dart

import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

class HomeAppBar extends SliverPersistentHeaderDelegate {
  final String userName;
  final String appTitle;
  final VoidCallback onRefresh;
  final AppColorSchemeExt c;

  const HomeAppBar({
    required this.userName,
    required this.appTitle,
    required this.onRefresh,
    required this.c,
  });

  static const double _expanded = 120.0;
  static const double _collapsed = 64.0;

  @override
  double get maxExtent => _expanded;

  @override
  double get minExtent => _collapsed;

  @override
  bool shouldRebuild(HomeAppBar old) =>
      old.userName != userName || old.appTitle != appTitle;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    final progress = (shrinkOffset / (_expanded - _collapsed)).clamp(0.0, 1.0);
    final isCollapsed = progress > 0.85;

    return Container(
      color: c.pageBg,
      padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
      child: Stack(
        children: [
          // ── Expanded greeting (fades out on scroll) ────────────────
          Opacity(
            opacity: (1 - progress * 2).clamp(0.0, 1.0),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Hamburger space (default leading is 56px)
                  const SizedBox(width: 56),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Hey, $userName 👋',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: c.textPrimary,
                            letterSpacing: -0.3,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          appTitle,
                          style: TextStyle(fontSize: 12, color: c.textMuted),
                        ),
                      ],
                    ),
                  ),
                  // Refresh button
                  GestureDetector(
                    onTap: onRefresh,
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: c.surfaceBg,
                        borderRadius: BorderRadius.circular(AppDimens.radiusMd),
                        border: Border.all(color: c.surfaceBorder),
                      ),
                      child: Icon(
                        Icons.refresh_rounded,
                        size: 17,
                        color: c.textPrimary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Collapsed title (fades in on scroll) ──────────────────
          Opacity(
            opacity: ((progress - 0.5) * 2).clamp(0.0, 1.0),
            child: Align(
              alignment: Alignment.bottomLeft,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(72, 0, 16, 12),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        appTitle,
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                          color: c.textPrimary,
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: onRefresh,
                      child: Icon(
                        Icons.refresh_rounded,
                        size: 20,
                        color: c.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ── Bottom border (only when collapsed) ───────────────────
          if (isCollapsed)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(height: 1, color: c.surfaceBorder),
            ),
        ],
      ),
    );
  }
}
