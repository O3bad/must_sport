// lib/features/auth/auth_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../l10n/app_localizations.dart';
import '../../core/theme/app_theme.dart';
import '../../core/constants/app_constants.dart';
import 'bloc/auth_bloc.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});
  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen>
    with SingleTickerProviderStateMixin {
  bool _isLogin = true;
  bool _obscure = true;
  String _selectedRole = UserRoles.student;

  final _formKey       = GlobalKey<FormState>();
  final _emailCtrl     = TextEditingController();
  final _passCtrl      = TextEditingController();
  final _nameCtrl      = TextEditingController();
  final _studentIdCtrl = TextEditingController();

  late AnimationController _glowCtrl;
  late Animation<double>   _glowAnim;

  @override
  void initState() {
    super.initState();
    _glowCtrl = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 2200),
    )..repeat(reverse: true);
    _glowAnim = Tween<double>(begin: 0.35, end: 1.0)
        .animate(CurvedAnimation(parent: _glowCtrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _glowCtrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _nameCtrl.dispose();
    _studentIdCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;
    final bloc = context.read<AuthBloc>();
    if (_isLogin) {
      bloc.add(AuthSignInRequested(
        email: _emailCtrl.text.trim(),
        password: _passCtrl.text,
      ));
    } else {
      bloc.add(AuthRegisterRequested(
        email:     _emailCtrl.text.trim(),
        password:  _passCtrl.text,
        name:      _nameCtrl.text.trim(),
        nameAr:    '',
        role:      _selectedRole,
        studentId: _selectedRole == UserRoles.student
            ? _studentIdCtrl.text.trim()
            : null,
      ));
    }
  }

  void _forgotPassword() {
    if (_emailCtrl.text.trim().isEmpty) {
      _showSnack('Enter your email address first.', DarkColors.accent);
      return;
    }
    context
        .read<AuthBloc>()
        .add(AuthPasswordResetRequested(_emailCtrl.text.trim()));
  }

  void _showSnack(String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg, style: AppTextStyles.body(14, context: context, color: Colors.white)),
      backgroundColor: color,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.all(16),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';

    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthFailure) {
          HapticFeedback.lightImpact();
          _showSnack(state.message, DarkColors.error);
        } else if (state is AuthPasswordResetSent) {
          HapticFeedback.lightImpact();
          _showSnack(
              isArabic ? 'تم إرسال رابط استعادة كلمة المرور!' : 'Password reset email sent! Check your inbox.',
              DarkColors.secondary);
        } else if (state is AuthAuthenticated) {
          ScaffoldMessenger.of(context).clearSnackBars();
        }
      },
      child: Scaffold(
        backgroundColor: DarkColors.bg,
        body: SafeArea(
          child: SingleChildScrollView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            padding: EdgeInsets.fromLTRB(
              28, 28, 28,
              MediaQuery.of(context).viewInsets.bottom + 28,
            ),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),

                  // ── Logo + brand ───────────────────────────
                  Center(
                    child: Column(children: [
                      AnimatedBuilder(
                        animation: _glowAnim,
                        builder: (_, __) => Container(
                          width: 88, height: 88,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [DarkColors.primary, Color(0xFF005F6B)],
                              begin: AlignmentDirectional.topStart,
                              end: AlignmentDirectional.bottomEnd,
                            ),
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: [BoxShadow(
                              color: DarkColors.primary
                                  .withValues(alpha: 0.55 * _glowAnim.value),
                              blurRadius: 40 * _glowAnim.value,
                              spreadRadius: 4 * _glowAnim.value,
                            )],
                          ),
                          child: const Center(
                              child: Text('🏟️',
                                  style: TextStyle(fontSize: 42))),
                        ),
                      ),
                      const SizedBox(height: 16),
                      ShaderMask(
                        shaderCallback: (b) => const LinearGradient(
                          colors: [DarkColors.primary, DarkColors.secondary],
                        ).createShader(b),
                        child: Text(isArabic ? 'أنشطة جامعة MUST' : 'MUST Activities',
                            style: AppTextStyles.display(22,
                                context: context,
                                color: Colors.white, letterSpacing: isArabic ? 0 : 2)),
                      ),
                      const SizedBox(height: 4),
                      Text(isArabic ? 'منصة الرياضة والفنون' : 'SPORT & ARTS PLATFORM',
                          style: AppTextStyles.label(context: context, color: DarkColors.muted)
                              .copyWith(fontSize: 11, letterSpacing: isArabic ? 0 : 3)),
                    ]),
                  ),
                  const SizedBox(height: 40),

                  // ── Tab toggle ─────────────────────────────
                  _ModeToggle(
                    isLogin: _isLogin,
                    onToggle: () => setState(() {
                      _isLogin = !_isLogin;
                      _formKey.currentState?.reset();
                    }),
                  ),
                  const SizedBox(height: 28),

                  // ── Sign-up only fields ────────────────────
                  if (!_isLogin) ...[
                    _buildField(
                      controller: _nameCtrl,
                      label: l.fullNameLabel,
                      icon: Icons.person_outline_rounded,
                      validator: (v) =>
                          (v == null || v.trim().isEmpty) ? l.nameCannotBeEmpty : null,
                    ),
                    const SizedBox(height: 14),
                    _RolePicker(
                      selected: _selectedRole,
                      onChanged: (r) =>
                          setState(() => _selectedRole = r),
                    ),
                    const SizedBox(height: 14),
                    if (_selectedRole == UserRoles.student) ...[
                      _buildField(
                        controller: _studentIdCtrl,
                        label: l.studentId,
                        icon: Icons.badge_outlined,
                        keyboardType: TextInputType.number,
                        validator: (v) =>
                            (v == null || v.trim().isEmpty)
                                ? (isArabic ? 'مطلوب' : 'Required')
                                : null,
                      ),
                      const SizedBox(height: 14),
                    ],
                  ],

                  // ── Shared fields ──────────────────────────
                  _buildField(
                    controller: _emailCtrl,
                    label: l.universityEmailLabel,
                    icon: Icons.mail_outline_rounded,
                    keyboardType: TextInputType.emailAddress,
                    validator: (v) =>
                        (v == null || !v.contains('@'))
                            ? l.errorInvalidEmail
                            : null,
                  ),
                  const SizedBox(height: 14),
                  _buildField(
                    controller: _passCtrl,
                    label: l.passwordLabel,
                    icon: Icons.lock_outline_rounded,
                    obscure: _obscure,
                    suffix: IconButton(
                      icon: Icon(
                          _obscure
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                          color: DarkColors.muted,
                          size: 20),
                      onPressed: () =>
                          setState(() => _obscure = !_obscure),
                    ),
                    validator: (v) =>
                        (v == null || v.length < 6)
                            ? l.errorPasswordShort
                            : null,
                  ),

                  if (_isLogin) ...[
                    const SizedBox(height: 10),
                    Align(
                      alignment: isArabic ? Alignment.centerLeft : Alignment.centerRight,
                      child: TextButton(
                        onPressed: _forgotPassword,
                        child: Text(l.forgotPassword,
                            style: AppTextStyles.body(14,
                                context: context,
                                color: DarkColors.primary)),
                      ),
                    ),
                  ],
                  const SizedBox(height: 24),

                  // ── Submit button ──────────────────────────
                  BlocBuilder<AuthBloc, AuthState>(
                    builder: (context, state) {
                      final loading = state is AuthLoading;
                      return _GlowButton(
                        label: _isLogin ? l.signIn : l.createAccount,
                        loading: loading,
                        onPressed: loading ? null : _submit,
                      );
                    },
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool obscure = false,
    Widget? suffix,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      keyboardType: keyboardType,
      style: AppTextStyles.body(15, context: context, color: AppColors.text(context)),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, size: 20),
        suffixIcon: suffix,
      ),
      validator: validator,
    );
  }
}

