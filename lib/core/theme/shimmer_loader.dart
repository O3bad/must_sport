import 'package:flutter/material.dart';
import 'widgets.dart';
import 'app_theme.dart';

// ─── IMPROVEMENT #16: Shimmer loading skeleton ────────────────────────────────
// Use SkeletonCard and SkeletonList wherever data is loading from Firestore.
// No external package needed — pure Flutter animation.

class _ShimmerPainter extends CustomPainter {
  final double progress;
  final Color base;
  final Color highlight;

  const _ShimmerPainter({
    required this.progress,
    required this.base,
    required this.highlight,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final gradient = LinearGradient(
      begin: Alignment(-1.5 + progress * 3, 0),
      end:   Alignment(-0.5 + progress * 3, 0),
      colors: [base, highlight, base],
      stops: const [0.0, 0.5, 1.0],
    );
    canvas.drawRect(rect, Paint()..shader = gradient.createShader(rect));
  }

  @override
  bool shouldRepaint(_ShimmerPainter old) => old.progress != progress;
}

class ShimmerBox extends StatefulWidget {
  final double width, height, borderRadius;
  const ShimmerBox({super.key, this.width = double.infinity, this.height = 16, this.borderRadius = 8});

  @override
  State<ShimmerBox> createState() => _ShimmerBoxState();
}

class _ShimmerBoxState extends State<ShimmerBox> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1400))
      ..repeat();
    _anim = Tween<double>(begin: 0.0, end: 1.0).animate(_ctrl);
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;
    final base      = isDark ? DarkColors.surface  : const Color(0xFFE0E0E0);
    final highlight = isDark ? DarkColors.surface2 : const Color(0xFFF5F5F5);
    return AnimatedBuilder(
      animation: _anim,
      builder: (_, __) => ClipRRect(
        borderRadius: BorderRadius.circular(widget.borderRadius),
        child: CustomPaint(
          painter: _ShimmerPainter(progress: _anim.value, base: base, highlight: highlight),
          child: SizedBox(width: widget.width, height: widget.height),
        ),
      ),
    );
  }
}

/// A shimmer card that mimics a content card while data loads.
class SkeletonCard extends StatelessWidget {
  const SkeletonCard({super.key});

  @override
  Widget build(BuildContext context) {
    final surf   = context.surfaceColor;
    final border = context.borderColor;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: surf,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: border),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          const ShimmerBox(width: 44, height: 44, borderRadius: 12),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const ShimmerBox(height: 14, borderRadius: 6),
            const SizedBox(height: 8),
            ShimmerBox(width: MediaQuery.of(context).size.width * 0.4, height: 12, borderRadius: 6),
          ])),
        ]),
        const SizedBox(height: 14),
        const ShimmerBox(height: 12, borderRadius: 6),
        const SizedBox(height: 6),
        ShimmerBox(width: MediaQuery.of(context).size.width * 0.6, height: 12, borderRadius: 6),
      ]),
    );
  }
}

/// Drop-in list of skeleton cards for loading states.
class SkeletonList extends StatelessWidget {
  final int count;
  const SkeletonList({super.key, this.count = 5});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: count,
      itemBuilder: (_, __) => const SkeletonCard(),
    );
  }
}
