// lib/core/theme/app_theme.dart

import 'package:flutter/material.dart';

// ─── Colors ───────────────────────────────────────────────────────────────────

class AppColors {
  AppColors._();

  // ── Dark ──
  static const Color darkPageBg = Color(0xFF0C0C15);
  static const Color darkSurfaceBg = Color(0xFF13131E);
  static const Color darkSurfaceBorder = Color(0x12FFFFFF);
  static const Color darkTextPrimary = Color(0xFFFFFFFF);
  static const Color darkTextMuted = Color(0x66FFFFFF);
  static const Color darkTextSubtle = Color(0x59FFFFFF);
  static const Color darkDivider = Color(0x12FFFFFF);
  static const Color darkTick = Color(0x4DFFFFFF);

  // ── Light ──
  static const Color lightPageBg = Color(0xFFF4F4F8);
  static const Color lightSurfaceBg = Color(0xFFFFFFFF);
  static const Color lightSurfaceBorder = Color(0x1A000000); // black 10%
  static const Color lightTextPrimary = Color(0xFF0C0C15);
  static const Color lightTextMuted = Color(0x99000000); // black 60%
  static const Color lightTextSubtle = Color(0x80000000); // black 50%
  static const Color lightDivider = Color(0x1A000000);
  static const Color lightTick = Color(0x4D000000); // black 30%

  // ── Accents (same in both modes) ──
  static const Color accentGreen = Color(
    0xFF5DB800,
  ); // darker for light legibility
  static const Color accentRed = Color(0xFFD63050);

  // In AppColors
  static const Color accentWarning = Color(0xFFFF9500); // iOS-style amber

  // ── Accents (dark mode variants) ──
  static const Color accentGreenDark = Color(0xFFC8FF47);
  static const Color accentRedDark = Color(0xFFFF4D6A);

  // ── Course palette ──
  static const List<Color> courseColors = [
    Color(0xFF6366F1),
    Color(0xFF10B981),
    Color(0xFFF97316),
    Color(0xFFEC4899),
    Color(0xFF0EA5E9),
    Color(0xFF8B5CF6),
    Color(0xFFF59E0B),
    Color(0xFF22C55E),
  ];
}

// ─── Text styles ──────────────────────────────────────────────────────────────
// These are base styles — color is intentionally omitted so Theme.of(context)
// drives it at runtime. Apply .copyWith(color: ...) at the widget level
// when you need a specific shade.

class AppTextStyles {
  AppTextStyles._();

  static const TextStyle courseName = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
  );

  static const TextStyle courseCode = TextStyle(
    fontSize: 12,
    fontFamily: 'monospace',
  );

  static const TextStyle statValue = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w700,
  );

  static const TextStyle statSuffix = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
  );

  static const TextStyle statLabel = TextStyle(fontSize: 11);

  static const TextStyle pillLabel = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w600,
  );

  static const TextStyle appBarTitle = TextStyle(
    fontWeight: FontWeight.w600,
    fontSize: 18,
  );

  static const TextStyle sectionFallback = TextStyle(fontSize: 18);
}

// ─── Dimensions ───────────────────────────────────────────────────────────────

class AppDimens {
  AppDimens._();

  static const double radiusSm = 8.0;
  static const double radiusMd = 10.0;
  static const double radiusLg = 16.0;
  static const double radiusPill = 20.0;

  static const double tileColorDotContainer = 36.0;
  static const double tileColorDot = 12.0;
  static const double progressBarHeight = 6.0;

  static const EdgeInsets tilePadding = EdgeInsets.all(16);
  static const EdgeInsets tileMargin = EdgeInsets.only(bottom: 12);
  static const EdgeInsets listPadding = EdgeInsets.fromLTRB(16, 16, 16, 32);
  static const EdgeInsets pillPadding = EdgeInsets.symmetric(
    horizontal: 8,
    vertical: 3,
  );
  static const EdgeInsets statDividerMargin = EdgeInsets.symmetric(
    horizontal: 12,
  );
}

// ─── Theme extension — carries mode-specific tokens into the widget tree ──────

class AppColorSchemeExt extends ThemeExtension<AppColorSchemeExt> {
  final Color pageBg;
  final Color surfaceBg;
  final Color surfaceBorder;
  final Color textPrimary;
  final Color textMuted;
  final Color textSubtle;
  final Color divider;
  final Color tick;
  final Color accentGreen;
  final Color accentRed;

  const AppColorSchemeExt({
    required this.pageBg,
    required this.surfaceBg,
    required this.surfaceBorder,
    required this.textPrimary,
    required this.textMuted,
    required this.textSubtle,
    required this.divider,
    required this.tick,
    required this.accentGreen,
    required this.accentRed,
  });

