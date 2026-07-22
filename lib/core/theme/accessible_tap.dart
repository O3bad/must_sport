import 'package:flutter/material.dart';

/// A tappable region that behaves correctly for every input method.
///
/// Replaces bare `GestureDetector`, which is invisible to keyboard, switch
/// access and screen readers: it is not focusable, has no semantic role, and
/// exposes no label. This wrapper supplies all three.
///
/// [label] is required and becomes the node's accessible name, so a screen
/// reader announces something meaningful instead of nothing. It should be
/// localised — use `AppLocalizations.of(context)` rather than a literal.
///
/// Set [excludeSemantics] to `false` when the child renders text a screen reader
/// should read verbatim; [label] then supplements rather than replaces it.
///
/// The tap area is constrained to at least 48x48dp (WCAG 2.5.5 / 2.5.8) even
/// when the visual child is smaller.
///
/// Lives in its own library so that feature screens can use it without
/// importing `widgets.dart` (which itself depends on some of those screens).
class AccessibleTap extends StatelessWidget {
  final VoidCallback? onTap;
  final String label;
  final Widget child;
  final bool excludeSemantics;
  final String? hint;
  final bool toggleable;
  final bool isToggled;

  const AccessibleTap({
    super.key,
    required this.onTap,
    required this.label,
    required this.child,
    this.excludeSemantics = true,
    this.hint,
    this.toggleable = false,
    this.isToggled = false,
  });

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null;
    // Read from the ambient Theme rather than the app's own context extensions,
    // so this library stays free of project-wide theme imports.
    final accent = Theme.of(context).colorScheme.primary;
    return Semantics(
      button: true,
      enabled: enabled,
      label: label,
      hint: hint,
      toggled: toggleable ? isToggled : null,
      onTap: enabled ? onTap : null,
      child: ExcludeSemantics(
        excluding: excludeSemantics,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
          child: Material(
            type: MaterialType.transparency,
            child: InkWell(
              onTap: onTap,
              canRequestFocus: enabled,
              focusColor: accent.withValues(alpha: 0.12),
              splashColor: accent.withValues(alpha: 0.10),
              child: Center(child: child),
            ),
          ),
        ),
      ),
    );
  }
}
