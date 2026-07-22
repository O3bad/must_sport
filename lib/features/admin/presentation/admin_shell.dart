import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/widgets.dart';
import '../../../core/theme/animated_nav_bar.dart';
import '../../../core/state/app_state.dart';
import '../../../core/state/activity_state.dart';
import '../../../l10n/app_localizations.dart';
import 'admin_dashboard_screen.dart';
import 'admin_registrations_screen.dart';
import 'admin_bookings_screen.dart';
import 'admin_events_screen.dart';
import 'admin_users_screen.dart';
import '../../chatbot/presentation/chatbot_screen.dart';

class AdminShell extends StatelessWidget {
  const AdminShell({super.key});

  static const _screens = [
    AdminDashboardScreen(),
    AdminRegistrationsScreen(),
    AdminBookingsScreen(),
    AdminEventsScreen(),
    AdminUsersScreen(),
    ChatbotScreen(),
  ];

  static const int _screenCount = 6;

  @override
  Widget build(BuildContext context) {
    final l           = AppLocalizations.of(context)!;
    final state        = context.watch<AppState>();
    final regState     = context.watch<ActivityRegistrationState>();
    final isDark       = context.isDark;
    final primary      = context.primaryColor;
    final muted        = context.mutedColor;
    final border       = context.borderColor;
    final surface2     = isDark ? DarkColors.surface2 : LightColors.surface2;
    final pendingCount = regState.pending.length;
    final currentIndex = state.navIndex.clamp(0, _screenCount - 1);

    // Inject live pending badge count into the Requests item
    final items = [
      NavItemData(label: l.dashboard, icon: Icons.dashboard_rounded),
      NavItemData(
        label:      l.requests,
        icon:       Icons.assignment_rounded,
        hasBadge:   pendingCount > 0,
        badgeCount: pendingCount,
      ),
      NavItemData(label: l.booking,    icon: Icons.calendar_month_rounded),
      NavItemData(label: l.events,     icon: Icons.emoji_events_rounded),
      NavItemData(label: l.rank,       icon: Icons.group_rounded), // Using 'rank' or finding 'Users' key
      NavItemData(label: l.aiGuide,    icon: Icons.smart_toy_rounded),
    ];

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
            index: currentIndex,
            children: _screens,
          ),
          bottomNavigationBar: AnimatedNavBar(
            currentIndex: currentIndex,
            items:        items,
            primary:      primary,
            muted:        muted,
            surface2:     surface2,
            border:       border,
            isDark:       isDark,
            errorColor:   context.errorColor,
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
