import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cadastro_beneficios/core/theme/app_theme.dart';
import 'package:cadastro_beneficios/core/router/app_router.dart';
import 'package:cadastro_beneficios/core/config/env_config.dart';
import 'package:cadastro_beneficios/firebase_options.dart';
import 'package:cadastro_beneficios/core/di/service_locator.dart';
import 'package:cadastro_beneficios/presentation/bloc/auth/auth_bloc.dart';
import 'package:cadastro_beneficios/domain/usecases/auth/login_with_email_usecase.dart';
import 'package:cadastro_beneficios/domain/usecases/auth/login_with_google_usecase.dart';
import 'package:cadastro_beneficios/domain/usecases/auth/register_usecase.dart';
import 'package:cadastro_beneficios/domain/usecases/auth/get_current_user_usecase.dart';
import 'package:cadastro_beneficios/domain/usecases/auth/logout_usecase.dart';
import 'package:cadastro_beneficios/domain/usecases/auth/forgot_password_usecase.dart';

void main() async {
  // Garantir que os bindings do Flutter estejam inicializados
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializar Firebase (com verificação para evitar duplicação)
  try {
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
    }
  } catch (e) {
    // Ignorar erro de app duplicado (ocorre em hot reload)
    if (!e.toString().contains('duplicate-app')) {
      rethrow;
    }
  }

  // Carregar variáveis de ambiente do arquivo .env
  await EnvConfig.load();

  // Validar se todas as variáveis obrigatórias estão configuradas
  EnvConfig.validate();

  // Imprimir configuração (apenas se ENABLE_DEBUG_LOGS=true no .env)
  EnvConfig.printConfig();

  // Inicializar Service Locator (DI)
  await sl.init();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AuthBloc(
        loginWithEmailUseCase: LoginWithEmailUseCase(sl.authRepository),
        loginWithGoogleUseCase: LoginWithGoogleUseCase(sl.authRepository, sl.googleAuthService),
        registerUseCase: RegisterUseCase(sl.authRepository),
        getCurrentUserUseCase: GetCurrentUserUseCase(sl.authRepository),
        logoutUseCase: LogoutUseCase(sl.authRepository),
        forgotPasswordUseCase: ForgotPasswordUseCase(sl.authRepository),
        tokenService: sl.tokenService,
      ),
      child: MaterialApp.router(
        title: 'Sistema de Cartão de Benefícios',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        routerConfig: AppRouter.router,
      ),
    );
  }
}
