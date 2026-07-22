// lib/features/admin/create_activity_screen.dart
import '../../core/models/user_model.dart';
import 'bloc/admin_bloc.dart';
import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/constants/app_constants.dart';
import '../../l10n/app_localizations.dart';

class CreateActivityScreen extends StatefulWidget {
  const CreateActivityScreen({super.key});
  @override
  State<CreateActivityScreen> createState() =>
      _CreateActivityScreenState();
}

class _CreateActivityScreenState extends State<CreateActivityScreen>
    with SingleTickerProviderStateMixin {
  final _formKey          = GlobalKey<FormState>();
  String _type            = ActivityTypes.sports;
  String _category        = SportsList.sports[0]['name']!;
  String? _coachId;
  String? _coachName;

  late AnimationController _ctrl;
  late Animation<double>   _opacity;

  final _nameEnCtrl   = TextEditingController();
  final _nameArCtrl   = TextEditingController();
  final _descEnCtrl   = TextEditingController();
  final _descArCtrl   = TextEditingController();
  final _scheduleCtrl = TextEditingController();
  final _locEnCtrl    = TextEditingController();
  final _locArCtrl    = TextEditingController();
  final _maxCtrl      = TextEditingController(text: '30');

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this,
        duration: const Duration(milliseconds: 600))..forward();
    _opacity = Tween<double>(begin: 0, end: 1)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeIn));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    for (final c in [_nameEnCtrl, _nameArCtrl, _descEnCtrl, _descArCtrl,
        _scheduleCtrl, _locEnCtrl, _locArCtrl, _maxCtrl]) {
      c.dispose();
    }
    super.dispose();
  }

  List<Map<String, dynamic>> get _cats =>
      _type == ActivityTypes.sports ? SportsList.sports : ArtsList.arts;

  void _submit() {
    final l = AppLocalizations.of(context)!;
    if (!_formKey.currentState!.validate()) return;
    if (_coachId == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(l.errorSelectCoach, style: AppTextStyles.body(14, color: Colors.white, context: context)),
        backgroundColor: Colors.orange,
      ));
      return;
    }
    context.read<AdminBloc>().add(
      AdminActivityCreateRequested({
        'name':           _nameEnCtrl.text.trim(),
        'nameAr':         _nameArCtrl.text.trim(),
        'type':           _type,
        'category':       _category,
        'description':    _descEnCtrl.text.trim(),
        'descriptionAr':  _descArCtrl.text.trim(),
        'coachId':        _coachId,
        'coachName':      _coachName ?? '',
        'maxParticipants':int.tryParse(_maxCtrl.text) ?? 30,
        'schedule':       _scheduleCtrl.text.trim(),
        'location':       _locEnCtrl.text.trim(),
        'locationAr':     _locArCtrl.text.trim(),
      }, l),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return BlocListener<AdminBloc, AdminState>(
      listener: (context, state) {
        if (state is AdminActionSuccess) Navigator.pop(context);
        if (state is AdminError) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(state.message, style: AppTextStyles.body(14, color: Colors.white, context: context)),
            backgroundColor: Colors.redAccent,
          ));
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(l.createActivity, style: AppTextStyles.heading(18, color: Colors.white, context: context)),
          backgroundColor: DarkColors.bg,
          foregroundColor: DarkColors.text,
        ),
        body: FadeTransition(
          opacity: _opacity,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSizes.paddingL),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _sectionTitle(l.activityType),
                  Row(children: [
                    _typeChip(ActivityTypes.sports, '🏆 ${l.sports}'),
                    const SizedBox(width: 12),
                    _typeChip(ActivityTypes.arts, '🎨 ${l.arts}'),
                  ]),
                  const SizedBox(height: 20),
                  _sectionTitle(l.activityCategory),
                  _dropdown(),
                  const SizedBox(height: 20),
                  _sectionTitle(l.activities),
                  _tf(_nameEnCtrl, l.activityNameEn, Icons.title,
                      validator: (v) => v!.isEmpty ? 'Required' : null),
                  const SizedBox(height: 12),
                  _tf(_nameArCtrl, l.activityNameAr, Icons.title,
                      isAr: true,
                      validator: (v) => v!.isEmpty ? 'مطلوب' : null),
                  const SizedBox(height: 20),
                  _sectionTitle(l.activityDescEn),
                  _tf(_descEnCtrl, l.activityDescEn,
                      Icons.description, maxLines: 3),
                  const SizedBox(height: 12),
                  _tf(_descArCtrl, l.activityDescAr,
                      Icons.description, isAr: true, maxLines: 3),
                  const SizedBox(height: 20),
                  _sectionTitle(l.activityCoach),
                  _coachSelector(),
                  const SizedBox(height: 20),
                  _sectionTitle(l.activitySchedule),
                  _tf(_scheduleCtrl, l.activitySchedule,
                      Icons.schedule,
                      validator: (v) => v!.isEmpty ? 'Required' : null),
                  const SizedBox(height: 12),
                  _tf(_locEnCtrl, l.activityLocEn,
                      Icons.location_on),
                  const SizedBox(height: 12),
                  _tf(_locArCtrl, l.activityLocAr,
                      Icons.location_on, isAr: true),
                  const SizedBox(height: 12),
                  _tf(_maxCtrl, l.activityMax, Icons.people,
                      keyboardType: TextInputType.number),
                  const SizedBox(height: 32),
                  BlocBuilder<AdminBloc, AdminState>(
                    builder: (_, state) {
                      final loading = state is AdminActionInProgress;
                      return GestureDetector(
                        onTap: loading ? null : _submit,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 180),
                          height: 54,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [DarkColors.primary, Color(0xFF0097A7)],
                              begin: Alignment.centerLeft, end: Alignment.centerRight,
                            ),
                            borderRadius: BorderRadius.circular(14),
                            boxShadow: [BoxShadow(
                              color: DarkColors.primary.withValues(alpha: loading ? 0.1 : 0.3),
                              blurRadius: 16)],
                          ),
                          child: Center(child: loading
                            ? const SizedBox(width: 22, height: 22,
                                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
                            : Text(l.createActivity,
                                style: const TextStyle(color: DarkColors.bg, fontSize: 16, fontWeight: FontWeight.w700))),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _sectionTitle(String t) => Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: Text(t, style: const TextStyle(
        fontWeight: FontWeight.bold, fontSize: 16,
        color: DarkColors.primary)),
  );

  Widget _typeChip(String type, String label) {
    final sel = _type == type;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() {
          _type = type;
          _category = (type == ActivityTypes.sports
              ? SportsList.sports : ArtsList.arts)[0]['name']!;
        }),
        child: AnimatedContainer(
          duration: AppDurations.medium,
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: sel ? DarkColors.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(AppSizes.radiusM),
            border: Border.all(
              color: sel ? DarkColors.primary
                  : Colors.grey.withValues(alpha: 0.3)),
            boxShadow: sel ? [BoxShadow(
              color: DarkColors.primary.withValues(alpha: 0.3),
              blurRadius: 12)] : [],
          ),
          child: Center(child: Text(label, style: TextStyle(
            color: sel ? Colors.white : Colors.grey,
            fontWeight: sel ? FontWeight.bold : FontWeight.normal,
          ))),
        ),
      ),
    );
  }

  Widget _dropdown() => Container(
    padding: const EdgeInsets.symmetric(horizontal: 16),
    decoration: BoxDecoration(
      border: Border.all(color: Colors.grey.withValues(alpha: 0.3)),
      borderRadius: BorderRadius.circular(AppSizes.radiusM),
    ),
    child: DropdownButtonHideUnderline(
      child: DropdownButton<String>(
        value: _category,
        isExpanded: true,
        items: _cats.map((c) => DropdownMenuItem<String>(
          value: c['name'] as String,
          child: Text('${c['icon']} ${c['name']}'),
        )).toList(),
        onChanged: (v) { if (v != null) setState(() => _category = v); },
      ),
    ),
  );

  Widget _coachSelector() {
    // In BLoC-driven version we read coaches from AdminBloc state
    return BlocBuilder<AdminBloc, AdminState>(
      builder: (_, state) {
        final  List<UserModel> coaches;
        if (state is AdminLoaded) {
          coaches = state.coaches;
        } else {
          coaches = <UserModel>[];
        }
        if (coaches.isEmpty) {
          final l = AppLocalizations.of(context)!;
          return Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.orange.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                  color: Colors.orange.withValues(alpha: 0.3)),
            ),
            child: Row(children: [
              const Icon(Icons.warning_amber, color: Colors.orange),
              const SizedBox(width: 8),
              Text(l.noStudentsYet.replaceAll('طلاب', 'مدربون'), // Quick fix for "No coaches"
                  style: const TextStyle(color: Colors.orange)),
            ]),
          );
        }
        final l = AppLocalizations.of(context)!;
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            border: Border.all(
                color: Colors.grey.withValues(alpha: 0.3)),
            borderRadius: BorderRadius.circular(AppSizes.radiusM),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _coachId,
              isExpanded: true,
              hint: Text(l.activityCoach.replaceAll(' *', '')),
              items: coaches.map((c) => DropdownMenuItem<String>(
                value: c.uid,
                child: Row(children: [
                  CircleAvatar(
                    radius: 14,
                    backgroundColor: DarkColors.bg,
                    child: Text(
                      c.name.isNotEmpty ? c.name.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty).map((p) => p[0].toUpperCase()).take(2).join() : 'C',
                      style: const TextStyle(
                          color: Colors.white, fontSize: 12)),
                  ),
                  const SizedBox(width: 10),
                  Text(c.name),
                ]),
              )).toList(),
              onChanged: (v) {
                if (v != null) {
                  final coach =
                      coaches.firstWhere((c) => c.uid == v);
                  setState(() {
                    _coachId   = v;
                    _coachName = coach.name;
                  });
                }
              },
            ),
          ),
        );
      },
    );
  }

  Widget _tf(
    TextEditingController ctrl,
    String label,
    IconData icon, {
    bool isAr = false,
    int maxLines = 1,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: ctrl,
      maxLines: maxLines,
      keyboardType: keyboardType,
      textDirection: isAr ? TextDirection.rtl : TextDirection.ltr,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        hintText: AppHints.activity['create'],
        hintStyle: const TextStyle(color: Colors.grey, fontSize: 12),
        prefixIcon: Icon(icon, color: DarkColors.primary),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppSizes.radiusM),
            borderSide:
                BorderSide(color: Colors.grey.withValues(alpha: 0.3))),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppSizes.radiusM),
            borderSide:
                const BorderSide(color: DarkColors.primary, width: 2)),
      ),
    );
  }
}
