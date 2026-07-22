import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/state/app_state.dart';
import '../../../l10n/app_localizations.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});
  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _emailCtrl = TextEditingController();
  bool   _loading  = false;
  bool   _sent     = false;
  String? _error;

  @override
  void dispose() { _emailCtrl.dispose(); super.dispose(); }

  Future<void> _send(AppLocalizations l) async {
    final email = _emailCtrl.text.trim();
    if (!email.contains('@') || !email.contains('.')) {
      setState(() => _error = l.errorInvalidEmail); return;
    }
    setState(() { _loading = true; _error = null; });
    final err = await context.read<AppState>().sendPasswordReset(email);
    if (!mounted) return;
    setState(() { _loading = false; });
    if (err != null) {
      setState(() => _error = switch (err) {
        'noAccountFound' => l.errorNoAccount,
        'invalidEmail'   => l.errorInvalidEmail,
        _                => l.errorGeneric,
      });
    } else {
      setState(() => _sent = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: DarkColors.bg,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  width: 40, height: 40,
                  decoration: BoxDecoration(
                    color: DarkColors.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: DarkColors.border),
                  ),
                  child: Center(child: Icon(
                      Directionality.of(context) == TextDirection.ltr 
                          ? Icons.arrow_back_ios_new 
                          : Icons.arrow_forward_ios,
                      color: DarkColors.muted, size: 16)),
                ),
              ),
              const SizedBox(height: 32),

              if (_sent) ...[
                const Icon(Icons.mark_email_read_rounded, size: 48, color: Color(0xFF00E5FF)),
                const SizedBox(height: 16),
                Text(l.checkEmail,
                    style: AppTextStyles.display(26, color: DarkColors.secondary, context: context)),
                const SizedBox(height: 12),
                Text(l.resetLinkSent(_emailCtrl.text.trim()),
                    style: AppTextStyles.body(15, color: DarkColors.muted, context: context)),
                const SizedBox(height: 32),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    width: double.infinity, height: 56,
                    decoration: BoxDecoration(
                      color: DarkColors.secondary.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: DarkColors.secondary.withValues(alpha: 0.4)),
                    ),
                    child: Center(child: Text(l.backToSignIn,
                        style: AppTextStyles.body(16, color: DarkColors.secondary,
                            weight: FontWeight.w700, context: context))),
                  ),
                ),
              ] else ...[
                Text(l.forgotPasswordTitle,
                    style: AppTextStyles.display(28, color: DarkColors.text, context: context)),
                const SizedBox(height: 8),
                Text(l.forgotPasswordSubtitle,
                    style: AppTextStyles.body(14, color: DarkColors.muted, context: context)),
                const SizedBox(height: 32),

                Text(l.universityEmailLabel,
                    style: AppTextStyles.label(color: DarkColors.muted, context: context)),
                const SizedBox(height: 10),
                TextField(
                  controller: _emailCtrl,
                  keyboardType: TextInputType.emailAddress,
                  style: AppTextStyles.body(15, color: DarkColors.text, context: context),
                  onSubmitted: (_) => _send(l),
                  decoration: InputDecoration(
                    hintText: l.emailHint,
                    hintStyle: AppTextStyles.body(14, color: DarkColors.muted, context: context),
                    prefixIcon: const Icon(Icons.email_outlined, color: DarkColors.muted, size: 22),
                    filled: true, fillColor: DarkColors.surface,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                    enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: const BorderSide(color: DarkColors.border)),
                    focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: const BorderSide(color: DarkColors.secondary, width: 1.8)),
                  ),
                ),

                if (_error != null) ...[
                  const SizedBox(height: 14),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    decoration: BoxDecoration(
                      color: DarkColors.error.withValues(alpha: 0.10),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: DarkColors.error.withValues(alpha: 0.35)),
                    ),
                    child: Row(children: [
                      const Icon(Icons.error_outline, color: DarkColors.error, size: 18),
                      const SizedBox(width: 10),
                      Expanded(child: Text(_error!,
                          style: AppTextStyles.body(13, color: DarkColors.error, context: context))),
                    ]),
                  ),
                ],
                const SizedBox(height: 28),
                GestureDetector(
                  onTap: _loading ? null : () => _send(l),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: double.infinity, height: 58,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: _loading
                            ? [DarkColors.muted, DarkColors.muted]
                            : [DarkColors.secondary, const Color(0xFF7ACC2A)],
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Center(
                      child: _loading
                          ? const SizedBox(width: 24, height: 24,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                  valueColor: AlwaysStoppedAnimation(Color(0xFF0a1a04))))
                          : Text(l.sendResetLink,
                              style: AppTextStyles.body(16,
                                  color: const Color(0xFF0a1a04), weight: FontWeight.w800, context: context)),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
