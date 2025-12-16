import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'package:cadastro_beneficios/core/network/dio_client.dart';
import 'package:cadastro_beneficios/core/services/token_service.dart';
import 'package:cadastro_beneficios/data/datasources/auth_local_datasource.dart';
import 'package:cadastro_beneficios/data/datasources/auth_remote_datasource.dart';
import 'package:cadastro_beneficios/data/repositories/auth_repository_impl.dart';
import 'package:cadastro_beneficios/domain/usecases/auth/login_with_email_usecase.dart';
import 'package:cadastro_beneficios/domain/usecases/auth/login_with_google_usecase.dart';
import 'package:cadastro_beneficios/domain/usecases/auth/register_usecase.dart';
import 'package:cadastro_beneficios/domain/usecases/auth/logout_usecase.dart';
import 'package:cadastro_beneficios/domain/usecases/auth/get_current_user_usecase.dart';
import 'package:cadastro_beneficios/domain/usecases/auth/forgot_password_usecase.dart';
import 'package:cadastro_beneficios/presentation/bloc/auth/auth_bloc.dart';
import 'package:cadastro_beneficios/presentation/bloc/auth/auth_event.dart';
import 'package:cadastro_beneficios/presentation/bloc/auth/auth_state.dart';
import 'package:cadastro_beneficios/core/services/google_auth_service.dart';

import 'auth_integration_test.mocks.dart';

