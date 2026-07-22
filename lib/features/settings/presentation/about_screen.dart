// lib/features/settings/presentation/about_screen.dart
// Team showcase / credits screen for MUSTER Sport

import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/theme/widgets.dart';

class AboutScreen extends StatefulWidget {
  const AboutScreen({super.key});
  @override
  State<AboutScreen> createState() => _AboutScreenState();
}

class _AboutScreenState extends State<AboutScreen> {
  String? _hoveredId;

  static const _team = [
    _Member(id:'m1', name:'Abdelrahman Abed', role:'Project Leader & Flutter Developer', emoji:'🚀', initials:'AA', color:Color(0xFF00E5FF)),
    _Member(id:'m2', name:'Youssef Alsayed',       role:'UI/UX Designer',         emoji:'🎨', initials:'SK', color:Color(0xFFA8FF3E)),
    _Member(id:'m3', name:'Omar Mostafa',      role:'Flutter Developer',      emoji:'📱', initials:'OM', color:Color(0xFFFFB800)),
    _Member(id:'m4', name:'Nour Hassan',       role:'Database & Firebase',    emoji:'🔥', initials:'NH', color:Color(0xFF7C4DFF)),
    _Member(id:'m5', name:'Mohamed Emad',     role:'QA & Testing',           emoji:'🧪', initials:'YT', color:Color(0xFFFF4757)),
    _Member(id:'m6', name:'Ahmed Amr',     role:'Business Analysis',      emoji:'📊', initials:'LI', color:Color(0xFF00BCD4)),
  ];

