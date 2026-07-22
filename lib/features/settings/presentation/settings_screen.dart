import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/state/activity_state.dart';
import '../../../core/theme/theme_provider.dart';
import '../../../core/state/app_state.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/widgets.dart';
import '../../../l10n/app_localizations.dart';
import 'about_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});
  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late TextEditingController _nameCtrl;
  late TextEditingController _phoneCtrl;
  late TextEditingController _bioCtrl;
  String _faculty  = '';
  String _semester = '';
  bool   _saving   = false;
  bool   _saved    = false;

  // Notification toggles
  bool _notifReservations = true;
  bool _notifRegistrations = true;
  bool _notifEvents = true;
  bool _notifForms  = true;

  // Privacy toggles
  bool _showProfile = true;
  bool _showStats   = true;

  static const _semesters = ['Spring 2026', 'Fall 2026', 'Spring 2027'];

  static const _facultiesList = [
    'IT Faculty','Engineering','Medicine','Pharmacy',
    'Business','physical therapy','special_education','Nursing','dentistry',
    'biotechnology','foreign_language','archaeology',
  ];

  List<String> get _faculties => _facultiesList;

  @override
  void initState() {
    super.initState();
    final user = context.read<AppState>().user;
    _nameCtrl  = TextEditingController(text: user.name);
    _phoneCtrl = TextEditingController(text: user.phone); // IMPROVEMENT #6: load saved phone
    _bioCtrl   = TextEditingController(text: user.bio);   // IMPROVEMENT #6: load saved bio
    _faculty   = user.faculty;
    _semester  = user.semester.isEmpty ? 'Spring 2026' : user.semester;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _bioCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final l = AppLocalizations.of(context)!;
    if (_nameCtrl.text.trim().isEmpty) {
      _showSnack(l.nameCannotBeEmpty, isError: true);
      return;
    }
    final appState = context.read<AppState>();
    final name     = _nameCtrl.text.trim();
    final faculty  = _faculty;
    final semester = _semester;
    setState(() => _saving = true);
    await Future.delayed(const Duration(milliseconds: 700));
    if (!mounted) return;
    appState.updateProfile(
      name:     name,
      faculty:  faculty,
      semester: semester,
    );
    setState(() { _saving = false; _saved = true; });
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) setState(() => _saved = false);
    });
    _showSnack(l.profileUpdated);
  }

  void _showSnack(String msg, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg, style: AppTextStyles.body(15, color: Colors.black)),
      backgroundColor: isError ? context.errorColor : context.secondaryColor,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      duration: const Duration(milliseconds: 2200),
    ));
  }

  void _pickAvatar() {
    // Shows a dialog with avatar color/initial options
    // (File picker requires a native plugin; we use initials customization instead)
    showModalBottomSheet(
      context: context,
      backgroundColor: context.surfaceColor,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => _AvatarPickerSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state  = context.watch<AppState>();
    final l      = AppLocalizations.of(context)!;
    final user   = state.user;
    final txt    = context.textColor;
    final muted  = context.mutedColor;
    final border = context.borderColor;
    final bg     = context.bgColor;
    final surf   = context.surfaceColor;
    final primary = context.primaryColor;
    final second  = context.secondaryColor;
    final isDark  = context.isDark;
    final hPad    = context.hPadding;

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: bg,
        surfaceTintColor: Colors.transparent,
        title: Text(l.settings, style: AppTextStyles.display(20, color: txt, context: context)),
        actions: [
          if (_saved)
            Padding(
              padding: const EdgeInsetsDirectional.only(end: 16),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                Icon(Icons.check_circle, color: second, size: 18),
                const SizedBox(width: 4),
                Text(l.saved, style: AppTextStyles.body(16, color: second,
                    weight: FontWeight.w600, context: context)),
              ]),
            ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Divider(height: 1, color: border),
        ),
      ),
      body: ListView(
        padding: EdgeInsets.fromLTRB(hPad, 20, hPad, 120),
        children: [

          // ── Profile picture ────────────────────────────────────────────
          Center(
            child: Stack(children: [
              GestureDetector(
                onTap: _pickAvatar,
                child: Container(
                  width: 90, height: 90,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [primary, primary.withValues(alpha: 0.6)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    shape: BoxShape.circle,
                    border: Border.all(color: primary.withValues(alpha: 0.4), width: 3),
                    boxShadow: [BoxShadow(
                        color: primary.withValues(alpha: 0.35), blurRadius: 20)],
                  ),
                  child: Center(
                    child: Text(user.initials,
                        style: AppTextStyles.display(30, color: Colors.white, context: context)),
                  ),
                ),
              ),
              PositionedDirectional(
                bottom: 0, end: 0,
                child: GestureDetector(
                  onTap: _pickAvatar,
                  child: Container(
                    width: 28, height: 28,
                    decoration: BoxDecoration(
                      color: second,
                      shape: BoxShape.circle,
                      border: Border.all(color: bg, width: 2),
                    ),
                    child: const Icon(Icons.camera_alt, size: 14, color: Colors.black),
                  ),
                ),
              ),
            ]),
          ),
          const SizedBox(height: 6),
          Center(child: Text(l.tapToChangePhoto,
              style: AppTextStyles.body(15, color: muted, context: context))),
          const SizedBox(height: 24),

          // ── Personal info ──────────────────────────────────────────────
          _SectionTitle(l.personalInfo),
          const SizedBox(height: 14),

          _FieldLabel(l.fullName.toUpperCase()),
          const SizedBox(height: 6),
          _InputField(controller: _nameCtrl, hint: l.fullName),
          const SizedBox(height: 14),

          // Read-only fields
          context.isSmallPhone
              ? Column(children: [
                  Row(children: [
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      _FieldLabel(l.studentId.toUpperCase()),
                      const SizedBox(height: 6),
                      _ReadOnly(user.studentId),
                    ])),
                    const SizedBox(width: 12),
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      _FieldLabel(l.email.toUpperCase()),
                      const SizedBox(height: 6),
                      _ReadOnly(user.email, overflow: true),
                    ])),
                  ]),
                ])
              : Row(children: [
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    _FieldLabel(l.studentId.toUpperCase()),
                    const SizedBox(height: 6),
                    _ReadOnly(user.studentId),
                  ])),
                  const SizedBox(width: 14),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    _FieldLabel(l.email.toUpperCase()),
                    const SizedBox(height: 6),
                    _ReadOnly(user.email, overflow: true),
                  ])),
                ]),
          const SizedBox(height: 14),

          _FieldLabel(l.phoneNumber.toUpperCase()),
          const SizedBox(height: 6),
          _InputField(
            controller: _phoneCtrl,
            hint: 'e.g. 01xxxxxxxxx',
            keyboardType: TextInputType.phone,
          ),
          const SizedBox(height: 14),

          context.isSmallPhone
              ? Column(children: [
                  Row(children: [
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      _FieldLabel(l.faculty.toUpperCase()),
                      const SizedBox(height: 6),
                      _DropdownField(
                        value: _faculty,
                        items: _faculties,
                        onChanged: (v) => setState(() => _faculty = v ?? _faculty),
                      ),
                    ])),
                    const SizedBox(width: 12),
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      _FieldLabel(l.semester.toUpperCase()),
                      const SizedBox(height: 6),
                      _DropdownField(
                        value: _semester,
                        items: _semesters,
                        onChanged: (v) => setState(() => _semester = v ?? _semester),
                      ),
                    ])),
                  ]),
                ])
              : Row(children: [
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    _FieldLabel(l.faculty.toUpperCase()),
                    const SizedBox(height: 6),
                    _DropdownField(
                      value: _faculty,
                      items: kFaculties,
                      onChanged: (v) => setState(() => _faculty = v ?? _faculty),
                    ),
                  ])),
                  const SizedBox(width: 14),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    _FieldLabel(l.semester.toUpperCase()),
                    const SizedBox(height: 6),
                    _DropdownField(
                      value: _semester,
                      items: _semesters,
                      onChanged: (v) => setState(() => _semester = v ?? _semester),
                    ),
                  ])),
                ]),
          const SizedBox(height: 14),

          _FieldLabel(l.bioOptional.toUpperCase()),
          const SizedBox(height: 6),
          TextField(
            controller: _bioCtrl,
            maxLines: 3,
            style: AppTextStyles.body(16, color: txt),
            decoration: _inputDec(context, hint: l.bioHint),
          ),
          const SizedBox(height: 28),

          // ── Academic (read-only) ───────────────────────────────────────
          _SectionTitle(l.academicInfo),
          const SizedBox(height: 14),
          Container(
            decoration: BoxDecoration(
              color: surf,
              border: Border.all(color: border),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(children: [
              _InfoRow('🎓  ${l.cgpa.toUpperCase()}', '${user.cgpa}'),
              Divider(height: 1, color: border),
              _InfoRow('📚  ${l.creditHours}', user.creditHours),
              Divider(height: 1, color: border),
              _InfoRow('🏅  ${l.points}', '${user.points}'),
              Divider(height: 1, color: border),
              _InfoRow('🏆  ${l.rank}', '#${user.rank}'),
            ]),
          ),
          const SizedBox(height: 28),

          // ── Notification preferences ───────────────────────────────────
          _SectionTitle(l.notificationPrefs),
          const SizedBox(height: 14),
          Container(
            decoration: BoxDecoration(
              color: surf, border: Border.all(color: border),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(children: [
              _Toggle(
                emoji: '📅', label: l.reservationReminders,
                sub: l.reservationRemindersDesc,
                value: _notifReservations,
                color: primary,
                onChanged: (v) => setState(() => _notifReservations = v),
              ),
              Divider(height: 1, color: border),
              _Toggle(
                emoji: '✅', label: l.registrationUpdates,
                sub: l.registrationUpdatesDesc,
                value: _notifRegistrations,
                color: second,
                onChanged: (v) => setState(() => _notifRegistrations = v),
              ),
              Divider(height: 1, color: border),
              _Toggle(
                emoji: '🏆', label: l.upcomingEvents,
                sub: l.upcomingEventsDesc,
                value: _notifEvents,
                color: context.accentColor,
                onChanged: (v) => setState(() => _notifEvents = v),
              ),
              Divider(height: 1, color: border),
              _Toggle(
                emoji: '📋', label: l.requiredForms,
                sub: l.requiredFormsDesc,
                value: _notifForms,
                color: const Color(0xFF7C4DFF),
                onChanged: (v) => setState(() => _notifForms = v),
              ),
            ]),
          ),
          const SizedBox(height: 28),

          // ── Privacy ────────────────────────────────────────────────────
          _SectionTitle(l.privacy),
          const SizedBox(height: 14),
          Container(
            decoration: BoxDecoration(
              color: surf, border: Border.all(color: border),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(children: [
              _Toggle(
                emoji: '👁️', label: l.showMyProfile,
                sub: l.showMyProfileDesc,
                value: _showProfile, color: primary,
                onChanged: (v) => setState(() => _showProfile = v),
              ),
              Divider(height: 1, color: border),
              _Toggle(
                emoji: '📊', label: l.showMyStats,
                sub: l.showMyStatsDesc,
                value: _showStats, color: second,
                onChanged: (v) => setState(() => _showStats = v),
              ),
            ]),
          ),
          const SizedBox(height: 28),

          // ── Language ───────────────────────────────────────────────
          _SectionTitle('${l.language} / اللغة'),
          const SizedBox(height: 14),
          Container(
            decoration: BoxDecoration(
              color: surf, border: Border.all(color: border),
              borderRadius: BorderRadius.circular(14),
            ),
            child: _LanguageSwitcher(),
          ),
          const SizedBox(height: 28),

          // ── Appearance ─────────────────────────────────────────────────
          _SectionTitle(l.appearance),
          const SizedBox(height: 14),
          Container(
            decoration: BoxDecoration(
              color: surf, border: Border.all(color: border),
              borderRadius: BorderRadius.circular(14),
            ),
            child: ListTile(
              leading: Icon(isDark ? Icons.dark_mode_rounded : Icons.light_mode_rounded, size: 20),
              title: Text(isDark ? l.darkMode : l.lightMode,
                  style: AppTextStyles.body(16, color: txt, weight: FontWeight.w500, context: context)),
              subtitle: Text(l.tapToSwitch,
                  style: AppTextStyles.body(15, color: muted, context: context)),
              trailing: Switch(
                value: isDark,
                onChanged: (_) => context.read<ThemeProvider>().toggleTheme(),
                activeThumbColor: primary,
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            ),
          ),
          const SizedBox(height: 32),

          // ── About ────────────────────────────────────────────────────────
          GestureDetector(
            onTap: () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => const AboutScreen())),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: surf,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: border),
              ),
              child: Row(children: [
                Container(
                  width: 36, height: 36,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: [primary, second]),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Center(child: Icon(Icons.stadium_rounded, color: Colors.white, size: 18)),
                ),
                const SizedBox(width: 12),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(
                    Localizations.localeOf(context).languageCode == 'ar'
                        ? 'حول MUSTER'
                        : 'About MUSTER',
                    style: AppTextStyles.body(15, color: txt, weight: FontWeight.w600, context: context),
                  ),
                  Text(
                    Localizations.localeOf(context).languageCode == 'ar'
                        ? 'الفريق، الإصدار والمساهمون'
                        : 'Team, version & credits',
                    style: AppTextStyles.body(12, color: muted, context: context),
                  ),
                ])),
                Icon(
                  Localizations.localeOf(context).languageCode == 'ar'
                      ? Icons.chevron_left
                      : Icons.chevron_right,
                  color: muted,
                  size: 20,
                ),
              ]),
            ),
          ),
          const SizedBox(height: 20),

          // ── Save button ────────────────────────────────────────────────
          SizedBox(
            height: 54,
            child: ElevatedButton(
              onPressed: _saving ? null : _save,
              style: ElevatedButton.styleFrom(
                backgroundColor: second,
                foregroundColor: Colors.black,
                elevation: 0,
                disabledBackgroundColor: second.withValues(alpha: 0.5),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: _saving
                  ? SizedBox(width: 22, height: 22,
                      child: CircularProgressIndicator(strokeWidth: 2.5,
                          color: Colors.black.withValues(alpha: 0.6)))
                  : Text(l.saveChanges,
                      style: AppTextStyles.body(16, color: Colors.black,
                          weight: FontWeight.w700, context: context)),
            ),
          ),
        ],
      ),
    );
  }

  InputDecoration _inputDec(BuildContext context, {required String hint}) =>
      InputDecoration(
        hintText: hint,
        hintStyle: AppTextStyles.body(16, color: context.mutedColor),
        filled: true, fillColor: context.surfaceColor,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: context.borderColor)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: context.primaryColor, width: 1.5)),
      );
}

