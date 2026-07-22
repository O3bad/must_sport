# MUSTER Sport 🏅

**University Sports Management App** — A Flutter mobile application for managing sports activities, facility bookings, events, and student participation at a university.

---

## Overview

MUSTER Sport is a full-featured sports management platform built for university students, coaches, and administrators. It centralizes sports activity registration, facility booking, event management, and student performance tracking into a single mobile app with full English/Arabic bilingual support.

---

## Features

### For Students
- **Home Dashboard** — Personalized greeting, activity stats, quick-access shortcuts
- **Activities** — Browse and register for 24+ sports and performing arts activities
- **Events & Tournaments** — View upcoming tournaments, register, and track open/full/completed status
- **Facility Booking** — Book sports fields and venues by date and time slot
- **My Registrations** — Track registration status (pending, approved, rejected)
- **My Reservations** — View and manage upcoming and past bookings
- **Participation History** — Review past activity and event participation
- **Leaderboard** — Semester rankings and top performers
- **Notifications** — In-app and push notification alerts for reminders, approvals, and events
- **AI Chatbot** — Built-in AI guide for app navigation and sports queries
- **Profile** — View stats, achievements/badges, CGPA, credit hours, and semester goals

### For Coaches
- **Coach Dashboard** — Overview of assigned teams and activities
- **Athlete Management** — View and manage registered athletes

### For Admins
- **Admin Dashboard** — Platform-wide stats and overview
- **User Management** — View and manage all student, coach, and admin accounts
- **Event Management** — Create, edit, and manage sports events
- **Booking Management** — View and oversee all facility bookings
- **Registration Management** — Approve or reject activity registrations
- **Send Notifications** — Push targeted notifications to users

---

## Tech Stack

| Layer | Technology |
|---|---|
| Framework | Flutter (Dart SDK ≥ 3.2.0) |
| State Management | Provider `^6.1.2` + flutter_bloc `^9.1.1` |
| Backend / Auth | Firebase Auth `^6.2.0`, Cloud Firestore `^6.1.3` |
| Push Notifications | Firebase Messaging `^16.1.3`, flutter_local_notifications `^21.0.0` |
| Storage | Firebase Storage `^13.2.0` |
| HTTP | Dio `^5.7.0` + pretty_dio_logger |
| Local Storage | shared_preferences `^2.2.3` |
| Charts | fl_chart `^1.2.0` |
| Images | image_picker `^1.1.2`, cached_network_image `^3.4.1` |
| Fonts | Google Fonts `^8.0.2` |
| Localization | Flutter Intl — ARB files (English + Arabic) |
| Auth Extras | Google Sign-In `^6.2.1` |
| Utilities | uuid `^4.4.2`, timeago `^3.7.0`, equatable `^2.0.5` |

---

## Project Structure

```
lib/
├── main.dart                        # App entry point, Firebase init, providers
├── app.dart                         # MaterialApp setup, theme, localization
├── app_shell.dart                   # Main navigation shell
├── firebase_options.dart            # Firebase config
│
├── core/
│   ├── api/                         # Dio client, API models, MustAPI service
│   ├── constants/                   # App-wide constants
│   ├── di/                          # Service locator (dependency injection)
│   ├── errors/                      # AppException, Result type
│   ├── models/                      # Data models (UserModel, Booking, SportEvent, etc.)
│   ├── repositories/                # Activity, auth, notification, user repositories
│   ├── router/                      # App navigation / routing
│   ├── services/                    # Firebase auth, Firestore, FCM, cache, photo upload
│   ├── state/                       # App-wide state (AppState, ActivityState, NotificationState)
│   ├── theme/                       # AppTheme, widgets, animations, animated nav bar, shimmer
│   └── widgets/                     # Shared widgets (expandable tab row, glowing button, particles)
│
├── features/
│   ├── auth/                        # Login, signup, forgot password, splash — BLoC
│   ├── home/                        # Home dashboard
│   ├── activities/                  # Activity listing, detail, registration form
│   ├── events/                      # Events & tournaments
│   ├── booking/                     # Facility booking and reservations
│   ├── chatbot/                     # AI assistant screen
│   ├── notifications/               # Notifications — BLoC
│   ├── profile/                     # User profile
│   ├── settings/                    # App settings (theme, language, privacy, about)
│   ├── leadership/                  # Leaderboard
│   ├── sports/                      # Sports category browser
│   ├── participation_history/       # Past participation log
│   ├── my_registrations/            # User's activity applications
│   ├── student/                     # Student home, activity cards — BLoC
│   ├── coach/                       # Coach dashboard and athlete management — BLoC
│   └── admin/                       # Admin dashboard, users, events, bookings, registrations — BLoC
│
└── l10n/                            # Localisation — English and Arabic (ARB + generated files)
```

---

## User Roles

| Role | Access |
|---|---|
| 🎓 Student | Browse activities & events, book facilities, track stats and participation |
| 🏅 Coach | Manage assigned teams, view athlete registrations |
| 🛡️ Admin | Full access — manage users, events, bookings, and registrations |

---

## Localization

The app supports **English** and **Arabic** with full RTL layout support. Language switching is available in Settings. Translations are managed via `.arb` files under `lib/l10n/`.

---

## Getting Started

### Prerequisites

- Flutter SDK ≥ 3.2.0
- Dart SDK ≥ 3.2.0
- A Firebase project with **Authentication**, **Cloud Firestore**, **Firebase Storage**, and **Cloud Messaging** enabled

### Setup

1. **Clone the repository**
   ```bash
   git clone <repo-url>
   cd muster_sport
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Configure Firebase**
   - Create a Firebase project at [console.firebase.google.com](https://console.firebase.google.com)
   - Enable Email/Password and Google Sign-In authentication
   - Enable Cloud Firestore, Firebase Storage, and Cloud Messaging
   - Run `flutterfire configure` to generate `lib/firebase_options.dart`
   - Place `google-services.json` in `android/app/` and `GoogleService-Info.plist` in `ios/Runner/`

4. **Generate localization files**
   ```bash
   flutter gen-l10n
   ```

5. **Run the app**
   ```bash
   flutter run
   ```

> **Note:** The app includes mock/demo data and falls back gracefully if Firebase is not fully configured, making it possible to explore the UI without a live backend. Demo credentials for all three roles (Student, Admin, Coach) are available on the login screen.

---

## Key Architecture Decisions

- **Provider + BLoC hybrid** — Provider for app-wide state (auth, user, activities); BLoC for isolated feature state (admin, coach, notifications)
- **Feature-first folder structure** — each feature is self-contained with its own screens, BLoC, and presentation layer
- **Repository pattern** — `ActivityRepository`, `AuthRepository`, `NotificationRepository`, `UserRepository` abstract all data access
- **Offline-first cache layer** — `CacheService` persists session, bookings, and enrolled IDs locally via `shared_preferences`
- **Result type** — custom `Result<T>` wraps success/failure for safe error handling across the data layer
- **Portrait-locked** orientation for consistent mobile UX
- **Dark mode** support with user preference persistence
