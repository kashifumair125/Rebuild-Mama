import 'package:drift/drift.dart';
import '../app_database.dart';

part 'user_dao.g.dart';

@DriftAccessor(tables: [Users])
class UserDao extends DatabaseAccessor<AppDatabase> with _$UserDaoMixin {
  UserDao(AppDatabase db) : super(db);

  // ============================================================================
  // CREATE
  // ============================================================================

  /// Insert a new user
  Future<int> insertUser(UsersCompanion user) async {
    return await into(users).insert(user);
  }

  /// Insert or update a user (based on email)
  Future<int> upsertUser(UsersCompanion user) async {
    return await into(users).insertOnConflictUpdate(user);
  }

  // ============================================================================
  // READ
  // ============================================================================

  /// Get user by ID
  Future<User?> getUserById(int userId) async {
    return await (select(users)..where((u) => u.userId.equals(userId)))
        .getSingleOrNull();
  }

  /// Get user by email
  Future<User?> getUserByEmail(String email) async {
    return await (select(users)..where((u) => u.email.equals(email)))
        .getSingleOrNull();
  }

  /// Get all users (for admin purposes or multi-user support)
  Future<List<User>> getAllUsers() async {
    return await select(users).get();
  }

  /// Watch user by ID (reactive stream)
  Stream<User?> watchUserById(int userId) {
    return (select(users)..where((u) => u.userId.equals(userId)))
        .watchSingleOrNull();
  }

  /// Watch user by email (reactive stream)
  Stream<User?> watchUserByEmail(String email) {
    return (select(users)..where((u) => u.email.equals(email)))
        .watchSingleOrNull();
  }

  /// Get users by delivery type
  Future<List<User>> getUsersByDeliveryType(String deliveryType) async {
    return await (select(users)
          ..where((u) => u.deliveryType.equals(deliveryType)))
        .get();
  }

  /// Get users by weeks postpartum range
  Future<List<User>> getUsersByWeeksPostpartumRange(
    int minWeeks,
    int maxWeeks,
  ) async {
    return await (select(users)
          ..where((u) =>
              u.weeksPostpartum.isBiggerOrEqualValue(minWeeks) &
              u.weeksPostpartum.isSmallerOrEqualValue(maxWeeks)))
        .get();
  }

  // ============================================================================
  // UPDATE
  // ============================================================================

  /// Update user
  Future<bool> updateUser(User user) async {
    final updatedUser = user.copyWith(updatedAt: DateTime.now());
    return await update(users).replace(updatedUser);
  }

  /// Update user's weeks postpartum
  Future<int> updateWeeksPostpartum(int userId, int weeks) async {
    return await (update(users)..where((u) => u.userId.equals(userId))).write(
      UsersCompanion(
        weeksPostpartum: Value(weeks),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  /// Update user's delivery type
  Future<int> updateDeliveryType(int userId, String deliveryType) async {
    return await (update(users)..where((u) => u.userId.equals(userId))).write(
      UsersCompanion(
        deliveryType: Value(deliveryType),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  /// Update user's email
  Future<int> updateEmail(int userId, String email) async {
    return await (update(users)..where((u) => u.userId.equals(userId))).write(
      UsersCompanion(
        email: Value(email),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  /// Update user's password hash
  Future<int> updatePasswordHash(int userId, String passwordHash) async {
    return await (update(users)..where((u) => u.userId.equals(userId))).write(
      UsersCompanion(
        passwordHash: Value(passwordHash),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  /// Update user's name
  Future<int> updateName(int userId, String name) async {
    return await (update(users)..where((u) => u.userId.equals(userId))).write(
      UsersCompanion(
        name: Value(name),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  // ============================================================================
  // DELETE
  // ============================================================================

  /// Delete user by ID
  Future<int> deleteUser(int userId) async {
    return await (delete(users)..where((u) => u.userId.equals(userId))).go();
  }

  /// Delete user by email
  Future<int> deleteUserByEmail(String email) async {
    return await (delete(users)..where((u) => u.email.equals(email))).go();
  }

  /// Delete all users (use with caution)
  Future<int> deleteAllUsers() async {
    return await delete(users).go();
  }

  // ============================================================================
  // UTILITY
  // ============================================================================

  /// Check if email exists
  Future<bool> emailExists(String email) async {
    final user = await getUserByEmail(email);
    return user != null;
  }

  /// Get total user count
  Future<int> getUserCount() async {
    final countExp = users.userId.count();
    final query = selectOnly(users)..addColumns([countExp]);
    final result = await query.getSingle();
    return result.read(countExp) ?? 0;
  }

  /// Get users created within date range
  Future<List<User>> getUsersCreatedBetween(
    DateTime startDate,
    DateTime endDate,
  ) async {
    return await (select(users)
          ..where((u) =>
              u.createdAt.isBiggerOrEqualValue(startDate) &
              u.createdAt.isSmallerOrEqualValue(endDate))
          ..orderBy([(u) => OrderingTerm.desc(u.createdAt)]))
        .get();
  }

  /// Get recently updated users
  Future<List<User>> getRecentlyUpdatedUsers({int limit = 10}) async {
    return await (select(users)
          ..orderBy([(u) => OrderingTerm.desc(u.updatedAt)])
          ..limit(limit))
        .get();
  }
}
