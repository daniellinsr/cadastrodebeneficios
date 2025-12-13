import 'package:equatable/equatable.dart';
import 'package:cadastro_beneficios/domain/entities/user.dart';

/// Estados de autenticação
///
/// Define todos os possíveis estados do AuthBloc
abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

/// Estado inicial - Verificando autenticação
class AuthInitial extends AuthState {
  const AuthInitial();
}

/// Estado: Carregando (processando login, logout, etc)
class AuthLoading extends AuthState {
  const AuthLoading();
}

/// Estado: Autenticado
class AuthAuthenticated extends AuthState {
  final User user;

  const AuthAuthenticated({
    required this.user,
  });

  @override
  List<Object?> get props => [user];
}

/// Estado: Não autenticado
class AuthUnauthenticated extends AuthState {
  const AuthUnauthenticated();
}

/// Estado: Erro
class AuthError extends AuthState {
  final String message;
  final String? code;

  const AuthError({
    required this.message,
    this.code,
  });

  @override
  List<Object?> get props => [message, code];
}

/// Estado: Senha recuperada (email enviado)
class AuthPasswordResetEmailSent extends AuthState {
  final String email;

  const AuthPasswordResetEmailSent({
    required this.email,
  });

  @override
  List<Object?> get props => [email];
}
