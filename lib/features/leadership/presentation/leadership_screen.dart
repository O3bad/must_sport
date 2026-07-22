import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/widgets.dart';
import '../../../core/state/app_state.dart';
import '../../../core/models/models.dart';
import '../../../core/services/firestore_service.dart';
import '../../../l10n/app_localizations.dart';

class LeadershipScreen extends StatelessWidget {
  const LeadershipScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final currentUid = context.read<AppState>().user.uid;
    final isDark = context.isDark;
    final primary = context.primaryColor;
    final bg = context.bgColor;
    final surf = context.surfaceColor;
    final border = context.borderColor;
    final muted = context.mutedColor;
    final text = context.textColor;

    final l = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: bg,
      appBar: const MusterAppBar(),
      body: StreamBuilder<List<LeaderboardEntry>>(
        stream: FirestoreService.instance.leaderboardStream(currentUid),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator(color: primary, strokeWidth: 2));
          }

          if (snapshot.hasError) {
            final fallback = context.read<AppState>().leaderboard;
            if (fallback.isNotEmpty) {
              final podium = fallback.take(3).toList();
              final rest = fallback.skip(3).toList();
              return _LeaderboardBody(
                podium: podium, rest: rest,
                isDark: isDark, surf: surf, border: border,
                text: text, muted: muted, primary: primary,
              );
            }
            return Center(
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                const Icon(Icons.warning_amber_rounded, size: 40, color: Color(0xFFFFB800)),
                const SizedBox(height: 12),
                Text(
                  l.failedToLoadLeaderboard,
                  style: AppTextStyles.body(15, color: muted, context: context),
                ),
              ]),
            );
          }

          final entries = snapshot.data ?? [];
          if (entries.isEmpty) {
            return Center(
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                const Icon(Icons.emoji_events_rounded, size: 48, color: Color(0xFFFFD700)),
                const SizedBox(height: 12),
                Text(AppLocalizations.of(context)!.noStudentsYet, style: AppTextStyles.body(15, color: muted, context: context)),
                const SizedBox(height: 8),
                Text("Waiting for students with role 'student'...", style: AppTextStyles.body(11, color: muted, context: context)),
              ]),
            );
          }

          final podium = entries.take(3).toList();
          final rest = entries.length > 3 ? entries.skip(3).toList() : <LeaderboardEntry>[];

          return _LeaderboardBody(
            podium: podium,
            rest: rest,
            isDark: isDark, surf: surf, border: border,
            text: text, muted: muted, primary: primary,
          );
        },
      ),
    );
  }
}

// ─── LEADERBOARD BODY ────────────────────────────────────────────────────────
class _LeaderboardBody extends StatelessWidget {
  final List<LeaderboardEntry> podium, rest;
  final bool isDark;
  final Color surf, border, text, muted, primary;

  const _LeaderboardBody({
    required this.podium, required this.rest,
    required this.isDark, required this.surf, required this.border,
    required this.text, required this.muted, required this.primary,
  });

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
            child: StaggerItem(
              delay: const Duration(milliseconds: 60),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(l.leaderboard, style: AppTextStyles.display(26, color: primary, context: context)),
                  const SizedBox(height: 4),
                  Text(l.topPerformers, style: AppTextStyles.body(13, color: text.withValues(alpha: 0.7), context: context)),
                ],
              ),
            ),
          ),
        ),
        if (podium.isNotEmpty)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 28, 20, 4),
              child: StaggerItem(
                delay: const Duration(milliseconds: 120),
                child: _PodiumSection(entries: podium),
              ),
            ),
          ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
            child: Row(children: [
              Expanded(child: Divider(color: border, height: 1)),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Text(l.rankingsLabel,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.label(color: primary.withValues(alpha: 0.9), context: context)),
              ),
              Expanded(child: Divider(color: border, height: 1)),
            ]),
          ),
        ),
        SliverList(
          delegate: SliverChildBuilderDelegate(
                (context, index) {
              final entry = rest[index];
              return Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                child: StaggerItem(
                  delay: Duration(milliseconds: 180 + index * 55),
                  child: _LeaderRow(
                    entry: entry,
                    isDark: isDark, surf: surf, border: border,
                    text: text, muted: muted, primary: primary,
                  ),
                ),
              );
            },
            childCount: rest.length,
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 120)),
      ],
    );
  }
} // <--- Corrected: Moved closing brace to here

// ─── PODIUM ──────────────────────────────────────────────────────────────────
class _PodiumSection extends StatelessWidget {
  final List<LeaderboardEntry> entries;
  const _PodiumSection({required this.entries});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    
    // Safety check: how many podium spots can we actually fill?
    final count = entries.length.clamp(0, 3);
    if (count == 0) return const SizedBox.shrink();

    // Mapping: index in 'entries' to podium position
    // We want: [1, 0, 2] -> Silver (2nd), Gold (1st), Bronze (3rd)
    final podiumPositions = count == 3 ? [1, 0, 2] : (count == 2 ? [1, 0] : [0]);
    
