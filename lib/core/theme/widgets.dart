import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../theme/animations.dart';
import '../state/app_state.dart';
import '../state/notification_state.dart';
import '../theme/theme_provider.dart';
import '../models/models.dart';
import '../../l10n/app_localizations.dart';
import '../../features/auth/presentation/login_screen.dart';

// ─── THEME HELPERS ────────────────────────────────────────────────────────────
extension ThemeX on BuildContext {
  bool get isDark        => Theme.of(this).brightness == Brightness.dark;
  double get screenWidth => MediaQuery.sizeOf(this).width;
  bool get isSmallPhone  => screenWidth < 360;
  bool get isPhone       => screenWidth < 600;
  bool get isTablet      => screenWidth >= 600;
  double get hPadding {
    final w = screenWidth;
    if (w < 360) return 14;
    if (w < 420) return 16;
    if (w < 600) return 20;
    return 24;
  }
  Color get bgColor      => AppColors.bg(this);
  Color get surfaceColor => AppColors.surface(this);
  Color get surface2Color=> AppColors.surface2(this);
  Color get borderColor  => AppColors.border(this);
  Color get textColor    => AppColors.text(this);
  Color get mutedColor   => AppColors.muted(this);
  Color get primaryColor => AppColors.primary(this);
  Color get secondaryColor=>AppColors.secondary(this);
  Color get accentColor  => AppColors.accent(this);
  Color get errorColor   => AppColors.error(this);
}

// ─── MUSTER APP BAR ───────────────────────────────────────────────────────────
class MusterAppBar extends StatelessWidget implements PreferredSizeWidget {
  final VoidCallback? onNotificationTap;

  const MusterAppBar({
    super.key,
    @Deprecated('Use onNotificationTap; badge is now driven by NotificationState')
    bool hasNotification = false,
    this.onNotificationTap,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight + 10);

  @override
  Widget build(BuildContext context) {
    final isDark       = context.isDark;
    final primary      = context.primaryColor;
    final surf         = context.surfaceColor;
    final border       = context.borderColor;
    final bg           = context.bgColor;
    final state        = context.read<AppState>();
    final themeProvider = context.read<ThemeProvider>();
    final isAr         = Localizations.localeOf(context).languageCode == 'ar';
    final unreadCount  = context.watch<NotificationState>().unreadCount;
    final hasUnread    = unreadCount > 0;

    return AppBar(
      backgroundColor: isDark ? bg.withValues(alpha: 0.95) : surf,
      surfaceTintColor: Colors.transparent,
      toolbarHeight: kToolbarHeight + 10,
      title: Row(children: [
        Container(
          width: 34, height: 34,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: isDark
                  ? [DarkColors.primary, const Color(0xFF0097A7)]
                  : [LightColors.blue, LightColors.navy],
              begin: Alignment.topLeft, end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(child: Icon(
            state.user.role.icon,
            color: Colors.white,
            size: 18,
          )),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('MUSTER',
                  style: AppTextStyles.display(14, color: primary, letterSpacing: 0, context: context),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis),
              Row(mainAxisSize: MainAxisSize.min, children: [
                Flexible(child: Text(state.user.role.label,
                    style: AppTextStyles.label(color: context.mutedColor, context: context).copyWith(fontSize: 11),
                    overflow: TextOverflow.ellipsis)),
                if (state.user.semester.isNotEmpty) ...[
                  const SizedBox(width: 5),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                    decoration: BoxDecoration(
                      color: context.secondaryColor.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(state.user.semester,
                        style: AppTextStyles.label(color: context.secondaryColor, size: 9, context: context),
                        overflow: TextOverflow.ellipsis),
                  ),
                ],
              ]),
            ],
          ),
        ),
      ]),
      actions: [
        // Language toggle
        IconButton(
          onPressed: themeProvider.toggleLanguage,
          tooltip: isAr ? 'Switch to English' : 'التبديل إلى العربية',
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(minWidth: 38, minHeight: 38),
          icon: _NavIconBox(
            surf: surf, border: border, size: 32,
            child: Text(isAr ? 'EN' : 'AR',
                style: AppTextStyles.label(color: primary, size: 10, context: context).copyWith(fontWeight: FontWeight.bold)),
          ),
        ),
        // Theme toggle
        IconButton(
          onPressed: themeProvider.toggleTheme,
          tooltip: isDark ? 'Switch to Light' : 'Switch to Dark',
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(minWidth: 38, minHeight: 38),
          icon: _NavIconBox(
            surf: surf, border: border, size: 32,
            child: Icon(isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
                color: isDark ? DarkColors.accent : LightColors.navy, size: 17),
          ),
        ),
        // Notification bell with badge
        Stack(clipBehavior: Clip.none, children: [
          IconButton(
            onPressed: onNotificationTap,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 38, minHeight: 38),
            icon: _NavIconBox(
              surf: surf, border: border, size: 32,
              child: Icon(Icons.notifications_rounded,
                  color: isDark ? DarkColors.text : LightColors.navy, size: 18),
            ),
          ),
          if (hasUnread)
            Positioned(
              top: 6, right: 6,
              child: Container(
                width: 8, height: 8,
                decoration: BoxDecoration(
                  color: context.errorColor,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isDark ? DarkColors.bg : LightColors.surface,
                    width: 1.5,
                  ),
                ),
              ),
            ),
        ]),
        // Sign out
        IconButton(
          onPressed: () => _showSignOutDialog(context),
          tooltip: 'Sign Out',
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(minWidth: 38, minHeight: 38),
          icon: _NavIconBox(
            surf: surf, border: border, size: 32,
            child: Icon(Icons.logout_rounded, color: context.errorColor, size: 16),
          ),
        ),
        const SizedBox(width: 6),
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(height: 1, color: border.withValues(alpha: 0.5)),
      ),
    );
  }

  void _showSignOutDialog(BuildContext context) {
    showDialog(context: context, builder: (_) => const MusterSignOutDialog());
  }
}

