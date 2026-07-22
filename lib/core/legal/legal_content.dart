// lib/core/legal/legal_content.dart
// In-app legal documents.
//
// The text describes what MUSTER Sport actually does today. It was written
// against the shipped source and pubspec, not copied from a template:
//   * no advertising, no data sale, no behavioural analytics SDK is present
//   * the only processors are Firebase (Auth / Firestore / Cloud Messaging)
//     and google_fonts, which fetches font files from Google
//   * card details entered in the booking form are validated locally and are
//     never transmitted or persisted
//   * deletion is available in-app (Settings -> Delete account)
// Anything the repository cannot prove (a registered legal entity, a governing
// jurisdiction) is deliberately left generic rather than invented.

import 'legal_config.dart';

enum LegalDocumentKind { privacy, terms, refund, cookies }

class LegalSection {
  const LegalSection(this.title, this.paragraphs, {this.bullets = const []});

  final String title;
  final List<String> paragraphs;
  final List<String> bullets;
}

class LegalDocument {
  const LegalDocument({
    required this.kind,
    required this.title,
    required this.intro,
    required this.sections,
  });

  final LegalDocumentKind kind;
  final String title;
  final String intro;
  final List<LegalSection> sections;
}

class LegalContent {
  const LegalContent._();

  static LegalDocument of(LegalDocumentKind kind, String languageCode) =>
      languageCode == 'ar' ? _arabic[kind]! : _english[kind]!;

  static String titleOf(LegalDocumentKind kind, String languageCode) =>
      of(kind, languageCode).title;

  // ───────────────────────────── English ─────────────────────────────

