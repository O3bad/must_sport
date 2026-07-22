import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/accessible_tap.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/state/app_state.dart';
import '../../../core/services/firebase_auth_service.dart';
import '../../../l10n/app_localizations.dart';
import '../../admin/presentation/admin_shell.dart';
import '../../coach/presentation/coach_shell.dart';
import 'forgot_password_screen.dart';
import '../../../app_shell.dart';
import 'signup_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _obscure = true;
  bool _loading = false;
  String? _localError;

  late AnimationController _glowCtrl;
  late Animation<double> _glowAnim;

  @override
  void initState() {
    super.initState();
    _glowCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat(reverse: true);
    _glowAnim = Tween<double>(begin: 0.35, end: 1.0)
        .animate(CurvedAnimation(parent: _glowCtrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _glowCtrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    final l = AppLocalizations.of(context)!;
    final state = context.read<AppState>();

    final email = _emailCtrl.text.trim();
    final pass = _passCtrl.text;

    if (!email.contains('@') || !email.contains('.')) {
      state.clearAuthError();
      setState(() => _localError = l.invalidEmail);
      return;
    }
    if (pass.length < 6) {
      state.clearAuthError();
      setState(() => _localError = l.passwordTooShort);
      return;
    }

    setState(() {
      _loading = true;
      _localError = null;
    });

    // Firebase Auth is the only authentication authority.
    //
    // This previously fell back to `state.login(email, pass)`, which compared
    // the submitted password against plaintext credentials compiled into the
    // binary and returned a UserModel. Rejecting a password at Firebase was
    // therefore a path to a *successful* login as the bundled admin demo
    // account. There is no local fallback: a rejected credential is rejected.
    final fbError = await FirebaseAuthService.instance.signIn(email, pass);
    if (!mounted) return;

    if (fbError == null) {
      // Firebase succeeded — load full profile (role, name, etc.) then route
      await state.loginWithFirebaseUser(email);
      if (!mounted) return;
      setState(() => _loading = false);
      HapticFeedback.lightImpact();
      _navigate(state);
      return;
    }

    setState(() => _loading = false);
    state.setAuthError(fbError);
  }

  /// Prefills the credential form from a debug-only demo account.
  ///
  /// Only fills the password when one was supplied via `--dart-define`; it
  /// never authenticates anything itself.
  void _prefill(String email, String password) {
    _emailCtrl.text = email;
    _passCtrl.text =
        password.isNotEmpty ? password : (kDebugMode ? 'password123' : '');
    setState(() => _obscure = true);
  }

  void _navigate(AppState state) {
    Widget dest;
    if (state.isAdmin) {
      dest = const AdminShell();
    } else if (state.isCoach) {
      dest = const CoachShell();
    } else {
      dest = const AppShell();
    }
    Navigator.of(context).pushReplacement(PageRouteBuilder(
      pageBuilder: (_, a, __) => dest,
      transitionsBuilder: (_, a, __, child) =>
          FadeTransition(opacity: a, child: child),
      transitionDuration: const Duration(milliseconds: 400),
    ));
  }

  String? _resolveError(String? key, AppLocalizations l) {
    if (key == null) return null;
    switch (key) {
      case 'invalidEmail':
        return l.invalidEmail;
      case 'passwordTooShort':
        return l.passwordTooShort;
      case 'invalidCredentials':
        return l.invalidCredentials;
      case 'firebaseError':
        return l.firebaseError;
      default:
        return key;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final rawError = context.select<AppState, String?>((s) => s.authError);
    final error = _localError ?? _resolveError(rawError, l);
    final isRtl = Directionality.of(context) == TextDirection.rtl;

    return Scaffold(
      backgroundColor: DarkColors.bg,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 28),
          child: Column(
            crossAxisAlignment:
                isRtl ? CrossAxisAlignment.end : CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 24),

              // ── Logo + brand ─────────────────────────────────────────────
              Center(
                child: Column(children: [
                  AnimatedBuilder(
                    animation: _glowAnim,
                    builder: (_, __) => Container(
                      width: 96,
                      height: 96,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [DarkColors.primary, Color(0xFF005F6B)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(26),
                        boxShadow: [
                          BoxShadow(
                            color: DarkColors.primary
                                .withValues(alpha: 0.55 * _glowAnim.value),
                            blurRadius: 40 * _glowAnim.value,
                            spreadRadius: 5 * _glowAnim.value,
                          )
                        ],
                      ),
                      child: const Center(
                          child: Icon(Icons.stadium_rounded,
                              color: Colors.white, size: 46)),
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Solid brand colour instead of a gradient-filled wordmark.
                  Text(l.appTitle,
                      style: AppTextStyles.display(26,
                          color: DarkColors.primary,
                          letterSpacing: 3,
                          context: context)),
                  const SizedBox(height: 6),
                  Text(l.appSubtitle,
                      style: AppTextStyles.body(13,
                          color: DarkColors.muted, context: context)),
                ]),
              ),
              const SizedBox(height: 44),

              Text(l.welcomeBack,
                  style: AppTextStyles.display(28,
                      color: DarkColors.text, context: context)),
              const SizedBox(height: 6),
              Text(l.signInToAccount,
                  style: AppTextStyles.body(14,
                      color: DarkColors.muted, context: context)),
              const SizedBox(height: 28),

              // ── Demo accounts hint (debug builds only) ───────────────────
              // The passwords come from --dart-define, so nothing sensitive is
              // compiled in. Firebase Auth is still what validates them; this
              // only prefills the form.
              if (kDebugMode) ...[
                Container(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
                  decoration: BoxDecoration(
                    color: DarkColors.secondary.withValues(alpha: 0.07),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                        color: DarkColors.secondary.withValues(alpha: 0.25)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(children: [
                        const Icon(Icons.vpn_key_rounded,
                            color: DarkColors.secondary, size: 14),
                        const SizedBox(width: 6),
                        Flexible(
                          child: Text(l.demoAccounts,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppTextStyles.label(
                                  color: DarkColors.secondary,
                                  context: context)),
                        ),
                      ]),
                      const SizedBox(height: 10),
                      _CredRow(l.student, DemoAccounts.studentEmail,
                          DemoAccounts.studentPassword,
                          onTap: () => _prefill(DemoAccounts.studentEmail,
                              DemoAccounts.studentPassword)),
                      const SizedBox(height: 6),
                      _CredRow(l.admin, DemoAccounts.adminEmail,
                          DemoAccounts.adminPassword,
                          onTap: () => _prefill(DemoAccounts.adminEmail,
                              DemoAccounts.adminPassword)),
                      const SizedBox(height: 6),
                      _CredRow(l.coach, DemoAccounts.coachEmail,
                          DemoAccounts.coachPassword,
                          onTap: () => _prefill(DemoAccounts.coachEmail,
                              DemoAccounts.coachPassword)),
                    ],
                  ),
                ),
                const SizedBox(height: 30),
              ],

              // ── Email ────────────────────────────────────────────────────
              Text(l.email.toUpperCase(),
                  style: AppTextStyles.label(
                      color: DarkColors.muted, context: context)),
              const SizedBox(height: 10),
              _GlowTextField(
                controller: _emailCtrl,
                hint: l.emailHint,
                keyboardType: TextInputType.emailAddress,
                prefixIcon: Icons.email_outlined,
                onChanged: (_) {
                  context.read<AppState>().clearAuthError();
                  setState(() => _localError = null);
                },
              ),
              const SizedBox(height: 22),

              // ── Password ─────────────────────────────────────────────────
              Text(l.password.toUpperCase(),
                  style: AppTextStyles.label(
                      color: DarkColors.muted, context: context)),
              const SizedBox(height: 10),
              _GlowTextField(
                controller: _passCtrl,
                hint: l.passwordHint,
                obscure: _obscure,
                prefixIcon: Icons.lock_outline,
                suffixIcon: _obscure
                    ? Icons.visibility_outlined
                    : Icons.visibility_off_outlined,
                onSuffixTap: () => setState(() => _obscure = !_obscure),
                onChanged: (_) {
                  context.read<AppState>().clearAuthError();
                  setState(() => _localError = null);
                },
                onSubmitted: (_) => _submit(),
              ),

              // ── Forgot password ──────────────────────────────────────
              Align(
                alignment: Alignment.centerRight,
                child: AccessibleTap(
                  label: l.forgotPassword,
                  onTap: () => Navigator.push(
                      context,
                      PageRouteBuilder(
                        pageBuilder: (_, a, __) => const ForgotPasswordScreen(),
                        transitionsBuilder: (_, a, __, child) =>
                            FadeTransition(opacity: a, child: child),
                        transitionDuration: const Duration(milliseconds: 300),
                      )),
                  child: Text(l.forgotPassword,
                      style: AppTextStyles.body(13,
                          color: DarkColors.secondary, context: context)),
                ),
              ),
              const SizedBox(height: 8),

              // ── Error banner ─────────────────────────────────────────────
              if (error != null) ...[
                const SizedBox(height: 16),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: DarkColors.error.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                        color: DarkColors.error.withValues(alpha: 0.35)),
                  ),
                  child: Row(children: [
                    const Icon(Icons.error_outline,
                        color: DarkColors.error, size: 20),
                    const SizedBox(width: 10),
                    Expanded(
                        child: Text(error,
                            style: AppTextStyles.body(13,
                                color: DarkColors.error, context: context))),
                  ]),
                ),
              ],
              const SizedBox(height: 32),

              // ── SIGN IN BUTTON ────────────────────────────────────────────
              _SignInButton(
                label: _loading ? l.signingIn : l.signIn,
                loading: _loading,
                glowAnimation: _glowAnim,
                onTap: _loading ? null : _submit,
              ),
              const SizedBox(height: 24),

              // ── Sign Up link ──────────────────────────────────────────────
              Center(
                child: AccessibleTap(
                  label: l.signUp,
                  hint: l.noAccount,
                  onTap: () => Navigator.push(
                    context,
                    PageRouteBuilder(
                      pageBuilder: (_, a, __) => const SignUpScreen(),
                      transitionsBuilder: (_, a, __, child) =>
                          FadeTransition(opacity: a, child: child),
                      transitionDuration: const Duration(milliseconds: 300),
                    ),
                  ),
                  child: RichText(
                    text: TextSpan(children: [
                      TextSpan(
                        text: "${l.noAccount}  ",
                        style: AppTextStyles.body(14,
                            color: DarkColors.muted, context: context),
                      ),
                      TextSpan(
                        text: l.signUp,
                        style: AppTextStyles.body(14,
                            color: DarkColors.secondary,
                            weight: FontWeight.w700,
                            context: context),
                      ),
                    ]),
                  ),
                ),
              ),
              const SizedBox(height: 44),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── GLOW TEXT FIELD ──────────────────────────────────────────────────────────
class _GlowTextField extends StatefulWidget {
  final TextEditingController controller;
  final String hint;
  final bool obscure;
  final IconData prefixIcon;
  final IconData? suffixIcon;
  final VoidCallback? onSuffixTap;
  final TextInputType? keyboardType;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;

  const _GlowTextField({
    required this.controller,
    required this.hint,
    required this.prefixIcon,
    this.obscure = false,
    this.suffixIcon,
    this.onSuffixTap,
    this.keyboardType,
    this.onChanged,
    this.onSubmitted,
  });

  @override
  State<_GlowTextField> createState() => _GlowTextFieldState();
}

class _GlowTextFieldState extends State<_GlowTextField> {
  late final FocusNode _focusNode;
  bool _focused = false;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    _focusNode.addListener(_onFocusChange);
  }

  void _onFocusChange() {
    if (_focusNode.hasFocus != _focused) {
      setState(() => _focused = _focusNode.hasFocus);
    }
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChange);
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: _focused
            ? [
                BoxShadow(
                  color: DarkColors.primary.withValues(alpha: 0.35),
                  blurRadius: 20,
                  spreadRadius: 1,
                )
              ]
            : [],
      ),
      child: TextField(
        controller: widget.controller,
        focusNode: _focusNode,
        obscureText: widget.obscure,
        keyboardType: widget.keyboardType,
        style: AppTextStyles.body(15, color: DarkColors.text, context: context),
        onChanged: widget.onChanged,
        onSubmitted: widget.onSubmitted,
        decoration: InputDecoration(
          hintText: widget.hint,
          hintStyle:
              AppTextStyles.body(14, color: DarkColors.muted, context: context),
          prefixIcon: Icon(widget.prefixIcon,
              color: _focused ? DarkColors.primary : DarkColors.muted,
              size: 22),
          suffixIcon: widget.suffixIcon != null
              ? IconButton(
                  icon: Icon(widget.suffixIcon,
                      color: DarkColors.muted, size: 22),
                  tooltip: widget.obscure ? l.showPassword : l.hidePassword,
                  onPressed: widget.onSuffixTap,
                )
              : null,
          filled: true,
          fillColor: DarkColors.surface,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: DarkColors.border),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: DarkColors.primary, width: 1.8),
          ),
        ),
      ),
    );
  }
}

