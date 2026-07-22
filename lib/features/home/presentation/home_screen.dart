import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/widgets.dart';
import '../../../core/theme/animations.dart';
import '../../../core/state/app_state.dart';
import '../../../l10n/app_localizations.dart';
import '../../notifications/presentation/notifications_screen.dart';
import '../../events/presentation/events_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  String _greeting(AppLocalizations l) {
    final h = DateTime.now().hour;
    if (h < 12) return l.goodMorning;
    if (h < 17) return l.goodAfternoon;
    return l.goodEvening;
  }

  @override
  Widget build(BuildContext context) {
    final l       = AppLocalizations.of(context)!;
    final state   = context.watch<AppState>();
    final user    = state.user;
    final primary = context.primaryColor;
    final second  = context.secondaryColor;
    final accent  = context.accentColor;
    final txt     = context.textColor;
    final muted   = context.mutedColor;
    final hPad    = context.hPadding;
    final quickCols = context.isTablet ? 3 : (context.isSmallPhone ? 1 : 2);

    return Scaffold(
      backgroundColor: context.bgColor,
      appBar: MusterAppBar(
        hasNotification: true,
        onNotificationTap: () => Navigator.push(
          context,
          PageRouteBuilder(
            pageBuilder: (_, a, __) => const NotificationsScreen(),
            transitionsBuilder: (_, a, __, child) =>
                FadeTransition(opacity: a, child: child),
            transitionDuration: const Duration(milliseconds: 300),
          ),
        ),
      ),
      body: ListView(
        padding: EdgeInsets.only(
          left: hPad, right: hPad, top: 20,
          bottom: MediaQuery.of(context).padding.bottom + 90,
        ),
        children: [
          // Hero greeting — instant
          StaggerItem(delay: const Duration(milliseconds: 0), child:
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(_greeting(l), style: AppTextStyles.body(18, color: muted, context: context)),
              const SizedBox(height: 2),
              Text.rich(
                TextSpan(children: [
                  TextSpan(
                    text: '${l.welcome}\n',
                    style: AppTextStyles.display(28, color: txt, context: context),
                  ),
                  TextSpan(
                    text: user.name.split(' ').first,
                    style: AppTextStyles.display(28, color: primary, context: context),
                  ),
                ]),
                maxLines: 4,
                overflow: TextOverflow.ellipsis,
              ),
            ]),
          ),
          const SizedBox(height: 15),

          // Pills row
          StaggerItem(delay: const Duration(milliseconds: 60), child:
            Wrap(spacing: 6, runSpacing: 6, children: [
              AppPill(label: '🏅 #${user.rank} ${l.overall}',          color: primary),
              AppPill(label: '⭐ ${user.points} ${l.pts}',              color: accent),
              AppPill(label: '✓ ${state.enrolledCount} ${l.enrolled}', color: second),
            ]),
          ),
          const SizedBox(height: 20),
          const MusterDivider(),

          // Stat boxes — staggered individually
          StaggerItem(
            delay: const Duration(milliseconds: 120),
            child: context.isSmallPhone
                ? Column(children: [
                    Row(children: [
                      Expanded(child: StatBox(value: '${user.stats.eventsJoined}', label: l.eventsLabel, color: primary)),
                      const SizedBox(width: 8),
                      Expanded(child: StatBox(value: '${user.stats.bookingsMade}', label: l.bookings, color: txt)),
                    ]),
                    const SizedBox(height: 8),
                    StatBox(value: '${user.stats.wins}', label: l.wins, color: second),
                  ])
                : Row(children: [
                    Expanded(child: StatBox(value: '${user.stats.eventsJoined}', label: l.eventsLabel, color: primary)),
                    const SizedBox(width: 8),
                    Expanded(child: StatBox(value: '${user.stats.bookingsMade}', label: l.bookings, color: txt)),
                    const SizedBox(width: 8),
                    Expanded(child: StatBox(value: '${user.stats.wins}', label: l.wins, color: second)),
                  ]),
          ),
          const SizedBox(height: 25),

          StaggerItem(delay: const Duration(milliseconds: 180), child: SectionLabel(l.quickAccess)),

          // Quick access grid
          StaggerItem(delay: const Duration(milliseconds: 220), child:
            GridView.count(
              crossAxisCount: quickCols, shrinkWrap: true,
              padding: EdgeInsets.zero,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 10, crossAxisSpacing: 10,
              childAspectRatio: context.isSmallPhone ? 2.6 : (context.isTablet ? 2.2 : 1.8),
              children: [
                QuickAccessCard(icon: '📅', label: l.bookAField,     color: primary, onTap: () => context.read<AppState>().setNavIndex(2)),
                QuickAccessCard(icon: '🏆', label: l.joinAnEvent,    color: second,  onTap: () => context.read<AppState>().setNavIndex(3)),
                QuickAccessCard(icon: '📋', label: l.myApplications, color: accent,  onTap: () => context.read<AppState>().setNavIndex(4)),
                QuickAccessCard(icon: '⚽', label: l.allActivities,  color: context.errorColor, onTap: () => context.read<AppState>().setNavIndex(1)),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Tournament banner with shimmer
          StaggerItem(delay: const Duration(milliseconds: 290), child:
            _TournamentBanner(onTap: () => context.read<AppState>().setNavIndex(3)),
          ),
          const SizedBox(height: 24),

          StaggerItem(delay: const Duration(milliseconds: 340), child: SectionLabel(l.recentActivity)),

          StaggerItem(delay: const Duration(milliseconds: 370), child:
            _RecentActivityCard(name: l.footballFieldA, time: l.tomorrowAt('4:00 PM'),
              status: l.confirmed, statusColor: second),
          ),
          const SizedBox(height: 10),
          StaggerItem(delay: const Duration(milliseconds: 400), child:
            _RecentActivityCard(name: l.padelCourt2, time: l.mar7At('6:00 PM'),
              status: l.pending, statusColor: accent),
          ),
        ],
      ),
    );
  }
}

