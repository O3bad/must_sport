// lib/features/settings/presentation/about_screen.dart
// Team showcase / credits screen for MUSTER Sport

import 'package:flutter/material.dart';

import '../../../core/legal/legal_config.dart';
import '../../../core/legal/legal_content.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/widgets.dart';
import 'legal_document_screen.dart';

class AboutScreen extends StatefulWidget {
  const AboutScreen({super.key});
  @override
  State<AboutScreen> createState() => _AboutScreenState();
}

class _AboutScreenState extends State<AboutScreen> {
  String? _hoveredId;

  static const _team = [
    _Member(
        id: 'm1',
        name: 'Abdelrahman Abed',
        role: 'Project Leader & Flutter Developer',
        initials: 'AA',
        color: Color(0xFF00E5FF)),
    _Member(
        id: 'm2',
        name: 'Youssef Alsayed',
        role: 'UI/UX Designer',
        initials: 'YA',
        color: Color(0xFFA8FF3E)),
    _Member(
        id: 'm3',
        name: 'Omar Mostafa',
        role: 'Flutter Developer',
        initials: 'OM',
        color: Color(0xFFFFB800)),
    _Member(
        id: 'm4',
        name: 'Nour Hassan',
        role: 'Database & Firebase',
        initials: 'NH',
        color: Color(0xFF7C4DFF)),
    _Member(
        id: 'm5',
        name: 'Mohamed Emad',
        role: 'QA & Testing',
        initials: 'ME',
        color: Color(0xFFFF4757)),
    _Member(
        id: 'm6',
        name: 'Ahmed Amr',
        role: 'Business Analysis',
        initials: 'AM',
        color: Color(0xFF00BCD4)),
  ];

