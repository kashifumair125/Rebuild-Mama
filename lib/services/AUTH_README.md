# Firebase Authentication Service Documentation

## Overview

This is a comprehensive Firebase authentication system with security best practices, local storage integration, and Riverpod state management.

## Features

- Email/password authentication
- User registration with Firestore document creation
- Email verification
- Password reset
- Profile updates (display name, photo URL)
- Account deletion
- Secure token storage with flutter_secure_storage
- Session restoration on app launch
- Rate limiting (5 failed attempts = 15-minute lockout)
- Comprehensive error handling with user-friendly messages
- Input validation (RFC 5322 email, strong password requirements)
- Riverpod integration with loading and error states

## Architecture

### Files Structure

```
lib/
├── services/
│   ├── auth_service.dart          # Main authentication service
│   ├── auth_exceptions.dart       # Custom exception classes
│   └── AUTH_README.md            # This file
├── providers/
│   └── auth_provider.dart        # Riverpod providers
└── utils/
    └── validators.dart           # Input validation utilities
```

## Getting Started

### 1. Installation

The required dependencies are already in `pubspec.yaml`:

```yaml
dependencies:
  firebase_core: ^2.24.2
  firebase_auth: ^4.15.3
  cloud_firestore: ^4.13.6
  flutter_secure_storage: ^9.0.0
  flutter_riverpod: ^2.4.9
```

### 2. Firebase Setup

Make sure Firebase is initialized in your `main.dart`:

```dart
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(ProviderScope(child: MyApp()));
}
```

### 3. Generate Riverpod Code

Run the build_runner to generate Riverpod provider code:

```bash
dart run build_runner build --delete-conflicting-outputs
```

## Usage Examples

### Sign Up

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/auth_provider.dart';
import '../services/auth_exceptions.dart';

class SignUpScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authHelpers = ref.read(authHelpersProvider.notifier);
    final isLoading = ref.watch(authLoadingStateProvider);
    final error = ref.watch(authErrorStateProvider);

    return Scaffold(
      body: Column(
        children: [
          // Your form fields here

          if (error != null)
            Text(error, style: TextStyle(color: Colors.red)),

          ElevatedButton(
            onPressed: isLoading ? null : () async {
              try {
                await authHelpers.signUp(
                  email: emailController.text,
                  password: passwordController.text,
                  displayName: nameController.text,
                );
                // Navigate to home or email verification screen
              } on AuthException catch (e) {
                // Error is already handled by authErrorStateProvider
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(e.message)),
                );
              }
            },
            child: isLoading
                ? CircularProgressIndicator()
                : Text('Sign Up'),
          ),
        ],
      ),
    );
  }
}
```

### Login

```dart
class LoginScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authHelpers = ref.read(authHelpersProvider.notifier);
    final isLoading = ref.watch(authLoadingStateProvider);

    return ElevatedButton(
      onPressed: isLoading ? null : () async {
        try {
          await authHelpers.login(
            email: emailController.text,
            password: passwordController.text,
          );
          // Navigate to home screen
        } on AuthException catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(e.message)),
          );
        }
      },
      child: Text('Login'),
    );
  }
}
```

### Logout

```dart
ElevatedButton(
  onPressed: () async {
    final authHelpers = ref.read(authHelpersProvider.notifier);
    await authHelpers.logout();
    // Navigate to login screen
  },
  child: Text('Logout'),
);
```

### Password Reset

```dart
class ForgotPasswordScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authHelpers = ref.read(authHelpersProvider.notifier);

    return ElevatedButton(
      onPressed: () async {
        try {
          await authHelpers.resetPassword(email: emailController.text);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Password reset email sent!')),
          );
        } on AuthException catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(e.message)),
          );
        }
      },
      child: Text('Reset Password'),
    );
  }
}
```

### Update Profile

```dart
await authHelpers.updateProfile(
  displayName: 'New Name',
  photoUrl: 'https://example.com/photo.jpg',
);
```

### Delete Account

```dart
// Re-authenticate first for security
await authHelpers.reauthenticate(password: currentPassword);

// Then delete account
await authHelpers.deleteAccount();
```

### Session Restoration

In your splash screen or main.dart:

```dart
class SplashScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sessionAsync = ref.watch(restoreSessionProvider);

    return sessionAsync.when(
      data: (user) {
        if (user != null) {
          // Navigate to home screen
          return HomeScreen();
        } else {
          // Navigate to login screen
          return LoginScreen();
        }
      },
      loading: () => CircularProgressIndicator(),
      error: (_, __) => LoginScreen(),
    );
  }
}
```

### Watch Auth State

```dart
class MyApp extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUserAsync = ref.watch(currentUserProvider);

    return currentUserAsync.when(
      data: (user) {
        if (user != null) {
          return HomeScreen();
        } else {
          return LoginScreen();
        }
      },
      loading: () => SplashScreen(),
      error: (_, __) => ErrorScreen(),
    );
  }
}
```

## Available Providers

### Auth State Providers

- **`currentUserProvider`**: Stream of current user (AsyncValue<User?>)
- **`isUserLoggedInProvider`**: Boolean indicating if user is logged in
- **`currentUserIdProvider`**: Current user's ID (String?)
- **`currentUserEmailProvider`**: Current user's email (String?)
- **`currentUserDisplayNameProvider`**: Current user's display name (String?)
- **`isEmailVerifiedProvider`**: Boolean indicating if email is verified

### Firestore Providers

- **`userDocumentProvider`**: Stream of user's Firestore document
- **`userDocumentDataProvider`**: Stream of user's document data as Map

### State Management Providers

- **`authLoadingStateProvider`**: Loading state for auth operations
- **`authErrorStateProvider`**: Error messages from auth operations
- **`authHelpersProvider`**: Helper methods for auth operations

### Utility Providers

- **`authTokenProvider`**: Get current auth token
- **`restoreSessionProvider`**: Restore user session on app startup

## Input Validation

### Email Validation

```dart
import '../utils/validators.dart';