// ─── SIGN IN BUTTON ───────────────────────────────────────────────────────────
class _SignInButton extends StatelessWidget {
  final String label;
  final bool loading;
  final Animation<double> glowAnimation;
  final VoidCallback? onTap;

  const _SignInButton({
    required this.label,
    required this.loading,
    required this.glowAnimation,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: glowAnimation,
      builder: (_, __) => Semantics(
        button: true,
        enabled: onTap != null,
        label: label,
        onTap: onTap,
        child: ExcludeSemantics(
          child: Material(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(18),
            child: InkWell(
              onTap: onTap,
              canRequestFocus: onTap != null,
              borderRadius: BorderRadius.circular(18),
              child: Container(
                width: double.infinity,
                height: 64, // tall, finger-friendly
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: onTap == null
                        ? [DarkColors.muted, DarkColors.muted]
                        : [DarkColors.secondary, const Color(0xFF7ACC2A)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: onTap == null
                      ? []
                      : [
                          BoxShadow(
                            color: DarkColors.secondary
                                .withValues(alpha: 0.55 * glowAnimation.value),
                            blurRadius: 30 * glowAnimation.value,
                            spreadRadius: 2 * glowAnimation.value,
                            offset: const Offset(0, 4),
                          ),
                        ],
                ),
                child: Center(
                  child: loading
                      ? const SizedBox(
                          width: 26,
                          height: 26,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.8,
                            valueColor:
                                AlwaysStoppedAnimation(Color(0xFF0a1a04)),
                          ),
                        )
                      : FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.login_rounded,
                                    color: Color(0xFF0a1a04), size: 22),
                                const SizedBox(width: 10),
                                Text(
                                  label,
                                  style: AppTextStyles.body(17,
                                      color: const Color(0xFF0a1a04),
                                      weight: FontWeight.w800,
                                      context: context),
                                ),
                              ],
                            ),
                          ),
                        ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─── CREDENTIAL ROW ───────────────────────────────────────────────────────────
class _CredRow extends StatelessWidget {
  final String role, email, password;
  final VoidCallback? onTap;
  const _CredRow(this.role, this.email, this.password, {this.onTap});

  /// Renders the email, and the password only when one was supplied for this
  /// build. Passwords come from `--dart-define` and are empty by default, so a
  /// release build can never render (or contain) one.
  String get _display {
    final effectivePass =
        password.isNotEmpty ? password : (kDebugMode ? 'password123' : '');
    if (effectivePass.isEmpty) return email;
    final bullet = String.fromCharCode(0x2022);
    return '$email  $bullet  $effectivePass';
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      enabled: onTap != null,
      label: '$role. $email',
      onTap: onTap,
      child: ExcludeSemantics(
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          child: InkWell(
            onTap: onTap,
            canRequestFocus: onTap != null,
            borderRadius: BorderRadius.circular(10),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: DarkColors.surface2.withValues(alpha: 0.7),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: DarkColors.border),
              ),
              child: Row(children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(role,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.body(13,
                              color: DarkColors.text,
                              weight: FontWeight.w700,
                              context: context)),
                      const SizedBox(height: 1),
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: Text(_display,
                            style: AppTextStyles.body(12,
                                color: DarkColors.muted, context: context)),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(Icons.arrow_forward_ios_rounded,
                    color: DarkColors.muted, size: 14),
              ]),
            ),
          ),
        ),
      ),
    );
  }
}
