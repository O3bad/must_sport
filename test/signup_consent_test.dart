import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:muster_sport/core/state/app_state.dart';
import 'package:muster_sport/features/auth/presentation/signup_screen.dart';
import 'package:muster_sport/l10n/app_localizations.dart';
import 'package:provider/provider.dart';

void main() {
  testWidgets('signup requires separate age and terms confirmations',
      (tester) async {
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => AppState(),
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const SignUpScreen(),
        ),
      ),
    );

    final fields = find.byType(TextField);
    await tester.enterText(fields.at(0), 'Test Student');
    await tester.enterText(fields.at(1), 'student@example.edu');
    await tester.enterText(fields.at(2), '123456');
    await tester.tap(find.text('Continue'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.text('Account Details'), findsOneWidget);
    expect(find.byType(CheckboxListTile), findsNWidgets(2));

    final ageConsent = find.byType(CheckboxListTile).at(0);
    final termsConsent = find.byType(CheckboxListTile).at(1);
    expect(tester.widget<CheckboxListTile>(ageConsent).value, isFalse);
    expect(tester.widget<CheckboxListTile>(termsConsent).value, isFalse);

    await tester.ensureVisible(ageConsent);
    await tester.tap(ageConsent);
    await tester.pump();

    expect(tester.widget<CheckboxListTile>(ageConsent).value, isTrue);
    expect(tester.widget<CheckboxListTile>(termsConsent).value, isFalse);
  });
}
