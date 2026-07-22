import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';

import 'firebase_options.dart';
import 'core/state/app_state.dart';
import 'core/state/activity_state.dart';
import 'core/state/notification_state.dart';
import 'core/theme/app_theme.dart';
import 'core/services/fcm_service.dart';
import 'core/services/cache_service.dart';
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

  // Initialise Firebase — errors are caught so the app still works
  // with mock credentials if Firebase isn't configured yet.
  bool firebaseReady = false;
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    firebaseReady = true;
  } catch (e) {
    debugPrint('⚠️  Firebase init skipped: $e');
  }

  // Initialise FCM (push notifications + local notifications).
  // Must run after Firebase.initializeApp succeeds.
  if (firebaseReady) {
    try {
      await FCMService().initialize();
    } catch (e) {
      debugPrint('⚠️  FCM init skipped: $e');
    }
  }

  // Initialise CacheService (low-level persistence)
  await CacheService.instance.init();

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
        final clampedScale = media.textScaler.clamp(minScaleFactor: 0.9, maxScaleFactor: 1.15);
        return MediaQuery(
          data: media.copyWith(textScaler: clampedScale),
          child: child ?? const SizedBox.shrink(),
        );
      },
      home: const SplashScreen(),
    );
  }
}
