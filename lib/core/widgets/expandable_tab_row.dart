// lib/core/widgets/expandable_tab_row.dart
//
// ──────────────────────────────────────────────────────────────
//  OPTION A  –  Floating Horizontal Expandable Tab Row
//
//  Behaviour (matches the HTML preview exactly):
//   • Inactive tabs  → icon only, muted colour
//   • Active tab     → pill background + icon + label springs open
//                      with elastic overshoot (cubic-bezier spring)
//   • Separator      → thin vertical divider between tab groups
//   • The whole row  → frosted-glass pill, floating box-shadow
// ──────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../constants/app_constants.dart';

// ── Data model for one tab item ─────────────────────────────────
class ExpandableTabItem {
  final IconData icon;
  final String label;
  final bool isSeparatorBefore; // draws a thin divider before this item

  const ExpandableTabItem({
    required this.icon,
    required this.label,
    this.isSeparatorBefore = false,
  });
}

class ExpandableTab {
  final String? title;
  final IconData? icon;
  final bool isSeparator;

  const ExpandableTab({this.title, this.icon}) : isSeparator = false;
  const ExpandableTab.separator() : title = null, icon = null, isSeparator = true;
}

// ── Main widget ─────────────────────────────────────────────────
class ExpandableTabs extends StatefulWidget {
  final List<ExpandableTab> tabs;
  final int initialIndex;
  final ValueChanged<int?> onChange;
  final Color? activeColor;
  final EdgeInsets? padding;

  const ExpandableTabs({
    super.key,
    required this.tabs,
    required this.initialIndex,
    required this.onChange,
    this.activeColor,
    this.padding,
  });

  @override
  State<ExpandableTabs> createState() => _ExpandableTabsState();
}

class _ExpandableTabsState extends State<ExpandableTabs> {
  late int _selectedIndex;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final activeColor = widget.activeColor ?? (isDark ? DarkColors.primary : DarkColors.primary);
    
    return Container(
      padding: widget.padding ?? const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: isDark ? DarkColors.surface2 : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isDark ? DarkColors.primary.withValues(alpha: 0.18) : DarkColors.primary.withValues(alpha: 0.12),
        ),
        boxShadow: [
          BoxShadow(
            color: isDark ? DarkColors.primary.withValues(alpha: 0.15) : DarkColors.primary.withValues(alpha: 0.10),
            blurRadius: 24,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(widget.tabs.length, (index) {
          final tab = widget.tabs[index];
          if (tab.isSeparator) {
            return Container(
              width: 1,
              height: 22,
              margin: const EdgeInsets.symmetric(horizontal: 4),
              color: isDark ? Colors.white.withValues(alpha: 0.08) : DarkColors.primary.withValues(alpha: 0.12),
            );
          }
          
          final isActive = _selectedIndex == index;
          return GestureDetector(
            onTap: () {
              setState(() => _selectedIndex = index);
              widget.onChange(index);
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 320),
              curve: const Cubic(0.34, 1.56, 0.64, 1),
              padding: EdgeInsets.symmetric(horizontal: isActive ? 14 : 10, vertical: 8),
              decoration: BoxDecoration(
                color: isActive ? activeColor.withValues(alpha: 0.12) : Colors.transparent,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(
                    tab.icon,
                    size: 20,
                    color: isActive ? activeColor : (isDark ? Colors.white38 : Colors.black38),
                  ),
                  if (isActive)
                    Padding(
                      padding: const EdgeInsets.only(left: 6),
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 120),
                        child: Text(
                          tab.title!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w600,
                            color: activeColor,
                            letterSpacing: 0.15,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          );
        }),
        ),
      ),
    );
  }
}

// ── Main widget ─────────────────────────────────────────────────
class ExpandableTabRow extends StatefulWidget {

  final List<ExpandableTabItem> tabs;
  final int selectedIndex;
  final ValueChanged<int> onTabSelected;

  /// Active pill colour (defaults to MUST Blue / Sky-Blue in dark)
  final Color? activeColor;

  /// Icon colour when active (defaults to [activeColor])
  final Color? activeIconColor;

  /// Background of the whole floating row
  final Color? rowBackground;

  const ExpandableTabRow({
    super.key,
    required this.tabs,
    required this.selectedIndex,
    required this.onTabSelected,
    this.activeColor,
    this.activeIconColor,
    this.rowBackground,
  });

  @override
  State<ExpandableTabRow> createState() => _ExpandableTabRowState();
}

