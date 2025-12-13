import 'package:dartz/dartz.dart';
import 'package:cadastro_beneficios/core/errors/failures.dart';
import 'package:cadastro_beneficios/domain/entities/user.dart';
import 'package:cadastro_beneficios/domain/entities/auth_token.dart';

/// Interface do repositório de autenticação
///
/// Define os contratos que devem ser implementados pela camada de dados
/// Usa Either do pacote dartz para tratamento de erros funcionais
abstract class AuthRepository {
  /// Login com email e senha
  ///
  /// Returns: Right(AuthToken) em caso de sucesso
  /// Returns: Left(Failure) em caso de erro
  Future<Either<Failure, AuthToken>> loginWithEmail({
    required String email,
    required String password,
  });

  /// Login com Google OAuth
  ///
  /// [idToken] - ID Token obtido do Google Sign In
  /// Returns: Right(AuthToken) em caso de sucesso
  /// Returns: Left(Failure) em caso de erro
  Future<Either<Failure, AuthToken>> loginWithGoogle({required String idToken});

  /// Registro de novo usuário
  ///
  /// Returns: Right(AuthToken) em caso de sucesso
  /// Returns: Left(Failure) em caso de erro
  Future<Either<Failure, AuthToken>> register({
    required String name,
    required String email,
    required String password,
    required String phoneNumber,
    String? cpf,
  });

  /// Logout do usuário
  ///
  /// Returns: Right(void) em caso de sucesso
  /// Returns: Left(Failure) em caso de erro
  Future<Either<Failure, void>> logout();

  /// Recuperar senha via email
  ///
  /// Returns: Right(void) em caso de sucesso
  /// Returns: Left(Failure) em caso de erro
  Future<Either<Failure, void>> forgotPassword({
    required String email,
  });

  /// Redefinir senha com token de recuperação
  ///
  /// Returns: Right(void) em caso de sucesso
  /// Returns: Left(Failure) em caso de erro
  Future<Either<Failure, void>> resetPassword({
    required String token,
    required String newPassword,
  });

  /// Atualizar access token usando refresh token
  ///
  /// Returns: Right(AuthToken) em caso de sucesso
  /// Returns: Left(Failure) em caso de erro
  Future<Either<Failure, AuthToken>> refreshToken({
    required String refreshToken,
  });

  /// Obter dados do usuário autenticado
  ///
  /// Returns: Right(User) em caso de sucesso
  /// Returns: Left(Failure) em caso de erro
  Future<Either<Failure, User>> getCurrentUser();

  /// Verificar se o usuário está autenticado
  ///
  /// Returns: Right(bool) em caso de sucesso
  /// Returns: Left(Failure) em caso de erro
  Future<Either<Failure, bool>> isAuthenticated();

  /// Enviar código de verificação por SMS/WhatsApp
  ///
  /// Returns: Right(void) em caso de sucesso
  /// Returns: Left(Failure) em caso de erro
  Future<Either<Failure, void>> sendVerificationCode({
    required String phoneNumber,
    required VerificationMethod method,
  });

  /// Verificar código de verificação
  ///
  /// Returns: Right(void) em caso de sucesso
  /// Returns: Left(Failure) em caso de erro
  Future<Either<Failure, void>> verifyCode({
    required String phoneNumber,
    required String code,
  });
}

/// Método de verificação (SMS ou WhatsApp)
enum VerificationMethod {
  sms,
  whatsapp,
}
