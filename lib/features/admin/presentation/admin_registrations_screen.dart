import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/widgets.dart';
import '../../../core/state/app_state.dart';
import '../../../core/state/activity_state.dart';
import '../../../core/models/activity_models.dart';

class AdminRegistrationsScreen extends StatefulWidget {
  const AdminRegistrationsScreen({super.key});
  @override
  State<AdminRegistrationsScreen> createState() => _AdminRegistrationsScreenState();
}

class _AdminRegistrationsScreenState extends State<AdminRegistrationsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tab;

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() { _tab.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final txt      = context.textColor;
    final muted    = context.mutedColor;
    final border   = context.borderColor;
    final bg       = context.bgColor;
    final primary  = context.primaryColor;
    final isAr     = Localizations.localeOf(context).languageCode == 'ar';
    final regState = context.watch<ActivityRegistrationState>();
    final all      = regState.all;
    final pending  = regState.pending;
    final approved = all.where((r) => r.status == RegistrationStatus.approved).toList();
    final rejected = all.where((r) => r.status == RegistrationStatus.rejected).toList();

    final tabs = [
      (isAr ? 'الكل (${all.length})' : 'All (${all.length})',           all),
      (isAr ? 'قيد الانتظار (${pending.length})' : 'Pending (${pending.length})',    pending),
      (isAr ? 'مقبول (${approved.length})' : 'Approved (${approved.length})',  approved),
      (isAr ? 'مرفوض (${rejected.length})' : 'Rejected (${rejected.length})',  rejected),
    ];

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: bg,
        surfaceTintColor: Colors.transparent,
        title: Text(isAr ? 'التسجيلات' : 'Registrations', style: AppTextStyles.display(22, color: txt, context: context)),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: txt, size: 20),
          onPressed: () => context.read<AppState>().setNavIndex(0),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(49),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Divider(height: 1, color: border),
            TabBar(
              controller: _tab,
              isScrollable: true,
              labelColor: primary,
              unselectedLabelColor: muted,
              indicatorColor: primary,
              indicatorSize: TabBarIndicatorSize.label,
              labelStyle: AppTextStyles.body(15, weight: FontWeight.w700, context: context),
              unselectedLabelStyle: AppTextStyles.body(13, context: context),
              tabAlignment: TabAlignment.start,
              tabs: tabs.map((t) => Tab(text: t.$1)).toList(),
            ),
          ]),
        ),
      ),
      body: TabBarView(
        controller: _tab,
        children: tabs.map((t) => _AdminRegList(registrations: t.$2)).toList(),
      ),
    );
  }
}

// ─── ADMIN REGISTRATION LIST ──────────────────────────────────────────────────
class _AdminRegList extends StatelessWidget {
  final List<ActivityRegistration> registrations;
  const _AdminRegList({required this.registrations});

  @override
  Widget build(BuildContext context) {
    final muted = context.mutedColor;
    final isAr = Localizations.localeOf(context).languageCode == 'ar';
    if (registrations.isEmpty) {
      return Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
        const Icon(Icons.inbox_rounded, size: 52, color: Color(0xFF5A7090)),
        const SizedBox(height: 12),
        Text(isAr ? 'لا توجد تسجيلات في هذه الفئة' : 'No registrations in this category', style: AppTextStyles.body(15, color: muted, context: context)),
      ]));
    }
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
      itemCount: registrations.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (ctx, i) => _AdminRegCard(reg: registrations[i]),
    );
  }
}

// ─── ADMIN REGISTRATION CARD ──────────────────────────────────────────────────
class _AdminRegCard extends StatelessWidget {
  final ActivityRegistration reg;
  const _AdminRegCard({required this.reg});