// ─── SHARED SIGN-OUT DIALOG ───────────────────────────────────────────────────
class MusterSignOutDialog extends StatelessWidget {
  const MusterSignOutDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final l       = AppLocalizations.of(context)!;
    final surf    = context.surfaceColor;
    final txt     = context.textColor;
    final muted   = context.mutedColor;
    final errC    = context.errorColor;
    final border  = context.borderColor;

    return AlertDialog(
      backgroundColor: surf,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Row(children: [
        Container(
          width: 36, height: 36,
          decoration: BoxDecoration(
            color: errC.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(Icons.logout_rounded, color: errC, size: 18),
        ),
        const SizedBox(width: 10),
        Text(l.signOut, style: AppTextStyles.heading(18, color: txt, context: context)),
      ]),
      content: Text(
        l.signOutConfirm,
        style: AppTextStyles.body(14, color: muted, context: context),
      ),
      actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      actions: [
        Row(children: [
          Expanded(
            child: OutlinedButton(
              onPressed: () => Navigator.pop(context),
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: border),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: Text(l.cancel,              style: AppTextStyles.body(14, color: muted, context: context)),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () async {
                Navigator.pop(context);
                await context.read<AppState>().logout();
                if (!context.mounted) return;
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                  (_) => false,
                );
              },
              icon: const Icon(Icons.logout_rounded, size: 16),
              label: Text(l.signOut, style: AppTextStyles.body(14, color: Colors.white, weight: FontWeight.w600, context: context)),
              style: ElevatedButton.styleFrom(
                backgroundColor: errC,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
        ]),
      ],
    );
  }
}

class _NavIconBox extends StatelessWidget {
  final Widget child;
  final Color surf, border;
  final double size;
  const _NavIconBox({required this.child, required this.surf, required this.border, this.size = 34});
  @override
  Widget build(BuildContext context) => Container(
    width: size, height: size,
    decoration: BoxDecoration(
      color: surf,
      borderRadius: BorderRadius.circular(10),
      border: Border.all(color: border),
    ),
    child: Center(child: child),
  );
}

// ─── APP PILL ─────────────────────────────────────────────────────────────────
class AppPill extends StatelessWidget {
  final String label;
  final Color color;
  final VoidCallback? onTap;
  final double fontSize;

  const AppPill({
    super.key,
    required this.label,
    required this.color,
    this.onTap,
    this.fontSize = 12,
  });

