import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/widgets.dart';
import '../../../core/state/app_state.dart';
import '../../../core/models/models.dart';

class AdminBookingsScreen extends StatelessWidget {
  const AdminBookingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isAr = Localizations.localeOf(context).languageCode == 'ar';
    final bookings = context.watch<AppState>().bookings;

    return Scaffold(
      backgroundColor: context.bgColor,
      appBar: _AdminAppBar(title: isAr ? 'الحجوزات' : 'Bookings'),
      body: bookings.isEmpty
          ? _EmptyBookings()
          : ListView.separated(
              padding: EdgeInsetsDirectional.only(
                start: 20, end: 20, top: 20,
                bottom: MediaQuery.of(context).padding.bottom + 90,
              ),
              itemCount: bookings.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (_, i) => _BookingRow(booking: bookings[i], index: i),
            ),
    );
  }
}

class _AdminAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  const _AdminAppBar({required this.title});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
      title: Text(title,
        style: AppTextStyles.body(18, color: context.textColor, weight: FontWeight.w700, context: context)),
      leading: IconButton(
        icon: Icon(Icons.arrow_back_ios_new, color: context.textColor, size: 20),
        onPressed: () => context.read<AppState>().setNavIndex(0),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class _BookingRow extends StatelessWidget {
  final Booking booking;
  final int index;
  const _BookingRow({required this.booking, required this.index});

  Color _statusColor(BuildContext ctx) => switch (booking.status) {
    BookingStatus.confirmed  => ctx.secondaryColor,
    BookingStatus.pending    => ctx.accentColor,
    BookingStatus.cancelled  => ctx.errorColor,
    BookingStatus.completed  => ctx.mutedColor,
  };

  String _dateLabel(BuildContext context) {
    final isAr = Localizations.localeOf(context).languageCode == 'ar';
    final d = booking.date;
    final mEn = ['','Jan','Feb','Mar','Apr','May','Jun',
                   'Jul','Aug','Sep','Oct','Nov','Dec'];
    final mAr = ['','يناير','فبراير','مارس','أبريل','مايو','يونيو',
                   'يوليو','أغسطس','سبتمبر','أكتوبر','نوفمبر','ديسمبر'];
    final month = isAr ? mAr[d.month] : mEn[d.month];
    return isAr ? '${d.day} $month ${d.year}' : '$month ${d.day}, ${d.year}';
  }

  @override
  Widget build(BuildContext context) {
    final isAr = Localizations.localeOf(context).languageCode == 'ar';
    final col  = _statusColor(context);
    final txt  = context.textColor;
    final muted= context.mutedColor;

    return AppCard(
      glowColor: col,
      padding: const EdgeInsetsDirectional.symmetric(horizontal: 14, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Container(
              width: 36, height: 36,
              decoration: BoxDecoration(
                color: col.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: Text('#${index + 1}',
                  style: AppTextStyles.body(13, color: col, weight: FontWeight.w700, context: context)),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(booking.facilityName,
                maxLines: 1, overflow: TextOverflow.ellipsis,
                style: AppTextStyles.body(15, color: txt, weight: FontWeight.w600, context: context)),
              const SizedBox(height: 2),
              Text('${_dateLabel(context)} · ${booking.timeSlot}',
                maxLines: 1, overflow: TextOverflow.ellipsis,
                style: AppTextStyles.body(13, color: muted, context: context)),
              // FIX: show student name now that it's populated
              if (booking.studentName != null && booking.studentName!.isNotEmpty) ...[
                const SizedBox(height: 2),
                Text(booking.studentName!,
                  maxLines: 1, overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.body(13, color: muted, context: context)),
              ],
            ])),
            const SizedBox(width: 8),
            AppPill(label: _statusLabel(booking.status, isAr), color: col),
          ]),

          // FIX: Status action buttons — admin can confirm or cancel bookings
          if (booking.status != BookingStatus.cancelled) ...[
            const SizedBox(height: 10),
            Row(children: [
              if (booking.status == BookingStatus.pending)
                _ActionButton(
                  label: isAr ? 'تأكيد' : 'Confirm',
                  icon: Icons.check_circle_outline,
                  color: context.secondaryColor,
                  onTap: () => context.read<AppState>()
                      .adminUpdateBookingStatus(booking.bookingId, BookingStatus.confirmed),
                ),
              if (booking.status == BookingStatus.pending) const SizedBox(width: 8),
              _ActionButton(
                label: isAr ? 'إلغاء' : 'Cancel',
                icon: Icons.cancel_outlined,
                color: context.errorColor,
                onTap: () => _confirmCancel(context),
              ),
            ]),
          ],
        ],
      ),
    );
  }

  String _statusLabel(BookingStatus status, bool isAr) => switch (status) {
    BookingStatus.confirmed => isAr ? 'مؤكد' : 'CONFIRMED',
    BookingStatus.pending   => isAr ? 'قيد الانتظار' : 'PENDING',
    BookingStatus.cancelled => isAr ? 'ملغى' : 'CANCELLED',
    BookingStatus.completed => isAr ? 'مكتمل' : 'COMPLETED',
  };

  void _confirmCancel(BuildContext context) {
    final isAr = Localizations.localeOf(context).languageCode == 'ar';
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: context.surfaceColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: Text(isAr ? 'إلغاء الحجز؟' : 'Cancel Booking?',
            style: AppTextStyles.heading(18, color: context.textColor, context: context)),
        content: Text(isAr ? 'إلغاء الحجز لـ ${booking.facilityName} في ${_dateLabel(context)}؟' : 'Cancel the booking for ${booking.facilityName} on ${_dateLabel(context)}?',
            style: AppTextStyles.body(15, color: context.mutedColor, context: context)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context),
              child: Text(isAr ? 'إبقاء' : 'Keep', style: AppTextStyles.body(15, color: context.mutedColor, context: context))),
          TextButton(
            onPressed: () {
              context.read<AppState>()
                  .adminUpdateBookingStatus(booking.bookingId, BookingStatus.cancelled);
              Navigator.pop(context);
            },
            child: Text(isAr ? 'إلغاء الحجز' : 'Cancel Booking',
                style: AppTextStyles.body(15, color: context.errorColor, weight: FontWeight.w700, context: context)),
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  const _ActionButton({required this.label, required this.icon,
    required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsetsDirectional.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.10),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withValues(alpha: 0.35)),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(icon, color: color, size: 14),
          const SizedBox(width: 5),
          Text(label, style: AppTextStyles.body(14, color: color, weight: FontWeight.w700, context: context)),
        ]),
      ),
    );
  }
}

class _EmptyBookings extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final isAr = Localizations.localeOf(context).languageCode == 'ar';
    return Center(
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        const Icon(Icons.calendar_month_rounded, size: 52, color: Color(0xFF5A7090)),
        const SizedBox(height: 16),
        Text(isAr ? 'لا يوجد حجوزات بعد' : 'No bookings yet',
          style: AppTextStyles.body(15, color: context.mutedColor, context: context)),
        const SizedBox(height: 6),
        Text(isAr ? 'ستظهر هنا الحجوزات التي يقوم بها الطلاب.' : 'Bookings made by students will appear here.',
          style: AppTextStyles.body(14, color: context.mutedColor, context: context),
          textAlign: TextAlign.center),
      ]),
    );
  }
}
