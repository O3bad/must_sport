import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/widgets.dart';
import '../../../core/state/app_state.dart';
import '../../../core/state/activity_state.dart';
import '../../../core/models/activity_models.dart';

import '../../../l10n/app_localizations.dart';

class RegistrationFormScreen extends StatefulWidget {
  final ActivityModel activity;
  const RegistrationFormScreen({super.key, required this.activity});
  @override
  State<RegistrationFormScreen> createState() => _RegistrationFormScreenState();
}

class _RegistrationFormScreenState extends State<RegistrationFormScreen> {
  final _formKey   = GlobalKey<FormState>();
  final _phoneCtrl = TextEditingController();
  final _msgCtrl   = TextEditingController();
  String  _faculty   = '';
  String  _semester  = 'Spring 2026';
  String  _level     = 'Beginner';
  bool    _medical   = false;
  bool    _terms     = false;
  bool    _loading   = false;
  bool    _submitted = false;
  String? _error;  // FIX #1: declare _error field (was undefined at line 90)

  // ── Team member controllers (team sports only) ──
  final List<Map<String, TextEditingController>> _teamMembers = [];

  bool get _isTeamSport =>
      widget.activity.category == ActivityCategory.teamSports;

  static const _semesters = ['Spring 2026', 'Fall 2026', 'Spring 2027'];

  @override
  void initState() {
    super.initState();
    _faculty = context.read<AppState>().user.faculty;
    if (_isTeamSport) _addTeamMember();
  }

  void _addTeamMember() {
    _teamMembers.add({
      'name':    TextEditingController(),
      'id':      TextEditingController(),
      'faculty': TextEditingController(),
    });
    setState(() {});
  }

  void _removeTeamMember(int index) {
    final m = _teamMembers.removeAt(index);
    for (var c in m.values) {
      c.dispose();
    }
    setState(() {});
  }

  @override
  void dispose() {
    _phoneCtrl.dispose();
    _msgCtrl.dispose();
    for (final m in _teamMembers) {
      for (var c in m.values) {
        c.dispose();
      }
    }
    super.dispose();
  }

  Future<void> _submit() async {
    final l = AppLocalizations.of(context)!;
    if (!_formKey.currentState!.validate()) return;
    if (!_terms) {
      _showError(l.errorPleaseAgreeTerms);
      return;
    }
    setState(() { _loading = true; _error = null; });

    // FIX #2 & #3: capture context-dependent objects before the async gap
    final appState  = context.read<AppState>();
    final regState  = context.read<ActivityRegistrationState>();
    final user      = appState.user;

    await Future.delayed(const Duration(milliseconds: 800));

    // IMPROVEMENT #13: capacity check before submitting
    if (!regState.hasCapacity(widget.activity.id)) {
      setState(() {
        _loading = false;
        _error = l.errorActivityFull;
      });
      return;
    }

    final reg = ActivityRegistration(
      id:           regState.generateId(),
      studentEmail: user.email,
      studentName:  user.name,
      studentId:    user.studentId,
      faculty:      _faculty.isEmpty ? user.faculty : _faculty,
      phone:        _phoneCtrl.text.trim(),
      semester:     _semester,
      level:        _level,
      message:      _msgCtrl.text.trim(),
      activity:     widget.activity,
      createdAt:    DateTime.now(),
    );
    regState.addRegistration(reg);
    setState(() { _loading = false; _submitted = true; });
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg, style: AppTextStyles.body(15, color: Colors.white)),
      backgroundColor: context.errorColor,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final primary = context.primaryColor;
    final second  = context.secondaryColor;
    final txt     = context.textColor;
    final muted   = context.mutedColor;
    final border  = context.borderColor;
    final surf    = context.surfaceColor;
    final bg      = context.bgColor;
    final user    = context.read<AppState>().user;

    final experiences = [
      l.experienceBeginner,
      l.experienceIntermediate,
      l.experienceAdvanced,
      l.experienceProfessional
    ];

