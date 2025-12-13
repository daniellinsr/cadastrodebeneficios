import 'package:equatable/equatable.dart';

/// Classe base abstrata para todos os tipos de falhas
///
/// Usar Equatable para facilitar comparação e testes
abstract class Failure extends Equatable {
  final String message;
  final String? code;

  const Failure({
    required this.message,
    this.code,
  });

  @override
  List<Object?> get props => [message, code];
}

// ===== Falhas de Rede =====

/// Falha de servidor (5xx)
class ServerFailure extends Failure {
  const ServerFailure({
    required String message,
    String? code,
  }) : super(message: message, code: code);
}

/// Falha de conexão (sem internet, timeout, etc)
class ConnectionFailure extends Failure {
  const ConnectionFailure({
    String message = 'Erro de conexão. Verifique sua internet.',
    String? code,
  }) : super(message: message, code: code);
}

/// Falha de autenticação (401)
class AuthenticationFailure extends Failure {
  const AuthenticationFailure({
    String message = 'Credenciais inválidas. Verifique email e senha.',
    String? code,
  }) : super(message: message, code: code);
}

/// Falha de autorização (403)
class AuthorizationFailure extends Failure {
  const AuthorizationFailure({
    String message = 'Você não tem permissão para acessar este recurso.',
    String? code,
  }) : super(message: message, code: code);
}

/// Falha de não encontrado (404)
class NotFoundFailure extends Failure {
  const NotFoundFailure({
    String message = 'Recurso não encontrado.',
    String? code,
  }) : super(message: message, code: code);
}

/// Falha de validação (400)
class ValidationFailure extends Failure {
  final Map<String, List<String>>? errors;

  const ValidationFailure({
    String message = 'Dados inválidos. Verifique as informações.',
    String? code,
    this.errors,
  }) : super(message: message, code: code);

  @override
  List<Object?> get props => [message, code, errors];
}

// ===== Falhas Locais =====

/// Falha de cache/armazenamento local
class CacheFailure extends Failure {
  const CacheFailure({
    String message = 'Erro ao acessar dados locais.',
    String? code,
  }) : super(message: message, code: code);
}

/// Falha de formato/parsing de dados
class FormatFailure extends Failure {
  const FormatFailure({
    String message = 'Formato de dados inválido.',
    String? code,
  }) : super(message: message, code: code);
}

// ===== Falhas de Negócio =====

/// Falha de regra de negócio
class BusinessFailure extends Failure {
  const BusinessFailure({
    required String message,
    String? code,
  }) : super(message: message, code: code);
}

/// Falha genérica (quando não se encaixa em nenhuma categoria)
class UnknownFailure extends Failure {
  const UnknownFailure({
    String message = 'Erro desconhecido. Tente novamente.',
    String? code,
  }) : super(message: message, code: code);
}

// ===== Falhas Específicas de Autenticação =====

/// Token expirado
class TokenExpiredFailure extends Failure {
  const TokenExpiredFailure({
    String message = 'Sessão expirada. Faça login novamente.',
    String? code,
  }) : super(message: message, code: code);
}

/// Email já cadastrado
class EmailAlreadyExistsFailure extends Failure {
  const EmailAlreadyExistsFailure({
    String message = 'Este email já está cadastrado.',
    String? code,
  }) : super(message: message, code: code);
}

/// CPF já cadastrado
class CpfAlreadyExistsFailure extends Failure {
  const CpfAlreadyExistsFailure({
    String message = 'Este CPF já está cadastrado.',
    String? code,
  }) : super(message: message, code: code);
}

/// Telefone já cadastrado
class PhoneAlreadyExistsFailure extends Failure {
  const PhoneAlreadyExistsFailure({
    String message = 'Este telefone já está cadastrado.',
    String? code,
  }) : super(message: message, code: code);
}

/// Código de verificação inválido
class InvalidVerificationCodeFailure extends Failure {
  const InvalidVerificationCodeFailure({
    String message = 'Código de verificação inválido ou expirado.',
    String? code,
  }) : super(message: message, code: code);
}

/// Senha fraca
class WeakPasswordFailure extends Failure {
  const WeakPasswordFailure({
    String message = 'Senha muito fraca. Use pelo menos 8 caracteres com letras e números.',
    String? code,
  }) : super(message: message, code: code);
}
