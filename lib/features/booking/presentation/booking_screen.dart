import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/widgets.dart';
import '../../../core/state/app_state.dart';
import '../../../core/state/notification_state.dart';
import '../../../core/models/models.dart';
import '../../../core/models/mock_data.dart';
import '../../../l10n/app_localizations.dart';

// ── Input formatters ──────────────────────────────────────────────────────────

/// Groups card digits into blocks of 4: "1234 5678 9012 3456"
class _CardNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    final digits = newValue.text.replaceAll(RegExp(r'\D'), '');
    final capped  = digits.length > 16 ? digits.substring(0, 16) : digits;
    final buffer  = StringBuffer();
    for (int i = 0; i < capped.length; i++) {
      if (i > 0 && i % 4 == 0) buffer.write('  ');
      buffer.write(capped[i]);
    }
    final str = buffer.toString();
    return TextEditingValue(
      text: str,
      selection: TextSelection.collapsed(offset: str.length),
    );
  }
}

/// Formats expiry as MM/YY
class _ExpiryFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    final digits = newValue.text.replaceAll(RegExp(r'\D'), '');
    final capped  = digits.length > 4 ? digits.substring(0, 4) : digits;
    String str;
    if (capped.length >= 3) {
      str = '${capped.substring(0, 2)}/${capped.substring(2)}';
    } else {
      str = capped;
    }
    return TextEditingValue(
      text: str,
      selection: TextSelection.collapsed(offset: str.length),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class BookingScreen extends StatefulWidget {
  const BookingScreen({super.key});
  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  Facility? _field;
  String?   _time;
  DateTime  _date = DateTime.now();
  bool      _confirmed = false;
  bool      _loading   = false;
  String    _paymentMethod = 'instapay'; // instapay | vodafone_cash | fawry | card

  // FIX #7: GlobalKeys so _confirm() can call validate() on child form widgets
  final GlobalKey<_GlassCardFormState>  _cardFormKey  = GlobalKey();
  final GlobalKey<_MobilePayFormState>  _instapayKey  = GlobalKey();
  final GlobalKey<_MobilePayFormState>  _vodafoneKey  = GlobalKey();

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
    final months = ['',
      l.january, l.february, l.march,
      l.april, l.may, l.june,
      l.july, l.august, l.september,
      l.october, l.november, l.december
    ];
    return '${months[_date.month]} ${_date.day}, ${_date.year}';
  }

  Future<void> _confirm() async {
    if (_field == null || _time == null) return;

    // FIX #1: Validate payment input before confirming
    String? payError;
    if (_paymentMethod == 'card') {
      payError = _cardFormKey.currentState?.validate();
    } else if (_paymentMethod == 'instapay') {
      payError = _instapayKey.currentState?.validate();
    } else if (_paymentMethod == 'vodafone_cash') {
      payError = _vodafoneKey.currentState?.validate();
    }
    // Fawry needs no user input — reference is pre-generated
    if (payError != null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(payError),
          backgroundColor: context.errorColor,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final appState   = context.read<AppState>();
    final notifState = context.read<NotificationState>();
    final fieldName  = _field!.name;
    final fieldId    = _field!.id;
    final time       = _time!;
    final date       = _date;
    final dateLabel  = _dateLabel;
    final payMethod  = _paymentMethod;

    if (appState.hasBookingConflict(fieldId, date, time)) {
      if (!mounted) return;
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          backgroundColor: context.surfaceColor,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
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
              child: Text(AppLocalizations.of(context)!.ok, style: AppTextStyles.body(15,
                  color: context.primaryColor, weight: FontWeight.w700)),
            ),
          ],
        ),
      );
      return;
    }

    setState(() => _loading = true);
    await Future.delayed(const Duration(milliseconds: 600));

    // FIX #6: Pass paymentMethod into Booking so it is persisted
    await appState.addBooking(Booking(
      bookingId:     const Uuid().v4(),
      facilityId:    fieldId,
      facilityName:  fieldName,
      date:          date,
      timeSlot:      time,
      status:        BookingStatus.confirmed,
      studentName:   appState.user.name,
      paymentMethod: payMethod,
    ));
    if (!mounted) return;
    notifState.addReservationReminder(
      facilityName: fieldName,
      date: dateLabel,
      time: time,
    );
    setState(() { _loading = false; _confirmed = true; });
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
        paymentMethod: _paymentMethod,
        onReset: () => setState(() => _confirmed = false),
      );
    }

    final primary = context.primaryColor;
    final second  = context.secondaryColor;
    final surf    = context.surfaceColor;
    final border  = context.borderColor;
    final txt     = context.textColor;
    final muted   = context.mutedColor;
    final hPad    = context.hPadding;
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
          left: hPad, right: hPad, top: 20,
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
                width: 38, height: 38,
                decoration: BoxDecoration(
                  color: primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: primary.withValues(alpha: 0.3)),
                ),
                child: const Center(child: Icon(Icons.calendar_today_rounded, size: 18, color: Color(0xFF00E5FF))),
              ),
              const SizedBox(width: 12),
              Expanded(child: Text(_dateLabel,
                  maxLines: 1, overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.body(15, context: context, color: txt, weight: FontWeight.w600))),
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
            crossAxisCount: facilityCols, shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 10, crossAxisSpacing: 10,
            childAspectRatio: context.isSmallPhone ? 2.2 : 2.6,
            children: MockData.facilities.map((f) {
              final active = _field?.id == f.id;
              return GestureDetector(
                onTap: () { if (f.isAvailable) setState(() => _field = f); },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
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
                            style: AppTextStyles.body(15, context: context, weight: FontWeight.w600,
                                color: f.isAvailable ? (active ? primary : txt) : muted))),
                    if (!f.isAvailable)
                      Positioned(top: 0, right: 0,
                        child: Text(l.full,
                            style: AppTextStyles.label(color: context.errorColor))),
                  ]),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 20),

          // ── Time ──────────────────────────────────────────────────────
          SectionLabel(l.selectTime),
          Wrap(
            spacing: 8, runSpacing: 8,
            children: MockData.timeSlots.map((t) {
              final active = _time == t;
              final hasConflict = _field != null &&
                  context.watch<AppState>().hasBookingConflict(_field!.id, _date, t);
              return GestureDetector(
                // FIX #2: Block selecting conflicted slots
                onTap: () { if (!hasConflict) setState(() => _time = t); },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: hasConflict ? context.errorColor.withValues(alpha: 0.08)
                        : active ? primary.withValues(alpha: 0.10) : surf,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: hasConflict
                        ? context.errorColor.withValues(alpha: 0.5)
                        : active ? primary : border),
                  ),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    Text(t, style: AppTextStyles.body(16, context: context,
                        color: hasConflict ? context.errorColor : active ? primary : txt,
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

          // ── Payment Method ─────────────────────────────────────────────
          SectionLabel(l.paymentMethod),
          const SizedBox(height: 10),
          _PaymentSelector(
            selected: _paymentMethod,
            accentColor: second,
            onChanged: (v) => setState(() => _paymentMethod = v),
          ),
          if (_paymentMethod == 'card') ...[
            const SizedBox(height: 14),
            _GlassCardForm(key: _cardFormKey, accentColor: second),
          ],
          if (_paymentMethod == 'instapay') ...[
            const SizedBox(height: 14),
            _MobilePayForm(
              key: _instapayKey,
              accentColor: second,
              method: 'instapay',
              hint: 'InstaPay username or +20xxxxxxxxxx',
              icon: Icons.flash_on_rounded,
            ),
          ],
          if (_paymentMethod == 'vodafone_cash') ...[
            const SizedBox(height: 14),
            _MobilePayForm(
              key: _vodafoneKey,
              accentColor: second,
              method: 'vodafone_cash',
              hint: 'Vodafone Cash number (010xxxxxxxx)',
              icon: Icons.phone_android_rounded,
            ),
          ],
          if (_paymentMethod == 'fawry') ...[
            const SizedBox(height: 14),
            _FawryForm(accentColor: second),
          ],

          const SizedBox(height: 24),

          MorphButton(
            label: '${l.confirmBooking} – ${_field?.name ?? "–"}',
            loading: _loading,
            success: false,
            onPressed: _confirm,
            backgroundColor: second,
            foregroundColor: context.isDark ? const Color(0xFF0a1a04) : Colors.white,
          ),
        ],
      ),
    );
  }
}

