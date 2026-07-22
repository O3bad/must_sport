// Adds the consent / account-deletion / license strings to both ARB files.
// Run: dart run tool/add_l10n_keys.dart
import 'dart:convert';
import 'dart:io';

const additions = <String, Map<String, String>>{
  'lib/l10n/app_en.arb': {
    'signupTermsConsent':
        'I agree to the Terms of Service and Privacy Policy, and I confirm I am at least 18 years old.',
    'signupTermsConsentError':
        'You must accept the terms to create an account.',
    'deleteAccount': 'Delete Account',
    'deleteAccountSectionTitle': 'Account',
    'deleteAccountWarning':
        'Deleting your account permanently removes your profile, reservations and participation history from MUSTER Sport.',
    'deleteAccountConfirmTitle': 'Delete your account?',
    'deleteAccountConfirmBody':
        'This permanently erases your account and all data associated with it. This cannot be undone.',
    'deleteAccountTypeToConfirm': 'Type DELETE to confirm',
    'deleteAccountConfirmWord': 'DELETE',
    'deleteAccountPasswordPrompt': 'Enter your password to confirm',
    'deleteAccountCancel': 'Cancel',
    'deleteAccountFinalConfirm': 'Permanently delete',
    'deleteAccountInProgress': 'Deleting your account…',
    'deleteAccountSuccess': 'Your account has been deleted.',
    'deleteAccountFailed': 'Could not delete your account: {reason}',
    'licenses': 'Open Source Licenses',
    'licensesIntro':
        'MUSTER Sport is built on the following open source software and fonts.',
  },
  'lib/l10n/app_ar.arb': {
    'signupTermsConsent':
        'أوافق على شروط الخدمة وسياسة الخصوصية، وأؤكد أن عمري لا يقل عن ١٨ عامًا.',
    'signupTermsConsentError': 'يجب الموافقة على الشروط لإنشاء حساب.',
    'deleteAccount': 'حذف الحساب',
    'deleteAccountSectionTitle': 'الحساب',
    'deleteAccountWarning':
        'حذف حسابك يزيل نهائيًا ملفك الشخصي وحجوزاتك وسجل مشاركتك من تطبيق MUSTER Sport.',
    'deleteAccountConfirmTitle': 'حذف حسابك؟',
    'deleteAccountConfirmBody':
        'سيؤدي هذا إلى مسح حسابك وجميع البيانات المرتبطة به نهائيًا. لا يمكن التراجع عن هذا الإجراء.',
    'deleteAccountTypeToConfirm': 'اكتب DELETE للتأكيد',
    'deleteAccountConfirmWord': 'DELETE',
    'deleteAccountPasswordPrompt': 'أدخل كلمة المرور للتأكيد',
    'deleteAccountCancel': 'إلغاء',
    'deleteAccountFinalConfirm': 'حذف نهائي',
    'deleteAccountInProgress': 'جارٍ حذف حسابك…',
    'deleteAccountSuccess': 'تم حذف حسابك.',
    'deleteAccountFailed': 'تعذّر حذف حسابك: {reason}',
    'licenses': 'تراخيص المصادر المفتوحة',
    'licensesIntro':
        'بُني تطبيق MUSTER Sport على البرامج والخطوط مفتوحة المصدر التالية.',
  },
};

void main() {
  additions.forEach((path, entries) {
    final file = File(path);
    final data = jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;

    final added = <String>[];
    entries.forEach((k, v) {
      if (data.containsKey(k)) {
        stdout.writeln('  skip (exists): $k');
        return;
      }
      data[k] = v;
      added.add(k);
    });

    // Preserve insertion order, two-space indent, trailing newline.
    final sink = StringBuffer();
    sink.writeln('{');
    final keys = data.keys.toList();
    for (var i = 0; i < keys.length; i++) {
      final key = keys[i];
      final encodedKey = jsonEncode(key);
      final value = jsonEncode(data[key]);
      sink.writeln('  $encodedKey: $value${i == keys.length - 1 ? '' : ','}');
    }
    sink.writeln('}');
    file.writeAsStringSync(sink.toString(), encoding: utf8);

    stdout.writeln('$path -> added ${added.length} keys');
  });
}
