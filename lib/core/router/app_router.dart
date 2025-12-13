import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:cadastro_beneficios/presentation/pages/landing_page.dart';
import 'package:cadastro_beneficios/presentation/pages/auth/login_page.dart';
import 'package:cadastro_beneficios/presentation/pages/auth/forgot_password_page.dart';

/// Configuração de rotas do aplicativo
class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/',
    routes: [
      // ===== Rotas Públicas =====

      // Tela inicial
      GoRoute(
        path: '/',
        name: 'landing',
        builder: (context, state) => const LandingPage(),
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

      // Cadastro (a ser implementado)
      GoRoute(
        path: '/register',
        name: 'register',
        builder: (context, state) => Scaffold(
          appBar: AppBar(title: const Text('Cadastro')),
          body: const Center(
            child: Text('Página de Cadastro em desenvolvimento'),
          ),
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

      // Home do Cliente
      GoRoute(
        path: '/home',
        name: 'home',
        builder: (context, state) => Scaffold(
          appBar: AppBar(title: const Text('Área do Cliente')),
          body: const Center(
            child: Text('Página Home em desenvolvimento'),
          ),
        ),
        // TODO: Adicionar redirect para /login se não autenticado
      ),

      // Dashboard Admin
      GoRoute(
        path: '/admin',
        name: 'admin',
        builder: (context, state) => Scaffold(
          appBar: AppBar(title: const Text('Admin')),
          body: const Center(
            child: Text('Dashboard Admin em desenvolvimento'),
          ),
        ),
        // TODO: Adicionar redirect para /login se não autenticado ou não admin
      ),
    ],

    // Tratamento de erros
    errorBuilder: (context, state) => const LandingPage(),
  );
}
