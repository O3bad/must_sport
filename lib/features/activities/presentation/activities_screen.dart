import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/theme_provider.dart';
import '../../../core/models/models.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/widgets.dart';
import '../../../core/state/app_state.dart';
import '../../../core/state/activity_state.dart';
import '../../../core/models/activity_models.dart';
import '../../../core/widgets/expandable_tab_row.dart';
import 'activity_detail_screen.dart';
import '../../../l10n/app_localizations.dart';

class ActivitiesScreen extends StatefulWidget {
  const ActivitiesScreen({super.key});
  @override
  State<ActivitiesScreen> createState() => _ActivitiesScreenState();
}

class _ActivitiesScreenState extends State<ActivitiesScreen>
    with SingleTickerProviderStateMixin {
  ActivityCategory? _filter;
  final _search = TextEditingController();
  String _query = '';
  late TabController _tab;   // Sports | Arts | All

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _search.dispose();
    _tab.dispose();
    super.dispose();
  }

  List<ActivityModel> _baseList(int tabIdx) {
    switch (tabIdx) {
      case 0:  return kAllActivities.where((a) => !a.category.isArts).toList();
      case 1:  return kAllActivities.where((a) =>  a.category.isArts).toList();
      default: return kAllActivities;
    }
  }

  List<ActivityModel> _filtered(int tabIdx, BuildContext context) {
    return _baseList(tabIdx).where((a) {
      final matchCat = _filter == null || a.category == _filter;
      final q = _query.toLowerCase();
      final matchQ   = _query.isEmpty ||
          a.name.toLowerCase().contains(q) ||
          a.category.displayName(context).toLowerCase().contains(q) ||
          a.category.emoji.contains(q);
      return matchCat && matchQ;
    }).toList();
  }

  // Category chips for the current tab
  List<ActivityCategory> _catsForTab(int tabIdx) {
    switch (tabIdx) {
      case 0: return [
        ActivityCategory.teamSports,
        ActivityCategory.racketSports,
        ActivityCategory.individual,
        ActivityCategory.combatSports,
        ActivityCategory.aquatics,
        ActivityCategory.wellness,
        ActivityCategory.mindSports,
      ];
      case 1: return [
        ActivityCategory.performingArts,
        ActivityCategory.music,
        ActivityCategory.literaryArts,
      ];
      default: return ActivityCategory.values.toList();
    }
  }

  @override
  Widget build(BuildContext context) {
    final primary  = context.primaryColor;
    final second   = context.secondaryColor;
    final txt      = context.textColor;
    final muted    = context.mutedColor;
    final border   = context.borderColor;
    final bg       = context.bgColor;
    final regState = context.watch<ActivityRegistrationState>();
    final user     = context.read<AppState>().user;
    final isStudent = user.role == UserRole.student;

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: bg,
        surfaceTintColor: Colors.transparent,
        title: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(AppLocalizations.of(context)!.activitiesTitle,
              maxLines: 1, overflow: TextOverflow.ellipsis,
              style: AppTextStyles.display(28, color: txt, context: context)),
          Text(AppLocalizations.of(context)!.activitiesSubtitle,
              maxLines: 1, overflow: TextOverflow.ellipsis,
              style: AppTextStyles.body(15, color: muted, context: context)),
        ]),
        actions: const [_ThemeToggleBtn()],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(49),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Divider(height: 1, color: border),
            TabBar(
              controller: _tab,
              isScrollable: true,
              tabAlignment: TabAlignment.start,
              onTap: (_) => setState(() => _filter = null),
              labelColor: primary,
              unselectedLabelColor: muted,
              indicatorColor: primary,
              indicatorSize: TabBarIndicatorSize.label,
              labelStyle: AppTextStyles.body(14, weight: FontWeight.w700, context: context),
              unselectedLabelStyle: AppTextStyles.body(12.5, context: context),
              tabs: [
                Tab(child: Row(mainAxisSize: MainAxisSize.min, children: [
                  const Icon(Icons.sports_soccer_rounded, size: 14),
                  const SizedBox(width: 4),
                  Text(AppLocalizations.of(context)!.sports, maxLines: 1),
                ])),
                Tab(child: Row(mainAxisSize: MainAxisSize.min, children: [
                  const Icon(Icons.theater_comedy_rounded, size: 14),
                  const SizedBox(width: 4),
                  Text(AppLocalizations.of(context)!.arts, maxLines: 1),
                ])),
                Tab(text: AppLocalizations.of(context)!.all24),
              ],
            ),
          ]),
        ),
      ),
      body: TabBarView(
        controller: _tab,
        children: List.generate(3, (tabIdx) =>
          _ActivityTabContent(
            key: ValueKey(tabIdx),
            filtered: _filtered(tabIdx, context),
            cats: _catsForTab(tabIdx),
            filter: _filter,
            query: _query,
            search: _search,
            isStudent: isStudent,
            regState: regState,
            userEmail: user.email,
            primary: primary,
            second: second,
            onFilterChange: (c) => setState(() => _filter = c),
            onQueryChange: (q) => setState(() => _query = q),
          ),
        ),
      ),
    );
  }
}

