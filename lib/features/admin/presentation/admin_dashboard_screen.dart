import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/widgets.dart';
import '../../../core/theme/animations.dart';
import '../../../core/widgets/expandable_tab_row.dart';
import '../../../core/state/app_state.dart';
import '../../../core/state/activity_state.dart';
import '../../../core/theme/theme_provider.dart';
import '../../../core/models/models.dart';
import '../../../l10n/app_localizations.dart';
import '../send_notification_screen.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});
  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  // 0 = Overview, 1 = Events, 2 = Users, 3 = Quick Actions
  int _section = 0;

  static List<ExpandableTab> _sectionTabs(AppLocalizations l) => [
    ExpandableTab(title: l.overview,  icon: Icons.dashboard_rounded),
    ExpandableTab(title: l.eventsAdmin,    icon: Icons.emoji_events_rounded),
    const ExpandableTab.separator(),
    ExpandableTab(title: l.users,     icon: Icons.group_rounded),
    ExpandableTab(title: l.actions,   icon: Icons.bolt_rounded),
  ];

  // Map tab index (accounting for separator at idx 2) → section int
  int _tabToSection(int tabIdx) => switch (tabIdx) {
    0 => 0,
    1 => 1,
    3 => 2,
    4 => 3,
    _ => 0,
  };

  // Map section int → tab index
  int _sectionToTab(int section) => switch (section) {
    0 => 0,
    1 => 1,
    2 => 3,
    3 => 4,
    _ => 0,
  };

  @override
  Widget build(BuildContext context) {
    final l       = AppLocalizations.of(context)!;
    final isAr    = Localizations.localeOf(context).languageCode == 'ar';
    final state   = context.watch<AppState>();
    context.read<ThemeProvider>();
    final user    = state.user;
    final primary = context.primaryColor;
    final second  = context.secondaryColor;
    final accent  = context.accentColor;
    final errC    = context.errorColor;

    final totalUsers   = state.adminAllUsers.length;
    final students     = state.adminAllUsers.where((u) => u.role == UserRole.student).length;
    final openEvents   = state.events.where((e) => e.status == EventStatus.open).length;
    final totalBookings= state.bookings.length;
    final regState     = context.watch<ActivityRegistrationState>();
    final pendingRegs  = regState.pending.length;
    final totalRegs    = regState.all.length;
    final hasPending   = pendingRegs > 0;
    final hPad         = context.hPadding;
    final statsCols    = context.isTablet ? 3 : (context.isSmallPhone ? 1 : 2);

    final stats = [
      _StatData(l.totalUsers,    '$totalUsers',   '👥', primary),
      _StatData(l.student,       '$students',     '🎓', second),
      _StatData(l.activeEvents,  '$openEvents',   '🏆', accent),
      _StatData(l.registrations, '$totalRegs',    '📋', errC),
      _StatData(l.pendingReview, '$pendingRegs',  '⏳', const Color(0xFFFFB547)),
      _StatData(l.activities,    '24', '🎭', const Color(0xFF00BCD4)),
    ];

    final sectionTabs = _sectionTabs(l);

    return Scaffold(
      backgroundColor: context.bgColor,
      appBar: _AdminAppBar(title: l.dashboard),
      body: ListView(
        padding: EdgeInsets.only(
          left: hPad, right: hPad, top: 20,
          bottom: MediaQuery.of(context).padding.bottom + 90,
        ),
        children: [
          // ── Welcome hero ──────────────────────────────────────────────────
          _AdminHeroCard(user: user),
          const SizedBox(height: 16),

          // ── Pending registrations alert ───────────────────────────────────
          if (hasPending)
            Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFFFFB547).withValues(alpha: 0.12),
                border: Border.all(color: const Color(0xFFFFB547).withValues(alpha: 0.45)),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(children: [
                const Text('⏳', style: TextStyle(fontSize: 20)),
                const SizedBox(width: 10),
                Expanded(child: Text(
                  isAr ? 'لديك $pendingRegs تسجيل قيد الانتظار بانتظار المراجعة.' : 'You have $pendingRegs pending registration${pendingRegs > 1 ? "s" : ""} awaiting review.',
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.body(15, color: const Color(0xFFFFB547), weight: FontWeight.w600, context: context),
                )),
                Flexible(
                  child: TextButton(
                    onPressed: () => context.read<AppState>().setNavIndex(1),
                    style: TextButton.styleFrom(foregroundColor: const Color(0xFFFFB547),
                        padding: const EdgeInsets.symmetric(horizontal: 6)),
                    child: Text(isAr ? 'مراجعة ←' : 'Review →',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.body(13, color: const Color(0xFFFFB547), weight: FontWeight.w700, context: context)),
                  ),
                ),
              ]),
            ),

          // ── ExpandableTabs section switcher ───────────────────────────────
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            clipBehavior: Clip.none,
            child: ExpandableTabs(
              tabs: sectionTabs,
              initialIndex: _sectionToTab(_section),
              activeColor: primary,
              onChange: (idx) {
                if (idx != null) setState(() => _section = _tabToSection(idx));
              },
              padding: const EdgeInsets.all(5),
            ),
          ),
          const SizedBox(height: 20),

          // ── Section: Overview ─────────────────────────────────────────────
          if (_section == 0) ...[
            SectionLabel(isAr ? 'نظرة عامة' : 'Overview', margin: const EdgeInsets.only(bottom: 12)),
            GridView.count(
              crossAxisCount: statsCols,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 14,
              crossAxisSpacing: 12,
              childAspectRatio: context.isSmallPhone ? 1.6 : 1.35,
              children: stats.map((s) => _GlowStatCard(stat: s)).toList(),
            ),
          ],

          // ── Section: Events ───────────────────────────────────────────────
          if (_section == 1) ...[
            SectionLabel(l.recentEvents, margin: const EdgeInsets.only(bottom: 12)),
            ...state.events.take(5).map((e) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: StaggerItem(
                delay: Duration(milliseconds: state.events.indexOf(e) * 50),
                child: _EventSummaryRow(event: e),
              ),
            )),
            const SizedBox(height: 8),
            Center(
              child: PressScale(
                onTap: () => context.read<AppState>().setNavIndex(3),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 11),
                  decoration: BoxDecoration(
                    color: second.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: second.withValues(alpha: 0.3)),
                  ),
                  child: Text(l.manageAllEvents,
                    style: AppTextStyles.body(14, color: second, weight: FontWeight.w700, context: context)),
                ),
              ),
            ),
          ],

          // ── Section: Users ────────────────────────────────────────────────
          if (_section == 2) ...[
            SectionLabel(l.userBreakdown, margin: const EdgeInsets.only(bottom: 12)),
            ...[ 
              _StatData(l.totalUsers,  '$totalUsers', '👥', primary),
              _StatData(l.student,     '$students',   '🎓', second),
              _StatData(l.pendingReview, '$pendingRegs','⏳', const Color(0xFFFFB547)),
              _StatData(l.allBookings, '$totalBookings','📅', accent),
            ].map((s) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: StaggerItem(
                delay: const Duration(milliseconds: 40),
                child: _GlowStatCard(stat: s),
              ),
            )),
            const SizedBox(height: 8),
            Center(
              child: PressScale(
                onTap: () => context.read<AppState>().setNavIndex(4),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 11),
                  decoration: BoxDecoration(
                    color: primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: primary.withValues(alpha: 0.3)),
                  ),
                  child: Text(l.manageAllUsers,
                    style: AppTextStyles.body(14, color: primary, weight: FontWeight.w700, context: context)),
                ),
              ),
            ),
          ],

          // ── Section: Quick Actions ────────────────────────────────────────
          if (_section == 3) ...[
            SectionLabel(l.quickActions, margin: const EdgeInsets.only(bottom: 12)),
            context.isSmallPhone
                ? Column(children: [
                    _QuickAction(
                icon: '📋', label: l.registrations,
                      color: const Color(0xFFFFB547),
                      onTap: () => context.read<AppState>().setNavIndex(1),
                    ),
                    const SizedBox(height: 12),
                    _QuickAction(
                icon: '🏆', label: l.eventsAdmin,
                      color: second,
                      onTap: () => context.read<AppState>().setNavIndex(3),
                    ),
                    const SizedBox(height: 12),
                    _QuickAction(
                icon: '👥', label: l.users,
                      color: primary,
                      onTap: () => context.read<AppState>().setNavIndex(4),
                    ),
                    const SizedBox(height: 12),
                    _QuickAction(
                      icon: '🤖', label: l.aiGuideTitle,
                      color: accent,
                      onTap: () => context.read<AppState>().setNavIndex(5),
                    ),
                    const SizedBox(height: 12),
                    _QuickAction(
                      icon: '📢', label: l.sendNotification,
                      color: const Color(0xFF00BCD4),
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SendNotificationScreen())),
                    ),
                  ])
                : Column(children: [
                    Row(children: [
                      Expanded(child: _QuickAction(
                        icon: '📋', label: l.registrations,
                        color: const Color(0xFFFFB547),
                        onTap: () => context.read<AppState>().setNavIndex(1),
                      )),
                      const SizedBox(width: 12),
                      Expanded(child: _QuickAction(
                        icon: '🏆', label: l.eventsAdmin,
                        color: second,
                        onTap: () => context.read<AppState>().setNavIndex(3),
                      )),
                    ]),
                    const SizedBox(height: 12),
                    Row(children: [
                      Expanded(child: _QuickAction(
                        icon: '👥', label: l.users,
                        color: primary,
                        onTap: () => context.read<AppState>().setNavIndex(4),
                      )),
                      const SizedBox(width: 12),
                      Expanded(child: _QuickAction(
                        icon: '📢', label: l.sendNotification,
                        color: const Color(0xFF00BCD4),
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SendNotificationScreen())),
                      )),
                    ]),
                  ]),
          ],
        ],
      ),
    );
  }
}

