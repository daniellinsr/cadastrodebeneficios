import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:animate_do/animate_do.dart';
import 'package:cadastro_beneficios/core/theme/app_colors.dart';
import 'package:cadastro_beneficios/core/theme/app_text_styles.dart';
import 'package:cadastro_beneficios/core/services/token_service.dart';

/// Splash Screen animado com verificação de autenticação
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  final TokenService _tokenService = TokenService();

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _checkAuthAndNavigate();
  }

  void _setupAnimations() {
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.5,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutBack,
      ),
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.5, curve: Curves.easeIn),
      ),
    );

    _controller.forward();
  }

  Future<void> _checkAuthAndNavigate() async {
    // Aguarda pelo menos 2 segundos para mostrar o splash screen
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    try {
      final hasToken = await _tokenService.hasToken();

      if (!mounted) return;

      if (hasToken) {
        // Usuário autenticado - vai para home
        context.go('/home');
      } else {
        // Usuário não autenticado - vai para landing page
        context.go('/');
      }
    } catch (e) {
      // Em caso de erro, vai para landing page
      if (mounted) {
        context.go('/');
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.primaryBlue,
              Color(0xFF0C63E4),
              Color(0xFF0A4FB8),
            ],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo animado com escala e fade
              AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _scaleAnimation.value,
                    child: Opacity(
                      opacity: _fadeAnimation.value,
                      child: child,
                    ),
                  );
                },
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.2),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.card_giftcard,
                    size: 60,
                    color: AppColors.primaryBlue,
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // Título animado
              FadeInUp(
                delay: const Duration(milliseconds: 500),
                duration: const Duration(milliseconds: 800),
                child: Text(
                  'Cadastro de Benefícios',
                  style: AppTextStyles.h2.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),

              const SizedBox(height: 12),

              // Subtítulo animado
              FadeInUp(
                delay: const Duration(milliseconds: 700),
                duration: const Duration(milliseconds: 800),
                child: Text(
                  'Seu cartão de benefícios digital',
                  style: AppTextStyles.bodyLarge.copyWith(
                    color: Colors.white.withValues(alpha: 0.9),
                  ),
                  textAlign: TextAlign.center,
                ),
              ),

              const SizedBox(height: 60),

              // Loading indicator animado
              FadeIn(
                delay: const Duration(milliseconds: 1000),
                duration: const Duration(milliseconds: 800),
                child: const SizedBox(
                  width: 40,
                  height: 40,
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    strokeWidth: 3,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