  @override
  Widget build(BuildContext context) {
    final bg      = context.bgColor;
    final txt     = context.textColor;
    final muted   = context.mutedColor;
    final primary = context.primaryColor;
    final second  = context.secondaryColor;
    final border  = context.borderColor;
    final surf    = context.surfaceColor;

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: bg,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: txt, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Divider(height: 1, color: border),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.only(
          left: 24, right: 24, top: 24,
          bottom: MediaQuery.of(context).padding.bottom + 32,
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // ── Hero ────────────────────────────────────────────────────────
          Center(child: Column(children: [
            Container(
              width: 80, height: 80,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [primary, second],
                  begin: Alignment.topLeft, end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [BoxShadow(color: primary.withValues(alpha: 0.35), blurRadius: 28, spreadRadius: 2)],
              ),
              child: const Center(child: Icon(Icons.stadium_rounded, color: Colors.white, size: 40)),
            ),
            const SizedBox(height: 16),
            ShaderMask(
              shaderCallback: (b) => LinearGradient(colors: [primary, second]).createShader(b),
              child: Text('MUSTER', style: AppTextStyles.display(32, color: Colors.white, letterSpacing: 6)),
            ),
            const SizedBox(height: 4),
            Text('Sport Management Platform', style: AppTextStyles.body(13, color: muted).copyWith(letterSpacing: 2)),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
              decoration: BoxDecoration(
                color: primary.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: primary.withValues(alpha: 0.3)),
              ),
              child: Text('Version 1.0.0 · Spring 2026',
                  style: AppTextStyles.body(11, color: primary, weight: FontWeight.w600)),
            ),
          ])),

          const SizedBox(height: 36),

          // ── Mission ──────────────────────────────────────────────────────
          AppCard(
            padding: const EdgeInsets.all(20),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Text('🎯', style: const TextStyle(fontSize: 20)),
                const SizedBox(width: 10),
                Expanded(
                  child: Text('Our Mission',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.heading(16, color: txt)),
                ),
              ]),
              const SizedBox(height: 10),
              Text(
                'MUSTER is a graduation project built to modernize university sports management at MUST University. '
                'We connect students, coaches, and administrators through one seamless platform — '
                'from booking facilities to tracking achievements.',
                style: AppTextStyles.body(14, color: muted),
              ),
            ]),
          ),

          const SizedBox(height: 28),
          SectionLabel('Meet the Team'),
          const SizedBox(height: 14),

          // ── Team grid ────────────────────────────────────────────────────
          ...List.generate(_team.length, (i) {
            final m = _team[i];
            final isHovered = _hoveredId == m.id;
            final isDimmed  = _hoveredId != null && !isHovered;
            return GestureDetector(
              onTap: () => setState(() => _hoveredId = _hoveredId == m.id ? null : m.id),
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 200),
                opacity: isDimmed ? 0.45 : 1.0,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: isHovered ? m.color.withValues(alpha: 0.08) : surf,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isHovered ? m.color.withValues(alpha: 0.45) : border,
                      width: isHovered ? 1.6 : 1,
                    ),
                    boxShadow: isHovered
                        ? [BoxShadow(color: m.color.withValues(alpha: 0.18), blurRadius: 16)]
                        : [],
                  ),
                  child: Row(children: [
                    // Avatar
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: isHovered ? 52 : 44, height: isHovered ? 52 : 44,
                      decoration: BoxDecoration(
                        color: m.color.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                        border: Border.all(color: m.color.withValues(alpha: 0.4), width: 2),
                      ),
                      child: Center(child: Text(m.emoji, style: TextStyle(fontSize: isHovered ? 22 : 18))),
                    ),
                    const SizedBox(width: 14),
                    // Info
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(m.name,
                          style: AppTextStyles.body(15, color: isHovered ? m.color : txt, weight: FontWeight.w700)),
                      const SizedBox(height: 2),
                      Text(m.role, style: AppTextStyles.body(12, color: muted)),
                    ])),
                    // Initials badge
                    if (isHovered)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: m.color.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(m.initials,
                            style: AppTextStyles.body(12, color: m.color, weight: FontWeight.w800)),
                      )
                    else
                      Icon(Icons.chevron_right, color: muted, size: 18),
                  ]),
                ),
              ),
            );
          }),

          const SizedBox(height: 28),

          // ── Tech stack ───────────────────────────────────────────────────
          SectionLabel('Built With'),
          const SizedBox(height: 14),
          Wrap(spacing: 8, runSpacing: 8, children: [
            _TechChip('Flutter', '💙', const Color(0xFF54C5F8)),
            _TechChip('Firebase', '🔥', const Color(0xFFFFCA28)),
            _TechChip('Dart', '🎯', const Color(0xFF00B4AB)),
            _TechChip('Provider', '⚡', const Color(0xFF7C4DFF)),
            _TechChip('Firestore', '🗄️', const Color(0xFFFF6D00)),
            _TechChip('FCM', '🔔', const Color(0xFFA8FF3E)),
          ]),

          const SizedBox(height: 28),

          // ── Footer ───────────────────────────────────────────────────────
          Center(child: Column(children: [
            Divider(color: border),
            const SizedBox(height: 12),
            Text('© 2026 MUSTER Team · MUST University',
                style: AppTextStyles.body(12, color: muted), textAlign: TextAlign.center),
            const SizedBox(height: 4),
            Text('Graduation Project — Faculty of Information Technology',
                style: AppTextStyles.body(11, color: muted.withValues(alpha: 0.6)),
                textAlign: TextAlign.center),
          ])),
        ]),
      ),
    );
  }
}

class _Member {
  final String id, name, role, emoji, initials;
  final Color color;
  const _Member({required this.id, required this.name, required this.role,
      required this.emoji, required this.initials, required this.color});
}

class _TechChip extends StatelessWidget {
  final String label, emoji;
  final Color color;
  const _TechChip(this.label, this.emoji, this.color);
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    decoration: BoxDecoration(
      color: color.withValues(alpha: 0.10),
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: color.withValues(alpha: 0.3)),
    ),
    child: Row(mainAxisSize: MainAxisSize.min, children: [
      Text(emoji, style: const TextStyle(fontSize: 14)),
      const SizedBox(width: 6),
      Text(label, style: AppTextStyles.body(13, color: color, weight: FontWeight.w600)),
    ]),
  );
}