// ── Payment Method Selector (2×2 grid — overflow-safe) ───────────────────────
class _PaymentSelector extends StatelessWidget {
  final String selected;
  final Color accentColor;
  final void Function(String) onChanged;

  const _PaymentSelector({
    required this.selected,
    required this.accentColor,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final surf   = context.surfaceColor;
    final border = context.borderColor;
    final muted  = context.mutedColor;
    final l      = AppLocalizations.of(context)!;
    final cols   = context.isTablet ? 4 : (context.isSmallPhone ? 1 : 2);
    final ratio  = context.isSmallPhone ? 2.8 : 1.6;

    final methods = [
      ('instapay',      Icons.flash_on_rounded,     l.payInstaPay,      l.payCentralBank),
      ('vodafone_cash', Icons.phone_android_rounded, l.payVodafoneCash, l.payMobileWallet),
      ('fawry',         Icons.store_rounded,         l.payFawry,         l.payAtOutlet),
      ('card',          Icons.credit_card_rounded,   l.payCard,          l.payVisaMastercard),
    ];

    return GridView.builder(
      shrinkWrap: true,
      padding: EdgeInsets.zero,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: methods.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: cols,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        childAspectRatio: ratio,
      ),
      itemBuilder: (_, i) => _tile(methods[i], surf, border, muted, context),
    );
  }

