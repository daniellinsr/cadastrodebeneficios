import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:animate_do/animate_do.dart';
import 'package:cadastro_beneficios/core/theme/app_colors.dart';
import 'package:cadastro_beneficios/core/theme/app_text_styles.dart';
import 'package:cadastro_beneficios/core/theme/responsive_utils.dart';
import 'package:cadastro_beneficios/core/services/registration_draft_service.dart';
import 'package:cadastro_beneficios/presentation/widgets/registration_draft_dialog.dart';
import 'package:cadastro_beneficios/presentation/bloc/auth/auth_bloc.dart';
import 'package:cadastro_beneficios/presentation/bloc/auth/auth_event.dart';
import 'package:cadastro_beneficios/presentation/bloc/auth/auth_state.dart';
import 'package:cadastro_beneficios/presentation/widgets/feedback/feedback_widgets.dart';
import 'package:url_launcher/url_launcher.dart';

/// Tela de introdução ao cadastro
/// Primeira tela do fluxo de cadastro com mensagem de boas-vindas
class RegistrationIntroPage extends StatefulWidget {
  const RegistrationIntroPage({super.key});

  @override
  State<RegistrationIntroPage> createState() => _RegistrationIntroPageState();
}

class _RegistrationIntroPageState extends State<RegistrationIntroPage> {
  final RegistrationDraftService _draftService = RegistrationDraftService();

  @override
  void initState() {
    super.initState();
    _checkForDraft();
  }

  Future<void> _checkForDraft() async {
    // Aguarda um momento para a tela carregar
    await Future.delayed(const Duration(milliseconds: 500));

    if (!mounted) return;

    final hasDraft = await _draftService.hasDraft();
    if (!hasDraft) return;

    final isExpired = await _draftService.isDraftExpired();
    if (isExpired) {
      await _draftService.clearDraft();
      return;
    }

    final summary = await _draftService.getDraftSummary();
    final progress = await _draftService.getDraftProgress();

    if (!mounted || summary == null) return;

    final shouldContinue = await RegistrationDraftDialog.show(
      context: context,
      draftSummary: summary,
      progressPercentage: progress,
    );

    if (!mounted) return;

    if (shouldContinue == true) {
      // Continuar cadastro - vai para identificação que carregará os dados
      context.go('/registration/identification');
    } else if (shouldContinue == false) {
      // Começar novo cadastro - limpa o rascunho
      await _draftService.clearDraft();
    }
  }

  Future<void> _openWhatsApp() async {
    final Uri whatsappUrl = Uri.parse(
      'https://wa.me/5511999999999?text=Olá! Preciso de ajuda com o cadastro.',
    );

    if (await canLaunchUrl(whatsappUrl)) {
      await launchUrl(whatsappUrl, mode: LaunchMode.externalApplication);
    }
  }

