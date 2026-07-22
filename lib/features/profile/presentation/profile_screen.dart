import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/widgets.dart';
import '../../../core/state/app_state.dart';
import '../../../core/services/firebase_auth_service.dart';
import '../../../l10n/app_localizations.dart';
import '../../../core/state/notification_state.dart';
import '../../auth/presentation/login_screen.dart';
import '../../notifications/presentation/notifications_screen.dart';
import '../../booking/presentation/my_reservations_screen.dart';
import '../../participation_history/presentation/participation_history_screen.dart';
import '../../settings/presentation/settings_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state     = context.watch<AppState>();
    final notifState = context.watch<NotificationState>();
    final user      = state.user;
    final progress  = state.goalProgress;
    final pct       = (progress * 100).round();
    final primary   = context.primaryColor;
    final second    = context.secondaryColor;
    final accent    = context.accentColor;
    final txt       = context.textColor;
    final muted     = context.mutedColor;
    final isDark    = context.isDark;
    final unread    = notifState.unreadCount;

    final heroGrad = isDark
        ? const [Color(0xFF0D2A5A), Color(0xFF12204B), Color(0xFF0A1228)]
        : [LightColors.navy, const Color(0xFF1E3F80), const Color(0xFF142B58)];

    final isAr      = Localizations.localeOf(context).languageCode == 'ar';

    void goTo(Widget screen) => Navigator.push(context,
        MaterialPageRoute(builder: (_) => screen));

    void showAvatarEditor(BuildContext ctx, AppState st) {
      showModalBottomSheet(
        context: ctx,
        backgroundColor: Colors.transparent,
        isScrollControlled: true,
        builder: (_) => ChangeNotifierProvider.value(
          value: st,
          child: _AvatarEditorSheet(initials: st.user.initials),
        ),
      );
    }

    return Scaffold(
      backgroundColor: context.bgColor,
      appBar: AppBar(
        backgroundColor: context.bgColor,
        surfaceTintColor: Colors.transparent,
        title: Text(AppLocalizations.of(context)!.profileTitle, style: AppTextStyles.display(20, color: txt, context: context)),
        actions: [
          // ── Notification bell with badge ──────────────────────────────
          Stack(clipBehavior: Clip.none, children: [
            IconButton(
              onPressed: () => goTo(const NotificationsScreen()),
              icon: Container(
                width: 36, height: 36,
                decoration: BoxDecoration(
                  color: context.surfaceColor,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: context.borderColor),
                ),
                child: const Center(child: Icon(Icons.notifications_rounded, size: 18, color: Color(0xFFF0F4FF))),
              ),
            ),
            if (unread > 0)
              Positioned(
                top: 6, right: 6,
                child: Container(
                  padding: const EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    color: context.errorColor,
                    shape: BoxShape.circle,
                    border: Border.all(color: context.bgColor, width: 1.5),
                  ),
                  child: Text('$unread',
                      style: const TextStyle(color: Colors.white,
                          fontSize: 9, fontWeight: FontWeight.bold)),
                ),
              ),
          ]),
          const SizedBox(width: 6),
          // ── Settings shortcut ─────────────────────────────────────────
          IconButton(
            onPressed: () => goTo(const SettingsScreen()),
            icon: Container(
              width: 36, height: 36,
              decoration: BoxDecoration(
                color: context.surfaceColor,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: context.borderColor),
              ),
              child: const Center(child: Icon(Icons.settings_rounded, size: 18, color: Color(0xFFF0F4FF))),
            ),
          ),
          const SizedBox(width: 8),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Divider(height: 1, color: context.borderColor),
        ),
      ),
      body: ListView(
        padding: EdgeInsetsDirectional.only(
          start: 20, end: 20, top: 20,
          bottom: MediaQuery.of(context).padding.bottom + 90,
        ),
        children: [
          // ── Hero card ─────────────────────────────────────────────────
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: heroGrad,
                begin: AlignmentDirectional.topStart, end: AlignmentDirectional.bottomEnd,
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: primary.withValues(alpha: 0.2)),
              boxShadow: [BoxShadow(color: primary.withValues(alpha: 0.08),
                  blurRadius: 24)],
            ),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                // Avatar with tap to open avatar editor
                GestureDetector(
                  onTap: () => showAvatarEditor(context, state),
                  child: Stack(children: [
                    AppAvatar(
                      initials: user.initials,
                      size: 54,
                      gradientColors: state.avatarGradient,
                    ),
                    PositionedDirectional(
                      bottom: 0, end: 0,
                      child: Container(
                        width: 20, height: 20,
                        decoration: BoxDecoration(
                          color: second, shape: BoxShape.circle,
                          border: Border.all(
                              color: isDark ? DarkColors.bg : LightColors.surface,
                              width: 2),
                        ),
                        child: const Icon(Icons.edit, size: 15, color: Colors.black),
                      ),
                    ),
                  ]),
                ),
                const SizedBox(width: 14),
                Expanded(child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(user.name,
                        maxLines: 1, overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.display(16, color: Colors.white, context: context)),
                    const SizedBox(height: 3),
                    Text(user.studentId,
                        maxLines: 1, overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.body(15, color: Colors.white, context: context)),
                    Text(user.email,
                        maxLines: 1, overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.body(13, color: Colors.white38, context: context)),
                  ],
                )),
              ]),
              const SizedBox(height: 14),
              Wrap(spacing: 6, runSpacing: 6, children: [
                AppPill(label: user.faculty,                      color: primary),
                AppPill(label: '#${user.rank} ${AppLocalizations.of(context)!.rank}',              color: accent),
                AppPill(label: '${state.enrolledCount} ${AppLocalizations.of(context)!.enrolled}', color: second),
              ]),
              const SizedBox(height: 14),
              Row(children: [
        _MiniMetric(value: '${user.points}', label: AppLocalizations.of(context)!.points.toUpperCase(), color: primary),
        const SizedBox(width: 8),
        _MiniMetric(value: '${user.cgpa}',   label: AppLocalizations.of(context)!.cgpa.toUpperCase(), color: accent),
        const SizedBox(width: 8),
        _MiniMetric(value: '$pct%',           label: isAr ? 'الهدف' : 'GOAL',   color: second),
      ]),
            ]),
          ),
          const SizedBox(height: 16),

          // ── Semester goal ──────────────────────────────────────────────
          AppCard(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Expanded(child: Text(AppLocalizations.of(context)!.semesterGoal,
                    maxLines: 1, overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.body(15, color: txt, weight: FontWeight.w600, context: context))),
                const SizedBox(width: 8),
                Flexible(child: Text('${state.enrolledCount} / ${user.targetEvents} ${AppLocalizations.of(context)!.eventsLabel}',
                    maxLines: 1, overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.body(16, color: muted, context: context))),
              ]),
              const SizedBox(height: 10),
              AppProgressBar(
                  value: progress,
                  color: pct >= 100 ? second : primary, height: 6),
              if (pct >= 100) ...[
                const SizedBox(height: 8),
                Text(AppLocalizations.of(context)!.goalAchieved,
                    style: AppTextStyles.body(15, color: second,
                        weight: FontWeight.w600, context: context)),
              ],
            ]),
          ),
          const SizedBox(height: 20),

          // ── Stats ─────────────────────────────────────────────────────
          SectionLabel(AppLocalizations.of(context)!.statistics),
          context.isSmallPhone
              ? Column(children: [
                  Row(children: [
                    Expanded(child: StatBox(value: '${user.stats.eventsJoined}',
                        label: AppLocalizations.of(context)!.eventsLabel, color: primary)),
                    const SizedBox(width: 10),
                    Expanded(child: StatBox(value: '${user.stats.bookingsMade}',
                        label: AppLocalizations.of(context)!.bookings, color: txt)),
                  ]),
                  const SizedBox(height: 10),
                  StatBox(value: '${user.stats.wins}',
                      label: AppLocalizations.of(context)!.wins, color: second),
                ])
              : Row(children: [
                  Expanded(child: StatBox(value: '${user.stats.eventsJoined}',
                      label: AppLocalizations.of(context)!.eventsLabel, color: primary)),
                  const SizedBox(width: 10),
                  Expanded(child: StatBox(value: '${user.stats.bookingsMade}',
                      label: AppLocalizations.of(context)!.bookings, color: txt)),
                  const SizedBox(width: 10),
                  Expanded(child: StatBox(value: '${user.stats.wins}',
                      label: AppLocalizations.of(context)!.wins, color: second)),
                ]),
          const SizedBox(height: 20),

          // ── Achievements ───────────────────────────────────────────────
          if (user.achievements.isNotEmpty) ...[
            SectionLabel(AppLocalizations.of(context)!.achievementsBadges),
            GridView.count(
              crossAxisCount: 2, shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 10, crossAxisSpacing: 10, childAspectRatio: 2.4,
              children: user.achievements.map((a) => AppCard(
                glowColor: a.color,
                gradient: LinearGradient(
                  colors: [a.color.withValues(alpha: 0.10), context.surfaceColor],
                  begin: AlignmentDirectional.topStart, end: AlignmentDirectional.bottomEnd,
                ),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                child: Stack(children: [
                  Row(children: [
                    Text(a.icon, style: const TextStyle(fontSize: 22)),
                    const SizedBox(width: 8),
                    Expanded(child: Text(a.label,
                        style: AppTextStyles.body(16, color: txt, weight: FontWeight.w600, context: context),
                        maxLines: 2, overflow: TextOverflow.ellipsis)),
                  ]),
                  // Share achievement button
                  PositionedDirectional(top: 0, end: 0,
                    child: GestureDetector(
                      onTap: () => _shareAchievement(context, a),
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: a.color.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(Icons.share_rounded, size: 14, color: a.color),
                      ),
                    )),
                ]),
              )).toList(),
            ),
            const SizedBox(height: 20),
          ],

          // ── Menu ──────────────────────────────────────────────────────
          SectionLabel(AppLocalizations.of(context)!.quickAccess),
          const SizedBox(height: 10),
          ...[
            _MenuItem(
              icon: Icons.notifications_rounded, label: AppLocalizations.of(context)!.notifications,
              badge: unread > 0 ? '$unread' : null,
              badgeColor: context.errorColor,
              onTap: () => goTo(const NotificationsScreen()),
            ),
            _MenuItem(
              icon: Icons.calendar_month_rounded, label: AppLocalizations.of(context)!.myReservations,
              sub: AppLocalizations.of(context)!.viewManageBookings,
              onTap: () => goTo(const MyReservationsScreen()),
            ),
            _MenuItem(
              icon: Icons.sports_rounded, label: AppLocalizations.of(context)!.participationHistory,
              sub: AppLocalizations.of(context)!.activitiesEventsBookings,
              onTap: () => goTo(const ParticipationHistoryScreen()),
            ),
            _MenuItem(
              icon: Icons.settings_rounded, label: AppLocalizations.of(context)!.settings,
              sub: AppLocalizations.of(context)!.updateProfilePrefs,
              onTap: () => goTo(const SettingsScreen()),
            ),
          ].map((item) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: AppCard(
              onTap: item.onTap,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(children: [
                Icon(item.icon, size: 22, color: context.primaryColor),
                const SizedBox(width: 12),
                Expanded(child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                  Text(item.label, maxLines: 1, overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.body(16, color: txt, weight: FontWeight.w600, context: context)),
                  if (item.sub != null)
                    Text(item.sub!, maxLines: 1, overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.body(15, color: muted, context: context)),
                ])),
                if (item.badge != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: (item.badgeColor ?? primary).withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(item.badge!,
                        style: AppTextStyles.label(
                            color: item.badgeColor ?? primary, context: context)
                            .copyWith(fontSize: 11)),
                  ),
                const SizedBox(width: 6),
                Icon(
                  Localizations.localeOf(context).languageCode == 'ar'
                      ? Icons.chevron_left
                      : Icons.chevron_right,
                  color: muted,
                  size: 20,
                ),
              ]),
            ),
          )),

          const SizedBox(height: 4),
          _GlowSignOutButton(),
        ],
      ),
    );
  }
}

