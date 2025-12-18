import 'package:equatable/equatable.dart';
import 'package:cadastro_beneficios/domain/entities/user.dart';

/// Eventos de autenticação
///
/// Define todos os eventos que podem ser disparados para o AuthBloc
abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

/// Evento: Verificar autenticação inicial
///
/// Disparado ao iniciar o app para verificar se existe sessão ativa
class AuthCheckRequested extends AuthEvent {
  const AuthCheckRequested();
}

/// Evento: Login com email e senha
class AuthLoginWithEmailRequested extends AuthEvent {
  final String email;
  final String password;

  const AuthLoginWithEmailRequested({
    required this.email,
    required this.password,
  });

  @override
  List<Object?> get props => [email, password];
}

/// Evento: Login com Google
class AuthLoginWithGoogleRequested extends AuthEvent {
  const AuthLoginWithGoogleRequested();
}

/// Evento: Registro de novo usuário
class AuthRegisterRequested extends AuthEvent {
  final String name;
  final String email;
  final String password;
  final String phoneNumber;
  final String? cpf;

  const AuthRegisterRequested({
    required this.name,
    required this.email,
    required this.password,
    required this.phoneNumber,
    this.cpf,
  });

  @override
  List<Object?> get props => [name, email, password, phoneNumber, cpf];
}

/// Evento: Logout
class AuthLogoutRequested extends AuthEvent {
  const AuthLogoutRequested();
}

/// Evento: Recuperar senha
class AuthForgotPasswordRequested extends AuthEvent {
  final String email;

  const AuthForgotPasswordRequested({
    required this.email,
  });

  @override
  List<Object?> get props => [email];
}

/// Evento: Atualizar dados do usuário
class AuthUserUpdated extends AuthEvent {
  const AuthUserUpdated();
}

/// Evento: Definir usuário diretamente (sem buscar do backend)
/// Usado após operações que já retornam o usuário atualizado (ex: completeProfile)
class AuthUserSet extends AuthEvent {
  final User user;

  const AuthUserSet(this.user);

  @override
  List<Object?> get props => [user];
}
