import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/widgets.dart';
import '../../../core/state/app_state.dart';
import '../../../core/state/activity_state.dart';
import '../../../core/models/activity_models.dart';
import '../../../core/models/models.dart';
import '../../../l10n/app_localizations.dart';

class ParticipationHistoryScreen extends StatefulWidget {
  const ParticipationHistoryScreen({super.key});
  @override
  State<ParticipationHistoryScreen> createState() =>
      _ParticipationHistoryScreenState();
}

class _ParticipationHistoryScreenState extends State<ParticipationHistoryScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tab;

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l        = AppLocalizations.of(context)!;
    final state    = context.watch<AppState>();
    final regState = context.watch<ActivityRegistrationState>();
    final user     = state.user;
    final txt      = context.textColor;
    final muted    = context.mutedColor;
    final bg       = context.bgColor;
    final primary  = context.primaryColor;
    final second   = context.secondaryColor;
    final accent   = context.accentColor;
    final border   = context.borderColor;
    final hPad     = context.hPadding;

    final myRegs    = regState.forStudent(user.email);
    final approved  = myRegs.where((r) => r.status == RegistrationStatus.approved).toList();
    final events    = state.enrolledEvents;
    final bookings  = state.bookings;

    // Summary stats
    final totalParticipation = approved.length + events.length;
    final sportsCount = approved.where((r) => !r.activity.category.isArts).length;
    final artsCount   = approved.where((r) =>  r.activity.category.isArts).length;

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: bg,
        surfaceTintColor: Colors.transparent,
        title: Text(l.participationHistory,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.display(18, color: txt)),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(49),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Divider(height: 1, color: border),
            TabBar(
              controller: _tab,
              isScrollable: true,
              tabAlignment: TabAlignment.start,
              labelColor: primary,
              unselectedLabelColor: muted,
              indicatorColor: primary,
              indicatorSize: TabBarIndicatorSize.label,
              labelStyle: AppTextStyles.body(14, weight: FontWeight.w700),
              unselectedLabelStyle: AppTextStyles.body(12.5),
              tabs: [
                Tab(text: '${l.activities} (${approved.length})'),
                Tab(text: '${l.events} (${events.length})'),
                Tab(text: '${l.bookings} (${bookings.length})'),
              ],
            ),
          ]),
        ),
      ),
      body: Column(children: [
        // ── Summary banner ────────────────────────────────────────────────
        Container(
          color: bg,
          padding: EdgeInsets.fromLTRB(hPad, 12, hPad, 14),
          child: context.isSmallPhone
              ? GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  mainAxisSpacing: 8,
                  crossAxisSpacing: 8,
                  childAspectRatio: 2.2,
                  children: [
                    _SummaryPill(Icons.emoji_events_rounded, '$totalParticipation', 'Total', primary),
                    _SummaryPill(Icons.sports_rounded, '$sportsCount', 'Sports', second),
                    _SummaryPill(Icons.theater_comedy_rounded, '$artsCount', 'Arts', accent),
                    _SummaryPill(Icons.leaderboard_rounded, '${events.length}', 'Events', const Color(0xFFFFB547)),
                  ],
                )
              : Row(children: [
                  Expanded(child: _SummaryPill(Icons.emoji_events_rounded, '$totalParticipation', 'Total', primary)),
                  const SizedBox(width: 8),
                  Expanded(child: _SummaryPill(Icons.sports_rounded, '$sportsCount', 'Sports', second)),
                  const SizedBox(width: 8),
                  Expanded(child: _SummaryPill(Icons.theater_comedy_rounded, '$artsCount', 'Arts', accent)),
                  const SizedBox(width: 8),
                  Expanded(child: _SummaryPill(Icons.leaderboard_rounded, '${events.length}', 'Events', const Color(0xFFFFB547))),
                ]),
        ),
        Divider(height: 1, color: border),
        // ── Tab views ─────────────────────────────────────────────────────
        Expanded(
          child: TabBarView(
            controller: _tab,
            children: [
              // Activities tab
              approved.isEmpty
                  ? const _EmptyTab(icon: Icons.sports_rounded, message: 'No approved activity registrations yet.')
                  : ListView.separated(
                      padding: EdgeInsets.fromLTRB(hPad, 16, hPad, 100),
                      itemCount: approved.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 10),
                      itemBuilder: (_, i) => _ActivityHistoryCard(reg: approved[i]),
                    ),

              // Events tab
              events.isEmpty
                  ? const _EmptyTab(icon: Icons.emoji_events_rounded, message: 'You haven\'t enrolled in any events yet.')
                  : ListView.separated(
                      padding: EdgeInsets.fromLTRB(hPad, 16, hPad, 100),
                      itemCount: events.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 10),
                      itemBuilder: (_, i) => _EventHistoryCard(event: events[i]),
                    ),

              // Bookings tab
              bookings.isEmpty
                  ? const _EmptyTab(icon: Icons.calendar_month_rounded, message: 'No facility bookings yet.')
                  : ListView.separated(
                      padding: EdgeInsets.fromLTRB(hPad, 16, hPad, 100),
                      itemCount: bookings.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 10),
                      itemBuilder: (_, i) => _BookingHistoryCard(booking: bookings[i]),
                    ),
            ],
          ),
        ),
      ]),
    );
  }
}

