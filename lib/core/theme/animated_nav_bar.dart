// ─── SHARED ANIMATED NAV BAR ─────────────────────────────────────────────────
// Used by AppShell (student), AdminShell (admin/coach) and CoachShell.
// Extracted so all roles share the exact same animation logic.

import 'package:flutter/material.dart';
import 'app_theme.dart';

// ─── NAV ITEM DATA ────────────────────────────────────────────────────────────
class NavItemData {
  final String   label;
  final IconData icon;
  final bool     hasBadge;
  final int      badgeCount;

  const NavItemData({
    required this.label,
    required this.icon,
    this.hasBadge  = false,
    this.badgeCount = 0,
  });
}

// ─── ANIMATED EXPANDABLE TAB BAR ─────────────────────────────────────────────
class AnimatedNavBar extends StatelessWidget {
  final int      currentIndex;
  final List<NavItemData> items;
  final Color    primary;
  final Color    muted;
  final Color    surface2;
  final Color    border;
  final Color    errorColor;
  final bool     isDark;
  final void Function(int) onTap;

  const AnimatedNavBar({
    super.key,
    required this.currentIndex,
    required this.items,
    required this.primary,
    required this.muted,
    required this.surface2,
    required this.border,
    required this.errorColor,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: isDark ? DarkColors.bg : LightColors.bg,
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 68,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 6, 12, 8),
            child: Container(
              decoration: BoxDecoration(
                color: surface2,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: border),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.08),
                    blurRadius: 20,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 5),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: List.generate(
                  items.length,
                  (i) => Expanded(
                    flex: currentIndex == i ? 3 : 2,
                    child: AnimatedNavItem(
                      data:        items[i],
                      index:       i,
                      totalCount:  items.length,
                      activeIndex: currentIndex,
                      isActive:    currentIndex == i,
                      primary:     primary,
                      muted:       muted,
                      surface2:    surface2,
                      errorColor:  errorColor,
                      onTap:       () => onTap(i),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─── ANIMATED NAV ITEM ────────────────────────────────────────────────────────
class AnimatedNavItem extends StatefulWidget {
  final NavItemData  data;
  final bool         isActive;
  final int          index;
  final int          totalCount;
  final int          activeIndex;
  final Color        primary;
  final Color        muted;
  final Color        surface2;
  final Color        errorColor;
  final VoidCallback onTap;

  const AnimatedNavItem({
    super.key,
    required this.data,
    required this.isActive,
    required this.index,
    required this.totalCount,
    required this.activeIndex,
    required this.primary,
    required this.muted,
    required this.surface2,
    required this.errorColor,
    required this.onTap,
  });

  @override
  State<AnimatedNavItem> createState() => _AnimatedNavItemState();
}

class _AnimatedNavItemState extends State<AnimatedNavItem>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double>   _scaleDown;
  late final Animation<double>   _bounce;
  bool _prevActive = false;

  @override
  void initState() {
    super.initState();
    _prevActive = widget.isActive;
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 380),
    );
    _scaleDown = Tween<double>(begin: 1.0, end: 0.85).animate(
      CurvedAnimation(
        parent: _ctrl,
        curve: const Interval(0.0, 0.28, curve: Curves.easeIn),
      ),
    );
    _bounce = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(
        parent: _ctrl,
        curve: const Interval(0.28, 1.0, curve: Curves.elasticOut),
      ),
    );
  }

  @override
  void didUpdateWidget(AnimatedNavItem old) {
    super.didUpdateWidget(old);
    if (!_prevActive && widget.isActive) {
      _ctrl.forward(from: 0);
    }
    _prevActive = widget.isActive;
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  double get _combinedScale {
    if (_ctrl.value <= 0.0)  return 1.0;
    if (_ctrl.value <= 0.28) return _scaleDown.value;
    return _bounce.value;
  }

  @override
  Widget build(BuildContext context) {
    final distRight  = widget.index - widget.activeIndex;
    final isLastItem = widget.index == widget.totalCount - 1;

    // Softly fade the last icon when the active pill is immediately to its left.
    final fadeOpacity = (!widget.isActive && isLastItem && distRight == 1)
        ? 0.25
        : 1.0;

    return GestureDetector(
      onTap: widget.onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox.expand(
        child: AnimatedBuilder(
          animation: _ctrl,
          builder: (_, child) => Transform.scale(
            scale: _combinedScale,
            child: child,
          ),
          child: AnimatedOpacity(
            duration: const Duration(milliseconds: 260),
            curve: Curves.easeOut,
            opacity: fadeOpacity,
            child: Center(
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeOut,
                padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 7),
                decoration: widget.isActive
                    ? BoxDecoration(
                        color: widget.primary.withValues(alpha: 0.13),
                        borderRadius: BorderRadius.circular(14),
                      )
                    : null,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // ── Icon + badge ──────────────────────────────────────
                    Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Icon(
                          widget.data.icon,
                          size: 18,
                          color: widget.isActive ? widget.primary : widget.muted,
                        ),
                        if (widget.data.hasBadge)
                          Positioned(
                            top: -4, right: -6,
                            child: Container(
                              width: 15, height: 15,
                              decoration: BoxDecoration(
                                color: widget.errorColor,
                                shape: BoxShape.circle,
                                border: Border.all(
                                    color: widget.surface2, width: 1.5),
                              ),
                              child: Center(
                                child: Text(
                                  '${widget.data.badgeCount}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 8,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                    // ── Animated label — Flexible keeps long localized labels inside the tab slot
                    Flexible(
                      child: ClipRect(
                        child: AnimatedSize(
                          duration: const Duration(milliseconds: 280),
                          curve: Curves.easeOutCubic,
                          alignment: Alignment.centerLeft,
                          child: widget.isActive
                              ? Padding(
                                  padding: const EdgeInsets.only(left: 3),
                                  child: Text(
                                    widget.data.label,
                                    style: AppTextStyles.body(
                                      10.5,
                                      color: widget.primary,
                                      weight: FontWeight.w700,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    softWrap: false,
                                  ),
                                )
                              : const SizedBox.shrink(),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
