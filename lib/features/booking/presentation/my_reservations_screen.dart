import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/widgets.dart';
import '../../../core/state/app_state.dart';
import '../../../core/state/notification_state.dart';
import '../../../core/models/models.dart';
import '../../booking/presentation/booking_screen.dart';
import '../../../l10n/app_localizations.dart';

class MyReservationsScreen extends StatelessWidget {
  const MyReservationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state    = context.watch<AppState>();
    final notifState = context.read<NotificationState>();
    final bookings = state.bookings;
    final txt      = context.textColor;
    final border   = context.borderColor;
    final bg       = context.bgColor;
    final primary  = context.primaryColor;
    final second   = context.secondaryColor;
    final hPad     = context.hPadding;

    final upcoming  = bookings.where((b) =>
        b.date.isAfter(DateTime.now().subtract(const Duration(hours: 1))) &&
        b.status != BookingStatus.cancelled).toList()
      ..sort((a, b) => a.date.compareTo(b.date));
    final past = bookings.where((b) =>
        b.date.isBefore(DateTime.now().subtract(const Duration(hours: 1))) ||
        b.status == BookingStatus.cancelled).toList()
      ..sort((a, b) => b.date.compareTo(a.date));

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: bg,
        surfaceTintColor: Colors.transparent,
        title: Text(AppLocalizations.of(context)!.myReservationsTitle, style: AppTextStyles.display(20, color: txt)),
        actions: [
          TextButton.icon(
            onPressed: () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => const BookingScreen())),
            icon: Icon(Icons.add, size: 18, color: second),
            label: Text(AppLocalizations.of(context)!.newBooking, style: AppTextStyles.body(13, color: second, weight: FontWeight.w700)),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Divider(height: 1, color: border),
        ),
      ),
      body: bookings.isEmpty
          ? _EmptyReservations(onBook: () => Navigator.push(context,
              MaterialPageRoute(builder: (_) => const BookingScreen())))
          : ListView(
              padding: EdgeInsets.fromLTRB(hPad, 16, hPad, 100),
              children: [
                // ── Upcoming ─────────────────────────────────────────────
                if (upcoming.isNotEmpty) ...[
                  _SectionHeader(
                    emoji: '📅',
                    title: '${AppLocalizations.of(context)!.upcomingSection} (${upcoming.length})',
                    color: primary,
                  ),
                  ...upcoming.map((b) => _ReservationCard(
                    booking: b,
                    isUpcoming: true,
                    onRemind: () {
                      notifState.addReservationReminder(
                        facilityName: b.facilityName,
                        date: _dateLabel(b.date),
                        time: b.timeSlot,
                      );
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text(
                          '${AppLocalizations.of(context)!.reminderSet} ${b.facilityName}',
                          style: AppTextStyles.body(13, color: Colors.black),
                        ),
                        backgroundColor: primary,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        duration: const Duration(milliseconds: 2200),
                      ));
                    },
                    onCancel: () => _confirmCancel(context, state, b),
                  )),
                ],

                // ── Past ─────────────────────────────────────────────────
                if (past.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  _SectionHeader(
                    emoji: '🕐',
                    title: '${AppLocalizations.of(context)!.pastCancelled} (${past.length})',
                    color: context.mutedColor,
                  ),
                  ...past.map((b) => _ReservationCard(
                    booking: b,
                    isUpcoming: false,
                  )),
                ],
              ],
            ),
    );
  }

  String _dateLabel(DateTime d) {
    const m = ['','Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    return '${m[d.month]} ${d.day}, ${d.year}';
  }

  void _confirmCancel(BuildContext context, AppState state, Booking b) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: context.surfaceColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(AppLocalizations.of(context)!.cancelBooking,
            style: AppTextStyles.heading(17, color: context.textColor)),
        content: Text(
          '${AppLocalizations.of(context)!.cancelBookingMsg} ${b.facilityName} ${AppLocalizations.of(context)!.on} ${_dateLabel(b.date)} ${AppLocalizations.of(context)!.all} ${b.timeSlot}?',
          style: AppTextStyles.body(13, color: context.mutedColor),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppLocalizations.of(context)!.keepIt,
                style: AppTextStyles.body(13, color: context.mutedColor)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              state.adminUpdateBookingStatus(b.bookingId, BookingStatus.cancelled);
            },
            child: Text(AppLocalizations.of(context)!.cancelBookingConfirm,
                style: AppTextStyles.body(13, color: context.errorColor,
                    weight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }
}

// ─── SECTION HEADER ───────────────────────────────────────────────────────────
class _SectionHeader extends StatelessWidget {
  final String emoji, title;
  final Color color;
  const _SectionHeader({required this.emoji, required this.title, required this.color});
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: Row(children: [
      Text(emoji, style: const TextStyle(fontSize: 16)),
      const SizedBox(width: 8),
      Expanded(child: Text(title,
          maxLines: 1, overflow: TextOverflow.ellipsis,
          style: AppTextStyles.body(13, color: color, weight: FontWeight.w700))),
    ]),
  );
}

