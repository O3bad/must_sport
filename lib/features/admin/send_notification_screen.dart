// lib/features/admin/send_notification_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../l10n/app_localizations.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_theme.dart';
import 'bloc/admin_bloc.dart';

class SendNotificationScreen extends StatefulWidget {
  const SendNotificationScreen({super.key});
  @override
  State<SendNotificationScreen> createState() => _SendNotificationScreenState();
}

class _SendNotificationScreenState extends State<SendNotificationScreen> {
  final _titleCtrl   = TextEditingController();
  final _titleArCtrl = TextEditingController();
  final _bodyCtrl    = TextEditingController();
  final _bodyArCtrl  = TextEditingController();
  String? _targetRole;
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _titleCtrl.dispose(); _titleArCtrl.dispose();
    _bodyCtrl.dispose();  _bodyArCtrl.dispose();
    super.dispose();
  }

  void _send() {
    if (!_formKey.currentState!.validate()) return;
    final l10n = AppLocalizations.of(context)!;
    context.read<AdminBloc>().add(AdminNotificationSent(
      title:     _titleCtrl.text.trim(),
      titleAr:   _titleArCtrl.text.trim(),
      body:      _bodyCtrl.text.trim(),
      bodyAr:    _bodyArCtrl.text.trim(),
      targetRole: _targetRole,
      l10n:      l10n,
    ));
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final l10n    = AppLocalizations.of(context)!;
    final primary = AppColors.primary(context);
    final bg      = AppColors.bg(context);
    final txt     = AppColors.text(context);
    final muted   = AppColors.muted(context);
    final isAr    = l10n.localeName == 'ar';

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: bg, surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: Icon(
            isAr ? Icons.arrow_forward_ios_rounded : Icons.arrow_back_ios_rounded,
            color: txt, size: 20),
          onPressed: () => Navigator.pop(context)),
        title: Text(l10n.sendNotification, style: AppTextStyles.heading(18, color: txt, context: context)),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
          children: [
            _field(_titleCtrl,   l10n.notificationTitleEn,   Icons.title_rounded,   required: true),
            const SizedBox(height: 12),
            _field(_titleArCtrl, l10n.notificationTitleAr,   Icons.title_rounded, textDirection: TextDirection.rtl),
            const SizedBox(height: 12),
            _field(_bodyCtrl,    l10n.notificationMessageEn, Icons.message_rounded,  required: true, maxLines: 3),
            const SizedBox(height: 12),
            _field(_bodyArCtrl,  l10n.notificationMessageAr, Icons.message_rounded,  maxLines: 3, textDirection: TextDirection.rtl),
            const SizedBox(height: 20),

            Text(l10n.targetAudience.toUpperCase(), style: AppTextStyles.label(color: muted, size: 12, context: context)),
            const SizedBox(height: 10),
            _RoleChips(
              selected: _targetRole,
              onChanged: (r) => setState(() => _targetRole = r),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
          child: GestureDetector(
            onTap: _send,
            child: Container(
              height: 54,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [primary, const Color(0xFF0097A7)],
                  begin: Alignment.centerLeft, end: Alignment.centerRight),
                borderRadius: BorderRadius.circular(14),
                boxShadow: [BoxShadow(color: primary.withValues(alpha: 0.3), blurRadius: 16)],
              ),
              child: Center(child: Text(l10n.sendNotification,
                style: AppTextStyles.body(16, color: DarkColors.bg, weight: FontWeight.w700, context: context))),
            ),
          ),
        ),
      ),
    );
  }

  Widget _field(TextEditingController ctrl, String label, IconData icon,
      {bool required = false, int maxLines = 1, TextDirection? textDirection}) {
    final l10n = AppLocalizations.of(context)!;
    return TextFormField(
      controller: ctrl,
      maxLines: maxLines,
      textDirection: textDirection,
      style: AppTextStyles.body(14, color: AppColors.text(context), context: context),
      decoration: InputDecoration(labelText: label, prefixIcon: Icon(icon, size: 20)),
      validator: required ? (v) => (v == null || v.trim().isEmpty) ? l10n.requiredField : null : null,
    );
  }
}

class _RoleChips extends StatelessWidget {
  final String? selected;
  final ValueChanged<String?> onChanged;
  const _RoleChips({required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final l10n    = AppLocalizations.of(context)!;
    final primary = AppColors.primary(context);
    final second  = AppColors.secondary(context);
    final accent  = AppColors.accent(context);
    final muted   = AppColors.muted(context);

    final options = [
      (null,             l10n.everyone,  '📢', muted),
      (UserRoles.student,l10n.students,  '🎓', primary),
      (UserRoles.coach,  l10n.coaches,   '🏋️', second),
      (UserRoles.admin,  l10n.admins,    '⚙️', accent),
    ];

    return Wrap(spacing: 8, runSpacing: 8, children: options.map((o) {
      final isActive = selected == o.$1;
      return GestureDetector(
        onTap: () => onChanged(o.$1),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
          decoration: BoxDecoration(
            color: isActive ? (o.$4).withValues(alpha: 0.12) : AppColors.surface(context),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isActive ? (o.$4).withValues(alpha: 0.5) : AppColors.border(context)),
          ),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            Text(o.$3, style: const TextStyle(fontSize: 16)),
            const SizedBox(width: 6),
            Text(o.$2, style: AppTextStyles.body(13,
              color: isActive ? o.$4 : AppColors.muted(context),
              weight: FontWeight.w600, context: context)),
          ]),
        ),
      );
    }).toList());
  }
}

