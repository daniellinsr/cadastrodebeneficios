import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:cadastro_beneficios/presentation/pages/splash_screen.dart';
import 'package:cadastro_beneficios/presentation/pages/landing_page_new.dart';
import 'package:cadastro_beneficios/presentation/pages/auth/login_page.dart';
import 'package:cadastro_beneficios/presentation/pages/auth/forgot_password_page.dart';
import 'package:cadastro_beneficios/presentation/pages/registration/registration_intro_page.dart';
import 'package:cadastro_beneficios/presentation/pages/registration/registration_identification_page.dart';
import 'package:cadastro_beneficios/presentation/pages/registration/registration_address_page.dart';
import 'package:cadastro_beneficios/presentation/pages/registration/registration_password_page.dart';
import 'package:cadastro_beneficios/presentation/pages/complete_profile_page.dart';
import 'package:cadastro_beneficios/presentation/pages/home/home_page.dart';
import 'package:cadastro_beneficios/core/router/page_transitions.dart';
import 'package:cadastro_beneficios/core/di/service_locator.dart';

/// Configuração de rotas do aplicativo
class AppRouter {
  /// Verifica se o usuário está autenticado
  static Future<bool> _isAuthenticated() async {
    // Usar a mesma instância do TokenService do service locator
    return await sl.tokenService.hasToken();
  }

  static final GoRouter router = GoRouter(
    initialLocation: '/splash',
    redirect: (context, state) async {
      // Não redireciona o splash screen
      if (state.matchedLocation == '/splash') {
        return null;
      }

      final isAuthenticated = await _isAuthenticated();
      final isAuthRoute = state.matchedLocation == '/login' ||
          state.matchedLocation == '/register' ||
          state.matchedLocation == '/forgot-password';
      final isRegistrationRoute = state.matchedLocation.startsWith('/registration');
      final isCompleteProfileRoute = state.matchedLocation == '/complete-profile';
      final isPublicRoute = state.matchedLocation == '/' ||
          state.matchedLocation == '/partners' ||
          isAuthRoute ||
          isRegistrationRoute;

      // Se está autenticado, verificar se o perfil está completo
      if (isAuthenticated) {
        try {
          debugPrint('🔍 [Router] Navegando para: ${state.matchedLocation}');
          debugPrint('🔍 [Router] Buscando usuário atual...');
          final userResult = await sl.authRepository.getCurrentUser();

          return userResult.fold(
            (failure) {
              debugPrint('❌ [Router] Erro ao buscar usuário: ${failure.message}');
              return '/login'; // Se falhar ao buscar usuário, volta ao login
            },
            (user) {
              debugPrint('✅ [Router] Usuário carregado: ${user.email}');
              debugPrint('   isProfileComplete: ${user.isProfileComplete}');
              debugPrint('   profileCompletionStatus: ${user.profileCompletionStatus}');

              // Se perfil incompleto e não está na página de completar
              if (!user.isProfileComplete && !isCompleteProfileRoute) {
                debugPrint('→ [Router] Redirecionando para /complete-profile (perfil incompleto)');
                return '/complete-profile';
              }

              // Se perfil completo e está tentando acessar login/register
              if (user.isProfileComplete && (isAuthRoute || isRegistrationRoute)) {
                debugPrint('→ [Router] Redirecionando para /home (perfil completo, saindo de auth)');
                return '/home';
              }

              // Se perfil completo e está na página de completar perfil
              if (user.isProfileComplete && isCompleteProfileRoute) {
                debugPrint('→ [Router] Redirecionando para /home (perfil completo, saindo de complete-profile)');
                return '/home';
              }

              debugPrint('✅ [Router] Navegação permitida para ${state.matchedLocation}');
              return null; // Permite a navegação
            },
          );
        } catch (e) {
          debugPrint('⚠️ [Router] Erro no redirect: $e');
          // Em caso de erro, permite a navegação
          return null;
        }
      }

      // Se não está autenticado e tentando acessar rota protegida, redireciona para login
      if (!isAuthenticated && !isPublicRoute && !isCompleteProfileRoute) {
        return '/login';
      }

      // Se não está autenticado e tentando acessar complete-profile
      if (!isAuthenticated && isCompleteProfileRoute) {
        return '/login';
      }

      // Permite a navegação
      return null;
    },
    routes: [
      // ===== Rotas Públicas =====

      // Splash Screen (primeira tela ao abrir o app)
      GoRoute(
        path: '/splash',
        name: 'splash',
        builder: (context, state) => const SplashScreen(),
      ),

      // Landing Page
      GoRoute(
        path: '/',
        name: 'landing',
        builder: (context, state) => const LandingPageNew(),
      ),

      // Login
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginPage(),
      ),

      // Recuperar senha
      GoRoute(
        path: '/forgot-password',
        name: 'forgot-password',
        builder: (context, state) => const ForgotPasswordPage(),
      ),

      // Cadastro - Introdução
      GoRoute(
        path: '/register',
        name: 'register',
        pageBuilder: (context, state) => PageTransitions.scaleTransition(
          child: const RegistrationIntroPage(),
          state: state,
        ),
      ),

      // Cadastro - Identificação (Passo 1)
      GoRoute(
        path: '/registration/identification',
        name: 'registration-identification',
        pageBuilder: (context, state) => PageTransitions.registrationTransition(
          child: const RegistrationIdentificationPage(),
          state: state,
        ),
      ),

      // Cadastro - Endereço (Passo 2)
      GoRoute(
        path: '/registration/address',
        name: 'registration-address',
        pageBuilder: (context, state) => PageTransitions.registrationTransition(
          child: const RegistrationAddressPage(),
          state: state,
        ),
      ),

      // Cadastro - Senha (Passo 3)
      GoRoute(
        path: '/registration/password',
        name: 'registration-password',
        pageBuilder: (context, state) => PageTransitions.registrationTransition(
          child: const RegistrationPasswordPage(),
          state: state,
        ),
      ),

      // Lista de Parceiros (público)
      GoRoute(
        path: '/partners',
        name: 'partners',
        builder: (context, state) => Scaffold(
          appBar: AppBar(title: const Text('Parceiros')),
          body: const Center(
            child: Text('Lista de Parceiros em desenvolvimento'),
          ),
        ),
      ),

      // ===== Rotas Protegidas (requerem autenticação) =====

      // Completar Perfil (para usuários OAuth com perfil incompleto)
      GoRoute(
        path: '/complete-profile',
        name: 'complete-profile',
        builder: (context, state) => const CompleteProfilePage(),
      ),

      // Home do Cliente (PROTEGIDO)
      GoRoute(
        path: '/home',
        name: 'home',
        builder: (context, state) => const HomePage(),
      ),

      // Dashboard Admin (PROTEGIDO)
      GoRoute(
        path: '/admin',
        name: 'admin',
        builder: (context, state) => Scaffold(
          appBar: AppBar(title: const Text('Admin')),
          body: const Center(
            child: Text('Dashboard Admin em desenvolvimento'),
          ),
        ),
      ),
    ],

    // Tratamento de erros
    errorBuilder: (context, state) => const LandingPageNew(),
  );
}
