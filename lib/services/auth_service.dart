import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'auth_exceptions.dart';
import '../utils/validators.dart';

/// Comprehensive Firebase Authentication Service
/// Handles all authentication operations with proper error handling,
/// local storage integration, and security best practices
class AuthService {
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;
  final FlutterSecureStorage _secureStorage;

  // Rate limiting for failed login attempts
  final Map<String, int> _failedAttempts = {};
  final Map<String, DateTime> _lockoutUntil = {};
  static const int _maxFailedAttempts = 5;
  static const Duration _lockoutDuration = Duration(minutes: 15);

  // Keys for secure storage
  static const String _authTokenKey = 'auth_token';
  static const String _userIdKey = 'user_id';
  static const String _emailKey = 'user_email';

  AuthService({
    FirebaseAuth? auth,
    FirebaseFirestore? firestore,
    FlutterSecureStorage? secureStorage,
  })  : _auth = auth ?? FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance,
        _secureStorage = secureStorage ?? const FlutterSecureStorage();

  /// Sign up a new user with email and password
  /// Creates both Firebase Auth user and Firestore user document
  ///
  /// Throws [AuthException] on errors
  Future<User> signUp({
    required String email,
    required String password,
    String? displayName,
  }) async {
    try {
      // Validate inputs
      final emailError = Validators.validateEmail(email);
      if (emailError != null) {
        throw InvalidEmailException();
      }

      final passwordError = Validators.validatePassword(password);
      if (passwordError != null) {
        throw WeakPasswordException();
      }

      // Create Firebase Auth user
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      final user = userCredential.user;
      if (user == null) {
        throw const UnknownAuthException('User creation failed');
      }

      // Update display name if provided
      if (displayName != null && displayName.isNotEmpty) {
        await user.updateDisplayName(displayName.trim());
      }

      // Send email verification
      await user.sendEmailVerification();

      // Create Firestore user document
      await _createUserDocument(
        userId: user.uid,
        email: email.trim(),
        displayName: displayName?.trim(),
      );

      // Save auth token to secure storage
      await _saveAuthToken(user);

      return user;
    } on FirebaseAuthException catch (e) {
      throw mapFirebaseException(e.code, e.message);
    } on AuthException {
      rethrow;
    } catch (e) {
      throw UnknownAuthException('Sign up failed: ${e.toString()}');
    }
  }

