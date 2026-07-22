# MUSTER Sport — Figma Design Specification
**A UI/UX redesign specification derived from the actual `must_sport` Flutter codebase**
Prepared for: Abdelrahman Abed · Package: `muster_sport` v1.0.0+1 · Analyzed: Aug 2026

> Scope discipline: this document changes **visual design and UX polish only**. Every screen, navigation path, role, business rule, and data flow described below is the one that exists in the code today. Where the code has a real problem (dead code, missing tokens, inconsistent components), it is flagged in Part 1 and addressed as a *design-system fix*, not a feature change.

---

## How to read this document

1. **Part 1** is the audit — what the app actually is today, warts included. Read this first; it's the "do not skip" step the brief asked for.
2. **Parts 2–4** are the new design system and component library — the toolkit a designer builds in Figma once.
3. **Part 5** applies that toolkit to every real screen.
4. **Parts 6–11** are the supporting deliverables: UX fixes, flows, Figma file structure, accessibility, the Flutter↔Figma mapping table, and a checklist against the original 16 deliverables.

---

# PART 1 — Current Application Analysis

## 1.1 What MUSTER is

MUSTER ("MUST Activities" / أنشطة MUST) is a bilingual (English/Arabic, full RTL) sports & arts management app for **Misr University for Science & Technology**. It runs on Firebase (Auth, Firestore, FCM, Storage) with a local `CacheService`/`SharedPreferences` fallback so the app is fully usable offline/in demo mode. State is managed with **Provider** (`ChangeNotifier`) as the live architecture; a parallel, unused **flutter_bloc** implementation exists alongside it (see 1.6).

Three roles, three shells:

| Role | Shell | Bottom-nav tabs |
|---|---|---|
| Student | `AppShell` | Home · Activity · Booking · Events · Apps (My Registrations) · Ranks (Leadership) · Profile — **7 tabs** |
| Admin | `AdminShell` | Dashboard · Requests · Booking · Events · Users · AI Guide — **6 tabs** |
| Coach | `CoachShell` | Dashboard · Athletes · Requests · AI Guide — **4 tabs** (reuses `AdminRegistrationsScreen` and `ChatbotScreen`) |

## 1.2 Full screen inventory

| # | Screen (class) | Route / access | Role(s) | Purpose |
|---|---|---|---|---|
| 1 | `SplashScreen` | app launch | all | Animated logo, routes by cached session + role |
| 2 | `LoginScreen` | `login` | all | Email/password sign-in, demo quick-fill credentials |
| 3 | `SignUpScreen` | `signup` | all | 2-page registration: role picker → details |
| 4 | `ForgotPasswordScreen` | `forgotPassword` | all | Email reset, inline success state |
| 5 | `HomeScreen` | tab (student) | student | Greeting hero, stat pills, quick access grid, tournament banner |
| 6 | `ActivitiesScreen` | tab (student) | student | Sports/Arts/All tab bar + category filters + search + list |
| 7 | `ActivityDetailScreen` | pushed | student | Hero detail, schedule/venue/coach info, CTA |
| 8 | `RegistrationFormScreen` | pushed | student | Multi-field activity registration form |
| 9 | `BookingScreen` | tab (student) | student | Facility booking: date → facility → time slot → payment |
| 10 | `MyReservationsScreen` | pushed | student | Upcoming/past bookings, remind/cancel |
| 11 | `EventsScreen` | tab (student) | student | Filterable event list with fill-ratio progress |
| 12 | `MyRegistrationsScreen` | tab (student) | student | All/Pending/Approved/Rejected registration status |
| 13 | `LeadershipScreen` | tab (student) | student | Animated podium + ranked leaderboard |
| 14 | `ProfileScreen` | tab (student) | student | Hero profile, stats, achievements, menu |
| 15 | `SettingsScreen` | pushed | all | Personal info, notification/privacy prefs, language, theme |
| 16 | `AboutScreen` | pushed | all | Mission, team, tech stack, credits |
| 17 | `SportsScreen` | pushed | student | Sport category grid → filters Events tab |
| 18 | `NotificationsScreen` | pushed | all | Grouped (Today/Yesterday/Earlier), swipe-to-delete |
| 19 | `ParticipationHistoryScreen` | pushed | student | Activities/Events/Bookings history + points |
| 20 | `ChatbotScreen` | pushed / tab (admin, coach) | all | Rule-based bilingual assistant |
| 21 | `AdminDashboardScreen` | tab (admin) | admin | Section-switching overview: stats, pending alerts, quick actions |
| 22 | `AdminRegistrationsScreen` | tab (admin, coach) | admin, coach | Approve/reject activity registrations |
| 23 | `AdminBookingsScreen` | tab (admin) | admin | Confirm/cancel facility bookings |
| 24 | `AdminEventsScreen` | tab (admin) | admin | Create/edit/delete events (bottom-sheet form) |
| 25 | `AdminUsersScreen` | tab (admin) | admin | Search/filter/remove users |
| 26 | `SendNotificationScreen` | pushed (admin) | admin | Broadcast composer (BLoC-driven) |
| 27 | `CoachDashboardScreen` | tab (coach) | coach | Pending/Approved/Total stats, "My Activities" |
| 28 | `CoachAthletesScreen` | tab (coach) | coach | Read-only roster of approved athletes |

**Flagged as dead/legacy — not part of the active app, excluded from the redesign scope but documented for the developer's awareness (see 1.6‑#4):**

| — | `AuthScreen` (+`AuthBloc`) | unrouted | BLoC-based combined login/register, superseded by `LoginScreen`/`SignUpScreen` |
| — | `CreateActivityScreen` | unrouted | BLoC-based, superseded by `AdminEventsScreen`'s inline sheet |
| — | `ManageUsersScreen` | unrouted | BLoC-based, superseded by `AdminUsersScreen` |

## 1.3 Navigation map

```
SplashScreen ──(session?)──┬── LoginScreen ──┬── SignUpScreen ── (back to Login)
                            │                 └── ForgotPasswordScreen
                            │
                            ├── AppShell (student, IndexedStack, 7 tabs)
                            │     Home · Activities · Booking · Events · MyRegistrations · Leadership · Profile
                            │     Activities ──push──> ActivityDetail ──push──> RegistrationForm
                            │     Booking ──inline──> payment method sheet ──> Confirmation
                            │     Home/Sports ──setNavIndex──> Events tab (filtered)
                            │     Any tab ──push──> Notifications / Settings / About / ParticipationHistory / Chatbot
                            │
                            ├── AdminShell (IndexedStack, 6 tabs)
                            │     Dashboard · Registrations · Bookings · Events · Users · Chatbot
                            │     Dashboard ──ExpandableTabs──> Overview/Events/Users/Actions sections
                            │     Dashboard quick actions ──setNavIndex──> other admin tabs, or push SendNotification
                            │
                            └── CoachShell (IndexedStack, 4 tabs)
                                  Dashboard · Athletes · Registrations(shared) · Chatbot(shared)
```

Key navigation mechanics a Figma prototype must reproduce:
- Each shell uses **IndexedStack**, not `Navigator` push, for tab switching — tab state is preserved (scroll position, filters) when switching away and back. In Figma this means each tab is a persistent frame, not a fresh navigation.
- Cross-tab jumps happen via `AppState.setNavIndex(i)` from *inside* another tab (Home's Quick Access cards, Sports category cards, Admin Dashboard's quick actions) — these are not simple "go to next screen" links, they're "jump to tab N and also apply a filter." Prototype these as two linked actions per tap: set filter → switch tab.
- `AdminRegistrationsScreen` and `ChatbotScreen` are **literally the same screen instance** reused across the Admin and Coach shells — one Figma component, instantiated in two nav contexts, not two separate screen designs.

