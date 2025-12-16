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
import 'package:cadastro_beneficios/core/services/token_service.dart';

/// Configuração de rotas do aplicativo
class AppRouter {
  static final TokenService _tokenService = TokenService();

  /// Verifica se o usuário está autenticado
  static Future<bool> _isAuthenticated() async {
    return await _tokenService.hasToken();
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
      final isPublicRoute = state.matchedLocation == '/' ||
          state.matchedLocation == '/partners' ||
          isAuthRoute ||
          isRegistrationRoute;

      // Se está autenticado e tentando acessar rota de autenticação, redireciona para home
      if (isAuthenticated && isAuthRoute) {
        return '/home';
      }

      // Se não está autenticado e tentando acessar rota protegida, redireciona para login
      if (!isAuthenticated && !isPublicRoute) {
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
        builder: (context, state) => const RegistrationIntroPage(),
      ),

      // Cadastro - Identificação
      GoRoute(
        path: '/registration/identification',
        name: 'registration-identification',
        builder: (context, state) => const RegistrationIdentificationPage(),
      ),

      // Cadastro - Endereço
      GoRoute(
        path: '/registration/address',
        name: 'registration-address',
        builder: (context, state) => const RegistrationAddressPage(),
      ),

      // Cadastro - Senha
      GoRoute(
        path: '/registration/password',
        name: 'registration-password',
        builder: (context, state) => const RegistrationPasswordPage(),
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

      // Home do Cliente (PROTEGIDO)
      GoRoute(
        path: '/home',
        name: 'home',
        builder: (context, state) => Scaffold(
          appBar: AppBar(title: const Text('Área do Cliente')),
          body: const Center(
            child: Text('Página Home em desenvolvimento'),
          ),
        ),
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
