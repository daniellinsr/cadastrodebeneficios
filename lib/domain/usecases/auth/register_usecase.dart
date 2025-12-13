import 'package:dartz/dartz.dart';
import 'package:cadastro_beneficios/core/errors/failures.dart';
import 'package:cadastro_beneficios/domain/entities/auth_token.dart';
import 'package:cadastro_beneficios/domain/repositories/auth_repository.dart';

/// Caso de uso: Registrar novo usuário
///
/// Responsável por cadastrar um novo usuário no sistema
class RegisterUseCase {
  final AuthRepository repository;

  RegisterUseCase(this.repository);

  /// Executa o caso de uso
  ///
  /// Params:
  /// - name: Nome completo do usuário
  /// - email: Email do usuário
  /// - password: Senha do usuário
  /// - phoneNumber: Telefone do usuário
  /// - cpf: CPF do usuário (opcional)
  ///
  /// Returns: Either com Failure ou AuthToken
  Future<Either<Failure, AuthToken>> call({
    required String name,
    required String email,
    required String password,
    required String phoneNumber,
    String? cpf,
  }) async {
    // Validações básicas
    if (name.isEmpty) {
      return const Left(ValidationFailure(
        message: 'Nome é obrigatório',
        code: 'NAME_REQUIRED',
      ));
    }

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

    if (phoneNumber.isEmpty) {
      return const Left(ValidationFailure(
        message: 'Telefone é obrigatório',
        code: 'PHONE_REQUIRED',
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

    // Validação de senha forte
    if (password.length < 8) {
      return const Left(WeakPasswordFailure(
        code: 'PASSWORD_TOO_SHORT',
      ));
    }

    // Validação de nome (mínimo 3 caracteres)
    if (name.length < 3) {
      return const Left(ValidationFailure(
        message: 'Nome deve ter pelo menos 3 caracteres',
        code: 'NAME_TOO_SHORT',
      ));
    }

    // Chamar repositório
    return await repository.register(
      name: name,
      email: email,
      password: password,
      phoneNumber: phoneNumber,
      cpf: cpf,
    );
  }
}