@GenerateMocks([
  DioClient,
  FlutterSecureStorage,
  AuthLocalDataSource,
  GoogleAuthService,
])
void main() {
  late AuthBloc authBloc;
  late AuthRepositoryImpl authRepository;
  late AuthRemoteDataSourceImpl remoteDataSource;
  late TokenService tokenService;

  late LoginWithEmailUseCase loginWithEmailUseCase;
  late LoginWithGoogleUseCase loginWithGoogleUseCase;
  late RegisterUseCase registerUseCase;
  late LogoutUseCase logoutUseCase;
  late GetCurrentUserUseCase getCurrentUserUseCase;
  late ForgotPasswordUseCase forgotPasswordUseCase;

  late MockGoogleAuthService mockGoogleAuthService;

  late MockDioClient mockDioClient;
  late MockFlutterSecureStorage mockSecureStorage;
  late MockAuthLocalDataSource mockLocalDataSource;

  setUp(() {
    mockDioClient = MockDioClient();
    mockSecureStorage = MockFlutterSecureStorage();
    mockLocalDataSource = MockAuthLocalDataSource();

    // Configurar TokenService com mock
    tokenService = TokenService(secureStorage: mockSecureStorage);

    // Configurar DataSources
    remoteDataSource = AuthRemoteDataSourceImpl(mockDioClient);

    // Configurar Repository
    authRepository = AuthRepositoryImpl(
      remoteDataSource: remoteDataSource,
      localDataSource: mockLocalDataSource,
      tokenService: tokenService,
    );

    // Mock LocalDataSource - retornar null por padrão (sem cache)
    when(mockLocalDataSource.getCachedUser()).thenAnswer((_) async => null);
    when(mockLocalDataSource.cacheUser(any)).thenAnswer((_) async => {});
    when(mockLocalDataSource.clearCache()).thenAnswer((_) async => {});

    // Configurar mocks adicionais
    mockGoogleAuthService = MockGoogleAuthService();

    // Configurar UseCases
    loginWithEmailUseCase = LoginWithEmailUseCase(authRepository);
    loginWithGoogleUseCase = LoginWithGoogleUseCase(authRepository, mockGoogleAuthService);
    registerUseCase = RegisterUseCase(authRepository);
    logoutUseCase = LogoutUseCase(authRepository);
    getCurrentUserUseCase = GetCurrentUserUseCase(authRepository);
    forgotPasswordUseCase = ForgotPasswordUseCase(authRepository);

    // Configurar BLoC com todas as dependências reais
    authBloc = AuthBloc(
      loginWithEmailUseCase: loginWithEmailUseCase,
      loginWithGoogleUseCase: loginWithGoogleUseCase,
      registerUseCase: registerUseCase,
      logoutUseCase: logoutUseCase,
      getCurrentUserUseCase: getCurrentUserUseCase,
      forgotPasswordUseCase: forgotPasswordUseCase,
      tokenService: tokenService,
    );
  });

  tearDown(() {
    authBloc.close();
  });

  group('Fluxo Completo de Login com Email', () {
    test('deve completar o fluxo de login: BLoC -> UseCase -> Repository -> DataSource -> BLoC',
        () async {
      // Arrange
      const email = 'joao@exemplo.com';
      const password = 'senha123';

      final loginResponseData = {
        'access_token': 'test_access_token',
        'refresh_token': 'test_refresh_token',
        'expires_at': DateTime.now().add(const Duration(hours: 1)).toIso8601String(),
        'token_type': 'Bearer',
      };

      final userResponseData = {
        'id': '123',
        'name': 'João Silva',
        'email': email,
        'cpf': '12345678900',
        'phone_number': '11987654321',
        'role': 'beneficiary',
        'created_at': '2024-01-01T10:00:00Z',
        'updated_at': '2024-01-01T10:00:00Z',
        'is_email_verified': false,
        'is_phone_verified': false,
      };

      // Mock DioClient calls
      when(mockDioClient.post(
        '/auth/login',
        data: anyNamed('data'),
      )).thenAnswer(
          (_) async => Response(
                requestOptions: RequestOptions(path: '/auth/login'),
                data: loginResponseData,
                statusCode: 200,
              ));

      when(mockDioClient.get('/auth/me')).thenAnswer(
          (_) async => Response(
                requestOptions: RequestOptions(path: '/auth/me'),
                data: userResponseData,
                statusCode: 200,
              ));

      // Mock SecureStorage operations
      when(mockSecureStorage.write(
        key: anyNamed('key'),
        value: anyNamed('value'),
      )).thenAnswer((_) async => {});

      when(mockSecureStorage.read(key: 'access_token'))
          .thenAnswer((_) async => 'test_access_token');
      when(mockSecureStorage.read(key: 'refresh_token'))
          .thenAnswer((_) async => 'test_refresh_token');
      when(mockSecureStorage.read(key: 'expires_at')).thenAnswer(
          (_) async => DateTime.now()
              .add(const Duration(hours: 1))
              .toIso8601String());
      when(mockSecureStorage.read(key: 'token_type'))
          .thenAnswer((_) async => 'Bearer');

      // Act - Disparar evento de login
      authBloc.add(const AuthLoginWithEmailRequested(
        email: email,
        password: password,
      ));

      // Assert - Verificar sequência de estados
      await expectLater(
        authBloc.stream,
        emitsInOrder([
          isA<AuthLoading>(),
          isA<AuthAuthenticated>().having(
            (state) => state.user.email,
            'email do usuário',
            email,
          ),
        ]),
      );

      // Verificar que todas as chamadas foram feitas
      verify(mockDioClient.post(
        '/auth/login',
        data: anyNamed('data'),
      )).called(1);

      verify(mockDioClient.get('/auth/me')).called(1);

      verify(mockSecureStorage.write(
              key: 'access_token', value: 'test_access_token'))
          .called(1);
      verify(mockSecureStorage.write(
              key: 'refresh_token', value: 'test_refresh_token'))
          .called(1);
    });

    test('deve tratar erro de credenciais inválidas em todo o fluxo',
        () async {
      // Arrange
      const email = 'joao@exemplo.com';
      const password = 'senha_errada';

      final errorResponseData = {
        'code': 'INVALID_CREDENTIALS',
        'message': 'Email ou senha inválidos',
      };

      // Mock DioClient call com erro 401
      when(mockDioClient.post(
        '/auth/login',
        data: anyNamed('data'),
      )).thenThrow(
        DioException(
          requestOptions: RequestOptions(path: '/auth/login'),
          response: Response(
            requestOptions: RequestOptions(path: '/auth/login'),
            data: errorResponseData,
            statusCode: 401,
          ),
          type: DioExceptionType.badResponse,
        ),
      );

      // Act
      authBloc.add(const AuthLoginWithEmailRequested(
        email: email,
        password: password,
      ));

      // Assert
      await expectLater(
        authBloc.stream,
        emitsInOrder([
          isA<AuthLoading>(),
          isA<AuthError>().having(
            (state) => state.message,
            'mensagem de erro',
            'Email ou senha inválidos',
          ),
          isA<AuthUnauthenticated>(),
        ]),
      );
    });
  });

  group('Fluxo Completo de Registro', () {
    test('deve completar o fluxo de registro: BLoC -> UseCase -> Repository -> DataSource -> BLoC',
        () async {
      // Arrange
      const nome = 'Maria Silva';
      const email = 'maria@exemplo.com';
      const cpf = '98765432100';
      const telefone = '11987654321';
      const password = 'senha123';

      final registerResponseData = {
        'access_token': 'new_access_token',
        'refresh_token': 'new_refresh_token',
        'expires_at': DateTime.now().add(const Duration(hours: 1)).toIso8601String(),
        'token_type': 'Bearer',
      };

      final userResponseData = {
        'id': '456',
        'name': nome,
        'email': email,
        'cpf': cpf,
        'phone_number': telefone,
        'role': 'beneficiary',
        'created_at': '2024-01-02T10:00:00Z',
        'updated_at': '2024-01-02T10:00:00Z',
        'is_email_verified': false,
        'is_phone_verified': false,
      };

      // Mock DioClient calls
      when(mockDioClient.post(
        '/auth/register',
        data: anyNamed('data'),
      )).thenAnswer(
          (_) async => Response(
                requestOptions: RequestOptions(path: '/auth/register'),
                data: registerResponseData,
                statusCode: 201,
              ));

      when(mockDioClient.get('/auth/me')).thenAnswer(
          (_) async => Response(
                requestOptions: RequestOptions(path: '/auth/me'),
                data: userResponseData,
                statusCode: 200,
              ));

      // Mock SecureStorage
      when(mockSecureStorage.write(
        key: anyNamed('key'),
        value: anyNamed('value'),
      )).thenAnswer((_) async => {});

      when(mockSecureStorage.read(key: 'access_token'))
          .thenAnswer((_) async => 'new_access_token');
      when(mockSecureStorage.read(key: 'refresh_token'))
          .thenAnswer((_) async => 'new_refresh_token');
      when(mockSecureStorage.read(key: 'expires_at')).thenAnswer(
          (_) async => DateTime.now()
              .add(const Duration(hours: 1))
              .toIso8601String());
      when(mockSecureStorage.read(key: 'token_type'))
          .thenAnswer((_) async => 'Bearer');

      // Act
      authBloc.add(AuthRegisterRequested(
        name: nome,
        email: email,
        cpf: cpf,
        phoneNumber: telefone,
        password: password,
      ));

      // Assert
      await expectLater(
        authBloc.stream,
        emitsInOrder([
          isA<AuthLoading>(),
          isA<AuthAuthenticated>().having(
            (state) => state.user.email,
            'email do usuário',
            email,
          ),
        ]),
      );

      verify(mockDioClient.post(
        '/auth/register',
        data: anyNamed('data'),
      )).called(1);

      verify(mockDioClient.get('/auth/me')).called(1);
    });

    test('deve tratar erro de email já existente no registro', () async {
      // Arrange
      const nome = 'Maria Silva';
      const email = 'existente@exemplo.com';
      const cpf = '98765432100';
      const telefone = '11987654321';
      const password = 'senha123';

      final errorResponseData = {
        'code': 'EMAIL_ALREADY_EXISTS',
        'message': 'Email já cadastrado',
      };

      when(mockDioClient.post(
        '/auth/register',
        data: anyNamed('data'),
      )).thenThrow(
        DioException(
          requestOptions: RequestOptions(path: '/auth/register'),
          response: Response(
            requestOptions: RequestOptions(path: '/auth/register'),
            data: errorResponseData,
            statusCode: 400,
          ),
          type: DioExceptionType.badResponse,
        ),
      );

      // Act
      authBloc.add(AuthRegisterRequested(
        name: nome,
        email: email,
        cpf: cpf,
        phoneNumber: telefone,
        password: password,
      ));

      // Assert
      await expectLater(
        authBloc.stream,
        emitsInOrder([
          isA<AuthLoading>(),
          isA<AuthError>().having(
            (state) => state.message,
            'mensagem de erro',
            contains('Email já cadastrado'),
          ),
          isA<AuthUnauthenticated>(),
        ]),
      );
    });
  });

  group('Fluxo Completo de Logout', () {
    test('deve completar o fluxo de logout: BLoC -> UseCase -> Repository -> DataSource -> BLoC',
        () async {
      // Arrange
      when(mockSecureStorage.read(key: 'access_token'))
          .thenAnswer((_) async => 'existing_token');

      when(mockDioClient.post('/auth/logout')).thenAnswer(
          (_) async => Response(
                requestOptions: RequestOptions(path: '/auth/logout'),
                data: {'message': 'Logout successful'},
                statusCode: 200,
              ));

      when(mockSecureStorage.delete(key: anyNamed('key')))
          .thenAnswer((_) async => {});

      // Act
      authBloc.add(const AuthLogoutRequested());

      // Assert
      await expectLater(
        authBloc.stream,
        emitsInOrder([
          isA<AuthLoading>(),
          isA<AuthUnauthenticated>(),
        ]),
      );

      verify(mockDioClient.post('/auth/logout')).called(1);

      verify(mockSecureStorage.delete(key: 'access_token')).called(1);
      verify(mockSecureStorage.delete(key: 'refresh_token')).called(1);
      verify(mockSecureStorage.delete(key: 'expires_at')).called(1);
      verify(mockSecureStorage.delete(key: 'token_type')).called(1);
    });

    test('deve completar logout mesmo se a chamada ao servidor falhar',
        () async {
      // Arrange
      when(mockSecureStorage.read(key: 'access_token'))
          .thenAnswer((_) async => 'existing_token');

      when(mockDioClient.post('/auth/logout')).thenThrow(
        DioException(
          requestOptions: RequestOptions(path: '/auth/logout'),
          response: Response(
            requestOptions: RequestOptions(path: '/auth/logout'),
            data: {'error': 'Server error'},
            statusCode: 500,
          ),
          type: DioExceptionType.badResponse,
        ),
      );

      when(mockSecureStorage.delete(key: anyNamed('key')))
          .thenAnswer((_) async => {});

      // Act
      authBloc.add(const AuthLogoutRequested());

      // Assert - Deve fazer logout local mesmo com erro no servidor
      // Nota: O BLoC sempre completa o logout localmente, mesmo se o servidor falhar
      await expectLater(
        authBloc.stream,
        emitsInOrder([
          isA<AuthLoading>(),
          isA<AuthUnauthenticated>(),
        ]),
      );

      verify(mockSecureStorage.delete(key: 'access_token')).called(1);
      verify(mockSecureStorage.delete(key: 'refresh_token')).called(1);
    });
  });

  group('Fluxo Completo de Recuperação de Senha', () {
    test('deve completar o fluxo de recuperação de senha', () async {
      // Arrange
      const email = 'usuario@exemplo.com';

      when(mockDioClient.post(
        '/auth/forgot-password',
        data: anyNamed('data'),
      )).thenAnswer(
          (_) async => Response(
                requestOptions:
                    RequestOptions(path: '/auth/forgot-password'),
                data: {'message': 'Email de recuperação enviado'},
                statusCode: 200,
              ));

      // Act
      authBloc.add(const AuthForgotPasswordRequested(email: email));

      // Assert
      await expectLater(
        authBloc.stream,
        emitsInOrder([
          isA<AuthLoading>(),
          isA<AuthPasswordResetEmailSent>().having(
            (state) => state.email,
            'email',
            email,
          ),
        ]),
      );

      verify(mockDioClient.post(
        '/auth/forgot-password',
        data: anyNamed('data'),
      )).called(1);
    });

    test('deve tratar erro de email não encontrado na recuperação de senha',
        () async {
      // Arrange
      const email = 'naoexiste@exemplo.com';

      when(mockDioClient.post(
        '/auth/forgot-password',
        data: anyNamed('data'),
      )).thenThrow(
        DioException(
          requestOptions: RequestOptions(path: '/auth/forgot-password'),
          response: Response(
            requestOptions: RequestOptions(path: '/auth/forgot-password'),
            data: {
              'code': 'USER_NOT_FOUND',
              'message': 'Usuário não encontrado'
            },
            statusCode: 404,
          ),
          type: DioExceptionType.badResponse,
        ),
      );

      // Act
      authBloc.add(const AuthForgotPasswordRequested(email: email));

      // Assert
      // Nota: ForgotPassword não emite AuthUnauthenticated após erro (possível bug no BLoC)
      await expectLater(
        authBloc.stream,
        emitsInOrder([
          isA<AuthLoading>(),
          isA<AuthError>().having(
            (state) => state.message,
            'mensagem de erro',
            'Usuário não encontrado',
          ),
        ]),
      );
    });
  });

  group('Fluxo Completo de Verificação de Autenticação', () {
    test('deve verificar autenticação quando existe token válido', () async {
      // Arrange
      final expiresAt = DateTime.now().add(const Duration(hours: 2));

      when(mockSecureStorage.read(key: 'access_token'))
          .thenAnswer((_) async => 'valid_token');
      when(mockSecureStorage.read(key: 'refresh_token'))
          .thenAnswer((_) async => 'valid_refresh_token');
      when(mockSecureStorage.read(key: 'expires_at'))
          .thenAnswer((_) async => expiresAt.toIso8601String());
      when(mockSecureStorage.read(key: 'token_type'))
          .thenAnswer((_) async => 'Bearer');

      final userResponseData = {
        'id': '789',
        'name': 'Pedro Santos',
        'email': 'pedro@exemplo.com',
        'cpf': '11122233344',
        'phone_number': '11999999999',
        'role': 'beneficiary',
        'created_at': '2024-01-03T10:00:00Z',
        'updated_at': '2024-01-03T10:00:00Z',
        'is_email_verified': false,
        'is_phone_verified': false,
      };

      when(mockDioClient.get('/auth/me')).thenAnswer(
          (_) async => Response(
                requestOptions: RequestOptions(path: '/auth/me'),
                data: userResponseData,
                statusCode: 200,
              ));

      // Act
      authBloc.add(const AuthCheckRequested());

      // Assert
      await expectLater(
        authBloc.stream,
        emitsInOrder([
          isA<AuthLoading>(),
          isA<AuthAuthenticated>().having(
            (state) => state.user.name,
            'nome do usuário',
            'Pedro Santos',
          ),
        ]),
      );
    });

    test('deve retornar unauthenticated quando não existe token', () async {
      // Arrange
      when(mockSecureStorage.read(key: anyNamed('key')))
          .thenAnswer((_) async => null);

      // Act
      authBloc.add(const AuthCheckRequested());

      // Assert
      await expectLater(
        authBloc.stream,
        emitsInOrder([
          isA<AuthLoading>(),
          isA<AuthUnauthenticated>(),
        ]),
      );
    });

    test('deve tratar token inválido ou expirado', () async {
      // Arrange
      final expiresAt = DateTime.now().add(const Duration(hours: 2));

      when(mockSecureStorage.read(key: 'access_token'))
          .thenAnswer((_) async => 'invalid_token');
      when(mockSecureStorage.read(key: 'refresh_token'))
          .thenAnswer((_) async => 'invalid_refresh_token');
      when(mockSecureStorage.read(key: 'expires_at'))
          .thenAnswer((_) async => expiresAt.toIso8601String());
      when(mockSecureStorage.read(key: 'token_type'))
          .thenAnswer((_) async => 'Bearer');

      when(mockDioClient.get('/auth/me')).thenThrow(
        DioException(
          requestOptions: RequestOptions(path: '/auth/me'),
          response: Response(
            requestOptions: RequestOptions(path: '/auth/me'),
            data: {'error': 'invalid_token'},
            statusCode: 401,
          ),
          type: DioExceptionType.badResponse,
        ),
      );

      when(mockSecureStorage.delete(key: anyNamed('key')))
          .thenAnswer((_) async => {});

      // Act
      authBloc.add(const AuthCheckRequested());

      // Assert
      await expectLater(
        authBloc.stream,
        emitsInOrder([
          isA<AuthLoading>(),
          isA<AuthUnauthenticated>(),
        ]),
      );
    });
  });
}