  void _handleGoogleSignup() {
    print('🔵 [RegistrationIntroPage] Botão Google clicado');
    // Dispara evento no AuthBloc
    context.read<AuthBloc>().add(const AuthLoginWithGoogleRequested());
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveUtils.isMobile(context);

    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        print('🎯 [RegistrationIntroPage] Estado recebido: ${state.runtimeType}');

        if (state is AuthError) {
          print('❌ [RegistrationIntroPage] Erro: ${state.message}');
          CustomSnackBar.show(
            context,
            message: state.message,
            type: SnackBarType.error,
          );
        } else if (state is AuthAuthenticated) {
          print('✅ [RegistrationIntroPage] AuthAuthenticated recebido!');
          print('   User: ${state.user.email}');
          print('   isProfileComplete: ${state.user.isProfileComplete}');

          // Verificar se o perfil está completo
          if (state.user.isProfileComplete) {
            print('🔀 [RegistrationIntroPage] Redirecionando para /home...');
            context.go('/home');
          } else {
            print('🔀 [RegistrationIntroPage] Redirecionando para /complete-profile...');
            context.go('/complete-profile');
          }
        }
      },
      builder: (context, state) {
        final isLoading = state is AuthLoading;

        return Scaffold(
          body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.primaryBlue,
              Color(0xFF0C63E4),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // AppBar personalizado
              _buildAppBar(context),

              // Conteúdo principal
              Expanded(
                child: Center(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.all(isMobile ? 24.0 : 48.0),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 600),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Logo
                          FadeInDown(
                            delay: const Duration(milliseconds: 200),
                            child: Container(
                              width: 120,
                              height: 120,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(30),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.1),
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

                          const SizedBox(height: 40),

                          // Título
                          FadeInDown(
                            delay: const Duration(milliseconds: 400),
                            child: Text(
                              'Bem-vindo ao seu\nCartão de Benefícios!',
                              style: AppTextStyles.h1.copyWith(
                                color: Colors.white,
                                fontSize: isMobile ? 28 : 32,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),

                          const SizedBox(height: 24),

                          // Descrição
                          FadeInUp(
                            delay: const Duration(milliseconds: 600),
                            child: Text(
                              'Estamos felizes em tê-lo aqui! Com nosso cartão, você terá acesso a:',
                              style: AppTextStyles.bodyLarge.copyWith(
                                color: Colors.white.withValues(alpha: 0.9),
                                fontSize: isMobile ? 16 : 18,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),

                          const SizedBox(height: 32),

                          // Benefícios
                          ..._buildBenefits(),

                          const SizedBox(height: 48),

                          // Mensagem de incentivo
                          FadeInUp(
                            delay: const Duration(milliseconds: 1200),
                            child: Text(
                              'O processo de cadastro leva apenas 5 minutos!',
                              style: AppTextStyles.bodyMedium.copyWith(
                                color: Colors.white.withValues(alpha: 0.8),
                                fontStyle: FontStyle.italic,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),

                          const SizedBox(height: 40),

                          // Botões
                          FadeInUp(
                            delay: const Duration(milliseconds: 1400),
                            child: Column(
                              children: [
                                // Botão principal
                                SizedBox(
                                  width: double.infinity,
                                  height: 56,
                                  child: ElevatedButton(
                                    onPressed: () {
                                      context.go('/registration/identification');
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.white,
                                      foregroundColor: AppColors.primaryBlue,
                                      elevation: 8,
                                      shadowColor: Colors.black.withValues(alpha: 0.3),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        const Icon(Icons.check_circle_outline, size: 24),
                                        const SizedBox(width: 12),
                                        Text(
                                          'Quero Me Cadastrar Agora',
                                          style: AppTextStyles.button.copyWith(
                                            color: AppColors.primaryBlue,
                                            fontSize: 16,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),

                                const SizedBox(height: 16),

                                // Separador "ou"
                                Row(
                                  children: [
                                    Expanded(
                                      child: Divider(
                                        color: Colors.white.withValues(alpha: 0.3),
                                        thickness: 1,
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 16),
                                      child: Text(
                                        'ou',
                                        style: AppTextStyles.bodyMedium.copyWith(
                                          color: Colors.white.withValues(alpha: 0.8),
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: Divider(
                                        color: Colors.white.withValues(alpha: 0.3),
                                        thickness: 1,
                                      ),
                                    ),
                                  ],
                                ),

                                const SizedBox(height: 16),

                                // Botão Google (funciona em todas as plataformas com Firebase Auth)
                                SizedBox(
                                  width: double.infinity,
                                  height: 56,
                                  child: OutlinedButton(
                                    onPressed: isLoading ? null : _handleGoogleSignup,
                                    style: OutlinedButton.styleFrom(
                                      backgroundColor: Colors.white,
                                      foregroundColor: AppColors.darkGray,
                                      side: BorderSide.none,
                                      elevation: 2,
                                      shadowColor: Colors.black.withValues(alpha: 0.1),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Image.asset(
                                          'assets/icons/google_logo.png',
                                          height: 24,
                                          width: 24,
                                          errorBuilder: (context, error, stackTrace) {
                                            // Fallback para ícone se imagem não estiver disponível
                                            return const Icon(
                                              Icons.login,
                                              size: 24,
                                              color: AppColors.primaryBlue,
                                            );
                                          },
                                        ),
                                        const SizedBox(width: 12),
                                        Text(
                                          'Cadastrar com Google',
                                          style: AppTextStyles.button.copyWith(
                                            color: AppColors.darkGray,
                                            fontSize: 16,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),

                                const SizedBox(height: 16),

                                // Botão WhatsApp
                                SizedBox(
                                  width: double.infinity,
                                  height: 56,
                                  child: OutlinedButton(
                                    onPressed: _openWhatsApp,
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: Colors.white,
                                      side: const BorderSide(color: Colors.white, width: 2),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        const Icon(Icons.chat, size: 24),
                                        const SizedBox(width: 12),
                                        Text(
                                          'Falar no WhatsApp',
                                          style: AppTextStyles.button.copyWith(
                                            color: Colors.white,
                                            fontSize: 16,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 24),

                          // Link para voltar
                          FadeIn(
                            delay: const Duration(milliseconds: 1600),
                            child: TextButton(
                              onPressed: () => context.go('/'),
                              child: Text(
                                'Voltar para página inicial',
                                style: AppTextStyles.caption.copyWith(
                                  color: Colors.white.withValues(alpha: 0.8),
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
      },
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => context.go('/'),
          ),
          const Expanded(
            child: Text(
              'Cadastro',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(width: 48), // Para centralizar o título
        ],
      ),
    );
  }

  List<Widget> _buildBenefits() {
    final benefits = [
      {
        'icon': Icons.health_and_safety,
        'title': 'Saúde e Bem-estar',
        'description': 'Descontos em consultas, exames e farmácias',
      },
      {
        'icon': Icons.shopping_bag,
        'title': 'Compras',
        'description': 'Ofertas exclusivas em lojas parceiras',
      },
      {
        'icon': Icons.restaurant,
        'title': 'Alimentação',
        'description': 'Descontos em restaurantes e delivery',
      },
    ];

    return benefits.asMap().entries.map((entry) {
      final index = entry.key;
      final benefit = entry.value;

      return FadeInLeft(
        delay: Duration(milliseconds: 800 + (index * 100)),
        child: Padding(
          padding: const EdgeInsets.only(bottom: 16.0),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.3),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    benefit['icon'] as IconData,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        benefit['title'] as String,
                        style: AppTextStyles.h4.copyWith(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        benefit['description'] as String,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: Colors.white.withValues(alpha: 0.8),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }).toList();
  }
}
