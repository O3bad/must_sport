// Verifies the onFillFor() rule by computing real WCAG 2.x contrast ratios for
// every (theme, fill) pair the app actually uses.
// Run: dart run tool/contrast_final.dart
import 'dart:math' as math;

class Rgb {
  final int r, g, b;
  const Rgb(this.r, this.g, this.b);
  const Rgb.hex(int v)
      : r = (v >> 16) & 0xFF,
        g = (v >> 8) & 0xFF,
        b = v & 0xFF;
}

double _channel(double c) =>
    c <= 0.03928 ? c / 12.92 : math.pow((c + 0.055) / 1.055, 2.4).toDouble();

double luminance(Rgb c) =>
    0.2126 * _channel(c.r / 255) +
    0.7152 * _channel(c.g / 255) +
    0.0722 * _channel(c.b / 255);

/// WCAG 2.x contrast ratio, 1.0 .. 21.0
double contrast(Rgb a, Rgb b) {
  final la = luminance(a), lb = luminance(b);
  final hi = math.max(la, lb), lo = math.min(la, lb);
  return (hi + 0.05) / (lo + 0.05);
}

void check(String label, Rgb fg, Rgb bg,
    {double min = 4.5, bool expectPass = true}) {
  final ratio = contrast(fg, bg);
  final pass = ratio >= min;
  final ok = pass == expectPass;
  print('${ok ? "PASS" : "FAIL"}  ${ratio.toStringAsFixed(2).padLeft(6)}:1 '
      '(min $min, expected ${expectPass ? "pass" : "fail"})  $label');
  if (!ok) _failures++;
}

int _failures = 0;