// ── Achievement Share ─────────────────────────────────────────────────────────
void _shareAchievement(BuildContext context, dynamic achievement) {
  final second = context.secondaryColor;
  final isAr = Localizations.localeOf(context).languageCode == 'ar';
  showModalBottomSheet(
    context: context,
    backgroundColor: context.surfaceColor,
    shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
    builder: (ctx) => Padding(
      padding: EdgeInsets.fromLTRB(24, 20, 24,
          MediaQuery.of(ctx).padding.bottom + 24),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Container(width: 36, height: 4,
            decoration: BoxDecoration(color: ctx.borderColor,
                borderRadius: BorderRadius.circular(2))),
        const SizedBox(height: 20),
        // Badge preview
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [achievement.color.withValues(alpha: 0.15), ctx.bgColor],
              begin: AlignmentDirectional.topStart, end: AlignmentDirectional.bottomEnd,
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: achievement.color.withValues(alpha: 0.4)),
            boxShadow: [BoxShadow(color: achievement.color.withValues(alpha: 0.2),
                blurRadius: 20, spreadRadius: 2)],
          ),
          child: Column(children: [
            Text(achievement.icon, style: const TextStyle(fontSize: 48)),
            const SizedBox(height: 12),
            Text(achievement.label,
                style: AppTextStyles.heading(18, color: ctx.textColor, context: ctx),
                textAlign: TextAlign.center),
            const SizedBox(height: 6),
            Text(isAr ? 'تم تحقيقه في MUSTER Sport' : 'Earned at MUSTER Sport',
                style: AppTextStyles.body(13, color: ctx.mutedColor, context: ctx)),
          ]),
        ),
        const SizedBox(height: 20),
        Text(isAr ? 'مشاركة الإنجاز' : 'Share Achievement',
            style: AppTextStyles.heading(16, color: ctx.textColor, context: ctx)),
        const SizedBox(height: 6),
        Text(isAr ? 'شارك شبكتك هذا الإنجاز' : 'Let your network know about this achievement',
            style: AppTextStyles.body(13, color: ctx.mutedColor, context: ctx),
            textAlign: TextAlign.center),
        const SizedBox(height: 20),
        // Share channels
        Wrap(
          alignment: WrapAlignment.spaceEvenly,
          spacing: 12,
          runSpacing: 16,
          children: [
            _ShareChannel(emoji: '📸', label: isAr ? 'القصة' : 'Story',   color: const Color(0xFFE1306C), onTap: () => Navigator.pop(ctx)),
            _ShareChannel(emoji: '🐦', label: 'Twitter', color: const Color(0xFF1DA1F2), onTap: () => Navigator.pop(ctx)),
            _ShareChannel(emoji: '💼', label: 'LinkedIn',color: const Color(0xFF0A66C2), onTap: () => Navigator.pop(ctx)),
            _ShareChannel(emoji: '🔗', label: isAr ? 'نسخ الرابط' : 'Copy Link',color: second,                  onTap: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text(isAr ? 'تم نسخ الرابط!' : 'Link copied to clipboard!'),
                backgroundColor: second,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ));
            }),
          ],
        ),
      ]),
    ),
  );
}