// ─── TAB CONTENT ─────────────────────────────────────────────────────────────
class _ActivityTabContent extends StatelessWidget {
  final List<ActivityModel>     filtered;
  final List<ActivityCategory>  cats;
  final ActivityCategory?       filter;
  final String                  query;
  final TextEditingController   search;
  final bool                    isStudent;
  final ActivityRegistrationState regState;
  final String                  userEmail;
  final Color                   primary;
  final Color                   second;
  final void Function(ActivityCategory?) onFilterChange;
  final void Function(String)            onQueryChange;

  const _ActivityTabContent({
    super.key,
    required this.filtered,
    required this.cats,
    required this.filter,
    required this.query,
    required this.search,
    required this.isStudent,
    required this.regState,
    required this.userEmail,
    required this.primary,
    required this.second,
    required this.onFilterChange,
    required this.onQueryChange,
  });

  @override
  Widget build(BuildContext context) {
    final muted  = context.mutedColor;
    final border = context.borderColor;
    final bg     = context.bgColor;
    final hPad   = context.hPadding;

    // Map ActivityCategory → ExpandableTab (icon + label)
    IconData catIcon(ActivityCategory c) => switch (c) {
      ActivityCategory.teamSports     => Icons.groups_rounded,
      ActivityCategory.racketSports   => Icons.sports_tennis_rounded,
      ActivityCategory.individual     => Icons.directions_run_rounded,
      ActivityCategory.combatSports   => Icons.sports_martial_arts_rounded,
      ActivityCategory.aquatics       => Icons.pool_rounded,
      ActivityCategory.wellness       => Icons.self_improvement_rounded,
      ActivityCategory.mindSports     => Icons.psychology_rounded,
      ActivityCategory.performingArts => Icons.theater_comedy_rounded,
      ActivityCategory.music          => Icons.music_note_rounded,
      ActivityCategory.literaryArts   => Icons.menu_book_rounded,
    };

    // Build tab list: "All" first, then one tab per category, with a separator
    final allTab = ExpandableTab(
      title: AppLocalizations.of(context)!.all,
      icon: Icons.apps_rounded,
    );
    final catTabs = cats.map((c) {
      return ExpandableTab(title: c.displayName(context), icon: catIcon(c));
    }).toList();

    final expandTabs = <ExpandableTab>[
      allTab,
      if (catTabs.isNotEmpty) const ExpandableTab.separator(),
      ...catTabs,
    ];

    // Map selected expandable index back to a category
    void onTabChange(int? idx) {
      if (idx == null || idx == 0) {
        onFilterChange(null);
        return;
      }
      // idx 1 is separator — skip; real cats start at idx 2
      final catIdx = idx - 2; // account for "All" (0) + separator (1)
      if (catIdx >= 0 && catIdx < cats.length) {
        final tapped = cats[catIdx];
        onFilterChange(filter == tapped ? null : tapped);
      }
    }

    // Compute initial index from current filter
    int? initialIdx;
    if (filter != null) {
      final ci = cats.indexOf(filter!);
      if (ci >= 0) initialIdx = ci + 2; // +2 for "All" + separator
    } else {
      initialIdx = 0;
    }

    return Column(children: [
      // ── Search ─────────────────────────────────────────────────────────
      Container(
        color: bg,
        padding: EdgeInsets.fromLTRB(hPad, 12, hPad, 0),
        child: TextField(
          controller: search,
          onChanged: onQueryChange,
          style: AppTextStyles.body(16, color: context.textColor, context: context),
          decoration: InputDecoration(
            hintText: AppLocalizations.of(context)!.searchActivities,
            hintStyle: AppTextStyles.body(16, color: muted, context: context),
            prefixIcon: const Icon(Icons.search, size: 20),
            prefixIconColor: muted,
            suffixIcon: query.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.close, size: 18), color: muted,
                    onPressed: () { search.clear(); onQueryChange(''); })
                : null,
            filled: true, fillColor: context.surfaceColor,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(color: border)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(color: primary, width: 1.5)),
          ),
        ),
      ),

