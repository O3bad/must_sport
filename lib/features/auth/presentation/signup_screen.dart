import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/state/app_state.dart';
import '../../../core/models/models.dart';
import '../../../l10n/app_localizations.dart';
import '../../../app_shell.dart';
import '../../admin/presentation/admin_shell.dart';
import '../../coach/presentation/coach_shell.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});
  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen>
    with SingleTickerProviderStateMixin {
  final _pageCtrl      = PageController();
  final _nameCtrl      = TextEditingController();
  final _emailCtrl     = TextEditingController();
  final _studentIdCtrl = TextEditingController();
  final _passCtrl      = TextEditingController();
  final _confirmCtrl   = TextEditingController();
  final _phoneCtrl     = TextEditingController();

  UserRole _role     = UserRole.student;
  String   _faculty  = '';
  String   _semester = 'Spring 2026';
  bool     _obscureP = true;
  bool     _obscureC = true;
  bool     _loading  = false;
  String?  _error;
  int      _page     = 0;

  late AnimationController _glowCtrl;
  late Animation<double>   _glowAnim;

  static const _semesters = ['Spring 2026', 'Fall 2026', 'Spring 2027'];
  static const _faculties = [
    'IT Faculty','Engineering','Medicine','Pharmacy',
    'Business','physical therapy','special_education','Nursing','dentistry',
    'biotechnology','foreign_language','archaeology',

  ];
  static const _roles = [
    _RoleMeta(role: UserRole.student, label: 'Student'),
    _RoleMeta(role: UserRole.coach,   label: 'Coach'),
    _RoleMeta(role: UserRole.admin,   label: 'Admin'),
  ];

  @override
  void initState() {
    super.initState();
    _glowCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 2400))
      ..repeat(reverse: true);
    _glowAnim = Tween<double>(begin: 0.4, end: 1.0)
        .animate(CurvedAnimation(parent: _glowCtrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _glowCtrl.dispose();
    _pageCtrl.dispose();
    for (final c in [_nameCtrl, _emailCtrl, _studentIdCtrl, _passCtrl, _confirmCtrl, _phoneCtrl]) {
      c.dispose();
    }
    super.dispose();
  }

  Color get _roleColor => switch (_role) {
    UserRole.student => DarkColors.primary,
    UserRole.coach   => DarkColors.accent,
    UserRole.admin   => DarkColors.error,
  };

  String? _validatePage0(AppLocalizations l) {
    if (_nameCtrl.text.trim().length < 3) return l.errorNameShort;
    final email = _emailCtrl.text.trim();
    if (!email.contains('@') || !email.contains('.')) return l.errorInvalidEmail;
    if (_role == UserRole.student && _studentIdCtrl.text.trim().isEmpty) {
      return l.studentId; // TODO: Add specific error if needed
    }
    return null;
  }

  String? _validateAll(AppLocalizations l) {
    final p0 = _validatePage0(l);
    if (p0 != null) return p0;
    if (_passCtrl.text.length < 6)  return l.errorPasswordShort;
    if (_passCtrl.text != _confirmCtrl.text) return l.errorPasswordMismatch;
    if (_faculty.isEmpty) return l.errorSelectFaculty;
    return null;
  }

  void _nextPage(AppLocalizations l) {
    FocusScope.of(context).unfocus();
    final err = _validatePage0(l);
    if (err != null) { setState(() => _error = err); return; }
    setState(() { _error = null; _page = 1; });
    _pageCtrl.animateToPage(1,
        duration: const Duration(milliseconds: 350), curve: Curves.easeInOut);
  }

  void _prevPage() {
    FocusScope.of(context).unfocus();
    setState(() { _error = null; _page = 0; });
    _pageCtrl.animateToPage(0,
        duration: const Duration(milliseconds: 350), curve: Curves.easeInOut);
  }

  Future<void> _submit(AppLocalizations l) async {
    FocusScope.of(context).unfocus();
    final err = _validateAll(l);
    if (err != null) { setState(() => _error = err); return; }
    setState(() { _loading = true; _error = null; });

    final name = _nameCtrl.text.trim();
    final email = _emailCtrl.text.trim();
    final year = DateTime.now().year;
    final suffix = (1000 + (name.hashCode.abs() % 9000)).toString();
    final studentId = _studentIdCtrl.text.trim().isNotEmpty
        ? _studentIdCtrl.text.trim()
        : 'MUST-$year-$suffix';

    final newUser = UserModel(
      uid: 'pending', role: _role,
      name: name, studentId: studentId, email: email,
      faculty: _faculty, semester: _semester,
      phone: _phoneCtrl.text.trim(),
      points: 0, rank: 999, cgpa: 0.0, creditHours: '0/140', targetEvents: 5,
      stats: const UserStats(eventsJoined: 0, bookingsMade: 0, wins: 0),
      achievements: [],
    );

    final appState = context.read<AppState>();
    final regError = await appState.registerNewUser(newUser, password: _passCtrl.text);
    if (!mounted) return;

    if (regError != null) {
      setState(() { _loading = false; _error = _mapError(regError, l); });
      return;
    }
    setState(() => _loading = false);
    HapticFeedback.lightImpact();

    final Widget dest = switch (_role) {
      UserRole.admin   => const AdminShell(),
      UserRole.coach   => const CoachShell(),
      UserRole.student => const AppShell(),
    };
    Navigator.of(context).pushReplacement(PageRouteBuilder(
      pageBuilder: (_, a, __) => dest,
      transitionsBuilder: (_, a, __, child) => FadeTransition(opacity: a, child: child),
      transitionDuration: const Duration(milliseconds: 400),
    ));
  }

  String _mapError(String code, AppLocalizations l) => switch (code) {
    'emailAlreadyInUse' => l.errorEmailInUse,
    'invalidEmail'      => l.errorInvalidEmail,
    'weakPassword'      => l.errorWeakPassword,
    _                   => l.errorSignUpFailed,
  };

  Color _accentFor(UserRole r) => switch (r) {
    UserRole.student => DarkColors.primary,
    UserRole.coach   => DarkColors.accent,
    UserRole.admin   => DarkColors.error,
  };

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: DarkColors.bg,
      body: SafeArea(
        child: Column(children: [
          // ── Top bar ────────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
            child: Row(children: [
              _BackButton(onTap: _page == 1 ? _prevPage : () => Navigator.pop(context)),
              const Spacer(),
              _StepDots(current: _page, color: _roleColor),
            ]),
          ),
          // ── Header ────────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 18, 24, 0),
            child: Row(children: [
              Expanded(
                child: AnimatedBuilder(
                  animation: _glowAnim,
                  builder: (_, __) => ShaderMask(
                    shaderCallback: (b) => LinearGradient(
                        colors: [_roleColor, DarkColors.secondary]).createShader(b),
                    child: Text(
                      _page == 0 ? l.createAccount : l.accountDetails,
                      style: AppTextStyles.display(28, color: Colors.white, context: context),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              ),
            ]),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 4, 24, 0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                _page == 0 ? l.joinMusterSport : l.almostThere,
                style: AppTextStyles.body(13, color: DarkColors.muted, context: context),
              ),
            ),
          ),
          const SizedBox(height: 4),
          // ── Pages ──────────────────────────────────────────────────────
          Expanded(
            child: PageView(
              controller: _pageCtrl,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                // PAGE 0
                SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    // Role picker
                    _SectionLabel(l.iAmA, context: context),
                    const SizedBox(height: 10),
                    Row(children: _roles.map((meta) {
                      final active = _role == meta.role;
                      final color  = _accentFor(meta.role);
                      return Expanded(child: Padding(
                        padding: EdgeInsets.only(
                          right: (Directionality.of(context) == TextDirection.ltr && meta.role != UserRole.admin) ? 8 : 0,
                          left: (Directionality.of(context) == TextDirection.rtl && meta.role != UserRole.admin) ? 8 : 0,
                        ),
                        child: GestureDetector(
                          onTap: () { HapticFeedback.selectionClick(); setState(() { _role = meta.role; _error = null; }); },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 6),
                            decoration: BoxDecoration(
                              color: active ? color.withValues(alpha: 0.12) : DarkColors.surface,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: active ? color : DarkColors.border, width: active ? 1.8 : 1),
                              boxShadow: active ? [BoxShadow(color: color.withValues(alpha: 0.22), blurRadius: 12)] : [],
                            ),
                            child: Column(mainAxisSize: MainAxisSize.min, children: [
                              Icon(meta.icon, color: active ? color : DarkColors.muted, size: active ? 26 : 22),
                              const SizedBox(height: 5),
                              Text(meta.localizedLabel(l),
                                  textAlign: TextAlign.center,
                                  style: AppTextStyles.body(12, color: active ? color : DarkColors.muted, weight: FontWeight.w700, context: context)),
                            ]),
                          ),
                        ),
                      ));
                    }).toList()),

                    const SizedBox(height: 22),

                    // Full Name
                    _FieldLabel(l.fullNameLabel, context: context),
                    const SizedBox(height: 7),
                    _GlowField(controller: _nameCtrl, hint: l.fullNameHint,
                        prefixIcon: Icons.person_outline, accentColor: _roleColor,
                        textCapitalization: TextCapitalization.words,
                        onChanged: (_) => setState(() => _error = null)),

                    const SizedBox(height: 14),

                    // Email
                    _FieldLabel(l.universityEmailLabel, context: context),
                    const SizedBox(height: 7),
                    _GlowField(controller: _emailCtrl, hint: l.emailHint,
                        prefixIcon: Icons.email_outlined, accentColor: _roleColor,
                        keyboardType: TextInputType.emailAddress,
                        onChanged: (_) => setState(() => _error = null)),

                    const SizedBox(height: 14),

                    // Student ID (only for students)
                    if (_role == UserRole.student) ...[
                      _FieldLabel(l.studentId, context: context),
                      const SizedBox(height: 7),
                      _GlowField(
                        controller: _studentIdCtrl,
                        hint: l.studentIdHint,
                        prefixIcon: Icons.badge_outlined,
                        accentColor: _roleColor,
                        textCapitalization: TextCapitalization.characters,
                        onChanged: (_) => setState(() => _error = null),
                      ),
                      const SizedBox(height: 4),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: Text(l.studentIdDesc,
                          style: AppTextStyles.body(11, color: DarkColors.muted.withValues(alpha: 0.65), context: context)),
                      ),
                      const SizedBox(height: 14),
                    ],

                    if (_error != null) ...[_ErrorBanner(_error!), const SizedBox(height: 14)],

                    // Next
                    _PrimaryButton(label: l.continueBtn, icon: Icons.arrow_forward_rounded,
                        color: _roleColor, onTap: () => _nextPage(l)),

                    const SizedBox(height: 14),
                    Center(child: GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: RichText(text: TextSpan(children: [
                        TextSpan(text: '${l.alreadyHaveAccount}  ',
                            style: AppTextStyles.body(13, color: DarkColors.muted, context: context)),
                        TextSpan(text: l.signIn,
                            style: AppTextStyles.body(13, color: DarkColors.secondary, weight: FontWeight.w700, context: context)),
                      ])),
                    )),
                  ]),
                ),

                // PAGE 1
                SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    // Faculty + Semester
                    Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        _FieldLabel(l.facultyLabel, context: context),
                        const SizedBox(height: 7),
                        _DropdownField(value: _faculty.isEmpty ? null : _faculty, hint: l.selectFaculty,
                            items: _faculties, accentColor: _roleColor,
                            onChanged: (v) => setState(() => _faculty = v ?? '')),
                      ])),
                      const SizedBox(width: 12),
                      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        _FieldLabel(l.semesterLabel, context: context),
                        const SizedBox(height: 7),
                        _DropdownField(value: _semester, hint: l.semesterHint, items: _semesters,
                            accentColor: _roleColor,
                            onChanged: (v) => setState(() => _semester = v ?? _semester)),
                      ])),
                    ]),

                    const SizedBox(height: 14),

                    // Phone
                    _FieldLabel(l.phoneLabel, context: context),
                    const SizedBox(height: 7),
                    _GlowField(controller: _phoneCtrl, hint: l.phoneHint,
                        prefixIcon: Icons.phone_outlined, accentColor: _roleColor,
                        keyboardType: TextInputType.phone,
                        onChanged: (_) => setState(() => _error = null)),

                    const SizedBox(height: 14),

                    // Password
                    _FieldLabel(l.passwordLabel, context: context),
                    const SizedBox(height: 7),
                    _GlowField(controller: _passCtrl, hint: l.passwordHint2,
                        prefixIcon: Icons.lock_outline, accentColor: _roleColor,
                        obscure: _obscureP,
                        suffixIcon: _obscureP ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                        onSuffixTap: () => setState(() => _obscureP = !_obscureP),
                        onChanged: (_) => setState(() => _error = null)),

                    const SizedBox(height: 14),

                    // Confirm password
                    _FieldLabel(l.confirmPasswordLabel, context: context),
                    const SizedBox(height: 7),
                    _GlowField(controller: _confirmCtrl, hint: l.confirmPasswordHint,
                        prefixIcon: Icons.lock_outline, accentColor: _roleColor,
                        obscure: _obscureC,
                        suffixIcon: _obscureC ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                        onSuffixTap: () => setState(() => _obscureC = !_obscureC),
                        onChanged: (_) => setState(() => _error = null),
                        onSubmitted: (_) => _submit(l)),

                    if (_error != null) ...[const SizedBox(height: 14), _ErrorBanner(_error!)],

                    const SizedBox(height: 22),

                    // Submit
                    AnimatedBuilder(
                      animation: _glowAnim,
                      builder: (_, __) => GestureDetector(
                        onTap: _loading ? null : () => _submit(l),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          width: double.infinity, height: 56,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: _loading
                                  ? [DarkColors.muted, DarkColors.muted]
                                  : [_roleColor, _roleColor.withValues(alpha: 0.75)],
                            ),
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: _loading ? [] : [BoxShadow(
                              color: _roleColor.withValues(alpha: 0.45 * _glowAnim.value),
                              blurRadius: 24 * _glowAnim.value, spreadRadius: 1,
                              offset: const Offset(0, 4),
                            )],
                          ),
                          child: Center(child: _loading
                            ? const SizedBox(width: 24, height: 24,
                                child: CircularProgressIndicator(strokeWidth: 2.5,
                                    valueColor: AlwaysStoppedAnimation(Colors.white)))
                            : Row(mainAxisSize: MainAxisSize.min, children: [
                                Icon(_roles.firstWhere((r) => r.role == _role).icon,
                                    color: Colors.white, size: 19),
                                const SizedBox(width: 8),
                                Flexible(
                                  child: Text(
                                    '${l.joinAs} ${_roles.firstWhere((r) => r.role == _role).localizedLabel(l)}',
                                    style: AppTextStyles.body(16, color: Colors.white, weight: FontWeight.w800, context: context),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ]),
                          ),
                        ),
                      ),
                    ),
                  ]),
                ),
              ],
            ),
          ),
        ]),
      ),
    );
  }
}

