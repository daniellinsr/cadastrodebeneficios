import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:cadastro_beneficios/core/errors/failures.dart';
import 'package:cadastro_beneficios/core/services/token_service.dart';
import 'package:cadastro_beneficios/domain/entities/user.dart';
import 'package:cadastro_beneficios/domain/entities/auth_token.dart';
import 'package:cadastro_beneficios/domain/usecases/auth/login_with_email_usecase.dart';
import 'package:cadastro_beneficios/domain/usecases/auth/login_with_google_usecase.dart';
import 'package:cadastro_beneficios/domain/usecases/auth/register_usecase.dart';
import 'package:cadastro_beneficios/domain/usecases/auth/logout_usecase.dart';
import 'package:cadastro_beneficios/domain/usecases/auth/get_current_user_usecase.dart';
import 'package:cadastro_beneficios/domain/usecases/auth/forgot_password_usecase.dart';
import 'package:cadastro_beneficios/presentation/bloc/auth/auth_bloc.dart';
import 'package:cadastro_beneficios/presentation/bloc/auth/auth_event.dart';
import 'package:cadastro_beneficios/presentation/bloc/auth/auth_state.dart';

import 'auth_bloc_test.mocks.dart';

@GenerateMocks([
  LoginWithEmailUseCase,
  LoginWithGoogleUseCase,
  RegisterUseCase,
  LogoutUseCase,
  GetCurrentUserUseCase,
  ForgotPasswordUseCase,
  TokenService,
])
void main() {
  late AuthBloc authBloc;
  late MockLoginWithEmailUseCase mockLoginWithEmailUseCase;
  late MockLoginWithGoogleUseCase mockLoginWithGoogleUseCase;
  late MockRegisterUseCase mockRegisterUseCase;
  late MockLogoutUseCase mockLogoutUseCase;
  late MockGetCurrentUserUseCase mockGetCurrentUserUseCase;
  late MockForgotPasswordUseCase mockForgotPasswordUseCase;
  late MockTokenService mockTokenService;

  setUp(() {
    mockLoginWithEmailUseCase = MockLoginWithEmailUseCase();
    mockLoginWithGoogleUseCase = MockLoginWithGoogleUseCase();
    mockRegisterUseCase = MockRegisterUseCase();
    mockLogoutUseCase = MockLogoutUseCase();
    mockGetCurrentUserUseCase = MockGetCurrentUserUseCase();
    mockForgotPasswordUseCase = MockForgotPasswordUseCase();
    mockTokenService = MockTokenService();

    authBloc = AuthBloc(
      loginWithEmailUseCase: mockLoginWithEmailUseCase,
      loginWithGoogleUseCase: mockLoginWithGoogleUseCase,
      registerUseCase: mockRegisterUseCase,
      logoutUseCase: mockLogoutUseCase,
      getCurrentUserUseCase: mockGetCurrentUserUseCase,
      forgotPasswordUseCase: mockForgotPasswordUseCase,
      tokenService: mockTokenService,
    );
  });

  tearDown(() {
    authBloc.close();
  });

  final tUser = User(
    id: '123',
    name: 'João Silva',
    email: 'joao@exemplo.com',
    role: UserRole.beneficiary,
    createdAt: DateTime(2024, 1, 1),
  );

  final tAuthToken = AuthToken(
    accessToken: 'access_token_123',
    refreshToken: 'refresh_token_456',
    expiresAt: DateTime.now().add(const Duration(hours: 1)),
  );

  group('AuthBloc - Initial State', () {
    test('estado inicial deve ser AuthInitial', () {
      expect(authBloc.state, const AuthInitial());
    });
  });

  group('AuthBloc - AuthCheckRequested', () {
    blocTest<AuthBloc, AuthState>(
      'deve emitir [AuthLoading, AuthUnauthenticated] quando não houver token',
      build: () {
        when(mockTokenService.hasToken()).thenAnswer((_) async => false);
        return authBloc;
      },
      act: (bloc) => bloc.add(const AuthCheckRequested()),
      expect: () => [
        const AuthLoading(),
        const AuthUnauthenticated(),
      ],
      verify: (_) {
        verify(mockTokenService.hasToken()).called(1);
        verifyNever(mockGetCurrentUserUseCase());
      },
    );

    blocTest<AuthBloc, AuthState>(
      'deve emitir [AuthLoading, AuthAuthenticated] quando houver token válido',
      build: () {
        when(mockTokenService.hasToken()).thenAnswer((_) async => true);
        when(mockGetCurrentUserUseCase()).thenAnswer((_) async => Right(tUser));
        return authBloc;
      },
      act: (bloc) => bloc.add(const AuthCheckRequested()),
      expect: () => [
        const AuthLoading(),
        AuthAuthenticated(user: tUser),
      ],
      verify: (_) {
        verify(mockTokenService.hasToken()).called(1);
        verify(mockGetCurrentUserUseCase()).called(1);
      },
    );

    blocTest<AuthBloc, AuthState>(
      'deve emitir [AuthLoading, AuthUnauthenticated] quando falhar ao buscar usuário',
      build: () {
        when(mockTokenService.hasToken()).thenAnswer((_) async => true);
        when(mockGetCurrentUserUseCase()).thenAnswer(
          (_) async => const Left(
            AuthenticationFailure(message: 'Token inválido'),
          ),
        );
        return authBloc;
      },
      act: (bloc) => bloc.add(const AuthCheckRequested()),
      expect: () => [
        const AuthLoading(),
        const AuthUnauthenticated(),
      ],
    );
  });

  group('AuthBloc - AuthLoginWithEmailRequested', () {
    blocTest<AuthBloc, AuthState>(
      'deve emitir [AuthLoading, AuthAuthenticated] quando login for bem-sucedido',
      build: () {
        when(mockLoginWithEmailUseCase(
          email: anyNamed('email'),
          password: anyNamed('password'),
        )).thenAnswer((_) async => Right(tAuthToken));
        when(mockTokenService.saveToken(any)).thenAnswer((_) async => {});
        when(mockGetCurrentUserUseCase()).thenAnswer((_) async => Right(tUser));
        return authBloc;
      },
      act: (bloc) => bloc.add(const AuthLoginWithEmailRequested(
        email: 'joao@exemplo.com',
        password: 'senha123',
      )),
      expect: () => [
        const AuthLoading(),
        AuthAuthenticated(user: tUser),
      ],
      verify: (_) {
        verify(mockLoginWithEmailUseCase(
          email: 'joao@exemplo.com',
          password: 'senha123',
        )).called(1);
        verify(mockTokenService.saveToken(tAuthToken)).called(1);
        verify(mockGetCurrentUserUseCase()).called(1);
      },
    );

    blocTest<AuthBloc, AuthState>(
      'deve emitir [AuthLoading, AuthError, AuthUnauthenticated] quando credenciais forem inválidas',
      build: () {
        when(mockLoginWithEmailUseCase(
          email: anyNamed('email'),
          password: anyNamed('password'),
        )).thenAnswer(
          (_) async => const Left(
            AuthenticationFailure(
              message: 'Credenciais inválidas',
              code: 'INVALID_CREDENTIALS',
            ),
          ),
        );
        return authBloc;
      },
      act: (bloc) => bloc.add(const AuthLoginWithEmailRequested(
        email: 'joao@exemplo.com',
        password: 'senha_errada',
      )),
      expect: () => [
        const AuthLoading(),
        const AuthError(
          message: 'Credenciais inválidas',
          code: 'INVALID_CREDENTIALS',
        ),
        const AuthUnauthenticated(),
      ],
      wait: const Duration(milliseconds: 150),
    );

    blocTest<AuthBloc, AuthState>(
      'deve emitir [AuthLoading, AuthError] quando falhar ao buscar usuário após login',
      build: () {
        when(mockLoginWithEmailUseCase(
          email: anyNamed('email'),
          password: anyNamed('password'),
        )).thenAnswer((_) async => Right(tAuthToken));
        when(mockTokenService.saveToken(any)).thenAnswer((_) async => {});
        when(mockGetCurrentUserUseCase()).thenAnswer(
          (_) async => const Left(
            ServerFailure(message: 'Erro ao buscar usuário'),
          ),
        );
        return authBloc;
      },
      act: (bloc) => bloc.add(const AuthLoginWithEmailRequested(
        email: 'joao@exemplo.com',
        password: 'senha123',
      )),
      expect: () => [
        const AuthLoading(),
        const AuthError(
          message: 'Erro ao buscar usuário',
          code: null,
        ),
      ],
    );
  });

  group('AuthBloc - AuthRegisterRequested', () {
    blocTest<AuthBloc, AuthState>(
      'deve emitir [AuthLoading, AuthAuthenticated] quando registro for bem-sucedido',
      build: () {
        when(mockRegisterUseCase(
          name: anyNamed('name'),
          email: anyNamed('email'),
          password: anyNamed('password'),
          phoneNumber: anyNamed('phoneNumber'),
          cpf: anyNamed('cpf'),
        )).thenAnswer((_) async => Right(tAuthToken));
        when(mockTokenService.saveToken(any)).thenAnswer((_) async => {});
        when(mockGetCurrentUserUseCase()).thenAnswer((_) async => Right(tUser));
        return authBloc;
      },
      act: (bloc) => bloc.add(const AuthRegisterRequested(
        name: 'João Silva',
        email: 'joao@exemplo.com',
        password: 'senha123456',
        phoneNumber: '11987654321',
      )),
      expect: () => [
        const AuthLoading(),
        AuthAuthenticated(user: tUser),
      ],
      verify: (_) {
        verify(mockRegisterUseCase(
          name: 'João Silva',
          email: 'joao@exemplo.com',
          password: 'senha123456',
          phoneNumber: '11987654321',
          cpf: null,
        )).called(1);
        verify(mockTokenService.saveToken(tAuthToken)).called(1);
      },
    );

    blocTest<AuthBloc, AuthState>(
      'deve emitir [AuthLoading, AuthError, AuthUnauthenticated] quando email já existir',
      build: () {
        when(mockRegisterUseCase(
          name: anyNamed('name'),
          email: anyNamed('email'),
          password: anyNamed('password'),
          phoneNumber: anyNamed('phoneNumber'),
          cpf: anyNamed('cpf'),
        )).thenAnswer(
          (_) async => const Left(
            EmailAlreadyExistsFailure(
              message: 'Email já cadastrado',
            ),
          ),
        );
        return authBloc;
      },
      act: (bloc) => bloc.add(const AuthRegisterRequested(
        name: 'João Silva',
        email: 'joao@exemplo.com',
        password: 'senha123456',
        phoneNumber: '11987654321',
      )),
      expect: () => [
        const AuthLoading(),
        const AuthError(
          message: 'Email já cadastrado',
          code: null,
        ),
        const AuthUnauthenticated(),
      ],
      wait: const Duration(milliseconds: 150),
    );
  });

  group('AuthBloc - AuthLogoutRequested', () {
    blocTest<AuthBloc, AuthState>(
      'deve emitir [AuthLoading, AuthUnauthenticated] quando logout for bem-sucedido',
      build: () {
        when(mockTokenService.deleteToken()).thenAnswer((_) async => {});
        when(mockLogoutUseCase()).thenAnswer((_) async => const Right(null));
        return authBloc;
      },
      act: (bloc) => bloc.add(const AuthLogoutRequested()),
      expect: () => [
        const AuthLoading(),
        const AuthUnauthenticated(),
      ],
      verify: (_) {
        verify(mockTokenService.deleteToken()).called(1);
        verify(mockLogoutUseCase()).called(1);
      },
    );

    blocTest<AuthBloc, AuthState>(
      'deve emitir [AuthLoading, AuthUnauthenticated] mesmo quando logout falhar no servidor',
      build: () {
        when(mockTokenService.deleteToken()).thenAnswer((_) async => {});
        when(mockLogoutUseCase()).thenAnswer(
          (_) async => const Left(
            ServerFailure(message: 'Erro no servidor'),
          ),
        );
        return authBloc;
      },
      act: (bloc) => bloc.add(const AuthLogoutRequested()),
      expect: () => [
        const AuthLoading(),
        const AuthUnauthenticated(),
      ],
      verify: (_) {
        verify(mockTokenService.deleteToken()).called(1);
        verify(mockLogoutUseCase()).called(1);
      },
    );
  });

  group('AuthBloc - AuthForgotPasswordRequested', () {
    blocTest<AuthBloc, AuthState>(
      'deve emitir [AuthLoading, AuthPasswordResetEmailSent] quando email for enviado',
      build: () {
        when(mockForgotPasswordUseCase(email: anyNamed('email')))
            .thenAnswer((_) async => const Right(null));
        return authBloc;
      },
      act: (bloc) => bloc.add(
        const AuthForgotPasswordRequested(email: 'joao@exemplo.com'),
      ),
      expect: () => [
        const AuthLoading(),
        const AuthPasswordResetEmailSent(email: 'joao@exemplo.com'),
      ],
      verify: (_) {
        verify(mockForgotPasswordUseCase(email: 'joao@exemplo.com')).called(1);
      },
    );

    blocTest<AuthBloc, AuthState>(
      'deve emitir [AuthLoading, AuthError] quando falhar ao enviar email',
      build: () {
        when(mockForgotPasswordUseCase(email: anyNamed('email'))).thenAnswer(
          (_) async => const Left(
            ValidationFailure(
              message: 'Email não encontrado',
              code: 'EMAIL_NOT_FOUND',
            ),
          ),
        );
        return authBloc;
      },
      act: (bloc) => bloc.add(
        const AuthForgotPasswordRequested(email: 'inexistente@exemplo.com'),
      ),
      expect: () => [
        const AuthLoading(),
        const AuthError(
          message: 'Email não encontrado',
          code: 'EMAIL_NOT_FOUND',
        ),
      ],
    );
  });

  group('AuthBloc - AuthUserUpdated', () {
    blocTest<AuthBloc, AuthState>(
      'deve emitir [AuthAuthenticated] com dados atualizados do usuário',
      build: () {
        when(mockGetCurrentUserUseCase()).thenAnswer((_) async => Right(tUser));
        return authBloc;
      },
      act: (bloc) => bloc.add(const AuthUserUpdated()),
      expect: () => [
        AuthAuthenticated(user: tUser),
      ],
      verify: (_) {
        verify(mockGetCurrentUserUseCase()).called(1);
      },
    );

    blocTest<AuthBloc, AuthState>(
      'deve emitir [AuthError] quando falhar ao atualizar usuário',
      build: () {
        when(mockGetCurrentUserUseCase()).thenAnswer(
          (_) async => const Left(
            ServerFailure(message: 'Erro ao buscar dados'),
          ),
        );
        return authBloc;
      },
      act: (bloc) => bloc.add(const AuthUserUpdated()),
      expect: () => [
        const AuthError(
          message: 'Erro ao buscar dados',
          code: null,
        ),
      ],
    );
  });

  group('AuthBloc - AuthLoginWithGoogleRequested', () {
    blocTest<AuthBloc, AuthState>(
      'deve emitir [AuthLoading, AuthAuthenticated] quando login Google for bem-sucedido',
      build: () {
        when(mockLoginWithGoogleUseCase())
            .thenAnswer((_) async => Right(tAuthToken));
        when(mockTokenService.saveToken(any)).thenAnswer((_) async => {});
        when(mockGetCurrentUserUseCase()).thenAnswer((_) async => Right(tUser));
        return authBloc;
      },
      act: (bloc) => bloc.add(const AuthLoginWithGoogleRequested()),
      expect: () => [
        const AuthLoading(),
        AuthAuthenticated(user: tUser),
      ],
      verify: (_) {
        verify(mockLoginWithGoogleUseCase()).called(1);
        verify(mockTokenService.saveToken(tAuthToken)).called(1);
        verify(mockGetCurrentUserUseCase()).called(1);
      },
    );

    blocTest<AuthBloc, AuthState>(
      'deve emitir [AuthLoading, AuthError, AuthUnauthenticated] quando login Google falhar',
      build: () {
        when(mockLoginWithGoogleUseCase()).thenAnswer(
          (_) async => const Left(
            AuthenticationFailure(
              message: 'Falha no login com Google',
              code: 'GOOGLE_LOGIN_FAILED',
            ),
          ),
        );
        return authBloc;
      },
      act: (bloc) => bloc.add(const AuthLoginWithGoogleRequested()),
      expect: () => [
        const AuthLoading(),
        const AuthError(
          message: 'Falha no login com Google',
          code: 'GOOGLE_LOGIN_FAILED',
        ),
        const AuthUnauthenticated(),
      ],
      wait: const Duration(milliseconds: 150),
    );
  });
}