  static final LegalDocument _privacyEn = LegalDocument(
    kind: LegalDocumentKind.privacy,
    title: 'Privacy Policy',
    intro:
        'This policy explains what personal data MUSTER Sport collects, why we '
        'collect it, who can see it, and how you can control or delete it. '
        'It applies to the MUSTER Sport mobile app and web app.',
    sections: [
      LegalSection(
        '1. Who we are',
        [
          'MUSTER Sport is operated by ${LegalConfig.organisation} as a '
              'graduation project ("we", "us"). We are the data controller for '
              'the personal data described in this policy.',
          'Questions about this policy or your data: ${LegalConfig.contactDisplay}',
        ],
      ),
      LegalSection(
        '2. Data you give us',
        [
          'We collect only what the app needs to run a university sports '
              'platform. You provide it during sign-up and profile editing.',
        ],
        bullets: [
          'Account: name, university email address, phone number, student ID, faculty.',
          'Profile: avatar, bio, and your role (every new account is created as a student).',
          'Activity: the events you register for, the facilities you book, and the '
              'status of each registration or booking.',
          'Gameplay: points, rank, achievements and match history used for the leaderboard.',
        ],
      ),
      LegalSection(
        '3. Data we generate automatically',
        [
          'These are created so the app can function. They are not used for '
              'advertising or profiling.',
        ],
        bullets: [
          'A push-notification device token, so the app can alert you to '
              'registration and booking updates. You can turn notifications off at '
              'any time from the notification settings.',
          'Local preferences on your device: selected theme, language, and a short-'
              'lived sign-in marker. This marker is bound to your account ID, expires '
              'after 30 days, and is deleted when you sign out.',
        ],
      ),
      LegalSection(
        '4. Data we do NOT collect',
        [
          'MUSTER Sport contains no advertising SDK, no third-party analytics or '
              'tracking SDK, and no data broker integration. We do not build '
              'advertising profiles and we do not sell or rent personal data.',
        ],
      ),
      LegalSection(
        '5. Who can see your data',
        [
          'Access is limited by role and enforced on the server, not just in the '
              'interface. Other students cannot browse your record.',
        ],
        bullets: [
          'You can read and edit your own profile.',
          'University administrators can manage accounts, events and bookings, '
              'which is necessary to run the platform.',
          'Coaches see the students registered for their own activity only, not '
              'the full user directory.',
          'The public leaderboard shows only your display name, faculty, points '
              'and rank. Email address, phone number and student ID are never '
              'published there.',
        ],
      ),
      LegalSection(
        '6. Third-party services we rely on',
        [
          'These providers process data only to deliver the features you use. '
              'They are subject to their own privacy terms.',
        ],
        bullets: [
          'Google Firebase Authentication — signs you in and stores your account credentials.',
          'Google Cloud Firestore — stores your profile, events, bookings and points.',
          'Firebase Cloud Messaging — delivers push notifications.',
          'Google Fonts — supplies the font files used by the interface.',
          'Shared device storage (your operating system) — holds local preferences.',
        ],
      ),
      LegalSection(
        '7. Payment and card data',
        [
          'MUSTER Sport does not process payments. If you select the card option '
              'while booking a facility, the card number, expiry and security code '
              'are typed into the app and checked locally for format only. They are '
              'never transmitted to us, never written to our servers, and never '
              'stored on the device. Any amount due is settled directly with the '
              'university through the channels it provides.',
        ],
      ),
      LegalSection(
        '8. How long we keep your data',
        [
          'Your data is kept while your account is active. When you delete your '
              'account from Settings, we remove your profile, your registrations, '
              'your bookings and your leaderboard entry from our systems.',
        ],
      ),
      LegalSection(
        '9. Your rights',
        [
          'You can exercise these rights directly in the app, without contacting us.',
        ],
        bullets: [
          'Access and correct your data — edit your profile at any time.',
          'Delete your account and data — Settings -> Delete account, which asks '
              'you to re-enter your password and type a confirmation word.',
          'Withdraw notification consent — turn notifications off in settings; you '
              'will stop receiving push messages.',
          'Ask a question or request a copy of your data — contact us using the '
              'address in section 1.',
        ],
      ),
      LegalSection(
        '10. Children and young users',
        [
          'MUSTER Sport is intended for adults aged ${LegalConfig.minimumAge} or '
              'older who are enrolled at the university. You must confirm your age '
              'when creating an account.',
          'The service is not directed at children, and we do not knowingly collect '
              'personal data from anyone under the age of 13. If you believe a minor '
              'has created an account, contact us and we will remove it.',
        ],
      ),
      LegalSection(
        '11. How we protect your data',
        [
          'Data is stored on Google Firebase infrastructure. Access is restricted by '
              'role, enforced in server-side security rules, and transport is '
              'encrypted in transit. Sign-in credentials are handled by Firebase '
              'Authentication; the app never stores your password.',
          'No system is perfectly secure, but we do not sell data and we do not use '
              'it for advertising.',
        ],
      ),
      LegalSection(
        '12. Changes to this policy',
        [
          'If we make a material change, we will update the date at the top of this '
              'policy and describe the change in the app before it takes effect.',
        ],
      ),
    ],
  );

