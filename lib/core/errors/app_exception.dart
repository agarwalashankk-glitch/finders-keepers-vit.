class AppException implements Exception {
  final String message;
  final String? code;
  final dynamic details;

  const AppException(this.message, {this.code, this.details});

  @override
  String toString() => message;
}

class NetworkException extends AppException {
  const NetworkException([String message = 'Network connection unavailable. Please check your internet.'])
      : super(message, code: 'NETWORK_ERROR');
}

class AuthException extends AppException {
  const AuthException(String message, {String? code}) : super(message, code: code);
}

class ValidationException extends AppException {
  const ValidationException(String message) : super(message, code: 'VALIDATION_ERROR');
}

class StateTransitionException extends AppException {
  const StateTransitionException(String message) : super(message, code: 'INVALID_STATE_TRANSITION');
}

class PermissionException extends AppException {
  const PermissionException([String message = 'You do not have permission to perform this action.'])
      : super(message, code: 'PERMISSION_DENIED');
}

class StorageUploadException extends AppException {
  const StorageUploadException(String message, {String? code})
      : super(message, code: code ?? 'STORAGE_ERROR');
}
