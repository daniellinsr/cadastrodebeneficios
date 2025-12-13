import 'package:dartz/dartz.dart';
import 'package:cadastro_beneficios/core/errors/failures.dart';
import 'package:cadastro_beneficios/domain/entities/auth_token.dart';
import 'package:cadastro_beneficios/domain/repositories/auth_repository.dart';
import 'package:cadastro_beneficios/core/services/google_auth_service.dart';

/// Caso de uso: Login com Google OAuth
///
/// Responsável por autenticar usuário usando conta Google
class LoginWithGoogleUseCase {
  final AuthRepository repository;
  final GoogleAuthService googleAuthService;

  LoginWithGoogleUseCase(this.repository, this.googleAuthService);

  /// Executa o caso de uso
  ///
  /// 1. Faz login com Google (obtém ID token)
  /// 2. Envia ID token para o backend
  /// 3. Recebe AuthToken do backend
  ///
  /// Returns: Either<Failure, AuthToken>
  Future<Either<Failure, AuthToken>> call() async {
    try {
      // 1. Obter ID token do Google
      final String idToken = await googleAuthService.signIn();

      // 2. Enviar ID token para o backend e receber AuthToken
      return await repository.loginWithGoogle(idToken: idToken);
    } catch (e) {
      // Converter exceções em Failures
      return Left(AuthenticationFailure(
        message: e.toString(),
        code: 'GOOGLE_LOGIN_ERROR',
      ));
    }
  }
}
