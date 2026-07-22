import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/widgets.dart';
import '../../../core/state/app_state.dart';
import '../../../core/state/activity_state.dart';
import '../../../core/models/activity_models.dart';
import '../../../l10n/app_localizations.dart';

class MyRegistrationsScreen extends StatefulWidget {
  const MyRegistrationsScreen({super.key});
  @override
  State<MyRegistrationsScreen> createState() => _MyRegistrationsScreenState();
}

class _MyRegistrationsScreenState extends State<MyRegistrationsScreen>
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
    final primary  = context.primaryColor;
    final second   = context.secondaryColor;
    final txt      = context.textColor;
    final muted    = context.mutedColor;
    final border   = context.borderColor;
    final bg       = context.bgColor;
    final regState = context.watch<ActivityRegistrationState>();
    final email    = context.read<AppState>().user.email;
    final all      = regState.forStudent(email);
    final pending  = all.where((r) => r.status == RegistrationStatus.pending).toList();
    final approved = all.where((r) => r.status == RegistrationStatus.approved).toList();
    final rejected = all.where((r) => r.status == RegistrationStatus.rejected).toList();

    final tabs = [
      ('${AppLocalizations.of(context)!.allTab} (${all.length})',      all),
      ('${AppLocalizations.of(context)!.pendingTab} (${pending.length})',  pending),
      ('${AppLocalizations.of(context)!.approvedTab} (${approved.length})', approved),
      ('${AppLocalizations.of(context)!.rejectedTab} (${rejected.length})', rejected),
    ];

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: bg,
        surfaceTintColor: Colors.transparent,
        title: Text(AppLocalizations.of(context)!.myApplicationsTitle, style: AppTextStyles.display(20, color: txt, context: context)),
        leading: IconButton(
          icon: Icon(
            Localizations.localeOf(context).languageCode == 'ar'
                ? Icons.arrow_forward_ios_rounded
                : Icons.arrow_back_ios_new_rounded,
            color: txt,
            size: 20,
          ),
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
      body: Column(children: [
        // ── Stats row ────────────────────────────────────────────────────
        Container(
          color: bg,
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
          child: Row(children: [
            _StatPill(label: AppLocalizations.of(context)!.approved, value: approved.length, color: second),
            const SizedBox(width: 8),
            _StatPill(label: AppLocalizations.of(context)!.pending,  value: pending.length,  color: const Color(0xFFFFB547)),
            const SizedBox(width: 8),
            _StatPill(label: AppLocalizations.of(context)!.rejected, value: rejected.length, color: context.errorColor),
          ]),
        ),
        Divider(height: 1, color: border),
        // ── Tabs ─────────────────────────────────────────────────────────
        Expanded(
          child: TabBarView(
            controller: _tab,
            children: tabs.map((t) => _RegistrationList(registrations: t.$2)).toList(),
          ),
        ),
      ]),
    );
  }
}

// ─── REGISTRATION LIST ────────────────────────────────────────────────────────
class _RegistrationList extends StatelessWidget {
  final List<ActivityRegistration> registrations;
  const _RegistrationList({required this.registrations});

  @override
  Widget build(BuildContext context) {
    final muted = context.mutedColor;
    if (registrations.isEmpty) {
      return Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
        const Icon(Icons.inbox_rounded, size: 52, color: Color(0xFF5A7090)),
        const SizedBox(height: 12),
        Text(AppLocalizations.of(context)!.noApplicationsYet, style: AppTextStyles.body(15, color: muted)),
        const SizedBox(height: 6),
        Text(AppLocalizations.of(context)!.goToActivities, style: AppTextStyles.body(15, color: muted)),
      ]));
    }
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
      itemCount: registrations.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (ctx, i) => _RegCard(reg: registrations[i]),
    );
  }
}

// ─── REGISTRATION CARD ────────────────────────────────────────────────────────
class _RegCard extends StatelessWidget {
  final ActivityRegistration reg;
  const _RegCard({required this.reg});

