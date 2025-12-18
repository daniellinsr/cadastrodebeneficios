import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cadastro_beneficios/core/services/token_service.dart';
import 'package:cadastro_beneficios/domain/usecases/auth/login_with_email_usecase.dart';
import 'package:cadastro_beneficios/domain/usecases/auth/login_with_google_usecase.dart';
import 'package:cadastro_beneficios/domain/usecases/auth/register_usecase.dart';
import 'package:cadastro_beneficios/domain/usecases/auth/logout_usecase.dart';
import 'package:cadastro_beneficios/domain/usecases/auth/get_current_user_usecase.dart';
import 'package:cadastro_beneficios/domain/usecases/auth/forgot_password_usecase.dart';
import 'auth_event.dart';
import 'auth_state.dart';

/// BLoC de Autenticação
///
/// Gerencia o estado de autenticação do aplicativo
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final LoginWithEmailUseCase loginWithEmailUseCase;
  final LoginWithGoogleUseCase loginWithGoogleUseCase;
  final RegisterUseCase registerUseCase;
  final LogoutUseCase logoutUseCase;
  final GetCurrentUserUseCase getCurrentUserUseCase;
  final ForgotPasswordUseCase forgotPasswordUseCase;
  final TokenService tokenService;

  AuthBloc({
    required this.loginWithEmailUseCase,
    required this.loginWithGoogleUseCase,
    required this.registerUseCase,
    required this.logoutUseCase,
    required this.getCurrentUserUseCase,
    required this.forgotPasswordUseCase,
    required this.tokenService,
  }) : super(const AuthInitial()) {
    // Registrar handlers de eventos
    on<AuthCheckRequested>(_onAuthCheckRequested);
    on<AuthLoginWithEmailRequested>(_onLoginWithEmailRequested);
    on<AuthLoginWithGoogleRequested>(_onLoginWithGoogleRequested);
    on<AuthRegisterRequested>(_onRegisterRequested);
    on<AuthLogoutRequested>(_onLogoutRequested);
    on<AuthForgotPasswordRequested>(_onForgotPasswordRequested);
    on<AuthUserUpdated>(_onUserUpdated);
    on<AuthUserSet>(_onUserSet);
  }

  /// Handler: Verificar autenticação inicial
  Future<void> _onAuthCheckRequested(
    AuthCheckRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());

    // Verificar se existe token salvo
    final hasToken = await tokenService.hasToken();

    if (!hasToken) {
      emit(const AuthUnauthenticated());
      return;
    }

    // Buscar dados do usuário
    final result = await getCurrentUserUseCase();

    result.fold(
      (failure) => emit(const AuthUnauthenticated()),
      (user) => emit(AuthAuthenticated(user: user)),
    );
  }

  /// Handler: Login com email e senha
  Future<void> _onLoginWithEmailRequested(
    AuthLoginWithEmailRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());

    final result = await loginWithEmailUseCase(
      email: event.email,
      password: event.password,
    );

    await result.fold(
      (failure) async {
        emit(AuthError(
          message: failure.message,
          code: failure.code,
        ));
        // Voltar para unauthenticated após mostrar erro
        await Future.delayed(const Duration(milliseconds: 100));
        emit(const AuthUnauthenticated());
      },
      (authToken) async {
        // Salvar token
        await tokenService.saveToken(authToken);

        // Buscar dados do usuário
        final userResult = await getCurrentUserUseCase();

        userResult.fold(
          (failure) => emit(AuthError(
            message: failure.message,
            code: failure.code,
          )),
          (user) => emit(AuthAuthenticated(user: user)),
        );
      },
    );
  }

  /// Handler: Login com Google
  Future<void> _onLoginWithGoogleRequested(
    AuthLoginWithGoogleRequested event,
    Emitter<AuthState> emit,
  ) async {
    print('🔐 [AuthBloc] Iniciando login com Google...');
    emit(const AuthLoading());

    final result = await loginWithGoogleUseCase();

    await result.fold(
      (failure) async {
        print('❌ [AuthBloc] Erro no login Google: ${failure.message}');
        emit(AuthError(
          message: failure.message,
          code: failure.code,
        ));
        // Voltar para unauthenticated após mostrar erro
        await Future.delayed(const Duration(milliseconds: 100));
        emit(const AuthUnauthenticated());
      },
      (authToken) async {
        print('✅ [AuthBloc] Login Google bem-sucedido!');

        // Salvar token
        await tokenService.saveToken(authToken);
        print('✅ [AuthBloc] Token salvo');

        // Buscar dados do usuário
        print('🔍 [AuthBloc] Buscando dados do usuário...');
        final userResult = await getCurrentUserUseCase();

        userResult.fold(
          (failure) {
            print('❌ [AuthBloc] Erro ao buscar usuário: ${failure.message}');
            emit(AuthError(
              message: failure.message,
              code: failure.code,
            ));
          },
          (user) {
            print('✅ [AuthBloc] Usuário carregado: ${user.email}');
            print('   isProfileComplete: ${user.isProfileComplete}');
            print('   profileCompletionStatus: ${user.profileCompletionStatus}');
            print('📤 [AuthBloc] Emitindo AuthAuthenticated...');
            emit(AuthAuthenticated(user: user));
          },
        );
      },
    );
  }

  /// Handler: Registro de novo usuário
  Future<void> _onRegisterRequested(
    AuthRegisterRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());

    final result = await registerUseCase(
      name: event.name,
      email: event.email,
      password: event.password,
      phoneNumber: event.phoneNumber,
      cpf: event.cpf,
    );

    await result.fold(
      (failure) async {
        emit(AuthError(
          message: failure.message,
          code: failure.code,
        ));
        // Voltar para unauthenticated após mostrar erro
        await Future.delayed(const Duration(milliseconds: 100));
        emit(const AuthUnauthenticated());
      },
      (authToken) async {
        // Salvar token
        await tokenService.saveToken(authToken);

        // Buscar dados do usuário
        final userResult = await getCurrentUserUseCase();

        userResult.fold(
          (failure) => emit(AuthError(
            message: failure.message,
            code: failure.code,
          )),
          (user) => emit(AuthAuthenticated(user: user)),
        );
      },
    );
  }

  /// Handler: Logout
  Future<void> _onLogoutRequested(
    AuthLogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());

    // Limpar token local primeiro
    await tokenService.deleteToken();

    // Chamar logout no backend
    await logoutUseCase();

    emit(const AuthUnauthenticated());
  }

  /// Handler: Recuperar senha
  Future<void> _onForgotPasswordRequested(
    AuthForgotPasswordRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());

    final result = await forgotPasswordUseCase(email: event.email);

    result.fold(
      (failure) {
        emit(AuthError(
          message: failure.message,
          code: failure.code,
        ));
      },
      (_) {
        emit(AuthPasswordResetEmailSent(email: event.email));
      },
    );
  }

  /// Handler: Atualizar dados do usuário
  Future<void> _onUserUpdated(
    AuthUserUpdated event,
    Emitter<AuthState> emit,
  ) async {
    debugPrint('🔄 [AuthBloc] AuthUserUpdated disparado');
    debugPrint('🔍 [AuthBloc] Buscando dados do usuário atualizado...');

    // Recarregar dados do usuário
    final result = await getCurrentUserUseCase();

    result.fold(
      (failure) {
        debugPrint('❌ [AuthBloc] Erro ao buscar usuário: ${failure.message}');
        emit(AuthError(
          message: failure.message,
          code: failure.code,
        ));
      },
      (user) {
        debugPrint('✅ [AuthBloc] Usuário carregado: ${user.email}');
        debugPrint('   isProfileComplete: ${user.isProfileComplete}');
        debugPrint('   profileCompletionStatus: ${user.profileCompletionStatus}');
        debugPrint('📤 [AuthBloc] Emitindo AuthAuthenticated...');
        emit(AuthAuthenticated(user: user));
      },
    );
  }

  /// Handler: Definir usuário diretamente (sem buscar do backend)
  void _onUserSet(
    AuthUserSet event,
    Emitter<AuthState> emit,
  ) {
    debugPrint('✅ [AuthBloc] AuthUserSet disparado');
    debugPrint('✅ [AuthBloc] Usuário injetado diretamente: ${event.user.email}');
    debugPrint('   isProfileComplete: ${event.user.isProfileComplete}');
    debugPrint('   profileCompletionStatus: ${event.user.profileCompletionStatus}');
    debugPrint('📤 [AuthBloc] Emitindo AuthAuthenticated...');
    emit(AuthAuthenticated(user: event.user));
  }
}
