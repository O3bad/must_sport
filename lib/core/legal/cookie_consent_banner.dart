// lib/core/legal/cookie_consent_banner.dart
// Browser-storage notice for the web build.
//
// Android and iOS have no cookie mechanism, so this widget renders nothing
// there. The web app currently uses browser storage for its core session and
// app data, with no advertising or analytics cookies; this is a disclosure,
// not a consent choice.

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../l10n/app_localizations.dart';
import '../../features/settings/presentation/legal_document_screen.dart';
import 'legal_content.dart';

class CookieConsentBanner extends StatefulWidget {
  const CookieConsentBanner({super.key});

  @override
  State<CookieConsentBanner> createState() => _CookieConsentBannerState();
}

class _CookieConsentBannerState extends State<CookieConsentBanner> {
  static const String _kNoticeKey = 'legal.cookieNoticeDismissed';

  bool _dismissed = false;
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
      _dismissed = prefs.getBool(_kNoticeKey) ?? false;
      _loaded = true;
    });
  }

  Future<void> _dismiss() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = await prefs.setBool(_kNoticeKey, true);
    if (!saved) {
      throw StateError('Could not persist browser-storage notice dismissal.');
    }
    if (!mounted) return;
    setState(() => _dismissed = true);
  }

  @override
  Widget build(BuildContext context) {
    if (kIsWeb && _loaded && !_dismissed) {
      return _Banner(onDismiss: _dismiss);
    }
    return const SizedBox.shrink();
  }
}

class _Banner extends StatelessWidget {
  const _Banner({required this.onDismiss});

  final VoidCallback onDismiss;

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
                style: const TextStyle(color: Colors.white70, fontSize: 12),
              ),
              const SizedBox(height: 6),
              Wrap(
                alignment: WrapAlignment.end,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  TextButton(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const LegalDocumentScreen(
                          kind: LegalDocumentKind.cookies,
                        ),
                      ),
                    ),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.white,
                      minimumSize: const Size(48, 44),
                    ),
                    child: Text(l.cookieBannerLearnMore),
                  ),
                  FilledButton(
                    onPressed: onDismiss,
                    style: FilledButton.styleFrom(
                      minimumSize: const Size(88, 44),
                    ),
                    child: Text(l.cookieBannerContinue),
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