    if (_submitted) return _SuccessScreen(activity: widget.activity);

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: bg,
        surfaceTintColor: Colors.transparent,
        title: Text(l.registerTitle(widget.activity.name),
            style: AppTextStyles.heading(18, color: txt, context: context)),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Divider(height: 1, color: border),
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
          children: [
            // ── Activity banner ──────────────────────────────────────────
            Container(
              decoration: BoxDecoration(
                color: primary.withValues(alpha: 0.08),
                border: Border.all(color: primary.withValues(alpha: 0.3)),
                borderRadius: BorderRadius.circular(14),
              ),
              padding: const EdgeInsets.all(14),
              child: Row(children: [
                Text(widget.activity.emoji, style: const TextStyle(fontSize: 38)),
                const SizedBox(width: 12),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(widget.activity.name,
                      maxLines: 1, overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.heading(15, color: txt, context: context)),
                  const SizedBox(height: 2),
                  Text(widget.activity.schedule,
                      maxLines: 1, overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.body(16, color: muted, context: context)),
                  Text(l.coachPrefix(widget.activity.coach),
                      maxLines: 1, overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.body(16, color: muted, context: context)),
                ])),
              ]),
            ),
            const SizedBox(height: 24),

            // ── Capacity / general error banner ──────────────────────────
            if (_error != null) ...[
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: context.errorColor.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: context.errorColor.withValues(alpha: 0.35)),
                ),
                child: Row(children: [
                  Icon(Icons.error_outline, color: context.errorColor, size: 20),
                  const SizedBox(width: 10),
                  Expanded(child: Text(_error!,
                      maxLines: 5,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.body(13, color: context.errorColor, context: context))),
                ]),
              ),
              const SizedBox(height: 16),
            ],

            _SectionLabel(l.personalInfoSection),
            const SizedBox(height: 12),

            // ── Read-only fields ─────────────────────────────────────────
            Row(children: [
              Expanded(child: _ReadOnlyField(label: l.fullNameLabel, value: user.name)),
              const SizedBox(width: 12),
              Expanded(child: _ReadOnlyField(label: l.studentId, value: user.studentId)),
            ]),
            const SizedBox(height: 12),
            _ReadOnlyField(label: l.email, value: user.email),
            const SizedBox(height: 12),

            // ── Phone ────────────────────────────────────────────────────
            _FieldLabel(l.fieldLabelPhone),
            const SizedBox(height: 6),
            TextFormField(
              controller: _phoneCtrl,
              keyboardType: TextInputType.phone,
              style: AppTextStyles.body(16, color: txt, context: context),
              decoration: _inputDec(context, hint: l.phoneHint),
              validator: (v) {
                if (v == null || v.trim().isEmpty) return l.fieldLabelPhone;
                if (!RegExp(r'^01[0125][0-9]{8}$').hasMatch(v.trim())) {
                  return l.errorVodafoneNumber; // Using an existing valid phone error key
                }
                return null;
              },
            ),
            const SizedBox(height: 12),

            // ── Faculty + Semester ───────────────────────────────────────
            Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                _FieldLabel(l.fieldLabelFaculty),
                const SizedBox(height: 6),
                _DropdownField(
                  value: _faculty.isEmpty ? null : _faculty,
                  hint: l.selectFaculty,
                  items: kFaculties,
                  onChanged: (v) => setState(() => _faculty = v ?? ''),
                ),
                if (_faculty.isEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(l.errorSelectFaculty, 
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.body(15, color: context.errorColor, context: context)),
                  ),
              ])),
              const SizedBox(width: 12),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                _FieldLabel(l.fieldLabelSemester),
                const SizedBox(height: 6),
                _DropdownField(value: _semester, hint: l.semesterHint, items: _semesters,
                    onChanged: (v) => setState(() => _semester = v ?? _semester)),
              ])),
            ]),
            const SizedBox(height: 12),

            // ── Level ────────────────────────────────────────────────────
            _FieldLabel(l.fieldLabelLevel),
            const SizedBox(height: 10),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: experiences.map((exp) {
                final isSelected = _level == exp;
                return InkWell(
                  onTap: () => setState(() => _level = exp),
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: isSelected ? context.secondaryColor : context.surfaceColor,
                      border: Border.all(color: isSelected ? context.secondaryColor : context.borderColor),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        exp,
                        style: AppTextStyles.body(15,
                            color: isSelected ? context.bgColor : context.mutedColor,
                            weight: isSelected ? FontWeight.w700 : FontWeight.w500,
                            context: context),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),

            // ── Team Members (team sports only) ──────────────────────────
            if (_isTeamSport) ...[
              _SectionLabel(l.teamMembersSection),
              const SizedBox(height: 6),
              Text(
                l.teamMembersDesc,
                style: AppTextStyles.body(16, color: muted, context: context),
              ),
              const SizedBox(height: 12),
              ..._teamMembers.asMap().entries.map((entry) {
                final i = entry.key;
                final m = entry.value;
                return Container(
                  margin: const EdgeInsets.only(bottom: 14),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: primary.withValues(alpha: 0.04),
                    border: Border.all(color: primary.withValues(alpha: 0.25)),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Row(children: [
                      Text(l.memberNum(i + 1),
                          style: AppTextStyles.body(15, color: primary, weight: FontWeight.w700, context: context)),
                      const Spacer(),
                      GestureDetector(
                        onTap: () => _removeTeamMember(i),
                        child: Container(
                          width: 26, height: 26,
                          decoration: BoxDecoration(
                            color: context.errorColor.withValues(alpha: 0.10),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(Icons.close, size: 14, color: context.errorColor),
                        ),
                      ),
                    ]),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: m['name'],
                      style: AppTextStyles.body(16, color: txt, context: context),
                      decoration: _inputDec(context, hint: l.fullNameLabel),
                      validator: (v) => (v == null || v.trim().isEmpty) ? l.errorNameShort : null,
                    ),
                    const SizedBox(height: 8),
                    Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Expanded(
                        child: TextFormField(
                          controller: m['id'],
                          style: AppTextStyles.body(16, color: txt, context: context),
                          decoration: _inputDec(context, hint: l.studentId),
                          validator: (v) => (v == null || v.trim().isEmpty) ? l.studentId : null,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: TextFormField(
                          controller: m['faculty'],
                          style: AppTextStyles.body(16, color: txt, context: context),
                          decoration: _inputDec(context, hint: l.facultyLabel),
                          validator: (v) => (v == null || v.trim().isEmpty) ? l.errorSelectFaculty : null,
                        ),
                      ),
                    ]),
                  ]),
                );
              }),
              TextButton.icon(
                onPressed: _addTeamMember,
                icon: Icon(Icons.add_circle_outline, color: primary, size: 18),
                label: Text(l.addAnotherMember,
                    style: AppTextStyles.body(15, color: primary, weight: FontWeight.w600, context: context)),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 4),
                ),
              ),
              const SizedBox(height: 8),
            ],

            _SectionLabel(l.motivationSection),
            const SizedBox(height: 12),
            _FieldLabel(l.fieldLabelStatement),
            const SizedBox(height: 6),
            TextFormField(
              controller: _msgCtrl,
              maxLines: 4,
              style: AppTextStyles.body(16, color: txt, context: context),
              decoration: _inputDec(context,
                  hint: l.statementHint),
            ),
            const SizedBox(height: 20),

            _SectionLabel(l.agreementsSection),
            const SizedBox(height: 12),

            _CheckboxRow(
              value: _medical,
              onChanged: (v) => setState(() => _medical = v!),
              label: l.agreementMedical,
              color: primary,
            ),
            const SizedBox(height: 10),
            _CheckboxRow(
              value: _terms,
              onChanged: (v) => setState(() => _terms = v!),
              label: l.agreementTerms,
              color: second,
            ),
            const SizedBox(height: 28),

            MorphButton(
              label: l.submitApplication,
              loading: _loading,
              success: _submitted,
              onPressed: _submit,
              backgroundColor: second,
              foregroundColor: bg,
            ),
          ],
        ),
      ),
    );
  }

  InputDecoration _inputDec(BuildContext context, {required String? hint}) => InputDecoration(
    hintText: hint,
    hintStyle: AppTextStyles.body(16, color: context.mutedColor, context: context),
    filled: true,
    fillColor: context.surfaceColor,
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: context.borderColor)),
    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: context.primaryColor, width: 1.5)),
    errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: context.errorColor)),
    focusedErrorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: context.errorColor, width: 1.5)),
    errorStyle: AppTextStyles.body(15, color: context.errorColor, context: context),
  );
}