## 1.4 Current design tokens (as extracted from `app_theme.dart` and `app_constants.dart`)

**Dark palette** (`DarkColors`, default theme)

| Token | Hex | Used as |
|---|---|---|
| bg | `#080F22` | Scaffold background |
| surface | `#0F1A33` | Cards, app bar |
| surface2 | `#162140` | Pressed/elevated surface |
| border | `#1E2F50` | Card borders, dividers |
| primary | `#00E5FF` (cyan) | CTAs, active states, links |
| secondary | `#A8FF3E` (lime) | Success accents, secondary CTAs |
| accent | `#FFB800` (amber) | Warnings, highlights, ratings |
| error | `#FF4757` | Errors, destructive actions |
| text | `#F0F4FF` | Primary text |
| muted | `#B8C8D8` | Secondary text |
| gold/silver/bronze | `#FFD700` / `#C0C0C0` / `#CD7F32` | Leaderboard podium |

**Light palette** (`LightColors`)

| Token | Hex | Used as |
|---|---|---|
| bg | `#EBEBEC` | Scaffold background |
| surface | `#FFFFFF` | Cards, app bar |
| surface2 | `#F4F4F6` | Pressed/elevated surface |
| border | `#D8D8DC` | Card borders, dividers |
| primary (blue) | `#2E65C3` | CTAs, active states |
| secondary (green) | `#37A66F` | Success accents |
| navy (text) | `#142B58` | Primary text |
| muted | `#4A5568` | Secondary text |
| error | `#D93025` | Errors |
| gold/silver/bronze | `#D4A017` / `#9E9E9E` / `#B07D3A` | Leaderboard podium |

**Note — the app currently has no `success`, `warning`, or `info` tokens.** Screens reuse `secondary` for success, `accent`/`gold` for warning, and `primary` for info *ad hoc*, per-widget. Part 3.1 formalizes this.

**Typography** — Google Fonts, no static asset bundling needed:

| Style method | Font | Weight | Line height | Arabic behavior |
|---|---|---|---|---|
| `display()` | Plus Jakarta Sans | 800 | 1.22 | Switches to Noto Kufi Arabic at 0.9× size, 800, 1.3 lh |
| `heading()` | Plus Jakarta Sans | 700 | 1.35 | Noto Kufi Arabic, 0.9×, 700, 1.4 lh |
| `body()` | Inter | 500 (default) | 1.55 | Noto Kufi Arabic, 0.9×, 1.6 lh |
| `label()` | Inter | 600 | 1.45, +0.55 letter-spacing | Noto Kufi Arabic, 0.9×, 600 |
| `stat()` | Plus Jakarta Sans | 800 | 1.15 | Noto Kufi Arabic, 0.9× |

Sizes are passed ad hoc per call site (spotted: 10, 11, 12, 13, 14, 15, 16, 18, 20, 24, 32) rather than drawn from a fixed scale — Part 3.2 formalizes a 9-step scale from this observed range. App-wide `MediaQuery` textScaler is clamped **0.9–1.15**.

**Spacing** (`AppSizes`): `paddingXS=4, S=8, M=16, L=24, XL=32, XXL=48` — a 6-step scale. Ad-hoc values of 10, 12, 14, 18, 20, 28, 36 appear directly in screens outside this scale (e.g., Sports category card padding=20, avatar sizes 44/52).

**Radius** (`AppSizes`): `radiusS=8, M=16, L=24, XL=32, Circle=100`. The global `CardThemeData` actually ships **20px** (not on the declared scale at all), and individual screens freely use 14/16/18/20 for "card-like" containers.

**Elevation**: `AppSizes.cardElevation = 8` is declared but **never consumed** — every `CardThemeData` sets `elevation: 0`. All visible depth comes from manual, per-widget `BoxShadow` (usually a soft dark shadow in light mode, or a `primary.withValues(alpha: ~0.12–0.35)` glow in dark mode/active states) — there is no shared elevation system today.

## 1.5 Reusable widget inventory (what already exists to design *from*, not around)

| Widget | File | Role |
|---|---|---|
| `MusterAppBar` | `theme/widgets.dart` | Logo + role badge + semester pill, language toggle, theme toggle, notification bell, sign-out |
| `AppCard` | `theme/widgets.dart` | Base card, 20px radius, optional glow/gradient, press-scale |
| `AppPill` | `theme/widgets.dart` | Rounded-100 label chip |
| `SectionLabel` | `theme/widgets.dart` | Uppercase section heading |
| `MusterDivider` | `theme/widgets.dart` | 2px gradient accent→border divider |
| `AppProgressBar` | `theme/widgets.dart` | Animated linear progress |
| `AppAvatar` | `theme/widgets.dart` | Gradient circle, initials or photo |
| `StatBox` | `theme/widgets.dart` | AppCard + animated counter + label |
| `ToastOverlay` | `theme/widgets.dart` | Top slide-in toast (in-house snackbar) |
| `QuickAccessCard` | `theme/widgets.dart` | Home quick-access tile |
| `MorphButton` | `theme/widgets.dart` | Primary CTA: button → spinner → checkmark, h=52, r=14 |
| `MusterSignOutDialog` | `theme/widgets.dart` | Shared confirm dialog, r=20 |
| `AnimatedNavBar` / `AnimatedNavItem` | `theme/animated_nav_bar.dart` | Bottom nav, 68px, floating pill container, r=20, spring-scale active item |
| `ExpandableTabs` / `ExpandableTabItem` | `widgets/expandable_tab_row.dart` | Frosted pill tab row w/ spring label-reveal |
| `ExpandableTabRow` / `FloatingExpandableTabRow` | same file | **Duplicate** of the above, second implementation |
| `GlowingButton` / `GlowingFAB` | `widgets/glowing_button.dart` | Pulsing-glow button / FAB, h=56, r=16 |
| `ShimmerBox` / `SkeletonCard` / `SkeletonList` | `theme/shimmer_loader.dart` | Loading skeletons |
| `ParticleBackground` | `widgets/particle_background.dart` | Floating-particle canvas — present, no confirmed usage in any read screen |
| `PressScale`, `PulseRings`, `LiquidProgressBar`, `CountUpText`, `TypingCursor`, `GlitchText`, `MagneticPull` | `theme/animations.dart` | Motion-language primitives |

## 1.6 Inconsistencies & UX weak points found (evidence-based)