  @override
  Widget build(BuildContext context) {
    final txt    = context.textColor;
    final muted  = context.mutedColor;
    final border = context.borderColor;
    final surf   = context.surfaceColor;
    final second = context.secondaryColor;
    final error  = context.errorColor;
    final sColor = reg.status.color;
    final isAr   = Localizations.localeOf(context).languageCode == 'ar';
    final regState = context.read<ActivityRegistrationState>();

    return Container(
      decoration: BoxDecoration(
        color: surf,
        border: Border.all(color: reg.status == RegistrationStatus.pending
            ? sColor.withValues(alpha: 0.5)
            : border),
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // Header
        Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(
          width: 44, height: 44,
          decoration: BoxDecoration(
            color: (reg.status == RegistrationStatus.approved ? const Color(0xFFA8FF3E) : const Color(0xFF00E5FF)).withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(child: Icon(reg.activity.category.icon,
              color: reg.activity.category.isArts ? const Color(0xFFA8FF3E) : const Color(0xFF00E5FF), size: 22)),
        ),
          const SizedBox(width: 10),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(reg.activity.name,
                maxLines: 1, overflow: TextOverflow.ellipsis,
                style: AppTextStyles.heading(15, color: txt, context: context)),
            Text(reg.studentName,
                maxLines: 1, overflow: TextOverflow.ellipsis,
                style: AppTextStyles.body(15, color: txt, context: context)),
            Text('${reg.studentId}  ·  ${reg.faculty}',
                maxLines: 1, overflow: TextOverflow.ellipsis,
                style: AppTextStyles.body(15, color: muted, context: context)),
          ])),
          Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
            _StatusBadge(status: reg.status),
            const SizedBox(height: 4),
            Text(reg.dateLabel, style: AppTextStyles.body(10, color: muted, context: context)),
          ]),
        ]),

        // Details row
        const SizedBox(height: 10),
        Wrap(spacing: 12, runSpacing: 4, children: [
          _InfoRow('📧', reg.studentEmail),
          _InfoRow('📞', reg.phone),
          _InfoRow('🎯', reg.level),
          _InfoRow('📚', reg.semester),
        ]),

        // Personal statement
        if (reg.message.isNotEmpty) ...[
          const SizedBox(height: 10),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: context.bgColor,
              border: BorderDirectional(start: BorderSide(color: border, width: 3)),
            ),
            child: Text('"${reg.message}"',
                style: AppTextStyles.body(14, color: muted, context: context)),
          ),
        ],

        const SizedBox(height: 12),
        // Action buttons
        if (reg.status == RegistrationStatus.pending)
          Row(children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _showDetail(context, reg),
                icon: const Icon(Icons.info_outline, size: 16),
                label: Text(isAr ? 'التفاصيل' : 'Details', style: AppTextStyles.body(15, color: muted, weight: FontWeight.w600, context: context)),
                style: OutlinedButton.styleFrom(
                  foregroundColor: muted, side: BorderSide(color: border),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () {
                  regState.updateStatus(reg.id, RegistrationStatus.rejected);
                  _toast(context, isAr ? '❌ تم الرفض' : '❌ Rejected', error);
                },
                icon: const Icon(Icons.close_rounded, size: 14),
                label: Text(isAr ? 'رفض' : 'Reject', style: AppTextStyles.body(15, color: error, weight: FontWeight.w600, context: context)),
                style: OutlinedButton.styleFrom(
                  foregroundColor: error,
                  side: BorderSide(color: error.withValues(alpha: 0.5)),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () {
                  regState.updateStatus(reg.id, RegistrationStatus.approved);
                  _toast(context, isAr ? '✅ تم القبول' : '✅ Approved', second);
                },
                icon: const Icon(Icons.check_rounded, size: 14),
                label: Text(isAr ? 'قبول' : 'Approve', style: AppTextStyles.body(15, color: context.bgColor, weight: FontWeight.w700, context: context)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: second, foregroundColor: context.bgColor, elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                ),
              ),
            ),
          ])
        else
          Row(children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => _showDetail(context, reg),
                style: OutlinedButton.styleFrom(
                  foregroundColor: muted, side: BorderSide(color: border),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: Text(isAr ? 'عرض التفاصيل' : 'View Details', style: AppTextStyles.body(15, color: muted, weight: FontWeight.w600, context: context)),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: OutlinedButton(
                onPressed: () => regState.updateStatus(reg.id, RegistrationStatus.pending),
                style: OutlinedButton.styleFrom(
                  foregroundColor: muted, side: BorderSide(color: border),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: Text(isAr ? '↩ إعادة تعيين' : '↩ Reset', style: AppTextStyles.body(15, color: muted, weight: FontWeight.w600, context: context)),
              ),
            ),
          ]),
      ]),
    );
  }

  void _toast(BuildContext context, String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg, style: AppTextStyles.body(15, color: Colors.black, context: context)),
      backgroundColor: color,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      duration: const Duration(milliseconds: 1800),
    ));
  }

  void _showDetail(BuildContext context, ActivityRegistration reg) {
    showModalBottomSheet(
      context: context,
      backgroundColor: context.surfaceColor,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      isScrollControlled: true,
      builder: (_) => _DetailSheet(reg: reg),
    );
  }
}

// ─── DETAIL SHEET ─────────────────────────────────────────────────────────────
class _DetailSheet extends StatelessWidget {
  final ActivityRegistration reg;
  const _DetailSheet({required this.reg});