// ─── AVATAR PICKER SHEET ─────────────────────────────────────────────────────
class _AvatarPickerSheet extends StatelessWidget {
  static const _colors = [
    Color(0xFF00E5FF), Color(0xFFA8FF3E), Color(0xFFFFB800),
    Color(0xFFFF4757), Color(0xFF7C4DFF), Color(0xFFFF6B35),
    Color(0xFF00BCD4), Color(0xFF4CAF50),
  ];

  @override
  Widget build(BuildContext context) {
    final l      = AppLocalizations.of(context)!;
    final txt    = context.textColor;
    final muted  = context.mutedColor;
    final border = context.borderColor;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 40),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Container(width: 40, height: 4,
            decoration: BoxDecoration(color: border,
                borderRadius: BorderRadius.circular(2)),
            margin: const EdgeInsets.only(bottom: 20)),
        Text(l.chooseAvatarColor,
            style: AppTextStyles.heading(18, color: txt)),
        const SizedBox(height: 6),
        Text(l.uploadComingSoon,
            style: AppTextStyles.body(16, color: muted)),
        const SizedBox(height: 20),
        Wrap(spacing: 16, runSpacing: 16, children: _colors.map((c) =>
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 52, height: 52,
              decoration: BoxDecoration(
                color: c, shape: BoxShape.circle,
                boxShadow: [BoxShadow(color: c.withValues(alpha: 0.5), blurRadius: 12)],
              ),
            ),
          ),
        ).toList()),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.photo_library_outlined),
            label: Text(l.uploadFromGallery),
            style: OutlinedButton.styleFrom(
              foregroundColor: muted,
              side: BorderSide(color: border),
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ),
      ]),
    );
  }
}