// ─── RESERVATION CARD ─────────────────────────────────────────────────────────
class _ReservationCard extends StatelessWidget {
  final Booking     booking;
  final bool        isUpcoming;
  final VoidCallback? onRemind;
  final VoidCallback? onCancel;
  const _ReservationCard({
    required this.booking,
    required this.isUpcoming,
    this.onRemind,
    this.onCancel,
  });

  static const _facilityEmojis = {
    'Football Field A': '⚽',
    'Football Field B': '⚽',
    'Padel Court 1':    '🎾',
    'Padel Court 2':    '🎾',
    'Basketball Court': '🏀',
    'Volleyball Court': '🏐',
    'Swimming Pool':    '🏊',
    'Gym':              '🏋️',
  };

  // FIX #6: helpers for showing payment method in history
  static String _payLabel(String method) => switch (method) {
    'instapay'      => 'InstaPay',
    'vodafone_cash' => 'Vodafone Cash',
    'fawry'         => 'Fawry',
    _               => 'Credit Card',
  };

  static IconData _payIcon(String method) => switch (method) {
    'instapay'      => Icons.flash_on_rounded,
    'vodafone_cash' => Icons.phone_android_rounded,
    'fawry'         => Icons.store_rounded,
    _               => Icons.credit_card_rounded,
  };

  Color _statusColor(BuildContext ctx) => switch (booking.status) {
    BookingStatus.confirmed  => ctx.secondaryColor,
    BookingStatus.pending    => const Color(0xFFFFB547),
    BookingStatus.cancelled  => ctx.errorColor,
    BookingStatus.completed  => ctx.mutedColor,
  };

  String _statusLabel(AppLocalizations l) => switch (booking.status) {
    BookingStatus.confirmed  => l.statusConfirmed,
    BookingStatus.pending    => l.statusPending,
    BookingStatus.cancelled  => l.statusCancelled,
    BookingStatus.completed  => l.statusCompleted,
  };

