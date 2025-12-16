import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:animate_do/animate_do.dart';
import 'package:cadastro_beneficios/core/theme/app_colors.dart';
import 'package:cadastro_beneficios/core/theme/app_text_styles.dart';
import 'package:cadastro_beneficios/core/theme/responsive_utils.dart';
import 'package:url_launcher/url_launcher.dart';

/// Landing Page moderna e responsiva com animações
class LandingPageNew extends StatefulWidget {
  const LandingPageNew({super.key});

  @override
  State<LandingPageNew> createState() => _LandingPageNewState();
}

class _LandingPageNewState extends State<LandingPageNew> {
  final ScrollController _scrollController = ScrollController();
  bool _showScrollToTop = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scrollListener);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollListener() {
    if (_scrollController.offset > 300 && !_showScrollToTop) {
      setState(() => _showScrollToTop = true);
    } else if (_scrollController.offset <= 300 && _showScrollToTop) {
      setState(() => _showScrollToTop = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background gradient
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.primaryBlue.withOpacity(0.05),
                  AppColors.white,
                  AppColors.accentOrange.withOpacity(0.05),
                ],
              ),
            ),
          ),

          // Content
          CustomScrollView(
            controller: _scrollController,
            slivers: [
              // App Bar
              _buildAppBar(context),

              // Content
              SliverToBoxAdapter(
                child: Column(
                  children: [
                    _buildHeroSection(context),
                    _buildFeaturesSection(context),
                    _buildBenefitsSection(context),
                    _buildCTASection(context),
                    _buildFooter(context),
                  ],
                ),
              ),
            ],
          ),

          // Scroll to top button
          if (_showScrollToTop)
            Positioned(
              right: 16,
              bottom: 80,
              child: FadeInUp(
                child: FloatingActionButton(
                  mini: true,
                  onPressed: () {
                    _scrollController.animateTo(
                      0,
                      duration: const Duration(milliseconds: 500),
                      curve: Curves.easeInOut,
                    );
                  },
                  child: const Icon(Icons.arrow_upward),
                ),
              ),
            ),
        ],
      ),
      floatingActionButton: _buildWhatsAppButton(),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return SliverAppBar(
      floating: true,
      snap: true,
      elevation: 0,
      backgroundColor: AppColors.white.withOpacity(0.95),
      title: FadeInDown(
        child: Row(
          children: [
            Icon(
              Icons.card_membership_rounded,
              color: AppColors.primaryBlue,
              size: 28,
            ),
            const SizedBox(width: 8),
            Text(
              'Benefícios',
              style: AppTextStyles.h3.copyWith(
                color: AppColors.primaryBlue,
              ),
            ),
          ],
        ),
      ),
      actions: [
        FadeInDown(
          delay: const Duration(milliseconds: 100),
          child: TextButton.icon(
            onPressed: () => context.go('/login'),
            icon: const Icon(Icons.login),
            label: const Text('Entrar'),
          ),
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildHeroSection(BuildContext context) {
    final isMobile = ResponsiveUtils.isMobile(context);

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: ResponsiveUtils.horizontalPadding(context),
        vertical: isMobile ? 60 : 100,
      ),
      child: Center(
        child: Container(
          constraints: BoxConstraints(
            maxWidth: ResponsiveUtils.maxContentWidth(context),
          ),
          child: isMobile
              ? _buildHeroContentMobile(context)
              : _buildHeroContentDesktop(context),
        ),
      ),
    );
  }

  Widget _buildHeroContentMobile(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Icon animado
        FadeInDown(
          duration: const Duration(milliseconds: 600),
          child: Container(
            padding: const EdgeInsets.all(30),
            decoration: BoxDecoration(
              color: AppColors.primaryBlue.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.card_membership_rounded,
              size: 80,
              color: AppColors.primaryBlue,
            ),
          ),
        ),
        const SizedBox(height: 40),

        // Título
        FadeInUp(
          delay: const Duration(milliseconds: 200),
          child: Text(
            'Seus Benefícios,\nNossa Prioridade',
            style: AppTextStyles.h1.copyWith(
              fontSize: 36,
              height: 1.2,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(height: 16),

        // Subtítulo
        FadeInUp(
          delay: const Duration(milliseconds: 400),
          child: Text(
            'Acesso fácil e rápido a saúde, bem-estar e serviços essenciais com seu cartão de benefícios digital.',
            style: AppTextStyles.bodyLarge.copyWith(
              color: AppColors.darkGray.withOpacity(0.8),
              height: 1.6,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(height: 40),

        // Botões
        _buildHeroButtons(context),
      ],
    );
  }

  Widget _buildHeroContentDesktop(BuildContext context) {
    return Row(
      children: [
        // Coluna esquerda - Texto
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              FadeInLeft(
                child: Text(
                  'Seus Benefícios,\nNossa Prioridade',
                  style: AppTextStyles.h1.copyWith(
                    fontSize: 48,
                    height: 1.2,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              FadeInLeft(
                delay: const Duration(milliseconds: 200),
                child: Text(
                  'Acesso fácil e rápido a saúde, bem-estar e serviços essenciais com seu cartão de benefícios digital.',
                  style: AppTextStyles.bodyLarge.copyWith(
                    color: AppColors.darkGray.withOpacity(0.8),
                    height: 1.6,
                  ),
                ),
              ),
              const SizedBox(height: 40),
              _buildHeroButtons(context),
            ],
          ),
        ),
        const SizedBox(width: 60),

        // Coluna direita - Ilustração
        Expanded(
          child: FadeInRight(
            child: Container(
              padding: const EdgeInsets.all(40),
              decoration: BoxDecoration(
                color: AppColors.primaryBlue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(
                Icons.health_and_safety_rounded,
                size: 200,
                color: AppColors.primaryBlue.withOpacity(0.3),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeroButtons(BuildContext context) {
    return FadeInUp(
      delay: const Duration(milliseconds: 600),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ElevatedButton(
            onPressed: () => context.go('/register'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
              backgroundColor: AppColors.primaryBlue,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.person_add),
                const SizedBox(width: 8),
                Text(
                  'Cadastre-se Grátis',
                  style: AppTextStyles.button,
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          OutlinedButton(
            onPressed: () => context.go('/login'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.login),
                const SizedBox(width: 8),
                Text(
                  'Já sou cadastrado',
                  style: AppTextStyles.button.copyWith(
                    color: AppColors.primaryBlue,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeaturesSection(BuildContext context) {
    final features = [
      {
        'icon': Icons.medical_services_rounded,
        'title': 'Saúde',
        'description': 'Consultas, exames e medicamentos com desconto',
      },
      {
        'icon': Icons.fitness_center_rounded,
        'title': 'Bem-estar',
        'description': 'Academias, spas e atividades físicas',
      },
      {
        'icon': Icons.store_rounded,
        'title': 'Compras',
        'description': 'Descontos em lojas parceiras',
      },
      {
        'icon': Icons.restaurant_rounded,
        'title': 'Alimentação',
        'description': 'Restaurantes e delivery com vantagens',
      },
    ];

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: ResponsiveUtils.horizontalPadding(context),
        vertical: 80,
      ),
      color: AppColors.lightGray.withOpacity(0.3),
      child: Center(
        child: Container(
          constraints: BoxConstraints(
            maxWidth: ResponsiveUtils.maxContentWidth(context),
          ),
          child: Column(
            children: [
              FadeInUp(
                child: Text(
                  'Nossos Benefícios',
                  style: AppTextStyles.h2,
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 16),
              FadeInUp(
                delay: const Duration(milliseconds: 200),
                child: Text(
                  'Acesse uma rede completa de parceiros',
                  style: AppTextStyles.bodyLarge.copyWith(
                    color: AppColors.darkGray.withOpacity(0.8),
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 60),
              Wrap(
                spacing: 20,
                runSpacing: 20,
                children: features.asMap().entries.map((entry) {
                  return FadeInUp(
                    delay: Duration(milliseconds: 100 * entry.key),
                    child: _buildFeatureCard(
                      icon: entry.value['icon'] as IconData,
                      title: entry.value['title'] as String,
                      description: entry.value['description'] as String,
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureCard({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Container(
      width: 250,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.darkGray.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.primaryBlue.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: 40,
              color: AppColors.primaryBlue,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: AppTextStyles.h4,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            description,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.darkGray.withOpacity(0.7),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildBenefitsSection(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: ResponsiveUtils.horizontalPadding(context),
        vertical: 80,
      ),
      child: Center(
        child: Container(
          constraints: BoxConstraints(
            maxWidth: ResponsiveUtils.maxContentWidth(context),
          ),
          child: Column(
            children: [
              FadeInUp(
                child: Text(
                  'Por que escolher nosso cartão?',
                  style: AppTextStyles.h2,
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 60),
              _buildBenefitItem(
                index: 0,
                icon: Icons.smartphone_rounded,
                title: '100% Digital',
                description:
                    'Sem burocracia. Tudo no seu celular, rápido e fácil.',
              ),
              const SizedBox(height: 32),
              _buildBenefitItem(
                index: 1,
                icon: Icons.security_rounded,
                title: 'Seguro e Confiável',
                description:
                    'Seus dados protegidos com criptografia de ponta.',
              ),
              const SizedBox(height: 32),
              _buildBenefitItem(
                index: 2,
                icon: Icons.payments_rounded,
                title: 'Economia Garantida',
                description:
                    'Até 50% de desconto em serviços essenciais.',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBenefitItem({
    required int index,
    required IconData icon,
    required String title,
    required String description,
  }) {
    return FadeInLeft(
      delay: Duration(milliseconds: 200 * index),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.accentOrange.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              icon,
              size: 40,
              color: AppColors.accentOrange,
            ),
          ),
          const SizedBox(width: 24),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.h4,
                ),
                const SizedBox(height: 8),
                Text(
                  description,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.darkGray.withOpacity(0.8),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCTASection(BuildContext context) {
    return FadeInUp(
      child: Container(
        margin: EdgeInsets.symmetric(
          horizontal: ResponsiveUtils.horizontalPadding(context),
          vertical: 80,
        ),
        padding: const EdgeInsets.all(60),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.primaryBlue,
              AppColors.primaryBlue.withOpacity(0.8),
            ],
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          children: [
            Text(
              'Pronto para começar?',
              style: AppTextStyles.h2.copyWith(color: AppColors.white),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              'Cadastre-se agora e aproveite todos os benefícios',
              style: AppTextStyles.bodyLarge.copyWith(
                color: AppColors.white.withOpacity(0.9),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () => context.go('/register'),
              style: ElevatedButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(vertical: 16, horizontal: 48),
                backgroundColor: AppColors.white,
                foregroundColor: AppColors.primaryBlue,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'Cadastrar Agora',
                style: AppTextStyles.button.copyWith(
                  color: AppColors.primaryBlue,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFooter(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: ResponsiveUtils.horizontalPadding(context),
        vertical: 40,
      ),
      color: AppColors.darkGray.withOpacity(0.05),
      child: Column(
        children: [
          Text(
            '© 2025 Sistema de Cartão de Benefícios',
            style: AppTextStyles.caption.copyWith(
              color: AppColors.darkGray.withOpacity(0.6),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Todos os direitos reservados',
            style: AppTextStyles.caption.copyWith(
              color: AppColors.darkGray.withOpacity(0.6),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWhatsAppButton() {
    return FadeInUp(
      delay: const Duration(milliseconds: 1000),
      child: FloatingActionButton.extended(
        onPressed: _openWhatsApp,
        backgroundColor: AppColors.success,
        icon: const Icon(Icons.chat),
        label: const Text('WhatsApp'),
      ),
    );
  }

  void _openWhatsApp() async {
    const phone = '5561999999999'; // TODO: Substituir pelo número real
    const message = 'Olá! Gostaria de saber mais sobre os benefícios.';

    final uri = Uri.parse(
      'https://wa.me/$phone?text=${Uri.encodeComponent(message)}',
    );

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}