// ─── SUMMARY PILL ─────────────────────────────────────────────────────────────
class _SummaryPill extends StatelessWidget {
  final IconData icon;
  final String value, label;
  final Color color;
  const _SummaryPill(this.icon, this.value, this.label, this.color);

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(vertical: 10),
    decoration: BoxDecoration(
      color: color.withValues(alpha: 0.1),
      border: Border.all(color: color.withValues(alpha: 0.3)),
      borderRadius: BorderRadius.circular(12),
    ),
    child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Icon(icon, color: color, size: 18),
      const SizedBox(height: 2),
      Text(value,
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: AppTextStyles.heading(16, color: color)),
      Text(label,
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: AppTextStyles.body(9.5, color: color)),
    ]),
  );
}

// ─── ACTIVITY HISTORY CARD ────────────────────────────────────────────────────
class _ActivityHistoryCard extends StatelessWidget {
  final ActivityRegistration reg;
  const _ActivityHistoryCard({required this.reg});

  @override
  Widget build(BuildContext context) {
    final txt    = context.textColor;
    final muted  = context.mutedColor;
    final surf   = context.surfaceColor;
    final second = context.secondaryColor;
    final accent = context.accentColor;
    final isArts = reg.activity.category.isArts;
    final c = isArts ? accent : second;

    return Container(
      decoration: BoxDecoration(
        color: surf,
        border: Border.all(color: c.withValues(alpha: 0.35)),
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.all(14),
      child: Row(children: [
        Container(
          width: 48, height: 48,
          decoration: BoxDecoration(
            color: c.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(13),
          ),
          child: Center(child: Icon(reg.activity.category.icon, color: c, size: 24)),
        ),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(reg.activity.name,
              maxLines: 1, overflow: TextOverflow.ellipsis,
              style: AppTextStyles.heading(14, color: txt)),
          const SizedBox(height: 3),
          Row(children: [
            Icon(reg.activity.category.icon, size: 12, color: muted),
            const SizedBox(width: 4),
            Flexible(
              child: Text(reg.activity.category.displayName(context),
                  style: AppTextStyles.body(15, color: muted),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 5),
              child: Text('·', style: AppTextStyles.body(15, color: muted)),
            ),
            Flexible(
              child: Text(reg.dateLabel,
                  style: AppTextStyles.body(15, color: muted),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1),
            ),
          ]),
          const SizedBox(height: 6),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              _SmallTag('Level: ${reg.level}', c),
              _SmallTag('✅ Enrolled', second),
            ],
          ),
        ])),
        // Points awarded
        Column(mainAxisSize: MainAxisSize.min, children: [
          Text('+50', style: AppTextStyles.display(18, color: c)),
          Text('pts', style: AppTextStyles.body(10, color: muted)),
        ]),
      ]),
    );
  }
}

// ─── EVENT HISTORY CARD ───────────────────────────────────────────────────────
class _EventHistoryCard extends StatelessWidget {
  final SportEvent event;
  const _EventHistoryCard({required this.event});

  @override
  Widget build(BuildContext context) {
    final txt    = context.textColor;
    final muted  = context.mutedColor;
    final surf   = context.surfaceColor;
    final accent = context.accentColor;

    final statusColor = switch (event.status) {
      EventStatus.open      => context.primaryColor,
      EventStatus.full      => context.errorColor,
      EventStatus.soon      => const Color(0xFFFFB547),
      EventStatus.completed => context.mutedColor,
    };

    return Container(
      decoration: BoxDecoration(
        color: surf,
        border: Border.all(color: accent.withValues(alpha: 0.3)),
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.all(14),
      child: Row(children: [
        Container(
          width: 48, height: 48,
          decoration: BoxDecoration(
            color: accent.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(13),
          ),
          child: Center(child: Icon(event.sportType.icon, color: accent, size: 24)),
        ),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(event.title,
              maxLines: 1, overflow: TextOverflow.ellipsis,
              style: AppTextStyles.heading(14, color: txt)),
          const SizedBox(height: 3),
          Row(children: [
            Flexible(
              child: Text(event.dateRangeLabel,
                  style: AppTextStyles.body(15, color: muted),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 5),
              child: Text('·', style: AppTextStyles.body(15, color: muted)),
            ),
            Flexible(
              child: Text(event.location,
                  style: AppTextStyles.body(15, color: muted),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1),
            ),
          ]),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(event.status.name.toUpperCase(),
                style: AppTextStyles.label(color: statusColor)
                    .copyWith(fontSize: 9)),
          ),
        ])),
        Column(mainAxisSize: MainAxisSize.min, children: [
          Text('+30', style: AppTextStyles.display(18, color: accent)),
          Text('pts', style: AppTextStyles.body(10, color: muted)),
        ]),
      ]),
    );
  }
}

