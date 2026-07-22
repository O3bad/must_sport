import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// ─── DARK PALETTE ────────────────────────────────────────────────────────────
class DarkColors {
  DarkColors._();
  static const bg       = Color(0xFF080F22);
  static const surface  = Color(0xFF0F1A33);
  static const surface2 = Color(0xFF162140);
  static const border   = Color(0xFF1E2F50);
  static const primary  = Color(0xFF00E5FF);
  static const secondary= Color(0xFFA8FF3E);
  static const accent   = Color(0xFFFFB800);
  static const error    = Color(0xFFFF4757);
  static const text     = Color(0xFFF0F4FF);
  static const muted    = Color(0xFFB8C8D8);
  static const gold     = Color(0xFFFFD700);
  static const silver   = Color(0xFFC0C0C0);
  static const bronze   = Color(0xFFCD7F32);
}

// ─── LIGHT PALETTE ───────────────────────────────────────────────────────────
class LightColors {
  LightColors._();
  static const bg       = Color(0xFFEBEBEC);
  static const surface  = Color(0xFFFFFFFF);
  static const surface2 = Color(0xFFF4F4F6);
  static const border   = Color(0xFFD8D8DC);
  static const navy     = Color(0xFF142B58);
  static const blue     = Color(0xFF2E65C3);
  static const green    = Color(0xFF37A66F);
  static const error    = Color(0xFFD93025);
  static const text     = Color(0xFF142B58);
  static const muted    = Color(0xFF4A5568);
  static const gold     = Color(0xFFD4A017);
  static const silver   = Color(0xFF9E9E9E);
  static const bronze   = Color(0xFFB07D3A);
}

// ─── SEMANTIC COLOR TOKENS ────────────────────────────────────────────────────
class AppColors {
  AppColors._();
  static Color bg(BuildContext ctx)        => _d(ctx) ? DarkColors.bg        : LightColors.bg;
  static Color surface(BuildContext ctx)   => _d(ctx) ? DarkColors.surface   : LightColors.surface;
  static Color surface2(BuildContext ctx)  => _d(ctx) ? DarkColors.surface2  : LightColors.surface2;
  static Color border(BuildContext ctx)    => _d(ctx) ? DarkColors.border    : LightColors.border;
  static Color text(BuildContext ctx)      => _d(ctx) ? DarkColors.text      : LightColors.text;
  static Color muted(BuildContext ctx)     => _d(ctx) ? DarkColors.muted     : LightColors.muted;
  static Color primary(BuildContext ctx)   => _d(ctx) ? DarkColors.primary   : LightColors.blue;
  static Color secondary(BuildContext ctx) => _d(ctx) ? DarkColors.secondary : LightColors.green;
  static Color accent(BuildContext ctx)    => _d(ctx) ? DarkColors.accent    : LightColors.gold;
  static Color error(BuildContext ctx)     => _d(ctx) ? DarkColors.error     : LightColors.error;

  static Color get gold   => DarkColors.gold;
  static Color get silver => DarkColors.silver;
  static Color get bronze => DarkColors.bronze;

  static const darkBg       = DarkColors.bg;
  static const darkSurface  = DarkColors.surface;
  static const darkSurface2 = DarkColors.surface2;
  static const darkBorder   = DarkColors.border;
  static const cyan         = DarkColors.primary;
  static const lime         = DarkColors.secondary;
  static const amber        = DarkColors.accent;
  static const coral        = DarkColors.error;
  static const lightBg      = LightColors.bg;
  static const lightSurface = LightColors.surface;
  static const navy         = LightColors.navy;
  static const blue         = LightColors.blue;
  static const green        = LightColors.green;

  static bool _d(BuildContext ctx) =>
      Theme.of(ctx).brightness == Brightness.dark;
}

class AppTextStyles {
  AppTextStyles._();

  /// Hero titles, display numbers — Plus Jakarta Sans (readable at large sizes)
  static TextStyle display(double size, {Color? color, double? letterSpacing, BuildContext? context}) {
    final isAr = context != null && Localizations.localeOf(context).languageCode == 'ar';
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
  static TextStyle heading(double size, {Color? color, double? letterSpacing, BuildContext? context}) {
    final isAr = context != null && Localizations.localeOf(context).languageCode == 'ar';
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
  static TextStyle body(double size, {Color? color, FontWeight? weight, BuildContext? context}) {
    final isAr = context != null && Localizations.localeOf(context).languageCode == 'ar';
    if (isAr) return arabicBody(size * 0.9, color: color, weight: weight);
    return GoogleFonts.inter(
      fontSize: size,
      fontWeight: weight ?? FontWeight.w500,
      color: color,
      height: 1.55,
      letterSpacing: 0.2,
    );
  }

  static TextStyle arabicBody(double size, {Color? color, FontWeight? weight}) =>
      GoogleFonts.notoKufiArabic(
        fontSize: size,
        fontWeight: weight ?? FontWeight.w500,
        color: color,
        height: 1.6,
      );

  static TextStyle arabicHeading(double size, {Color? color, double? letterSpacing}) =>
      GoogleFonts.notoKufiArabic(
        fontSize: size,
        fontWeight: FontWeight.w700,
        color: color,
        height: 1.4,
      );

  static TextStyle arabicDisplay(double size, {Color? color, double? letterSpacing}) =>
      GoogleFonts.notoKufiArabic(
        fontSize: size,
        fontWeight: FontWeight.w800,
        color: color,
        height: 1.3,
      );

  /// Uppercase field labels & badges
  static TextStyle label({Color? color, double size = 12.5, FontWeight? weight, BuildContext? context}) {
    final isAr = context != null && Localizations.localeOf(context).languageCode == 'ar';
    if (isAr) return arabicBody(size * 0.9, color: color, weight: weight ?? FontWeight.w600);
    return GoogleFonts.inter(
      fontSize: size,
      fontWeight: weight ?? FontWeight.w600,
      color: color,
      letterSpacing: 0.55,
      height: 1.45,
    );
  }

  /// Numbers, stats, scores
  static TextStyle stat(double size, {Color? color, FontWeight? weight, BuildContext? context}) {
    final isAr = context != null && Localizations.localeOf(context).languageCode == 'ar';
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
      primary:   DarkColors.primary,
      secondary: DarkColors.secondary,
      tertiary:  DarkColors.accent,
      error:     DarkColors.error,
      surface:   DarkColors.surface,
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
      selectedItemColor:   DarkColors.primary,
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
      primary:   LightColors.blue,
      secondary: LightColors.green,
      tertiary:  LightColors.gold,
      error:     LightColors.error,
      surface:   LightColors.surface,
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
      selectedItemColor:   LightColors.blue,
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
