import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:muster_sport/core/theme/accessible_tap.dart';
import 'package:muster_sport/core/theme/app_theme.dart';
import 'package:muster_sport/l10n/app_localizations.dart';

Widget _wrap(Widget child, {ThemeData? theme}) => MaterialApp(
      theme: theme ?? AppTheme.dark,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(body: Center(child: child)),
    );

void main() {
  group('AccessibleTap', () {
    testWidgets('exposes a labelled button node to screen readers',
        (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(_wrap(AccessibleTap(
        onTap: () {},
        label: 'Open schedule',
        child: const Icon(Icons.calendar_today),
      )));

      expect(
        tester.getSemantics(find.byType(AccessibleTap)),
        matchesSemantics(
          label: 'Open schedule',
          isButton: true,
          hasEnabledState: true,
          isEnabled: true,
          hasTapAction: true,
        ),
      );
      handle.dispose();
    });

    testWidgets('propagates the tap action', (tester) async {
      var taps = 0;
      await tester.pumpWidget(_wrap(AccessibleTap(
        onTap: () => taps++,
        label: 'Retry',
        child: const Text('Retry'),
      )));

      await tester.tap(find.byType(AccessibleTap));
      expect(taps, 1);
    });

    testWidgets('is reachable by keyboard traversal', (tester) async {
      await tester.pumpWidget(_wrap(AccessibleTap(
        onTap: () {},
        label: 'Keyboard target',
        child: const Text('Press me'),
      )));

      // Tab must move focus onto the target rather than skipping it, which is
      // what happens with a bare GestureDetector.
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pump();
      expect(
        FocusManager.instance.primaryFocus?.hasPrimaryFocus ?? false,
        isTrue,
        reason: 'AccessibleTap must accept keyboard focus',
      );
    });

    testWidgets('activates on Enter/Space when focused', (tester) async {
      var taps = 0;
      await tester.pumpWidget(_wrap(AccessibleTap(
        onTap: () => taps++,
        label: 'Activate me',
        child: const Text('Go'),
      )));

      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pump();
      expect(taps, 1);
    });

    testWidgets('meets the 48dp minimum target size (WCAG 2.5.8)',
        (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(_wrap(AccessibleTap(
        onTap: () {},
        label: 'Tiny icon',
        // Deliberately well under 48dp.
        child: const SizedBox(width: 16, height: 16, child: Icon(Icons.close)),
      )));

      await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
      await expectLater(tester, meetsGuideline(iOSTapTargetGuideline));
      handle.dispose();
    });

    testWidgets('reports disabled state and does not fire', (tester) async {
      var taps = 0;
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(_wrap(AccessibleTap(
        onTap: null,
        label: 'Disabled action',
        child: const Text('Nope'),
      )));

      await tester.tap(find.byType(AccessibleTap), warnIfMissed: false);
      expect(taps, 0);
      expect(
        tester.getSemantics(find.byType(AccessibleTap)),
        matchesSemantics(
          label: 'Disabled action',
          isButton: true,
          hasEnabledState: true,
          isEnabled: false,
          hasTapAction: false,
        ),
      );
      handle.dispose();
    });

    testWidgets('announces toggle state when used as a switch', (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(_wrap(AccessibleTap(
        onTap: () {},
        label: 'Dark mode',
        toggleable: true,
        isToggled: true,
        child: const Text('Dark'),
      )));

      expect(
        tester.getSemantics(find.byType(AccessibleTap)),
        matchesSemantics(
          label: 'Dark mode',
          isButton: true,
          hasEnabledState: true,
          isEnabled: true,
          hasTapAction: true,
          hasToggledState: true,
          isToggled: true,
        ),
      );
      handle.dispose();
    });
  });

  group('onFillFor contrast', () {
    testWidgets('uses dark ink on the dark-theme neon accents',
        (tester) async {
      late Color onCyan, onLime, onError;
      await tester.pumpWidget(_wrap(
        Builder(builder: (context) {
          onCyan = onFillFor(context, DarkColors.primary);
          onLime = onFillFor(context, DarkColors.secondary);
          onError = onFillFor(context, DarkColors.error);
          return const SizedBox.shrink();
        }),
      ));

      // Neon fills are bright; light text on them scores 1.2-3.3:1 and fails.
      expect(onCyan, DarkColors.onFill);
      expect(onLime, DarkColors.onFill);
      expect(onError, DarkColors.onFill);
    });

    testWidgets('uses white on the deep light-theme brand tones',
        (tester) async {
      late Color onNavy, onBlue, onGreen, onError;
      await tester.pumpWidget(_wrap(
        theme: AppTheme.light,
        Builder(builder: (context) {
          onNavy = onFillFor(context, LightColors.navy);
          onBlue = onFillFor(context, LightColors.blue);
          onGreen = onFillFor(context, LightColors.green);
          onError = onFillFor(context, LightColors.error);
          return const SizedBox.shrink();
        }),
      ));

      expect(onNavy, Colors.white);
      expect(onBlue, Colors.white);
      expect(onGreen, Colors.white);
      expect(onError, Colors.white);
    });

    // Every fill the palette defines must end up with an ink that clears
    // WCAG 1.4.3. This is the regression guard for the saturated mid-tone bug:
    // #FF4757 is classified "dark" by ThemeData.estimateBrightnessForColor,
    // yet light text on it only reaches 3.03:1.
    final fills = <String, Color>{
      'cyan': DarkColors.primary,
      'lime': DarkColors.secondary,
      'gold': DarkColors.accent,
      'error': DarkColors.error,
      'darkSurface': DarkColors.surface,
      'blue': LightColors.blue,
      'green': LightColors.green,
      'navy': LightColors.navy,
      'lightError': LightColors.error,
      'lightGold': LightColors.gold,
      'white': Colors.white,
      'lightSurface2': LightColors.surface2,
    };

    for (final entry in fills.entries) {
      for (final dark in [true, false]) {
        testWidgets(
            'dark=$dark ${entry.key} clears 4.5:1 against its chosen ink',
            (tester) async {
          late double ratio;
          late Color ink;
          late Color fill;
          await tester.pumpWidget(_wrap(
            theme: dark ? AppTheme.dark : AppTheme.light,
            Builder(builder: (context) {
              fill = entry.value;
              ink = onFillFor(context, fill);
              ratio = contrastRatio(ink, fill);
              return const SizedBox.shrink();
            }),
          ));

          expect(
            ratio,
            greaterThanOrEqualTo(4.5),
            reason: '$fill needs $ink but only reaches '
                '${ratio.toStringAsFixed(2)}:1 in the '
                '${dark ? "dark" : "light"} theme',
          );
        });
      }
    }
  });
}
