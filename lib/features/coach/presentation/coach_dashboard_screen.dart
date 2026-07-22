import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/theme_provider.dart';
import '../../../core/models/activity_models.dart';
import '../../../core/models/models.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/widgets.dart';
import '../../../core/state/app_state.dart';
import '../../../core/state/activity_state.dart';
import '../../../l10n/app_localizations.dart';

// ─── IMPROVEMENT #15: Coach-specific dashboard ────────────────────────────────
// Shows: assigned activities, pending requests summary, quick stats.
// Does NOT expose user management or system admin features.
class CoachDashboardScreen extends StatelessWidget {
  const CoachDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l        = AppLocalizations.of(context)!;
    final state    = context.watch<AppState>();
    final regState = context.watch<ActivityRegistrationState>();
    final user     = state.user;
    final primary  = context.primaryColor;
    final accent   = context.accentColor;
    final second   = context.secondaryColor;
    final txt      = context.textColor;
    final muted    = context.mutedColor;
    final surf     = context.surfaceColor;
    final border   = context.borderColor;

    final allRegs    = regState.all;
    final pending    = regState.pending.length;
    final approved   = allRegs.where((r) => r.status == RegistrationStatus.approved).length;
    final myActivities = kAllActivities.where((a) =>
        a.coach.toLowerCase().contains('coach') ||
        a.coach.toLowerCase().contains(user.name.toLowerCase().split(' ').first.toLowerCase())
    ).take(6).toList();

    return Scaffold(
      backgroundColor: context.bgColor,
      appBar: _CoachAppBar(),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
        children: [
          // ── Greeting ─────────────────────────────────────────────────────
          Text(l.welcomeBack, style: AppTextStyles.body(15, color: muted, context: context)),
          Text(user.name.split(' ').first,
              style: AppTextStyles.display(26, color: primary, context: context)),
          const SizedBox(height: 20),

          // ── Stats row (tap any card → Registrations tab) ─────────────
          GestureDetector(
            onTap: () => context.read<AppState>().setNavIndex(2),
            child: Row(children: [
              _StatCard(value: '$pending',  label: l.pending,  color: accent,  icon: Icons.hourglass_top_rounded),
              const SizedBox(width: 10),
              _StatCard(value: '$approved', label: l.approved, color: second,  icon: Icons.check_circle_rounded),
              const SizedBox(width: 10),
              _StatCard(value: '${allRegs.length}', label: l.total, color: primary, icon: Icons.people_rounded),
            ]),
          ),
          const SizedBox(height: 24),

          // ── Quick action ─────────────────────────────────────────────────
          if (pending > 0) ...[
            GestureDetector(
              onTap: () => context.read<AppState>().setNavIndex(2),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: accent.withValues(alpha: 0.35)),
                ),
                child: Row(children: [
                  Icon(Icons.notifications_active_rounded, color: accent, size: 22),
                  const SizedBox(width: 12),
                  Expanded(child: Text(
                    '$pending ${l.requests} ${l.awaitingReview}',
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.body(14, color: accent, context: context),
                  )),
                  Container(
                    width: 28, height: 28,
                    decoration: BoxDecoration(
                      color: accent.withValues(alpha: 0.18),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(Icons.arrow_forward_ios_rounded, color: accent, size: 14),
                  ),
                ]),
              ),
            ),
            const SizedBox(height: 20),
          ],

          // ── Activities ───────────────────────────────────────────────────
          Text(l.activities, style: AppTextStyles.heading(16, color: txt, context: context)),
          const SizedBox(height: 12),
          ...myActivities.map((a) => Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: surf, borderRadius: BorderRadius.circular(14),
              border: Border.all(color: border),
            ),
            child: Row(children: [
              Icon(a.category.icon, color: primary, size: 24),
              const SizedBox(width: 14),
              Expanded(child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(a.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.body(14, color: txt, weight: FontWeight.w700, context: context)),
                  Text(a.schedule,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.body(12, color: muted, context: context)),
                ],
              )),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text('${a.slots} ${l.spots}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.label(color: primary, size: 10, context: context)),
              ),
            ]),
          )),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String value, label;
  final Color color;
  final IconData icon;
  const _StatCard({required this.value, required this.label, required this.color, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Expanded(child: Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.30)),
      ),
      child: Column(children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(height: 6),
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(value,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.display(20, color: color, context: context)),
        ),
        Text(label,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.label(color: color, size: 10, context: context)),
      ]),
    ));
  }
}

// ─── COACH APP BAR ────────────────────────────────────────────────────────────
class _CoachAppBar extends StatelessWidget implements PreferredSizeWidget {
  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight + 1);

  @override
  Widget build(BuildContext context) {
    final l       = AppLocalizations.of(context)!;
    final isDark  = context.isDark;
    final primary = context.primaryColor;
    final second  = context.secondaryColor;
    final surf    = context.surfaceColor;
    final border  = context.borderColor;
    final bg      = context.bgColor;
    final muted   = context.mutedColor;
    final state   = context.read<AppState>();
    final themeProvider = context.read<ThemeProvider>();
    final user    = state.user;

    return AppBar(
      backgroundColor: isDark ? bg.withValues(alpha: 0.95) : surf,
      surfaceTintColor: Colors.transparent,
      title: Row(children: [
        Container(
          width: 40, height: 40,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: isDark
                  ? [DarkColors.primary, const Color(0xFF0097A7)]
                  : [LightColors.blue, LightColors.navy],
              begin: Alignment.topLeft, end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(11),
          ),
          child: Center(child: Icon(user.role.icon, color: Colors.white, size: 20)),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(l.coachDashboard,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.heading(17, color: primary, context: context)),
              Text(user.role.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.label(color: muted, context: context).copyWith(fontSize: 11)),
            ],
          ),
        ),
      ]),
      actions: [
        Flexible(
          child: AppPill(label: user.name.split(' ').first, color: second, fontSize: 12),
        ),
        const SizedBox(width: 4),
        // Language toggle
        IconButton(
          onPressed: themeProvider.toggleLanguage,
          icon: Container(
            width: 34, height: 34,
            decoration: BoxDecoration(
              color: surf, borderRadius: BorderRadius.circular(10),
              border: Border.all(color: border),
            ),
            child: Center(child: Text(themeProvider.isArabic ? 'EN' : 'AR',
                style: AppTextStyles.label(color: primary, weight: FontWeight.w800, context: context))),
          ),
        ),
        IconButton(
          onPressed: themeProvider.toggleTheme,
          icon: Container(
            width: 34, height: 34,
            decoration: BoxDecoration(
              color: surf, borderRadius: BorderRadius.circular(10),
              border: Border.all(color: border),
            ),
            child: Center(child: Icon(isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded, size: 18, color: isDark ? DarkColors.accent : LightColors.navy)),
          ),
        ),
        IconButton(
          onPressed: () => showDialog(
            context: context,
            builder: (_) => const MusterSignOutDialog(),
          ),
          tooltip: l.signOut,
          icon: Container(
            width: 34, height: 34,
            decoration: BoxDecoration(
              color: surf, borderRadius: BorderRadius.circular(10),
              border: Border.all(color: border),
            ),
            child: Center(child: Icon(Icons.logout_rounded,
              color: context.errorColor, size: 18)),
          ),
        ),
        const SizedBox(width: 8),
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(height: 1, color: border.withValues(alpha: 0.5)),
      ),
    );
  }
}