  @override
  Widget build(BuildContext context) {
    final pill = Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: context.isDark ? 0.13 : 0.10),
        borderRadius: BorderRadius.circular(100),
        border: Border.all(color: color.withValues(alpha: context.isDark ? 0.4 : 0.45)),
      ),
      child: Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: AppTextStyles.label(color: color, size: fontSize, context: context),
      ),
    );
    if (onTap == null) return pill;
    return PressScale(onTap: onTap, scale: 0.92, child: pill);
  }
}

// ─── APP CARD ─────────────────────────────────────────────────────────────────
class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final VoidCallback? onTap;
  final Color? glowColor;
  final Gradient? gradient;
  final double borderRadius;

  const AppCard({
    super.key,
    required this.child,
    this.padding,
    this.onTap,
    this.glowColor,
    this.gradient,
    this.borderRadius = 20,
  });

  @override
  Widget build(BuildContext context) {
    final surf   = context.surfaceColor;
    final border = context.borderColor;
    final isDark = context.isDark;

    final card = AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      padding: padding ?? const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: gradient == null ? surf : null,
        gradient: gradient,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(color: glowColor?.withValues(alpha: 0.3) ?? border),
        boxShadow: [
          if (glowColor != null)
            BoxShadow(
              color: glowColor!.withValues(alpha: isDark ? 0.08 : 0.12),
              blurRadius: 20,
            ),
          if (!isDark)
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
        ],
      ),
      child: child,
    );

    if (onTap == null) return card;
    return PressScale(onTap: onTap, child: card);
  }
}

// ─── SECTION LABEL ────────────────────────────────────────────────────────────
class SectionLabel extends StatelessWidget {
  final String text;
  final EdgeInsetsGeometry? margin;

  const SectionLabel(this.text, {super.key, this.margin});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: margin ?? const EdgeInsets.only(bottom: 14),
      child: Text(
        text.toUpperCase(),
        style: AppTextStyles.label(color: context.mutedColor, size: 13, context: context),
      ),
    );
  }
}

// ─── MUSTER DIVIDER ───────────────────────────────────────────────────────────
class MusterDivider extends StatelessWidget {
  const MusterDivider({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;
    final accent = isDark ? DarkColors.error : LightColors.blue;
    final fadeTo = context.borderColor;
    return Container(
      height: 2,
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [accent.withValues(alpha: 0.7), fadeTo],
          stops: const [0.3, 0.3],
        ),
      ),
    );
  }
}

// ─── PROGRESS BAR ─────────────────────────────────────────────────────────────
/// Animated progress bar — tweens from 0 → value on first render.
class AppProgressBar extends StatefulWidget {
  final double value;
  final Color? color;
  final double height;

  const AppProgressBar({
    super.key,
    required this.value,
    this.color,
    this.height = 5,
  });

  @override
  State<AppProgressBar> createState() => _AppProgressBarState();
}

