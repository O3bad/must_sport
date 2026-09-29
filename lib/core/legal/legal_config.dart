// lib/core/legal/legal_config.dart
// Operator identity used by the in-app legal documents.
//
// Nothing here is invented. The project-provided privacy mailbox is the
// default; deployments can override it with --dart-define.
//
//   flutter run --dart-define=SUPPORT_EMAIL=realyou@university.edu
//
// [isContactConfigured] lets the UI surface an honest "not configured"
// state if a deployment explicitly clears the contact value.

class LegalConfig {
  const LegalConfig._();

  static const String appName = 'MUSTER Sport';

  static const String operatorName = 'Abdelrahman Abed';

  static const String organisation =
      'Misr University for Science and Technology (MUST), Egypt';

  /// Published contact mailbox for privacy/rights requests.
  static const String supportEmail = String.fromEnvironment(
    'SUPPORT_EMAIL',
    defaultValue: 'podywaleed28@gmail.com',
  );

  /// Date the published documents took effect (ISO-8601).
  static const String effectiveDate = String.fromEnvironment(
    'LEGAL_EFFECTIVE_DATE',
    defaultValue: '2026-09-30',
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