  @override
  Widget build(BuildContext context) {
    final txt    = context.textColor;
    final muted  = context.mutedColor;
    final border = context.borderColor;
    final second = context.secondaryColor;
    final error  = context.errorColor;
    final isAr   = Localizations.localeOf(context).languageCode == 'ar';
    final regState = context.read<ActivityRegistrationState>();

    final rows = [
      (isAr ? 'اسم الطالب' : 'Student Name', reg.studentName),
      (isAr ? 'الرقم الجامعي' : 'Student ID',   reg.studentId),
      (isAr ? 'البريد الإلكتروني' : 'Email',        reg.studentEmail),
      (isAr ? 'رقم الهاتف' : 'Phone',        reg.phone),
      (isAr ? 'الكلية' : 'Faculty',      reg.faculty),
      (isAr ? 'الفصل الدراسي' : 'Semester',     reg.semester),
      (isAr ? 'المستوى' : 'Level',        reg.level),
      (isAr ? 'تاريخ التقديم' : 'Applied',      reg.dateLabel),
    ];

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.7,
      maxChildSize: 0.95,
      builder: (ctx, scroll) => SingleChildScrollView(
        controller: scroll,
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Center(child: Container(width: 40, height: 4,
              decoration: BoxDecoration(color: border, borderRadius: BorderRadius.circular(2)),
              margin: const EdgeInsets.only(bottom: 16))),
          Row(children: [
            Container(
              width: 52, height: 52,
              decoration: BoxDecoration(
                color: const Color(0xFF00E5FF).withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Center(child: Icon(reg.activity.category.icon,
                  color: reg.activity.category.isArts ? const Color(0xFFA8FF3E) : const Color(0xFF00E5FF), size: 26)),
            ),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(reg.activity.name, style: AppTextStyles.display(22, color: txt, context: context), overflow: TextOverflow.ellipsis),
              _StatusBadge(status: reg.status),
            ])),
          ]),
          const SizedBox(height: 16),
          ...rows.map((r) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Row(children: [
              SizedBox(width: 120, child: Text(r.$1, style: AppTextStyles.body(15, color: muted, context: context))),
              Expanded(child: Text(r.$2, style: AppTextStyles.body(15, color: txt, weight: FontWeight.w600, context: context))),
            ]),
          )),
          if (reg.message.isNotEmpty) ...[
            Divider(height: 24, color: border),
            Text(isAr ? 'الرسالة الشخصية' : 'PERSONAL STATEMENT', style: AppTextStyles.label(color: muted, context: context)),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: context.bgColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: border),
              ),
              child: Text(reg.message, style: AppTextStyles.body(15, color: txt, context: context)),
            ),
          ],
          if (reg.status == RegistrationStatus.pending) ...[
            const SizedBox(height: 24),
            Row(children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    regState.updateStatus(reg.id, RegistrationStatus.rejected);
                    Navigator.pop(context);
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: error,
                    side: BorderSide(color: error.withValues(alpha: 0.5)),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text(isAr ? 'رفض' : 'Reject', style: AppTextStyles.body(15, color: error, weight: FontWeight.w700, context: context)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    regState.updateStatus(reg.id, RegistrationStatus.approved);
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: second,
                    foregroundColor: context.bgColor,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text(isAr ? 'قبول' : 'Approve', style: AppTextStyles.body(15, color: context.bgColor, weight: FontWeight.w700, context: context)),
                ),
              ),
            ]),
          ],
        ]),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final RegistrationStatus status;
  const _StatusBadge({required this.status});
  @override
  Widget build(BuildContext context) {
    final isAr = Localizations.localeOf(context).languageCode == 'ar';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: status.color.withValues(alpha: 0.15),
        border: Border.all(color: status.color.withValues(alpha: 0.4)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(status.icon, color: status.color, size: 11),
        const SizedBox(width: 4),
        Text(isAr ? _statusLabelAr(status) : status.label, style: AppTextStyles.label(color: status.color, context: context).copyWith(fontSize: 11, letterSpacing: 0.3)),
      ]),
    );
  }

  String _statusLabelAr(RegistrationStatus s) => switch (s) {
    RegistrationStatus.pending  => 'قيد الانتظار',
    RegistrationStatus.approved => 'مقبول',
    RegistrationStatus.rejected => 'مرفوض',
  };
}

class _InfoRow extends StatelessWidget {
  final String icon, text;
  const _InfoRow(this.icon, this.text);
  @override
  Widget build(BuildContext context) => Row(mainAxisSize: MainAxisSize.min, children: [
    Text(icon, style: const TextStyle(fontSize: 12)),
    const SizedBox(width: 4),
    ConstrainedBox(
      constraints: BoxConstraints(maxWidth: MediaQuery.sizeOf(context).width * 0.4),
      child: Text(text,
          maxLines: 1, overflow: TextOverflow.ellipsis,
          style: AppTextStyles.body(14, color: context.mutedColor, context: context)),
    ),
  ]);
}
