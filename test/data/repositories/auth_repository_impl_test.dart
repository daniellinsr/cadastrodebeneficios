import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:dio/dio.dart';
import 'package:cadastro_beneficios/core/errors/failures.dart';
import 'package:cadastro_beneficios/core/services/token_service.dart';
import 'package:cadastro_beneficios/data/datasources/auth_remote_datasource.dart';
import 'package:cadastro_beneficios/data/datasources/auth_local_datasource.dart';
import 'package:cadastro_beneficios/data/repositories/auth_repository_impl.dart';
import 'package:cadastro_beneficios/data/models/auth_token_model.dart';
import 'package:cadastro_beneficios/data/models/user_model.dart';

import 'auth_repository_impl_test.mocks.dart';

@GenerateMocks([
  AuthRemoteDataSource,
  AuthLocalDataSource,
  TokenService,
])
void main() {
  late AuthRepositoryImpl repository;
  late MockAuthRemoteDataSource mockRemoteDataSource;
  late MockAuthLocalDataSource mockLocalDataSource;
  late MockTokenService mockTokenService;

  setUp(() {
    mockRemoteDataSource = MockAuthRemoteDataSource();
    mockLocalDataSource = MockAuthLocalDataSource();
    mockTokenService = MockTokenService();
    repository = AuthRepositoryImpl(
      remoteDataSource: mockRemoteDataSource,
      localDataSource: mockLocalDataSource,
      tokenService: mockTokenService,
    );
  });

  final tAuthTokenModel = AuthTokenModel(
    accessToken: 'access_token_123',
    refreshToken: 'refresh_token_456',
    expiresAt: DateTime(2024, 12, 31),
  );

  final tUserModel = UserModel(
    id: '123',
    name: 'João Silva',
    email: 'joao@exemplo.com',
    role: 'beneficiary',
    createdAt: DateTime(2024, 1, 1),
  );

  group('AuthRepositoryImpl - loginWithEmail', () {
    test('deve retornar AuthToken quando login for bem-sucedido', () async {
      // Arrange
      when(mockRemoteDataSource.loginWithEmail(
        email: anyNamed('email'),
        password: anyNamed('password'),
      )).thenAnswer((_) async => tAuthTokenModel);

      // Act
      final result = await repository.loginWithEmail(
        email: 'joao@exemplo.com',
        password: 'senha123',
      );

      // Assert
      expect(result.isRight(), true);
      result.fold(
        (failure) => fail('Should return Right'),
        (token) {
          expect(token.accessToken, 'access_token_123');
          expect(token.refreshToken, 'refresh_token_456');
        },
      );
      verify(mockRemoteDataSource.loginWithEmail(
        email: 'joao@exemplo.com',
        password: 'senha123',
      ));
    });

    test('deve retornar ConnectionFailure quando houver timeout', () async {
      // Arrange
      when(mockRemoteDataSource.loginWithEmail(
        email: anyNamed('email'),
        password: anyNamed('password'),
      )).thenThrow(
        DioException(
          type: DioExceptionType.connectionTimeout,
          requestOptions: RequestOptions(path: '/auth/login'),
        ),
      );

      // Act
      final result = await repository.loginWithEmail(
        email: 'joao@exemplo.com',
        password: 'senha123',
      );

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (failure) {
          expect(failure, isA<ConnectionFailure>());
          expect(failure.message,
              'Tempo de conexão esgotado. Verifique sua internet.');
        },
        (_) => fail('Should return Left'),
      );
    });

    test('deve retornar AuthenticationFailure quando credenciais forem inválidas',
        () async {
      // Arrange
      when(mockRemoteDataSource.loginWithEmail(
        email: anyNamed('email'),
        password: anyNamed('password'),
      )).thenThrow(
        DioException(
          type: DioExceptionType.badResponse,
          response: Response(
            statusCode: 401,
            data: {
              'message': 'Credenciais inválidas',
              'code': 'INVALID_CREDENTIALS',
            },
            requestOptions: RequestOptions(path: '/auth/login'),
          ),
          requestOptions: RequestOptions(path: '/auth/login'),
        ),
      );

      // Act
      final result = await repository.loginWithEmail(
        email: 'joao@exemplo.com',
        password: 'senha_errada',
      );

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (failure) {
          expect(failure, isA<AuthenticationFailure>());
          expect(failure.message, 'Credenciais inválidas');
        },
        (_) => fail('Should return Left'),
      );
    });
  });

  group('AuthRepositoryImpl - register', () {
    test('deve retornar AuthToken quando registro for bem-sucedido', () async {
      // Arrange
      when(mockRemoteDataSource.register(
        name: anyNamed('name'),
        email: anyNamed('email'),
        password: anyNamed('password'),
        phoneNumber: anyNamed('phoneNumber'),
        cpf: anyNamed('cpf'),
      )).thenAnswer((_) async => tAuthTokenModel);

      // Act
      final result = await repository.register(
        name: 'João Silva',
        email: 'joao@exemplo.com',
        password: 'senha123456',
        phoneNumber: '11987654321',
      );

      // Assert
      expect(result.isRight(), true);
      verify(mockRemoteDataSource.register(
        name: 'João Silva',
        email: 'joao@exemplo.com',
        password: 'senha123456',
        phoneNumber: '11987654321',
        cpf: null,
      ));
    });

    test('deve retornar EmailAlreadyExistsFailure quando email já existir',
        () async {
      // Arrange
      when(mockRemoteDataSource.register(
        name: anyNamed('name'),
        email: anyNamed('email'),
        password: anyNamed('password'),
        phoneNumber: anyNamed('phoneNumber'),
        cpf: anyNamed('cpf'),
      )).thenThrow(
        DioException(
          type: DioExceptionType.badResponse,
          response: Response(
            statusCode: 400,
            data: {
              'message': 'Email já cadastrado',
              'code': 'EMAIL_ALREADY_EXISTS',
            },
            requestOptions: RequestOptions(path: '/auth/register'),
          ),
          requestOptions: RequestOptions(path: '/auth/register'),
        ),
      );

      // Act
      final result = await repository.register(
        name: 'João Silva',
        email: 'joao@exemplo.com',
        password: 'senha123456',
        phoneNumber: '11987654321',
      );

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (failure) {
          expect(failure, isA<EmailAlreadyExistsFailure>());
          expect(failure.message, 'Email já cadastrado');
        },
        (_) => fail('Should return Left'),
      );
    });
  });

  group('AuthRepositoryImpl - getCurrentUser', () {
    test('deve retornar User do cache quando disponível', () async {
      // Arrange
      when(mockLocalDataSource.getCachedUser())
          .thenAnswer((_) async => tUserModel);

      // Act
      final result = await repository.getCurrentUser();

      // Assert
      expect(result.isRight(), true);
      result.fold(
        (failure) => fail('Should return Right'),
        (user) {
          expect(user.id, '123');
          expect(user.name, 'João Silva');
        },
      );
      verify(mockLocalDataSource.getCachedUser());
      verifyNever(mockRemoteDataSource.getCurrentUser());
    });

    test('deve buscar User da API quando cache estiver vazio', () async {
      // Arrange
      when(mockLocalDataSource.getCachedUser()).thenAnswer((_) async => null);
      when(mockRemoteDataSource.getCurrentUser())
          .thenAnswer((_) async => tUserModel);
      when(mockLocalDataSource.cacheUser(any)).thenAnswer((_) async => {});

      // Act
      final result = await repository.getCurrentUser();

      // Assert
      expect(result.isRight(), true);
      verify(mockLocalDataSource.getCachedUser());
      verify(mockRemoteDataSource.getCurrentUser());
      verify(mockLocalDataSource.cacheUser(tUserModel));
    });

    test('deve retornar ServerFailure quando servidor falhar', () async {
      // Arrange
      when(mockLocalDataSource.getCachedUser()).thenAnswer((_) async => null);
      when(mockRemoteDataSource.getCurrentUser()).thenThrow(
        DioException(
          type: DioExceptionType.badResponse,
          response: Response(
            statusCode: 500,
            data: {'message': 'Erro no servidor'},
            requestOptions: RequestOptions(path: '/auth/me'),
          ),
          requestOptions: RequestOptions(path: '/auth/me'),
        ),
      );

      // Act
      final result = await repository.getCurrentUser();

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (failure) {
          expect(failure, isA<ServerFailure>());
        },
        (_) => fail('Should return Left'),
      );
    });
  });

  group('AuthRepositoryImpl - logout', () {
    test('deve limpar cache ao fazer logout', () async {
      // Arrange
      when(mockRemoteDataSource.logout()).thenAnswer((_) async => {});
      when(mockLocalDataSource.clearCache()).thenAnswer((_) async => {});

      // Act
      final result = await repository.logout();

      // Assert
      expect(result.isRight(), true);
      verify(mockRemoteDataSource.logout());
      verify(mockLocalDataSource.clearCache());
    });

    test('deve retornar ConnectionFailure quando não houver conexão', () async {
      // Arrange
      when(mockRemoteDataSource.logout()).thenThrow(
        DioException(
          type: DioExceptionType.connectionError,
          requestOptions: RequestOptions(path: '/auth/logout'),
        ),
      );

      // Act
      final result = await repository.logout();

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (failure) {
          expect(failure, isA<ConnectionFailure>());
          expect(failure.message, 'Sem conexão com a internet.');
        },
        (_) => fail('Should return Left'),
      );
    });
  });

  group('AuthRepositoryImpl - isAuthenticated', () {
    test('deve retornar true quando houver token', () async {
      // Arrange
      when(mockTokenService.hasToken()).thenAnswer((_) async => true);

      // Act
      final result = await repository.isAuthenticated();

      // Assert
      expect(result, const Right(true));
      verify(mockTokenService.hasToken());
    });

    test('deve retornar false quando não houver token', () async {
      // Arrange
      when(mockTokenService.hasToken()).thenAnswer((_) async => false);

      // Act
      final result = await repository.isAuthenticated();

      // Assert
      expect(result, const Right(false));
    });
  });

  group('AuthRepositoryImpl - Error Handling', () {
    test('deve retornar UnknownFailure para exceções não tratadas', () async {
      // Arrange
      when(mockRemoteDataSource.loginWithEmail(
        email: anyNamed('email'),
        password: anyNamed('password'),
      )).thenThrow(Exception('Unexpected error'));

      // Act
      final result = await repository.loginWithEmail(
        email: 'joao@exemplo.com',
        password: 'senha123',
      );

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (failure) {
          expect(failure, isA<UnknownFailure>());
        },
        (_) => fail('Should return Left'),
      );
    });

    test('deve mapear diferentes status codes para Failures corretos',
        () async {
      // Test 404
      when(mockRemoteDataSource.getCurrentUser()).thenThrow(
        DioException(
          type: DioExceptionType.badResponse,
          response: Response(
            statusCode: 404,
            data: {'message': 'Not found'},
            requestOptions: RequestOptions(path: '/auth/me'),
          ),
          requestOptions: RequestOptions(path: '/auth/me'),
        ),
      );
      when(mockLocalDataSource.getCachedUser()).thenAnswer((_) async => null);

      final result = await repository.getCurrentUser();

      expect(result.isLeft(), true);
      result.fold(
        (failure) => expect(failure, isA<NotFoundFailure>()),
        (_) => fail('Should return Left'),
      );
    });
  });
}