1. **Two parallel `UserModel` definitions.** `core/models/user_model.dart` defines a Firestore-shaped model (`department`, `enrolledActivities`, `isActive`…) that is **not** what any screen actually renders. The model in active use, imported as `core/models/models.dart`, carries the gamification fields (`points`, `rank`, `cgpa`, `creditHours`, `achievements`, `faculty`, `semester`, `initials`, `stats`) that Profile, Settings, Leadership, and Sign-up all depend on. This is dead/confusing code, not a design issue — flagged here so a Flutter developer cleans it up; the design spec below is built exclusively against the *real* model.
2. **Auth screens don't theme.** `SplashScreen`, `LoginScreen`, `SignUpScreen`, and `ForgotPasswordScreen` hardcode `DarkColors.*` instead of the `context.xColor` theme-aware getters every other screen uses. Result: a user who prefers light mode still gets a dark-only first impression, and toggling theme post-login has no visible continuity with what they just saw.
3. **Duplicate faculty lists.** `kFaculties` (in `activity_state.dart`) and an inline `_faculties` array inside `signup_screen.dart` both enumerate the same 10 faculties independently — a future edit to one silently desyncs from the other.
4. **Legacy BLoC screens are dead weight.** `auth_screen.dart`/`auth_bloc.dart`, `create_activity_screen.dart`, and `manage_users_screen.dart` (all under `admin_bloc.dart`) are fully-built screens that duplicate functionality already shipped through the Provider-based screens, and are referenced nowhere in `app_router.dart` or either shell. They should not be redesigned — they should be deleted from the codebase. Noted so no Figma effort is spent on them.
5. **Radius drift.** The declared scale (`8/16/24/32/100`) doesn't include the *actual* most common card radius (`20`, from `CardThemeData`), and screens freely add 14/18 on top — three near-identical "rounded card" radii exist where one should.
6. **A declared-but-dead token.** `AppSizes.cardElevation = 8` is set once and used nowhere; every real card is flat (`elevation: 0`) with manual shadows layered on. A future engineer reading the constants file would reasonably assume elevation is Material-standard when it's actually fully custom per widget.
7. **No formal success/warning/info colors** (see 1.4) — every "this succeeded" or "this needs attention" moment picks its color from whichever of `secondary`/`accent`/`primary` felt right at that call site, screen to screen.
8. **Non-functional share affordances.** `ProfileScreen`'s achievement share sheet offers Story/Twitter/LinkedIn/Copy Link buttons that are UI-only stubs with no real share behavior wired up. Visually these look exactly as capable as every working button in the app — a user can't tell the difference until they tap.
9. **Disabled-but-styled upload control.** `SettingsScreen`'s avatar sheet presents 8 working solid-color swatches next to a "photo upload — coming soon" state that isn't visually distinguished as clearly disabled versus the color options that *do* work.
10. **Fragile coach-activity matching.** `CoachDashboardScreen`'s "My Activities" section finds a coach's own activities via a case-insensitive substring match on the coach's display name against the activity's free-text `coach` field, not a stable ID relationship. Not a visual defect, but the design must plan for a visible **empty/partial state** here — a coach whose name doesn't substring-match any activity's coach field currently sees nothing, silently.
11. **Motion is dense and uniform.** Glow pulses, shimmer sweeps, spring-elastic bounces, and gradient hero cards recur on nearly every screen at similar intensity — energetic, but it flattens hierarchy: a login button pulses at the same intensity as an achievement unlock. The visual-quality bar in the brief ("professional commercial app," not "generic/overcrowded") calls for reserving high-intensity motion for genuinely rare moments (success, unlock, first-run) and quieting default/idle states.
12. **Duplicate pill-tab component.** `ExpandableTabs` and `ExpandableTabRow`/`FloatingExpandableTabRow` are two independently built implementations of the same "horizontal scrollable filter pill row with spring expand" pattern, used in different screens with subtly different visual results (icon-only vs icon+label rules differ slightly).
13. **Fixed-height controls under text scaling.** The app clamps text scale to 0.9–1.15 (good, deliberate accessibility choice) but several controls (56px buttons, 44–52px avatars, fixed-height list rows) don't reflow — at the top of that scale range, labels are at real risk of clipping inside controls sized for the 1.0× case.
14. **Search fields aren't a shared component.** `ActivitiesScreen`, `AdminUsersScreen`, and `CoachAthletesScreen` each build their own search input with slightly different padding, radius, and icon treatment — a textbook case for one Figma/Flutter component instead of three near-twins.

## 1.7 Role deep-dive

- **Student** — the primary persona; owns 7 of the app's tabs and the richest feature set (browse/register for activities, book facilities & pay, follow events, track registrations, see leaderboard rank, manage profile/settings). Gamification (points, rank, achievements, CGPA display) is student-only and central to Home/Profile/Leadership.
- **Admin** — operational control: approve/reject activity registrations, confirm/cancel bookings, CRUD events, manage users, broadcast notifications. Sees a section-switching dashboard (Overview/Events/Users/Actions) rather than a tab-per-feature layout.
- **Coach** — a deliberately narrowed admin, per an explicit in-code comment: 4 tabs only, no user management, no full admin panel. Sees pending/approved counts for *their* activities, a roster of approved "athletes," and shares the registration-approval screen and chatbot with Admin.

---

# PART 2 — Design Direction

**Direction: "Confident Sports-Tech."** Keep the app's real identity — dark-first, cyan/lime/amber energy, bilingual, gamified — but bring it up to a professional commercial bar by tightening the systems that are currently ad hoc (spacing, radius, elevation, color roles, motion intensity) rather than reskinning the brand. This is an *evolution*, not a redesign from zero: the hex values, font families, and component names below are the ones already in the codebase, formalized and completed.

Principles:
1. **One 8pt-based system, no exceptions.** Every spacing, radius, and size value in new/updated screens comes from the scales in Part 3 — no more one-off 14/18/28/36px values.
2. **Color has meaning, not vibes.** Success is always the same green, warning always the same amber, info always the same cyan/blue, error always the same red — in both themes.
3. **Motion is a hierarchy tool, not decoration.** Reserve the strongest effects (elastic bounce, glow pulse, shimmer) for genuine state changes (success, unlock, active/selected); keep idle and default states calm.
4. **Theme parity.** Every screen, including auth, must render correctly and consistently in both light and dark themes — no hardcoded dark-only screens.
5. **RTL is not an afterthought.** All layouts use directional (`Start`/`End`) spacing and alignment, verified in both languages, matching the app's existing `Directionality`-aware pattern.
6. **Componentize repetition.** Anywhere the same pattern was hand-rebuilt 2–3 times in code (search fields, tab-pill rows, faculty pickers), Figma gets exactly one master component with variants — and the Flutter fix is to consolidate to match.
7. **Realistic for Flutter.** Every effect specified here (shadows, gradients, blur, spring curves) has a direct, already-proven Flutter equivalent in this codebase — nothing here requires a capability the app doesn't already demonstrate.

---

# PART 3 — Design System

## 3.1 Color

Keep all existing hex values (this is a maturation of the current palette, not a rebrand) and add the three missing semantic roles by assigning them to hues the app already uses elsewhere for exactly that meaning.

### Dark theme (default)

| Role | Token | Hex | Notes |
|---|---|---|---|
| Background | `bg` | `#080F22` | Scaffold |
| Surface | `surface` | `#0F1A33` | Cards, sheets, app bar |
| Surface (raised/pressed) | `surface2` | `#162140` | Hover/press states, nested cards |
| Border / Divider | `border` | `#1E2F50` | 1px hairlines |
| Primary | `primary` | `#00E5FF` | CTAs, active nav, links, focus ring |
| Secondary | `secondary` | `#A8FF3E` | Secondary emphasis, positive stats |
| Accent | `accent` | `#FFB800` | Highlights, ratings, featured badges |
| **Success** *(new formal role)* | `success` | `#A8FF3E` (=secondary) | Approved, confirmed, completed |
| **Warning** *(new formal role)* | `warning` | `#FFB800` (=accent) | Pending, low-capacity, needs-attention |
| **Info** *(new formal role)* | `info` | `#00E5FF` (=primary) | Neutral notices, tips |
| Error | `error` | `#FF4757` | Destructive, rejected, invalid |
| Text primary | `text` | `#F0F4FF` | |
| Text secondary | `muted` | `#B8C8D8` | |
| Gold / Silver / Bronze | — | `#FFD700` / `#C0C0C0` / `#CD7F32` | Podium only |

