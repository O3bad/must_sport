// lib/app.dart
//
// Root widget. Wires up:
//  • ThemeProvider               (dark / light toggle)
//  • Repository providers        (available to every route)
//  • AuthBloc                    (global auth state)
//  • AppRouter                   (named routes)
//  • Auth-state listener         (redirects to /auth on sign-out)

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'core/di/service_locator.dart';
import 'core/repositories/activity_repository.dart';
import 'core/repositories/auth_repository.dart';
import 'core/repositories/notification_repository.dart';
import 'core/repositories/user_repository.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_provider.dart';
import 'features/auth/bloc/auth_bloc.dart';
import 'l10n/app_localizations.dart';

class MustApp extends StatelessWidget {
  const MustApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
      child: MultiRepositoryProvider(
        // ── All repositories available to every screen in the tree ──
        providers: [
          RepositoryProvider<AuthRepository>(
              create: (_) => sl.authRepository),
          RepositoryProvider<ActivityRepository>(
              create: (_) => sl.activityRepository),
          RepositoryProvider<UserRepository>(
              create: (_) => sl.userRepository),
          RepositoryProvider<NotificationRepository>(
              create: (_) => sl.notificationRepository),
        ],
        child: BlocProvider(
          create: (ctx) => AuthBloc(
            authRepository: ctx.read<AuthRepository>(),
          ),
          child: _AppView(),
        ),
      ),
    );
  }
}

class _AppView extends StatelessWidget {
  final _navigatorKey = GlobalKey<NavigatorState>();

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (_, themeProvider, __) {
        return BlocListener<AuthBloc, AuthState>(
          // Global listener: redirect to /auth whenever user signs out
          listener: (ctx, state) {
            if (state is AuthUnauthenticated) {
              _navigatorKey.currentState
                  ?.pushNamedAndRemoveUntil(AppRouter.login, (_) => false);
            }
          },
          child: MaterialApp(
            navigatorKey: _navigatorKey,
            title: 'MUST Activities',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.light,
            darkTheme: AppTheme.dark,
            themeMode: themeProvider.themeMode,
            locale: themeProvider.locale,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            initialRoute: AppRouter.splash,
            onGenerateRoute: AppRouter.onGenerateRoute,
          ),
        );
      },
    );
  }
}