// ─── SUCCESS SCREEN ───────────────────────────────────────────────────────────
class _SuccessScreen extends StatelessWidget {
  final ActivityModel activity;
  const _SuccessScreen({required this.activity});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final second = context.secondaryColor;
    // final txt    = context.textColor;
    final muted  = context.mutedColor;

    return Scaffold(
      backgroundColor: context.bgColor,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              const Icon(Icons.celebration_rounded, size: 72, color: Color(0xFFA8FF3E)),
              const SizedBox(height: 20),
              Text(l.applicationSubmitted,
                  style: AppTextStyles.display(28, color: second, context: context), textAlign: TextAlign.center),
              const SizedBox(height: 12),
              RichText(
                textAlign: TextAlign.center,
                text: TextSpan(children: [
                  TextSpan(text: l.appSubmittedDesc('${activity.emoji} ${activity.name}'),
                      style: AppTextStyles.body(15, color: muted, context: context)),
                ]),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).popUntil((route) => route.isFirst),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: second,
                    foregroundColor: context.bgColor,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  child: Text(l.backToActivities,
                      style: AppTextStyles.body(15, color: context.bgColor, weight: FontWeight.w700, context: context)),
                ),
              ),
            ]),
          ),
        ),
      ),
    );
  }
}

// ─── HELPERS ─────────────────────────────────────────────────────────────────
class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);
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

