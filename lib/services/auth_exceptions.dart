/// Custom exception classes for authentication errors
/// Provides user-friendly error messages for various auth scenarios

/// Base class for all authentication exceptions
class AuthException implements Exception {
  final String message;
  final String? code;

  const AuthException(this.message, {this.code});

  @override
  String toString() => message;
}

/// Exception thrown when email is invalid
class InvalidEmailException extends AuthException {
  const InvalidEmailException()
      : super('The email address is invalid. Please enter a valid email.');
}

/// Exception thrown when password is weak
class WeakPasswordException extends AuthException {
  const WeakPasswordException()
      : super(
            'Password is too weak. Must be at least 8 characters with 1 uppercase letter and 1 number.');
}

/// Exception thrown when email already exists
class EmailAlreadyInUseException extends AuthException {
  const EmailAlreadyInUseException()
      : super('An account already exists with this email address.');
}

/// Exception thrown when user is not found
class UserNotFoundException extends AuthException {
  const UserNotFoundException()
      : super('No account found with this email address.');
}

/// Exception thrown when password is incorrect
class WrongPasswordException extends AuthException {
  const WrongPasswordException()
      : super('Incorrect password. Please try again.');
}

/// Exception thrown when user is disabled
class UserDisabledException extends AuthException {
  const UserDisabledException()
      : super('This account has been disabled. Please contact support.');
}

/// Exception thrown when too many requests are made
class TooManyRequestsException extends AuthException {
  const TooManyRequestsException()
      : super(
            'Too many failed attempts. Please try again later or reset your password.');
}

/// Exception thrown when operation is not allowed
class OperationNotAllowedException extends AuthException {
  const OperationNotAllowedException()
      : super('This operation is not allowed. Please contact support.');
}

/// Exception thrown when network request fails
class NetworkRequestFailedException extends AuthException {
  const NetworkRequestFailedException()
      : super('Network error. Please check your connection and try again.');
}

/// Exception thrown when user needs to verify email
class EmailNotVerifiedException extends AuthException {
  const EmailNotVerifiedException()
      : super('Please verify your email address before continuing.');
}

/// Exception thrown when requires recent login
class RequiresRecentLoginException extends AuthException {
  const RequiresRecentLoginException()
      : super(
            'This operation requires recent authentication. Please log in again.');
}

/// Exception thrown for unknown errors
class UnknownAuthException extends AuthException {
  const UnknownAuthException([String? message])
      : super(message ?? 'An unexpected error occurred. Please try again.');
}

/// Helper function to map Firebase error codes to custom exceptions
AuthException mapFirebaseException(String code, [String? message]) {
  switch (code) {
    case 'invalid-email':
      return const InvalidEmailException();
    case 'weak-password':
      return const WeakPasswordException();
    case 'email-already-in-use':
      return const EmailAlreadyInUseException();
    case 'user-not-found':
      return const UserNotFoundException();
    case 'wrong-password':
      return const WrongPasswordException();
    case 'user-disabled':
      return const UserDisabledException();
    case 'too-many-requests':
      return const TooManyRequestsException();
    case 'operation-not-allowed':
      return const OperationNotAllowedException();
    case 'network-request-failed':
      return const NetworkRequestFailedException();
    case 'requires-recent-login':
      return const RequiresRecentLoginException();
    default:
      return UnknownAuthException(message);
  }
}
