import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// ─── DARK PALETTE ────────────────────────────────────────────────────────────
class DarkColors {
  DarkColors._();
  static const bg = Color(0xFF080F22);
  static const surface = Color(0xFF0F1A33);
  static const surface2 = Color(0xFF162140);
  static const border = Color(0xFF1E2F50);

  /// Border for interactive controls (inputs, checkboxes, focusable targets).
  /// WCAG 1.4.11 requires 3:1 against adjacent surfaces; `border` is decorative
  /// only and sits at ~1.3:1 by design.
  static const borderInteractive = Color(0xFF4A72A8);
  static const primary = Color(0xFF00E5FF);
  static const secondary = Color(0xFFA8FF3E);
  static const accent = Color(0xFFFFB800);
  static const error = Color(0xFFFF4757);
  static const text = Color(0xFFF0F4FF);
  static const muted = Color(0xFFB8C8D8);

  /// Pre-composited replacement for `muted.withValues(alpha: 0.6/0.65)`.
  /// Alpha-faded text drops to ~3.5:1 and fails WCAG 1.4.3.
  static const mutedSubtle = Color(0xFFAABACD);

  /// Foreground for text/icons placed ON primary/secondary/accent/error fills.
  /// Dark ink on the bright neon palette scores 10.8-15.2:1, versus 1.2-1.7:1
  /// for white. 10.8 = 0xFF0A1128.
  static const onFill = Color(0xFF0A1128);
  static const gold = Color(0xFFFFD700);
  static const silver = Color(0xFFC0C0C0);
  static const bronze = Color(0xFFCD7F32);
}

// ─── LIGHT PALETTE ───────────────────────────────────────────────────────────
class LightColors {
  LightColors._();
  static const bg = Color(0xFFEBEBEC);
  static const surface = Color(0xFFFFFFFF);
  static const surface2 = Color(0xFFF4F4F6);
  static const border = Color(0xFFD8D8DC);

  /// Border for interactive controls — see DarkColors.borderInteractive.
  static const borderInteractive = Color(0xFF7A8089);
  static const navy = Color(0xFF142B58);
  static const blue = Color(0xFF2E65C3);

  /// Darkened from #37A66F (2.6-3.1:1) to clear 4.5:1 on all light surfaces.
  static const green = Color(0xFF0A7942);

  /// Darkened from #D93025 (4.0:1 on bg) to clear 4.5:1 on all light surfaces.
  static const error = Color(0xFFCB2A1F);
  static const text = Color(0xFF142B58);
  static const muted = Color(0xFF4A5568);

  /// Darkened from #D4A017 (2.0-2.4:1) to clear 4.5:1 on all light surfaces.
  static const gold = Color(0xFF895500);
  static const silver = Color(0xFF6B7280);
  static const bronze = Color(0xFF7A4E1D);

  /// White text on the light palette's darker fills scores 4.8-5.6:1, so white
  /// is retained here (dark ink would drop to ~3.0-3.4:1).
  static const onFill = Colors.white;
}

// ─── SEMANTIC COLOR TOKENS ────────────────────────────────────────────────────
class AppColors {
  AppColors._();
  static Color bg(BuildContext ctx) => _d(ctx) ? DarkColors.bg : LightColors.bg;
  static Color surface(BuildContext ctx) =>
      _d(ctx) ? DarkColors.surface : LightColors.surface;
  static Color surface2(BuildContext ctx) =>
      _d(ctx) ? DarkColors.surface2 : LightColors.surface2;
  static Color border(BuildContext ctx) =>
      _d(ctx) ? DarkColors.border : LightColors.border;

  /// 3:1-safe border for interactive controls. Use for input outlines,
  /// checkbox borders and focus rings — not decorative separators.
  static Color borderInteractive(BuildContext ctx) =>
      _d(ctx) ? DarkColors.borderInteractive : LightColors.borderInteractive;
  static Color text(BuildContext ctx) =>
      _d(ctx) ? DarkColors.text : LightColors.text;
  static Color muted(BuildContext ctx) =>
      _d(ctx) ? DarkColors.muted : LightColors.muted;

  /// Alpha-free substitute for faded muted text.
  static Color mutedSubtle(BuildContext ctx) =>
      _d(ctx) ? DarkColors.mutedSubtle : LightColors.muted;

  /// Foreground colour that is legible on top of primary/secondary/accent/error
  /// fills. Always pair with the fill rather than hard-coding white.
  static Color onFill(BuildContext ctx) =>
      _d(ctx) ? DarkColors.onFill : LightColors.onFill;
  static Color primary(BuildContext ctx) =>
      _d(ctx) ? DarkColors.primary : LightColors.blue;
  static Color secondary(BuildContext ctx) =>
      _d(ctx) ? DarkColors.secondary : LightColors.green;
  static Color accent(BuildContext ctx) =>
      _d(ctx) ? DarkColors.accent : LightColors.gold;
  static Color error(BuildContext ctx) =>
      _d(ctx) ? DarkColors.error : LightColors.error;

