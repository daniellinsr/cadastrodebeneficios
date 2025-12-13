import 'package:dartz/dartz.dart';
import 'package:cadastro_beneficios/core/errors/failures.dart';
import 'package:cadastro_beneficios/domain/repositories/auth_repository.dart';

/// Caso de uso: Recuperar Senha
///
/// Responsável por enviar email de recuperação de senha
class ForgotPasswordUseCase {
  final AuthRepository repository;

  ForgotPasswordUseCase(this.repository);

  /// Executa o caso de uso
  ///
  /// Params:
  /// - email: Email do usuário que esqueceu a senha
  ///
  /// Returns: Either com Failure ou void
  Future<Either<Failure, void>> call({
    required String email,
  }) async {
    // Validações básicas
    if (email.isEmpty) {
      return const Left(ValidationFailure(
        message: 'Email é obrigatório',
        code: 'EMAIL_REQUIRED',
      ));
    }

    // Validação de formato de email
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(email)) {
      return const Left(ValidationFailure(
        message: 'Email inválido',
        code: 'INVALID_EMAIL',
      ));
    }

    return await repository.forgotPassword(email: email);
  }
}