// ── HERO CARD ─────────────────────────────────────────────────────────────────
class _AdminHeroCard extends StatelessWidget {
  final UserModel user;
  const _AdminHeroCard({required this.user});

  @override
  Widget build(BuildContext context) {
    final isDark  = context.isDark;
    final primary = context.primaryColor;
    final second  = context.secondaryColor;

    final gradColors = isDark
        ? const [Color(0xFF0D2A5A), Color(0xFF1a2a50), Color(0xFF0A1228)]
        : [LightColors.navy, const Color(0xFF1E3F80)];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: gradColors,
          begin: Alignment.topLeft, end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: primary.withValues(alpha: 0.25)),
        boxShadow: [
          BoxShadow(color: primary.withValues(alpha: 0.12), blurRadius: 24),
        ],
      ),
      child: Row(children: [
        Container(
          width: 56, height: 56,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: [primary.withValues(alpha: 0.8), second.withValues(alpha: 0.5)],
            ),
            boxShadow: [
              BoxShadow(color: primary.withValues(alpha: 0.4), blurRadius: 16),
            ],
          ),
          child: Center(
            child: Icon(user.role.icon, color: Colors.white, size: 22),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(user.name,
              maxLines: 1, overflow: TextOverflow.ellipsis,
              style: AppTextStyles.display(22, color: Colors.white, context: context)),
          const SizedBox(height: 2),
          Text(user.role.label,
              maxLines: 1, overflow: TextOverflow.ellipsis,
              style: AppTextStyles.body(14, color: Colors.white60, context: context)),
          const SizedBox(height: 6),
          AppPill(label: user.faculty, color: second),
        ])),
      ]),
    );
  }
}