  static Color get gold => DarkColors.gold;
  static Color get silver => DarkColors.silver;
  static Color get bronze => DarkColors.bronze;

  static const darkBg = DarkColors.bg;
  static const darkSurface = DarkColors.surface;
  static const darkSurface2 = DarkColors.surface2;
  static const darkBorder = DarkColors.border;
  static const cyan = DarkColors.primary;
  static const lime = DarkColors.secondary;
  static const amber = DarkColors.accent;
  static const coral = DarkColors.error;
  static const lightBg = LightColors.bg;
  static const lightSurface = LightColors.surface;
  static const navy = LightColors.navy;
  static const blue = LightColors.blue;
  static const green = LightColors.green;

  static bool _d(BuildContext ctx) =>
      Theme.of(ctx).brightness == Brightness.dark;
}

/// Relative luminance per WCAG 2.x.
///
/// `ThemeData.estimateBrightnessForColor` is deliberately *not* used for this:
/// it weights raw channels (0.299/0.587/0.114), so a saturated mid-tone like
/// #FF4757 scores "dark" while its true relative luminance only supports
/// 3.03:1 against light text. This is the same formula the spec uses for
/// contrast, so the two agree.
double relativeLuminance(Color c) {
  double channel(double v) =>
      v <= 0.03928 ? v / 12.92 : math.pow((v + 0.055) / 1.055, 2.4).toDouble();
  return 0.2126 * channel(c.r) + 0.7152 * channel(c.g) + 0.0722 * channel(c.b);
}

/// WCAG 2.x contrast ratio between two opaque colours, 1.0 .. 21.0.
double contrastRatio(Color a, Color b) {
  final la = relativeLuminance(a), lb = relativeLuminance(b);
  final hi = math.max(la, lb), lo = math.min(la, lb);
  return (hi + 0.05) / (lo + 0.05);
}

/// Picks a WCAG-legible foreground for text and icons drawn on [fill].
///
/// Rather than guessing from brightness, this measures every candidate ink
/// against [fill] using the real WCAG formula. Preference order is
/// theme-first so the design intent is respected:
///
///  1. the theme's designated on-fill ink,
///  2. the theme's body text,
///  3. pure white, then pure black.
///
/// The first candidate clearing [aaThreshold] (4.5:1, WCAG 1.4.3 for body text)
/// wins. If none clear it, the highest-contrast candidate is returned as a
/// best effort — callers should then not rely on full AA compliance.
///
/// This stays correct for any fill, including saturated mid-tones that a
/// brightness heuristic misclassifies (e.g. #FF4757, where
/// `estimateBrightnessForColor` says "dark" but light text only reaches 3.03:1).
///
/// Lives here rather than in `widgets.dart` so that low-level widgets can use
/// it without importing the app-wide widget library (and risking an import
/// cycle). Ratios are asserted by `tool/contrast_final.dart` and by
/// `test/accessibility_test.dart`.
///
/// | fill         | chosen     | ratio |
/// |--------------|------------|-------|
/// | #00E5FF cyan | dark ink   | 12.15 |
/// | #A8FF3E lime | dark ink   | 15.16 |
/// | #FFB800 gold | dark ink   | 10.78 |
/// | #FF4757 red  | dark ink   |  4.84 |
/// | #142B58 navy | white      | 13.85 |
/// | #CB2A1F red  | white      |  5.40 |
Color onFillFor(BuildContext context, Color fill, {double aaThreshold = 4.5}) {
  final candidates = <Color>[
    AppColors.onFill(context), // theme's designated on-fill ink
    AppColors.text(context), // theme's body text
    Colors.white,
    Colors.black,
  ];

  Color best = candidates.first;
  var bestRatio = -1.0;
  for (final ink in candidates) {
    final ratio = contrastRatio(ink, fill);
    if (ratio >= aaThreshold) return ink; // first passing candidate wins
    if (ratio > bestRatio) {
      bestRatio = ratio;
      best = ink;
    }
  }
  return best; // nothing reached AA — return the least-bad option
}

class AppTextStyles {
  AppTextStyles._();

  /// Hero titles, display numbers — Plus Jakarta Sans (readable at large sizes)
  static TextStyle display(double size,
      {Color? color, double? letterSpacing, BuildContext? context}) {
    final isAr =
        context != null && Localizations.localeOf(context).languageCode == 'ar';
    if (isAr) return arabicDisplay(size * 0.9, color: color);
    return GoogleFonts.plusJakartaSans(
      fontSize: size,
      fontWeight: FontWeight.w800,
      color: color,
      letterSpacing: letterSpacing ?? 0,
      height: 1.22,
    );
  }

  /// Section headings
  static TextStyle heading(double size,
      {Color? color, double? letterSpacing, BuildContext? context}) {
    final isAr =
        context != null && Localizations.localeOf(context).languageCode == 'ar';
    if (isAr) return arabicHeading(size * 0.9, color: color);
    return GoogleFonts.plusJakartaSans(
      fontSize: size,
      fontWeight: FontWeight.w700,
      color: color,
      letterSpacing: letterSpacing ?? 0.15,
      height: 1.35,
    );
  }