      // ── ExpandableTabs filter row ───────────────────────────────────────
      Container(
        color: bg,
        padding: EdgeInsets.fromLTRB(hPad, 10, hPad, 12),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          clipBehavior: Clip.none,
          child: ExpandableTabs(
            key: ValueKey('${cats.length}_${filter?.name}'),
            tabs: expandTabs,
            initialIndex: initialIdx ?? 0,
            activeColor: primary,
            onChange: (int? idx) => onTabChange(idx),
            padding: const EdgeInsets.all(5),
          ),
        ),
      ),

      Divider(height: 1, color: border),
      // ── List ──────────────────────────────────────────────────────────────
      Expanded(
        child: filtered.isEmpty
            ? Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
                const Icon(Icons.search_rounded, size: 30, color: Color(0xFF5A7090)),
                const SizedBox(height: 12),
                Text(AppLocalizations.of(context)!.noActivitiesFound, style: AppTextStyles.body(15, color: muted, context: context)),
              ]))
            : ListView.separated(
                padding: EdgeInsets.fromLTRB(hPad, 16, hPad, 100),
                itemCount: filtered.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (ctx, i) {
                  final a   = filtered[i];
                  final reg = regState.hasRegistered(userEmail, a.id);
                  return StaggerItem(
                    delay: Duration(milliseconds: (i * 50).clamp(0, 400)),
                    child: _ActivityCard(
                      activity: a,
                      isRegistered: reg,
                      isStudent: isStudent,
                      onTap: () => Navigator.push(ctx,
                          MaterialPageRoute(builder: (_) =>
                              ActivityDetailScreen(activity: a, isRegistered: reg))),
                    ),
                  );
                },
              ),
      ),
    ]);
  }
}

// ─── CATEGORY CHIP ────────────────────────────────────────────────────────────
class _CategoryChip extends StatefulWidget {
  final String label;
  final bool selected;
  final Color color;
  final VoidCallback onTap;
  const _CategoryChip({required this.label, required this.selected,
      required this.color, required this.onTap});

  @override
  State<_CategoryChip> createState() => _CategoryChipState();
}

class _CategoryChipState extends State<_CategoryChip> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: widget.selected ? widget.color : context.surfaceColor,
          border: Border.all(color: widget.selected ? widget.color : context.borderColor),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(widget.label, style: AppTextStyles.body(15,
            color: widget.selected ? context.bgColor : context.mutedColor,
            weight: FontWeight.w600, context: context)),
      ),
    );
  }
}