  @override
  Widget build(BuildContext context) {
    final txt    = context.textColor;
    final muted  = context.mutedColor;
    final surf   = context.surfaceColor;
    final border = context.borderColor;
    final primary = context.primaryColor;
    final l      = AppLocalizations.of(context)!;
    final sColor = _statusColor(context);
    final emoji  = _facilityEmojis[booking.facilityName] ?? '🏟️';

    const months = ['','Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    final dateStr = '${months[booking.date.month]} ${booking.date.day}, ${booking.date.year}';

    // Days until
    final daysUntil  = booking.date.difference(DateTime.now()).inDays;
    final isToday    = daysUntil == 0;
    final isTomorrow = daysUntil == 1;
    final urgencyLabel = isToday ? l.todayLabel : isTomorrow ? l.tomorrowLabel : null;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: surf,
        border: Border.all(
          color: isUpcoming
              ? (urgencyLabel != null ? primary.withValues(alpha: 0.6) : border)
              : border.withValues(alpha: 0.5),
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(children: [
        // ── Main content ───────────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.all(14),
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            // Emoji box
            Container(
              width: 50, height: 50,
              decoration: BoxDecoration(
                color: isUpcoming
                    ? primary.withValues(alpha: 0.12)
                    : context.surface2Color,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Center(child: Text(emoji,
                  style: const TextStyle(fontSize: 26))),
            ),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Expanded(child: Text(booking.facilityName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.heading(14,
                        color: isUpcoming ? txt : muted))),
                // Urgency badge
                if (urgencyLabel != null)
                  Container(
                    margin: const EdgeInsets.only(left: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: primary.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(urgencyLabel,
                        style: AppTextStyles.label(color: primary)
                            .copyWith(fontSize: 10)),
                  ),
              ]),
              const SizedBox(height: 4),
              Row(children: [
                Flexible(child: Text(dateStr, style: AppTextStyles.body(12, color: muted), overflow: TextOverflow.ellipsis, maxLines: 1)),
                const SizedBox(width: 8),
                Flexible(child: Text(booking.timeSlot,
                    style: AppTextStyles.body(12, color: muted), overflow: TextOverflow.ellipsis, maxLines: 1)),
              ]),
              const SizedBox(height: 4),
              // FIX #6: Show persisted payment method in booking history
              Row(children: [
                Icon(_payIcon(booking.paymentMethod), size: 11, color: muted),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(_payLabel(booking.paymentMethod),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.body(11, color: muted)),
                ),
              ]),
              const SizedBox(height: 6),
              // Status badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: sColor.withValues(alpha: 0.12),
                  border: Border.all(color: sColor.withValues(alpha: 0.4)),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(_statusLabel(l),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.label(color: sColor)
                        .copyWith(fontSize: 10, letterSpacing: 0.3)),
              ),
            ])),
          ]),
        ),

        // ── Actions (upcoming only) ────────────────────────────────────
        if (isUpcoming && booking.status != BookingStatus.cancelled) ...[
          Divider(height: 1, color: border),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            child: context.isSmallPhone
                ? Column(children: [
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: onRemind,
                        icon: const Icon(Icons.notifications_outlined, size: 16),
                        label: Text(AppLocalizations.of(context)!.remindMe,
                            style: AppTextStyles.body(12, color: primary, weight: FontWeight.w600)),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: primary,
                          side: BorderSide(color: primary.withValues(alpha: 0.5)),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          padding: const EdgeInsets.symmetric(vertical: 9),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: onCancel,
                        icon: const Icon(Icons.close, size: 16),
                        label: Text(AppLocalizations.of(context)!.cancel,
                            style: AppTextStyles.body(12, color: context.errorColor,
                                weight: FontWeight.w600)),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: context.errorColor,
                          side: BorderSide(color: context.errorColor.withValues(alpha: 0.4)),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          padding: const EdgeInsets.symmetric(vertical: 9),
                        ),
                      ),
                    ),
                  ])
                : Row(children: [
                    // Remind me
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: onRemind,
                        icon: const Icon(Icons.notifications_outlined, size: 16),
                        label: Text(AppLocalizations.of(context)!.remindMe,
                            style: AppTextStyles.body(12, color: primary, weight: FontWeight.w600)),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: primary,
                          side: BorderSide(color: primary.withValues(alpha: 0.5)),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          padding: const EdgeInsets.symmetric(vertical: 9),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    // Cancel
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: onCancel,
                        icon: const Icon(Icons.close, size: 16),
                        label: Text(AppLocalizations.of(context)!.cancel,
                            style: AppTextStyles.body(12, color: context.errorColor,
                                weight: FontWeight.w600)),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: context.errorColor,
                          side: BorderSide(color: context.errorColor.withValues(alpha: 0.4)),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          padding: const EdgeInsets.symmetric(vertical: 9),
                        ),
                      ),
                    ),
                  ]),
          ),
        ],
      ]),
    );
  }
}

// ─── EMPTY STATE ─────────────────────────────────────────────────────────────
class _EmptyReservations extends StatelessWidget {
  final VoidCallback onBook;
  const _EmptyReservations({required this.onBook});

  @override
  Widget build(BuildContext context) => Center(
    child: Column(mainAxisSize: MainAxisSize.min, children: [
      const Icon(Icons.calendar_month_rounded, size: 64, color: Color(0xFF00E5FF)),
      const SizedBox(height: 16),
      Text(AppLocalizations.of(context)!.noReservationsYet,
          style: AppTextStyles.heading(18, color: context.textColor)),
      const SizedBox(height: 6),
      Text(AppLocalizations.of(context)!.bookFacilityToStart,
          style: AppTextStyles.body(14, color: context.mutedColor)),
      const SizedBox(height: 24),
      ElevatedButton(
        onPressed: onBook,
        style: ElevatedButton.styleFrom(
          backgroundColor: context.secondaryColor,
          foregroundColor: context.bgColor,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
        child: Text(AppLocalizations.of(context)!.bookNow,
            style: AppTextStyles.body(14, color: context.bgColor,
                weight: FontWeight.w700)),
      ),
    ]),
  );
}
