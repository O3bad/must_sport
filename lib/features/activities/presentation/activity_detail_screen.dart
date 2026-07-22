import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/models/models.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/widgets.dart';
import '../../../core/state/app_state.dart';
import '../../../core/models/activity_models.dart';
import '../../../l10n/app_localizations.dart';
import 'registration_form_screen.dart';

class ActivityDetailScreen extends StatelessWidget {
  final ActivityModel activity;
  final bool isRegistered;
  const ActivityDetailScreen({super.key, required this.activity, required this.isRegistered});

  @override
  Widget build(BuildContext context) {
    final l       = AppLocalizations.of(context)!;
    final primary = context.primaryColor;
    final second  = context.secondaryColor;
    final txt     = context.textColor;
    final muted   = context.mutedColor;
    final border  = context.borderColor;
    final surf    = context.surfaceColor;
    final bg      = context.bgColor;
    final isStudent = context.read<AppState>().user.role == UserRole.student;

    return Scaffold(
      backgroundColor: bg,
      body: CustomScrollView(slivers: [
        // ── Hero app bar ───────────────────────────────────────────────────
        SliverAppBar(
          expandedHeight: 200,
          pinned: true,
          backgroundColor: bg,
          foregroundColor: txt,
          surfaceTintColor: Colors.transparent,
          flexibleSpace: FlexibleSpaceBar(
            background: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [primary.withValues(alpha: 0.25), bg],
                  begin: Alignment.topCenter, end: Alignment.bottomCenter,
                ),
              ),
              child: Center(child: Text(activity.emoji,
                  style: const TextStyle(fontSize: 80))),
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              // Title + badge
              Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(activity.name,
                      maxLines: 2, overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.display(28, color: txt, context: context)),
                  const SizedBox(height: 4),
                  _Tag(label: activity.category.displayName(context), color: primary),
                ])),
                if (isRegistered) ...[
                  const SizedBox(width: 8),
                  _Tag(label: l.enrolledTag, color: second),
                ],
              ]),
              const SizedBox(height: 16),

              // Description
              Text(activity.description,
                  style: AppTextStyles.body(16, color: muted, context: context)),
              const SizedBox(height: 20),

              // Details grid
              Container(
                decoration: BoxDecoration(color: surf, border: Border.all(color: border),
                    borderRadius: BorderRadius.circular(16)),
                padding: const EdgeInsets.all(16),
                child: Column(children: [
                  _DetailRow('📅  ${l.schedule}', activity.schedule),
                  const Divider(height: 20),
                  _DetailRow('📍  ${l.venue}', activity.venue),
                  const Divider(height: 20),
                  _DetailRow('👨‍🏫  ${l.coachLabel}', activity.coach),
                  const Divider(height: 20),
                  _DetailRow('🎯  ${l.level}', activity.level),
                  const Divider(height: 20),
                  _DetailRow('👥  ${l.activeMembers}', l.studentsCount(activity.slots)),
                  const Divider(height: 20),
                  _DetailRow('💰  ${l.regFee}', activity.fee),
                ]),
              ),
              const SizedBox(height: 24),

              // CTA
              if (isRegistered)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: second.withValues(alpha: 0.1),
                    border: Border.all(color: second.withValues(alpha: 0.4)),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Column(children: [
                    Text(l.alreadyRegistered, style: AppTextStyles.heading(18, color: second, context: context)),
                    const SizedBox(height: 4),
                    Text(l.checkStatusInMyApps,
                        style: AppTextStyles.body(15, color: muted, context: context)),
                  ]),
                )
              else if (isStudent)
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.push(context,
                        MaterialPageRoute(builder: (_) => RegistrationFormScreen(activity: activity))),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: second,
                      foregroundColor: context.bgColor,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    child: Text(l.registerForActivity(activity.name),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.body(16, color: bg, weight: FontWeight.w700, context: context)),
                  ),
                ),
            ]),
          ),
        ),
      ]),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label, value;
  const _DetailRow(this.label, this.value);
  @override
  Widget build(BuildContext context) => Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Expanded(
        flex: 5,
        child: Text(label,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.body(15, color: context.mutedColor, context: context)),
      ),
      const SizedBox(width: 12),
      Expanded(
        flex: 4,
        child: Text(value,
            textAlign: TextAlign.end,
            maxLines: 4,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.body(15, color: context.textColor, weight: FontWeight.w600, context: context)),
      ),
    ],
  );
}

class _Tag extends StatelessWidget {
  final String label;
  final Color color;
  const _Tag({required this.label, required this.color});
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
    decoration: BoxDecoration(
      color: color.withValues(alpha: 0.15),
      border: Border.all(color: color.withValues(alpha: 0.4)),
      borderRadius: BorderRadius.circular(8),
    ),
    child: Text(label, style: AppTextStyles.label(color: color, context: context).copyWith(fontSize: 11)),
  );
}
