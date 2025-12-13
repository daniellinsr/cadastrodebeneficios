/// Exceções que ocorrem durante operações do sistema
///
/// Exceções são lançadas nas camadas de Data/Infrastructure
/// e convertidas em Failures na camada de Domain

/// Exceção base
class AppException implements Exception {
  final String message;
  final String? code;

  const AppException({
    required this.message,
    this.code,
  });

  @override
  String toString() => 'AppException: $message${code != null ? ' (Code: $code)' : ''}';
}

/// Exceção de servidor (5xx)
class ServerException extends AppException {
  const ServerException({
    required String message,
    String? code,
  }) : super(message: message, code: code);
}

/// Exceção de autenticação (401)
class AuthException extends AppException {
  const AuthException({
    required String message,
    String? code,
  }) : super(message: message, code: code);
}

/// Exceção de autorização (403)
class AuthorizationException extends AppException {
  const AuthorizationException({
    required String message,
    String? code,
  }) : super(message: message, code: code);
}

/// Exceção de não encontrado (404)
class NotFoundException extends AppException {
  const NotFoundException({
    required String message,
    String? code,
  }) : super(message: message, code: code);
}

/// Exceção de validação (400)
class ValidationException extends AppException {
  final Map<String, List<String>>? errors;

  const ValidationException({
    required String message,
    String? code,
    this.errors,
  }) : super(message: message, code: code);
}

/// Exceção de cache/storage local
class CacheException extends AppException {
  const CacheException({
    required String message,
    String? code,
  }) : super(message: message, code: code);
}

/// Exceção de formato/parsing
class FormatException extends AppException {
  const FormatException({
    required String message,
    String? code,
  }) : super(message: message, code: code);
}

/// Exceção de rede/conexão
class NetworkException extends AppException {
  const NetworkException({
    required String message,
    String? code,
  }) : super(message: message, code: code);
}
