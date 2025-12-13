import 'package:dartz/dartz.dart';
import 'package:cadastro_beneficios/core/errors/failures.dart';
import 'package:cadastro_beneficios/domain/entities/auth_token.dart';
import 'package:cadastro_beneficios/domain/repositories/auth_repository.dart';

/// Caso de uso: Login com Email e Senha
///
/// Responsável por autenticar usuário usando email e senha
class LoginWithEmailUseCase {
  final AuthRepository repository;

  LoginWithEmailUseCase(this.repository);

  /// Executa o caso de uso
  ///
  /// Params:
  /// - email: Email do usuário
  /// - password: Senha do usuário
  ///
  /// Returns: Either<Failure, AuthToken>
  Future<Either<Failure, AuthToken>> call({
    required String email,
    required String password,
  }) async {
    // Validações básicas
    if (email.isEmpty) {
      return const Left(ValidationFailure(
        message: 'Email é obrigatório',
        code: 'EMAIL_REQUIRED',
      ));
    }

    if (password.isEmpty) {
      return const Left(ValidationFailure(
        message: 'Senha é obrigatória',
        code: 'PASSWORD_REQUIRED',
      ));
    }

    // Validação de formato de email (RFC compliant - permite + no local-part)
    final emailRegex = RegExp(r'^[\w\-\.+]+@([\w\-]+\.)+[\w\-]{2,}$');
    if (!emailRegex.hasMatch(email)) {
      return const Left(ValidationFailure(
        message: 'Email inválido',
        code: 'INVALID_EMAIL',
      ));
    }

    // Chamar repositório
    return await repository.loginWithEmail(
      email: email,
      password: password,
    );
  }
}