  static final LegalDocument _termsEn = LegalDocument(
    kind: LegalDocumentKind.terms,
    title: 'Terms of Service',
    intro:
        'These terms govern your use of MUSTER Sport. By creating an account you '
        'agree to them. If you do not agree, do not create an account.',
    sections: [
      LegalSection(
        '1. Eligibility',
        [
          'You must be at least ${LegalConfig.minimumAge} years old and enrolled at '
              '${LegalConfig.organisation} to hold an account. You must give accurate '
              'information and keep it up to date.',
        ],
      ),
      LegalSection(
        '2. Your account',
        [
          'You are responsible for what happens under your account, including keeping '
              'your password confidential. Every new account is created with the '
              'standard student role. Elevated roles such as coach or administrator '
              'are assigned by the university and cannot be self-selected.',
          'Tell us promptly if you suspect unauthorised access.',
        ],
      ),
      LegalSection(
        '3. Acceptable use',
        [
          'You agree not to use the platform to harass others, to impersonate '
              'anyone, to submit false registrations, to attempt to access data that '
              'is not yours, to bypass the security rules that govern the service, or '
              'to interfere with its operation.',
          'You must also follow the code of conduct and sports policies of the '
              'university. Where those rules and these terms overlap, the university '
              'rules apply.',
        ],
      ),
      LegalSection(
        '4. Bookings and payments',
        [
          'Facility bookings and event entries are subject to availability and to '
              'confirmation by the university. Any amount due is shown before you '
              'confirm, and MUSTER Sport does not add charges at a later step.',
          'The app does not process card payments. If you enter card details during '
              'booking, they are used for a local format check only, are not '
              'transmitted or stored, and settlement happens directly with the '
              'university.',
        ],
      ),
      LegalSection(
        '5. Content and results',
        [
          'Points, rankings and achievements are maintained for the purpose of the '
              'leaderboard. Final results, eligibility and any disciplinary outcome '
              'are decided by the university, not by this app.',
        ],
      ),
      LegalSection(
        '6. Availability',
        [
          'The service is provided on an as-available basis for a graduation project. '
              'We aim to keep it working, but we do not promise uninterrupted access.',
        ],
      ),
      LegalSection(
        '7. Suspension and termination',
        [
          'You may delete your account at any time from Settings. Administrators may '
              'suspend an account that breaks these terms, and may remove content '
              'that misrepresents the university.',
        ],
      ),
      LegalSection(
        '8. Disclaimer and liability',
        [
          'The service is provided without warranties of any kind, to the extent '
              'permitted by law. To the extent permitted by law, the operators are '
              'not liable for indirect or consequential loss arising from use of the '
              'service. Nothing here limits liability that cannot be limited by law.',
        ],
      ),
      LegalSection(
        '9. Changes and contact',
        [
          'We may update these terms; the effective date at the top always reflects '
              'the current version. Questions: ${LegalConfig.contactDisplay}',
        ],
      ),
    ],
  );

  static final LegalDocument _refundEn = LegalDocument(
    kind: LegalDocumentKind.refund,
    title: 'Refund Policy',
    intro:
        'This policy explains what you pay for, when a fee applies, and how a '
        'refund is handled. The short version: any charge is shown to you before '
        'you confirm, and there are no hidden fees.',
    sections: [
      LegalSection(
        '1. What the app costs',
        [
          'MUSTER Sport itself is free to download and to use. There is no paid '
              'tier, no subscription, and no advertising.',
        ],
      ),
      LegalSection(
        '2. Fees you may see',
        [
          'A facility booking or an organised event may carry a fee set by the '
              'university. That amount is displayed in full, together with the '
              'facility or event it applies to, before you confirm the booking. The '
              'price does not change after you confirm.',
          'MUSTER Sport does not add service charges, delivery fees, or any other '
              'surcharge on top of that amount.',
        ],
      ),
      LegalSection(
        '3. How payment is taken',
        [
          'The app does not process payments. If you enter card details in the '
              'booking form, they are checked for format on your device only, and '
              'are not transmitted to or stored by us. Any amount due is settled '
              'directly with the university through the channels it provides.',
        ],
      ),
      LegalSection(
        '4. Refunds for cancelled bookings',
        [
          'If a booking you paid for is cancelled by the university, the amount is '
              'returned through the same payment method you used, on the timescale '
              'that provider applies.',
          'If you cancel yourself, whether a fee is refundable depends on the '
              'notice period set by the university for that facility. That policy is '
              'shown to you before you confirm, so you can see it before committing.',
        ],
      ),
      LegalSection(
        '5. Duplicate or incorrect charges',
        [
          'If you believe you have been charged twice or charged for the wrong '
              'booking, contact us and we will investigate and correct it.',
          'Contact: ${LegalConfig.contactDisplay}',
        ],
      ),
    ],
  );

