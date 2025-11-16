import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../services/auth_service.dart';

part 'auth_provider.g.dart';

// ==================== Core Firebase Providers ====================

/// Provider for Firebase Auth instance
@riverpod
FirebaseAuth firebaseAuth(FirebaseAuthRef ref) {
  return FirebaseAuth.instance;
}

/// Provider for Firestore instance
@riverpod
FirebaseFirestore firebaseFirestore(FirebaseFirestoreRef ref) {
  return FirebaseFirestore.instance;
}

/// Provider for Secure Storage instance
@riverpod
FlutterSecureStorage secureStorage(SecureStorageRef ref) {
  return const FlutterSecureStorage();
}

// ==================== Auth Service Provider ====================

/// Provider for the comprehensive AuthService
/// This is the main service for all authentication operations
@riverpod
AuthService authService(AuthServiceRef ref) {
  final auth = ref.watch(firebaseAuthProvider);
  final firestore = ref.watch(firebaseFirestoreProvider);
  final storage = ref.watch(secureStorageProvider);

  return AuthService(
    auth: auth,
    firestore: firestore,
    secureStorage: storage,
  );
}

// ==================== Auth State Providers ====================

/// Stream provider for current user
/// Automatically updates when authentication state changes
/// Returns User? - null if not logged in
@riverpod
Stream<User?> authStateChanges(AuthStateChangesRef ref) {
  final auth = ref.watch(firebaseAuthProvider);
  return auth.authStateChanges();
}

/// Provider for current user
/// Returns AsyncValue<User?> which can be in loading, data, or error state
@riverpod
Stream<User?> currentUser(CurrentUserRef ref) {
  return ref.watch(authStateChangesProvider);
}

/// Provider to check if user is logged in
/// Returns boolean - true if user is logged in, false otherwise
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
/// Returns String? - null if user is not logged in
@riverpod
String? currentUserId(CurrentUserIdRef ref) {
  final userAsync = ref.watch(currentUserProvider);

  return userAsync.when(
    data: (user) => user?.uid,
    loading: () => null,
    error: (_, __) => null,
  );
}

/// Provider for current user email
/// Returns String? - null if user is not logged in or email is not available
@riverpod
String? currentUserEmail(CurrentUserEmailRef ref) {
  final userAsync = ref.watch(currentUserProvider);

  return userAsync.when(
    data: (user) => user?.email,
    loading: () => null,
    error: (_, __) => null,
  );
}

/// Provider for current user display name
/// Returns String? - null if user is not logged in or display name is not set
@riverpod
String? currentUserDisplayName(CurrentUserDisplayNameRef ref) {
  final userAsync = ref.watch(currentUserProvider);

  return userAsync.when(
    data: (user) => user?.displayName,
    loading: () => null,
    error: (_, __) => null,
  );
}

/// Provider to check if current user's email is verified
/// Returns boolean - false if not logged in or email not verified
@riverpod
bool isEmailVerified(IsEmailVerifiedRef ref) {
  final userAsync = ref.watch(currentUserProvider);

  return userAsync.when(
    data: (user) => user?.emailVerified ?? false,
    loading: () => false,
    error: (_, __) => false,
  );
}

// ==================== Firestore User Document Provider ====================

/// Provider for current user's Firestore document
/// Returns a stream of the user's document data
/// Returns null if user is not logged in
@riverpod
Stream<DocumentSnapshot<Map<String, dynamic>>?> userDocument(
    UserDocumentRef ref) {
  final userId = ref.watch(currentUserIdProvider);

  if (userId == null) {
    return Stream.value(null);
  }

  final firestore = ref.watch(firebaseFirestoreProvider);
  return firestore.collection('users').doc(userId).snapshots();
}

/// Provider for user document data as a Map
/// Returns AsyncValue<Map<String, dynamic>?> with the user's data
@riverpod
Stream<Map<String, dynamic>?> userDocumentData(UserDocumentDataRef ref) async* {
  final docStream = ref.watch(userDocumentProvider);

  await for (final doc in docStream) {
    yield doc?.data();
  }
}

// ==================== Auth Token Provider ====================

/// Provider to get the current auth token
/// Useful for API calls that require authentication
@riverpod
Future<String?> authToken(AuthTokenRef ref) async {
  final authService = ref.watch(authServiceProvider);
  return authService.getAuthToken();
}

// ==================== Session Restoration ====================

/// Provider to restore user session on app startup
/// Call this in your main.dart or splash screen
@riverpod
Future<User?> restoreSession(RestoreSessionRef ref) async {
  final authService = ref.watch(authServiceProvider);
  return authService.restoreSession();
}

// ==================== Auth State Notifiers ====================

/// State notifier for auth loading states
/// Useful for showing loading indicators during auth operations
@riverpod
class AuthLoadingState extends _$AuthLoadingState {
  @override
  bool build() => false;

  void setLoading(bool value) {
    state = value;
  }
}

/// State notifier for auth error messages
/// Useful for displaying error messages to users
@riverpod
class AuthErrorState extends _$AuthErrorState {
  @override
  String? build() => null;

  void setError(String? error) {
    state = error;
  }

  void clearError() {
    state = null;
  }
}