  Widget _tile(
    (String, IconData, String, String) m,
    Color surf, Color border, Color muted, BuildContext context,
  ) {
    final id     = m.$1;
    final icon   = m.$2;
    final label  = m.$3;
    final sub    = m.$4;
    final active = selected == id;

    return GestureDetector(
      onTap: () { HapticFeedback.selectionClick(); onChanged(id); },
      child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
          decoration: BoxDecoration(
            color: active ? accentColor.withValues(alpha: 0.10) : surf,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: active ? accentColor : border,
              width: active ? 1.8 : 1,
            ),
            boxShadow: active
                ? [BoxShadow(color: accentColor.withValues(alpha: 0.18), blurRadius: 12)]
                : [],
          ),
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              Icon(icon, color: active ? accentColor : muted, size: 20),
              const SizedBox(height: 4),
              Text(label,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                  style: AppTextStyles.body(12, context: context, color: active ? accentColor : muted,
                      weight: active ? FontWeight.w700 : FontWeight.w600)),
              const SizedBox(height: 2),
              Text(sub,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                  style: AppTextStyles.body(11, context: context, color: muted,
                      weight: FontWeight.w400)),
            ]),
          ),
      ),
    );
  }
}

// ── Glass card form ───────────────────────────────────────────────────────────
class _GlassCardForm extends StatefulWidget {
  final Color accentColor;
  const _GlassCardForm({super.key, required this.accentColor});
  @override
  State<_GlassCardForm> createState() => _GlassCardFormState();
}

class _GlassCardFormState extends State<_GlassCardForm> {
  final _cardCtrl = TextEditingController();
  final _expCtrl  = TextEditingController();
  final _cvcCtrl  = TextEditingController();
  final _nameCtrl = TextEditingController();

  @override
  void dispose() {
    _cardCtrl.dispose(); _expCtrl.dispose();
    _cvcCtrl.dispose();  _nameCtrl.dispose();
    super.dispose();
  }