// ── GLOW STAT CARD ────────────────────────────────────────────────────────────
class _StatData {
  final String label, value, icon;
  final Color color;
  const _StatData(this.label, this.value, this.icon, this.color);
}

class _GlowStatCard extends StatefulWidget {
  final _StatData stat;
  const _GlowStatCard({required this.stat});
  @override
  State<_GlowStatCard> createState() => _GlowStatCardState();
}

class _GlowStatCardState extends State<_GlowStatCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double>   _glow;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 1800 + widget.stat.label.length * 60),
    )..repeat(reverse: true);
    _glow = Tween<double>(begin: 0.3, end: 0.9)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final c    = widget.stat.color;
    final surf = context.surfaceColor;

    return AnimatedBuilder(
      animation: _glow,
      builder: (_, __) => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: surf,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: c.withValues(alpha: 0.35)),
          boxShadow: [
            BoxShadow(
              color: c.withValues(alpha: 0.30 * _glow.value),
              blurRadius: 20 * _glow.value,
              spreadRadius: 1 * _glow.value,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(children: [
              Container(
                width: 32, height: 28,
                decoration: BoxDecoration(
                  color: c.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(child: Text(widget.stat.icon, style: const TextStyle(fontSize: 16))),
              ),
              const Spacer(),
              Container(
                width: 6, height: 6,
                decoration: BoxDecoration(
                  color: c,
                  shape: BoxShape.circle,
                  boxShadow: [BoxShadow(color: c.withValues(alpha: 0.8 * _glow.value), blurRadius: 6)],
                ),
              ),
            ]),
            const SizedBox(height: 6),
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(widget.stat.value,
                style: AppTextStyles.display(24, color: c, context: context)),
            ),
            const SizedBox(height: 2),
            Text(widget.stat.label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.label(color: context.mutedColor, context: context)),
          ],
        ),
      ),
    );
  }
}