// ── Mode Toggle ──────────────────────────────────────────────────────────────
class _ModeToggle extends StatelessWidget {
  final bool isLogin;
  final VoidCallback onToggle;
  const _ModeToggle({required this.isLogin, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: DarkColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: DarkColors.border),
      ),
      child: Row(children: [
        _Tab(label: l.signIn,        isActive: isLogin,  onTap: isLogin  ? null : onToggle),
        _Tab(label: l.signUp, isActive: !isLogin, onTap: !isLogin ? null : onToggle),
      ]),
    );
  }
}

class _Tab extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback? onTap;
  const _Tab({required this.label, required this.isActive, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOut,
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isActive
                ? DarkColors.primary.withValues(alpha: 0.15)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            border: isActive
                ? Border.all(color: DarkColors.primary.withValues(alpha: 0.4))
                : Border.all(color: Colors.transparent),
          ),
          child: Center(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(label,
                  maxLines: 1,
                  style: AppTextStyles.body(14,
                      context: context,
                      color: isActive ? DarkColors.primary : DarkColors.muted,
                      weight: FontWeight.w700)),
            ),
          ),
        ),
      ),
    );
  }
}

// ── Role Picker ──────────────────────────────────────────────────────────────
class _RolePicker extends StatelessWidget {
  final String selected;
  final ValueChanged<String> onChanged;
  const _RolePicker({required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final roles = [
      (UserRoles.student, '🎓', l.student),
      (UserRoles.coach,   '🏋️', l.coach),
      (UserRoles.admin,   '⚙️',  l.admin),
    ];
    return Row(
      children: roles.map((r) {
        final isActive = selected == r.$1;
        return Expanded(
          child: GestureDetector(
            onTap: () => onChanged(r.$1),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.symmetric(horizontal: 4),
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: isActive
                    ? DarkColors.primary.withValues(alpha: 0.12)
                    : DarkColors.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isActive
                      ? DarkColors.primary.withValues(alpha: 0.5)
                      : DarkColors.border,
                ),
              ),
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                Text(r.$2, style: const TextStyle(fontSize: 20)),
                const SizedBox(height: 4),
                Text(r.$3,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                    style: AppTextStyles.label(
                        context: context,
                        color: isActive
                            ? DarkColors.primary
                            : DarkColors.muted,
                        size: 11)),
              ]),
            ),
          ),
        );
      }).toList(),
    );
  }
}

// ── Glow Button ──────────────────────────────────────────────────────────────
class _GlowButton extends StatelessWidget {
  final String label;
  final bool loading;
  final VoidCallback? onPressed;
  const _GlowButton(
      {required this.label, required this.loading, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        height: 54,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [DarkColors.primary, Color(0xFF0097A7)],
            begin: AlignmentDirectional.centerStart,
            end: AlignmentDirectional.centerEnd,
          ),
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: DarkColors.primary
                  .withValues(alpha: onPressed != null ? 0.35 : 0.1),
              blurRadius: 20,
              spreadRadius: 0,
            ),
          ],
        ),
        child: Center(
          child: loading
              ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                      color: Colors.white, strokeWidth: 2.5))
              : Text(label,
                  style: AppTextStyles.body(16,
                      context: context,
                      color: DarkColors.bg, weight: FontWeight.w700)),
        ),
      ),
    );
  }
}