### Light theme

| Role | Token | Hex | Notes |
|---|---|---|---|
| Background | `bg` | `#EBEBEC` | |
| Surface | `surface` | `#FFFFFF` | |
| Surface (raised/pressed) | `surface2` | `#F4F4F6` | |
| Border / Divider | `border` | `#D8D8DC` | |
| Primary | `primary` | `#2E65C3` | |
| Secondary | `secondary` | `#37A66F` | |
| Accent | `accent` | `#D4A017` (gold) | |
| **Success** | `success` | `#37A66F` (=secondary) | |
| **Warning** | `warning` | `#D4A017` (=accent) | |
| **Info** | `info` | `#2E65C3` (=primary) | |
| Error | `error` | `#D93025` | |
| Text primary | `text` | `#142B58` (navy) | |
| Text secondary | `muted` | `#4A5568` | |
| Gold / Silver / Bronze | — | `#D4A017` / `#9E9E9E` / `#B07D3A` | Podium only |

**Contrast flags to carry into Figma (verify with the contrast plugin before final sign-off):**
- Dark-mode `accent` (`#FFB800`) and `secondary` (`#A8FF3E`) are bright/light colors — never pair **white** text on a solid fill of either; use `#080F22` (dark navy/bg) text on those fills instead.
- Light-mode `primary` (`#2E65C3`) with white button text sits close to the WCAG AA 4.5:1 body-text threshold — keep primary-fill button labels at ≥15px semibold (which the app already does via `AppTextStyles.body`/`MorphButton`) rather than smaller regular weight.
- All `text`/`bg` and `text`/`surface` pairs in both themes are high-contrast by construction — no action needed there.

## 3.2 Typography

Two font families are already wired via `google_fonts` with zero added dependency risk: **Plus Jakarta Sans** (display/heading/stat) and **Inter** (body/label), auto-swapped to **Noto Kufi Arabic** at 0.9× size for `ar` locale. Formalizing the observed size range into a 9-step scale:

| Style | Size (EN) | Size (AR, ×0.9) | Weight | Line height | Font | Flutter source |
|---|---|---|---|---|---|---|
| Display | 32 | 28.8 | 800 | 1.22 | Plus Jakarta Sans / Noto Kufi Arabic | `AppTextStyles.display(32)` |
| H1 | 24 | 21.6 | 800 | 1.22 | Plus Jakarta Sans | `display(24)` |
| H2 | 20 | 18 | 700 | 1.35 | Plus Jakarta Sans | `heading(20)` |
| H3 | 18 | 16.2 | 700 | 1.35 | Plus Jakarta Sans | `heading(18)` |
| H4 | 16 | 14.4 | 700 | 1.35 | Plus Jakarta Sans | `heading(16)` |
| Body Large | 16 | 14.4 | 500 | 1.55 | Inter | `body(16)` |
| Body | 14 | 12.6 | 500 | 1.55 | Inter | `body(14)` |
| Body Small | 12 | 10.8 | 500 | 1.55 | Inter | `body(12)` |
| Caption | 11 | 9.9 | 500 | 1.55 | Inter | `body(11)` |
| Button | 15–16 | — | 600–700 | 1.2 | Inter | inside `MorphButton`/`GlowingButton` |
| Label / Overline | 12.5 | 11.25 | 600 | 1.45, +0.55ls | Inter / Noto Kufi Arabic | `label()` |
| Stat / Number | 24–32 | ×0.9 | 800 | 1.15 | Plus Jakarta Sans | `stat()` |

RTL rule: every text style auto-detects `Localizations.localeOf(context).languageCode == 'ar'` and swaps family + drops 10% in size to compensate for Arabic's larger default glyph footprint — carry this exact rule into Figma text styles (build EN and AR variants of every style, AR at 0.9×).

## 3.3 Spacing scale

Extending the existing 6-step `AppSizes` scale to the requested 9 steps closes the gap that's currently plugged with ad-hoc values:

| Token | Value | Usage |
|---|---|---|
| space-1 | 4px | Icon-to-label gaps, tight badge padding |
| space-2 | 8px | Chip padding, small gaps between related elements |
| space-3 | **12px** *(new)* | Compact list-row internal padding, form field gaps |
| space-4 | 16px | Standard card padding, section internal padding |
| space-5 | 24px | Section-to-section gaps, screen horizontal padding |
| space-6 | 32px | Major section breaks |
| space-7 | **40px** *(new)* | Hero/header vertical breathing room |
| space-8 | 48px | Empty-state vertical centering, large section separation |
| space-9 | **64px** *(new)* | Splash/onboarding hero spacing |

## 3.4 Border radius

Reconciling the declared scale with the two most-used *actual* values (20 from the global card theme, and the 14–18 range scattered through screens):

| Token | Value | Usage |
|---|---|---|
| radius-xs | 8px | Small chips, inline badges |
| radius-sm | 12px | Inputs, small buttons, list-row icons |
| radius-md | 16px | Buttons (`MorphButton`), medium cards, dialogs |
| radius-lg | **20px** *(promoted from ad hoc to formal)* | Default card radius (matches `CardThemeData` today) |
| radius-xl | 24px | Hero cards, bottom sheets top corners, large containers |
| radius-2xl | 32px | Splash/hero graphics, large illustrations |
| radius-full | 999px | Pills, avatars, nav bar container, FAB |

## 3.5 Elevation / shadow system

Replace the current per-widget bespoke shadows with four named levels; keep the app's signature "colored glow on active state" as level 3, since it's a distinctive, already-proven part of the brand:

| Level | Name | Light theme | Dark theme | Used for |
|---|---|---|---|---|
| 0 | Flat | none | none | Default resting cards, list rows |
| 1 | Low | `0 2px 6px rgba(0,0,0,0.05)` | none (border-only) | Hover/lift on cards, pressed→released transition |
| 2 | Raised | `0 4px 12px rgba(0,0,0,0.08)` | `0 4px 16px rgba(primary,0.10)` | App bar shadow, bottom sheet, floating nav bar |
| 3 | Glow (active/success) | `0 0 20px rgba(primary,0.18)` | `0 0 28px rgba(primary,0.25–0.35)` | Selected states, primary CTA idle pulse (reserved, not default), achievement/success moments |

---

# PART 4 — Component Library

Every component below maps 1:1 to a real Flutter widget already in the codebase — build Figma variants that mirror the states that widget already implements, don't invent new ones.

### Buttons

| Component | Flutter source | Variants | States | Auto Layout |
|---|---|---|---|---|
| Primary Button | `MorphButton` | Filled (primary fill) | Default, Pressed, Loading (spinner morph), Success (checkmark morph), Disabled | Horizontal, center-aligned, hug width / fill option, padding 16/24, gap 8, height 52, radius-md |
| Secondary Button | new variant of `MorphButton` | Outlined (1px border, transparent fill) | Default, Pressed, Disabled | Same as Primary, border=1 `border` token |
| Text Button | ad hoc `TextButton` (Notifications "Mark all read", etc.) | Text-only | Default, Pressed, Disabled | Hug/hug, padding 8/4, no border |
| Icon Button | ad hoc `IconButton` (app bar actions) | Default, Filled-circle (e.g. notification bell) | Default, Pressed, Disabled, With-badge | 44×44 min tap target, icon 24, radius-full if filled |
| Glowing FAB | `GlowingFAB` | Primary | Default (pulsing glow, reserved for genuinely primary actions), Pressed | Fixed 56×56, radius-full |
| Glow CTA | `GlowingButton` | Filled w/ pulse | Default, Pressed, Disabled | height 56, radius-md, gap 8 |