final emailError = Validators.validateEmail(email);
if (emailError != null) {
  // Show error
}

// Or use boolean check
if (Validators.isValidEmail(email)) {
  // Email is valid
}
```

### Password Validation

Requirements:
- Minimum 8 characters
- At least 1 uppercase letter
- At least 1 lowercase letter
- At least 1 number

```dart
final passwordError = Validators.validatePassword(password);
if (passwordError != null) {
  // Show error
}

// Check password strength (0-4)
final strength = Validators.getPasswordStrength(password);
final description = Validators.getPasswordStrengthDescription(strength);
// Returns: "Very Weak", "Weak", "Fair", "Strong", "Very Strong"
```

### Confirm Password

```dart
final confirmError = Validators.validateConfirmPassword(
  confirmPassword,
  originalPassword,
);
```

## Error Handling

All auth errors are mapped to user-friendly custom exceptions:

- `InvalidEmailException`: Invalid email format
- `WeakPasswordException`: Password doesn't meet requirements
- `EmailAlreadyInUseException`: Email already registered
- `UserNotFoundException`: No account with this email
- `WrongPasswordException`: Incorrect password
- `UserDisabledException`: Account is disabled
- `TooManyRequestsException`: Rate limit exceeded
- `OperationNotAllowedException`: Operation not allowed
- `NetworkRequestFailedException`: Network error
- `EmailNotVerifiedException`: Email not verified
- `RequiresRecentLoginException`: Need to re-authenticate
- `UnknownAuthException`: Generic error

Example error handling:

```dart
try {
  await authHelpers.login(email: email, password: password);
} on EmailAlreadyInUseException catch (e) {
  showDialog(context, 'This email is already registered');
} on WrongPasswordException catch (e) {
  showDialog(context, 'Incorrect password');
} on AuthException catch (e) {
  showDialog(context, e.message);
}
```

## Security Features

### 1. Rate Limiting

- Maximum 5 failed login attempts per email
- 15-minute lockout after exceeding limit
- Automatic reset after successful login

### 2. Secure Storage

- Auth tokens stored in flutter_secure_storage
- Encrypted at rest
- Automatically cleared on logout

### 3. Email Verification

- Automatic verification email sent on signup
- Can check verification status with `isEmailVerifiedProvider`
- Can resend verification email

### 4. Input Validation

- RFC 5322 compliant email validation
- Strong password requirements enforced
- Input sanitization (trimming, lowercase for emails)

### 5. HTTPS Only

- Firebase SDK uses HTTPS by default
- All API calls are encrypted

### 6. Re-authentication

- Sensitive operations (delete account) require re-authentication
- Prevents unauthorized actions from compromised sessions

## Firestore User Document Structure

When a user signs up, a document is created in the `users` collection:

```json
{
  "email": "user@example.com",
  "displayName": "John Doe",
  "photoUrl": "https://example.com/photo.jpg",
  "createdAt": Timestamp,
  "updatedAt": Timestamp,
  "emailVerified": false
}
```

## Testing

### Unit Testing

```dart
void main() {
  group('AuthService', () {
    late AuthService authService;
    late MockFirebaseAuth mockAuth;
    late MockFirestore mockFirestore;
    late MockSecureStorage mockStorage;

    setUp(() {
      mockAuth = MockFirebaseAuth();
      mockFirestore = MockFirestore();
      mockStorage = MockSecureStorage();

      authService = AuthService(
        auth: mockAuth,
        firestore: mockFirestore,
        secureStorage: mockStorage,
      );
    });

    test('signUp creates user and Firestore document', () async {
      // Your test implementation
    });
  });
}
```

## Best Practices

1. **Always validate input** before calling auth methods
2. **Handle all exceptions** with try-catch blocks
3. **Show loading states** during auth operations
4. **Clear error states** before new operations
5. **Verify email** before allowing access to sensitive features
6. **Re-authenticate** before sensitive operations
7. **Never log passwords** in production
8. **Use secure storage** for tokens
9. **Implement proper logout** to clear all local data
10. **Test with mock Firebase** for unit tests

## Troubleshooting

### "User not found" on valid email

- Check if Firebase Authentication is enabled in Firebase Console
- Verify the user exists in Firebase Authentication panel

### Email verification not sending

- Check Firebase Console > Authentication > Templates
- Verify email settings and sender address

### Secure storage not working

- Add required permissions to AndroidManifest.xml and Info.plist
- Check flutter_secure_storage documentation for platform-specific setup

### Rate limiting not working in development

- Rate limiting persists only during app session
- Clear app data to reset failed attempts counter

## Additional Resources

- [Firebase Auth Documentation](https://firebase.google.com/docs/auth)
- [Riverpod Documentation](https://riverpod.dev)
- [Flutter Secure Storage](https://pub.dev/packages/flutter_secure_storage)

## Support

For issues or questions, please check the main project documentation or create an issue in the project repository.