// ==================== Helper Methods Provider ====================

/// Provider for auth helper methods
/// Provides convenient methods for common auth operations
@riverpod
class AuthHelpers extends _$AuthHelpers {
  @override
  void build() {}

  /// Sign up a new user
  Future<User> signUp({
    required String email,
    required String password,
    String? displayName,
  }) async {
    final authService = ref.read(authServiceProvider);
    ref.read(authLoadingStateProvider.notifier).setLoading(true);
    ref.read(authErrorStateProvider.notifier).clearError();

    try {
      final user = await authService.signUp(
        email: email,
        password: password,
        displayName: displayName,
      );
      return user;
    } catch (e) {
      ref.read(authErrorStateProvider.notifier).setError(e.toString());
      rethrow;
    } finally {
      ref.read(authLoadingStateProvider.notifier).setLoading(false);
    }
  }

  /// Log in an existing user
  Future<User> login({
    required String email,
    required String password,
  }) async {
    final authService = ref.read(authServiceProvider);
    ref.read(authLoadingStateProvider.notifier).setLoading(true);
    ref.read(authErrorStateProvider.notifier).clearError();

    try {
      final user = await authService.login(
        email: email,
        password: password,
      );
      return user;
    } catch (e) {
      ref.read(authErrorStateProvider.notifier).setError(e.toString());
      rethrow;
    } finally {
      ref.read(authLoadingStateProvider.notifier).setLoading(false);
    }
  }

  /// Log out the current user
  Future<void> logout() async {
    final authService = ref.read(authServiceProvider);
    ref.read(authLoadingStateProvider.notifier).setLoading(true);
    ref.read(authErrorStateProvider.notifier).clearError();

    try {
      await authService.logout();
    } catch (e) {
      ref.read(authErrorStateProvider.notifier).setError(e.toString());
      rethrow;
    } finally {
      ref.read(authLoadingStateProvider.notifier).setLoading(false);
    }
  }

  /// Send password reset email
  Future<void> resetPassword({required String email}) async {
    final authService = ref.read(authServiceProvider);
    ref.read(authLoadingStateProvider.notifier).setLoading(true);
    ref.read(authErrorStateProvider.notifier).clearError();

    try {
      await authService.resetPassword(email: email);
    } catch (e) {
      ref.read(authErrorStateProvider.notifier).setError(e.toString());
      rethrow;
    } finally {
      ref.read(authLoadingStateProvider.notifier).setLoading(false);
    }
  }

  /// Update user profile
  Future<void> updateProfile({
    String? displayName,
    String? photoUrl,
  }) async {
    final authService = ref.read(authServiceProvider);
    ref.read(authLoadingStateProvider.notifier).setLoading(true);
    ref.read(authErrorStateProvider.notifier).clearError();

    try {
      await authService.updateProfile(
        displayName: displayName,
        photoUrl: photoUrl,
      );
    } catch (e) {
      ref.read(authErrorStateProvider.notifier).setError(e.toString());
      rethrow;
    } finally {
      ref.read(authLoadingStateProvider.notifier).setLoading(false);
    }
  }

  /// Delete user account
  Future<void> deleteAccount() async {
    final authService = ref.read(authServiceProvider);
    ref.read(authLoadingStateProvider.notifier).setLoading(true);
    ref.read(authErrorStateProvider.notifier).clearError();

    try {
      await authService.deleteAccount();
    } catch (e) {
      ref.read(authErrorStateProvider.notifier).setError(e.toString());
      rethrow;
    } finally {
      ref.read(authLoadingStateProvider.notifier).setLoading(false);
    }
  }

  /// Send email verification
  Future<void> sendEmailVerification() async {
    final authService = ref.read(authServiceProvider);
    ref.read(authLoadingStateProvider.notifier).setLoading(true);
    ref.read(authErrorStateProvider.notifier).clearError();

    try {
      await authService.sendEmailVerification();
    } catch (e) {
      ref.read(authErrorStateProvider.notifier).setError(e.toString());
      rethrow;
    } finally {
      ref.read(authLoadingStateProvider.notifier).setLoading(false);
    }
  }

  /// Reload user data
  Future<void> reloadUser() async {
    final authService = ref.read(authServiceProvider);
    try {
      await authService.reloadUser();
    } catch (e) {
      ref.read(authErrorStateProvider.notifier).setError(e.toString());
      rethrow;
    }
  }

  /// Re-authenticate user
  Future<void> reauthenticate({required String password}) async {
    final authService = ref.read(authServiceProvider);
    ref.read(authLoadingStateProvider.notifier).setLoading(true);
    ref.read(authErrorStateProvider.notifier).clearError();

    try {
      await authService.reauthenticate(password: password);
    } catch (e) {
      ref.read(authErrorStateProvider.notifier).setError(e.toString());
      rethrow;
    } finally {
      ref.read(authLoadingStateProvider.notifier).setLoading(false);
    }
  }

  /// Refresh auth token
  Future<String?> refreshAuthToken() async {
    final authService = ref.read(authServiceProvider);
    try {
      return await authService.refreshAuthToken();
    } catch (e) {
      ref.read(authErrorStateProvider.notifier).setError(e.toString());
      return null;
    }
  }
}
