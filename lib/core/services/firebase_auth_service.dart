import 'package:firebase_auth/firebase_auth.dart';

/// IMPROVEMENT #18: Added sendPasswordResetEmail for forgot-password flow.
class FirebaseAuthService {
  FirebaseAuthService._();
  static final FirebaseAuthService instance = FirebaseAuthService._();

  final FirebaseAuth _auth = FirebaseAuth.instance;

  User? get currentUser         => _auth.currentUser;
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  Future<String?> signIn(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(
          email: email.trim(), password: password);
      return null;
    } on FirebaseAuthException catch (e) {
      return _mapCode(e.code);
    } catch (_) {
      return 'firebaseError';
    }
  }

  Future<String?> signUp(String email, String password) async {
    try {
      await _auth.createUserWithEmailAndPassword(
          email: email.trim(), password: password);
      return null;
    } on FirebaseAuthException catch (e) {
      return _mapSignUpCode(e.code);
    } catch (_) {
      return 'firebaseError';
    }
  }

  /// IMPROVEMENT #18: Sends a password-reset email via Firebase.
  /// Returns null on success, error key string on failure.
  Future<String?> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
      return null;
    } on FirebaseAuthException catch (e) {
      return switch (e.code) {
        'user-not-found' => 'noAccountFound',
        'invalid-email'  => 'invalidEmail',
        _                => 'firebaseError',
      };
    } catch (_) {
      return 'firebaseError';
    }
  }

  Future<void> signOut() async => _auth.signOut();

  String _mapCode(String code) => switch (code) {
    'user-not-found' || 'wrong-password' || 'invalid-credential' => 'invalidCredentials',
    'invalid-email' => 'invalidEmail',
    _ => 'firebaseError',
  };

  String _mapSignUpCode(String code) => switch (code) {
    'email-already-in-use'  => 'emailAlreadyInUse',
    'invalid-email'         => 'invalidEmail',
    'weak-password'         => 'weakPassword',
    'operation-not-allowed' => 'operationNotAllowed',
    _                       => 'firebaseError',
  };
}
