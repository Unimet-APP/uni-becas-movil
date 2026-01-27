class ApiException implements Exception {
  final String message;
  ApiException(this.message);

  @override
  String toString() => message;
}

class ValidationException extends ApiException {
  ValidationException(super.message);
}

class UnauthorizedException extends ApiException {
  UnauthorizedException()
      : super('Sesión expirada. Inicia sesión nuevamente.');
}

class ForbiddenException extends ApiException {
  ForbiddenException(super.message);
}

class NotFoundException extends ApiException {
  NotFoundException(super.message);
}

class ServerException extends ApiException {
  ServerException(super.message);
}

class NetworkException extends ApiException {
  NetworkException(super.message);
}