  static final LegalDocument _cookiesEn = LegalDocument(
    kind: LegalDocumentKind.cookies,
    title: 'Cookie Policy',
    intro:
        'This policy explains how MUSTER Sport uses cookies and similar local '
        'storage. The short version: the mobile app does not use cookies at all, '
        'and the web app uses storage only to keep you signed in.',
    sections: [
      LegalSection(
        '1. On the Android and iOS apps',
        [
          'The mobile apps do not use cookies. Android and iOS apps are not served '
              'over HTTP, so there is no cookie mechanism available.',
          'Instead, the app keeps a small amount of information in your device\'s '
              'local storage so it can start quickly and remember your preferences.',
        ],
        bullets: [
          'Your chosen language and light or dark theme.',
          'Your notification preferences.',
          'A sign-in marker, bound to your account, which expires after 30 days and '
              'is removed when you sign out.',
          'A cached copy of your own profile, used for display only.',
          'No cookies, no advertising identifiers, and no cross-site tracking.',
        ],
      ),
      LegalSection(
        '2. On the web app',
        [
          'The web version may store a small amount of data in your browser to keep '
              'you signed in and to remember your preferences.',
        ],
        bullets: [
          'Sign-in and session storage, required for you to stay logged in.',
          'Preference storage, such as language and theme.',
        ],
      ),
      LegalSection(
        '3. How to control it',
        [
          'On mobile, clearing the app\'s storage, or signing out, removes the local '
              'data. Uninstalling the app removes it entirely.',
          'In a browser, you can clear cookies and site data for this site at any '
              'time. Doing so signs you out but does not delete your account.',
        ],
      ),
    ],
  );

  // ───────────────────────────── Arabic ─────────────────────────────

