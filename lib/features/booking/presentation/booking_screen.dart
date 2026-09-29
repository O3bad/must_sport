import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/widgets.dart';
import '../../../core/state/app_state.dart';
import '../../../core/state/notification_state.dart';
import '../../../core/models/models.dart';
import '../../../core/models/mock_data.dart';
import '../../../l10n/app_localizations.dart';

class BookingScreen extends StatefulWidget {
  const BookingScreen({super.key});
  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  Facility? _field;
  String? _time;
  DateTime _date = DateTime.now();
  bool _confirmed = false;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _field = MockData.facilities.firstWhere(
      (f) => f.isAvailable,
      orElse: () => MockData.facilities.first,
    );
    _time = MockData.timeSlots[4];
  }

  String get _dateLabel {
    final l = AppLocalizations.of(context)!;
    final months = [
      '',
      l.january,
      l.february,
      l.march,
      l.april,
      l.may,
      l.june,
      l.july,
      l.august,
      l.september,
      l.october,
      l.november,
      l.december
    ];
    return '${months[_date.month]} ${_date.day}, ${_date.year}';
  }

  Future<void> _confirm() async {
    if (_field == null || _time == null) return;

    final appState = context.read<AppState>();
    final notifState = context.read<NotificationState>();
    final fieldName = _field!.name;
    final fieldId = _field!.id;
    final time = _time!;
    final date = _date;
    final dateLabel = _dateLabel;

    if (appState.hasBookingConflict(fieldId, date, time)) {
      if (!mounted) return;
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          backgroundColor: context.surfaceColor,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          title: Text(AppLocalizations.of(context)!.slotAlreadyBooked,
              style: AppTextStyles.heading(18, color: context.textColor)),
          content: Text(
            '$fieldName ${AppLocalizations.of(context)!.alreadyBookedMsg} $time ${AppLocalizations.of(context)!.on} $dateLabel. '
            '${AppLocalizations.of(context)!.chooseDifferent}',
            style: AppTextStyles.body(15, color: context.mutedColor),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(AppLocalizations.of(context)!.ok,
                  style: AppTextStyles.body(15,
                      color: context.primaryColor, weight: FontWeight.w700)),
            ),
          ],
        ),
      );
      return;
    }

    setState(() => _loading = true);
    await Future.delayed(const Duration(milliseconds: 600));

    try {
      await appState.addBooking(Booking(
        bookingId: Booking.idForSlot(
          facilityId: fieldId,
          date: date,
          timeSlot: time,
        ),
        facilityId: fieldId,
        facilityName: fieldName,
        date: date,
        timeSlot: time,
        status: BookingStatus.confirmed,
        studentName: appState.user.name,
        paymentMethod: 'pay_at_facility',
      ));
    } catch (_) {
      if (!mounted) return;
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.bookingFailedTryAgain),
          backgroundColor: context.errorColor,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
    if (!mounted) return;
    notifState.addReservationReminder(
      facilityName: fieldName,
      date: dateLabel,
      time: time,
    );
    setState(() {
      _loading = false;
      _confirmed = true;
    });
  }

  Future<void> _pickDate() async {
    final primary = context.primaryColor;
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 60)),
      builder: (ctx, child) => Theme(
        data: ctx.isDark
            ? ThemeData.dark().copyWith(
                colorScheme: ColorScheme.dark(
                primary: primary,
                surface: DarkColors.surface2,
              ))
            : ThemeData.light().copyWith(
                colorScheme: ColorScheme.light(
                primary: primary,
                surface: LightColors.surface,
              )),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _date = picked);
  }

  @override
  Widget build(BuildContext context) {
    if (_confirmed) {
      return _ConfirmationView(
        facilityName: _field!.name,
        time: _time!,
        date: _dateLabel,
        onReset: () => setState(() => _confirmed = false),
      );
    }

    final primary = context.primaryColor;
    final second = context.secondaryColor;
    final surf = context.surfaceColor;
    final border = context.borderColor;
    final txt = context.textColor;
    final muted = context.mutedColor;
    final hPad = context.hPadding;
    final facilityCols = context.isTablet ? 3 : (context.isSmallPhone ? 1 : 2);

    final l = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: context.bgColor,
      appBar: AppBar(
        backgroundColor: context.bgColor,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: Icon(
            Directionality.of(context) == TextDirection.rtl
                ? Icons.arrow_forward_ios
                : Icons.arrow_back_ios_new,
            color: context.textColor,
            size: 20,
          ),
          onPressed: () => context.read<AppState>().setNavIndex(0),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Divider(height: 1, color: context.borderColor),
        ),
      ),
      body: ListView(
        padding: EdgeInsets.only(
          left: hPad,
          right: hPad,
          top: 20,
          bottom: MediaQuery.of(context).padding.bottom + 90,
        ),
        children: [
          Text(l.bookAFieldTitle,
              style: AppTextStyles.display(28, context: context, color: txt)),
          const SizedBox(height: 4),
          Text(l.selectDateVenueTime,
              style: AppTextStyles.body(16, context: context, color: muted)),
          const SizedBox(height: 16),
          const MusterDivider(),

          // ── Date ──────────────────────────────────────────────────────
          SectionLabel(l.selectDate),
          AppCard(
            onTap: _pickDate,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: primary.withValues(alpha: 0.3)),
                ),
                child: const Center(
                    child: Icon(Icons.calendar_today_rounded,
                        size: 18, color: Color(0xFF00E5FF))),
              ),
              const SizedBox(width: 12),
              Expanded(
                  child: Text(_dateLabel,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.body(15,
                          context: context,
                          color: txt,
                          weight: FontWeight.w600))),
              const SizedBox(width: 8),
              Icon(
                Directionality.of(context) == TextDirection.rtl
                    ? Icons.chevron_left
                    : Icons.chevron_right,
                color: muted,
              ),
            ]),
          ),
          const SizedBox(height: 20),

          // ── Field ─────────────────────────────────────────────────────
          SectionLabel(l.selectField),
          GridView.count(
            crossAxisCount: facilityCols,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            childAspectRatio: context.isSmallPhone ? 2.2 : 2.6,
            children: MockData.facilities.map((f) {
              final active = _field?.id == f.id;
              return GestureDetector(
                onTap: () {
                  if (f.isAvailable) setState(() => _field = f);
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                  decoration: BoxDecoration(
                    color: active ? primary.withValues(alpha: 0.10) : surf,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: active ? primary : border),
                  ),
                  child: Stack(children: [
                    Center(
                        child: Text(f.name,
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyles.body(15,
                                context: context,
                                weight: FontWeight.w600,
                                color: f.isAvailable
                                    ? (active ? primary : txt)
                                    : muted))),
                    if (!f.isAvailable)
                      Positioned(
                          top: 0,
                          right: 0,
                          child: Text(l.full,
                              style: AppTextStyles.label(
                                  color: context.errorColor))),
                  ]),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 20),

          // ── Time ──────────────────────────────────────────────────────
          SectionLabel(l.selectTime),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: MockData.timeSlots.map((t) {
              final active = _time == t;
              final hasConflict = _field != null &&
                  context
                      .watch<AppState>()
                      .hasBookingConflict(_field!.id, _date, t);
              return GestureDetector(
                // FIX #2: Block selecting conflicted slots
                onTap: () {
                  if (!hasConflict) setState(() => _time = t);
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: hasConflict
                        ? context.errorColor.withValues(alpha: 0.08)
                        : active
                            ? primary.withValues(alpha: 0.10)
                            : surf,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                        color: hasConflict
                            ? context.errorColor.withValues(alpha: 0.5)
                            : active
                                ? primary
                                : border),
                  ),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    Text(t,
                        style: AppTextStyles.body(16,
                            context: context,
                            color: hasConflict
                                ? context.errorColor
                                : active
                                    ? primary
                                    : txt,
                            weight: FontWeight.w600)),
                    if (hasConflict) ...[
                      const SizedBox(width: 4),
                      Icon(Icons.block, size: 10, color: context.errorColor),
                    ],
                  ]),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 24),

          // ── Payment ───────────────────────────────────────────────────
          SectionLabel(l.paymentMethod),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: surf.withValues(alpha: 0.7),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: border),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.payments_outlined, color: second, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l.payAtFacility,
                        style: AppTextStyles.body(14,
                            context: context,
                            color: txt,
                            weight: FontWeight.w700),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        l.appDoesNotProcessPayments,
                        style: AppTextStyles.body(12,
                            context: context, color: muted),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          MorphButton(
            label: '${l.confirmBooking} – ${_field?.name ?? "–"}',
            loading: _loading,
            success: false,
            onPressed: _confirm,
            backgroundColor: second,
            foregroundColor:
                context.isDark ? const Color(0xFF0a1a04) : Colors.white,
          ),
        ],
      ),
    );
  }
}

