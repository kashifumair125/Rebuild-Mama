import 'package:firebase_auth/firebase_auth.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'auth_provider.g.dart';

/// Provider for Firebase Auth instance
@riverpod
FirebaseAuth firebaseAuth(FirebaseAuthRef ref) {
  return FirebaseAuth.instance;
}

/// Stream provider for current user
/// Automatically updates when authentication state changes
@riverpod
Stream<User?> currentUser(CurrentUserRef ref) {
  final auth = ref.watch(firebaseAuthProvider);
  return auth.authStateChanges();
}

/// Provider to check if user is logged in
/// Derived from currentUser stream
@riverpod
bool isUserLoggedIn(IsUserLoggedInRef ref) {
  final userAsync = ref.watch(currentUserProvider);

  return userAsync.when(
    data: (user) => user != null,
    loading: () => false,
    error: (_, __) => false,
  );
}

/// Provider for current user ID
/// Returns null if user is not logged in
@riverpod
String? userId(UserIdRef ref) {
  final userAsync = ref.watch(currentUserProvider);

  return userAsync.when(
    data: (user) => user?.uid,
    loading: () => null,
    error: (_, __) => null,
  );
}

/// Auth service provider for authentication operations
@riverpod
AuthService authService(AuthServiceRef ref) {
  final auth = ref.watch(firebaseAuthProvider);
  return AuthService(auth);
}

/// Authentication service class
/// Handles sign in, sign up, and sign out operations
class AuthService {
  final FirebaseAuth _auth;

  AuthService(this._auth);

  /// Sign in with email and password
  Future<UserCredential> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      return await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  /// Sign up with email and password
  Future<UserCredential> signUpWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      return await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  /// Sign out
  Future<void> signOut() async {
    await _auth.signOut();
  }

  /// Send password reset email
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  /// Handle Firebase Auth exceptions
  String _handleAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'No user found with this email.';
      case 'wrong-password':
        return 'Wrong password provided.';
      case 'email-already-in-use':
        return 'An account already exists with this email.';
      case 'invalid-email':
        return 'The email address is invalid.';
      case 'weak-password':
        return 'The password is too weak.';
      case 'operation-not-allowed':
        return 'This operation is not allowed.';
      default:
        return 'An error occurred. Please try again.';
    }
  }
}