// ── Helpers ───────────────────────────────────────────────────────────────────

class _BackButton extends StatelessWidget {
  final VoidCallback onTap;
  const _BackButton({required this.onTap});
  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      width: 38, height: 38,
      decoration: BoxDecoration(
        color: DarkColors.surface,
        borderRadius: BorderRadius.circular(11),
        border: Border.all(color: DarkColors.border),
      ),
      child: const Center(child: Icon(Icons.arrow_back_ios_new, color: DarkColors.muted, size: 15)),
    ),
  );
}

class _StepDots extends StatelessWidget {
  final int current;
  final Color color;
  const _StepDots({required this.current, required this.color});
  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: List.generate(2, (i) {
      final active = i == current;
      return AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        margin: const EdgeInsets.only(left: 5),
        width: active ? 20 : 7, height: 7,
        decoration: BoxDecoration(
          color: active ? color : DarkColors.border,
          borderRadius: BorderRadius.circular(4),
        ),
      );
    }),
  );
}

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text, {required this.context});
  final BuildContext context;
  @override
  Widget build(BuildContext context) => Text(text,
      style: AppTextStyles.label(color: DarkColors.muted, context: context));
}

class _FieldLabel extends StatelessWidget {
  final String text;
  const _FieldLabel(this.text, {required this.context});
  final BuildContext context;
  @override
  Widget build(BuildContext context) => Text(
    text.toUpperCase(),
    style: AppTextStyles.label(color: DarkColors.muted, context: context)
        .copyWith(fontSize: 10, letterSpacing: 1.1),
  );
}