  // FIX #1 & #4: Returns an error string if validation fails, null if OK
  String? validate() {
    final l      = AppLocalizations.of(context)!;
    final digits = _cardCtrl.text.replaceAll(RegExp(r'\D'), '');
    if (digits.length != 16) return l.errorCardNumber;

    final exp      = _expCtrl.text.trim();
    final expMatch = RegExp(r'^(0[1-9]|1[0-2])\/\d{2}$').hasMatch(exp);
    if (!expMatch) return l.errorExpiry;

    final parts = exp.split('/');
    final month = int.parse(parts[0]);
    final year  = 2000 + int.parse(parts[1]);
    final now   = DateTime.now();
    if (year < now.year || (year == now.year && month < now.month)) {
      return l.errorExpiry;
    }

    final cvc = _cvcCtrl.text.trim();
    if (cvc.length < 3 || cvc.length > 4) return l.errorCVC;

    if (_nameCtrl.text.trim().isEmpty) return l.errorCardholder;
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final surf   = context.surfaceColor;
    final border = context.borderColor;
    final txt    = context.textColor;
    final muted  = context.mutedColor;
    final accent = widget.accentColor;
    final l      = AppLocalizations.of(context)!;

    InputDecoration dec(String hint, IconData icon) => InputDecoration(
      hintText: hint,
      hintStyle: AppTextStyles.body(14, context: context, color: muted.withValues(alpha: 0.6)),
      prefixIcon: Icon(icon, color: muted, size: 18),
      filled: true, fillColor: surf,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: border)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: accent, width: 1.6)),
    );

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: surf.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: border),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Icon(Icons.lock_rounded, color: accent, size: 14),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              l.securePayment,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.body(12, context: context, color: accent, weight: FontWeight.w600),
            ),
          ),
          const Spacer(),
          _CardBadge('VISA', const Color(0xFF1A1F71)),
          const SizedBox(width: 6),
          _CardBadge('MC', const Color(0xFFEB001B)),
        ]),
        const SizedBox(height: 14),
        // FIX #4: digits only, grouped 4-4-4-4, max 16 digits
        TextField(
          controller: _cardCtrl,
          keyboardType: TextInputType.number,
          style: AppTextStyles.body(15, context: context, color: txt),
          inputFormatters: [_CardNumberFormatter()],
          decoration: dec('0000  0000  0000  0000', Icons.credit_card_rounded),
        ),
        const SizedBox(height: 10),
        Row(children: [
          // FIX #4: formatted MM/YY, max 5 chars
          Expanded(child: TextField(
            controller: _expCtrl,
            keyboardType: TextInputType.number,
            style: AppTextStyles.body(15, context: context, color: txt),
            inputFormatters: [_ExpiryFormatter()],
            decoration: dec(l.expiryDate, Icons.date_range_rounded),
          )),
          const SizedBox(width: 10),
          // FIX #4: digits only, max 4
          Expanded(child: TextField(
            controller: _cvcCtrl,
            keyboardType: TextInputType.number,
            obscureText: true,
            style: AppTextStyles.body(15, context: context, color: txt),
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(4),
            ],
            decoration: dec(l.cvc, Icons.lock_outline),
          )),
        ]),
        const SizedBox(height: 10),
        TextField(
          controller: _nameCtrl,
          textCapitalization: TextCapitalization.words,
          style: AppTextStyles.body(15, context: context, color: txt),
          decoration: dec(l.cardholderName, Icons.person_outline),
        ),
      ]),
    );
  }
}

class _CardBadge extends StatelessWidget {
  final String text;
  final Color color;
  const _CardBadge(this.text, this.color);
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
    decoration: BoxDecoration(
      color: color.withValues(alpha: 0.12),
      borderRadius: BorderRadius.circular(6),
      border: Border.all(color: color.withValues(alpha: 0.3)),
    ),
    child: Text(text, style: AppTextStyles.body(10, color: color, weight: FontWeight.w800)),
  );
}

// ── Confirmation View ─────────────────────────────────────────────────────────
class _ConfirmationView extends StatelessWidget {
  final String facilityName, time, date, paymentMethod;
  final VoidCallback onReset;

  const _ConfirmationView({
    required this.facilityName,
    required this.time,
    required this.date,
    required this.paymentMethod,
    required this.onReset,
  });