// ── EVENT SUMMARY ROW ─────────────────────────────────────────────────────────
class _EventSummaryRow extends StatelessWidget {
  final SportEvent event;
  const _EventSummaryRow({required this.event});

  Color _statusColor(BuildContext ctx) => switch (event.status) {
    EventStatus.open      => ctx.secondaryColor,
    EventStatus.full      => ctx.errorColor,
    EventStatus.soon      => ctx.accentColor,
    EventStatus.completed => ctx.mutedColor,
  };

  @override
  Widget build(BuildContext context) {
    final col = _statusColor(context);
    return AppCard(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      child: Row(children: [
        Icon(event.sportType.icon, color: context.primaryColor, size: 22),
        const SizedBox(width: 10),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(event.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.body(15, color: context.textColor, weight: FontWeight.w600, context: context)),
          Text('${event.participants}/${event.maxParticipants} · ${event.location}',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.body(13, color: context.mutedColor, context: context)),
        ])),
        const SizedBox(width: 8),
        AppPill(label: event.status.name.toUpperCase(), color: col),
      ]),
    );
  }
}

// ── QUICK ACTION ──────────────────────────────────────────────────────────────
class _QuickAction extends StatelessWidget {
  final String icon, label;
  final Color color;
  final VoidCallback onTap;
  const _QuickAction({required this.icon, required this.label,
    required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onTap,
      glowColor: color,
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Text(icon, style: const TextStyle(fontSize: 24)),
        const SizedBox(height: 6),
        Text(label,
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: AppTextStyles.body(14, color: color, weight: FontWeight.w700, context: context)),
      ]),
    );
  }
}

// ── SHARED ADMIN APP BAR ──────────────────────────────────────────────────────
class _AdminAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  const _AdminAppBar({required this.title});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight + 1);

  @override
  Widget build(BuildContext context) {
    final isDark  = context.isDark;
    final primary = context.primaryColor;
    final second  = context.secondaryColor;
    final surf    = context.surfaceColor;
    final border  = context.borderColor;
    final bg      = context.bgColor;
    context.read<AppState>();
    final themeProvider = context.read<ThemeProvider>();

    return AppBar(
      backgroundColor: isDark ? bg.withValues(alpha: 0.95) : surf,
      surfaceTintColor: Colors.transparent,
      title: Row(children: [
        Container(
          width: 28, height: 28,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: isDark
                  ? [DarkColors.primary, const Color(0xFF0097A7)]
                  : [LightColors.blue, LightColors.navy],
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Center(child: Icon(Icons.admin_panel_settings_rounded, size: 16, color: Colors.white)),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.heading(18, color: primary, context: context)),
        ),
      ]),
      actions: [
        Flexible(
          child: AppPill(
              label: context.watch<AppState>().user.role.label, color: second),
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
        // Theme toggle
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
        // Sign out
        IconButton(
          onPressed: () => _confirmSignOut(context),
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

  void _confirmSignOut(BuildContext context) {
    showDialog(context: context, builder: (_) => const MusterSignOutDialog());
  }
}