  /// Body & UI copy — Inter, tuned for long reading on screens
  static TextStyle body(double size,
      {Color? color, FontWeight? weight, BuildContext? context}) {
    final isAr =
        context != null && Localizations.localeOf(context).languageCode == 'ar';
    if (isAr) return arabicBody(size * 0.9, color: color, weight: weight);
    return GoogleFonts.inter(
      fontSize: size,
      fontWeight: weight ?? FontWeight.w500,
      color: color,
      height: 1.55,
      letterSpacing: 0.2,
    );
  }

  static TextStyle arabicBody(double size,
          {Color? color, FontWeight? weight}) =>
      GoogleFonts.notoKufiArabic(
        fontSize: size,
        fontWeight: weight ?? FontWeight.w500,
        color: color,
        height: 1.6,
      );

  static TextStyle arabicHeading(double size,
          {Color? color, double? letterSpacing}) =>
      GoogleFonts.notoKufiArabic(
        fontSize: size,
        fontWeight: FontWeight.w700,
        color: color,
        height: 1.4,
      );

  static TextStyle arabicDisplay(double size,
          {Color? color, double? letterSpacing}) =>
      GoogleFonts.notoKufiArabic(
        fontSize: size,
        fontWeight: FontWeight.w800,
        color: color,
        height: 1.3,
      );

  /// Uppercase field labels & badges
  static TextStyle label(
      {Color? color,
      double size = 12.5,
      FontWeight? weight,
      BuildContext? context}) {
    final isAr =
        context != null && Localizations.localeOf(context).languageCode == 'ar';
    if (isAr) {
      return arabicBody(size * 0.9,
          color: color, weight: weight ?? FontWeight.w600);
    }
    return GoogleFonts.inter(
      fontSize: size,
      fontWeight: weight ?? FontWeight.w600,
      color: color,
      letterSpacing: 0.55,
      height: 1.45,
    );
  }

  /// Numbers, stats, scores
  static TextStyle stat(double size,
      {Color? color, FontWeight? weight, BuildContext? context}) {
    final isAr =
        context != null && Localizations.localeOf(context).languageCode == 'ar';
    if (isAr) return arabicDisplay(size * 0.9, color: color);
    return GoogleFonts.plusJakartaSans(
      fontSize: size,
      fontWeight: weight ?? FontWeight.w800,
      color: color,
      letterSpacing: 0,
      height: 1.15,
    );
  }
}

// ─── THEME DATA ───────────────────────────────────────────────────────────────
class AppTheme {
  AppTheme._();

  static ThemeData get dark => ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: DarkColors.bg,
        colorScheme: const ColorScheme.dark(
          primary: DarkColors.primary,
          secondary: DarkColors.secondary,
          tertiary: DarkColors.accent,
          error: DarkColors.error,
          surface: DarkColors.surface,
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: DarkColors.bg,
          surfaceTintColor: Colors.transparent,
          elevation: 0,
          titleTextStyle: AppTextStyles.heading(18, color: DarkColors.primary),
          iconTheme: const IconThemeData(color: DarkColors.text, size: 26),
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: DarkColors.bg,
          selectedItemColor: DarkColors.primary,
          unselectedItemColor: DarkColors.muted,
          elevation: 0,
          type: BottomNavigationBarType.fixed,
        ),
        cardTheme: CardThemeData(
          color: DarkColors.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: const BorderSide(color: DarkColors.border),
          ),
          elevation: 0,
          margin: EdgeInsets.zero,
        ),
        dividerColor: DarkColors.border,
        textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme)
            .apply(bodyColor: DarkColors.text, displayColor: DarkColors.text),
        iconTheme: const IconThemeData(color: DarkColors.muted, size: 26),
      );

  static ThemeData get light => ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        scaffoldBackgroundColor: LightColors.bg,
        colorScheme: const ColorScheme.light(
          primary: LightColors.blue,
          secondary: LightColors.green,
          tertiary: LightColors.gold,
          error: LightColors.error,
          surface: LightColors.surface,
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: LightColors.surface,
          surfaceTintColor: Colors.transparent,
          elevation: 0,
          shadowColor: LightColors.border,
          titleTextStyle: AppTextStyles.heading(18, color: LightColors.navy),
          iconTheme: const IconThemeData(color: LightColors.navy, size: 26),
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: LightColors.surface,
          selectedItemColor: LightColors.blue,
          unselectedItemColor: LightColors.muted,
          elevation: 0,
          type: BottomNavigationBarType.fixed,
        ),
        cardTheme: CardThemeData(
          color: LightColors.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: const BorderSide(color: LightColors.border),
          ),
          elevation: 0,
          margin: EdgeInsets.zero,
        ),
        dividerColor: LightColors.border,
        textTheme: GoogleFonts.interTextTheme(ThemeData.light().textTheme)
            .apply(bodyColor: LightColors.navy, displayColor: LightColors.navy),
        iconTheme: const IconThemeData(color: LightColors.muted, size: 26),
      );
}
