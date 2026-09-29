import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';

import 'firebase_options.dart';
import 'core/state/app_state.dart';
import 'core/state/activity_state.dart';
import 'core/state/notification_state.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/widgets.dart';
import 'core/services/fcm_service.dart';
import 'core/services/cache_service.dart';
import 'core/services/notification_preferences.dart';
import 'core/legal/cookie_consent_banner.dart';
import 'core/theme/theme_provider.dart';
import 'features/auth/presentation/splash_screen.dart';
import 'l10n/app_localizations.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Lock to portrait
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  await _startApp();
}

Future<void> _startApp() async {
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (error, stackTrace) {
    debugPrint('Firebase initialization failed: $error\n$stackTrace');
    runApp(const _FirebaseUnavailableApp());
    return;
  }

  try {
    await FCMService().initialize();
  } catch (error) {
    debugPrint('Push notification initialization failed: $error');
  }

  // Initialise CacheService (low-level persistence)
  await CacheService.instance.init();

  // Persisted notification preferences, so an opt-out survives a restart.
  await NotificationPreferences.instance.init();

  // Initialise AppState (loads cached theme / session)
  final appState = AppState();
  await appState.init();

  final themeProvider = ThemeProvider();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<AppState>.value(value: appState),
        ChangeNotifierProvider<ThemeProvider>.value(value: themeProvider),
        ChangeNotifierProvider<ActivityRegistrationState>.value(
          value: ActivityRegistrationState.instance,
        ),
        ChangeNotifierProvider<NotificationState>.value(
          value: NotificationState.instance,
        ),
      ],
      child: const MusterApp(),
    ),
  );
}

class _FirebaseUnavailableApp extends StatefulWidget {
  const _FirebaseUnavailableApp();

  @override
  State<_FirebaseUnavailableApp> createState() =>
      _FirebaseUnavailableAppState();
}

class _FirebaseUnavailableAppState extends State<_FirebaseUnavailableApp> {
  bool _retrying = false;

  Future<void> _retry() async {
    setState(() => _retrying = true);
    await _startApp();
    if (mounted) setState(() => _retrying = false);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MUSTER',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Builder(
        builder: (context) {
          final l = AppLocalizations.of(context)!;
          return Scaffold(
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(28),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.cloud_off_rounded,
                        size: 52, color: context.errorColor),
                    const SizedBox(height: 20),
                    Text(
                      l.firebaseUnavailableTitle,
                      textAlign: TextAlign.center,
                      style: AppTextStyles.heading(
                        20,
                        color: context.textColor,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      l.firebaseUnavailableMessage,
                      textAlign: TextAlign.center,
                      style: AppTextStyles.body(
                        14,
                        context: context,
                        color: context.mutedColor,
                      ),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _retrying ? null : _retry,
                      child: _retrying
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2),
                            )
                          : Text(l.retry),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class MusterApp extends StatelessWidget {
  const MusterApp({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeProvider>();

    return MaterialApp(
      title: 'MUSTER',
      debugShowCheckedModeBanner: false,
      themeMode: theme.themeMode,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      locale: theme.locale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      builder: (context, child) {
        final media = MediaQuery.of(context);
        // Keep typography and spacing stable on very small/large Android screens.
        final clampedScale =
            media.textScaler.clamp(minScaleFactor: 0.9, maxScaleFactor: 1.15);
        return MediaQuery(
          data: media.copyWith(textScaler: clampedScale),
          child: Stack(
            children: [
              child ?? const SizedBox.shrink(),
              // Renders nothing outside the web build: native apps have no
              // cookies to consent to.
              const Align(
                alignment: Alignment.bottomCenter,
                child: CookieConsentBanner(),
              ),
            ],
          ),
        );
      },
      home: const SplashScreen(),
    );
  }
}