class _TournamentBanner extends StatelessWidget {
  final VoidCallback onTap;
  const _TournamentBanner({required this.onTap});

  @override
  Widget build(BuildContext context) {
    final l        = AppLocalizations.of(context)!;
    final isDark   = context.isDark;
    final primary  = context.primaryColor;
    final accent   = context.accentColor;

    final gradColors = isDark
        ? const [Color(0xFF0D2A5A), Color(0xFF162850), Color(0xFF0A1228)]
        : [LightColors.navy, const Color(0xFF1E3F80), const Color(0xFF142B58)];

    void navigateToEvent() {
      context.read<AppState>().setNavIndex(3);
      Navigator.push(
        context,
        PageRouteBuilder(
          pageBuilder: (_, a, __) => const EventsScreen(),
          transitionsBuilder: (_, a, __, child) =>
              FadeTransition(opacity: a, child: child),
          transitionDuration: const Duration(milliseconds: 280),
        ),
      );
    }

    return PressScale(
      onTap: navigateToEvent,
      child: ShimmerOverlay(
        shimmerColor: Colors.white,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: gradColors,
              begin: AlignmentDirectional.topStart, end: AlignmentDirectional.bottomEnd,
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: primary.withValues(alpha: 0.2)),
            boxShadow: [BoxShadow(color: primary.withValues(alpha: 0.08), blurRadius: 20)],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppPill(label: '🏆 ${l.upcomingTournament}', color: accent),
              const SizedBox(height: 12),
              Text(
                l.featuredTournamentName,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.heading(17, color: Colors.white, context: context)),
              const SizedBox(height: 4),
              Text(
                l.featuredTournamentDate,
                style: AppTextStyles.body(16, color: Colors.white60, context: context)),
              const SizedBox(height: 14),
              Row(mainAxisSize: MainAxisSize.min, children: [
                Text(l.registerNow,
                  style: AppTextStyles.body(15, color: primary, weight: FontWeight.w700, context: context)),
                const SizedBox(width: 4),
                Icon(
                  Directionality.of(context) == TextDirection.rtl
                      ? Icons.arrow_back_ios_new
                      : Icons.arrow_forward_ios,
                  color: primary,
                  size: 16,
                ),
              ]),
            ],
          ),
        ),
      ),
    );
  }
}

class _RecentActivityCard extends StatelessWidget {
  final String name, time, status;
  final Color statusColor;
  const _RecentActivityCard({required this.name, required this.time,
    required this.status, required this.statusColor});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Row(children: [
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(name, maxLines: 1, overflow: TextOverflow.ellipsis,
              style: AppTextStyles.body(16, color: context.textColor, weight: FontWeight.w600, context: context)),
          const SizedBox(height: 3),
          Text(time, maxLines: 1, overflow: TextOverflow.ellipsis,
              style: AppTextStyles.body(15, color: context.mutedColor, context: context)),
        ])),
        const SizedBox(width: 8),
        AppPill(label: status, color: statusColor),
      ]),
    );
  }
}