class _ErrorBanner extends StatelessWidget {
  final String message;
  const _ErrorBanner(this.message);
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
    decoration: BoxDecoration(
      color: DarkColors.error.withValues(alpha: 0.09),
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: DarkColors.error.withValues(alpha: 0.35)),
    ),
    child: Row(children: [
      const Icon(Icons.error_outline_rounded, color: DarkColors.error, size: 18),
      const SizedBox(width: 9),
      Expanded(child: Text(message, style: AppTextStyles.body(13, color: DarkColors.error, context: context))),
    ]),
  );
}

class _PrimaryButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  const _PrimaryButton({required this.label, required this.icon, required this.color, required this.onTap});
  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      width: double.infinity, height: 54,
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [color, color.withValues(alpha: 0.75)]),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        Text(label, style: AppTextStyles.body(16, color: Colors.white, weight: FontWeight.w700, context: context)),
        const SizedBox(width: 8),
        Icon(icon, color: Colors.white, size: 18),
      ]),
    ),
  );
}

class _RoleMeta {
  final UserRole role;
  final String label;
  const _RoleMeta({required this.role, required this.label});
  IconData get icon => role.icon;
  String localizedLabel(AppLocalizations l) => switch (role) {
    UserRole.student => l.roleStudent,
    UserRole.coach   => l.roleCoach,
    UserRole.admin   => l.roleAdmin,
  };
  String localizedDesc(AppLocalizations l) => switch (role) {
    UserRole.student => l.roleStudentDesc,
    UserRole.coach   => l.roleCoachDesc,
    UserRole.admin   => l.roleAdminDesc,
  };
}