  static final LegalDocument _privacyAr = LegalDocument(
    kind: LegalDocumentKind.privacy,
    title: 'سياسة الخصوصية',
    intro: 'توضّح هذه السياسة البيانات الشخصية التي يجمعها تطبيق MUSTER Sport، '
        'ولماذا نجمعها، ومن يمكنه الاطلاع عليها، وكيف تتحكم بها أو تحذفها. '
        'تنطبق على تطبيق MUSTER Sport على الهاتف وعلى الويب.',
    sections: [
      LegalSection(
        '١. من نحن',
        [
          'يتولى تشغيل MUSTER Sport ${LegalConfig.organisation} كمشروع تخرج '
              '("نحن"). نحن الجهة المتحكمة في البيانات الشخصية الموضحة في هذه السياسة.',
          'لأي استفسار عن هذه السياسة أو عن بياناتك: ${LegalConfig.contactDisplay}',
        ],
      ),
      LegalSection(
        '٢. البيانات التي تقدّمها لنا',
        [
          'نجمع فقط ما يحتاجه التطبيق لتشغيل منصة رياضية جامعية، وتقدّمه أنت '
              'أثناء إنشاء الحساب وتحرير الملف الشخصي.',
        ],
        bullets: [
          'الحساب: الاسم، والبريد الإلكتروني الجامعي، ورقم الهاتف، والرقم الجامعي، والكلية.',
          'الملف الشخصي: الصورة، ونبذة تعريف، والدور (كل حساب جديد يُنشأ كطالب).',
          'النشاط: الفعاليات التي تسجّل فيها، والمنشآت التي تحجزها، وحالة كل تسجيل أو حجز.',
          'الأداء: النقاط والترتيب والإنجازات وسجل المباريات المستخدمة في لوحة المتصدرين.',
        ],
      ),
      LegalSection(
        '٣. البيانات التي ننشئها تلقائيًا',
        [
          'تُنشأ هذه البيانات لتشغيل التطبيق، ولا تُستخدم للإعلانات أو التنبّؤ بسلوكك.',
        ],
        bullets: [
          'رمز جهاز خاص بالإشعارات، ليتمكّن التطبيق من تنبيهك بتحديثات التسجيل والحجز. '
              'يمكنك إيقاف الإشعارات في أي وقت من إعدادات الإشعارات.',
          'تفضيلات محفوظة على جهازك: اللغة، ونمط العرض، وعلامة تسجيل دخول قصيرة الأجل. '
              'هذه العلامة مرتبطة بمعرّف حسابك، وتنتهي صلاحيتها بعد ٣٠ يومًا، '
              'وتُحذف عند تسجيل الخروج.',
        ],
      ),
      LegalSection(
        '٤. البيانات التي لا نجمعها',
        [
          'لا يحتوي MUSTER Sport على أي حزمة إعلانية، ولا على أدوات تحليل أو '
              'تتبّع من طرف ثالث، ولا على أي تكامل مع وسطاء بيانات. '
              'لا نبني ملفات إعلانية، ولا نبيع البيانات الشخصية ولا نؤجّرها.',
        ],
      ),
      LegalSection(
        '٥. من يمكنه رؤية بياناتك',
        [
          'يكون الوصول محدودًا حسب الدور ومُطبَّق على الخادم لا في الواجهة فقط، '
              'ولا يستطيع بقية الطلاب تصفح سجلّك.',
        ],
        bullets: [
          'يمكنك قراءة ملفك الشخصي وتعديله.',
          'يمكن لمسؤولي الجامعة إدارة الحسابات والفعاليات والحجوزات، وهذا ضروري لتشغيل المنصة.',
          'يرى المدربون الطلاب المسجّلين في نشاطه فقط، ولا يرون قاعدة بيانات المستخدمين بالكامل.',
          'لوحة المتصدرين العامة تعرض اسمك المعروض وكليتك ونقاطك وترتيبك فقط. '
              'البريد الإلكتروني ورقم الهاتف والرقم الجامعي لا تُنشر فيها أبدًا.',
        ],
      ),
      LegalSection(
        '٦. الخدمات الخارجية التي نعتمد عليها',
        [
          'تعمل هذه المزوّدات على البيانات فقط لتقديم المزايا التي تستخدمها، '
              'وتخضع لكلمات خصوصيتها الخاصة.',
        ],
        bullets: [
          'Google Firebase Authentication — لتسجيل الدخول وحفظ بيانات اعتماد الحساب.',
          'Google Cloud Firestore — لحفظ ملفك الشخصي والفعاليات والحجوزات والنقاط.',
          'Firebase Cloud Messaging — لإرسال الإشعارات الفورية.',
          'Google Fonts — لتوفير ملفات الخطوط المستخدمة في الواجهة.',
          'التخزين المحلي في نظام التشغيل — لحفظ التفضيلات.',
        ],
      ),
      LegalSection(
        '٧. المدفوعات وبيانات البطاقات',
        [
          'لا يعالج MUSTER Sport المدفوعات. إذا اخترت خيار البطاقة أثناء حجز منشأة، '
              'فإن رقم البطاقة وتاريخ الانتهاء ورمز الأمان تُكتب داخل التطبيق '
              'ويُتحقق من شكلها على جهازك فقط، ولا تُرسل إلينا ولا تُحفظ على خوادمنا '
              'ولا على الجهاز. أي مبلغ مستحق يُسوّى مباشرة مع الجامعة عبر القنوات التي توفرها.',
        ],
      ),
      LegalSection(
        '٨. مدة الاحتفاظ بالبيانات',
        [
          'تُحفظ بياناتك ما دام حسابك نشطًا. عند حذف حسابك من الإعدادات، '
              'نزيل ملفك الشخصي وتسجيلاتك وحجوزاتك ومعلومتك من لوحة المتصدرين من أنظمةنا.',
        ],
      ),
      LegalSection(
        '٩. حقوقك',
        [
          'يمكنك ممارسة هذه الحقوق مباشرة من داخل التطبيق دون مراسلتنا.',
        ],
        bullets: [
          'الاطلاع على بياناتك وتصحيحها — عدّل ملفك الشخصي في أي وقت.',
          'حذف حسابك وبياناتك — الإعدادات ثم حذف الحساب، مع إعادة إدخال كلمة المرور '
              'وكتابة كلمة تأكيد.',
          'سحب موافقتك على الإشعارات — أوقف الإشعارات من الإعدادات لتتوقف عن استلامها.',
          'طلب نسخة من بياناتك أو طرح سؤال — تواصل معنا عبر العنوان في القسم ١.',
        ],
      ),
      LegalSection(
        '١٠. الأطفال ذوو السن الأصغر',
        [
          'صُمّم MUSTER Sport للبالغين من عمر ${LegalConfig.minimumAge} سنة فأكثر '
              'والمسجّلين بالجامعة، ويجب أن تؤكّد عمرك عند إنشاء الحساب.',
          'الخدمة غير موجّهة للأطفال، ولا نجمع عن علم بيانات شخصية من أي شخص دون '
              'سن ١٣ عامًا. إذا اعتقدت أن طفلًا أنشأ حسابًا فتواصل معنا وسنزيله.',
        ],
      ),
      LegalSection(
        '١١. كيف نحمي بياناتك',
        [
          'تُخزَّن البيانات على بنية Google Firebase. الوصول مقيد حسب الدور، '
              'ومُطبَّق عبر قواعد الأمان على الخادم، والاتصال مشفَّر أثناء النقل. '
              'تتولى Firebase Authentication بيانات الاعتماد، ولا يحفظ التطبيق كلمة المرور أبدًا.',
          'لا يوجد نظام آمن تمامًا، لكننا لا نبيع البيانات ولا نستخدمها في الإعلانات.',
        ],
      ),
      LegalSection(
        '١٢. تعديلات هذه السياسة',
        [
          'عند إجراء تعديل جوهري، سنحدّث التاريخ أعلى السياسة ونوضّح التغيير داخل '
              'التطبيق قبل سريانه.',
        ],
      ),
    ],
  );

