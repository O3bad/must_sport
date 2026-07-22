import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:muster_sport/main.dart';
import 'package:muster_sport/core/state/app_state.dart';
import 'package:muster_sport/core/state/activity_state.dart';
import 'package:muster_sport/core/state/notification_state.dart';
import 'package:muster_sport/features/auth/presentation/splash_screen.dart';

void main() {
  testWidgets('MusterApp builds with required providers', (WidgetTester tester) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<AppState>(create: (_) => AppState()),
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

    expect(find.byType(MusterApp), findsOneWidget);
  });

  testWidgets('MusterApp starts at splash screen', (WidgetTester tester) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<AppState>(create: (_) => AppState()),
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

    await tester.pump();
    expect(find.byType(SplashScreen), findsOneWidget);
  });
}
