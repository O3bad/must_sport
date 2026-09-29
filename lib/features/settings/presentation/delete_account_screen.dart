import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/theme/widgets.dart';
import '../../../core/state/app_state.dart';
import '../../../l10n/app_localizations.dart';

/// Two-step account deletion.
///
/// Google Play's Data Safety section requires an in-app path to permanently
/// delete an account. This screen enforces deliberate intent: the user types
/// DELETE to unlock the destructive button, then re-authenticates with their
/// password so a hijacked session cannot destroy the account.
class DeleteAccountScreen extends StatefulWidget {
  const DeleteAccountScreen({super.key});

  @override
  State<DeleteAccountScreen> createState() => _DeleteAccountScreenState();
}

class _DeleteAccountScreenState extends State<DeleteAccountScreen> {
  final _confirmCtrl = TextEditingController();
  final _passCtrl = TextEditingController();

  bool _armed = false; // the DELETE word has been typed
  bool _busy = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _confirmCtrl.addListener(() {
      final armed = _confirmCtrl.text.trim() == _confirmWord;
      if (armed != _armed) setState(() => _armed = armed);
    });
  }

  @override
  void dispose() {
    _confirmCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  String get _confirmWord =>
      AppLocalizations.of(context)!.deleteAccountConfirmWord;

  Future<void> _delete(AppLocalizations l) async {
    if (!_armed) return;
    if (_passCtrl.text.isEmpty) {
      setState(() => _error = l.deleteAccountPasswordPrompt);
      return;
    }

    setState(() {
      _busy = true;
      _error = null;
    });

    final appState = context.read<AppState>();
    final reason = await appState.deleteMyAccount(_passCtrl.text);
    if (!mounted) return;

    if (reason == null) {
      _showResult(l.deleteAccountSuccess, isError: false);
      return;
    }

    setState(() {
      _busy = false;
      _error = switch (reason) {
        'wrongPassword' || 'reauthFailed' => l.errorGeneric,
        'dataDeletionFailed' => l.deleteAccountDataRemovalFailed,
        _ => l.deleteAccountFailed(reason),
      };
    });
  }

  void _showResult(String message, {required bool isError}) {
    final l = AppLocalizations.of(context)!;
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogCtx) => AlertDialog(
        backgroundColor: dialogCtx.surfaceColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        icon: Icon(
          isError ? Icons.error_outline : Icons.check_circle_outline,
          color: isError ? dialogCtx.errorColor : context.secondaryColor,
          size: 34,
        ),
        title: Text(
          isError ? l.errorGeneric : l.deleteAccountSectionTitle,
          style: AppTextStyles.heading(17,
              color: dialogCtx.textColor, context: dialogCtx),
          textAlign: TextAlign.center,
        ),
        content: Text(
          message,
          style: AppTextStyles.body(14,
              color: dialogCtx.mutedColor, context: dialogCtx),
          textAlign: TextAlign.center,
        ),
        actions: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.of(dialogCtx).pop();
                // Return to the sign-in screen — the session no longer exists.
                Navigator.of(context).popUntil((r) => r.isFirst);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: context.primaryColor,
                foregroundColor: onFillFor(context, context.primaryColor),
                padding: const EdgeInsets.symmetric(vertical: 13),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(13),
                ),
              ),
              child: Text(
                l.ok,
                style: AppTextStyles.body(15,
                    weight: FontWeight.w700,
                    color: onFillFor(context, context.primaryColor),
                    context: context),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final destructive = context.errorColor;
    final fill = context.onFillColor;

    return Scaffold(
      backgroundColor: context.bgColor,
      appBar: AppBar(
        backgroundColor: context.bgColor,
        surfaceTintColor: Colors.transparent,
        title: Text(l.deleteAccount,
            style: AppTextStyles.heading(18,
                color: context.textColor, context: context)),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Divider(height: 1, color: context.borderColor),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
        children: [
          // Consequence banner
          Semantics(
            liveRegion: true,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: destructive.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: destructive.withValues(alpha: 0.40)),
              ),
              child:
                  Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Icon(Icons.warning_amber_rounded, color: destructive, size: 22),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(l.deleteAccountWarning,
                      style: AppTextStyles.body(13,
                          color: destructive, context: context)),
                ),
              ]),
            ),
          ),
          const SizedBox(height: 28),

          Text(l.deleteAccountTypeToConfirm,
              style: AppTextStyles.label(
                  color: context.mutedColor, context: context)),
          const SizedBox(height: 8),
          TextField(
            controller: _confirmCtrl,
            autocorrect: false,
            enableSuggestions: false,
            textCapitalization: TextCapitalization.characters,
            style: AppTextStyles.body(16,
                color: context.textColor, context: context),
            decoration: _inputDec(context, l.deleteAccountConfirmWord),
          ),
          const SizedBox(height: 20),

          Text(l.deleteAccountPasswordPrompt,
              style: AppTextStyles.label(
                  color: context.mutedColor, context: context)),
          const SizedBox(height: 8),
          TextField(
            controller: _passCtrl,
            obscureText: true,
            style: AppTextStyles.body(16,
                color: context.textColor, context: context),
            decoration: _inputDec(context, l.passwordHint2),
          ),

          if (_error != null) ...[
            const SizedBox(height: 16),
            Semantics(
              liveRegion: true,
              child: Text(
                _error!,
                style: AppTextStyles.body(13,
                    color: destructive, context: context),
              ),
            ),
          ],

          const SizedBox(height: 32),

          // Destructive action — disabled until the DELETE word is typed.
          Semantics(
            button: true,
            enabled: _armed && !_busy,
            label: l.deleteAccountFinalConfirm,
            child: ExcludeSemantics(
              child: SizedBox(
                width: double.infinity,
                height: 54,
                child: Material(
                  color: _armed && !_busy ? destructive : context.surface2Color,
                  borderRadius: BorderRadius.circular(15),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(15),
                    onTap: (_armed && !_busy) ? () => _delete(l) : null,
                    child: Center(
                      child: _busy
                          ? SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.4,
                                valueColor: AlwaysStoppedAnimation(fill),
                              ),
                            )
                          : Text(
                              l.deleteAccountFinalConfirm,
                              style: AppTextStyles.body(15,
                                  weight: FontWeight.w700,
                                  color: _armed && !_busy
                                      ? fill
                                      : context.mutedColor,
                                  context: context),
                            ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  InputDecoration _inputDec(BuildContext context, String hint) =>
      InputDecoration(
        hintText: hint,
        hintStyle: AppTextStyles.body(16,
            color: context.mutedSubtleColor, context: context),
        filled: true,
        fillColor: context.surfaceColor,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: context.borderInteractiveColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: context.primaryColor, width: 1.6),
        ),
      );
}
