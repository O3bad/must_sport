/**
 * Authorisation tests for `firestore.rules`.
 *
 * These are the only tests that exercise the real enforcement boundary. The
 * client-side sanitiser in FirestoreService.sanitizeUserPayload is advisory —
 * a patched app skips it — so if these assertions pass the attack is blocked
 * even against a hostile client.
 *
 * Run:
 *   firebase emulators:exec --only firestore "npm test"
 *
 * (requires Java on PATH).
 */
const {
  initializeTestEnvironment,
  assertSucceeds,
  assertFails,
} = require("@firebase/rules-unit-testing");
const {
  doc,
  getDoc,
  setDoc,
  updateDoc,
  deleteDoc,
  collection,
  addDoc,
  serverTimestamp,
} = require("firebase/firestore");
const { readFileSync } = require("fs");
const path = require("path");

const RULES = readFileSync(
  path.join(__dirname, "..", "..", "firestore.rules"),
  "utf8",
);
const PROJECT = "muster-clone";

let testEnv;

/** Seed a user document bypassing rules (admin SDK under the hood). */
async function seedUser(uid, role, extra = {}) {
  await testEnv.withSecurityRulesDisabled(async (ctx) => {
    await setDoc(doc(ctx.firestore(), "users", uid), {
      uid,
      role,
      name: `User ${uid}`,
      faculty: "Engineering",
      points: 0,
      rank: 0,
      ...extra,
    });
  });
}

/**
 * Mirrors `FirestoreService.sanitizeUserPayload` in
 * lib/core/services/firestore_service.dart.
 *
 * The rules *pin* the server-owned fields rather than forbidding them, so a
 * fixture that omits them is rejected — which is what caught the original
 * design mistake of stripping them and leaving documents without a `role`.
 */
const userPayload = (over = {}) => ({
  name: "New Student",
  email: "s@university.edu",
  faculty: "Engineering",
  semester: "Spring 2026",
  phone: "",
  bio: "",
  cgpa: 0,
  creditHours: "0/140",
  targetEvents: 5,
  stats: { eventsJoined: 0, bookingsMade: 0, wins: 0 },
  achievements: [],
  role: "student",
  points: 0,
  rank: 0,
  isActive: true,
  ...over,
});

