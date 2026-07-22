// lib/features/settings/presentation/legal_document_screen.dart
// Renders one of the in-app legal documents (privacy / terms / refund /
// cookies). Read-only, offline, and reachable without a network connection so
// the text is always available at the moment of consent.

import 'package:flutter/material.dart';

import '../../../core/legal/legal_config.dart';
import '../../../core/legal/legal_content.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/widgets.dart';

class LegalDocumentScreen extends StatelessWidget {
  const LegalDocumentScreen({super.key, required this.kind});

  final LegalDocumentKind kind;

  @override
  Widget build(BuildContext context) {
    final lang = Localizations.localeOf(context).languageCode;
    final doc = LegalContent.of(kind, lang);

    final bg = context.bgColor;
    final txt = context.textColor;
    final muted = context.mutedColor;
    final border = context.borderColor;

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: bg,
        surfaceTintColor: Colors.transparent,
        title: Text(doc.title, style: AppTextStyles.heading(17, color: txt)),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: txt, size: 20),
          tooltip: MaterialLocalizations.of(context).backButtonTooltip,
          onPressed: () => Navigator.pop(context),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Divider(height: 1, color: border),
        ),
      ),
      body: SelectionArea(
        child: ListView(
          padding: EdgeInsets.fromLTRB(
            20,
            20,
            20,
            MediaQuery.of(context).padding.bottom + 32,
          ),
          children: [
            Text(
              doc.intro,
              style: AppTextStyles.body(14, color: txt),
            ),
            const SizedBox(height: 14),
            _Meta(doc.title, lang == 'ar' ? 'تاريخ السريان' : 'Effective',
                LegalConfig.effectiveDate, muted),
            _Meta(
                doc.title,
                lang == 'ar' ? 'الجهة المشغِّلة' : 'Operated by',
                '${LegalConfig.operatorName} — ${LegalConfig.organisation}',
                muted),
            if (!LegalConfig.isContactConfigured) ...[
              const SizedBox(height: 10),
              _UnconfiguredNotice(lang == 'ar'),
            ],
            const SizedBox(height: 22),
            Divider(color: border),
            const SizedBox(height: 6),
            ...doc.sections.map((s) => _Section(
                  title: s.title,
                  paragraphs: s.paragraphs,
                  bullets: s.bullets,
                )),
          ],
        ),
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({
    required this.title,
    required this.paragraphs,
    required this.bullets,
  });

  final String title;
  final List<String> paragraphs;
  final List<String> bullets;

  @override
  Widget build(BuildContext context) {
    final txt = context.textColor;
    final muted = context.mutedColor;
    final primary = context.primaryColor;
    final isRtl = Directionality.of(context) == TextDirection.rtl;

    return Semantics(
      container: true,
      header: true,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: AppTextStyles.heading(15, color: primary)),
            const SizedBox(height: 8),
            ...paragraphs.map(
              (p) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(p, style: AppTextStyles.body(13, color: txt)),
              ),
            ),
            ...bullets.map(
              (b) => Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: EdgeInsets.only(top: 7, right: 8, left: 2),
                      child: Container(
                        width: 5,
                        height: 5,
                        decoration: BoxDecoration(
                          color: muted,
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Text(b, style: AppTextStyles.body(13, color: txt)),
                    ),
                  ],
                ),
              ),
            ),
            if (bullets.isNotEmpty && isRtl) const SizedBox.shrink(),
          ],
        ),
      ),
    );
  }
}

class _Meta extends StatelessWidget {
  const _Meta(this.docTitle, this.label, this.value, this.muted);

  final String docTitle;
  final String label;
  final String value;
  final Color muted;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 4),
        child: Text(
          '$label: $value',
          style: AppTextStyles.body(11, color: muted),
        ),
      );
}

class _UnconfiguredNotice extends StatelessWidget {
  const _UnconfiguredNotice(this.isArabic);

  final bool isArabic;

  @override
  Widget build(BuildContext context) {
    final primary = context.primaryColor;

    return Semantics(
      container: true,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: primary.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: primary.withValues(alpha: 0.35)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.info_outline_rounded, size: 18, color: primary),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                isArabic
                    ? 'لم يتم إعداد بريد تواصل في هذه النسخة. '
                        'يُرجى التواصل مع الجهة المشغِّلة عبر قناة الجامعة الرسمية.'
                    : 'A contact mailbox is not configured in this build. '
                        'Please reach the operator through the official '
                        'university channel.',
                style: AppTextStyles.body(12, color: context.textColor),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
