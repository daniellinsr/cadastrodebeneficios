import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:cadastro_beneficios/core/theme/app_colors.dart';
import 'package:cadastro_beneficios/core/theme/app_text_styles.dart';
import 'package:cadastro_beneficios/core/theme/app_spacing.dart';
import 'package:cadastro_beneficios/core/utils/responsive_utils.dart';
import 'package:cadastro_beneficios/presentation/bloc/auth/auth_bloc.dart';
import 'package:cadastro_beneficios/presentation/bloc/auth/auth_event.dart';
import 'package:cadastro_beneficios/presentation/bloc/auth/auth_state.dart';
import 'package:cadastro_beneficios/presentation/widgets/buttons/custom_button.dart';
import 'package:cadastro_beneficios/presentation/widgets/inputs/custom_text_field.dart';
import 'package:cadastro_beneficios/presentation/widgets/feedback/feedback_widgets.dart';

/// Tela de Recuperação de Senha
///
/// Permite solicitar email de recuperação de senha
class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _onSendPressed() {
    if (_formKey.currentState!.validate()) {
      context.read<AuthBloc>().add(
            AuthForgotPasswordRequested(
              email: _emailController.text.trim(),
            ),
          );
    }
  }

  void _onBackToLogin() {
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Recuperar Senha'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: _onBackToLogin,
        ),
      ),
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthError) {
            CustomSnackBar.show(
              context,
              message: state.message,
              type: SnackBarType.error,
            );
          } else if (state is AuthPasswordResetEmailSent) {
            CustomSnackBar.show(
              context,
              message: 'Email de recuperação enviado para ${state.email}',
              type: SnackBarType.success,
            );

            // Aguardar 2 segundos e voltar para login
            Future.delayed(const Duration(seconds: 2), () {
              if (mounted) {
                context.pop();
              }
            });
          }
        },
        builder: (context, state) {
          final isLoading = state is AuthLoading;
          final emailSent = state is AuthPasswordResetEmailSent;

          return SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(
                  ResponsiveUtils.valueWhen(
                    context: context,
                    mobile: AppSpacing.lg,
                    tablet: AppSpacing.xl,
                    desktop: AppSpacing.xxl,
                  ),
                ),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 400),
                  child: emailSent
                      ? _buildSuccessView(state as AuthPasswordResetEmailSent)
                      : _buildFormView(isLoading),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  /// View do formulário
  Widget _buildFormView(bool isLoading) {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Ícone
          Icon(
            Icons.lock_reset,
            size: ResponsiveUtils.valueWhen(
              context: context,
              mobile: 80,
              tablet: 100,
              desktop: 120,
            ),
            color: AppColors.primaryBlue,
          ),
          const SizedBox(height: AppSpacing.xl),

          // Título
          Text(
            'Esqueceu sua senha?',
            style: AppTextStyles.h2.copyWith(
              color: AppColors.darkGray,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.sm),

          // Descrição
          Text(
            'Não se preocupe! Digite seu email e enviaremos instruções para redefinir sua senha.',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.gray600,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.xxl),

          // Campo de Email
          CustomTextField(
            controller: _emailController,
            label: 'Email',
            hint: 'seuemail@exemplo.com',
            type: CustomTextFieldType.email,
            prefixIcon: Icons.email_outlined,
            enabled: !isLoading,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Email é obrigatório';
              }
              final emailRegex = RegExp(
                r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
              );
              if (!emailRegex.hasMatch(value)) {
                return 'Email inválido';
              }
              return null;
            },
          ),
          const SizedBox(height: AppSpacing.xl),

          // Botão de Enviar
          CustomButton(
            text: 'Enviar Email de Recuperação',
            onPressed: isLoading ? null : _onSendPressed,
            isLoading: isLoading,
            type: CustomButtonType.primary,
            isFullWidth: true,
          ),
          const SizedBox(height: AppSpacing.lg),

          // Botão Voltar
          CustomButton(
            text: 'Voltar ao Login',
            onPressed: isLoading ? null : _onBackToLogin,
            type: CustomButtonType.text,
            isFullWidth: true,
          ),
        ],
      ),
    );
  }

  /// View de sucesso (email enviado)
  Widget _buildSuccessView(AuthPasswordResetEmailSent state) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Ícone de sucesso
        Container(
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            color: AppColors.success.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.check_circle_outline,
            size: ResponsiveUtils.valueWhen(
              context: context,
              mobile: 80,
              tablet: 100,
              desktop: 120,
            ),
            color: AppColors.success,
          ),
        ),
        const SizedBox(height: AppSpacing.xxl),

        // Título
        Text(
          'Email Enviado!',
          style: AppTextStyles.h2.copyWith(
            color: AppColors.darkGray,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppSpacing.md),

        // Descrição
        Text(
          'Enviamos instruções para redefinir sua senha para:',
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.gray600,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppSpacing.sm),

        // Email
        Text(
          state.email,
          style: AppTextStyles.bodyLarge.copyWith(
            color: AppColors.primaryBlue,
            fontWeight: FontWeight.w600,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppSpacing.md),

        // Instruções
        Text(
          'Verifique sua caixa de entrada e siga as instruções. Se não receber o email em alguns minutos, verifique sua pasta de spam.',
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.gray500,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppSpacing.xxl),

        // Botão Voltar
        CustomButton(
          text: 'Voltar ao Login',
          onPressed: _onBackToLogin,
          type: CustomButtonType.primary,
          isFullWidth: true,
        ),
      ],
    );
  }
}