// ─── HELPERS ─────────────────────────────────────────────────────────────────
class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);
  @override
  Widget build(BuildContext context) => Text(text,
      style: AppTextStyles.heading(15, color: context.textColor, context: context));
}

class _FieldLabel extends StatelessWidget {
  final String text;
  const _FieldLabel(this.text);
  @override
  Widget build(BuildContext context) => Text(text,
      style: AppTextStyles.label(color: context.mutedColor, context: context));
}

class _ReadOnly extends StatelessWidget {
  final String value;
  final bool overflow;
  const _ReadOnly(this.value, {this.overflow = false});
  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
    decoration: BoxDecoration(
      color: context.surfaceColor.withValues(alpha: 0.5),
      border: Border.all(color: context.borderColor),
      borderRadius: BorderRadius.circular(12),
    ),
    child: Text(value,
        style: AppTextStyles.body(context.isSmallPhone ? 13 : 15, color: context.mutedColor, context: context),
        maxLines: 1,
        overflow: TextOverflow.ellipsis),
  );
}

class _InputField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final TextInputType? keyboardType;
  const _InputField({required this.controller, required this.hint,
      this.keyboardType});
  @override
  Widget build(BuildContext context) => TextField(
    controller: controller,
    keyboardType: keyboardType,
    style: AppTextStyles.body(context.isSmallPhone ? 15 : 16, color: context.textColor, context: context),
    decoration: InputDecoration(
      hintText: hint,
      hintStyle: AppTextStyles.body(16, color: context.mutedColor, context: context),
      filled: true, fillColor: context.surfaceColor,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: context.borderColor)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: context.primaryColor, width: 1.5)),
    ),
  );
}

