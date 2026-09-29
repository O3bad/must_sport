// lib/core/legal/legal_content.dart
// In-app legal documents.
//
// The text describes what MUSTER Sport actually does today. It was written
// against the shipped source and pubspec, not copied from a template:
//   * no advertising, no data sale, no behavioural analytics SDK is present
//   * the only processors are Firebase (Auth / Firestore / Cloud Messaging)
//     and google_fonts, which fetches font files from Google
//   * the booking flow collects no payment credentials or processes payments
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
          '${LegalConfig.operatorName} operates MUSTER Sport as a graduation '
              'project associated with ${LegalConfig.organisation} ("we", "us"). '
              'The project operator is the contact for the personal data '
              'described in this policy.',
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
          'Activity registration: contact phone number, faculty, semester, experience '
              'level and any message you choose to provide. Team registration may '
              'also include teammates’ names, student IDs and faculties.',
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
          'The app may cache your profile, bookings, enrolments, activity '
              'registrations and in-app notifications on your device or browser. '
              'Signing out removes the session marker but does not clear all cached '
              'data; account deletion clears the cached data associated with your account.',
          'We do not send marketing emails or operate a mailing list. The app only '
              'offers user-requested account email, such as password-reset messages, '
              'which is not marketing and has no unsubscribe link. If marketing email '
              'is introduced, every message must include an English unsubscribe link '
              'and a working opt-out.',
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
          'Google Fonts — supplies interface font files at runtime through the '
              'google_fonts package. Font requests disclose your IP address and '
              'request metadata to Google.',
          'Shared device or browser storage — holds preferences and cached app data.',
        ],
      ),
      LegalSection(
        '7. Payments',
        [
          'MUSTER Sport does not collect or process payments. The app does not '
              'request or store payment credentials. Any amount due is paid '
              'directly to the university or facility using the channels it provides.',
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
          'Facility bookings and event entries are subject to availability and '
              'confirmation by the university. Fees and payment arrangements, if '
              'any, are set by the university or facility and must be confirmed '
              'directly with it; MUSTER Sport does not display or collect them.',
          'MUSTER Sport does not collect or process payment. Any amount due is '
              'paid directly to the university or facility; no payment credentials '
              'are requested or stored in the app.',
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
        'This policy explains how facility fees and refunds are handled. MUSTER '
        'Sport does not set, display, collect, or process facility payments; '
        'contact the university or facility for its current fee and refund rules.',
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
          'A facility booking or organised event may carry a fee set by the '
              'university. MUSTER Sport does not display or collect that fee. '
              'Confirm the applicable amount and payment arrangements directly '
              'with the university or facility before booking.',
          'MUSTER Sport does not add service charges, delivery fees, or any other '
              'surcharge on top of that amount.',
        ],
      ),
      LegalSection(
        '3. How payment is taken',
        [
          'MUSTER Sport does not collect or process payment. Any amount due is '
              'paid directly to the university or facility through the channels '
              'it provides.',
        ],
      ),
      LegalSection(
        '4. Refunds for cancelled bookings',
        [
          'Any refund for a booking fee is handled by the university or facility '
              'under its published refund policy. Contact it directly for the '
              'applicable process and timescale.',
          'If you cancel yourself, any refund depends on the policy set by the '
              'university or facility. Contact it directly for the applicable '
              'conditions and process.',
        ],
      ),
      LegalSection(
        '5. Duplicate or incorrect charges',
        [
          'If you believe a payment was charged incorrectly, contact the university '
              'or facility that collected it.',
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
        'and the web app uses browser storage for sign-in, preferences and local app data.',
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
          'Cached profile, booking, enrolment, activity registration and notification data.',
          'No cookies, no advertising identifiers, and no cross-site tracking.',
        ],
      ),
      LegalSection(
        '2. On the web app',
        [
          'The web version uses browser storage to keep you signed in, remember '
              'preferences and retain local app data.',
        ],
        bullets: [
          'Sign-in and session storage, required for you to stay logged in.',
          'Preference storage, such as language and theme.',
          'Cached profile, booking, enrolment, activity registration and notification data.',
          'No advertising or analytics cookies are used.',
        ],
      ),
      LegalSection(
        '3. How to control it',
        [
          'On mobile, clearing the app\'s storage or uninstalling the app removes '
              'local data. Signing out removes the session marker but may leave '
              'other cached data on the device.',
          'In a browser, you can clear cookies and site data for this site at any '
              'time. Doing so signs you out and clears locally cached app data, but '
              'does not delete your account.',
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
          'يدير ${LegalConfig.operatorName} تطبيق MUSTER Sport كمشروع تخرج '
              'مرتبط بـ ${LegalConfig.organisation} ("نحن"). مشغّل المشروع هو '
              'جهة التواصل بشأن البيانات الشخصية الموضحة في هذه السياسة.',
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
          'التسجيل في الأنشطة: رقم هاتف للتواصل، والكلية، والفصل الدراسي، '
              'ومستوى الخبرة وأي رسالة تختار إرسالها. وقد يتضمن تسجيل الفريق '
              'أسماء زملائك وأرقامهم الجامعية وكلياتهم.',
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
          'قد يحتفظ التطبيق بنسخة محلية من ملفك الشخصي وحجوزاتك وتسجيلاتك '
              'وإشعاراتك على الجهاز أو المتصفح. يؤدي تسجيل الخروج إلى إزالة علامة '
              'الجلسة لكنه لا يمسح كل البيانات المخزّنة؛ وحذف الحساب يمسح بياناته المحلية.',
          'لا نرسل رسائل تسويقية ولا ندير قائمة بريدية. يتيح التطبيق فقط رسائل '
              'الحساب التي يطلبها المستخدم، مثل رسائل إعادة تعيين كلمة المرور، '
              'وهي ليست رسائل تسويقية ولا تتطلب رابط إلغاء اشتراك. إذا أُضيف البريد '
              'التسويقي مستقبلًا، يجب أن تتضمن كل رسالة رابط إلغاء اشتراك باللغة '
              'الإنجليزية وخيارًا فعّالًا لإيقافها.',
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
          'Google Fonts — توفّر ملفات خطوط الواجهة عند التشغيل عبر حزمة '
              'google_fonts. تكشف طلبات الخطوط عنوان IP وبيانات الطلب لشركة Google.',
          'التخزين المحلي على الجهاز أو المتصفح — لحفظ التفضيلات ونسخ بيانات التطبيق.',
        ],
      ),
      LegalSection(
        '٧. المدفوعات',
        [
          'لا يجمع MUSTER Sport المدفوعات ولا يعالجها. لا يطلب التطبيق بيانات '
              'الدفع ولا يحفظها. يُدفع أي مبلغ مستحق مباشرة إلى الجامعة أو المنشأة '
              'عبر القنوات التي توفرها.',
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
          'تخضع حجوزات المنشآت والمشاركة في الفعاليات للتوافر ولتأكيد الجامعة. '
              'تحدد الجامعة أو المنشأة أي رسوم وترتيبات للسداد، ويجب تأكيدها '
              'مباشرةً معها؛ لا يعرضها MUSTER Sport ولا يجمعها.',
          'لا يجمع MUSTER Sport المدفوعات ولا يعالجها. يُدفع أي مبلغ مستحق مباشرة '
              'إلى الجامعة أو المنشأة؛ ولا يطلب التطبيق بيانات الدفع ولا يحفظها.',
        ],
      ),
      LegalSection(
        '٥. المحتوى والنتائج',
        [
          'تُدار النقاط والترتيبات والإنجازات لغرض لوحة المتصدرين، أما النتائج النهائية '
              'والأهلية وأي إجراء تأديبي فتقررها الجامعة لا التطبيق.',
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
        'توضّح هذه السياسة كيفية التعامل مع رسوم المنشآت واستردادها. لا يحدد '
        'MUSTER Sport رسوم المنشآت ولا يعرضها ولا يجمعها ولا يعالجها؛ '
        'تواصل مع الجامعة أو المنشأة لمعرفة الرسوم وسياسة الاسترداد.',
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
              'لا يعرض MUSTER Sport هذا الرسم ولا يجمعه. تأكد من المبلغ '
              'وترتيبات السداد مباشرةً مع الجامعة أو المنشأة قبل الحجز.',
          'لا يضيف MUSTER Sport رسوم خدمة أو توصيل أو رسومًا إضافية.',
        ],
      ),
      LegalSection(
        '٣. طريقة السداد',
        [
          'لا يحدد MUSTER Sport رسوم المنشآت ولا يعرضها ولا يجمعها ولا يعالجها. '
              'تواصل مع الجامعة أو المنشأة مباشرة لمعرفة الرسوم وطرق السداد.',
        ],
      ),
      LegalSection(
        '٤. استرجاع مبالغ الحجوزات الملغاة',
        [
          'تتولى الجامعة أو المنشأة أي استرداد لرسوم الحجز وفق سياسة الاسترداد '
              'المعلنة لديها. تواصل معها مباشرة لمعرفة الإجراءات والمدة.',
          'إذا ألغيت الحجز بنفسك، فيعتمد ردّ الرسوم على سياسة الجامعة أو المنشأة. '
              'تواصل معها مباشرةً لمعرفة الإجراءات والمدة.',
        ],
      ),
      LegalSection(
        '٥. الرسوم المكررة أو غير الصحيحة',
        [
          'إذا اعتقدت أن رسومًا قد حُصلت منك خطأً، فتواصل مع الجامعة أو المنشأة '
              'التي استلمت المبلغ.',
        ],
      ),
    ],
  );

  static final LegalDocument _cookiesAr = LegalDocument(
    kind: LegalDocumentKind.cookies,
    title: 'سياسة ملفات تعريف الارتباط',
    intro: 'توضّح هذه السياسة كيف يستخدم MUSTER Sport ملفات تعريف الارتباط '
        'والتخزين المحلي المشابه. باختصار: لا يستخدم التطبيق على الهاتف ملفات '
        'تعريف ارتباط إطلاقًا، ويستخدم الويب التخزين لتسجيل الدخول والتفضيلات وبيانات التطبيق المحلية.',
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
          'نسخ محلية من الملف الشخصي والحجوزات والتسجيلات والإشعارات.',
          'لا توجد ملفات تعريف ارتباط، ولا معرّفات إعلانية، ولا تتبّع عبر المواقع.',
        ],
      ),
      LegalSection(
        '٢. على نسخة الويب',
        [
          'يستخدم إصدار الويب تخزين المتصفح لإبقائك مسجّل الدخول وتذكّر '
              'التفضيلات والاحتفاظ ببيانات التطبيق المحلية.',
        ],
        bullets: [
          'بيانات تسجيل الدخول والجلسة، المطلوبة لبقائك مسجّلًا.',
          'تفضيلات مثل اللغة ونمط العرض.',
          'نسخ محلية من الملف الشخصي والحجوزات والتسجيلات والإشعارات.',
          'لا نستخدم ملفات تعريف ارتباط للإعلانات أو التحليلات.',
        ],
      ),
      LegalSection(
        '٣. كيفية التحكم',
        [
          'على الهاتف، يؤدي مسح بيانات التطبيق أو إزالة التطبيق إلى حذف البيانات '
              'المحلية. يزيل تسجيل الخروج علامة الجلسة، لكنه قد يترك بيانات أخرى مخزّنة.',
          'وفي المتصفح يمكنك مسح ملفات تعريف الارتباط وبيانات الموقع في أي وقت. '
              'يؤدي ذلك إلى إخراجك من الحساب ومسح البيانات المحلية، لكنه لا يحذف حسابك.',
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