class _ShareChannel extends StatelessWidget {
  final String emoji, label;
  final Color color;
  final VoidCallback onTap;
  const _ShareChannel({required this.emoji, required this.label, required this.color, required this.onTap});
  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Column(mainAxisSize: MainAxisSize.min, children: [
      Container(
        width: 52, height: 52,
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          shape: BoxShape.circle,
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Center(child: Text(emoji, style: const TextStyle(fontSize: 22))),
      ),
      const SizedBox(height: 6),
      Text(label, style: AppTextStyles.body(11, color: context.mutedColor, context: context)),
    ]),
  );
}

class _MenuItem {
  final IconData icon;
  final String label;
  final String? sub, badge;
  final Color? badgeColor;
  final VoidCallback onTap;
  const _MenuItem({
    required this.icon, required this.label,
    this.sub, this.badge, this.badgeColor, required this.onTap,
  });
}

// ── GLOW SIGN OUT ─────────────────────────────────────────────────────────────
class _GlowSignOutButton extends StatefulWidget {
  @override State<_GlowSignOutButton> createState() => _GlowSignOutButtonState();
}
class _GlowSignOutButtonState extends State<_GlowSignOutButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double>   _glow;
  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this,
        duration: const Duration(milliseconds: 1800))..repeat(reverse: true);
    _glow = Tween<double>(begin: 0.3, end: 0.85)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }
  @override void dispose() { _ctrl.dispose(); super.dispose(); }

  Future<void> _signOut() async {
    // Capture context-dependent values before the async gap
    final surfaceColor = context.surfaceColor;
    final textColor = context.textColor;
    final mutedColor = context.mutedColor;
    final errorColor = context.errorColor;
    final l = AppLocalizations.of(context)!;
    final nav = Navigator.of(context);
    final appState = context.read<AppState>();

    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: surfaceColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(l.signOut,
            style: AppTextStyles.heading(18, color: textColor, context: context)),
        content: Text(l.signOutConfirm,
            style: AppTextStyles.body(16, color: mutedColor, context: context)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false),
              child: Text(l.cancel,
                  style: AppTextStyles.body(16, color: mutedColor, context: context))),
          GestureDetector(
            onTap: () => Navigator.pop(context, true),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(color: errorColor,
                  borderRadius: BorderRadius.circular(10)),
              child: Text(l.signOut, style: AppTextStyles.body(16,
                  color: Colors.white, weight: FontWeight.w700, context: context)),
            ),
          ),
        ],
      ),
    );
    if (confirm == true && mounted) {
      await FirebaseAuthService.instance.signOut();
      await appState.logout();
      if (!mounted) return;
      nav.pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LoginScreen()), (_) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final errorC = context.errorColor;
    return AnimatedBuilder(
      animation: _glow,
      builder: (_, __) => GestureDetector(
        onTap: _signOut,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          decoration: BoxDecoration(
            color: context.surfaceColor,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
                color: errorC.withValues(alpha: 0.4 + 0.3 * _glow.value)),
            boxShadow: [BoxShadow(
              color: errorC.withValues(alpha: 0.20 * _glow.value),
              blurRadius: 18 * _glow.value, spreadRadius: 1,
            )],
          ),
          child: Row(children: [
            Icon(Icons.logout_rounded, color: errorC, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(AppLocalizations.of(context)!.signOut,
                  style: AppTextStyles.body(16, color: errorC, weight: FontWeight.w600, context: context),
                  maxLines: 1, overflow: TextOverflow.ellipsis),
            ),
          ]),
        ),
      ),
    );
  }
}

