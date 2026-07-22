// lib/core/repositories/auth_repository.dart
//
// Single source of truth for auth operations.
// Uses Firebase Auth + syncs with REST API.
// Returns Result<T> — never throws.

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../api/dio_client.dart';
import '../api/must_api_service.dart';
import '../constants/app_constants.dart';
import '../errors/app_exception.dart';
import '../errors/result.dart';
import '../models/user_model.dart';

class AuthRepository {
  AuthRepository({
    FirebaseAuth? firebaseAuth,
    FirebaseFirestore? firestore,
    MustApiService? apiService,
  })  : _auth = firebaseAuth ?? FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance,
        _api = apiService ??
            MustApiService(DioClient.instance.dio);

  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;
  final MustApiService _api;

  // ── Current user stream ─────────────────────────────────────
  Stream<User?> get authStateChanges => _auth.authStateChanges();
  User? get currentFirebaseUser => _auth.currentUser;

  // ── Sign in ─────────────────────────────────────────────────
  Future<Result<UserModel>> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      final user = await _fetchUserModel(credential.user!.uid);
      if (!user.isActive) {
        await _auth.signOut();
        return failure(const AuthException(
            'Your account has been deactivated.'));
      }
      // Sync with API (best-effort — don't fail sign-in if API is down)
      _syncWithApi().ignore();
      return success(user);
    } on FirebaseAuthException catch (e) {
      return failure(AuthException.fromFirebase(e.code));
    } on FirestoreException catch (e) {
      return failure(e);
    } catch (e) {
      return failure(UnknownException(e.toString()));
    }
  }

  // ── Register ─────────────────────────────────────────────────
  Future<Result<UserModel>> register({
    required String email,
    required String password,
    required String name,
    required String nameAr,
    required String role,
    String? studentId,
  }) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      final uid = credential.user!.uid;

      final userModel = UserModel(
        uid: uid,
        email: email.trim(),
        name: name.trim(),
        nameAr: nameAr.trim(),
        role: role,
        studentId: studentId?.trim(),
        createdAt: DateTime.now(),
      );

      // Write to Firestore
      await _firestore
          .collection(FirestoreCollections.users)
          .doc(uid)
          .set(userModel.toFirestore());

      // Sync with API
      _syncWithApi().ignore();

      return success(userModel);
    } on FirebaseAuthException catch (e) {
      return failure(AuthException.fromFirebase(e.code));
    } catch (e) {
      return failure(UnknownException(e.toString()));
    }
  }

  // ── Sign out ─────────────────────────────────────────────────
  Future<Result<void>> signOut() async {
    try {
      await _auth.signOut();
      return success(null);
    } catch (e) {
      return failure(UnknownException(e.toString()));
    }
  }

  // ── Password reset ───────────────────────────────────────────
  Future<Result<void>> sendPasswordReset(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
      return success(null);
    } on FirebaseAuthException catch (e) {
      return failure(AuthException.fromFirebase(e.code));
    } catch (e) {
      return failure(UnknownException(e.toString()));
    }
  }

  // ── Get current user model ───────────────────────────────────
  Future<Result<UserModel>> getCurrentUser() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) {
      return failure(const UnauthorisedException());
    }
    try {
      return success(await _fetchUserModel(uid));
    } on FirestoreException catch (e) {
      return failure(e);
    } catch (e) {
      return failure(UnknownException(e.toString()));
    }
  }

  // ── Helpers ──────────────────────────────────────────────────
  Future<UserModel> _fetchUserModel(String uid) async {
    final doc = await _firestore
        .collection(FirestoreCollections.users)
        .doc(uid)
        .get();
    if (!doc.exists) {
      throw const FirestoreException('User profile not found.',
          code: 'not_found');
    }
    return UserModel.fromFirestore(doc);
  }

  Future<void> _syncWithApi() async {
    final user = _auth.currentUser;
    if (user == null) return;
    try {
      final token = await user.getIdToken();
      await _api.syncUser({
        'uid': user.uid,
        'email': user.email,
        'firebase_token': token,
      });
    } catch (_) {
      // Non-fatal: API might not be reachable
    }
  }
}
