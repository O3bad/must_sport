// lib/core/legal/legal_config.dart
// Operator identity used by the in-app legal documents.
//
// Nothing here is invented. Values that cannot be derived from the source
// repository (a real contact mailbox, a registered legal entity) are supplied
// at build time with --dart-define and are EMPTY by default, so a release can
// never ship a policy that points at a mailbox nobody owns.
//
//   flutter run --dart-define=SUPPORT_EMAIL=realyou@university.edu
//
// [isContactConfigured] lets the UI surface an honest "not configured"
// state instead of printing a broken or invented address.

class LegalConfig {
  const LegalConfig._();

  static const String appName = 'MUSTER Sport';

  static const String operatorName = 'MUSTER Sport';

  static const String organisation =
      'MUST University — Faculty of Information Technology';

  /// Published contact mailbox for privacy/rights requests.
  /// Empty unless provided at build time.
  static const String supportEmail = String.fromEnvironment('SUPPORT_EMAIL');

  /// Date the published documents took effect (ISO-8601).
  static const String effectiveDate = String.fromEnvironment(
    'LEGAL_EFFECTIVE_DATE',
    defaultValue: '2026-03-01',
  );

  /// Minimum age to hold an account. Mirrors the sign-up confirmation.
  static const int minimumAge = 18;

  static bool get isContactConfigured => supportEmail.trim().isNotEmpty;

  /// Placeholder rendered instead of inventing an address.
  static const String unconfiguredContactLabel = 'Not configured in this build';

  /// Display-safe contact string.
  static String get contactDisplay =>
      isContactConfigured ? supportEmail.trim() : unconfiguredContactLabel;
}
