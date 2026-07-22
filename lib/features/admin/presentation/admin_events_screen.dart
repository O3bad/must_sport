import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/theme/widgets.dart';
import '../../../core/state/app_state.dart';
import '../../../core/models/models.dart';

class AdminEventsScreen extends StatelessWidget {
  const AdminEventsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final events = context.select<AppState, List<SportEvent>>((s) => s.events);

    final isAr = Localizations.localeOf(context).languageCode == 'ar';

    return Scaffold(
      backgroundColor: context.bgColor,
      appBar: _AdminAppBar(title: isAr ? 'إدارة الفعاليات' : 'Manage Events'),
      floatingActionButton: _GlowFAB(
        label: isAr ? 'إضافة فعالية' : 'Add Event',
        icon: Icons.add,
        onTap: () => _showEventSheet(context, null),
      ),
      body: events.isEmpty
          ? Center(
              child: Text(isAr ? 'لا توجد فعاليات بعد' : 'No events yet',
                  style: AppTextStyles.body(14, color: context.mutedColor, context: context)))
          : ListView.separated(
              padding: EdgeInsetsDirectional.only(
                start: 20, end: 20, top: 20,
                bottom: MediaQuery.of(context).padding.bottom + 100,
              ),
              itemCount: events.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (ctx, i) => _AdminEventCard(
                event: events[i],
                onEdit: () => _showEventSheet(ctx, events[i]),
              ),
            ),
    );
  }

  void _showEventSheet(BuildContext context, SportEvent? existing) {
    final appState = context.read<AppState>();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ChangeNotifierProvider.value(
        value: appState,
        child: _EventSheet(existing: existing),
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

class _AdminEventCard extends StatelessWidget {
  final SportEvent event;
  final VoidCallback onEdit;
  const _AdminEventCard({required this.event, required this.onEdit});

  Color _col(BuildContext ctx) => switch (event.status) {
    EventStatus.open      => ctx.secondaryColor,
    EventStatus.full      => ctx.errorColor,
    EventStatus.soon      => ctx.accentColor,
    EventStatus.completed => ctx.mutedColor,
  };

  @override
  Widget build(BuildContext context) {
    final col   = _col(context);
    final txt   = context.textColor;
    final muted = context.mutedColor;

    final isAr  = Localizations.localeOf(context).languageCode == 'ar';

    return AppCard(
      glowColor: col,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Icon(event.sportType.icon, color: col, size: 24),
          const SizedBox(width: 10),
          Expanded(child: Text(event.title,
              maxLines: 1, overflow: TextOverflow.ellipsis,
              style: AppTextStyles.body(15, color: txt, weight: FontWeight.w700, context: context))),
          const SizedBox(width: 6),
          AppPill(label: event.status.name.toUpperCase(), color: col),
          const SizedBox(width: 6),
          // FIX: Edit button
          GestureDetector(
            onTap: onEdit,
            child: Container(
              width: 32, height: 32,
              decoration: BoxDecoration(
                color: context.primaryColor.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(Icons.edit_outlined, color: context.primaryColor, size: 16),
            ),
          ),
          const SizedBox(width: 6),
          GestureDetector(
            onTap: () => _confirmDelete(context),
            child: Container(
              width: 32, height: 32,
              decoration: BoxDecoration(
                color: context.errorColor.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(Icons.delete_outline, color: context.errorColor, size: 16),
            ),
          ),
        ]),
        const SizedBox(height: 8),
        Text('${event.dateRangeLabel} · ${event.location}',
            maxLines: 1, overflow: TextOverflow.ellipsis,
            style: AppTextStyles.body(13, color: muted, context: context)),
        const SizedBox(height: 10),
        AppProgressBar(value: event.fillRatio, color: col, height: 4),
        const SizedBox(height: 6),
        Text(isAr
            ? '${event.participants}/${event.maxParticipants} مشارك  ·  ${event.spotsLeft} أماكن متبقية'
            : '${event.participants}/${event.maxParticipants} participants  ·  ${event.spotsLeft} spots left',
            style: AppTextStyles.body(13, color: muted, context: context)),
      ]),
    );
  }

  void _confirmDelete(BuildContext context) {
    final state = context.read<AppState>();
    final isAr  = Localizations.localeOf(context).languageCode == 'ar';
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: context.surfaceColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: Text(isAr ? 'حذف الفعالية؟' : 'Delete Event?',
            style: AppTextStyles.heading(18, color: context.textColor, context: context)),
        content: Text(isAr ? 'سيتم حذف "${event.title}" نهائياً.' : 'This will permanently remove "${event.title}".',
            style: AppTextStyles.body(15, color: context.mutedColor, context: context)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context),
              child: Text(isAr ? 'إلغاء' : 'Cancel', style: AppTextStyles.body(15, color: context.mutedColor, context: context))),
          TextButton(
            onPressed: () {
              state.adminRemoveEvent(event.id);
              Navigator.pop(context);
            },
            child: Text(isAr ? 'حذف' : 'Delete',
                style: AppTextStyles.body(15, color: context.errorColor, weight: FontWeight.w700, context: context)),
          ),
        ],
      ),
    );
  }
}