  static final LegalDocument _termsAr = LegalDocument(
    kind: LegalDocumentKind.terms,
    title: 'شروط الاستخدام',
    intro:
        'تحكم هذه شروط استخدامك لتطبيق MUSTER Sport. بإنشائك حسابًا فإنك توافق عليها. '
        'وإن لم توافق فلا تنشئ حسابًا.',
    sections: [
      LegalSection(
        '١. شروط الأهلية',
        [
          'يجب أن يكون عمرك ${LegalConfig.minimumAge} عامًا على الأقل وأن تكون '
              'مُسجّلًا في ${LegalConfig.organisation} لإنشاء حساب. '
              'ويجب أن تُقدّم بيانات صحيحة وتُحدّثها باستمرار.',
        ],
      ),
      LegalSection(
        '٢. حسابك',
        [
          'أنت مسؤول عن كل ما يحدث عبر حسابك، بما في ذلك الحفاظ على سرية كلمة المرور. '
              'يُنشأ كل حساب جديد بالدور القياسي للطالب، أما الأدوار الأعلى مثل المدرب '
              'أو المسؤول فتُمنح من الجامعة ولا يمكن للمستخدم اختيارها بنفسه.',
          'أخبرنا فورًا إذا اشتبهت في وصول غير مصرّح به إلى حسابك.',
        ],
      ),
      LegalSection(
        '٣. الاستخدام المقبول',
        [
          'تتعهد بعدم استخدام المنصة للإساءة إلى الآخرين، أو انتحال شخصية أحدهم، '
              'أو تقديم تسجيلات غير صحيحة، أو محاولة الوصول إلى بيانات لا تخصّك، '
              'أو تجاوز قواعد الأمان التي تحكم الخدمة، أو تعطيل تشغيلها.',
          'كما تلتزم بلائحة السلوك وسياسات الرياضة في الجامعة، وعند التعارض '
              'تسود سياسات الجامعة.',
        ],
      ),
      LegalSection(
        '٤. الحجوزات والمدفوعات',
        [
          'تخضع حجوزات المنشآت والمشاركة في الفعاليات للتوافر وللتأكيد من الجامعة. '
              'يظهر أي مبلغ مستحق بالكامل قبل التأكيد، ولا يضيف MUSTER Sport أي '
              'رسوم إضافية في خطوة لاحقة.',
          'لا يعالج التطبيق مدفوعات البطاقات. وإذا أدخلت بيانات بطاقة أثناء الحجز '
              'فإنها تُستخدم للتحقق من الشكل على جهازك فقط، ولا تُرسل ولا تُحفظ، '
              'ويتم التسوية مباشرة مع الجامعة.',
        ],
      ),
      LegalSection(
        '٥. المحتوى والنتائج',
        [
          'تُدار النقاط والترتيبات والإنجازات لغرض لوحة المتصدرين، أما النتائج النهائية '
              'والأهلية وأي إجراء تأديبي فيقررها универси لا التطبيق.',
        ],
      ),
      LegalSection(
        '٦. توافر الخدمة',
        [
          'تُقدَّم الخدمة على أساس توفّرها ضمن مشروع تخرج. نحرص على استمرار عملها، '
              'لكننا لا نضمن عدم انقطاع الوصول.',
        ],
      ),
      LegalSection(
        '٧. الإيقاف وإنهاء الحساب',
        [
          'يمكنك حذف حسابك في أي وقت من الإعدادات. وللمسؤولين إيقاف حساب يخالف هذه '
              'الشروط، وحذف محتوى لا يمثّل الجامعة تمثيلًا صحيحًا.',
        ],
      ),
      LegalSection(
        '٨. إخلاء المسؤولية',
        [
          'تُقدَّم الخدمة دون أي ضمانات، في حدود ما يسمح به القانون. '
              'وفي حدود ما يسمح به القانون لا يتحمل المشغّلون أي خسارة غير مباشرة '
              'ناجمة عن استخدام الخدمة، ولا يحدّ هذا النص أي مسؤولية لا يجيز القانون استبعادها.',
        ],
      ),
      LegalSection(
        '٩. التعديلات والتواصل',
        [
          'قد نحدّث هذه الشروط، ويعكس تاريخ السريان أعلى الوثيقة النسخة الحالية دائمًا. '
              'للاستفسار: ${LegalConfig.contactDisplay}',
        ],
      ),
    ],
  );

