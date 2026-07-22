import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/widgets.dart';
import '../../../core/state/app_state.dart';
import '../../../core/models/models.dart';
import '../../../l10n/app_localizations.dart';

class EventsScreen extends StatelessWidget {
  const EventsScreen({super.key});

  static const _filters = [
    SportCategory.all, SportCategory.football, SportCategory.padel,
    SportCategory.basketball, SportCategory.volleyball,
  ];

  @override
  Widget build(BuildContext context) {
    final l        = AppLocalizations.of(context)!;
    final state    = context.watch<AppState>();
    final filtered = state.filteredEvents;
    final current  = state.eventFilter;
    final primary  = context.primaryColor;
    final muted    = context.mutedColor;
    final surf     = context.surfaceColor;
    final border   = context.borderColor;
    final txt      = context.textColor;
    final hPad     = context.hPadding;

    return Scaffold(
      backgroundColor: context.bgColor,
      appBar: AppBar(
        backgroundColor: context.bgColor,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: context.textColor, size: 20),
          onPressed: () {
            if (Navigator.canPop(context)) {
              Navigator.pop(context);
            } else {
              context.read<AppState>().setNavIndex(0);
            }
          },
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Divider(height: 1, color: context.borderColor),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(hPad, 20, hPad, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l.eventsAndTournaments, style: AppTextStyles.display(28, color: txt, context: context)),
                const SizedBox(height: 4),
                Text(l.competeWinRepresent, style: AppTextStyles.body(16, color: muted, context: context)),
                const SizedBox(height: 16),
                const MusterDivider(),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: _filters.map((cat) {
                      final active = current == cat;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: GestureDetector(
                          onTap: () => context.read<AppState>().setEventFilter(cat),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 180),
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: active ? primary.withValues(alpha: 0.12) : surf,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: active ? primary : border),
                            ),
                            child: Text(
                              cat == SportCategory.all ? l.all : cat.displayName,
                              style: AppTextStyles.body(16,
                                color: active ? primary : muted,
                                weight: FontWeight.w700,
                                context: context),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
          Expanded(
            child: filtered.isEmpty
                ? _EmptyState(onClear: () =>
                    context.read<AppState>().setEventFilter(SportCategory.all))
                : ListView.separated(
                    padding: EdgeInsets.only(
                      left: hPad, right: hPad,
                      bottom: MediaQuery.of(context).padding.bottom + 90,
                    ),
                    itemCount: filtered.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 14),
                    itemBuilder: (ctx, i) => StaggerItem(
                      delay: Duration(milliseconds: (i * 55).clamp(0, 450)),
                      child: _EventCard(event: filtered[i]),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

class _EventCard extends StatelessWidget {
  final SportEvent event;
  const _EventCard({required this.event});

  Color _statusColor(BuildContext ctx) => switch (event.status) {
    EventStatus.open      => ctx.secondaryColor,
    EventStatus.full      => ctx.errorColor,
    EventStatus.soon      => ctx.mutedColor,
    EventStatus.completed => ctx.mutedColor,
  };

  String _statusLabel(AppLocalizations l) => switch (event.status) {
    EventStatus.open      => l.registrationOpen,
    EventStatus.full      => l.eventFull,
    EventStatus.soon      => l.comingSoon,
    EventStatus.completed => l.completed,
  };

  @override
  Widget build(BuildContext context) {
    final l          = AppLocalizations.of(context)!;
    final state      = context.watch<AppState>();
    final isEnrolled = state.isEnrolled(event);
    final fillRatio  = event.fillRatio;
    final statusCol  = _statusColor(context);
    final barColor   = fillRatio > 0.85 ? context.errorColor : context.primaryColor;
    final second     = context.secondaryColor;
    final muted      = context.mutedColor;
    final txt        = context.textColor;

    return AppCard(
      glowColor: isEnrolled ? second : null,
      gradient: isEnrolled
          ? LinearGradient(colors: [
              second.withValues(alpha: context.isDark ? 0.06 : 0.08),
              context.surfaceColor,
            ], begin: Alignment.topLeft, end: Alignment.bottomRight)
          : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Flexible(
              child: Align(
                alignment: Alignment.centerLeft,
                child: AppPill(label: _statusLabel(l), color: statusCol),
              ),
            ),
            const SizedBox(width: 8),
            Flexible(
              flex: 2,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Icon(Icons.schedule_rounded, size: 13, color: muted),
                  const SizedBox(width: 3),
                  Flexible(
                    child: Text(
                      '${event.daysLeft}${l.daysLeft}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.end,
                      style: AppTextStyles.body(13, color: muted, context: context),
                    ),
                  ),
                ],
              ),
            ),
          ]),
          const SizedBox(height: 10),
          Text(event.title,
            maxLines: 2, overflow: TextOverflow.ellipsis,
            style: AppTextStyles.heading(18, color: txt, context: context)),
          const SizedBox(height: 4),
          Text('${event.dateRangeLabel} · ${event.location}',
            maxLines: 1, overflow: TextOverflow.ellipsis,
            style: AppTextStyles.body(14, color: muted, context: context)),
          const SizedBox(height: 12),
          AppProgressBar(value: fillRatio, color: barColor, height: 4),
          const SizedBox(height: 10),
          Row(children: [
            Expanded(child: Text('${event.participants}/${event.maxParticipants} spots',
              maxLines: 1, overflow: TextOverflow.ellipsis,
              style: AppTextStyles.body(14, color: muted, context: context))),
            const SizedBox(width: 8),
            Flexible(
              child: event.status == EventStatus.open
                  ? _EnrollButton(event: event, isEnrolled: isEnrolled)
                  : AppPill(label: _statusLabel(l), color: statusCol),
            ),
          ]),
        ],
      ),
    );
  }
}

class _EnrollButton extends StatelessWidget {
  final SportEvent event;
  final bool isEnrolled;
  const _EnrollButton({required this.event, required this.isEnrolled});

  @override
  Widget build(BuildContext context) {
    final l      = AppLocalizations.of(context)!;
    final second = context.secondaryColor;
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        final msg = context.read<AppState>().enrollWithNotification(event);
        context.read<AppState>().showToast(msg);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 9),
        decoration: BoxDecoration(
          color: isEnrolled ? second.withValues(alpha: 0.12) : second,
          borderRadius: BorderRadius.circular(20),
          border: isEnrolled ? Border.all(color: second.withValues(alpha: 0.5)) : null,
        ),
        child: Text(
          isEnrolled ? l.registered : l.register,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: AppTextStyles.body(16,
            color: isEnrolled ? second : (context.isDark ? const Color(0xFF0a1a04) : Colors.white),
            weight: FontWeight.w800,
            context: context),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final VoidCallback onClear;
  const _EmptyState({required this.onClear});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return Center(
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        const Icon(Icons.search_off_rounded, size: 48, color: Color(0xFF5A7090)),
        const SizedBox(height: 16),
        Text(l.noEventsInCategory, style: AppTextStyles.body(16, color: context.mutedColor, context: context)),
        const SizedBox(height: 16),
        GestureDetector(
          onTap: onClear,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            decoration: BoxDecoration(
              color: context.surfaceColor,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: context.borderColor),
            ),
            child: Text(l.clearFilter,
              style: AppTextStyles.body(15, color: context.primaryColor, weight: FontWeight.w600, context: context)),
          ),
        ),
      ]),
    );
  }
}
