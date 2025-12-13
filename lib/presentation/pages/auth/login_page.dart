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

/// Tela de Login
///
/// Permite login com email/senha ou Google
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _onLoginPressed() {
    if (_formKey.currentState!.validate()) {
      context.read<AuthBloc>().add(
            AuthLoginWithEmailRequested(
              email: _emailController.text.trim(),
              password: _passwordController.text,
            ),
          );
    }
  }

  void _onGoogleLoginPressed() {
    context.read<AuthBloc>().add(const AuthLoginWithGoogleRequested());
  }

  void _onForgotPasswordPressed() {
    context.push('/forgot-password');
  }

  void _onRegisterPressed() {
    context.push('/register');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthError) {
            CustomSnackBar.show(
              context,
              message: state.message,
              type: SnackBarType.error,
            );
          } else if (state is AuthAuthenticated) {
            // Navegar para home
            context.go('/home');
          }
        },
        builder: (context, state) {
          final isLoading = state is AuthLoading;

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
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Logo
                        Icon(
                          Icons.card_membership,
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
                          'Bem-vindo de volta!',
                          style: AppTextStyles.h2.copyWith(
                            color: AppColors.darkGray,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: AppSpacing.sm),

                        Text(
                          'Faça login para continuar',
                          style: AppTextStyles.bodyLarge.copyWith(
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
                        const SizedBox(height: AppSpacing.md),

                        // Campo de Senha
                        CustomTextField(
                          controller: _passwordController,
                          label: 'Senha',
                          hint: '••••••••',
                          type: CustomTextFieldType.password,
                          prefixIcon: Icons.lock_outline,
                          enabled: !isLoading,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Senha é obrigatória';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: AppSpacing.sm),

                        // Link "Esqueci minha senha"
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: isLoading ? null : _onForgotPasswordPressed,
                            child: Text(
                              'Esqueci minha senha',
                              style: AppTextStyles.bodyMedium.copyWith(
                                color: AppColors.primaryBlue,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.lg),

                        // Botão de Login
                        CustomButton(
                          text: 'Entrar',
                          onPressed: isLoading ? null : _onLoginPressed,
                          isLoading: isLoading,
                          type: CustomButtonType.primary,
                          isFullWidth: true,
                        ),
                        const SizedBox(height: AppSpacing.lg),

                        // Divider "ou"
                        Row(
                          children: [
                            const Expanded(
                              child: Divider(color: AppColors.gray300),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppSpacing.md,
                              ),
                              child: Text(
                                'ou',
                                style: AppTextStyles.bodyMedium.copyWith(
                                  color: AppColors.gray600,
                                ),
                              ),
                            ),
                            const Expanded(
                              child: Divider(color: AppColors.gray300),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.lg),

                        // Botão Google
                        CustomButton(
                          text: 'Continuar com Google',
                          onPressed: isLoading ? null : _onGoogleLoginPressed,
                          type: CustomButtonType.outline,
                          icon: Icons.g_mobiledata,
                          isFullWidth: true,
                        ),
                        const SizedBox(height: AppSpacing.xxl),

                        // Link para cadastro
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Não tem uma conta? ',
                              style: AppTextStyles.bodyMedium.copyWith(
                                color: AppColors.gray600,
                              ),
                            ),
                            TextButton(
                              onPressed: isLoading ? null : _onRegisterPressed,
                              child: Text(
                                'Cadastre-se',
                                style: AppTextStyles.bodyMedium.copyWith(
                                  color: AppColors.primaryBlue,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
