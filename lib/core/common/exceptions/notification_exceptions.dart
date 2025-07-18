// Base Exception for all notification-related errors
abstract class NotificationException implements Exception {
  final String message;
  final String? code;
  final dynamic originalError;

  const NotificationException(
      this.message, {
        this.code,
        this.originalError,
      });

  @override
  String toString() => 'NotificationException: $message';
}

// Permission related exceptions
class NotificationPermissionException extends NotificationException {
  const NotificationPermissionException(
      super.message, {
        super.code = 'PERMISSION_DENIED',
        super.originalError,
      });
}

// Scheduling related exceptions
class NotificationSchedulingException extends NotificationException {
  const NotificationSchedulingException(
      super.message, {
        super.code = 'SCHEDULING_FAILED',
        super.originalError,
      });
}

// Storage related exceptions
class NotificationStorageException extends NotificationException {
  const NotificationStorageException(
      super.message, {
        super.code = 'STORAGE_ERROR',
        super.originalError,
      });
}

// Validation related exceptions
class NotificationValidationException extends NotificationException {
  const NotificationValidationException(
      super.message, {
        super.code = 'VALIDATION_ERROR',
        super.originalError,
      });
}

// Service initialization exceptions
class NotificationServiceException extends NotificationException {
  const NotificationServiceException(
      super.message, {
        super.code = 'SERVICE_ERROR',
        super.originalError,
      });
}

// Network related exceptions
class NotificationNetworkException extends NotificationException {
  const NotificationNetworkException(
      super.message, {
        super.code = 'NETWORK_ERROR',
        super.originalError,
      });
}

// Parsing related exceptions
class NotificationParsingException extends NotificationException {
  const NotificationParsingException(
      super.message, {
        super.code = 'PARSING_ERROR',
        super.originalError,
      });
}

// Extension for easy error handling
extension NotificationExceptionExtension on NotificationException {
  bool get isPermissionError => this is NotificationPermissionException;
  bool get isSchedulingError => this is NotificationSchedulingException;
  bool get isStorageError => this is NotificationStorageException;
  bool get isValidationError => this is NotificationValidationException;
  bool get isServiceError => this is NotificationServiceException;
  bool get isNetworkError => this is NotificationNetworkException;
  bool get isParsingError => this is NotificationParsingException;
}