class _AppProgressBarState extends State<AppProgressBar>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _anim = Tween<double>(begin: 0, end: widget.value.clamp(0.0, 1.0))
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic));
    _ctrl.forward();
  }

  @override
  void didUpdateWidget(AppProgressBar old) {
    super.didUpdateWidget(old);
    if (old.value != widget.value) {
      _anim = Tween<double>(begin: _anim.value, end: widget.value.clamp(0.0, 1.0))
          .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic));
      _ctrl
        ..reset()
        ..forward();
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final barColor = widget.color ?? context.primaryColor;
    return AnimatedBuilder(
      animation: _anim,
      builder: (_, __) => LayoutBuilder(
        builder: (_, constraints) => Container(
          height: widget.height,
          width: constraints.maxWidth,
          decoration: BoxDecoration(
            color: barColor.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(widget.height),
          ),
          child: Align(
            alignment: Alignment.centerLeft,
            child: FractionallySizedBox(
              widthFactor: _anim.value,
              child: Container(
                decoration: BoxDecoration(
                  color: barColor,
                  borderRadius: BorderRadius.circular(widget.height),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─── AVATAR ───────────────────────────────────────────────────────────────────
class AppAvatar extends StatelessWidget {
  final String initials;
  final double size;
  final List<Color>? gradientColors;
  final String? photoPath;

  const AppAvatar({
    super.key,
    required this.initials,
    this.size = 48,
    this.gradientColors,
    this.photoPath,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;
    final defaultGrad = isDark
        ? const [Color(0xFF1a6b5a), Color(0xFF0d9f73)]
        : [LightColors.blue, LightColors.navy];

    // If we have a photo, show it as a circle image
    if (photoPath != null && photoPath!.isNotEmpty) {
      return ClipOval(
        child: Image.asset(
          photoPath!,
          width: size, height: size,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _gradientCircle(context, defaultGrad),
        ),
      );
    }

    return _gradientCircle(context, defaultGrad);
  }

  Widget _gradientCircle(BuildContext context, List<Color> defaultGrad) {
    return Container(
      width: size, height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: gradientColors ?? defaultGrad,
          begin: Alignment.topLeft, end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: Text(
          initials,
          style: AppTextStyles.display(size * 0.32, color: Colors.white, context: context),
        ),
      ),
    );
  }
}

// ─── STAT BOX ─────────────────────────────────────────────────────────────────
class StatBox extends StatelessWidget {
  final String value;
  final String label;
  final Color? color;

  const StatBox({
    super.key,
    required this.value,
    required this.label,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final c = color ?? context.primaryColor;
    final numeric = int.tryParse(value);
    return AppCard(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        FittedBox(
          fit: BoxFit.scaleDown,
          child: numeric != null
            ? AnimatedCounter(
                target: numeric,
                style: AppTextStyles.stat(24, color: c, context: context),
                duration: const Duration(milliseconds: 900),
              )
            : Text(value, style: AppTextStyles.stat(24, color: c, context: context)),
        ),
        const SizedBox(height: 4),
        Text(label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
          style: AppTextStyles.label(color: context.mutedColor, size: 11, context: context)),
      ]),
    );
  }
}

// ─── TOAST OVERLAY ────────────────────────────────────────────────────────────
class ToastOverlay extends StatefulWidget {
  final String message;
  const ToastOverlay({super.key, required this.message});
  @override
  State<ToastOverlay> createState() => _ToastOverlayState();
}

class _ToastOverlayState extends State<ToastOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<Offset> _slide;
  late Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: MusterAnim.normal);
    _slide = Tween<Offset>(
      begin: const Offset(0, -1.4),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _ctrl, curve: MusterAnim.snap));
    _opacity = CurvedAnimation(parent: _ctrl,
        curve: const Interval(0, 0.4, curve: Curves.easeOut));
    _ctrl.forward();
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final primary = context.primaryColor;
    return Positioned(
      top: MediaQuery.of(context).padding.top + 16,
      left: 24, right: 24,
      child: AnimatedBuilder(
        animation: _ctrl,
        builder: (_, child) => FadeTransition(
          opacity: _opacity,
          child: SlideTransition(position: _slide, child: child),
        ),
        child: Material(
          color: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            decoration: BoxDecoration(
              color: context.surface2Color,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: primary.withValues(alpha: 0.4)),
              boxShadow: [
                BoxShadow(color: primary.withValues(alpha: 0.12), blurRadius: 24),
                BoxShadow(
                  color: Colors.black.withValues(alpha: context.isDark ? 0.5 : 0.15),
                  blurRadius: 16,
                ),
              ],
            ),
            child: Text(
              widget.message,
              textAlign: TextAlign.center,
              style: AppTextStyles.body(14, color: primary, weight: FontWeight.w600, context: context),
            ),
          ),
        ),
      ),
    );
  }
}

// ─── QUICK ACCESS CARD ────────────────────────────────────────────────────────
class QuickAccessCard extends StatelessWidget {
  final String icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const QuickAccessCard({
    super.key,
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onTap,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 36, height: 36,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: color.withValues(alpha: 0.25)),
            ),
            child: Center(child: Text(icon, style: const TextStyle(fontSize: 17))),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(label,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.body(13,
                color: context.textColor,
                weight: FontWeight.w600,
                context: context)),
          ),
        ],
      ),
    );
  }
}

// ─── STAGGER ITEM ─────────────────────────────────────────────────────────────
/// Fades + slides a child in after [delay]. Replays whenever the widget
/// is first mounted (e.g. when a tab becomes visible).
class StaggerItem extends StatefulWidget {
  final Widget child;
  final Duration delay;
  final Duration duration;

  const StaggerItem({
    super.key,
    required this.child,
    required this.delay,
    this.duration = const Duration(milliseconds: 380),
  });