  @override
  Widget build(BuildContext context) {
    final bg = context.bgColor;
    final txt = context.textColor;
    final muted = context.mutedColor;
    final isAr = Localizations.localeOf(context).languageCode == 'ar';
    final primary = context.primaryColor;
    final second = context.secondaryColor;
    final border = context.borderColor;
    final surf = context.surfaceColor;

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
          left: 24,
          right: 24,
          top: 24,
          bottom: MediaQuery.of(context).padding.bottom + 32,
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // ── Hero ────────────────────────────────────────────────────────
          Center(
              child: Column(children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [primary, second],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                      color: primary.withValues(alpha: 0.35),
                      blurRadius: 28,
                      spreadRadius: 2)
                ],
              ),
              child: const Center(
                  child: Icon(Icons.stadium_rounded,
                      color: Colors.white, size: 40)),
            ),
            const SizedBox(height: 16),
            // Solid brand colour instead of a gradient-filled wordmark.
            Text('MUSTER',
                style: AppTextStyles.display(32,
                    color: primary, letterSpacing: 6)),
            const SizedBox(height: 4),
            Text('Sport Management Platform',
                style: AppTextStyles.body(13, color: muted)
                    .copyWith(letterSpacing: 2)),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
              decoration: BoxDecoration(
                color: primary.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: primary.withValues(alpha: 0.3)),
              ),
              child: Text('Version 1.0.0 · Spring 2026',
                  style: AppTextStyles.body(11,
                      color: primary, weight: FontWeight.w600)),
            ),
          ])),

          const SizedBox(height: 36),

          // ── Mission ──────────────────────────────────────────────────────
          AppCard(
            padding: const EdgeInsets.all(20),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Icon(Icons.flag_outlined, size: 20, color: primary),
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
            final isDimmed = _hoveredId != null && !isHovered;
            return GestureDetector(
              onTap: () =>
                  setState(() => _hoveredId = _hoveredId == m.id ? null : m.id),
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
                      color:
                          isHovered ? m.color.withValues(alpha: 0.45) : border,
                      width: isHovered ? 1.6 : 1,
                    ),
                  ),
                  child: Row(children: [
                    // Avatar — initials, not an emoji. An emoji glyph renders
                    // differently on every platform and carries no information
                    // the initials do not.
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: isHovered ? 52 : 44,
                      height: isHovered ? 52 : 44,
                      decoration: BoxDecoration(
                        color: m.color.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                        border: Border.all(
                            color: m.color.withValues(alpha: 0.4), width: 2),
                      ),
                      child: Center(
                        child: Text(m.initials,
                            style: AppTextStyles.body(
                              isHovered ? 17 : 14,
                              color: m.color,
                              weight: FontWeight.w800,
                            )),
                      ),
                    ),
                    const SizedBox(width: 14),
                    // Info
                    Expanded(
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                          Text(m.name,
                              style: AppTextStyles.body(15,
                                  color: isHovered ? m.color : txt,
                                  weight: FontWeight.w700)),
                          const SizedBox(height: 2),
                          Text(m.role,
                              style: AppTextStyles.body(12, color: muted)),
                        ])),
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
          Wrap(spacing: 8, runSpacing: 8, children: const [
            _TechChip('Flutter', Color(0xFF54C5F8)),
            _TechChip('Firebase', Color(0xFFFFCA28)),
            _TechChip('Dart', Color(0xFF00B4AB)),
            _TechChip('Provider', Color(0xFF7C4DFF)),
            _TechChip('Firestore', Color(0xFFFF6D00)),
            _TechChip('FCM', Color(0xFFA8FF3E)),
          ]),

          const SizedBox(height: 28),

          // ── Publisher / business details ──────────────────────────────
          // Google Play and the App Store both require the developer or
          // publisher to be identifiable. Nothing here is invented: the values
          // come from LegalConfig, and an unconfigured contact mailbox is shown
          // as such rather than as a plausible-looking fake address.
          SectionLabel(isAr ? 'بيانات الناشر' : 'Publisher details'),
          const SizedBox(height: 10),
          AppCard(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _DetailRow(
                  icon: Icons.badge_outlined,
                  label: isAr ? 'اسم التطبيق' : 'App name',
                  value: LegalConfig.appName,
                ),
                _DetailRow(
                  icon: Icons.apartment_rounded,
                  label: isAr ? 'الجهة المشغّلة' : 'Operated by',
                  value: LegalConfig.operatorName,
                ),
                _DetailRow(
                  icon: Icons.school_outlined,
                  label: isAr ? 'المؤسسة' : 'Organisation',
                  value: LegalConfig.organisation,
                ),
                _DetailRow(
                  icon: Icons.alternate_email_rounded,
                  label: isAr ? 'بريد التواصل' : 'Contact email',
                  value: LegalConfig.contactDisplay,
                  warn: !LegalConfig.isContactConfigured,
                ),
                _DetailRow(
                  icon: Icons.calendar_today_outlined,
                  label: isAr ? 'تاريخ إصدار الوثائق' : 'Policies updated',
                  value: LegalConfig.effectiveDate,
                ),
                _DetailRow(
                  icon: Icons.tag_rounded,
                  label: isAr ? 'معرّف الحزمة' : 'Package id',
                  value: 'com.muster.sport',
                ),
              ],
            ),
          ),

          const SizedBox(height: 28),

          // ── Legal documents ────────────────────────────────────────────
          SectionLabel(isAr ? 'الشؤون القانونية' : 'Legal'),
          const SizedBox(height: 10),
          Container(
            decoration: BoxDecoration(
              color: surf,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: border),
            ),
            child: Column(children: [
              for (var i = 0; i < LegalDocumentKind.values.length; i++) ...[
                if (i > 0) Divider(height: 1, color: border),
                _LegalRow(kind: LegalDocumentKind.values[i]),
              ],
            ]),
          ),

          const SizedBox(height: 28),

          // ── Font & third-party licences ──────────────────────────────────
          SectionLabel('Open Source Licenses'),
          const SizedBox(height: 10),
          Semantics(
            button: true,
            label: 'Open Source Licenses',
            child: ExcludeSemantics(
              child: Material(
                color: surf,
                borderRadius: BorderRadius.circular(14),
                child: InkWell(
                  borderRadius: BorderRadius.circular(14),
                  onTap: () => showLicensePage(
                    context: context,
                    applicationName: 'MUSTER Sport',
                    applicationVersion: '1.0.0',
                    applicationLegalese: '© 2026 MUSTER Team — MUST University',
                  ),
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: border),
                    ),
                    child: Row(children: [
                      Icon(Icons.balance_rounded, size: 20, color: primary),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Inter, Plus Jakarta Sans and Noto Kufi Arabic — '
                          'SIL Open Font License 1.1 (Google Fonts, loaded at runtime)',
                          style: AppTextStyles.body(12,
                              color: context.mutedSubtleColor,
                              context: context),
                        ),
                      ),
                      Icon(
                        Localizations.localeOf(context).languageCode == 'ar'
                            ? Icons.chevron_left
                            : Icons.chevron_right,
                        color: muted,
                        size: 18,
                      ),
                    ]),
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(height: 28),

          // ── Footer ───────────────────────────────────────────────────────
          Center(
              child: Column(children: [
            Divider(color: border),
            const SizedBox(height: 12),
            Text('© 2026 MUSTER Team · MUST University',
                style: AppTextStyles.body(12, color: muted),
                textAlign: TextAlign.center),
            const SizedBox(height: 4),
            Text('Graduation Project — Faculty of Information Technology',
                style: AppTextStyles.body(11, color: context.mutedSubtleColor),
                textAlign: TextAlign.center),
          ])),
        ]),
      ),
    );
  }
}

