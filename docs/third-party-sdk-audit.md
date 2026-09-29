# Third-party SDK & data-flow audit

Scope: every direct dependency in `pubspec.yaml`, plus the Firebase and Google
backends the app talks to. Audited against the repository source on 2026-09-30;
repeat the audit against the actual store/web artifacts before release.

## Verdict in one line

No advertising SDK, no behavioural analytics SDK, and no third-party data broker
is present. Every external dependency is either a Google Firebase service needed
to run the product, a Flutter/Dart platform package, or a pure-UI package.

## Direct dependencies

| Package | Purpose | Personal data it can reach | Network | Verdict |
|---|---|---|---|---|
| `firebase_core` | SDK bootstrap | none by itself | Firebase endpoints | Justified |
| `firebase_auth` | Email/password sign-in | email, password (to Google Auth only) | Google Identity | Justified, disclosed in Privacy Policy §6 |
| `cloud_firestore` | App database | full user profile, bookings, events, points | Firestore | Justified, disclosed |
| `firebase_messaging` | Push notifications | device push token | FCM | Justified, disclosed; opt-out revokes the token |
| `flutter_local_notifications` | Renders push messages on device | notification text | none | Justified |
| `shared_preferences` | Local settings, session marker and cached app state | language, theme, notification prefs, cached profile, bookings, enrolments, activity registrations, in-app notifications and session marker | none | Disclosed in the Privacy and Cookie Policies; cached data may remain after sign-out |
| `google_fonts` | Font rendering | **IP address + request metadata when a font is fetched** | Google Fonts endpoints | Disclosed in the Privacy Policy and in-app license attribution. Fonts are fetched at runtime rather than bundled; bundle fonts and remove this dependency if eliminating this third-party request is required. |
| `provider` | State management | none | none | Justified |
| `intl` | Date/number formatting | none | none | Justified |
| `uuid` | Local ID generation | none | none | Justified |
| `flutter_localizations` | Localised strings | none | none | Justified |
| `flutter_test` / `flutter_lints` | Dev-only | n/a | n/a | Dev-only |

## Confirmed absent

Searched the whole of `lib/`, `android/` and `ios/` for the usual offenders.
None are present:

- Advertising / attribution: Google Mobile Ads, Facebook SDK, Unity Ads, Adjust,
  AppsFlyer, Branch, Singular — none.
- Analytics / tracking: Firebase Analytics, Google Analytics, Mixpanel,
  Amplitude, Segment, Sentry, Crashlytics — none.
- Location: no geolocation, no location permission requested. Booking asks the
  user to type a facility; the app never reads GPS.
- Contacts, SMS, call log, camera, microphone, health, "background location":
  no permission is declared in `AndroidManifest.xml` or `Info.plist`.
- Advertising ID: never requested. `android:allowBackup="false"`, no
  `usesCleartextTraffic`, and no storage-permission declarations.

## Data minimisation

Fields collected are defined by the current product implementation; their
necessity has not been approved by the university. Confirm each field before
production. Activity registration currently requests contact phone, faculty,
semester, experience level and an optional message. Team registration may also
request teammates' names, student IDs and faculties. Remove fields that the
university cannot justify as necessary.

Other findings:

1. **Payments are handled outside the app.** The booking flow collects no
   card, wallet, or other payment credentials. Amounts, collection, and refunds
   are handled directly by the university or facility.
2. **The leaderboard is a projection.** The public ranking reads
   `leaderboard/{uid}`, not `users/{uid}`, so email, phone and student ID are
   never exposed to other students.

## Outstanding actions

- [ ] Replace `google_fonts` runtime fetching with bundled font assets.
- [ ] Confirm licensing/provenance for the app icon and splash artwork; this
      repository audit does not establish their redistribution rights.
- [ ] Verify the operator's legal status and whether email-only contact is
      sufficient for the privacy notice in each target jurisdiction. The
      provided project contact requested publishing the email without a postal
      address.
- [ ] Verify approved facilities, activities, availability and fee data are
      configured; the current repository still contains mock fixtures.
- [ ] Re-run this audit whenever `pubspec.yaml` gains a dependency, and before
      any Play Store / App Store Data Safety declaration is submitted.
