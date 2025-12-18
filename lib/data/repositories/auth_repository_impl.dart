import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:cadastro_beneficios/core/errors/failures.dart';
import 'package:cadastro_beneficios/domain/entities/user.dart';
import 'package:cadastro_beneficios/domain/entities/auth_token.dart';
import 'package:cadastro_beneficios/domain/repositories/auth_repository.dart';
import 'package:cadastro_beneficios/data/datasources/auth_remote_datasource.dart';
import 'package:cadastro_beneficios/data/datasources/auth_local_datasource.dart';
import 'package:cadastro_beneficios/core/services/token_service.dart';

/// Implementação do AuthRepository
///
/// Camada intermediária entre domain e data
class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final AuthLocalDataSource localDataSource;
  final TokenService tokenService;

  AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.tokenService,
  });

  @override
  Future<Either<Failure, AuthToken>> loginWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final tokenModel = await remoteDataSource.loginWithEmail(
        email: email,
        password: password,
      );

      return Right(tokenModel.toEntity());
    } on DioException catch (e) {
      return Left(_handleDioError(e));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, AuthToken>> loginWithGoogle({required String idToken}) async {
    try {
      final tokenModel = await remoteDataSource.loginWithGoogle(idToken: idToken);
      return Right(tokenModel.toEntity());
    } on DioException catch (e) {
      return Left(_handleDioError(e));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, AuthToken>> register({
    required String name,
    required String email,
    required String password,
    required String phoneNumber,
    String? cpf,
    String? birthDate,
    String? cep,
    String? logradouro,
    String? numero,
    String? complemento,
    String? bairro,
    String? cidade,
    String? estado,
  }) async {
    try {
      final tokenModel = await remoteDataSource.register(
        name: name,
        email: email,
        password: password,
        phoneNumber: phoneNumber,
        cpf: cpf,
        birthDate: birthDate,
        cep: cep,
        logradouro: logradouro,
        numero: numero,
        complemento: complemento,
        bairro: bairro,
        cidade: cidade,
        estado: estado,
      );

      return Right(tokenModel.toEntity());
    } on DioException catch (e) {
      return Left(_handleDioError(e));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> logout() async {
    try {
      await remoteDataSource.logout();
      await localDataSource.clearCache();
      return const Right(null);
    } on DioException catch (e) {
      return Left(_handleDioError(e));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> forgotPassword({
    required String email,
  }) async {
    try {
      await remoteDataSource.forgotPassword(email: email);
      return const Right(null);
    } on DioException catch (e) {
      return Left(_handleDioError(e));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> resetPassword({
    required String token,
    required String newPassword,
  }) async {
    try {
      await remoteDataSource.resetPassword(
        token: token,
        newPassword: newPassword,
      );
      return const Right(null);
    } on DioException catch (e) {
      return Left(_handleDioError(e));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, AuthToken>> refreshToken({
    required String refreshToken,
  }) async {
    try {
      final tokenModel = await remoteDataSource.refreshToken(
        refreshToken: refreshToken,
      );
      return Right(tokenModel.toEntity());
    } on DioException catch (e) {
      return Left(_handleDioError(e));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, User>> getCurrentUser() async {
    try {
      // Tentar buscar do cache primeiro
      final cachedUser = await localDataSource.getCachedUser();

      if (cachedUser != null) {
        return Right(cachedUser.toEntity());
      }

      // Se não houver cache, buscar da API
      final userModel = await remoteDataSource.getCurrentUser();

      // Salvar no cache
      await localDataSource.cacheUser(userModel);

      return Right(userModel.toEntity());
    } on DioException catch (e) {
      return Left(_handleDioError(e));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> isAuthenticated() async {
    try {
      final hasToken = await tokenService.hasToken();
      return Right(hasToken);
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> sendVerificationCode({
    required String phoneNumber,
    required VerificationMethod method,
  }) async {
    try {
      await remoteDataSource.sendVerificationCode(
        phoneNumber: phoneNumber,
        method: method,
      );
      return const Right(null);
    } on DioException catch (e) {
      return Left(_handleDioError(e));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> verifyCode({
    required String phoneNumber,
    required String code,
  }) async {
    try {
      await remoteDataSource.verifyCode(
        phoneNumber: phoneNumber,
        code: code,
      );
      return const Right(null);
    } on DioException catch (e) {
      return Left(_handleDioError(e));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, User>> completeProfile({
    required String cpf,
    required String phoneNumber,
    required String cep,
    required String street,
    required String number,
    String? complement,
    required String neighborhood,
    required String city,
    required String state,
    String? birthDate,
  }) async {
    try {
      final userModel = await remoteDataSource.completeProfile(
        cpf: cpf,
        phoneNumber: phoneNumber,
        cep: cep,
        street: street,
        number: number,
        complement: complement,
        neighborhood: neighborhood,
        city: city,
        state: state,
        birthDate: birthDate,
      );

      // CRÍTICO: Atualizar cache com o usuário atualizado
      // Isso garante que getCurrentUser() retorne o usuário com perfil completo
      await localDataSource.cacheUser(userModel);

      return Right(userModel.toEntity());
    } on DioException catch (e) {
      return Left(_handleDioError(e));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> sendVerificationCodeV2(String type) async {
    try {
      await remoteDataSource.sendVerificationCodeV2(type);
      return const Right(null);
    } on DioException catch (e) {
      return Left(_handleDioError(e));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> verifyCodeV2(String type, String code) async {
    try {
      await remoteDataSource.verifyCodeV2(type, code);
      return const Right(null);
    } on DioException catch (e) {
      return Left(_handleDioError(e));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, Map<String, bool>>> getVerificationStatus() async {
    try {
      final status = await remoteDataSource.getVerificationStatus();
      return Right(status);
    } on DioException catch (e) {
      return Left(_handleDioError(e));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  /// Tratamento centralizado de erros Dio
  Failure _handleDioError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return const ConnectionFailure(
          message: 'Tempo de conexão esgotado. Verifique sua internet.',
        );

      case DioExceptionType.badResponse:
        return _handleResponseError(error.response);

      case DioExceptionType.cancel:
        return const UnknownFailure(message: 'Requisição cancelada.');

      case DioExceptionType.connectionError:
        return const ConnectionFailure(
          message: 'Sem conexão com a internet.',
        );

      case DioExceptionType.badCertificate:
        return const ServerFailure(
          message: 'Certificado SSL inválido.',
        );

      case DioExceptionType.unknown:
        return const UnknownFailure(
          message: 'Erro desconhecido. Tente novamente.',
        );
    }
  }

  /// Tratamento de erros baseado no status code
  Failure _handleResponseError(Response? response) {
    if (response == null) {
      return const ServerFailure(message: 'Servidor não respondeu.');
    }

    final statusCode = response.statusCode;
    final data = response.data;

    // Extrair mensagem de erro se disponível
    String? errorMessage;
    String? errorCode;

    if (data is Map<String, dynamic>) {
      errorMessage = data['message'] as String?;
      errorCode = data['code'] as String?;
    }

    switch (statusCode) {
      case 400:
        // Bad Request - Validação
        if (errorCode == 'EMAIL_ALREADY_EXISTS') {
          return EmailAlreadyExistsFailure(
            message: errorMessage ?? 'Email já cadastrado.',
          );
        } else if (errorCode == 'CPF_ALREADY_EXISTS') {
          return CpfAlreadyExistsFailure(
            message: errorMessage ?? 'CPF já cadastrado.',
          );
        } else if (errorCode == 'PHONE_ALREADY_EXISTS') {
          return PhoneAlreadyExistsFailure(
            message: errorMessage ?? 'Telefone já cadastrado.',
          );
        } else if (errorCode == 'WEAK_PASSWORD') {
          return WeakPasswordFailure(
            message: errorMessage ?? 'Senha muito fraca.',
          );
        }
        return ValidationFailure(
          message: errorMessage ?? 'Dados inválidos.',
          code: errorCode,
        );

      case 401:
        // Unauthorized - Credenciais inválidas ou token expirado
        if (errorCode == 'TOKEN_EXPIRED') {
          return TokenExpiredFailure(
            message: errorMessage ?? 'Sessão expirada.',
          );
        }
        return AuthenticationFailure(
          message: errorMessage ?? 'Credenciais inválidas.',
          code: errorCode,
        );

      case 403:
        // Forbidden - Sem permissão
        return AuthorizationFailure(
          message: errorMessage ?? 'Sem permissão.',
          code: errorCode,
        );

      case 404:
        // Not Found
        return NotFoundFailure(
          message: errorMessage ?? 'Recurso não encontrado.',
          code: errorCode,
        );

      case 422:
        // Unprocessable Entity - Código de verificação inválido
        if (errorCode == 'INVALID_VERIFICATION_CODE') {
          return InvalidVerificationCodeFailure(
            message: errorMessage ?? 'Código de verificação inválido.',
          );
        }
        return ValidationFailure(
          message: errorMessage ?? 'Dados inválidos.',
          code: errorCode,
        );

      case 500:
      case 502:
      case 503:
      case 504:
        // Server Errors
        return ServerFailure(
          message: errorMessage ?? 'Erro no servidor. Tente novamente mais tarde.',
          code: errorCode,
        );

      default:
        return UnknownFailure(
          message: errorMessage ?? 'Erro desconhecido.',
          code: errorCode,
        );
    }
  }
}