// ─── BOOKING HISTORY CARD ─────────────────────────────────────────────────────
class _BookingHistoryCard extends StatelessWidget {
  final Booking booking;
  const _BookingHistoryCard({required this.booking});

  static IconData _facilityIcon(String name) {
    final n = name.toLowerCase();
    if (n.contains('football'))   return Icons.sports_soccer_rounded;
    if (n.contains('padel'))      return Icons.sports_tennis_rounded;
    if (n.contains('basketball')) return Icons.sports_basketball_rounded;
    if (n.contains('volleyball')) return Icons.sports_volleyball_rounded;
    if (n.contains('pool') || n.contains('swim')) return Icons.pool_rounded;
    if (n.contains('gym'))        return Icons.fitness_center_rounded;
    return Icons.stadium_rounded;
  }

  @override
  Widget build(BuildContext context) {
    final txt    = context.textColor;
    final muted  = context.mutedColor;
    final surf   = context.surfaceColor;
    final border = context.borderColor;
    final primary = context.primaryColor;

    final statusColor = switch (booking.status) {
      BookingStatus.confirmed => context.secondaryColor,
      BookingStatus.pending   => const Color(0xFFFFB547),
      BookingStatus.cancelled => context.errorColor,
      BookingStatus.completed => context.mutedColor,
    };
    final statusLabel = switch (booking.status) {
      BookingStatus.confirmed => 'Confirmed',
      BookingStatus.pending   => 'Pending',
      BookingStatus.cancelled => 'Cancelled',
      BookingStatus.completed => 'Completed',
    };

    const months = ['','Jan','Feb','Mar','Apr','May','Jun',
        'Jul','Aug','Sep','Oct','Nov','Dec'];
    final dateStr =
        '${months[booking.date.month]} ${booking.date.day}, ${booking.date.year}';
    final facilityIcon = _facilityIcon(booking.facilityName);

    return Container(
      decoration: BoxDecoration(
        color: surf,
        border: Border.all(color: border),
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.all(14),
      child: Row(children: [
        Container(
          width: 48, height: 48,
          decoration: BoxDecoration(
            color: primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(13),
          ),
          child: Center(child: Icon(facilityIcon, color: primary, size: 24)),
        ),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(booking.facilityName,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.heading(14, color: txt)),
          const SizedBox(height: 3),
          Row(children: [
            Flexible(
              child: Text(dateStr,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.body(15, color: muted)),
            ),
            const SizedBox(width: 10),
            Flexible(
              child: Text(booking.timeSlot,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.body(15, color: muted)),
            ),
          ]),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.12),
              border: Border.all(color: statusColor.withValues(alpha: 0.4)),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(statusLabel,
                style: AppTextStyles.label(color: statusColor)
                    .copyWith(fontSize: 9, letterSpacing: 0.3)),
          ),
        ])),
      ]),
    );
  }
}

class _SmallTag extends StatelessWidget {
  final String text;
  final Color color;
  const _SmallTag(this.text, this.color);
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
    decoration: BoxDecoration(
      color: color.withValues(alpha: 0.12),
      borderRadius: BorderRadius.circular(5),
    ),
    child: Text(text,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: AppTextStyles.label(color: color)
            .copyWith(fontSize: 9, letterSpacing: 0.3)),
  );
}

class _EmptyTab extends StatelessWidget {
  final IconData icon;
  final String message;
  const _EmptyTab({required this.icon, required this.message});
  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, color: context.mutedColor, size: 52),
        const SizedBox(height: 12),
        Text(message,
            style: AppTextStyles.body(16, color: context.mutedColor),
            textAlign: TextAlign.center,
            maxLines: 6,
            overflow: TextOverflow.ellipsis),
      ]),
    ),
  );
}