// ─── ADD / EDIT SHEET ─────────────────────────────────────────────────────────
class _EventSheet extends StatefulWidget {
  // FIX: existing != null means edit mode
  final SportEvent? existing;
  const _EventSheet({this.existing});
  @override
  State<_EventSheet> createState() => _EventSheetState();
}

class _EventSheetState extends State<_EventSheet> {
  late final TextEditingController _titleCtrl;
  late final TextEditingController _locationCtrl;
  late final TextEditingController _maxCtrl;
  late SportCategory _sport;
  late EventStatus   _status;
  late int           _max;
  DateTime?          _endDate;
  String?            _titleError;

  bool get _isEdit => widget.existing != null;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    _titleCtrl    = TextEditingController(text: e?.title ?? '');
    _locationCtrl = TextEditingController(text: e?.location ?? '');
    // FIX: exclude SportCategory.all from dropdown default
    _sport  = (e?.sportType == SportCategory.all || e == null)
        ? SportCategory.football
        : e.sportType;
    _status = e?.status ?? EventStatus.open;
    _max    = e?.maxParticipants ?? 32;
    _maxCtrl = TextEditingController(text: '$_max');
    _endDate = e?.endDate;
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _locationCtrl.dispose();
    _maxCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickEndDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _endDate ?? DateTime.now().add(const Duration(days: 14)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (ctx, child) => Theme(
        data: ctx.isDark
            ? ThemeData.dark().copyWith(colorScheme: ColorScheme.dark(
                primary: ctx.primaryColor, surface: DarkColors.surface2))
            : ThemeData.light().copyWith(colorScheme: ColorScheme.light(
                primary: ctx.primaryColor, surface: LightColors.surface)),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _endDate = picked);
  }

