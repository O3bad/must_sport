// lib/core/legal/cookie_consent_banner.dart
// Cookie consent banner for the web build.
//
// Android and iOS have no cookie mechanism, so this widget renders nothing
// there — showing a cookie banner inside a native app would itself be a dark
// pattern, and Play's Data Safety form explicitly collects this as a non-use.
// On web the banner gates non-essential storage and is required before any
// optional storage is written.

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../l10n/app_localizations.dart';
import '../../features/settings/presentation/legal_document_screen.dart';
import 'legal_content.dart';

class CookieConsentBanner extends StatefulWidget {
  const CookieConsentBanner({super.key, this.onDecided});

  /// Called after the user accepts or declines, with the resulting consent.
  final ValueChanged<bool>? onDecided;

  @override
  State<CookieConsentBanner> createState() => _CookieConsentBannerState();
}

class _CookieConsentBannerState extends State<CookieConsentBanner> {
  static const String _kConsentKey = 'legal.cookieConsent';

  bool? _decision;
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      _decision = prefs.getBool(_kConsentKey);
      _loaded = true;
    });
  }

  Future<void> _decide(bool accepted) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kConsentKey, accepted);
    if (!mounted) return;
    setState(() => _decision = accepted);
    widget.onDecided?.call(accepted);
  }

  @override
  Widget build(BuildContext context) {
    // Native platforms: no cookies exist, so there is nothing to consent to.
    if (kIsWeb && _loaded && _decision == null) {
      return _Banner(
          onAccept: () => _decide(true), onDecline: () => _decide(false));
    }
    return const SizedBox.shrink();
  }
}

class _Banner extends StatelessWidget {
  const _Banner({required this.onAccept, required this.onDecline});

  final VoidCallback onAccept;
  final VoidCallback onDecline;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    if (l == null) return const SizedBox.shrink();

    return Material(
      color: Colors.black87,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      l.cookieBannerTitle,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      l.cookieBannerBody,
                      style:
                          const TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                    const SizedBox(height: 6),
                    // Reject and accept are given equal visual weight, and the
                    // reject action is not buried: consent must be a real choice.
                    GestureDetector(
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const LegalDocumentScreen(
                            kind: LegalDocumentKind.cookies,
                          ),
                        ),
                      ),
                      child: Text(
                        l.cookieBannerLearnMore,
                        style: const TextStyle(
                          color: Colors.lightBlueAccent,
                          fontSize: 12,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextButton(
                    onPressed: onDecline,
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.white,
                      minimumSize: const Size(88, 44),
                    ),
                    child: Text(l.cookieBannerDecline),
                  ),
                  FilledButton(
                    onPressed: onAccept,
                    style: FilledButton.styleFrom(
                      minimumSize: const Size(88, 44),
                    ),
                    child: Text(l.cookieBannerAccept),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