  @override
  Widget build(BuildContext context) {
    final txt    = context.textColor;
    final muted  = context.mutedColor;
    final border = context.borderColor;
    final surf   = context.surfaceColor;
    final sColor = reg.status.color;

    return Container(
      decoration: BoxDecoration(
        color: surf,
        border: Border.all(color: sColor.withValues(alpha: 0.35)),
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // Header
        Row(children: [
          Container(
            width: 44, height: 44,
            decoration: BoxDecoration(
              color: sColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(child: Icon(
              reg.activity.category.icon,
              color: sColor, size: 22,
            )),
          ),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(reg.activity.name,
                maxLines: 1, overflow: TextOverflow.ellipsis,
                style: AppTextStyles.heading(15, color: txt)),
            Text(reg.activity.category.displayName(context),
                maxLines: 1, overflow: TextOverflow.ellipsis,
                style: AppTextStyles.body(16, color: muted)),
          ])),
          _StatusBadge(status: reg.status),
        ]),
        const SizedBox(height: 8),
        Row(children: [
          Flexible(child: Text('${AppLocalizations.of(context)!.applied} ${reg.dateLabel}',
              maxLines: 1, overflow: TextOverflow.ellipsis,
              style: AppTextStyles.body(16, color: muted))),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6),
            child: Text('·', style: AppTextStyles.body(16, color: muted)),
          ),
          Flexible(child: Text('${AppLocalizations.of(context)!.level} ${reg.level}',
              maxLines: 1, overflow: TextOverflow.ellipsis,
              style: AppTextStyles.body(16, color: muted))),
        ]),

        // Message
        if (reg.message.isNotEmpty) ...[
          const SizedBox(height: 10),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: context.bgColor,
              border: Border(left: BorderSide(color: border, width: 3)),
            ),
            child: Text('"${reg.message}"',
                style: AppTextStyles.body(16, color: muted)),
          ),
        ],

        // Status banner
        const SizedBox(height: 10),
        if (reg.status == RegistrationStatus.approved)
          _Banner(
            color: reg.status.color,
            icon: '🎉',
            text: AppLocalizations.of(context)!.congratsApproved,
          )
        else if (reg.status == RegistrationStatus.rejected)
          _Banner(
            color: reg.status.color,
            icon: 'ℹ️',
            text: AppLocalizations.of(context)!.rejectedMsg,
          )
        else
          _Banner(
            color: reg.status.color,
            icon: '⏳',
            text: AppLocalizations.of(context)!.underReview,
          ),
      ]),
    );
  }
}

class _Banner extends StatelessWidget {
  final Color color;
  final String icon, text;
  const _Banner({required this.color, required this.icon, required this.text});
  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    decoration: BoxDecoration(
      color: color.withValues(alpha: 0.1),
      border: Border.all(color: color.withValues(alpha: 0.35)),
      borderRadius: BorderRadius.circular(10),
    ),
    child: Row(children: [
      Text(icon, style: const TextStyle(fontSize: 14)),
      const SizedBox(width: 8),
      Expanded(child: Text(text, style: AppTextStyles.body(16, color: color))),
    ]),
  );
}

class _StatusBadge extends StatelessWidget {
  final RegistrationStatus status;
  const _StatusBadge({required this.status});
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
    decoration: BoxDecoration(
      color: status.color.withValues(alpha: 0.15),
      border: Border.all(color: status.color.withValues(alpha: 0.4)),
      borderRadius: BorderRadius.circular(8),
    ),
    child: Row(mainAxisSize: MainAxisSize.min, children: [
      Icon(status.icon, color: status.color, size: 11),
      const SizedBox(width: 4),
      Text(status.label,
          style: AppTextStyles.label(color: status.color).copyWith(fontSize: 11, letterSpacing: 0.3)),
    ]),
  );
}

class _StatPill extends StatelessWidget {
  final String label;
  final int value;
  final Color color;
  const _StatPill({required this.label, required this.value, required this.color});
  @override
  Widget build(BuildContext context) => Expanded(
    child: Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        border: Border.all(color: color.withValues(alpha: 0.3)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(children: [
        Text('$value',
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.display(18, color: color)),
        const SizedBox(height: 2),
        Text(label,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.body(13, color: color)),
      ]),
    ),
  );
}
