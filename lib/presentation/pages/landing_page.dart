import 'package:flutter/material.dart';
import 'package:cadastro_beneficios/core/theme/app_colors.dart';
import 'package:cadastro_beneficios/core/theme/app_text_styles.dart';
import 'package:cadastro_beneficios/core/theme/app_spacing.dart';
import 'package:cadastro_beneficios/core/theme/responsive_utils.dart';
import 'package:url_launcher/url_launcher.dart';

class LandingPage extends StatelessWidget {
  const LandingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Container(
            constraints: BoxConstraints(
              maxWidth: ResponsiveUtils.maxContentWidth(context),
            ),
            padding: EdgeInsets.all(ResponsiveUtils.horizontalPadding(context)),
            child: ResponsiveLayout(
              mobile: _buildContent(context),
              tablet: _buildContent(context),
              desktop: _buildContent(context),
            ),
          ),
        ),
      ),
      floatingActionButton: _buildWhatsAppButton(),
    );
  }

  Widget _buildContent(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Logo
        Icon(
          Icons.card_membership_rounded,
          size: ResponsiveUtils.valueWhen(
            context: context,
            mobile: 80,
            tablet: 100,
            desktop: 120,
          ),
          color: AppColors.primaryBlue,
        ),
        const SizedBox(height: AppSpacing.xxl),

        // Título
        Text(
          'Sistema de Cartão de Benefícios',
          style: ResponsiveUtils.valueWhen(
            context: context,
            mobile: AppTextStyles.h2,
            tablet: AppTextStyles.h1,
            desktop: AppTextStyles.h1,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppSpacing.md),

        // Subtítulo
        Text(
          'Facilitamos seu acesso a benefícios exclusivos em saúde, bem-estar e serviços essenciais.',
          style: AppTextStyles.bodyLarge.copyWith(
            color: AppColors.darkGrayWithOpacity(0.8),
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppSpacing.xxl),

        // Botão: Já sou cadastrado
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () {
              // TODO: Navegar para tela de login
              _showComingSoonSnackbar(context, 'Login');
            },
            icon: const Icon(Icons.login),
            label: const Text('Já sou cadastrado'),
          ),
        ),
        const SizedBox(height: AppSpacing.md),

        // Botão: Cadastre-se
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () {
              // TODO: Navegar para fluxo de cadastro
              _showComingSoonSnackbar(context, 'Cadastro');
            },
            icon: const Icon(Icons.person_add),
            label: const Text('Cadastre-se'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.success,
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.md),

        // Botão: Lista de Parceiros
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () {
              // TODO: Navegar para lista de parceiros
              _showComingSoonSnackbar(context, 'Lista de Parceiros');
            },
            icon: const Icon(Icons.store),
            label: const Text('Lista de Parceiros'),
          ),
        ),
      ],
    );
  }

  Widget _buildWhatsAppButton() {
    return FloatingActionButton.extended(
      onPressed: () => _openWhatsApp(),
      backgroundColor: AppColors.whatsapp,
      icon: const Icon(Icons.chat),
      label: const Text('WhatsApp'),
    );
  }

  void _openWhatsApp() async {
    // TODO: Substituir pelo número real do WhatsApp
    const phone = '5561999999999';
    const message = 'Olá! Gostaria de saber mais sobre os benefícios.';

    final uri = Uri.parse(
      'https://wa.me/$phone?text=${Uri.encodeComponent(message)}',
    );

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  void _showComingSoonSnackbar(BuildContext context, String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$feature - Em breve!'),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}
