import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:rebuild_mama/providers/auth_provider.dart';
import 'provider_test_utils.dart';

void main() {
  group('Auth Provider Tests', () {
    late ProviderContainer container;

    setUp(() {
      // Setup runs before each test
    });

    tearDown(() {
      // Cleanup after each test
      if (container != null) {
        disposeTestContainer(container);
      }
    });

    test('currentUserProvider returns user when authenticated', () async {
      // Arrange
      final mockUser = createMockUser(
        uid: 'test-123',
        email: 'test@example.com',
      );

      container = createTestProviderContainer(
        currentUser: mockUser,
      );

      // Act
      final userStream = container.read(currentUserProvider);

      // Assert
      await expectLater(
        userStream,
        emits(mockUser),
      );
    });

    test('isUserLoggedInProvider returns true when user is logged in', () async {
      // Arrange
      final mockUser = createMockUser();

      container = createTestProviderContainer(
        currentUser: mockUser,
      );

      await waitForProvider(container);

      // Act
      final isLoggedIn = container.read(isUserLoggedInProvider);

      // Assert
      expect(isLoggedIn, true);
    });

    test('isUserLoggedInProvider returns false when user is not logged in',
        () async {
      // Arrange
      container = createTestProviderContainer(
        currentUser: null,
      );

      await waitForProvider(container);

      // Act
      final isLoggedIn = container.read(isUserLoggedInProvider);

      // Assert
      expect(isLoggedIn, false);
    });

    test('userIdProvider returns user ID when logged in', () async {
      // Arrange
      final mockUser = createMockUser(uid: 'user-123');

      container = createTestProviderContainer(
        currentUser: mockUser,
      );

      await waitForProvider(container);

      // Act
      final userId = container.read(userIdProvider);

      // Assert
      expect(userId, 'user-123');
    });

    test('userIdProvider returns null when not logged in', () async {
      // Arrange
      container = createTestProviderContainer(
        currentUser: null,
      );

      await waitForProvider(container);

      // Act
      final userId = container.read(userIdProvider);

      // Assert
      expect(userId, null);
    });
  });

  group('AuthService Tests', () {
    test('handles authentication errors correctly', () async {
      // Example test for error handling
      // You would need to mock FirebaseAuth to throw exceptions
      // and verify that AuthService handles them correctly
    });
  });
}