class _ReadOnlyField extends StatelessWidget {
  final String label, value;
  const _ReadOnlyField({required this.label, required this.value});
  @override
  Widget build(BuildContext context) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    _FieldLabel(label),
    const SizedBox(height: 6),
    Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: context.surfaceColor.withValues(alpha: 0.5),
        border: Border.all(color: context.borderColor),
        borderRadius: BorderRadius.circular(12),
      ),
      child: FittedBox(
        alignment: Alignment.centerLeft,
        fit: BoxFit.scaleDown,
        child: Text(value, 
            maxLines: 1,
            style: AppTextStyles.body(16, color: context.mutedColor, context: context)),
      ),
    ),
  ]);
}

class _DropdownField extends StatelessWidget {
  final String? value;
  final String hint;
  final List<String> items;
  final void Function(String?) onChanged;
  const _DropdownField({required this.value, required this.hint, required this.items, required this.onChanged});

  @override
  Widget build(BuildContext context) => DropdownButtonFormField<String>(
    initialValue: value,
    isExpanded: true,
    hint: Text(hint, 
        maxLines: 1, 
        overflow: TextOverflow.ellipsis,
        style: AppTextStyles.body(16, color: context.mutedColor, context: context)),
    style: AppTextStyles.body(16, color: context.textColor, context: context),
    dropdownColor: context.surfaceColor,
    decoration: InputDecoration(
      filled: true,
      fillColor: context.surfaceColor,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: context.borderColor)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: context.primaryColor, width: 1.5)),
    ),
    items: items.map((i) => DropdownMenuItem(value: i,
        child: Text(i, 
            maxLines: 1, 
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.body(16, color: context.textColor, context: context)))).toList(),
    onChanged: onChanged,
  );
}

class _CheckboxRow extends StatelessWidget {
  final bool value;
  final void Function(bool?) onChanged;
  final String label;
  final Color color;
  const _CheckboxRow({required this.value, required this.onChanged, required this.label, required this.color});

  @override
  Widget build(BuildContext context) => Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Checkbox(value: value, onChanged: onChanged,
        activeColor: color,
        side: BorderSide(color: context.borderColor),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4))),
    Expanded(child: Padding(
      padding: const EdgeInsets.only(top: 11),
      child: Text(label, style: AppTextStyles.body(15, color: context.mutedColor, context: context)),
    )),
  ]);
}