class _MiniMetric extends StatelessWidget {
  final String value, label;
  final Color color;
  const _MiniMetric(
      {required this.value, required this.label, required this.color});
  @override
  Widget build(BuildContext context) => Expanded(
    child: Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Column(children: [
        Text(value,
            style: AppTextStyles.heading(15, color: color, context: context),
            maxLines: 1, overflow: TextOverflow.ellipsis),
        const SizedBox(height: 2),
        Text(label,
            style: AppTextStyles.label(color: Colors.white60, context: context),
            maxLines: 1, overflow: TextOverflow.ellipsis),
      ]),
    ),
  );
}

// ─── AVATAR EDITOR SHEET ──────────────────────────────────────────────────────
class _AvatarEditorSheet extends StatefulWidget {
  final String initials;
  const _AvatarEditorSheet({required this.initials});
  @override
  State<_AvatarEditorSheet> createState() => _AvatarEditorSheetState();
}

class _AvatarEditorSheetState extends State<_AvatarEditorSheet> {
  static const _presets = [
    // [start, end]
    [Color(0xFF1565C0), Color(0xFF0097A7)], // ocean blue
    [Color(0xFF1a6b5a), Color(0xFF0d9f73)], // emerald
    [Color(0xFF7B1FA2), Color(0xFFE91E63)], // purple-pink
    [Color(0xFFE53935), Color(0xFFFF6F00)], // fire
    [Color(0xFF00695C), Color(0xFF1B5E20)], // forest
    [Color(0xFF283593), Color(0xFF6A1B9A)], // deep purple
    [Color(0xFFBF360C), Color(0xFFE65100)], // burnt orange
    [Color(0xFF006064), Color(0xFF004D40)], // teal-dark
    [Color(0xFF37474F), Color(0xFF546E7A)], // slate
    [Color(0xFFC62828), Color(0xFFAD1457)], // crimson
  ];