class _Member {
  final String id, name, role, initials;
  final Color color;
  const _Member(
      {required this.id,
      required this.name,
      required this.role,
      required this.initials,
      required this.color});
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
    this.warn = false,
  });

  final IconData icon;
  final String label;
  final String value;
  final bool warn;

  @override
  Widget build(BuildContext context) {
    final muted = context.mutedColor;
    final warnColor = DarkColors.error;

    return Semantics(
      container: true,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 17, color: muted),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: AppTextStyles.body(11, color: muted)),
                  const SizedBox(height: 2),
                  Text(
                    value,
                    style: AppTextStyles.body(
                      14,
                      color: warn ? warnColor : context.textColor,
                      weight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LegalRow extends StatelessWidget {
  const _LegalRow({required this.kind});

  final LegalDocumentKind kind;

  @override
  Widget build(BuildContext context) {
    final txt = context.textColor;
    final muted = context.mutedColor;
    final primary = context.primaryColor;
    final lang = Localizations.localeOf(context).languageCode;
    final title = LegalContent.titleOf(kind, lang);

    return Semantics(
      button: true,
      label: title,
      child: ExcludeSemantics(
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => LegalDocumentScreen(kind: kind),
              ),
            ),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(children: [
                Icon(_legalGlyph(kind), size: 19, color: primary),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(title,
                      style: AppTextStyles.body(14,
                          color: txt, weight: FontWeight.w500)),
                ),
                Icon(
                  lang == 'ar' ? Icons.chevron_left : Icons.chevron_right,
                  color: muted,
                  size: 18,
                ),
              ]),
            ),
          ),
        ),
      ),
    );
  }
}

IconData _legalGlyph(LegalDocumentKind kind) => switch (kind) {
      LegalDocumentKind.privacy => Icons.privacy_tip_outlined,
      LegalDocumentKind.terms => Icons.gavel_rounded,
      LegalDocumentKind.refund => Icons.receipt_long_outlined,
      LegalDocumentKind.cookies => Icons.cookie_outlined,
    };

class _TechChip extends StatelessWidget {
  final String label;
  final Color color;
  const _TechChip(this.label, this.color);
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.10),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Text(label,
            style:
                AppTextStyles.body(13, color: color, weight: FontWeight.w600)),
      );
}
