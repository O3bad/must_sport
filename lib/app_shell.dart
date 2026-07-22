import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/widgets.dart';
import 'core/theme/animated_nav_bar.dart';
import 'core/state/app_state.dart';
import 'core/state/activity_state.dart';
import 'core/models/activity_models.dart';
import 'features/home/presentation/home_screen.dart';
import 'features/activities/presentation/activities_screen.dart';
import 'features/booking/presentation/booking_screen.dart';
import 'features/events/presentation/events_screen.dart';
import 'features/my_registrations/presentation/my_registrations_screen.dart';
import 'features/profile/presentation/profile_screen.dart';
import 'l10n/app_localizations.dart';
import 'features/leadership/presentation/leadership_screen.dart';


// Proxy kept for backwards compat
class AppShellStudentProxy extends StatelessWidget {
  const AppShellStudentProxy({super.key});
  @override
  Widget build(BuildContext context) => const AppShell();
}

class AppShell extends StatelessWidget {
  const AppShell({super.key});

  static final _screens = [
    const HomeScreen(),
    const ActivitiesScreen(),
    const BookingScreen(),
    const EventsScreen(),
    const MyRegistrationsScreen(),
    const LeadershipScreen(),
    const ProfileScreen(),
  ];

  static final int _screenCount = _screens.length;

  @override
  Widget build(BuildContext context) {
    final state    = context.watch<AppState>();
    final regState = context.watch<ActivityRegistrationState>();
    final isDark   = context.isDark;
    final primary  = context.primaryColor;
    final muted    = context.mutedColor;
    final border   = context.borderColor;
    final surface2 = isDark ? DarkColors.surface2 : LightColors.surface2;

    final pendingCount = regState
        .forStudent(state.user.email)
        .where((r) => r.status == RegistrationStatus.pending)
        .length;

    List<NavItemData> items(BuildContext ctx) {
      final l = AppLocalizations.of(ctx);
      return [
        NavItemData(label: l?.home ?? 'Home',        icon: Icons.home_rounded),
        NavItemData(label: l?.activities ?? 'Activity', icon: Icons.sports_soccer_rounded),
        NavItemData(label: l?.booking ?? 'Booking',   icon: Icons.calendar_month_rounded),
        NavItemData(label: l?.events ?? 'Events',     icon: Icons.emoji_events_rounded),
        NavItemData(
          label:      l?.myApps ?? 'Apps',
          icon:       Icons.assignment_rounded,
          hasBadge:   pendingCount > 0,
          badgeCount: pendingCount,
        ),
        NavItemData(label: l?.leaderboard ?? 'Ranks', icon: Icons.leaderboard_rounded),
        NavItemData(label: l?.profile ?? 'Profile',   icon: Icons.person_rounded),
      ];
    }

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: (isDark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark)
          .copyWith(
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: isDark ? DarkColors.bg : LightColors.bg,
      ),
      child: Stack(children: [
        Scaffold(
          backgroundColor: context.bgColor,
          body: IndexedStack(
            index: state.navIndex.clamp(0, _screenCount - 1),
            children: _screens,
          ),
          bottomNavigationBar: AnimatedNavBar(
            currentIndex: state.navIndex.clamp(0, _screenCount - 1),
            items: items(context),
            primary:    primary,
            muted:      muted,
            surface2:   surface2,
            border:     border,
            errorColor: context.errorColor,
            isDark:     isDark,
            onTap: (i) {
              HapticFeedback.selectionClick();
              context.read<AppState>().setNavIndex(i);
            },
          ),
        ),
        if (state.toastMessage != null)
          ToastOverlay(message: state.toastMessage!),
      ]),
    );
  }
}