class _DropdownField extends StatelessWidget {
  final String value;
  final List<String> items;
  final void Function(String?) onChanged;
  const _DropdownField({required this.value, required this.items,
      required this.onChanged});
  @override
  Widget build(BuildContext context) => DropdownButtonFormField<String>(
    initialValue: value,
    isExpanded: true,
    style: AppTextStyles.body(context.isSmallPhone ? 13 : 15, color: context.textColor, context: context),
    dropdownColor: context.surfaceColor,
    decoration: InputDecoration(
      filled: true, fillColor: context.surfaceColor,
      contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: context.borderColor)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: context.primaryColor, width: 1.5)),
    ),
    items: items.map((i) => DropdownMenuItem(value: i,
        child: Text(i, 
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: AppTextStyles.body(context.isSmallPhone ? 12 : 13, color: context.textColor, context: context)))).toList(),
    onChanged: onChanged,
  );
}

class _InfoRow extends StatelessWidget {
  final String label, value;
  const _InfoRow(this.label, this.value);
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 5,
          child: Text(
            label,
            style: AppTextStyles.body(15, color: context.mutedColor, context: context),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          flex: 4,
          child: Text(
            value,
            style: AppTextStyles.body(15, color: context.textColor,
                weight: FontWeight.w600, context: context),
            textAlign: Localizations.localeOf(context).languageCode == 'ar'
                ? TextAlign.left
                : TextAlign.right,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    ),
  );
}