  @override
  State<StaggerItem> createState() => _StaggerItemState();
}

class _StaggerItemState extends State<StaggerItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _fade;
  late Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: widget.duration);
    _fade  = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _slide = Tween<Offset>(begin: const Offset(0, 0.08), end: Offset.zero)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
    Future.delayed(widget.delay, () {
      if (mounted) _ctrl.forward();
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => FadeTransition(
        opacity: _fade,
        child: SlideTransition(position: _slide, child: widget.child),
      );
}

// ─── SHIMMER OVERLAY ─────────────────────────────────────────────────────────
/// Sweeps a translucent shimmer highlight across [child] in a loop.
/// Useful for banners and hero cards to add a polished gleam effect.
class ShimmerOverlay extends StatefulWidget {
  final Widget child;
  final Color shimmerColor;
  final Duration duration;

  const ShimmerOverlay({
    super.key,
    required this.child,
    this.shimmerColor = Colors.white,
    this.duration = const Duration(milliseconds: 2200),
  });

  @override
  State<ShimmerOverlay> createState() => _ShimmerOverlayState();
}

class _ShimmerOverlayState extends State<ShimmerOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: widget.duration)
      ..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        Positioned.fill(
          child: AnimatedBuilder(
            animation: _ctrl,
            builder: (_, __) => ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: CustomPaint(
                size: Size.infinite,
                painter: _ShimmerSweepPainter(
                  progress: _ctrl.value,
                  color: widget.shimmerColor,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _ShimmerSweepPainter extends CustomPainter {
  final double progress;
  final Color color;
  const _ShimmerSweepPainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final x = -size.width + progress * (size.width * 2.5);
    final gradient = LinearGradient(
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
      colors: [
        color.withValues(alpha: 0.0),
        color.withValues(alpha: 0.07),
        color.withValues(alpha: 0.0),
      ],
    );
    final rect = Rect.fromLTWH(x, 0, size.width * 0.6, size.height);
    canvas.drawRect(rect, Paint()..shader = gradient.createShader(rect));
  }

  @override
  bool shouldRepaint(_ShimmerSweepPainter old) => old.progress != progress;
}

// ─── MORPH BUTTON ─────────────────────────────────────────────────────────────
/// A full-width button that morphs into a loading spinner, then a success
/// check mark. Replaces plain ElevatedButton in forms.
class MorphButton extends StatelessWidget {
  final String label;
  final bool loading;
  final bool success;
  final VoidCallback? onPressed;
  final Color? backgroundColor;
  final Color? foregroundColor;

  const MorphButton({
    super.key,
    required this.label,
    required this.loading,
    required this.success,
    required this.onPressed,
    this.backgroundColor,
    this.foregroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final bg = backgroundColor ?? context.primaryColor;
    final fg = foregroundColor ?? Colors.white;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeInOut,
      height: 52,
      decoration: BoxDecoration(
        color: success ? const Color(0xFF22C55E) : bg,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: (success ? const Color(0xFF22C55E) : bg).withValues(alpha: 0.35),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: (loading || success) ? null : onPressed,
          borderRadius: BorderRadius.circular(14),
          child: Center(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 220),
              child: loading
                  ? SizedBox(
                      key: const ValueKey('loading'),
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        color: fg,
                        strokeWidth: 2.5,
                      ),
                    )
                  : success
                      ? Icon(Icons.check_rounded,
                          key: const ValueKey('success'), color: fg, size: 24)
                      : Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              key: const ValueKey('label'),
                              label,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppTextStyles.body(15,
                                  color: fg, weight: FontWeight.w700, context: context),
                            ),
                          ),
                        ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─── ANIMATED COUNTER ─────────────────────────────────────────────────────────
/// Counts up from 0 to [target] with a configurable [duration].
class AnimatedCounter extends StatelessWidget {
  final int target;
  final TextStyle style;
  final Duration duration;

  const AnimatedCounter({
    super.key,
    required this.target,
    required this.style,
    this.duration = const Duration(milliseconds: 800),
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: target.toDouble()),
      duration: duration,
      curve: Curves.easeOut,
      builder: (_, value, __) =>
          Text(value.round().toString(), style: style),
    );
  }
}
