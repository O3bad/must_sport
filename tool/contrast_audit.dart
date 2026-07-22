// Standalone WCAG 2.1 contrast audit. Run: dart run tool/contrast_audit.dart
import 'dart:math' as math;

class C {
  final int r, g, b;
  const C(this.r, this.g, this.b);
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

void main() {
  // ── Dark palette on its own backgrounds ──
  final darkBg = hex('080F22');
  final darkSurface = hex('0F1A33');
  final darkSurface2 = hex('162140');

  const darkFg = {
    'text': 'F0F4FF',
    'muted': 'B8C8D8',
    'primary': '00E5FF',
    'secondary': 'A8FF3E',
    'accent': 'FFB800',
    'error': 'FF4757',
    'border': '1E2F50',
  };

  // ── Light palette on its own backgrounds ──
  final lightBg = hex('EBEBEC');
  final lightSurface = hex('FFFFFF');
  final lightSurface2 = hex('F4F4F6');

  const lightFg = {
    'text': '142B58',
    'muted': '4A5568',
    'blue': '2E65C3',
    'green': '37A66F',
    'gold': 'D4A017',
    'error': 'D93025',
    'border': 'D8D8DC',
  };

  // Fills that carry white text on top of them.
  const onColor = {
    'whiteOn.primary(cyan)': ['FFFFFF', '00E5FF'],
    'whiteOn.secondary(lime)': ['FFFFFF', 'A8FF3E'],
    'whiteOn.accent(amber)': ['FFFFFF', 'FFB800'],
    'whiteOn.error(coral)': ['FFFFFF', 'FF4757'],
    'whiteOn.lightBlue': ['FFFFFF', '2E65C3'],
    'whiteOn.lightGreen': ['FFFFFF', '37A66F'],
    'whiteOn.lightGold': ['FFFFFF', 'D4A017'],
    'whiteOn.lightError': ['FFFFFF', 'D93025'],
  };

  void report(String label, String fg, List<String> bgs, double min) {
    for (final bg in bgs) {
      final r = ratio(hex(fg), hex(bg));
      final pass = r >= min;
      final tag = pass ? 'PASS' : 'FAIL';
      final need = r >= 4.5
          ? '4.5 (normal text)'
          : (r >= 3.0 ? '3.0 (large text/UI)' : 'below 3.0');
      print('${r.toStringAsFixed(2).padLeft(6)}  $tag  $label on #${bg.toUpperCase()}  '
          '(needs $need)');
    }
  }

  print('=' * 78);
  print('WCAG 2.1 CONTRAST AUDIT — MUSTER Sport');
  print('=' * 78);

  print('\n--- DARK THEME (min 4.5 body, 3.0 large/UI) ---');
  report('text', darkFg['text']!, [ '080F22', '0F1A33', '162140'], 4.5);
  report('muted', darkFg['muted']!, ['080F22', '0F1A33', '162140'], 4.5);
  report('primary/cyan', darkFg['primary']!, ['080F22', '0F1A33', '162140'], 4.5);
  report('secondary/lime', darkFg['secondary']!, ['080F22', '0F1A33', '162140'], 4.5);
  report('accent/amber', darkFg['accent']!, ['080F22', '0F1A33', '162140'], 4.5);
  report('error/coral', darkFg['error']!, ['080F22', '0F1A33', '162140'], 4.5);
  report('border (UI 3.0)', darkFg['border']!, ['080F22', '0F1A33'], 3.0);

  print('\n--- LIGHT THEME ---');
  report('text/navy', lightFg['text']!, ['EBEBEC', 'FFFFFF', 'F4F4F6'], 4.5);
  report('muted', lightFg['muted']!, ['EBEBEC', 'FFFFFF', 'F4F4F6'], 4.5);
  report('blue', lightFg['blue']!, ['EBEBEC', 'FFFFFF', 'F4F4F6'], 4.5);
  report('green', lightFg['green']!, ['EBEBEC', 'FFFFFF', 'F4F4F6'], 4.5);
  report('gold', lightFg['gold']!, ['EBEBEC', 'FFFFFF', 'F4F4F6'], 4.5);
  report('error', lightFg['error']!, ['EBEBEC', 'FFFFFF', 'F4F4F6'], 4.5);
  report('border (UI 3.0)', lightFg['border']!, ['EBEBEC', 'FFFFFF'], 3.0);

  print('\n--- WHITE TEXT ON COLORED FILLS (buttons) ---');
  onColor.forEach((label, pair) {
    final r = ratio(hex(pair[0]), hex(pair[1]));
    print('${r.toStringAsFixed(2).padLeft(6)}  ${r >= 4.5 ? 'PASS' : 'FAIL'}  $label');
  });

  print('\n--- MUTED USED AT REDUCED ALPHA (0.6-0.65) — common failure source ---');
  for (final a in [0.6, 0.65]) {
    final base = hex('B8C8D8');
    // Approximate alpha composite over darkSurface
    final bg = hex('0F1A33');
    final comp = C(
      (base.r * a + bg.r * (1 - a)).round(),
      (base.g * a + bg.g * (1 - a)).round(),
      (base.b * a + bg.b * (1 - a)).round(),
    );
    print('  muted@${a} on #0F1A33 -> effective #'
        '${comp.r.toRadixString(16).padLeft(2, '0')}'
        '${comp.g.toRadixString(16).padLeft(2, '0')}'
        '${comp.b.toRadixString(16).padLeft(2, '0')}'
        '  ratio vs text ${ratio(hex('F0F4FF'), comp).toStringAsFixed(2)}');
  }
}