  @override
  Widget build(BuildContext context) {
    final surf   = context.surfaceColor;
    final txt    = context.textColor;
    final muted  = context.mutedColor;
    final border = context.borderColor;
    final second = context.secondaryColor;

    final isAr   = Localizations.localeOf(context).languageCode == 'ar';

    return Container(
      decoration: BoxDecoration(
        color: surf,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        border: Border.all(color: border),
      ),
      padding: EdgeInsetsDirectional.only(
        start: 24, end: 24, top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: SingleChildScrollView(
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          Center(child: Container(width: 40, height: 4,
              decoration: BoxDecoration(color: border, borderRadius: BorderRadius.circular(99)))),
          const SizedBox(height: 16),
          Text(_isEdit ? (isAr ? 'تعديل الفعالية' : 'Edit Event') : (isAr ? 'فعالية جديدة' : 'New Event'),
              style: AppTextStyles.display(22, color: txt, context: context)),
          const SizedBox(height: 20),

          Text(isAr ? 'العنوان' : 'TITLE', style: AppTextStyles.label(color: muted, context: context)),
          const SizedBox(height: 6),
          // FIX: title validation with error display
          TextField(
            controller: _titleCtrl,
            maxLength: 60,
            style: AppTextStyles.body(14, color: txt, context: context),
            onChanged: (_) {
              if (_titleError != null) setState(() => _titleError = null);
            },
            decoration: _inputDeco(isAr ? 'مثال: كأس كرة القدم 2026' : 'e.g. Football Cup 2026', border).copyWith(
              errorText: _titleError,
              counterStyle: AppTextStyles.label(color: muted, context: context),
            ),
          ),
          const SizedBox(height: 14),

          Text(isAr ? 'المكان' : 'LOCATION', style: AppTextStyles.label(color: muted, context: context)),
          const SizedBox(height: 6),
          TextField(
            controller: _locationCtrl,
            maxLength: 40,
            style: AppTextStyles.body(14, color: txt, context: context),
            decoration: _inputDeco(isAr ? 'مثال: الملعب الرئيسي' : 'e.g. Main Court', border).copyWith(
              counterStyle: AppTextStyles.label(color: muted, context: context),
            ),
          ),
          const SizedBox(height: 14),

          Row(children: [
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(isAr ? 'الرياضة' : 'SPORT', style: AppTextStyles.label(color: muted, context: context)),
              const SizedBox(height: 6),
              // FIX: exclude SportCategory.all from options
              _DropdownField<SportCategory>(
                value: _sport,
                items: SportCategory.values
                    .where((c) => c != SportCategory.all)
                    .toList(),
                label: (c) => c.displayName,
                onChanged: (v) => setState(() => _sport = v),
                surf: surf, border: border, txt: txt,
              ),
            ])),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(isAr ? 'الحالة' : 'STATUS', style: AppTextStyles.label(color: muted, context: context)),
              const SizedBox(height: 6),
              _DropdownField<EventStatus>(
                value: _status == EventStatus.full || _status == EventStatus.completed
                    ? EventStatus.open
                    : _status,
                items: const [EventStatus.open, EventStatus.soon],
                label: (s) => s.name.toUpperCase(),
                onChanged: (v) => setState(() => _status = v),
                surf: surf, border: border, txt: txt,
              ),
            ])),
          ]),
          const SizedBox(height: 14),

          // FIX: End date picker
          Text(isAr ? 'تاريخ الانتهاء (اختياري)' : 'END DATE (OPTIONAL)', style: AppTextStyles.label(color: muted, context: context)),
          const SizedBox(height: 6),
          AppCard(
            onTap: _pickEndDate,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(children: [
              Expanded(child: Text(_endDate != null
                  ? '${_mo(_endDate!.month)} ${_endDate!.day}, ${_endDate!.year}'
                  : (isAr ? 'نفس تاريخ البدء' : 'Same as start date'),
                maxLines: 1, overflow: TextOverflow.ellipsis,
                style: AppTextStyles.body(15,
                  color: _endDate != null ? txt : muted, context: context))),
              const SizedBox(width: 8),
              if (_endDate != null)
                GestureDetector(
                  onTap: () => setState(() => _endDate = null),
                  child: Icon(Icons.close, color: muted, size: 16),
                )
              else
                Icon(Icons.calendar_today_outlined, color: muted, size: 16),
            ]),
          ),
          const SizedBox(height: 14),

          Row(children: [
            Flexible(
              child: Text(isAr ? 'الحد الأقصى للمشاركين' : 'MAX PARTICIPANTS',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.label(color: muted, context: context)),
            ),
            const Spacer(),
            SizedBox(
              width: 64,
              child: TextField(
                controller: _maxCtrl,
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                style: AppTextStyles.body(14, color: second, weight: FontWeight.w700, context: context),
                decoration: InputDecoration(
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: second.withValues(alpha: 0.5)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: second, width: 1.5),
                  ),
                  filled: true,
                  fillColor: second.withValues(alpha: 0.06),
                ),
                onChanged: (v) {
                  final n = int.tryParse(v);
                  if (n != null && n >= 2 && n <= 512) {
                    setState(() => _max = n);
                  }
                },
              ),
            ),
          ]),
          Slider(
            value: _max.clamp(8, 256).toDouble(),
            min: 8, max: 256, divisions: 30,
            activeColor: second,
            inactiveColor: border,
            onChanged: (v) {
              setState(() {
                _max = v.round();
                _maxCtrl.text = '$_max';
              });
            },
          ),
          const SizedBox(height: 20),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _submit,
              style: ElevatedButton.styleFrom(
                backgroundColor: second,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                elevation: 0,
              ),
              child: Text(_isEdit ? (isAr ? 'حفظ التغييرات' : 'Save Changes') : (isAr ? 'إنشاء فعالية' : 'Create Event'),
                  style: AppTextStyles.body(15, color: Colors.white, weight: FontWeight.w700, context: context)),
            ),
          ),
        ]),
      ),
    );
  }

  void _submit() {
    final title = _titleCtrl.text.trim();
    final isAr  = Localizations.localeOf(context).languageCode == 'ar';
    // FIX: Validate title length
    if (title.isEmpty) {
      setState(() => _titleError = isAr ? 'لا يمكن أن يكون العنوان فارغاً' : 'Title cannot be empty');
      return;
    }
    if (title.length < 3) {
      setState(() => _titleError = isAr ? 'يجب أن يتكون العنوان من 3 أحرف على الأقل' : 'Title must be at least 3 characters');
      return;
    }

    final state = context.read<AppState>();

    if (_isEdit) {
      // Edit mode: rebuild the existing event preserving participants etc.
      final updated = SportEvent(
        id:              widget.existing!.id,
        title:           title,
        emoji:           _sport.emoji,
        sportType:       _sport,
        startDate:       widget.existing!.startDate,
        endDate:         _endDate,
        participants:    widget.existing!.participants,
        maxParticipants: _max,
        status:          _status,
        location:        _locationCtrl.text.trim().isEmpty ? 'TBD' : _locationCtrl.text.trim(),
      );
      state.adminUpdateEvent(updated);
      state.showToast(isAr ? '✓ تم تحديث الفعالية "${updated.title}"' : '✓ Event "${updated.title}" updated');
    } else {
      final event = SportEvent(
        id:              const Uuid().v4(),
        title:           title,
        emoji:           _sport.emoji,
        sportType:       _sport,
        startDate:       DateTime.now().add(const Duration(days: 14)),
        endDate:         _endDate,
        participants:    0,
        maxParticipants: _max,
        status:          _status,
        location:        _locationCtrl.text.trim().isEmpty ? 'TBD' : _locationCtrl.text.trim(),
      );
      state.adminAddEvent(event);
      state.showToast(isAr ? '✓ تم إنشاء الفعالية "${event.title}"' : '✓ Event "${event.title}" created');
    }
    Navigator.pop(context);
  }

  InputDecoration _inputDeco(String hint, Color border) =>
      InputDecoration(
        hintText: hint,
        hintStyle: AppTextStyles.body(15, color: context.mutedColor, context: context),
        filled: true,
        fillColor: context.surface2Color,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: border)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: context.primaryColor, width: 1.5)),
        errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: context.errorColor)),
        focusedErrorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: context.errorColor, width: 1.5)),
      );

  String _mo(int m) => const ['','Jan','Feb','Mar','Apr','May','Jun',
      'Jul','Aug','Sep','Oct','Nov','Dec'][m];
}

