import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/widgets.dart';
import '../../../core/state/app_state.dart';
import '../../../core/models/models.dart';

class SportsScreen extends StatelessWidget {
  const SportsScreen({super.key});

  static const _categories = [
    SportCategory.football, SportCategory.padel, SportCategory.basketball,
    SportCategory.volleyball, SportCategory.gym, SportCategory.martialArts,
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.bgColor,
      appBar: const MusterAppBar(),
      body: ListView(
        padding: EdgeInsets.only(
          left: 20, right: 20, top: 20,
          bottom: MediaQuery.of(context).padding.bottom + 90,
        ),
        children: [
          Text('Sports Categories',
            style: AppTextStyles.display(24, color: context.textColor)),
          const SizedBox(height: 4),
          Text('Tap a sport to browse its events',
            style: AppTextStyles.body(12, color: context.mutedColor)),
          const SizedBox(height: 16),
          const MusterDivider(),
          GridView.count(
            crossAxisCount: 2, shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 14, crossAxisSpacing: 14, childAspectRatio: 0.95,
            children: _categories.map((cat) => _SportCategoryCard(
              category: cat,
              onTap: () => context.read<AppState>()
                ..setEventFilter(cat)
                ..setNavIndex(3),
            )).toList(),
          ),
        ],
      ),
    );
  }
}

class _SportCategoryCard extends StatefulWidget {
  final SportCategory category;
  final VoidCallback onTap;
  const _SportCategoryCard({required this.category, required this.onTap});

  @override
  State<_SportCategoryCard> createState() => _SportCategoryCardState();
}

class _SportCategoryCardState extends State<_SportCategoryCard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final primary = context.primaryColor;
    final surf    = context.surfaceColor;
    final surf2   = context.surface2Color;
    final border  = context.borderColor;
    final txt     = context.textColor;

    return GestureDetector(
      onTap: widget.onTap,
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        transform: Matrix4.translationValues(0, _pressed ? -3 : 0, 0),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: _pressed ? surf2 : surf,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: _pressed ? primary.withValues(alpha: 0.5) : border,
          ),
          boxShadow: _pressed
              ? [BoxShadow(color: primary.withValues(alpha: 0.12), blurRadius: 20)]
              : [
                  if (!context.isDark)
                    BoxShadow(color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 6, offset: const Offset(0, 2)),
                ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 52, height: 52,
              decoration: BoxDecoration(
                color: (_pressed ? primary : primary.withValues(alpha: 0.12)),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Center(child: Icon(
                widget.category.icon,
                color: _pressed ? Colors.white : primary,
                size: 26,
              )),
            ),
            const SizedBox(height: 10),
            Text(widget.category.displayName,
              style: AppTextStyles.heading(15, color: txt), textAlign: TextAlign.center),
            const SizedBox(height: 4),
            Text('${widget.category.activeCount} active →',
              style: AppTextStyles.body(11, color: primary, weight: FontWeight.w700)),
            const SizedBox(height: 8),
            Container(width: 28, height: 2,
              decoration: BoxDecoration(color: primary, borderRadius: BorderRadius.circular(99))),
          ],
        ),
      ),
    );
  }
}