    final heights = [100.0, 120.0, 80.0];
    final medals = ['🥈', '🥇', '🥉'];
    final colors = [AppColors.silver, AppColors.gold, AppColors.bronze];

    return SizedBox(
      height: 240,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: List.generate(podiumPositions.length, (i) {
          final entryIndex = podiumPositions[i];
          final e = entries[entryIndex];
          int visualIndex;
          if (count == 3) {
            visualIndex = i;
          } else {
            visualIndex = count == 2 ? i : 1;
          }

          return Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Container(
                  width: 46, height: 46,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: colors[visualIndex].withValues(alpha: 0.18),
                    border: Border.all(color: colors[visualIndex], width: 2),
                  ),
                  child: Center(child: Text(e.initials, style: AppTextStyles.heading(13, color: colors[visualIndex], context: context))),
                ),
                const SizedBox(height: 4),
                Text(medals[visualIndex], style: const TextStyle(fontSize: 18)),
                const SizedBox(height: 2),
                Text(e.name.split(' ').first,
                    style: AppTextStyles.body(11, color: context.textColor, weight: FontWeight.w700, context: context),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
                const SizedBox(height: 6),
                PodiumBar(
                  targetHeight: heights[visualIndex],
                  color: colors[visualIndex],
                  delay: Duration(milliseconds: visualIndex == 1 ? 100 : visualIndex == 0 ? 250 : 350),
                  child: Center(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('#${e.rank}', style: AppTextStyles.stat(18, color: Colors.white54, context: context)),
                          Text('${e.points}', style: AppTextStyles.body(10, color: Colors.white54, weight: FontWeight.w900, context: context)),
                          Text(l.pts, style: AppTextStyles.body(9, color: Colors.white54, context: context)),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }
}

class PodiumBar extends StatefulWidget {
  final double targetHeight;
  final Color color;
  final Duration delay;
  final Widget? child;

  const PodiumBar({
    super.key,
    required this.targetHeight,
    required this.color,
    required this.delay,
    this.child,
  });

  @override
  State<PodiumBar> createState() => _PodiumBarState();
}

class _PodiumBarState extends State<PodiumBar> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _heightAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _heightAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticOut,
    );
    Future.delayed(widget.delay, () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _heightAnimation,
      builder: (context, child) {
        return Container(
          width: double.infinity,
          height: _heightAnimation.value * widget.targetHeight,
          margin: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                widget.color,
                widget.color.withValues(alpha: 0.7),
              ],
            ),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(16),
              topRight: Radius.circular(16),
            ),
            boxShadow: [
              BoxShadow(
                color: widget.color.withValues(alpha: 0.3),
                blurRadius: 15,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: _heightAnimation.value > 0.5 ? widget.child : null,
        );
      },
    );
  }
}

// ─── ROW ─────────────────────────────────────────────────────────────────────
class _LeaderRow extends StatelessWidget {
  final LeaderboardEntry entry;
  final bool isDark;
  final Color surf, border, text, muted, primary;

  const _LeaderRow({
    required this.entry, required this.isDark,
    required this.surf, required this.border,
    required this.text, required this.muted, required this.primary,
  });

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final isMe = entry.isMe;
    final bg = isMe ? primary.withValues(alpha: isDark ? 0.10 : 0.07) : surf;
    final bord = isMe ? primary.withValues(alpha: 0.35) : border;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: bord),
      ),
      child: Row(children: [
        SizedBox(width: 32, child: Text('#${entry.rank}', style: AppTextStyles.stat(14, color: isMe ? primary : muted, weight: FontWeight.w800, context: context), textAlign: TextAlign.center)),
        const SizedBox(width: 12),
        Container(
          width: 38, height: 38,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: (isMe ? primary : muted).withValues(alpha: 0.15),
            border: Border.all(color: (isMe ? primary : border), width: 1.5),
          ),
          child: Center(child: Text(entry.initials, style: AppTextStyles.heading(11, color: isMe ? primary : muted, context: context))),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                Flexible(child: Text(entry.name, style: AppTextStyles.body(13, color: text, weight: FontWeight.w700, context: context), overflow: TextOverflow.ellipsis, maxLines: 1)),
                if (isMe) ...[
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                    decoration: BoxDecoration(color: primary.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(8), border: Border.all(color: primary.withValues(alpha: 0.4))),
                    child: Text(AppLocalizations.of(context)!.youLabel, style: AppTextStyles.label(color: primary, size: 10, context: context)),
                  ),
                ],
              ]),
              Text(entry.faculty, style: AppTextStyles.body(11, color: text.withValues(alpha: 0.6), context: context), maxLines: 1, overflow: TextOverflow.ellipsis),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            AnimatedCounter(target: entry.points, style: AppTextStyles.stat(16, color: isMe ? primary : text, context: context), duration: Duration(milliseconds: 800 + entry.rank * 40)),
            Text(l.pts, style: AppTextStyles.body(10, color: muted, context: context)),
          ],
        ),
      ]),
    );
  }
}