  /// Log in an existing user with email and password
  /// Implements rate limiting for security
  ///
  /// Throws [AuthException] on errors
  Future<User> login({
    required String email,
    required String password,
  }) async {
    try {
      // Check rate limiting
      final trimmedEmail = email.trim().toLowerCase();
      _checkRateLimit(trimmedEmail);

      // Validate email format
      final emailError = Validators.validateEmail(email);
      if (emailError != null) {
        throw InvalidEmailException();
      }

      // Attempt sign in
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: trimmedEmail,
        password: password,
      );

      final user = userCredential.user;
      if (user == null) {
        throw const UnknownAuthException('Login failed');
      }

      // Clear failed attempts on successful login
      _failedAttempts.remove(trimmedEmail);
      _lockoutUntil.remove(trimmedEmail);

      // Save auth token to secure storage
      await _saveAuthToken(user);

      return user;
    } on FirebaseAuthException catch (e) {
      // Track failed attempts
      final trimmedEmail = email.trim().toLowerCase();
      _failedAttempts[trimmedEmail] = (_failedAttempts[trimmedEmail] ?? 0) + 1;

      // Lock account if too many failed attempts
      if ((_failedAttempts[trimmedEmail] ?? 0) >= _maxFailedAttempts) {
        _lockoutUntil[trimmedEmail] = DateTime.now().add(_lockoutDuration);
        throw const TooManyRequestsException();
      }

      throw mapFirebaseException(e.code, e.message);
    } on AuthException {
      rethrow;
    } catch (e) {
      throw UnknownAuthException('Login failed: ${e.toString()}');
    }
  }

  /// Log out the current user
  /// Clears local storage and Firebase session
  Future<void> logout() async {
    try {
      await _auth.signOut();
      await _clearLocalStorage();
    } catch (e) {
      throw UnknownAuthException('Logout failed: ${e.toString()}');
    }
  }

  /// Get the currently logged-in user
  /// Returns null if no user is logged in
  User? getCurrentUser() {
    return _auth.currentUser;
  }

  /// Get current user as a stream
  /// Updates automatically when auth state changes
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// Send password reset email
  ///
  /// Throws [AuthException] on errors
  Future<void> resetPassword({required String email}) async {
    try {
      // Validate email
      final emailError = Validators.validateEmail(email);
      if (emailError != null) {
        throw InvalidEmailException();
      }

      await _auth.sendPasswordResetEmail(email: email.trim());
    } on FirebaseAuthException catch (e) {
      throw mapFirebaseException(e.code, e.message);
    } catch (e) {
      throw UnknownAuthException('Password reset failed: ${e.toString()}');
    }
  }

  /// Update user profile (display name and/or photo URL)
  ///
  /// Throws [AuthException] on errors
  Future<void> updateProfile({
    String? displayName,
    String? photoUrl,
  }) async {
    try {
      final user = getCurrentUser();
      if (user == null) {
        throw const UnknownAuthException('No user logged in');
      }

      // Validate display name if provided
      if (displayName != null) {
        final nameError = Validators.validateName(displayName);
        if (nameError != null) {
          throw AuthException('Invalid display name: $nameError');
        }
      }

      // Update Firebase Auth profile
      if (displayName != null) {
        await user.updateDisplayName(displayName.trim());
      }

      if (photoUrl != null) {
        await user.updatePhotoURL(photoUrl);
      }

      // Reload user to get updated data
      await user.reload();

      // Update Firestore document
      await _updateUserDocument(
        userId: user.uid,
        displayName: displayName?.trim(),
        photoUrl: photoUrl,
      );
    } on FirebaseAuthException catch (e) {
      throw mapFirebaseException(e.code, e.message);
    } on AuthException {
      rethrow;
    } catch (e) {
      throw UnknownAuthException('Profile update failed: ${e.toString()}');
    }
  }

  /// Delete the current user's account
  /// Removes both Firebase Auth user and Firestore document
  /// WARNING: This action is irreversible
  ///
  /// Throws [AuthException] on errors
  Future<void> deleteAccount() async {
    try {
      final user = getCurrentUser();
      if (user == null) {
        throw const UnknownAuthException('No user logged in');
      }

      final userId = user.uid;

      // Delete Firestore document first
      await _deleteUserDocument(userId);

      // Delete Firebase Auth user
      await user.delete();

      // Clear local storage
      await _clearLocalStorage();
    } on FirebaseAuthException catch (e) {
      // If requires recent login, inform user
      if (e.code == 'requires-recent-login') {
        throw const RequiresRecentLoginException();
      }
      throw mapFirebaseException(e.code, e.message);
    } catch (e) {
      throw UnknownAuthException('Account deletion failed: ${e.toString()}');
    }
  }

  /// Send email verification to current user
  ///
  /// Throws [AuthException] on errors
  Future<void> sendEmailVerification() async {
    try {
      final user = getCurrentUser();
      if (user == null) {
        throw const UnknownAuthException('No user logged in');
      }

      if (user.emailVerified) {
        throw const AuthException('Email is already verified');
      }

      await user.sendEmailVerification();
    } on FirebaseAuthException catch (e) {
      throw mapFirebaseException(e.code, e.message);
    } on AuthException {
      rethrow;
    } catch (e) {
      throw UnknownAuthException(
          'Failed to send verification email: ${e.toString()}');
    }
  }

  /// Check if current user's email is verified
  /// Returns false if no user is logged in
  bool isEmailVerified() {
    final user = getCurrentUser();
    return user?.emailVerified ?? false;
  }

  /// Reload current user data from Firebase
  /// Useful after email verification or profile updates
  Future<void> reloadUser() async {
    try {
      final user = getCurrentUser();
      if (user == null) {
        throw const UnknownAuthException('No user logged in');
      }

      await user.reload();
    } catch (e) {
      throw UnknownAuthException('Failed to reload user: ${e.toString()}');
    }
  }

  /// Re-authenticate user with current credentials
  /// Required for sensitive operations like account deletion
  ///
  /// Throws [AuthException] on errors
  Future<void> reauthenticate({required String password}) async {
    try {
      final user = getCurrentUser();
      if (user == null || user.email == null) {
        throw const UnknownAuthException('No user logged in');
      }

      final credential = EmailAuthProvider.credential(
        email: user.email!,
        password: password,
      );

      await user.reauthenticateWithCredential(credential);
    } on FirebaseAuthException catch (e) {
      throw mapFirebaseException(e.code, e.message);
    } catch (e) {
      throw UnknownAuthException('Re-authentication failed: ${e.toString()}');
    }
  }

  /// Restore session from local storage
  /// Call this on app startup to restore user session
  /// Returns the restored user or null if no session found
  Future<User?> restoreSession() async {
    try {
      // Check if we have a stored user ID
      final userId = await _secureStorage.read(key: _userIdKey);
      if (userId == null) {
        return null;
      }

      // Get current Firebase user
      final user = getCurrentUser();

      // Verify the stored user ID matches current user
      if (user != null && user.uid == userId) {
        return user;
      }

      // If mismatch, clear storage
      await _clearLocalStorage();
      return null;
    } catch (e) {
      // If any error occurs, clear storage and return null
      await _clearLocalStorage();
      return null;
    }
  }

  // ==================== Private Helper Methods ====================

  /// Check if user is rate limited
  void _checkRateLimit(String email) {
    final lockoutTime = _lockoutUntil[email];
    if (lockoutTime != null && DateTime.now().isBefore(lockoutTime)) {
      final remainingMinutes =
          lockoutTime.difference(DateTime.now()).inMinutes + 1;
      throw AuthException(
        'Too many failed attempts. Please try again in $remainingMinutes minutes.',
      );
    }
  }

  /// Create Firestore user document
  Future<void> _createUserDocument({
    required String userId,
    required String email,
    String? displayName,
  }) async {
    try {
      await _firestore.collection('users').doc(userId).set({
        'email': email,
        'displayName': displayName,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'emailVerified': false,
      });
    } catch (e) {
      // Log error but don't throw - user is created in Auth
      // This allows the app to continue even if Firestore fails
      // You can add proper logging here
      print('Warning: Failed to create Firestore user document: $e');
    }
  }

  /// Update Firestore user document
  Future<void> _updateUserDocument({
    required String userId,
    String? displayName,
    String? photoUrl,
  }) async {
    try {
      final updates = <String, dynamic>{
        'updatedAt': FieldValue.serverTimestamp(),
      };

      if (displayName != null) {
        updates['displayName'] = displayName;
      }

      if (photoUrl != null) {
        updates['photoUrl'] = photoUrl;
      }

      await _firestore.collection('users').doc(userId).update(updates);
    } catch (e) {
      // Log error but don't throw
      print('Warning: Failed to update Firestore user document: $e');
    }
  }

  /// Delete Firestore user document
  Future<void> _deleteUserDocument(String userId) async {
    try {
      await _firestore.collection('users').doc(userId).delete();
    } catch (e) {
      // Log error but don't throw
      print('Warning: Failed to delete Firestore user document: $e');
    }
  }

  /// Save auth token and user info to secure storage
  Future<void> _saveAuthToken(User user) async {
    try {
      final token = await user.getIdToken();
      if (token != null) {
        await _secureStorage.write(key: _authTokenKey, value: token);
      }
      await _secureStorage.write(key: _userIdKey, value: user.uid);
      if (user.email != null) {
        await _secureStorage.write(key: _emailKey, value: user.email!);
      }
    } catch (e) {
      // Log error but don't throw - auth still works without storage
      print('Warning: Failed to save auth token: $e');
    }
  }

  /// Clear all local storage
  Future<void> _clearLocalStorage() async {
    try {
      await _secureStorage.delete(key: _authTokenKey);
      await _secureStorage.delete(key: _userIdKey);
      await _secureStorage.delete(key: _emailKey);
    } catch (e) {
      // Log error but don't throw
      print('Warning: Failed to clear local storage: $e');
    }
  }

  /// Get stored auth token
  Future<String?> getAuthToken() async {
    try {
      return await _secureStorage.read(key: _authTokenKey);
    } catch (e) {
      return null;
    }
  }

  /// Refresh auth token
  Future<String?> refreshAuthToken() async {
    try {
      final user = getCurrentUser();
      if (user == null) return null;

      final token = await user.getIdToken(true); // Force refresh
      if (token != null) {
        await _secureStorage.write(key: _authTokenKey, value: token);
      }
      return token;
    } catch (e) {
      return null;
    }
  }
}