  @override
  Widget build(BuildContext context) {
    final second = context.secondaryColor;
    final l      = AppLocalizations.of(context)!;

    final payLabel = switch (paymentMethod) {
      'instapay'      => l.payInstaPay,
      'vodafone_cash' => l.payVodafoneCash,
      'fawry'         => l.payFawry,
      _               => l.payCard,
    };

    final payIcon = switch (paymentMethod) {
      'instapay'      => Icons.flash_on_rounded,
      'vodafone_cash' => Icons.phone_android_rounded,
      'fawry'         => Icons.store_rounded,
      _               => Icons.credit_card_rounded,
    };

    return Scaffold(
      backgroundColor: context.bgColor,
      appBar: const MusterAppBar(),
      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              const Icon(Icons.check_circle_rounded, size: 64, color: Color(0xFFA8FF3E)),
              const SizedBox(height: 20),
              Text(l.bookingConfirmed,
                  style: AppTextStyles.display(28, context: context, color: context.textColor),
                  textAlign: TextAlign.center),
              const SizedBox(height: 12),
              Text('$facilityName\n$time · $date',
                  maxLines: 3, overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.body(16, context: context, color: context.mutedColor),
                  textAlign: TextAlign.center),
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: second.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: second.withValues(alpha: 0.3)),
                ),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  Icon(payIcon, color: second, size: 16),
                  const SizedBox(width: 8),
                  Text(l.paidVia(payLabel),
                      style: AppTextStyles.body(13, context: context, color: second, weight: FontWeight.w600)),
                ]),
              ),
              const SizedBox(height: 24),
              const AppProgressBar(value: 1.0, color: Color(0xFFA8FF3E), height: 3),
              const SizedBox(height: 28),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: onReset,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: second,
                    foregroundColor: context.isDark ? const Color(0xFF0a1a04) : Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  child: Text(l.bookAnother,
                      style: AppTextStyles.body(15,
                          context: context,
                          color: context.isDark ? const Color(0xFF0a1a04) : Colors.white,
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

// ── Mobile Pay Form (InstaPay / Vodafone Cash) ────────────────────────────────
class _MobilePayForm extends StatefulWidget {
  final Color accentColor;
  final String method;
  final String hint;
  final IconData icon;
  const _MobilePayForm({
    super.key,
    required this.accentColor,
    required this.method,
    required this.hint,
    required this.icon,
  });
  @override
  State<_MobilePayForm> createState() => _MobilePayFormState();
}

class _MobilePayFormState extends State<_MobilePayForm> {
  final _numCtrl = TextEditingController();

  @override
  void dispose() { _numCtrl.dispose(); super.dispose(); }

  // FIX #5: Validate phone/username format
  String? validate() {
    final l     = AppLocalizations.of(context)!;
    final value = _numCtrl.text.trim();
    if (value.isEmpty) {
      return l.errorEnterPhone(widget.method == 'instapay' ? l.payInstaPay : l.payVodafoneCash);
    }
    if (widget.method == 'vodafone_cash') {
      final digits = value.replaceAll(RegExp(r'\D'), '');
      if (digits.length != 11 || !digits.startsWith('010')) {
        return l.errorVodafoneNumber;
      }
    } else if (widget.method == 'instapay') {
      final mobilePattern = RegExp(r'^(\+20|0)(10|11|12|15)\d{8}$');
      final isPhone    = mobilePattern.hasMatch(value.replaceAll(' ', ''));
      final isUsername = value.length >= 3 && !value.contains(' ');
      if (!isPhone && !isUsername) {
        return l.errorInstaPayFormat;
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final surf   = context.surfaceColor;
    final border = context.borderColor;
    final txt    = context.textColor;
    final muted  = context.mutedColor;
    final accent = widget.accentColor;
    final l      = AppLocalizations.of(context)!;

    final isInstaPay = widget.method == 'instapay';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: surf.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: border),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Icon(Icons.lock_rounded, color: accent, size: 14),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              isInstaPay ? l.payInstantlyCentralBank : l.payViaVodafoneCash,
              style: AppTextStyles.body(12, context: context, color: accent, weight: FontWeight.w600),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ]),
        const SizedBox(height: 14),
        TextField(
          controller: _numCtrl,
          keyboardType: isInstaPay ? TextInputType.emailAddress : TextInputType.phone,
          // FIX #5: digits only + 11-char limit for Vodafone Cash
          inputFormatters: isInstaPay
              ? []
              : [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(11)],
          style: AppTextStyles.body(15, context: context, color: txt),
          decoration: InputDecoration(
            hintText: isInstaPay ? l.instaPayHint : l.vodafoneCashHint,
            hintStyle: AppTextStyles.body(14, context: context, color: muted.withValues(alpha: 0.6)),
            prefixIcon: Icon(widget.icon, color: muted, size: 18),
            filled: true, fillColor: surf,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: accent, width: 1.6),
            ),
          ),
        ),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: accent.withValues(alpha: 0.07),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: accent.withValues(alpha: 0.25)),
          ),
          child: Row(children: [
            Icon(Icons.info_outline_rounded, color: accent, size: 14),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                isInstaPay ? l.instaPayInfo : l.vodafoneCashInfo,
                style: AppTextStyles.body(11, context: context, color: accent),
                overflow: TextOverflow.ellipsis,
                maxLines: 2,
              ),
            ),
          ]),
        ),
      ]),
    );
  }
}

