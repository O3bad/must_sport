import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:muster_sport/core/models/models.dart';
import 'package:muster_sport/core/state/app_state.dart';
import 'package:muster_sport/core/theme/app_theme.dart';
import 'package:muster_sport/features/booking/presentation/booking_screen.dart';
import 'package:muster_sport/l10n/app_localizations.dart';

void main() {
  test('booking slot IDs and stored dates are stable and payment is on-site',
      () {
    final date = DateTime(2026, 9, 30);
    final bookingId = Booking.idForSlot(
      facilityId: 'field-a',
      date: date,
      timeSlot: '10:00 AM',
    );
    final booking = Booking(
      bookingId: bookingId,
      facilityId: 'field-a',
      facilityName: 'Football Field A',
      date: date,
      timeSlot: '10:00 AM',
      status: BookingStatus.confirmed,
    );

    expect(bookingId, 'field-a|2026-09-30|10:00 AM');
    expect(booking.toJson()['date'], '2026-09-30');
    expect(booking.paymentMethod, 'pay_at_facility');
  });

  testWidgets('booking collects no payment credentials', (tester) async {
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => AppState(),
        child: MaterialApp(
          theme: AppTheme.light,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const BookingScreen(),
        ),
      ),
    );

    await tester.scrollUntilVisible(
      find.text('Pay at the facility'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('Pay at the facility'), findsOneWidget);
    expect(
      find.text('MUSTER does not collect or process payments in the app.'),
      findsOneWidget,
    );
    expect(find.byType(TextField), findsNothing);
  });
}
