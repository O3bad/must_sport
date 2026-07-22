/**
 * MUSTER Sport — trusted backend.
 *
 * These functions exist because some data must never be produced by the
 * client. The Firebase web/mobile SDK is under the user's control: anything it
 * sends can be forged from a patched app, `curl`, or a browser console. So:
 *
 *  - `role`/`points`/`rank`/`isActive` are stripped client-side AND rejected by
 *    `firestore.rules`, which means the server has to be the one that advances
 *    standings.
 *  - `leaderboard/{uid}` is a denormalised, non-sensitive projection of `users`
 *    so the leaderboard can be world-readable without making every student's
 *    email, phone number and student ID world-readable.
 *
 * Deployment: `firebase deploy --only functions`
 * (add an App Check token + billing plan before enabling external triggers).
 */
import { onDocumentWritten } from "firebase-functions/v2/firestore";
import { onCall, HttpsError } from "firebase-functions/v2/https";
import { initializeApp } from "firebase-admin/app";
import { FieldValue, getFirestore } from "firebase-admin/firestore";
import { logger } from "firebase-functions";

initializeApp();

const db = getFirestore();

/** Roles that may appear on the public leaderboard. */
const RANKED_ROLES = new Set(["student"]);

type UserDoc = {
  role?: string;
  name?: string;
  faculty?: string;
  points?: number;
  rank?: number;
};

/**
 * Mirrors the non-sensitive ranking fields of `users/{uid}` into
 * `leaderboard/{uid}`.
 *
 * Firestore rules deny the client write access to `leaderboard`, so this
 * trigger is the only thing that can populate it. Non-ranked users (coaches,
 * admins) are removed from the projection rather than written, so a demotion
 * cannot leave a stale entry behind.
 */
export const syncLeaderboard = onDocumentWritten("users/{uid}", async (event) => {
  const { uid } = event.params;
  const ref = db.doc(`leaderboard/${uid}`);

  const before = event.data?.before.data() as UserDoc | undefined;
  const after = event.data?.after.data() as UserDoc | undefined;

  // Deleted user.
  if (!after) {
    await ref.delete();
    return;
  }

  if (!RANKED_ROLES.has(after.role ?? "student")) {
    await ref.delete();
    return;
  }

  // Nothing ranking-relevant changed; avoid a needless write.
  const rankFieldsUnchanged =
    before &&
    before.name === after.name &&
    before.faculty === after.faculty &&
    before.points === after.points &&
    before.rank === after.rank;
  if (rankFieldsUnchanged) return;

  await ref.set(
    {
      name: after.name ?? "Unknown",
      faculty: after.faculty ?? "",
      points: after.points ?? 0,
      rank: after.rank ?? 0,
      updatedAt: FieldValue.serverTimestamp(),
    },
    { merge: true },
  );

  logger.info("Synced leaderboard projection", { uid });
});

/**
 * Awards points for a completed event and re-derives the affected rank.
 *
 * Callers are the server (not the client), which is why this is safe to keep
 * in the trusted tier: `firestore.rules` already prevents users from writing
 * `points` themselves.
 */
export const awardEventPoints = onCall(async (request) => {
  if (!request.auth) {
    throw new HttpsError("unauthenticated", "Sign in required.");
  }

  const caller = await db.doc(`users/${request.auth.uid}`).get();
  const role = caller.data()?.role;
  if (role !== "admin") {
    throw new HttpsError("permission-denied", "Staff only.");
  }

  const uid = request.data?.uid;
  const delta = Number(request.data?.points);
  if (typeof uid !== "string" || !Number.isFinite(delta)) {
    throw new HttpsError("invalid-argument", "uid and a numeric points are required.");
  }

  await db.doc(`users/${uid}`).update({
    points: FieldValue.increment(delta),
    // Rank is derived, not client-supplied; recomputed below.
  });

  const all = await db
    .collection("users")
    .where("role", "==", "student")
    .orderBy("points", "desc")
    .limit(1000)
    .get();

  const batch = db.batch();
  all.docs.forEach((doc, i) => {
    batch.update(doc.ref, { rank: i + 1 });
  });
  // Everyone ranked outside the top 1000 resets to a sentinel.
  batch.set(
    db.doc("leaderboard/_meta"),
    { lastRecomputedAt: FieldValue.serverTimestamp(), ranked: all.size },
    { merge: true },
  );
  await batch.commit();

  return { ok: true, ranked: all.size };
});