class _ExpandableTabRowState extends State<ExpandableTabRow>
    with TickerProviderStateMixin {
  // One AnimationController per tab for the label-width spring
  late List<AnimationController> _controllers;
  late List<Animation<double>> _widthAnims;
  late List<Animation<double>> _opacityAnims;

  static const _spring = Cubic(0.34, 1.56, 0.64, 1); // matches HTML preview
  static const _expandDuration = Duration(milliseconds: 320);
  static const _collapseDuration = Duration(milliseconds: 200);

  @override
  void initState() {
    super.initState();
    _buildAnimations();
    // Kick off the initially selected tab immediately (no animation on load)
    _controllers[widget.selectedIndex].value = 1.0;
  }

  void _buildAnimations() {
    _controllers = List.generate(widget.tabs.length, (i) {
      return AnimationController(
        vsync: this,
        duration: _expandDuration,
        reverseDuration: _collapseDuration,
      );
    });

    _widthAnims = _controllers.map((c) {
      return Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(parent: c, curve: _spring),
      );
    }).toList();

    _opacityAnims = _controllers.map((c) {
      return Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(
          parent: c,
          curve: const Interval(0.3, 1.0, curve: Curves.easeIn),
        ),
      );
    }).toList();
  }

  @override
  void didUpdateWidget(ExpandableTabRow oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedIndex != widget.selectedIndex) {
      // Collapse old, expand new
      _controllers[oldWidget.selectedIndex].reverse();
      _controllers[widget.selectedIndex].forward();
    }
    // Rebuild if tab count changed
    if (oldWidget.tabs.length != widget.tabs.length) {
      for (final c in _controllers) {
        c.dispose();
      }
      _buildAnimations();
      _controllers[widget.selectedIndex].value = 1.0;
    }
  }

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final activeColor = widget.activeColor ??
        (isDark ? DarkColors.primary : DarkColors.primary);
    final rowBg = widget.rowBackground ??
        (isDark ? DarkColors.surface2 : Colors.white);
    final borderColor =
        isDark ? DarkColors.primary.withValues(alpha: 0.18) : DarkColors.primary.withValues(alpha: 0.12);
    final shadowColor =
        isDark ? DarkColors.primary.withValues(alpha: 0.15) : DarkColors.primary.withValues(alpha: 0.10);

    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: rowBg,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: borderColor),
        boxShadow: [
          BoxShadow(
            color: shadowColor,
            blurRadius: 24,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: _buildChildren(activeColor, isDark),
        ),
      ),
    );
  }

  List<Widget> _buildChildren(Color activeColor, bool isDark) {
    final children = <Widget>[];
    for (int i = 0; i < widget.tabs.length; i++) {
      final tab = widget.tabs[i];
      if (tab.isSeparatorBefore) {
        children.add(_buildSeparator(isDark));
      }
      children.add(
        _ExpandableTabButton(
          icon: tab.icon,
          label: tab.label,
          isActive: i == widget.selectedIndex,
          activeColor: activeColor,
          widthAnim: _widthAnims[i],
          opacityAnim: _opacityAnims[i],
          onTap: () => widget.onTabSelected(i),
        ),
      );
    }
    return children;
  }

  Widget _buildSeparator(bool isDark) {
    return Container(
      width: 1,
      height: 22,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      color: isDark
          ? Colors.white.withValues(alpha: 0.08)
          : DarkColors.primary.withValues(alpha: 0.12),
    );
  }
}

// ── Individual animated tab button ──────────────────────────────
class _ExpandableTabButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final Color activeColor;
  final Animation<double> widthAnim;
  final Animation<double> opacityAnim;
  final VoidCallback onTap;

  const _ExpandableTabButton({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.activeColor,
    required this.widthAnim,
    required this.opacityAnim,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final mutedColor = isDark ? Colors.white38 : Colors.black38;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeInOut,
        padding: EdgeInsets.symmetric(
          horizontal: isActive ? 14 : 10,
          vertical: 8,
        ),
        decoration: BoxDecoration(
          color: isActive ? activeColor.withValues(alpha: 0.12) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon — always visible, colour transitions implicitly
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: Icon(
                icon,
                key: ValueKey(isActive),
                size: 20,
                color: isActive ? activeColor : mutedColor,
              ),
            ),

            // Label — springs open/closed via SizeTransition
            AnimatedBuilder(
              animation: widthAnim,
              builder: (context, child) {
                const maxLabelWidth = 90.0;
                return SizedBox(
                  width: widthAnim.value * maxLabelWidth,
                  child: child,
                );
              },
              child: FadeTransition(
                opacity: opacityAnim,
                child: Padding(
                  padding: const EdgeInsets.only(left: 6),
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    softWrap: false,
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                      color: activeColor,
                      letterSpacing: 0.15,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Convenience: centred floating row (wraps in Center + horizontal padding) ─
class FloatingExpandableTabRow extends StatelessWidget {
  final List<ExpandableTabItem> tabs;
  final int selectedIndex;
  final ValueChanged<int> onTabSelected;
  final Color? activeColor;
  final EdgeInsets padding;

  const FloatingExpandableTabRow({
    super.key,
    required this.tabs,
    required this.selectedIndex,
    required this.onTabSelected,
    this.activeColor,
    this.padding = const EdgeInsets.symmetric(
      horizontal: AppSizes.paddingM,
      vertical: AppSizes.paddingS,
    ),
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: Center(
        child: ExpandableTabRow(
          tabs: tabs,
          selectedIndex: selectedIndex,
          onTabSelected: onTabSelected,
          activeColor: activeColor,
        ),
      ),
    );
  }
}