// ─── LANGUAGE SWITCHER ────────────────────────────────────────────────────────
class _LanguageSwitcher extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final l             = AppLocalizations.of(context)!;
    final isArabic      = themeProvider.isArabic;
    final txt           = context.textColor;
    final border        = context.borderColor;

    return Column(children: [
      _LangOption(
        flag: '🇬🇧',
        label: l.english,
        selected: !isArabic,
        onTap: () => themeProvider.toggleLanguage(),
        showDivider: true,
        border: border,
        txt: txt,
      ),
      _LangOption(
        flag: '🇸🇦',
        label: l.arabic,
        selected: isArabic,
        onTap: () => themeProvider.toggleLanguage(),
        showDivider: false,
        border: border,
        txt: txt,
      ),
    ]);
  }
}

class _LangOption extends StatelessWidget {
  final String flag, label;
  final bool selected, showDivider;
  final VoidCallback onTap;
  final Color border, txt;

  const _LangOption({
    required this.flag, required this.label, required this.selected,
    required this.onTap, required this.showDivider,
    required this.border, required this.txt,
  });

  @override
  Widget build(BuildContext context) {
    final primary = context.primaryColor;
    return Column(
      children: [
        ListTile(
          leading: Text(flag, style: const TextStyle(fontSize: 22)),
          title: Text(label,
              style: AppTextStyles.body(16, color: txt, weight: FontWeight.w500, context: context)),
          trailing: selected
              ? Icon(Icons.check_circle, color: primary, size: 22)
              : Icon(Icons.radio_button_unchecked,
                  color: context.mutedColor, size: 22),
          onTap: onTap,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        ),
        if (showDivider) Divider(height: 1, color: border),
      ],
    );
  }
}

class _Toggle extends StatelessWidget {
  final String emoji, label, sub;
  final bool value;
  final Color color;
  final void Function(bool) onChanged;
  const _Toggle({required this.emoji, required this.label, required this.sub,
      required this.value, required this.color, required this.onChanged});
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    child: Row(children: [
      Text(emoji, style: const TextStyle(fontSize: 18)),
      const SizedBox(width: 12),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label, style: AppTextStyles.body(15, color: context.textColor,
            weight: FontWeight.w600, context: context)),
        Text(sub, style: AppTextStyles.body(15, color: context.mutedColor, context: context)),
      ])),
      Switch(
        value: value, onChanged: onChanged,
        activeThumbColor: color,
        trackOutlineColor: WidgetStateProperty.all(context.borderColor),
      ),
    ]),
  );
}