### Inputs

| Component | Flutter source | Variants | States | Auto Layout |
|---|---|---|---|---|
| Text Field | `_GlowTextField` (auth) + ad hoc `TextField`s elsewhere → **consolidate to one component** | Standard, Multiline (bio/motivation), Read-only | Default, Focused (primary border+glow), Error (error border+helper text), Disabled | Vertical, padding 16/12, gap 4 (label→field→helper), radius-sm |
| Password Field | variant of Text Field | — | + show/hide toggle icon state | same |
| Search Field | 3 duplicate implementations today → **consolidate to one component** | Default, With-filter-chip-row | Default, Focused, Active-query (clear icon visible) | Horizontal, icon-leading, radius-full or radius-sm (pick one, spec uses radius-sm to match other inputs) |
| Dropdown / Select | faculty/semester/level `DropdownButtonFormField` | Standard | Default, Open, Selected, Disabled | Same as Text Field + trailing chevron |
| Checkbox | signup/registration terms checkboxes | Standard | Unchecked, Checked, Disabled | 20×20, radius-xs |
| Switch | Settings theme/notification toggles | Standard | Off, On, Disabled | Track 40×24, thumb 20 |
| Level/category chip (selectable) | `_ActivityCard` level chips, registration-form level picker | Single-select group | Default, Selected, Disabled | Hug, padding 12/8, radius-full |

### Cards

| Component | Flutter source | Variants | States | Auto Layout |
|---|---|---|---|---|
| Base Card | `AppCard` | Default, Glow (optional colored glow), Gradient | Default, Pressed (press-scale 0.97) | Vertical, padding 16–20, gap 12, radius-lg |
| Stat Box | `StatBox` (wraps AppCard) | Single-column (small phone), Grid item (standard+) | Default, Loading (shimmer) | Vertical, center-aligned, padding 16, gap 4 |
| Activity Card | `_ActivityCard` (Activities screen) | Sports, Arts | Default, Full (registered/spots-full badge), Registered | Vertical, padding 16, gap 8, radius-lg |
| Event Card | `_EventCard` (Events screen) | Open, Soon, Full, Completed | Default, Registered | Vertical, padding 16, gap 8, radius-lg, includes fill-ratio progress bar |
| User/Athlete Card | `_UserCard` (Admin Users), athlete rows (Coach Athletes) | Student, Admin, Coach (role-colored avatar) | Default, "YOU" badge, Pressed | Horizontal, padding 14, gap 12, radius-md |
| List Item (Notification) | `_NotifCard` | Read, Unread | Default, Swipe-revealed (delete), Pressed | Horizontal, padding 14, gap 12, radius-lg |
| Registration/Booking Card | `_RegCard`, booking list rows | By status (Pending/Approved/Rejected/Confirmed/Cancelled) | Default, With-action-banner | Vertical, padding 14–16, gap 8, radius-lg |

### Navigation

| Component | Flutter source | Variants | States | Auto Layout |
|---|---|---|---|---|
| App Bar | `MusterAppBar` | Standard (with role badge/semester pill), Simple (back button only, e.g. About/Sports) | Default | Horizontal, height 56–64, padding 16, bottom 1px divider |
| Bottom Nav | `AnimatedNavBar` | 7-tab (student), 6-tab (admin), 4-tab (coach) | Item: Default, Selected (pill bg 13% alpha + label reveal), With-badge | Horizontal, floating pill container, height 68, margin 12/6/12/8, radius-full |
| Filter Tab Row | `ExpandableTabs` (consolidate the duplicate `ExpandableTabRow` into this one) | Icon+label group, With-separator | Default, Selected (expanded, label visible), Collapsed (icon only) | Horizontal, scrollable, gap 8, pill padding 12/8, radius-full |
| Drawer | *not present in the app* | N/A — the app uses bottom-nav + app-bar exclusively, no drawer pattern exists or is needed | — | — |
| Tab Bar (in-screen) | Activities' Sports/Arts/All `TabBar` | 3-tab, 4-tab (My Registrations) | Default, Selected (underline) | Horizontal, equal-width or hug, per Material defaults |

### Feedback & overlays

| Component | Flutter source | Variants | States | Auto Layout |
|---|---|---|---|---|
| Dialog | `MusterSignOutDialog` + admin confirm dialogs | Confirm (2-action), Info (1-action) | Default | Vertical, padding 24, gap 16, radius-xl, scrim behind |
| Bottom Sheet | `_DetailSheet`, `_EventSheet`, `_AvatarEditorSheet`/`_AvatarPickerSheet` | Draggable-detail, Form, Picker | Default, Dragging | Vertical, top radius-xl only, drag handle, padding 20 |
| Toast / Snackbar | `ToastOverlay` | Success, Error, Info (map to new semantic colors) | Enter (slide-in), Visible, Exit | Horizontal, top-anchored, padding 14/16, radius-md |
| Loading Skeleton | `ShimmerBox`, `SkeletonCard`, `SkeletonList` | Card-shape, List-row-shape | Shimmering | Matches the shape it's standing in for |
| Empty State | ad hoc per screen (Notifications, My Registrations, Coach Athletes…) → **consolidate to one component** | Icon+headline+subtext, + optional CTA | Default | Vertical, centered, gap 16, icon 64 |
| Error State | *not consistently implemented anywhere read* — **new, needed** | Icon+headline+subtext+retry CTA | Default | Same shape as Empty State, error-color icon |
| Success State | `_SuccessScreen` (Registration Form), `_ConfirmationView` (Booking) | Full-screen confirmation | Default | Vertical, centered, checkmark/illustration, gap 16, CTA |

### Auto Layout defaults (apply to all components unless noted above)

- Direction: vertical for cards/dialogs, horizontal for rows/nav/bars.
- Padding: pulled from the space-3/4/5 scale (12/16/24) — never a value outside Part 3.3.
- Gap: space-1 or space-2 (4/8) between tightly related elements (icon+label), space-3/4 (12/16) between distinct sub-groups.
- Sizing: buttons and inputs **fixed height, fill width**; cards **hug height, fill width** (or fixed in a grid); icons **fixed** 18/24/32/48 per `AppSizes.icon*`.
- Minimum interactive size: 44×44 (see Part 9).

---

# PART 5 — Screen-by-Screen Figma Specs

Cross-cutting responsive rule (applies to every screen below unless a screen-specific note overrides it): **small phone** (<360 logical px, `context.isSmallPhone`) collapses multi-column stat/grid rows to a single column and stacks button pairs vertically; **standard phone** (360–599) uses the 2-column grids as designed; **tablet** (≥600, `context.isTablet`) expands 2-column grids to 3 columns and caps content width (recommend 720px max content column, centered) rather than letting cards stretch full-bleed. This is a structural breakpoint change, not pure scaling, matching the `ThemeX` extension already in the codebase.

## 5.1 Authentication