  static const dark = AppColorSchemeExt(
    pageBg: AppColors.darkPageBg,
    surfaceBg: AppColors.darkSurfaceBg,
    surfaceBorder: AppColors.darkSurfaceBorder,
    textPrimary: AppColors.darkTextPrimary,
    textMuted: AppColors.darkTextMuted,
    textSubtle: AppColors.darkTextSubtle,
    divider: AppColors.darkDivider,
    tick: AppColors.darkTick,
    accentGreen: AppColors.accentGreenDark,
    accentRed: AppColors.accentRedDark,
  );

  static const light = AppColorSchemeExt(
    pageBg: AppColors.lightPageBg,
    surfaceBg: AppColors.lightSurfaceBg,
    surfaceBorder: AppColors.lightSurfaceBorder,
    textPrimary: AppColors.lightTextPrimary,
    textMuted: AppColors.lightTextMuted,
    textSubtle: AppColors.lightTextSubtle,
    divider: AppColors.lightDivider,
    tick: AppColors.lightTick,
    accentGreen: AppColors.accentGreen,
    accentRed: AppColors.accentRed,
  );

  // Convenience accessor — call anywhere you have a BuildContext.
  // Returns a sensible fallback if the extension isn't found on the current
  // ThemeData to avoid runtime null/type errors.
  static AppColorSchemeExt of(BuildContext context) {
    final ext = Theme.of(context).extension<AppColorSchemeExt>();
    if (ext != null) return ext;
    return Theme.of(context).brightness == Brightness.dark
        ? AppColorSchemeExt.dark
        : AppColorSchemeExt.light;
  }

  @override
  AppColorSchemeExt copyWith({
    Color? pageBg,
    Color? surfaceBg,
    Color? surfaceBorder,
    Color? textPrimary,
    Color? textMuted,
    Color? textSubtle,
    Color? divider,
    Color? tick,
    Color? accentGreen,
    Color? accentRed,
  }) => AppColorSchemeExt(
    pageBg: pageBg ?? this.pageBg,
    surfaceBg: surfaceBg ?? this.surfaceBg,
    surfaceBorder: surfaceBorder ?? this.surfaceBorder,
    textPrimary: textPrimary ?? this.textPrimary,
    textMuted: textMuted ?? this.textMuted,
    textSubtle: textSubtle ?? this.textSubtle,
    divider: divider ?? this.divider,
    tick: tick ?? this.tick,
    accentGreen: accentGreen ?? this.accentGreen,
    accentRed: accentRed ?? this.accentRed,
  );

  @override
  AppColorSchemeExt lerp(AppColorSchemeExt? other, double t) {
    if (other == null) return this;
    return AppColorSchemeExt(
      pageBg: Color.lerp(pageBg, other.pageBg, t)!,
      surfaceBg: Color.lerp(surfaceBg, other.surfaceBg, t)!,
      surfaceBorder: Color.lerp(surfaceBorder, other.surfaceBorder, t)!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textMuted: Color.lerp(textMuted, other.textMuted, t)!,
      textSubtle: Color.lerp(textSubtle, other.textSubtle, t)!,
      divider: Color.lerp(divider, other.divider, t)!,
      tick: Color.lerp(tick, other.tick, t)!,
      accentGreen: Color.lerp(accentGreen, other.accentGreen, t)!,
      accentRed: Color.lerp(accentRed, other.accentRed, t)!,
    );
  }
}

// ─── ThemeData ────────────────────────────────────────────────────────────────

class AppTheme {
  AppTheme._();

  static ThemeData get dark => ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: AppColors.darkPageBg,
    colorScheme: const ColorScheme.dark(
      surface: AppColors.darkSurfaceBg,
      primary: AppColors.accentGreenDark,
      error: AppColors.accentRedDark,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.darkSurfaceBg,
      foregroundColor: AppColors.darkTextPrimary,
      elevation: 0,
      titleTextStyle: AppTextStyles.appBarTitle,
    ),
    dividerColor: AppColors.darkDivider,
    useMaterial3: true,
    extensions: const [AppColorSchemeExt.dark],
  );

  static ThemeData get light => ThemeData(
    brightness: Brightness.light,
    scaffoldBackgroundColor: AppColors.lightPageBg,
    colorScheme: const ColorScheme.light(
      surface: AppColors.lightSurfaceBg,
      primary: AppColors.accentGreen,
      error: AppColors.accentRed,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.lightSurfaceBg,
      foregroundColor: AppColors.lightTextPrimary,
      elevation: 0,
      titleTextStyle: AppTextStyles.appBarTitle,
    ),
    dividerColor: AppColors.lightDivider,
    useMaterial3: true,
    extensions: const [AppColorSchemeExt.light],
  );
}
