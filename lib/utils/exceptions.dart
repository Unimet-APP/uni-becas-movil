class ApiException implements Exception {
  final String message;
  ApiException(this.message);

  @override
  String toString() => message;
}

class ValidationException extends ApiException {
  ValidationException(String message) : super(message);
}

class UnauthorizedException extends ApiException {
  UnauthorizedException()
      : super('Sesión expirada. Inicia sesión nuevamente.');
}

class ForbiddenException extends ApiException {
  ForbiddenException(String message) : super(message);
}

class NotFoundException extends ApiException {
  NotFoundException(String message) : super(message);
}

class ServerException extends ApiException {
  ServerException(String message) : super(message);
}

class NetworkException extends ApiException {
  NetworkException(String message) : super(message);
}
