import 'package:dartz/dartz.dart';
import 'package:cadastro_beneficios/core/errors/failures.dart';
import 'package:cadastro_beneficios/domain/repositories/auth_repository.dart';

/// Caso de uso: Logout
///
/// Responsável por fazer logout do usuário, limpando tokens e sessão
class LogoutUseCase {
  final AuthRepository repository;

  LogoutUseCase(this.repository);

  /// Executa o caso de uso
  ///
  /// Returns: Either com Failure ou void
  Future<Either<Failure, void>> call() async {
    return await repository.logout();
  }
}
