import 'package:dartz/dartz.dart';
import 'package:cadastro_beneficios/core/errors/failures.dart';
import 'package:cadastro_beneficios/domain/entities/user.dart';
import 'package:cadastro_beneficios/domain/repositories/auth_repository.dart';

/// Caso de uso: Obter Usuário Atual
///
/// Responsável por buscar dados do usuário autenticado
class GetCurrentUserUseCase {
  final AuthRepository repository;

  GetCurrentUserUseCase(this.repository);

  /// Executa o caso de uso
  ///
  /// Returns: Either com Failure ou User
  Future<Either<Failure, User>> call() async {
    return await repository.getCurrentUser();
  }
}