class _GlowField extends StatefulWidget {
  final TextEditingController controller;
  final String hint;
  final IconData prefixIcon;
  final Color accentColor;
  final bool obscure;
  final IconData? suffixIcon;
  final VoidCallback? onSuffixTap;
  final TextInputType? keyboardType;
  final TextCapitalization textCapitalization;
  final ValueChanged<String>? onChanged, onSubmitted;
  const _GlowField({
    required this.controller, required this.hint, required this.prefixIcon,
    required this.accentColor, this.obscure = false, this.suffixIcon,
    this.onSuffixTap, this.keyboardType,
    this.textCapitalization = TextCapitalization.none,
    this.onChanged, this.onSubmitted,
  });
  @override State<_GlowField> createState() => _GlowFieldState();
}
class _GlowFieldState extends State<_GlowField> {
  bool _focused = false;
  @override
  Widget build(BuildContext context) => AnimatedContainer(
    duration: const Duration(milliseconds: 200),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(14),
      boxShadow: _focused ? [BoxShadow(color: widget.accentColor.withValues(alpha: 0.25),
          blurRadius: 16, spreadRadius: 1)] : [],
    ),
    child: Focus(
      onFocusChange: (f) => setState(() => _focused = f),
      child: TextField(
        controller: widget.controller, obscureText: widget.obscure,
        keyboardType: widget.keyboardType,
        textCapitalization: widget.textCapitalization,
        style: AppTextStyles.body(15, color: DarkColors.text, context: context),
        onChanged: widget.onChanged, onSubmitted: widget.onSubmitted,
        decoration: InputDecoration(
          hintText: widget.hint,
          hintStyle: AppTextStyles.body(14, color: DarkColors.muted.withValues(alpha: 0.6), context: context),
          prefixIcon: Icon(widget.prefixIcon,
              color: _focused ? widget.accentColor : DarkColors.muted, size: 20),
          suffixIcon: widget.suffixIcon != null
              ? GestureDetector(onTap: widget.onSuffixTap,
                  child: Icon(widget.suffixIcon, color: DarkColors.muted, size: 20))
              : null,
          filled: true, fillColor: DarkColors.surface,
          contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: DarkColors.border)),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: widget.accentColor, width: 1.6)),
        ),
      ),
    ),
  );
}

class _DropdownField extends StatelessWidget {
  final String? value;
  final String hint;
  final List<String> items;
  final Color accentColor;
  final void Function(String?) onChanged;
  const _DropdownField({required this.value, required this.hint, required this.items,
      required this.accentColor, required this.onChanged});
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
    decoration: BoxDecoration(
      color: DarkColors.surface,
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: DarkColors.border),
    ),
    child: DropdownButtonHideUnderline(
      child: DropdownButton<String>(
        value: value, hint: Text(hint, style: AppTextStyles.body(14, color: DarkColors.muted, context: context)),
        style: AppTextStyles.body(14, color: DarkColors.text, context: context),
        dropdownColor: DarkColors.surface2, isExpanded: true,
        icon: const Icon(Icons.keyboard_arrow_down_rounded, color: DarkColors.muted, size: 20),
        items: items.map((i) => DropdownMenuItem(value: i,
            child: Text(i, style: AppTextStyles.body(14, color: DarkColors.text, context: context)))).toList(),
        onChanged: onChanged,
      ),
    ),
  );
}