  static final LegalDocument _refundAr = LegalDocument(
    kind: LegalDocumentKind.refund,
    title: 'سياسة الاسترجاع',
    intro:
        'توضّح هذه السياسة ما الذي تدفع مقابله، ومتى تُطبَّق رسوم، وكيف يتم الاسترجاع. '
        ' باختصار: يُعرض أي مبلغ عليك قبل التأكيد، ولا توجد رسوم خفية.',
    sections: [
      LegalSection(
        '١. تكلفة التطبيق',
        [
          'تحميل MUSTER Sport واستخدامه مجانيان بالكامل. لا توجد طبقة مدفوعة، '
              'ولا اشتراك، ولا إعلانات.',
        ],
      ),
      LegalSection(
        '٢. الرسوم التي قد تظهر',
        [
          'قد يترتب على حجز منشأة أو فعالية منظّمة رسم تحدّده الجامعة. '
              'يُعرض هذا المبلغ كاملًا مع المنشأة أو الفعالية ذات الصلة قبل تأكيد الحجز، '
              'ولا يتغير السعر بعد التأكيد.',
          'لا يضيف MUSTER Sport رسوم خدمة أو توصيل أو أي إضافة على هذا المبلغ.',
        ],
      ),
      LegalSection(
        '٣. طريقة السداد',
        [
          'لا يعالج التطبيق المدفوعات. وإذا أدخلت بيانات بطاقة في نموذج الحجز '
              'فإنها تُتحقق من شكلها على جهازك فقط، ولا تُرسل إلينا ولا تُحفظ لدينا. '
              'ويُسوّى أي مبلغ مستحق مباشرة مع الجامعة عبر القنوات التي توفرها.',
        ],
      ),
      LegalSection(
        '٤. استرجاع مبالغ الحجوزات الملغاة',
        [
          'إذا ألغت الجامعة حجزًا دفعت مقابله، يُعاد المبلغ بنفس وسيلة الدفع التي '
              'استخدمتها، وعلى المدة التي يطبقها مقدم الخدمة.',
          'وإذا ألغيت أنت بنفسك، فيعتمد ردّ الرسوم على مدة الإشعار التي تحدّدها '
              'الجامعة لتلك المنشأة. وتُعرض عليك هذه السياسة قبل التأكيد، '
              'فتراها قبل الالتزام.',
        ],
      ),
      LegalSection(
        '٥. الرسوم المكررة أو غير الصحيحة',
        [
          'إذا رأيت أنك حُسبت مرتين أو حُسبت مقابل حجز خاطئ، فتواصل معنا '
              'وسنتحقق من ذلك ونصحّحه.',
          'التواصل: ${LegalConfig.contactDisplay}',
        ],
      ),
    ],
  );