  int? _selected;

  @override
  Widget build(BuildContext context) {
    final state  = context.watch<AppState>();
    final surf   = context.surfaceColor;
    final border = context.borderColor;
    final txt    = context.textColor;
    final muted  = context.mutedColor;
    final second = context.secondaryColor;
    final isAr   = Localizations.localeOf(context).languageCode == 'ar';

    return Container(
      decoration: BoxDecoration(
        color: surf,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        border: Border.all(color: border),
      ),
      padding: EdgeInsets.only(
        left: 24, right: 24, top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 32,
      ),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Center(child: Container(width: 40, height: 4,
            decoration: BoxDecoration(color: border, borderRadius: BorderRadius.circular(99)))),
        const SizedBox(height: 18),
        Text(isAr ? 'تعديل الصورة الرمزية' : 'Edit Avatar', style: AppTextStyles.display(20, color: txt, context: context)),
        const SizedBox(height: 4),
        Text(isAr ? 'اختر ألوان الصورة الرمزية' : 'Choose a color theme for your avatar',
            style: AppTextStyles.body(16, color: muted, context: context)),
        const SizedBox(height: 20),
        // Preview
        Center(
          child: AppAvatar(
            initials: widget.initials,
            size: 72,
            gradientColors: _selected != null
                ? [_presets[_selected!][0], _presets[_selected!][1]]
                : state.avatarGradient,
          ),
        ),
        const SizedBox(height: 20),
        Text(isAr ? 'ألوان الصورة' : 'COLOUR THEMES', style: AppTextStyles.label(color: muted, context: context)),
        const SizedBox(height: 12),
        Wrap(spacing: 12, runSpacing: 12,
          children: List.generate(_presets.length, (i) {
            final selected = _selected == i;
            return GestureDetector(
              onTap: () => setState(() => _selected = i),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                width: 44, height: 44,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [_presets[i][0], _presets[i][1]],
                    begin: AlignmentDirectional.topStart, end: AlignmentDirectional.bottomEnd,
                  ),
                  border: Border.all(
                    color: Colors.white,
                    width: selected ? 3 : 0,
                  ),
                  boxShadow: selected
                      ? [BoxShadow(color: _presets[i][0].withValues(alpha: 0.5), blurRadius: 10)]
                      : null,
                ),
                child: selected
                    ? const Icon(Icons.check, color: Colors.white, size: 18)
                    : null,
              ),
            );
          }),
        ),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _selected == null ? null : () {
              state.updateProfile(
                avatarGradient: [_presets[_selected!][0], _presets[_selected!][1]],
              );
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: second,
              foregroundColor: Colors.white,
              disabledBackgroundColor: second.withValues(alpha: 0.3),
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              elevation: 0,
            ),
            child: Text(isAr ? 'تطبيق' : 'Apply', style: AppTextStyles.body(15,
                color: Colors.white, weight: FontWeight.w700, context: context)),
          ),
        ),
      ]),
    );
  }
}
