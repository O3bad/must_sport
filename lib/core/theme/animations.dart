// lib/core/theme/animations.dart

import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'widgets.dart'; // For ThemeX helpers

/// Standard Animation Durations for the App
class MusterAnim {
  static const fast = Duration(milliseconds: 200);
  static const normal = Duration(milliseconds: 400);
  static const slow = Duration(milliseconds: 800);
  static const snap = Curves.elasticOut;
}

// ─── PRESS SCALE ─────────────────────────────────────────────────────────────
class PressScale extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final double scale;
  final Duration duration;

  const PressScale({
    super.key,
    required this.child,
    this.onTap,
    this.scale = 0.96,
    this.duration = const Duration(milliseconds: 120),
  });

  @override
  State<PressScale> createState() => _PressScaleState();
}

class _PressScaleState extends State<PressScale> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: widget.duration);
    _anim = Tween<double>(begin: 1.0, end: widget.scale).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => widget.onTap != null ? _ctrl.forward() : null,
      onTapUp: (_) => _ctrl.reverse(),
      onTapCancel: () => _ctrl.reverse(),
      onTap: widget.onTap,
      child: ScaleTransition(scale: _anim, child: widget.child),
    );
  }
}

// ─── GLITCH TEXT (NEW) ───────────────────────────────────────────────────────
class GlitchText extends StatefulWidget {
  final String text;
  final TextStyle style;
  const GlitchText({super.key, required this.text, required this.style});

  @override
  State<GlitchText> createState() => _GlitchTextState();
}

class _GlitchTextState extends State<GlitchText> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 400))..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (context, _) {
        final offset = _random.nextBool() ? 1.5 : -1.5;
        return Stack(
          children: [
            // Red Offset
            Transform.translate(
              offset: Offset(offset, 0),
              child: Text(
                widget.text,
                style: widget.style.copyWith(color: const Color(0xFFFF4757).withValues(alpha: 0.5)),
              ),
            ),
            // Cyan Offset
            Transform.translate(
              offset: Offset(-offset, 0),
              child: Text(
                widget.text,
                style: widget.style.copyWith(color: const Color(0xFF00E5FF).withValues(alpha: 0.5)),
              ),
            ),
            // Main Text
            Text(widget.text, style: widget.style),
          ],
        );
      },
    );
  }
}

// ─── MAGNETIC PULL (NEW) ─────────────────────────────────────────────────────
class MagneticPull extends StatefulWidget {
  final Widget child;
  const MagneticPull({super.key, required this.child});

  @override
  State<MagneticPull> createState() => _MagneticPullState();
}

class _MagneticPullState extends State<MagneticPull> {
  Offset _offset = Offset.zero;

  void _handleHover(PointerHoverEvent event, BuildContext context) {
    final RenderBox box = context.findRenderObject() as RenderBox;
    final center = box.size.center(Offset.zero);
    final position = box.globalToLocal(event.position);

    setState(() {
      _offset = Offset(
        (position.dx - center.dx) * 0.25,
        (position.dy - center.dy) * 0.25,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onHover: (e) => _handleHover(e, context),
      onExit: (_) => setState(() => _offset = Offset.zero),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeOut,
        transform: Matrix4.translationValues(_offset.dx, _offset.dy, 0),
        child: widget.child,
      ),
    );
  }
}

// ─── PULSE RINGS (NEW) ───────────────────────────────────────────────────────
class PulseRings extends StatefulWidget {
  final Color color;
  final double size;
  const PulseRings({super.key, required this.color, this.size = 12});

  @override
  State<PulseRings> createState() => _PulseRingsState();
}

class _PulseRingsState extends State<PulseRings> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1800))..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: List.generate(2, (i) {
        final anim = CurvedAnimation(
          parent: _ctrl,
          curve: Interval(i * 0.3, 1.0, curve: Curves.easeOut),
        );
        return AnimatedBuilder(
          animation: anim,
          builder: (context, _) => Container(
            width: widget.size + (24 * anim.value),
            height: widget.size + (24 * anim.value),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: widget.color.withValues(alpha: 1 - anim.value),
                width: 1.2,
              ),
            ),
          ),
        );
      }),
    );
  }
}

// ─── LIQUID PROGRESS BAR (NEW) ──────────────────────────────────────────────
class LiquidProgressBar extends StatelessWidget {
  final double progress; // 0.0 to 1.0
  const LiquidProgressBar({super.key, required this.progress});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 12,
      width: double.infinity,
      decoration: BoxDecoration(
        color: context.surface2Color,
        borderRadius: BorderRadius.circular(100),
        border: Border.all(color: context.borderColor),
      ),
      child: Stack(
        children: [
          LayoutBuilder(builder: (context, constraints) {
            return AnimatedContainer(
              duration: MusterAnim.slow,
              curve: Curves.easeOutQuart,
              width: constraints.maxWidth * progress.clamp(0, 1),
              decoration: BoxDecoration(
                color: context.primaryColor,
                borderRadius: BorderRadius.circular(100),
                boxShadow: [
                  BoxShadow(
                    color: context.primaryColor.withValues(alpha: 0.3),
                    blurRadius: 8,
                  )
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}

// ─── COUNT UP TEXT ───────────────────────────────────────────────────────────
class CountUpText extends StatelessWidget {
  final num value;
  final TextStyle style;
  final String? suffix;

  const CountUpText({super.key, required this.value, required this.style, this.suffix});

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: value.toDouble()),
      duration: MusterAnim.slow,
      curve: MusterAnim.snap,
      builder: (_, val, __) => Text('${val.round()}${suffix ?? ""}', style: style),
    );
  }
}

// ─── TYPING CURSOR ───────────────────────────────────────────────────────────
class TypingCursor extends StatefulWidget {
  final Color? color;
  final double height;
  const TypingCursor({super.key, this.color, this.height = 18});

  @override
  State<TypingCursor> createState() => _TypingCursorState();
}

class _TypingCursorState extends State<TypingCursor> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 500))..repeat(reverse: true);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: _ctrl,
    builder: (_, __) => Opacity(
      opacity: _ctrl.value > 0.5 ? 1 : 0,
      child: Container(
        width: 2.5,
        height: widget.height,
        decoration: BoxDecoration(
          color: widget.color ?? context.primaryColor,
          boxShadow: [
            BoxShadow(
              color: (widget.color ?? context.primaryColor).withValues(alpha: 0.4),
              blurRadius: 4,
            )
          ],
        ),
      ),
    ),
  );
}