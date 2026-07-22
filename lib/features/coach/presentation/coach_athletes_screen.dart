import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/models/activity_models.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/widgets.dart';
import '../../../core/state/activity_state.dart';
import '../../../l10n/app_localizations.dart';

// ─── IMPROVEMENT #15: Coach Athletes Screen ───────────────────────────────────
// Coaches see their approved students only — not all system users.
class CoachAthletesScreen extends StatefulWidget {
  const CoachAthletesScreen({super.key});
  @override
  State<CoachAthletesScreen> createState() => _CoachAthletesScreenState();
}

class _CoachAthletesScreenState extends State<CoachAthletesScreen> {
  final _searchCtrl = TextEditingController();
  String _query = '';

  @override
  void initState() {
    super.initState();
    _searchCtrl.addListener(() => setState(() => _query = _searchCtrl.text.trim().toLowerCase()));
  }

  @override
  void dispose() { _searchCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final l        = AppLocalizations.of(context)!;
    final regState = context.watch<ActivityRegistrationState>();
    final txt      = context.textColor;
    final muted    = context.mutedColor;
    final surf     = context.surfaceColor;
    final border   = context.borderColor;
    final primary  = context.primaryColor;
    final second   = context.secondaryColor;

    var athletes = regState.all
        .where((r) => r.status == RegistrationStatus.approved)
        .toList();

    if (_query.isNotEmpty) {
      athletes = athletes.where((r) =>
          r.studentName.toLowerCase().contains(_query) ||
          r.studentEmail.toLowerCase().contains(_query) ||
          r.activity.name.toLowerCase().contains(_query) ||
          r.faculty.toLowerCase().contains(_query)).toList();
    }

    return Scaffold(
      backgroundColor: context.bgColor,
      appBar: AppBar(
        backgroundColor: context.bgColor,
        surfaceTintColor: Colors.transparent,
        title: Text(l.myAthletes, style: AppTextStyles.display(20, color: txt, context: context)),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: TextField(
              controller: _searchCtrl,
              style: AppTextStyles.body(14, color: txt, context: context),
              decoration: InputDecoration(
                hintText: l.searchAthletes,
                hintStyle: AppTextStyles.body(13, color: muted, context: context),
                prefixIcon: Icon(Icons.search_rounded, color: muted, size: 20),
                filled: true, fillColor: surf,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(color: border)),
                focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(color: primary, width: 1.5)),
              ),
            ),
          ),
        ),
      ),
      body: athletes.isEmpty
          ? Center(child: Text(l.noAthletes,
              style: AppTextStyles.body(14, color: muted, context: context)))
          : ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
              itemCount: athletes.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (_, i) {
                final r = athletes[i];
                return Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: surf, borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: border),
                  ),
                  child: Row(children: [
                    CircleAvatar(
                      radius: 22,
                      backgroundColor: second.withValues(alpha: 0.15),
                      child: Text(
                        r.studentName.split(' ').take(2)
                            .map((p) => p[0]).join().toUpperCase(),
                        style: AppTextStyles.body(13, color: second, weight: FontWeight.w700, context: context),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(r.studentName,
                            style: AppTextStyles.body(14, color: txt, weight: FontWeight.w700, context: context)),
                        Text('${r.activity.name}  ·  ${r.faculty}',
                            style: AppTextStyles.body(12, color: muted, context: context)),
                        Text(r.level,
                            style: AppTextStyles.label(color: primary, size: 11, context: context)),
                      ],
                    )),
                    Icon(Icons.verified_rounded, color: second, size: 18),
                  ]),
                );
              },
            ),
    );
  }
}

