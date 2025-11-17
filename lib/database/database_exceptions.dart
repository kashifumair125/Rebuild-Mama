/// Custom exceptions for database operations
/// Provides specific error types for better error handling and user feedback

/// Base exception for all database-related errors
class DatabaseException implements Exception {
  final String message;
  final Object? originalError;
  final StackTrace? stackTrace;

  DatabaseException(
    this.message, {
    this.originalError,
    this.stackTrace,
  });

  @override
  String toString() {
    if (originalError != null) {
      return 'DatabaseException: $message (Original: $originalError)';
    }
    return 'DatabaseException: $message';
  }
}

/// Exception thrown when database connection fails
class DatabaseConnectionException extends DatabaseException {
  DatabaseConnectionException(
    String message, {
    Object? originalError,
    StackTrace? stackTrace,
  }) : super(
          message,
          originalError: originalError,
          stackTrace: stackTrace,
        );

  @override
  String toString() => 'DatabaseConnectionException: $message';
}

/// Exception thrown when database migration fails
class DatabaseMigrationException extends DatabaseException {
  final int fromVersion;
  final int toVersion;

  DatabaseMigrationException(
    String message,
    this.fromVersion,
    this.toVersion, {
    Object? originalError,
    StackTrace? stackTrace,
  }) : super(
          message,
          originalError: originalError,
          stackTrace: stackTrace,
        );

  @override
  String toString() =>
      'DatabaseMigrationException: Failed to migrate from v$fromVersion to v$toVersion - $message';
}

/// Exception thrown when a database query fails
class DatabaseQueryException extends DatabaseException {
  final String query;

  DatabaseQueryException(
    String message,
    this.query, {
    Object? originalError,
    StackTrace? stackTrace,
  }) : super(
          message,
          originalError: originalError,
          stackTrace: stackTrace,
        );

  @override
  String toString() => 'DatabaseQueryException: $message (Query: $query)';
}

/// Exception thrown when data validation fails
class DatabaseValidationException extends DatabaseException {
  final Map<String, dynamic>? invalidData;

  DatabaseValidationException(
    String message, {
    this.invalidData,
    Object? originalError,
    StackTrace? stackTrace,
  }) : super(
          message,
          originalError: originalError,
          stackTrace: stackTrace,
        );

  @override
  String toString() {
    if (invalidData != null) {
      return 'DatabaseValidationException: $message (Data: $invalidData)';
    }
    return 'DatabaseValidationException: $message';
  }
}

/// Exception thrown when a foreign key constraint is violated
class DatabaseConstraintException extends DatabaseException {
  final String constraintName;

  DatabaseConstraintException(
    String message,
    this.constraintName, {
    Object? originalError,
    StackTrace? stackTrace,
  }) : super(
          message,
          originalError: originalError,
          stackTrace: stackTrace,
        );

  @override
  String toString() =>
      'DatabaseConstraintException: $message (Constraint: $constraintName)';
}

/// Exception thrown when a record is not found
class DatabaseRecordNotFoundException extends DatabaseException {
  final String tableName;
  final dynamic recordId;

  DatabaseRecordNotFoundException(
    this.tableName,
    this.recordId, {
    Object? originalError,
    StackTrace? stackTrace,
  }) : super(
          'Record not found in $tableName with ID: $recordId',
          originalError: originalError,
          stackTrace: stackTrace,
        );

  @override
  String toString() =>
      'DatabaseRecordNotFoundException: Record not found in $tableName with ID: $recordId';
}

/// Exception thrown when trying to insert a duplicate record
class DatabaseDuplicateException extends DatabaseException {
  final String tableName;
  final String fieldName;

  DatabaseDuplicateException(
    this.tableName,
    this.fieldName, {
    Object? originalError,
    StackTrace? stackTrace,
  }) : super(
          'Duplicate entry in $tableName for field $fieldName',
          originalError: originalError,
          stackTrace: stackTrace,
        );

  @override
  String toString() =>
      'DatabaseDuplicateException: Duplicate entry in $tableName for field $fieldName';
}

/// Exception thrown when database transaction fails
class DatabaseTransactionException extends DatabaseException {
  DatabaseTransactionException(
    String message, {
    Object? originalError,
    StackTrace? stackTrace,
  }) : super(
          message,
          originalError: originalError,
          stackTrace: stackTrace,
        );

  @override
  String toString() => 'DatabaseTransactionException: $message';
}

/// Exception thrown when database operation times out
class DatabaseTimeoutException extends DatabaseException {
  final Duration timeout;

  DatabaseTimeoutException(
    String message,
    this.timeout, {
    Object? originalError,
    StackTrace? stackTrace,
  }) : super(
          message,
          originalError: originalError,
          stackTrace: stackTrace,
        );

  @override
  String toString() =>
      'DatabaseTimeoutException: $message (Timeout: ${timeout.inSeconds}s)';
}
