// Validated contrast fixes. Run: dart run tool/contrast_fix_check.dart
import 'dart:math' as math;

class C {
  final int r, g, b;
  const C(this.r, this.g, this.b);
  String get hex =>
      '${r.toRadixString(16).padLeft(2, '0')}'
      '${g.toRadixString(16).padLeft(2, '0')}'
      '${b.toRadixString(16).padLeft(2, '0')}';
}

C hex(String h) {
  final v = int.parse(h.replaceFirst('#', ''), radix: 16);
  return C((v >> 16) & 0xFF, (v >> 8) & 0xFF, v & 0xFF);
}

double lum(C c) {
  double ch(int v) {
    final s = v / 255.0;
    return s <= 0.03928 ? s / 12.92 : math.pow((s + 0.055) / 1.055, 2.4).toDouble();
  }
  return 0.2126 * ch(c.r) + 0.7152 * ch(c.g) + 0.0722 * ch(c.b);
}

double ratio(C a, C b) {
  final la = lum(a), lb = lum(b);
  return (la > lb ? (la + 0.05) / (lb + 0.05) : (lb + 0.05) / (la + 0.05));
}

/// Lighten/darken a color's RGB channels by [amount] in -1..1
C shift(C c, double amount) {
  int f(int v) =>
      (v + amount * 255).round().clamp(0, 255);
  return C(f(c.r), f(c.g), f(c.b));
}

void main() {
  print('=' * 70);
  print('FIX VALIDATION');
  print('=' * 70);

  // ── 1. Button fills: replace white text with dark text ──
  print('\n[1] BUTTON FILLS — swap white text for near-black');
  const fills = {
    'cyan': '00E5FF',
    'lime': 'A8FF3E',
    'amber': 'FFB800',
    'coral': 'FF4757',
  };
  const fg = {'ink': '0A1128', 'midInk': '111A2E'};
  fills.forEach((name, f) {
    for (final ink in fg.values) {
      final r = ratio(hex(ink), hex(f));
      print('  ${r.toStringAsFixed(2).padLeft(6)}  ${r >= 4.5 ? "PASS" : "FAIL"}  '
          '#$ink on #$f ($name)');
    }
  });

  // ── 2. Light theme green / gold: darken until 4.5 on white ──
  print('\n[2] LIGHT THEME — darken green & gold to reach 4.5:1 on #FFFFFF');
  for (final pair in {'green': '37A66F', 'gold': 'D4A017'}.entries) {
    var c = hex(pair.value);
    print('  ${pair.key} current #${c.hex} on #FFFFFF = '
        '${ratio(hex('142B58'), c).toStringAsFixed(2)} (as text)');
    for (var step = 1; step <= 6; step++) {
      c = shift(c, -0.06);
      final onWhite = ratio(hex('142B58'), c);
      final onBg = ratio(hex('142B58'), c);
      print('     -6% -> #${c.hex.toUpperCase()}  vs #FFFFFF '
          '${ratio(c, hex('FFFFFF')).toStringAsFixed(2)}  vs #EBEBEC '
          '${ratio(c, hex('EBEBEC')).toStringAsFixed(2)}');
      if (ratio(c, hex('FFFFFF')) >= 4.5 &&
          ratio(c, hex('EBEBEC')) >= 4.5) {
        print('     ^^ USE #${c.hex.toUpperCase()}');
        break;
      }
    }
  }

  // ── 3. Borders: need 3:1 as UI component boundaries ──
  print('\n[3] BORDERS — target 3:1 against their own surface');
  for (final pair in {
    'dark.border on dark.surface': ['1E2F50', '0F1A33'],
    'light.border on light.surface': ['D8D8DC', 'FFFFFF'],
    'light.border on light.bg': ['D8D8DC', 'EBEBEC'],
  }.entries) {
    final parts = pair.value;
    print('  ${pair.key}: ${ratio(hex(parts[0]), hex(parts[1])).toStringAsFixed(2)}');
  }
  print('  candidates for dark.border:');
  for (final cand in ['2E4570', '35507F', '3B5A8C', '42679B']) {
    print('     #$cand on #0F1A33 = ${ratio(hex(cand), hex('0F1A33')).toStringAsFixed(2)}'
        '  on #080F22 = ${ratio(hex(cand), hex('080F22')).toStringAsFixed(2)}');
  }
  print('  candidates for light.border:');
  for (final cand in ['9AA0AC', '8A9099', '7A8089', '6B7280']) {
    print('     #$cand on #FFFFFF = ${ratio(hex(cand), hex('FFFFFF')).toStringAsFixed(2)}'
        '  on #EBEBEC = ${ratio(hex(cand), hex('EBEBEC')).toStringAsFixed(2)}');
  }

  // ── 4. Muted at alpha — remove alpha, use explicit colors ──
  print('\n[4] MUTED AT ALPHA — replace with explicit accessible values');
  for (final cand in ['B8C8D8', 'A9BACB', '9DAFC1']) {
    print('  dark.muted #$cand on #0F1A33 = '
        '${ratio(hex(cand), hex('0F1A33')).toStringAsFixed(2)}');
  }
  print('  light.muted #4A5568 on #FFFFFF = '
      '${ratio(hex('4A5568'), hex('FFFFFF')).toStringAsFixed(2)}');
  for (final cand in ['3E4A5C', '38424F', '323B47']) {
    print('  light.muted #$cand on #FFFFFF = '
        '${ratio(hex(cand), hex('FFFFFF')).toStringAsFixed(2)}'
        '  on #EBEBEC = ${ratio(hex(cand), hex('EBEBEC')).toStringAsFixed(2)}');
  }
}
