// lib/core/router/app_router.dart
//
// Central named-route table. All navigation goes through here.

import 'package:flutter/material.dart';

// Auth
import '../../features/auth/presentation/splash_screen.dart';
import '../../features/auth/presentation/login_screen.dart';
import '../../features/auth/presentation/signup_screen.dart';
import '../../features/auth/presentation/forgot_password_screen.dart';

// Student / home
import '../../app_shell.dart';

// Admin
import '../../features/admin/presentation/admin_shell.dart';

// Coach
import '../../features/coach/presentation/coach_shell.dart';

// Activities
import '../../features/activities/presentation/activities_screen.dart';
import '../../features/activities/presentation/activity_detail_screen.dart';
import '../../features/activities/presentation/registration_form_screen.dart';

// Booking
import '../../features/booking/presentation/booking_screen.dart';
import '../../features/booking/presentation/my_reservations_screen.dart';

// Notifications
import '../../features/notifications/presentation/notifications_screen.dart';

// Profile & settings
import '../../features/profile/presentation/profile_screen.dart';
import '../../features/settings/presentation/settings_screen.dart';
import '../../features/settings/presentation/about_screen.dart';

// Discovery
import '../../features/sports/presentation/sports_screen.dart';
import '../../features/events/presentation/events_screen.dart';
import '../../features/leadership/presentation/leadership_screen.dart';

// My activity history
import '../../features/my_registrations/presentation/my_registrations_screen.dart';
import '../../features/participation_history/presentation/participation_history_screen.dart';

// Chatbot
import '../../features/chatbot/presentation/chatbot_screen.dart';

class AppRouter {
  // ── Route name constants ────────────────────────────────────────────────────
  static const String splash               = '/';
  static const String login                = '/login';
  static const String signup               = '/signup';
  static const String forgotPassword       = '/forgot-password';

  static const String home                 = '/home';
  static const String admin                = '/admin';
  static const String coach                = '/coach';

  static const String activities           = '/activities';
  static const String activityDetail       = '/activities/detail';
  static const String registrationForm     = '/activities/register';

  static const String booking              = '/booking';
  static const String myReservations       = '/booking/reservations';

  static const String notifications        = '/notifications';

  static const String profile              = '/profile';
  static const String settings             = '/settings';
  static const String about                = '/about';

  static const String sports               = '/sports';
  static const String events               = '/events';
  static const String leaderboard          = '/leaderboard';

  static const String myRegistrations      = '/my-registrations';
  static const String participationHistory = '/participation-history';

  static const String chatbot              = '/chatbot';

  // ── Route generator ─────────────────────────────────────────────────────────
  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    return MaterialPageRoute(
      settings: settings,
      builder: (context) {
        final args = settings.arguments;
        return switch (settings.name) {
          AppRouter.splash               => const SplashScreen(),
          AppRouter.login                => const LoginScreen(),
          AppRouter.signup               => const SignUpScreen(),
          AppRouter.forgotPassword       => const ForgotPasswordScreen(),

          AppRouter.home                 => const AppShell(),
          AppRouter.admin                => const AdminShell(),
          AppRouter.coach                => const CoachShell(),

          AppRouter.activities           => const ActivitiesScreen(),
          AppRouter.activityDetail       => () {
              final map = args as Map<String, dynamic>;
              return ActivityDetailScreen(
                activity: map['activity'],
                isRegistered: map['isRegistered'] as bool? ?? false,
              );
            }(),
          AppRouter.registrationForm     => RegistrationFormScreen(
              activity: (args as Map<String, dynamic>)['activity'],
            ),

          AppRouter.booking              => const BookingScreen(),
          AppRouter.myReservations       => const MyReservationsScreen(),

          AppRouter.notifications        => const NotificationsScreen(),

          AppRouter.profile              => const ProfileScreen(),
          AppRouter.settings             => const SettingsScreen(),
          AppRouter.about                => const AboutScreen(),

          AppRouter.sports               => const SportsScreen(),
          AppRouter.events               => const EventsScreen(),
          AppRouter.leaderboard          => const LeadershipScreen(),

          AppRouter.myRegistrations      => const MyRegistrationsScreen(),
          AppRouter.participationHistory => const ParticipationHistoryScreen(),

          AppRouter.chatbot              => const ChatbotScreen(),

          _                              => _NotFoundScreen(settings.name),
        };
      },
    );
  }
}

// ── 404 screen ────────────────────────────────────────────────────────────────
class _NotFoundScreen extends StatelessWidget {
  final String? route;
  const _NotFoundScreen(this.route);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF080F22),
      body: Center(
        child: Text('Route not found: $route',
            style: const TextStyle(color: Colors.white60)),
      ),
    );
  }
}