(async () => {
  testEnv = await initializeTestEnvironment({
    projectId: PROJECT,
    firestore: { rules: RULES },
  });

  const alice = testEnv.authenticatedContext("alice").firestore();
  const bob = testEnv.authenticatedContext("bob").firestore();
  const admin = testEnv.authenticatedContext("root").firestore();
  const anon = testEnv.unauthenticatedContext().firestore();

  let passed = 0;
  let failed = 0;
  const check = async (name, fn) => {
    try {
      await fn();
      passed++;
      console.log(`  PASS  ${name}`);
    } catch (e) {
      failed++;
      console.log(`  FAIL  ${name}\n        ${e.message}`);
    }
  };

  console.log("\nusers — self-service registration");

  await check("student may create own profile with pinned fields", () =>
    assertSucceeds(setDoc(doc(alice, "users", "alice"), userPayload())),
  );

  await check("registration without a role field is rejected", () =>
    assertFails(setDoc(doc(alice, "users", "norole"), userPayload())),
  );

  await check("may NOT create a profile for another uid", () =>
    assertFails(setDoc(doc(alice, "users", "victim"), userPayload())),
  );

  await check("may NOT set role=admin on create (escalation)", () =>
    assertFails(
      setDoc(doc(alice, "users", "mallory"), userPayload({ role: "admin" })),
    ),
  );

  await check("may NOT set points on create (standing inflation)", () =>
    assertFails(
      setDoc(doc(alice, "users", "mallory2"), userPayload({ points: 100000 })),
    ),
  );

  await check("may NOT set rank on create", () =>
    assertFails(
      setDoc(doc(alice, "users", "mallory3"), userPayload({ rank: 1 })),
    ),
  );

  await check("may NOT set isActive=false on create (self-deactivation bypass)", () =>
    assertFails(
      setDoc(doc(alice, "users", "mallory5"), userPayload({ isActive: false })),
    ),
  );

  await check("may NOT set a non-zero rank on create", () =>
    assertFails(
      setDoc(doc(alice, "users", "mallory6"), userPayload({ rank: 1 })),
    ),
  );

  await check("may NOT self-deactivate by flipping isActive", () =>
    assertFails(
      updateDoc(doc(alice, "users", "alice"), { isActive: false }),
    ),
  );

  await check("unauthenticated may NOT register", () =>
    assertFails(setDoc(doc(anon, "users", "anon"), userPayload())),
  );

  console.log("\nusers — updates");

  await check("may update own name", () =>
    assertSucceeds(updateDoc(doc(alice, "users", "alice"), { name: "Renamed" })),
  );

  await check("may NOT promote self to admin", () =>
    assertFails(
      updateDoc(doc(alice, "users", "alice"), { role: "admin" }),
    ),
  );

  await check("may NOT promote self to coach", () =>
    assertFails(
      updateDoc(doc(alice, "users", "alice"), { role: "coach" }),
    ),
  );

  await check("may NOT inflate own points", () =>
    assertFails(
      updateDoc(doc(alice, "users", "alice"), { points: 999999 }),
    ),
  );

  await check("may NOT edit another user's profile", () =>
    assertFails(updateDoc(doc(alice, "users", "bob"), { name: "Hacked" })),
  );

  console.log("\nusers — reads");

  await check("may read own profile", () =>
    assertSucceeds(getDoc(doc(alice, "users", "alice"))),
  );

  await check("may NOT read another student's profile (PII)", () =>
    assertFails(getDoc(doc(alice, "users", "bob"))),
  );

  console.log("\nusers — staff powers");

  // `bob` must exist: the previous run failed here with NOT_FOUND because the
  // test promoted a document that had never been created.
  await seedUser("bob", "student");
  await seedUser("root", "admin");
  await seedUser("boss", "coach");

  await check("admin may read any user", () =>
    assertSucceeds(getDoc(doc(admin, "users", "bob"))),
  );

  await check("admin may promote a user to coach", () =>
    assertSucceeds(updateDoc(doc(admin, "users", "bob"), { role: "coach" })),
  );

  await check("admin may set points", () =>
    assertSucceeds(updateDoc(doc(admin, "users", "bob"), { points: 50 })),
  );

  const coachCtx = testEnv.authenticatedContext("boss").firestore();
  await check("coach may NOT read other users (least privilege)", () =>
    assertFails(getDoc(doc(coachCtx, "users", "alice"))),
  );

  await check("coach may read their own profile", () =>
    assertSucceeds(getDoc(doc(coachCtx, "users", "boss"))),
  );

  await check("coach may NOT grant admin", () =>
    assertFails(updateDoc(doc(coachCtx, "users", "bob"), { role: "admin" })),
  );

  console.log("\nbookings — ownership");

  // Uses `carol`, never `bob`: bob was promoted to coach above, and staff
  // legitimately bypass the owner-only branch, which masked this test.
  await seedUser("carol", "student");
  const carol = testEnv.authenticatedContext("carol").firestore();

  await testEnv.withSecurityRulesDisabled(async (ctx) => {
    await setDoc(doc(ctx.firestore(), "bookings", "b1"), {
      uid: "carol",
      eventId: "e1",
      status: "confirmed",
    });
  });

  await check("owner may read own booking", () =>
    assertSucceeds(getDoc(doc(carol, "bookings", "b1"))),
  );

  await check("other student may NOT read the booking", () =>
    assertFails(getDoc(doc(alice, "bookings", "b1"))),
  );

  await check("booking must be stamped with the caller's uid", () =>
    assertFails(
      addDoc(collection(alice, "bookings"), {
        uid: "carol",
        eventId: "e1",
        status: "pending",
      }),
    ),
  );

  await check("owner may cancel own booking (status only)", () =>
    assertSucceeds(
      updateDoc(doc(carol, "bookings", "b1"), { status: "cancelled" }),
    ),
  );

  await check("owner may NOT reassign booking ownership", () =>
    assertFails(updateDoc(doc(carol, "bookings", "b1"), { uid: "mallory" })),
  );

  await check("owner may NOT change an unrelated field", () =>
    assertFails(updateDoc(doc(carol, "bookings", "b1"), { eventId: "e9" })),
  );

  await check("non-owner may NOT update the booking", () =>
    assertFails(updateDoc(doc(alice, "bookings", "b1"), { status: "cancelled" })),
  );

  await check("owner may delete own booking", () =>
    assertSucceeds(deleteDoc(doc(carol, "bookings", "b1"))),
  );

  // Fresh document: the previous check deletes b1, so staff moderation has to
  // run against a booking that still exists.
  await testEnv.withSecurityRulesDisabled(async (ctx) => {
    await setDoc(doc(ctx.firestore(), "bookings", "b2"), {
      uid: "carol",
      eventId: "e1",
      status: "confirmed",
    });
  });

  await check("staff may update any booking (moderation)", () =>
    assertSucceeds(updateDoc(doc(admin, "bookings", "b2"), { status: "completed" })),
  );

  await check("staff may read any booking", () =>
    assertSucceeds(getDoc(doc(admin, "bookings", "b2"))),
  );

  await check("staff may NOT promote a user to admin via a booking write", () =>
    assertFails(updateDoc(doc(coachCtx, "bookings", "b2"), { uid: "root" })),
  );

  console.log("\nmissing user documents");

  // An Auth account with no Firestore profile. `storedRole()` on a missing
  // document used to throw, producing an evaluation error that poisoned every
  // isStaff()/isAdmin() check. These must be clean denials.
  const ghost = testEnv.authenticatedContext("ghost").firestore();

  await check("profile-less user is cleanly denied staff writes", () =>
    assertFails(setDoc(doc(ghost, "events", "e9"), { title: "Fake" })),
  );

  await check("profile-less user is cleanly denied other profiles", () =>
    assertFails(getDoc(doc(ghost, "users", "carol"))),
  );

  await check("profile-less user may NOT write the leaderboard", () =>
    assertFails(setDoc(doc(ghost, "leaderboard", "ghost"), { points: 1 })),
  );

  await check("profile-less user may still read events (signed in)", () =>
    assertSucceeds(getDoc(doc(ghost, "events", "e1"))),
  );

  await check("profile-less user may book for themselves", () =>
    assertSucceeds(
      addDoc(collection(ghost, "bookings"), { uid: "ghost", eventId: "e1" }),
    ),
  );

  console.log("\nleaderboard — projection integrity");

  await check("signed-in user may read leaderboard", () =>
    assertSucceeds(getDoc(doc(alice, "leaderboard", "bob"))),
  );

  await check("user may NOT write the leaderboard projection", () =>
    assertFails(
      setDoc(doc(alice, "leaderboard", "mallory"), { name: "Me", points: 999 }),
    ),
  );

  await check("user may NOT write their own leaderboard entry", () =>
    assertFails(
      setDoc(doc(alice, "leaderboard", "alice"), { points: 999999 }),
    ),
  );

  console.log("\nevents & enrolments");

  await testEnv.withSecurityRulesDisabled(async (ctx) => {
    await setDoc(doc(ctx.firestore(), "events", "e1"), { title: "Cup" });
  });

  await check("signed-in user may read events", () =>
    assertSucceeds(getDoc(doc(alice, "events", "e1"))),
  );

  await check("student may NOT create an event", () =>
    assertFails(setDoc(doc(alice, "events", "e9"), { title: "Fake" })),
  );

  await check("coach may create an event", () =>
    assertSucceeds(setDoc(doc(coachCtx, "events", "e2"), { title: "Real" })),
  );

  await check("user may enrol only themselves", () =>
    assertSucceeds(
      setDoc(doc(alice, "events", "e1", "enrollments", "alice"), { uid: "alice" }),
    ),
  );

  await check("user may NOT enrol somebody else", () =>
    assertFails(
      setDoc(doc(alice, "events", "e1", "enrollments", "bob"), { uid: "bob" }),
    ),
  );

  console.log("\ndefault deny");

  await check("unauthenticated may NOT read events", () =>
    assertFails(getDoc(doc(anon, "events", "e1"))),
  );

  await check("unauthenticated may NOT read the leaderboard", () =>
    assertFails(getDoc(doc(anon, "leaderboard", "bob"))),
  );

  await check("unmatched collection is denied by default", () =>
    assertFails(getDoc(doc(alice, "unknown_collection", "x"))),
  );

  await check("student may NOT write notifications", () =>
    assertFails(
      setDoc(doc(alice, "notifications", "n1"), { title: "Fake" }),
    ),
  );

  console.log(
    `\n${failed === 0 ? "ALL PASSED" : "FAILURES"}: ${passed} passed, ${failed} failed\n`,
  );

  await testEnv.cleanup();
  process.exit(failed === 0 ? 0 : 1);
})().catch((e) => {
  console.error("\nFATAL — rules failed to compile or the harness errored:\n");
  console.error(e);
  process.exit(1);
});