**SplashScreen** — Full-bleed `bg` background (fix: theme-aware, not hardcoded dark), centered logo mark with elastic scale-in + glow (level-3), app name in Display style below. 2.4s hold, then route by cached session/role. No interactive elements — pure brand moment, so this is where the strongest motion in the app is *earned* per the "reserve intensity for real moments" principle.

**LoginScreen** — Vertical layout: logo/wordmark (space-6 top), Display H1 "Welcome back," Body subtext, email field, password field (with visibility toggle), Primary Button "Sign In" (`MorphButton`), text-button "Forgot password?", divider "or", 3 demo-credential quick-fill rows (kept — useful for reviewers/graders, styled as low-emphasis outlined chips, not primary CTAs so they don't compete with real sign-in), text link to Sign Up. **Fix applied here:** rebuild on theme-aware tokens so this renders correctly in light mode too.

**SignUpScreen** — 2-page `PageView` with a progress dots indicator. Page 1: 3-column role-select cards (Student/Coach/Admin, icon+label, selected = primary border+fill-tint). Page 2: faculty dropdown (pull from the single consolidated `kFaculties` source — see 1.6-#3), semester dropdown, phone field, password + confirm password fields, terms checkbox, Primary Button "Create Account." Back button returns to page 1 without losing role selection.

**ForgotPasswordScreen** — Single email field, Primary Button "Send Reset Link," inline success state (checkmark icon + confirmation text replaces the form in place — matches the existing in-code pattern of not navigating to a separate screen).

## 5.2 Student — Home

**HomeScreen** — App bar (`MusterAppBar`). Below it: time-of-day greeting hero (Display H1 "Good morning, {name}"), stat pill row (rank/points/enrolled — horizontal AppPills), 3 `StatBox` cards (Events/Bookings/Wins) — **grid on standard+, single column stack on small phones**, 2×2 Quick Access grid (Book a Field / Join Event / My Applications / All Activities — each is a tappable icon+label card that both sets a filter and switches tabs), tournament banner (gradient card with shimmer sweep — reserve this as one of the few "always-animated" moments since it's a promotional CTA), Recent Activity list (compact cards, 3–5 items, "View all" link).

## 5.3 Student — Activities

**ActivitiesScreen** — App bar, 3-tab `TabBar` (Sports/Arts/All), `ExpandableTabs` category filter row beneath it, consolidated Search Field, then a vertical list of Activity Cards (emoji icon, name, category, registered/spots tag, description excerpt, info chips for schedule/venue/level, View Details + Register button pair — **stacked vertically on small phones, side-by-side on standard+**).

**ActivityDetailScreen** — `SliverAppBar` hero (200px expanded, large emoji/illustration on gradient), below the fold: detail rows (schedule/venue/coach/level/members/fee, icon+label+value pattern, space-3 between rows), sticky bottom CTA bar (Primary Button "Register Now," or an "Already registered" info banner if applicable).

**RegistrationFormScreen** — Vertical form: read-only pre-filled rows (name/studentId/email, visually distinct as non-editable — muted background, no focus ring), phone field (Egyptian mobile format, inline validation), faculty + semester dropdowns, level selector (chip group), dynamic team-member row list for team sports (add/remove rows), motivation textarea, 2 checkboxes (terms, notification opt-in), `MorphButton` submit → **Success State** component (full-screen confirmation).

## 5.4 Student — Booking

**BookingScreen** — Step-through single scroll (not a wizard/stepper UI in code, so don't add one): date picker row, facility grid (**2 columns small/standard, 3 columns tablet**, availability-tinted), time-slot chip row (conflict-detected slots shown disabled/struck), Payment Method 2×2 grid (InstaPay / Vodafone Cash / Fawry / Card, icon+label selectable cards), conditional payment form beneath (Card = formatted number/expiry/CVC/cardholder fields; Mobile = phone-number field; Fawry = reference code with copy-to-clipboard + 4-step instruction list), `MorphButton` "Confirm Booking" → Success State (`_ConfirmationView`).

**MyReservationsScreen** — Upcoming/Past sectioned list, urgency badge ("Today"/"Tomorrow" in warning color) on near-term bookings, Remind Me / Cancel actions per card, Empty State component when a section is empty.

## 5.5 Student — Events

**EventsScreen** — App bar, filter chip row (All/Football/Padel/Basketball/Volleyball — reuse the Chip component from 3.1's selectable-chip spec, not a bespoke row), vertical Event Card list with status pill (Open/Soon/Full/Completed → mapped to info/warning/error/muted respectively) and a fill-ratio progress bar that shifts to error color above 85% full, Register/Registered button state on each card.

**SportsScreen** — App bar, header text, 2-column grid (3 on tablet) of category cards: icon badge (52×52, radius-sm, primary-tinted; inverts to solid-fill on press), category name (H4), "{n} active →" in primary Body-Small-bold, small underline accent bar. Tapping applies the category as an Events filter and switches to the Events tab — spec this explicitly as the two-step action described in 1.3.

## 5.6 Student — Registrations, Leaderboard, History

**MyRegistrationsScreen** — 4-tab `TabBar` (All/Pending/Approved/Rejected), stat pill row summarizing counts, `_RegCard`-style list with status-colored badge and a contextual banner per status (approved = success banner "🎉 You're in!", rejected = muted info banner, pending = warning "⏳ Under review").

**LeadershipScreen** — App bar, animated 3-person podium (gold/silver/bronze bars, elastic height-in animation — this is an "earned" motion moment per 2-#3), ranked list below with the current user's row visually pinned/highlighted ("YOU" badge, primary border). Data streams from Firestore with local fallback — design should include both a live-data state and the same visual with fallback/offline data, since they're pixel-identical by design.

**ParticipationHistoryScreen** — 3-tab (Activities/Events/Bookings), 4-stat summary grid (Total/Sports/Arts/Events — 2-col small, 4-col standard+), per-tab history card list showing points awarded per entry (+50, +30 badges in success color).

## 5.7 Student — Notifications, Chatbot

**NotificationsScreen** — App bar with unread count + "Mark all read" text action, grouped list (Today/Yesterday/Earlier section headers, Label style, uppercase), each row a Dismissible List-Item card (swipe direction flips for RTL — swipe reveals error-colored delete affordance), unread rows get a colored left-tint + dot indicator, optional inline action button (e.g. "View Booking") on notifications that carry one. Empty State when zero notifications.

**ChatbotScreen** — Chat-bubble UI, asymmetric corner radii (own messages vs bot messages visually distinct via alignment + fill color, not just position), typing indicator (3 animated dots — keep, it's a standard, low-intensity, expected pattern), suggestion-chip row above the input field, text input + send button. Role-aware: the same screen instance renders different bot copy for student vs admin/coach — no visual difference needed, content difference only.

## 5.8 Profile & Settings

**ProfileScreen** — Hero gradient card (avatar with edit-tap → Avatar Editor sheet, 10 gradient presets), pill row (faculty/rank/enrolled), 3 mini-metrics (points/CGPA/goal%), semester goal `AppProgressBar`, 3 `StatBox` cards, achievements 2-column grid (glow-card style, reserved motion), share button on each achievement → share sheet. **Fix applied here:** the share sheet's Story/Twitter/LinkedIn/Copy Link options must be visually marked as either functioning or, until wired up, presented with a subtler "coming soon" treatment consistent with how Settings already marks its disabled photo-upload — don't let a non-functional control look identical to a functional one (see 1.6-#8). Menu list (Notifications/My Reservations/Participation History/Settings) as tappable rows with chevron. Sign-out button (glow-outline style) + confirm dialog.

**SettingsScreen** — Avatar row (tap → picker sheet: 8 color swatches functional + upload clearly marked disabled per the fix above), personal info fields (name editable, studentId/email read-only/muted, phone editable, faculty/semester dropdowns, bio textarea), read-only academic info card (CGPA/credit hours/points/rank — display-only, no edit affordance implied), 4 notification-preference switches, 2 privacy switches, language switcher (flag rows), appearance dark/light `Switch`, About link row, Save `MorphButton`.

**AboutScreen** — App bar (back + divider), hero (80×80 gradient icon, radius-xl, glow), wordmark with gradient shader text, version pill, Mission `AppCard`, "Meet the Team" section — interactive rows (tap to highlight one, dim the rest; avatar grows 44→52 and shows initials badge on hover/select), tech-stack chip `Wrap`, footer copyright + faculty credit.

## 5.9 Admin

**AdminDashboardScreen** — `ExpandableTabs` section switcher (Overview / Events / Users / Actions, with a visual separator between logical groups), Overview section: 6 glow stat cards (2-col small, 3-col standard+, Total Users/Students/Active Events/Registrations/Pending Review/Activities), pending-registrations alert banner (warning-colored, dismissible or persistent while count>0), Quick Actions section: action cards (Registrations/Events/Users/AI Guide/Send Notification) that either switch tabs or push `SendNotificationScreen`.

**AdminRegistrationsScreen** — 4-tab (All/Pending/Approved/Rejected), `_AdminRegCard` list: pending cards show Details/Reject/Approve; resolved cards show View Details/Reset. Tapping "Details" opens the `_DetailSheet` (draggable bottom sheet) with full registration info and inline approve/reject actions.

**AdminBookingsScreen** — Flat booking list, Confirm/Cancel inline actions, cancel-confirm dialog.

**AdminEventsScreen** — FAB "Add Event," `_AdminEventCard` list with inline edit/delete icon buttons (delete → confirm dialog), `_EventSheet` bottom-sheet form (shared for create and edit) with title, location, sport dropdown, status dropdown, end-date picker, max-participants slider+numeric field.

**AdminUsersScreen** — Consolidated Search Field, role filter pills (All/Student/Admin/Coach), `_UserCard` list (role-colored avatar, "YOU" badge on self, points shown for students, remove action hidden on own account, remove-confirm dialog).

**SendNotificationScreen** — Title EN/AR field pair, Message EN/AR field pair (AR fields RTL-directed), target-audience role chip group (Everyone/Students/Coaches/Admins), send `MorphButton`.

## 5.10 Coach

**CoachDashboardScreen** — Greeting header, 3 stat cards (Pending/Approved/Total — tap any to jump to the Registrations tab), pending-alert banner, "My Activities" list. **Design note tied to 1.6-#10:** because the underlying match is a fragile name-substring heuristic, this section needs an explicit, clearly-designed Empty State ("No activities matched to your account yet — contact an admin") rather than silently rendering nothing.

**CoachAthletesScreen** — Consolidated Search Field, read-only roster list of approved registrations ("athletes"), verified-badge icon per row.

---

# PART 6 — UX Improvements

| Problem (current) | Recommended solution | UX benefit |
|---|---|---|
| Auth screens are dark-only, breaking theme consistency with the rest of the app | Rebuild Login/Signup/Forgot-Password/Splash on the same `context.xColor` tokens every other screen uses | First impression matches the user's chosen theme; toggling theme post-login feels continuous instead of jarring |
| No formal success/warning/info color roles — chosen ad hoc per screen | Adopt the 3.1 semantic mapping everywhere a status is communicated | A user learns once that green=good/amber=pending/red=bad and that reading transfers across every screen |
| Three independently-built search fields with different styling | One consolidated Search Field component used in Activities, Admin Users, Coach Athletes | Consistent, predictable interaction; one place to improve search UX later (e.g. add recent searches) instead of three |
| Non-functional achievement-share buttons look identical to working buttons | Either wire up real sharing, or visually demote the share sheet's non-functional options (reduced opacity + "coming soon" label) until they work | Prevents user frustration from a control that visually promises an action it can't deliver |
| Coach's "My Activities" can silently show nothing due to fragile name matching | Add an explicit, friendly Empty State explaining the situation, and (functionality note, not visual) recommend the underlying match move to a stable `coachId` | Removes a confusing silent-failure moment for coaches |
| Achievement/CTA glow-pulse motion applied at similar intensity everywhere | Reserve level-3 "glow" motion for genuine state changes (success, selection, unlock); default idle states use level-0/1 only | Motion regains meaning as a signal instead of becoming visual noise; feels more professional |
| No dedicated Error State pattern found anywhere in the app (only Empty States) | Add a formal Error State component (icon + message + retry) and use it anywhere a Firestore stream/fetch can fail (Leaderboard, Dashboard stats, Chatbot) | Failures become recoverable and legible instead of silently falling back or showing blank content |
| Fixed-height buttons/avatars risk clipping at the top of the app's own 1.15× text-scale range | Rebuild Button/Input/Avatar Auto-Layout as hug-height with a defined minimum, not fixed height, letting content grow | The app's own accessibility commitment (clamped text scaling) is honored at every scale step, not just 1.0× |
| Settings' avatar upload looks tappable but is disabled | Visually distinguish disabled options (reduced opacity, "Coming soon" badge) from the 8 working color swatches next to it | User doesn't waste a tap or wonder if the app is broken |
| Duplicate faculty lists and duplicate tab-row components (code-level, but visible as subtle screen-to-screen visual drift) | Single source for faculty list; single `ExpandableTabs` component everywhere a pill-tab filter row appears | Every faculty dropdown and every filter row looks and behaves identically across the app |

---

# PART 7 — User Flow Specifications

### Login flow
`SplashScreen` (2.4s brand hold) → session check → **has session** → route directly to role's shell (`AppShell`/`AdminShell`/`CoachShell`) at its default tab. **No session** → `LoginScreen` → user enters credentials (or taps a demo quick-fill row) → `MorphButton` shows loading state → on success, `MorphButton` shows checkmark morph → auto-navigate to role's shell. On failure, inline error text appears under the password field (error color, Body-Small) and the button returns to default state — no dialog interruption. From `LoginScreen`, two escape paths: "Forgot password?" → `ForgotPasswordScreen` (submit email → inline success state, back to Login), and "Sign up" → `SignUpScreen` (2-page flow → on success, same auto-navigate-to-shell behavior as login).

### Activity registration flow
`ActivitiesScreen` (browse, filter by Sports/Arts/All + category, search) → tap an Activity Card's "View Details" → `ActivityDetailScreen` (review schedule/venue/coach/fee) → tap "Register Now" → `RegistrationFormScreen` (pre-filled identity fields, phone/faculty/semester/level, dynamic team-member rows if applicable, motivation text, 2 checkboxes) → submit via `MorphButton` (loading → success morph) → full-screen Success State → back to `ActivitiesScreen` or into `MyRegistrationsScreen` to see the new **Pending** entry. Parallel path: `MyRegistrationsScreen` lets the student check status at any time (Pending/Approved/Rejected), each with its own contextual banner copy.

### Booking → payment flow
`BookingScreen` (tab) → pick date → facility grid updates availability → pick facility → time-slot chips appear, conflicting slots shown disabled → pick time → Payment Method grid (InstaPay/Vodafone Cash/Fawry/Card) → selecting a method reveals its specific form beneath (card fields with live formatting, mobile-wallet number field, or Fawry reference-code + instructions) → `MorphButton` "Confirm Booking" (loading → success morph) → `_ConfirmationView` full-screen success (booking details recap) → back to `MyReservationsScreen`, new entry appears under Upcoming with urgency badge logic ("Today"/"Tomorrow") once the date approaches.

### Admin registration-approval flow
`AdminDashboardScreen` pending-alert banner or Quick Action → `AdminRegistrationsScreen` (defaults to Pending tab) → tap a card's "Details" → `_DetailSheet` draggable sheet opens with full applicant info → Approve or Reject → sheet dismisses, card moves tabs (Pending→Approved/Rejected), and — on the student's side — `NotificationState` pushes a registration-update notification (✅/❌) and `MyRegistrationsScreen`'s status/banner updates to match. This is the one flow that visibly connects the Admin and Student experiences — worth prototyping end-to-end in Figma to demonstrate the loop.

---

# PART 8 — Figma File & Page Organization

```
📄 Cover                      — project title, version, last-updated, contents index
📄 Design System              — color, typography, spacing, radius, elevation tables (Part 3, as live styles/variables)
📄 Components                 — full library from Part 4, organized by section, all variants/states
📄 Authentication              — Splash, Login, Signup, Forgot Password
📄 Home                        — Home screen + Quick Access, Tournament Banner
📄 Activities & Booking        — Activities, Activity Detail, Registration Form, Booking, My Reservations
📄 Events & Leadership         — Events, Sports, Leadership
📄 Registrations & History     — My Registrations, Participation History, Notifications
📄 Profile & Settings          — Profile, Settings, About, Chatbot
📄 Admin                       — Dashboard, Registrations, Bookings, Events, Users, Send Notification
📄 Coach                       — Coach Dashboard, Coach Athletes
📄 States (Empty / Error / Loading / Success)  — the consolidated components from Part 4, shown in context per screen family
📄 User Flows                  — the 4 flows from Part 7, as connected prototype frames with arrows
```

Each screen page should contain, left to right: the **light** theme frame, the **dark** theme frame, and (where noted in Part 5) the **Arabic/RTL** mirrored frame — three variants per screen keep theme and locale parity visible at a glance rather than buried in component overrides.

---

# PART 9 — Accessibility

- **Contrast**: verify all pairs in Part 3.1 with Figma's contrast plugin before sign-off; the two flagged risk pairs (bright accent/secondary fills needing dark text, light-mode primary-fill buttons needing bold ≥15px labels) need explicit checking, not assumption.
- **Touch targets**: minimum 44×44pt for every tappable element, 48×48pt preferred for primary actions — apply even where the current code ships a visually smaller icon (e.g., a 20px icon button still gets a 44pt hit area via padding).
- **Text readability**: respect the app's own 0.9–1.15 text-scale clamp; per the fix in Part 6, size interactive containers to hug content with a defined minimum rather than a hard fixed height, so nothing clips at 1.15×.
- **Form & error accessibility**: every invalid field gets both a color change (error token) *and* inline text — never color alone — matching the phone-number and password-length validation patterns already in the code.
- **Focus & disabled states**: every interactive component in Part 4 needs an explicit Focused variant (visible outline/ring, not just color shift, for keyboard/switch-access users) and Disabled variant (reduced opacity + no color-only reliance).
- **RTL**: mirror every layout for Arabic — directional padding/alignment (`Start`/`End`, never hardcoded `left`/`right`), swipe-to-delete direction flips, icon mirroring where directional (chevrons, back arrows), and the 0.9× Arabic type scale from Part 3.2.
- **Screen-reader labels**: icon-only buttons (notification bell, sign-out icon, chevrons, swipe actions) need explicit accessible labels in the component spec, not just a visual icon — flag this as a Flutter implementation note (`Semantics`/`tooltip`) alongside the Figma annotation.

---

# PART 10 — Flutter ↔ Figma Component Mapping

| Flutter widget | Figma component | Variants to build |
|---|---|---|
| `MorphButton` | Primary Button | Default / Pressed / Loading / Success / Disabled |
| `GlowingButton` / `GlowingFAB` | Glow CTA / Glow FAB | Default / Pressed |
| `_GlowTextField` + ad hoc `TextField`s | Text Field | Standard / Multiline / Read-only × Default/Focused/Error/Disabled |
| `DropdownButtonFormField` instances | Dropdown | Default/Open/Selected/Disabled |
| `AppCard` | Base Card | Default/Glow/Gradient |
| `StatBox` | Stat Box | Grid item / Single-column |
| `_ActivityCard` | Activity Card | Sports/Arts × Default/Full/Registered |
| `_EventCard` | Event Card | Open/Soon/Full/Completed |
| `_UserCard`, athlete rows | User Card | Student/Admin/Coach × Default/YOU-badge |
| `_NotifCard` | List Item (Notification) | Read/Unread × Default/Swipe-revealed |
| `_RegCard`, `_AdminRegCard` | Registration Card | Pending/Approved/Rejected |
| `MusterAppBar` | App Bar | Standard/Simple |
| `AnimatedNavBar`/`AnimatedNavItem` | Bottom Nav | 7-tab/6-tab/4-tab × item Default/Selected/Badged |
| `ExpandableTabs` (+ duplicate `ExpandableTabRow` to retire) | Filter Tab Row | Default/Selected/Collapsed |
| in-screen `TabBar` | Tab Bar | 3-tab/4-tab |
| `MusterSignOutDialog`, admin confirm dialogs | Dialog | Confirm/Info |
| `_DetailSheet`, `_EventSheet`, `_AvatarEditorSheet` | Bottom Sheet | Draggable-detail/Form/Picker |
| `ToastOverlay` | Toast | Success/Error/Info |
| `ShimmerBox`/`SkeletonCard`/`SkeletonList` | Loading Skeleton | Card-shape/List-row-shape |
| ad hoc empty-state widgets | Empty State | Icon+text / +CTA |
| *(new — no current Flutter equivalent)* | Error State | Icon+text+retry |
| `_SuccessScreen`, `_ConfirmationView` | Success State | Full-screen confirmation |
| `AppPill` | Pill / Badge | Status colors |
| level/category chips | Selectable Chip | Default/Selected/Disabled |
| `AppAvatar` | Avatar | Initials/Photo × sizes |

---

# PART 11 — Deliverables checklist

| # | Deliverable | Where covered |
|---|---|---|
| 1 | Screen inventory | Part 1.2 |
| 2 | User-flow map | Part 1.3, Part 7 |
| 3 | Design direction | Part 2 |
| 4 | Color system | Part 3.1 |
| 5 | Typography system | Part 3.2 |
| 6 | Spacing system | Part 3.3 |
| 7 | Radius system | Part 3.4 |
| 8 | Shadow/elevation system | Part 3.5 |
| 9 | Component library + variants/states | Part 4 |
| 10 | Screen-by-screen specs | Part 5 |
| 11 | Responsive behavior | Cross-cutting rule at top of Part 5 + per-screen notes |
| 12 | Accessibility recommendations | Part 9 |
| 13 | UX improvement list | Part 6 |
| 14 | Flutter↔Figma mapping | Part 10 |
| 15 | Recommended Figma file/page structure | Part 8 |
| 16 | Findings specific to *this* codebase (not generic) | Part 1.6 inconsistencies, dead-code flags throughout |

---

*End of specification.*
