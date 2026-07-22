import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/widgets.dart';
import '../../../core/state/notification_state.dart';
import '../../../l10n/app_localizations.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state  = context.watch<NotificationState>();
    final notifs = state.all;
    final txt    = context.textColor;
    final border = context.borderColor;
    final bg     = context.bgColor;
    final primary = context.primaryColor;

    // Group by: Today / Yesterday / Earlier
    final now       = DateTime.now();
    final today     = notifs.where((n) => _isToday(n.time, now)).toList();
    final yesterday = notifs.where((n) => _isYesterday(n.time, now)).toList();
    final earlier   = notifs.where((n) => !_isToday(n.time, now) && !_isYesterday(n.time, now)).toList();

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: bg,
        surfaceTintColor: Colors.transparent,
        title: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(AppLocalizations.of(context)!.notificationsTitle, style: AppTextStyles.display(20, color: txt, context: context)),
          if (state.unreadCount > 0)
            Text('${state.unreadCount} ${AppLocalizations.of(context)!.unread}',
                style: AppTextStyles.body(15, color: primary, context: context)),
        ]),
        actions: [
          if (state.unreadCount > 0)
            TextButton(
              onPressed: state.markAllRead,
              child: Text(AppLocalizations.of(context)!.markAllRead,
                  style: AppTextStyles.body(16, color: primary, weight: FontWeight.w600, context: context)),
            ),
          const SizedBox(width: 4),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Divider(height: 1, color: border),
        ),
      ),
      body: notifs.isEmpty
          ? _EmptyState()
          : ListView(
              padding: const EdgeInsets.only(bottom: 100),
              children: [
                if (today.isNotEmpty)     ...[_GroupHeader(AppLocalizations.of(context)!.today),     ..._buildCards(context, today, state)],
                if (yesterday.isNotEmpty) ...[_GroupHeader(AppLocalizations.of(context)!.yesterday), ..._buildCards(context, yesterday, state)],
                if (earlier.isNotEmpty)   ...[_GroupHeader(AppLocalizations.of(context)!.earlier),   ..._buildCards(context, earlier, state)],
              ],
            ),
    );
  }

  List<Widget> _buildCards(BuildContext context, List<AppNotification> notifs, NotificationState state) {
    return notifs.map((n) => Dismissible(
      key: Key(n.id),
      direction: Localizations.localeOf(context).languageCode == 'ar' 
          ? DismissDirection.startToEnd 
          : DismissDirection.endToStart,
      onDismissed: (_) => state.delete(n.id),
      background: Container(
        alignment: Localizations.localeOf(context).languageCode == 'ar'
            ? Alignment.centerLeft
            : Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        color: context.errorColor.withValues(alpha: 0.15),
        child: Icon(Icons.delete_outline, color: context.errorColor),
      ),
      child: _NotifCard(notif: n),
    )).toList();
  }

  bool _isToday(DateTime t, DateTime now) =>
      t.year == now.year && t.month == now.month && t.day == now.day;
  bool _isYesterday(DateTime t, DateTime now) {
    final y = now.subtract(const Duration(days: 1));
    return t.year == y.year && t.month == y.month && t.day == y.day;
  }
}

// ─── GROUP HEADER ─────────────────────────────────────────────────────────────
class _GroupHeader extends StatelessWidget {
  final String label;
  const _GroupHeader(this.label);
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(16, 20, 16, 6),
    child: Text(label,
        style: AppTextStyles.label(color: context.mutedColor, context: context)
            .copyWith(fontSize: 11, letterSpacing: 1.2)),
  );
}

// ─── NOTIFICATION CARD ────────────────────────────────────────────────────────
class _NotifCard extends StatelessWidget {
  final AppNotification notif;
  const _NotifCard({required this.notif});

  @override
  Widget build(BuildContext context) {
    final state  = context.read<NotificationState>();
    final txt    = context.textColor;
    final muted  = context.mutedColor;
    final surf   = context.surfaceColor;
    final border = context.borderColor;
    final c      = notif.type.color;
    final unread = !notif.isRead;

    return GestureDetector(
      onTap: () => state.markRead(notif.id),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
        decoration: BoxDecoration(
          color: unread ? c.withValues(alpha: 0.06) : surf,
          border: Border.all(
              color: unread ? c.withValues(alpha: 0.35) : border),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            // Icon bubble
            Container(
              width: 42, height: 42,
              decoration: BoxDecoration(
                color: c.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Icon(notif.type.icon, color: c, size: 20),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              // Title row
              Row(children: [
                Expanded(
                  child: Text(notif.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.body(15, color: txt,
                          weight: unread ? FontWeight.w700 : FontWeight.w500,
                          context: context)),
                ),
                const SizedBox(width: 8),
                if (unread)
                  Container(
                    width: 8, height: 8,
                    decoration: BoxDecoration(color: c, shape: BoxShape.circle),
                  ),
              ]),
              const SizedBox(height: 4),
              // Body
              Text(notif.body,
                  style: AppTextStyles.body(14, color: muted, context: context),
                  maxLines: 3, overflow: TextOverflow.ellipsis),
              const SizedBox(height: 8),
              // Footer
              Row(children: [
                Flexible(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: c.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(notif.type.label(context),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.label(color: c, context: context)
                            .copyWith(fontSize: 9, letterSpacing: 0.5)),
                  ),
                ),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(_timeAgo(context, notif.time),
                      textAlign: Localizations.localeOf(context).languageCode == 'ar'
                          ? TextAlign.left
                          : TextAlign.right,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.body(10, color: muted, context: context)),
                ),
              ]),
              // Action button
              if (notif.actionLabel != null) ...[
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: notif.onAction,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                    decoration: BoxDecoration(
                      color: c.withValues(alpha: 0.12),
                      border: Border.all(color: c.withValues(alpha: 0.4)),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(notif.actionLabel!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                        style: AppTextStyles.body(14, color: c, weight: FontWeight.w600, context: context)),
                  ),
                ),
              ],
            ])),
          ]),
        ),
      ),
    );
  }

  String _timeAgo(BuildContext context, DateTime t) {
    final diff = DateTime.now().difference(t);
    final l = AppLocalizations.of(context)!;
    
    if (diff.inMinutes < 60)  return l.minutesAgo(diff.inMinutes);
    if (diff.inHours < 24)    return l.hoursAgo(diff.inHours);
    if (diff.inDays < 7)      return l.daysAgo(diff.inDays);
    
    final months = [
      '', l.january, l.february, l.march, l.april, l.may, l.june,
      l.july, l.august, l.september, l.october, l.november, l.december
    ];
    
    final isAr = Localizations.localeOf(context).languageCode == 'ar';
    return isAr ? '${t.day} ${months[t.month]}' : '${months[t.month]} ${t.day}';
  }
}

// ─── EMPTY STATE ─────────────────────────────────────────────────────────────
class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Center(
    child: Column(mainAxisSize: MainAxisSize.min, children: [
      const Icon(Icons.notifications_none_rounded, size: 64, color: Color(0xFF5A7090)),
      const SizedBox(height: 16),
      Text(AppLocalizations.of(context)!.allCaughtUp,
          style: AppTextStyles.heading(18, color: context.textColor, context: context)),
      const SizedBox(height: 6),
      Text(AppLocalizations.of(context)!.noNotificationsNow,
          style: AppTextStyles.body(16, color: context.mutedColor, context: context)),
    ]),
  );
}