  static final LegalDocument _cookiesAr = LegalDocument(
    kind: LegalDocumentKind.cookies,
    title: 'سياسة ملفات تعريف الارتباط',
    intro: 'توضّح هذه السياسة كيف يستخدم MUSTER Sport ملفات تعريف الارتباط '
        'والتخزين المحلي المشابه. باختصار: لا يستخدم التطبيق على الهاتف ملفات '
        'تعريف ارتباط إطلاقًا، ويستخدم تطبيق الويب التخزين لإبقائك مسجّل الدخول فقط.',
    sections: [
      LegalSection(
        '١. على تطبيقات أندرويد و iOS',
        [
          'لا تستخدم تطبيقات الهاتف ملفات تعريف الارتباط، فهي لا تُقدَّم عبر بروتوكول '
              'HTTP فلا تتوفر فيها آلية ملفات تعريف الارتباط.',
          'بدلًا من ذلك يحتفظ التطبيق بمعلومات محدودة في التخزين المحلي لجهازك '
              'ليبدأ بسرعة ويتذكر تفضيلاتك.',
        ],
        bullets: [
          'اللغة التي اخترتها ونمط العرض الفاتح أو الداكن.',
          'تفضيلات الإشعارات.',
          'علامة تسجيل دخول مرتبطة بحسابك، تنتهي صلاحيتها بعد ٣٠ يومًا وتُحذف عند تسجيل الخروج.',
          'نسخة مخزّنة من ملفك الشخصي، تُستخدم للعرض فقط.',
          'لا توجد ملفات تعريف ارتباط، ولا معرّفات إعلانية، ولا تتبّع عبر المواقع.',
        ],
      ),
      LegalSection(
        '٢. على نسخة الويب',
        [
          'قد يخزّن إصدار الويب قدرًا صغيرًا من البيانات في متصفحك لإبقائك مسجّل '
              'الدخول ولتذكّر تفضيلاتك.',
        ],
        bullets: [
          'بيانات تسجيل الدخول والجلسة، المطلوبة لبقائك مسجّلًا.',
          'تفضيلات مثل اللغة ونمط العرض.',
        ],
      ),
      LegalSection(
        '٣. كيفية التحكم',
        [
          'على الهاتف، يؤدي مسح بيانات التطبيق أو تسجيل الخروج إلى إزالة البيانات '
              'المحلية، وإزالة التطبيق تحذفها بالكامل.',
          'وفي المتصفح يمكنك مسح ملفات تعريف الارتباط وبيانات الموقع في أي وقت. '
              'و يؤدي ذلك إلى إخراجك من الحساب لكنه لا يحذف حسابك.',
        ],
      ),
    ],
  );

  static final Map<LegalDocumentKind, LegalDocument> _english = {
    LegalDocumentKind.privacy: _privacyEn,
    LegalDocumentKind.terms: _termsEn,
    LegalDocumentKind.refund: _refundEn,
    LegalDocumentKind.cookies: _cookiesEn,
  };

  static final Map<LegalDocumentKind, LegalDocument> _arabic = {
    LegalDocumentKind.privacy: _privacyAr,
    LegalDocumentKind.terms: _termsAr,
    LegalDocumentKind.refund: _refundAr,
    LegalDocumentKind.cookies: _cookiesAr,
  };
}
