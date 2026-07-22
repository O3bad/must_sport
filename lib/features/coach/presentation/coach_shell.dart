import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/widgets.dart';
import '../../../core/theme/animated_nav_bar.dart';
import '../../../core/state/app_state.dart';
import '../../../core/state/activity_state.dart';
import '../../../l10n/app_localizations.dart';
import '../../admin/presentation/admin_registrations_screen.dart';
import '../../chatbot/presentation/chatbot_screen.dart';
import 'coach_dashboard_screen.dart';
import 'coach_athletes_screen.dart';

// ─── IMPROVEMENT #7 & #15: Dedicated CoachShell ──────────────────────────────
// Coaches get a tailored 4-tab experience:
//   Dashboard | My Athletes | Registrations | Chatbot
// They do NOT see the Users management or full admin panel.
class CoachShell extends StatelessWidget {
  const CoachShell({super.key});

  static const _screens = [
    CoachDashboardScreen(),
    CoachAthletesScreen(),
    AdminRegistrationsScreen(), // reused — coaches can approve/reject
    ChatbotScreen(),
  ];

  static const int _screenCount = 4;

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

    final items = [
      NavItemData(label: l.dashboard,  icon: Icons.sports_rounded),
      NavItemData(label: l.athletes,   icon: Icons.people_alt_rounded),
      NavItemData(
        label:      l.requests,
        icon:       Icons.assignment_rounded,
        hasBadge:   pendingCount > 0,
        badgeCount: pendingCount,
      ),
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
          body: IndexedStack(index: currentIndex, children: _screens),
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