class _DropdownField<T> extends StatelessWidget {
  final T value;
  final List<T> items;
  final String Function(T) label;
  final ValueChanged<T> onChanged;
  final Color surf, border, txt;

  const _DropdownField({
    required this.value, required this.items, required this.label,
    required this.onChanged, required this.surf, required this.border,
    required this.txt,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: context.surface2Color,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: border),
      ),
      child: DropdownButton<T>(
        value: value,
        isExpanded: true,
        underline: const SizedBox(),
        dropdownColor: surf,
        style: AppTextStyles.body(15, color: txt, context: context),
        items: items.map((i) => DropdownMenuItem(
          value: i,
          child: Text(label(i), style: AppTextStyles.body(15, color: txt, context: context)),
        )).toList(),
        onChanged: (v) { if (v != null) onChanged(v); },
      ),
    );
  }
}

class _GlowFAB extends StatefulWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  const _GlowFAB({required this.label, required this.icon, required this.onTap});
  @override
  State<_GlowFAB> createState() => _GlowFABState();
}

class _GlowFABState extends State<_GlowFAB> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _glow;
  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1600))
      ..repeat(reverse: true);
    _glow = Tween<double>(begin: 0.4, end: 1.0)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }
  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final second = context.secondaryColor;
    return AnimatedBuilder(
      animation: _glow,
      builder: (_, __) => GestureDetector(
        onTap: widget.onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [second, second.withValues(alpha: 0.75)],
              begin: Alignment.topLeft, end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: second.withValues(alpha: 0.55 * _glow.value),
                blurRadius: 24 * _glow.value,
                spreadRadius: 2 * _glow.value,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            Icon(widget.icon, color: Colors.white, size: 18),
            const SizedBox(width: 6),
            Text(widget.label,
                style: AppTextStyles.body(14, color: Colors.white, weight: FontWeight.w700, context: context)),
          ]),
        ),
      ),
    );
  }
}