void main() {
  // ── Dark theme ────────────────────────────────────────────────────────────
  const darkText = Rgb.hex(0xF0F4FF); // DarkColors.text
  const darkInk = Rgb.hex(0x0A1128);  // DarkColors.onFill
  print('== dark theme: bright fills take dark ink ==');
  check('cyan   #00E5FF / onFill', darkInk, const Rgb.hex(0x00E5FF), min: 4.5);
  check('lime   #A8FF3E / onFill', darkInk, const Rgb.hex(0xA8FF3E), min: 4.5);
  check('gold   #FFB800 / onFill', darkInk, const Rgb.hex(0xFFB800), min: 4.5);

  print('== dark theme: dark fills take light text ==');
  check('navy   #0F1A33 / text', darkText, const Rgb.hex(0x0F1A33), min: 4.5);
  check('blue   #2E65C3 / text', darkText, const Rgb.hex(0x2E65C3), min: 4.5);
  check('green  #0A7942 / text', darkText, const Rgb.hex(0x0A7942), min: 4.5);

  // #FF4757 has relative luminance ~0.22 but the weighted 0.299/0.587/0.114
  // estimate lands just above 0.5, so Flutter buckets it as *light* and
  // onFillFor() hands it dark ink. Light text on this red would be only
  // 3.03:1, which is why the ink must flip here.
  print('== dark theme: mid-bright fills take dark ink ==');
  check('error  #FF4757 / onFill', darkInk, const Rgb.hex(0xFF4757), min: 4.5);
  check('error  #FF4757 / text (must NOT be used)',
      darkText, const Rgb.hex(0xFF4757), min: 4.5, expectPass: false);

  // ── Light theme ───────────────────────────────────────────────────────────
  const lightText = Rgb.hex(0x142B58); // LightColors.text
  print('== light theme: dark fills take white ==');
  check('navy   #142B58 / white', const Rgb(255, 255, 255), const Rgb.hex(0x142B58), min: 4.5);
  check('blue   #2E65C3 / white', const Rgb(255, 255, 255), const Rgb.hex(0x2E65C3), min: 4.5);
  check('green  #0A7942 / white', const Rgb(255, 255, 255), const Rgb.hex(0x0A7942), min: 4.5);
  check('error  #CB2A1F / white', const Rgb(255, 255, 255), const Rgb.hex(0xCB2A1F), min: 4.5);
  check('gold   #895500 / white', const Rgb(255, 255, 255), const Rgb.hex(0x895500), min: 4.5);

  print('== light theme: pale fills take navy text ==');
  check('surface #FFFFFF / text', lightText, const Rgb(255, 255, 255), min: 4.5);
  check('surface2 #F4F4F6 / text', lightText, const Rgb.hex(0xF4F4F6), min: 4.5);

  // ── Body text on app surfaces (both themes) ───────────────────────────────
  print('== body text on surfaces ==');
  check('dark:  #F0F4FF on #080F22', darkText, const Rgb.hex(0x080F22));
  check('dark:  #F0F4FF on #162140', darkText, const Rgb.hex(0x162140));
  check('light: #142B58 on #EBEBEC', lightText, const Rgb.hex(0xEBEBEC));
  check('light: #142B58 on #FFFFFF', lightText, const Rgb(255, 255, 255));

  // ── MorphButton success fill ──────────────────────────────────────────────
  // The success state repaints the button green, so the label ink is resolved
  // against green, not against the idle `backgroundColor`.
  print('== MorphButton success fill ==');
  check('dark:  #22C55E / onFill', darkInk, const Rgb.hex(0x22C55E), min: 4.5);
  check('light: #0A7942 / white', const Rgb(255, 255, 255), const Rgb.hex(0x0A7942), min: 4.5);
  check('light: #0A7942 / text (must NOT be used)',
      lightText, const Rgb.hex(0x0A7942), min: 4.5, expectPass: false);

  // ── Exhaustively sweep every fill the palette defines ─────────────────────
  // Mirrors onFillFor()'s preference order: the theme's on-fill ink is tried
  // first, and body text is the fallback for dark fills that the ink cannot
  // cover. This is the check that would have caught the original #FF4757 bug,
  // where a brightness heuristic handed light text to a mid-tone red.
  print('== dark theme: every fill, onFillFor() preferred ink ==');
  // Bright fills -> dark ink.
  const darkBright = <String, int>{
    'cyan': 0x00E5FF,
    'lime': 0xA8FF3E,
    'gold/accent': 0xFFB800,
    'error': 0xFF4757,
  };
  darkBright.forEach((name, hex) {
    check('$name #${hex.toRadixString(16).padLeft(6, '0')} -> onFill',
        darkInk, Rgb.hex(hex), min: 4.5);
  });
  // Dark fills -> light body text.
  const darkDeep = <String, int>{
    'surface': 0x0F1A33,
    'blue': 0x2E65C3,
    'green': 0x0A7942,
  };
  darkDeep.forEach((name, hex) {
    check('$name #${hex.toRadixString(16).padLeft(6, '0')} -> text',
        darkText, Rgb.hex(hex), min: 4.5);
  });

  print('== light theme: every fill, onFillFor() preferred ink ==');
  const lightFills = <String, int>{
    'navy': 0x142B58,
    'blue': 0x2E65C3,
    'green': 0x0A7942,
    'error': 0xCB2A1F,
    'gold': 0x895500,
  };
  lightFills.forEach((name, hex) {
    check('$name #${hex.toRadixString(16).padLeft(6, '0')} -> white',
        const Rgb(255, 255, 255), Rgb.hex(hex), min: 4.5);
  });
  // Pale fills fall through the on-fill ink (white) to body text (navy).
  check('surface #FFFFFF -> text', lightText, const Rgb(255, 255, 255), min: 4.5);
  check('surface2 #F4F4F6 -> text', lightText, const Rgb.hex(0xF4F4F6), min: 4.5);

  // ── Muted text: must clear 4.5:1 because it carries real content ─────────
  print('== muted text (4.5:1 required) ==');
  check('dark:  muted #B8C8D8 on #080F22',
      const Rgb.hex(0xB8C8D8), const Rgb.hex(0x080F22), min: 4.5);
  check('dark:  mutedSubtle #AABACD on #0F1A33',
      const Rgb.hex(0xAABACD), const Rgb.hex(0x0F1A33), min: 4.5);
  check('light: muted #4A5568 on #EBEBEC',
      const Rgb.hex(0x4A5568), const Rgb.hex(0xEBEBEC), min: 4.5);

  print('');
  print(_failures == 0
      ? 'All contrast checks passed.'
      : '$_failures check(s) FAILED.');
  if (_failures > 0) {
    throw StateError('Contrast regression: $_failures failing combination(s).');
  }
}
