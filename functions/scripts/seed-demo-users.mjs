#!/usr/bin/env node
/**
 * Provisions the three demo accounts referenced by the login screen.
 *
 * WHY THIS EXISTS
 * ---------------
 * `login_screen.dart` advertises student@/admin@/coach@must.edu.eg, but nothing
 * in this repo ever creates them. The local mock authenticator that used to
 * serve them (`CacheService._kDemoUsers` + `AppState.login`) was deleted because
 * it meant a password rejected by Firebase could still produce a *successful*
 * login as the bundled admin — see the comment in `app_constants.dart`. Firebase
 * Auth is now the only authority, so the accounts must exist in Firebase.
 *
 * Firestore matters as much as Auth here. `AppState.loginWithFirebaseUser`
 * treats Firestore as the only role authority: if `users/{uid}` is missing it
 * synthesises a **student** profile. A console-created admin with no profile
 * document therefore signs in successfully and lands in `AppShell` instead of
 * `AdminShell`. This script writes both halves.
 *
 * Credentials are read from the environment and never printed, never committed,
 * and never baked into the app. The Admin SDK bypasses Firestore rules, which is
 * the only way to create a `role != 'student'` profile.
 *
 * USAGE
 * -----
 *   # 1. Download a service account key from the Firebase console and keep it
 *   #    OUTSIDE the repo, e.g. C:\secrets\muster-admin.json
 *   # 2. Set the three passwords (12+ chars):
 *   $env:DEMO_ADMIN_PASSWORD   = '...'
 *   $env:DEMO_COACH_PASSWORD   = '...'
 *   $env:DEMO_STUDENT_PASSWORD = '...'
 *   $env:GOOGLE_APPLICATION_CREDENTIALS = 'C:\secrets\muster-admin.json'
 *   # 3. Run it (from the repo root):
 *   node functions\scripts\seed-demo-users.mjs
 *   # 4. Pass the same values to the app so the hint can prefill them:
 *   flutter run --dart-define=demoAdminPassword=... --dart-define=demoCoachPassword=... `
 *              --dart-define=demoStudentPassword=...
 */

import { cert, getApps, initializeApp } from "firebase-admin/app";
import { getAuth } from "firebase-admin/auth";
import { getFirestore, FieldValue } from "firebase-admin/firestore";

const PROJECT_ID = process.env.FIREBASE_PROJECT_ID || "muster-clone";

/**
 * Field names must match `UserModel.toJson()` in lib/core/models/models.dart —
 * anything else is silently defaulted by `UserModel.fromJson`.
 */
const DEMO_USERS = [
  {
    role: "admin",
    email: "admin@must.edu.eg",
    passwordEnv: "DEMO_ADMIN_PASSWORD",
    profile: {
      name: "Mona Adel",
      studentId: "ADMIN-001",
      faculty: "Faculty of Information Technology",
      phone: "",
      bio: "MUST Sport administrator account.",
      points: 0,
      rank: 0,
      cgpa: 0.0,
      creditHours: "0/140",
      targetEvents: 0,
    },
  },
  {
    role: "coach",
    email: "coach@must.edu.eg",
    passwordEnv: "DEMO_COACH_PASSWORD",
    profile: {
      name: "Karim Nabil",
      studentId: "COACH-001",
      faculty: "Faculty of Information Technology",
      phone: "",
      bio: "MUST Sport coach account.",
      points: 0,
      rank: 0,
      cgpa: 0.0,
      creditHours: "0/140",
      targetEvents: 0,
    },
  },
  {
    role: "student",
    email: "student@must.edu.eg",
    passwordEnv: "DEMO_STUDENT_PASSWORD",
    profile: {
      name: "Sara Ibrahim",
      studentId: "STU-001",
      faculty: "Faculty of Information Technology",
      phone: "",
      bio: "MUST Sport student account.",
      points: 0,
      rank: 0,
      cgpa: 0.0,
      creditHours: "0/140",
      targetEvents: 5,
    },
  },
];

function die(msg) {
  console.error(`\nERROR: ${msg}\n`);
  process.exit(1);
}

// ── Preconditions ────────────────────────────────────────────────────────────
const missing = DEMO_USERS.filter((u) => !process.env[u.passwordEnv]);
if (missing.length) {
  die(
    "Missing password(s) in the environment: " +
      missing.map((u) => `${u.passwordEnv} (${u.email})`).join(", ") +
      "\nSet them all, or the run would create accounts you cannot sign in with."
  );
}

const credPath = process.env.GOOGLE_APPLICATION_CREDENTIALS;
if (!credPath) {
  die(
    "GOOGLE_APPLICATION_CREDENTIALS is not set.\n" +
      "Point it at a service account key with the 'Firebase Authentication Admin' " +
      "and 'Cloud Datastore User' roles.\n" +
      "Keep the key outside the repository."
  );
}

if (getApps().length === 0) {
  initializeApp({ credential: cert(credPath), projectId: PROJECT_ID });
}

const auth = getAuth();
const db = getFirestore();

// ── Seed ─────────────────────────────────────────────────────────────────────
const results = [];

for (const spec of DEMO_USERS) {
  const password = process.env[spec.passwordEnv];

  let uid;
  let action;

  try {
    const existing = await auth.getUserByEmail(spec.email);
    uid = existing.uid;
    await auth.updateUser(uid, {
      password,
      emailVerified: true,
      disabled: false,
    });
    action = "password reset";
  } catch (err) {
    if (err?.code !== "auth/user-not-found") throw err;
    const created = await auth.createUser({
      email: spec.email,
      password,
      emailVerified: true,
      disabled: false,
    });
    uid = created.uid;
    action = "created";
  }

  // Role authority. The Admin SDK bypasses `firestore.rules`, which is required:
  // the rules pin self-service creates to role == 'student'.
  await db.doc(`users/${uid}`).set(
    {
      uid,
      role: spec.role,
      email: spec.email,
      isActive: true,
      stats: { eventsJoined: 0, bookingsMade: 0, wins: 0 },
      achievements: [],
      updatedAt: FieldValue.serverTimestamp(),
    },
    { merge: true }
  );
  await db.doc(`users/${uid}`).set(spec.profile, { merge: true });

  results.push({ role: spec.role, email: spec.email, uid, action });
}

console.log("\nDemo accounts provisioned:\n");
for (const r of results) {
  console.log(
    `  ${r.role.padEnd(8)} ${r.email.padEnd(22)} ${r.action.padEnd(15)} uid=${r.uid}`
  );
}
console.log(
  "\n`leaderboard/{uid}` is populated automatically by the syncLeaderboard" +
    "\ntrigger on write to `users/{uid}` (functions/src/index.ts)."
);
console.log(
  "\nNow pass the same passwords to the app so the hint can prefill them:\n" +
    "  flutter run --dart-define=demoAdminPassword=... --dart-define=demoCoachPassword=... " +
    "--dart-define=demoStudentPassword=...\n"
);
