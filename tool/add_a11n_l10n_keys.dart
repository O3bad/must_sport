// Adds accessibility-specific strings to both ARB files.
// Semantics labels need localised, human-readable text, so the a11y work
// cannot hard-code English.
// Run: dart run tool/add_a11n_l10n_keys.dart
import 'dart:convert';
import 'dart:io';

const additions = <String, Map<String, String>>{
  'lib/l10n/app_en.arb': {
    'showPassword': 'Show password',
    'hidePassword': 'Hide password',
    'selectRole': 'Select role: {role}',
    'selected': 'Selected',
    'notificationsEnabled': 'Notifications enabled',
    'notificationsDisabled': 'Notifications disabled',
    'expandSection': 'Expand {section}',
    'collapseSection': 'Collapse {section}',
    'clearField': 'Clear {field}',
    'removeAvatar': 'Remove avatar',
    'back': 'Back',
    'retry': 'Retry',
    'loading': 'Loading',
    'navBadgeCount': '{count} new',
  },
  'lib/l10n/app_ar.arb': {
    'showPassword': 'إظهار كلمة المرور',
    'hidePassword': 'إخفاء كلمة المرور',
    'selectRole': 'اختر الدور: {role}',
    'selected': 'محدد',
    'notificationsEnabled': 'الإشعارات مفعّلة',
    'notificationsDisabled': 'الإشعارات معطّلة',
    'expandSection': 'توسيع {section}',
    'collapseSection': 'طي {section}',
    'clearField': 'مسح {field}',
    'removeAvatar': 'إزالة الصورة الشخصية',
    'back': 'رجوع',
    'retry': 'إعادة المحاولة',
    'loading': 'جارٍ التحميل',
    'navBadgeCount': '{count} جديد',
  },
};

/// Placeholder keys that need their name declared in the template ARB
/// (`@en` / `@ar`) for gen-l10n to emit a parameterised getter.
const parameterized = {
  'selectRole',
  'expandSection',
  'collapseSection',
  'clearField',
  'navBadgeCount',
};

/// Derives the ARB placeholder name from a camelCase key: `expandSection` ->
/// `expand section`.
String placeholderName(String key) =>
    key.split(RegExp(r'(?=[A-Z])')).map((w) => w.toLowerCase()).join(' ');

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

    // Register the @key placeholders so gen-l10n emits the getter signatures.
    // This ARB has no template object yet, so create it alongside @@locale.
    final locale = data['@@locale'] as String;
    final template = (data['@$locale'] as Map<String, dynamic>?) ?? <String, dynamic>{};
    for (final k in added.where(parameterized.contains)) {
      template['@$k'] = <String, dynamic>{
        'description': 'Accessibility label template for "$k".',
        'placeholders': <String, dynamic>{
          placeholderName(k): <String, dynamic>{'type': 'String'}
        }
      };
    }
    // The template must sit immediately after @@locale for readability.
    if (template.isNotEmpty) {
      final rebuilt = <String, dynamic>{'@@locale': locale, '@$locale': template};
      data.remove('@@locale');
      data.remove('@$locale');
      rebuilt.addAll(data);
      data
        ..clear()
        ..addAll(rebuilt);
    }

    final sink = StringBuffer();
    sink.writeln('{');
    final keys = data.keys.toList();
    for (var i = 0; i < keys.length; i++) {
      final key = keys[i];
      sink.writeln('  ${jsonEncode(key)}: ${jsonEncode(data[key])}${i == keys.length - 1 ? '' : ','}');
    }
    sink.writeln('}');
    file.writeAsStringSync(sink.toString(), encoding: utf8);

    stdout.writeln('$path -> added ${added.length} keys');
  });
}