// ─── ACTIVITY CARD ────────────────────────────────────────────────────────────
class _ActivityCard extends StatelessWidget {
  final ActivityModel activity;
  final bool isRegistered;
  final bool isStudent;
  final VoidCallback onTap;
  const _ActivityCard({required this.activity, required this.isRegistered,
      required this.isStudent, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final primary  = context.primaryColor;
    final second   = context.secondaryColor;
    final accent   = context.accentColor;
    final txt      = context.textColor;
    final muted    = context.mutedColor;
    final border   = context.borderColor;
    final surf     = context.surfaceColor;
    final isArts   = activity.category.isArts;

    // Arts cards get a warm gradient accent; sports stay cool
    final accentColor = isArts ? accent : primary;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: surf,
          border: Border.all(
              color: isRegistered
                  ? second.withValues(alpha: 0.5)
                  : isArts
                      ? accent.withValues(alpha: 0.25)
                      : border),
          borderRadius: BorderRadius.circular(18),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            // Emoji in a small pill background
            Container(
              width: 52, height: 52,
              decoration: BoxDecoration(
                color: accentColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Center(child: Text(activity.emoji,
                  style: const TextStyle(fontSize: 28))),
            ),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(activity.name,
                maxLines: 2, overflow: TextOverflow.ellipsis,
                style: AppTextStyles.heading(18, color: txt, context: context)),
              const SizedBox(height: 2),
              Row(children: [
                Text(activity.category.emoji, style: const TextStyle(fontSize: 13)),
                const SizedBox(width: 4),
                Flexible(child: Text(activity.category.displayName(context),
                    style: AppTextStyles.body(14, color: muted, context: context),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1)),
              ]),
            ])),
            const SizedBox(width: 8),
            if (isRegistered)
              _Tag(label: AppLocalizations.of(context)!.enrolledTag, color: second)
            else
              _Tag(label: '${activity.slots} ${AppLocalizations.of(context)!.spots}', color: accentColor),
          ]),
          const SizedBox(height: 10),
          Text(activity.description,
              style: AppTextStyles.body(15, color: muted, context: context),
              maxLines: 2, overflow: TextOverflow.ellipsis),
          const SizedBox(height: 10),
          Wrap(spacing: 12, runSpacing: 4, children: [
            _InfoChip('📅', activity.schedule.split(' ').take(3).join(' ')),
            const SizedBox(width: 8),
            _InfoChip('📍', activity.venue.split('–').first.trim()),
            const SizedBox(width: 8),
            _InfoChip('🎯', activity.level),
          ]),
          const SizedBox(height: 12),
          context.isSmallPhone
              ? Column(children: [
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: onTap,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: muted,
                        side: BorderSide(color: border),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                      ),
                      child: Text(AppLocalizations.of(context)!.viewDetails,
                          style: AppTextStyles.body(15, color: muted, weight: FontWeight.w600, context: context)),
                    ),
                  ),
                  if (isStudent && !isRegistered) ...[
                    const SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: onTap,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: second,
                          foregroundColor: context.bgColor,
                          elevation: 0,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          padding: const EdgeInsets.symmetric(vertical: 10),
                        ),
                        child: Text(AppLocalizations.of(context)!.registerNowBtn,
                            style: AppTextStyles.body(15, color: context.bgColor,
                                weight: FontWeight.w700, context: context)),
                      ),
                    ),
                  ],
                ])
              : Row(children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: onTap,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: muted,
                        side: BorderSide(color: border),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                      ),
                      child: Text(AppLocalizations.of(context)!.viewDetails,
                          style: AppTextStyles.body(15, color: muted, weight: FontWeight.w600, context: context)),
                    ),
                  ),
                  if (isStudent && !isRegistered) ...[
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: onTap,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: second,
                          foregroundColor: context.bgColor,
                          elevation: 0,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          padding: const EdgeInsets.symmetric(vertical: 10),
                        ),
                        child: Text(AppLocalizations.of(context)!.registerNowBtn,
                            style: AppTextStyles.body(15, color: context.bgColor,
                                weight: FontWeight.w700, context: context)),
                      ),
                    ),
                  ],
                ]),
        ]),
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  final String label;
  final Color color;
  const _Tag({required this.label, required this.color});
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
    decoration: BoxDecoration(
      color: color.withValues(alpha: 0.15),
      border: Border.all(color: color.withValues(alpha: 0.4)),
      borderRadius: BorderRadius.circular(8),
    ),
    child: Text(label, style: AppTextStyles.label(color: color, context: context)
        .copyWith(fontSize: 11, letterSpacing: 0.3)),
  );
}

class _InfoChip extends StatelessWidget {
  final String icon, text;
  const _InfoChip(this.icon, this.text);
  @override
  Widget build(BuildContext context) => Row(mainAxisSize: MainAxisSize.min, children: [
    Text(icon, style: const TextStyle(fontSize: 11)),
    const SizedBox(width: 4),
    ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 140),
      child: Text(text,
        style: AppTextStyles.body(13, color: context.mutedColor, context: context),
        overflow: TextOverflow.ellipsis,
        maxLines: 1,
      ),
    ),
  ]);
}

// ─── MINIMAL THEME TOGGLE BUTTON ─────────────────────────────────────────────
class _ThemeToggleBtn extends StatelessWidget {
  const _ThemeToggleBtn();
  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final isDark = themeProvider.isDarkMode;
    final surf   = context.surfaceColor;
    final border = context.borderColor;
    return IconButton(
      onPressed: themeProvider.toggleTheme,
      icon: Container(
        width: 32, height: 32,
        decoration: BoxDecoration(color: surf, borderRadius: BorderRadius.circular(10),
            border: Border.all(color: border)),
        child: Center(child: Icon(isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded, size: 18, color: isDark ? DarkColors.accent : LightColors.navy))),
    );
  }
}