// ── Fawry Form ────────────────────────────────────────────────────────────────
class _FawryForm extends StatelessWidget {
  final Color accentColor;
  const _FawryForm({required this.accentColor});

  static const _ref = 'FWR-2026-84712';

  @override
  Widget build(BuildContext context) {
    final surf   = context.surfaceColor;
    final border = context.borderColor;
    final muted  = context.mutedColor;
    final txt    = context.textColor;
    final accent = accentColor;
    final l      = AppLocalizations.of(context)!;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: surf.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: border),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Icon(Icons.store_rounded, color: accent, size: 14),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              l.fawryInstruction,
              style: AppTextStyles.body(12, context: context, color: accent, weight: FontWeight.w600),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ]),
        const SizedBox(height: 14),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: accent.withValues(alpha: 0.07),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: accent.withValues(alpha: 0.35)),
          ),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(l.referenceNumber,
                style: AppTextStyles.label(color: muted).copyWith(fontSize: 10)),
            const SizedBox(height: 6),
            // FIX #3: Copy button now copies the reference to clipboard
            GestureDetector(
              onTap: () {
                Clipboard.setData(const ClipboardData(text: _ref));
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(l.refCopied),
                    backgroundColor: accent,
                    behavior: SnackBarBehavior.floating,
                    duration: const Duration(seconds: 2),
                  ),
                );
              },
              child: Row(children: [
                Expanded(
                  child: Text(_ref,
                      style: AppTextStyles.display(18, context: context, color: accent),
                      overflow: TextOverflow.ellipsis),
                ),
                Icon(Icons.copy_rounded, color: accent, size: 18),
              ]),
            ),
          ]),
        ),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: surf,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: border),
          ),
          child: Column(children: [
            _FawryStep('1', l.fawryStep1, txt, muted),
            const SizedBox(height: 6),
            _FawryStep('2', l.fawryStep2, txt, muted),
            const SizedBox(height: 6),
            _FawryStep('3', l.fawryStep3, txt, muted),
            const SizedBox(height: 6),
            _FawryStep('4', l.fawryStep4, txt, muted),
          ]),
        ),
      ]),
    );
  }
}

class _FawryStep extends StatelessWidget {
  final String step, text;
  final Color txt, muted;
  const _FawryStep(this.step, this.text, this.txt, this.muted);
  @override
  Widget build(BuildContext context) => Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Container(
        width: 18, height: 18,
        decoration: BoxDecoration(
          color: context.primaryColor.withValues(alpha: 0.12),
          shape: BoxShape.circle,
        ),
        child: Center(child: Text(step,
            style: AppTextStyles.body(9, context: context, color: context.primaryColor, weight: FontWeight.w800))),
      ),
      const SizedBox(width: 8),
      Expanded(
        child: Text(text,
            style: AppTextStyles.body(12, context: context, color: muted),
            maxLines: 2,
            overflow: TextOverflow.ellipsis),
      ),
    ],
  );
}