// ── Confirmation View ─────────────────────────────────────────────────────────
class _ConfirmationView extends StatelessWidget {
  final String facilityName, time, date;
  final VoidCallback onReset;

  const _ConfirmationView({
    required this.facilityName,
    required this.time,
    required this.date,
    required this.onReset,
  });

  @override
  Widget build(BuildContext context) {
    final second = context.secondaryColor;
    final l = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: context.bgColor,
      appBar: const MusterAppBar(),
      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child:
                Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              const Icon(Icons.check_circle_rounded,
                  size: 64, color: Color(0xFFA8FF3E)),
              const SizedBox(height: 20),
              Text(l.bookingConfirmed,
                  style: AppTextStyles.display(28,
                      context: context, color: context.textColor),
                  textAlign: TextAlign.center),
              const SizedBox(height: 12),
              Text('$facilityName\n$time · $date',
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.body(16,
                      context: context, color: context.mutedColor),
                  textAlign: TextAlign.center),
              const SizedBox(height: 14),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: second.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: second.withValues(alpha: 0.3)),
                ),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  Icon(Icons.payments_outlined, color: second, size: 16),
                  const SizedBox(width: 8),
                  Text(l.payAtFacility,
                      style: AppTextStyles.body(13,
                          context: context,
                          color: second,
                          weight: FontWeight.w600)),
                ]),
              ),
              const SizedBox(height: 8),
              Text(
                l.appDoesNotProcessPayments,
                textAlign: TextAlign.center,
                style: AppTextStyles.body(12,
                    context: context, color: context.mutedColor),
              ),
              const SizedBox(height: 24),
              const AppProgressBar(
                  value: 1.0, color: Color(0xFFA8FF3E), height: 3),
              const SizedBox(height: 28),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: onReset,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: second,
                    foregroundColor:
                        context.isDark ? const Color(0xFF0a1a04) : Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                  ),
                  child: Text(l.bookAnother,
                      style: AppTextStyles.body(15,
                          context: context,
                          color: context.isDark
                              ? const Color(0xFF0a1a04)
                              : Colors.white,
                          weight: FontWeight.w700)),
                ),
              ),
            ]),
          ),
        ),
      ),
    );
  }
}
