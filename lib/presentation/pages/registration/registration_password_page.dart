import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:animate_do/animate_do.dart';
import 'package:cadastro_beneficios/core/theme/app_colors.dart';
import 'package:cadastro_beneficios/core/theme/app_text_styles.dart';
import 'package:cadastro_beneficios/core/theme/responsive_utils.dart';
import 'package:cadastro_beneficios/core/utils/validators.dart';
import 'package:cadastro_beneficios/core/di/service_locator.dart';

/// Formulário de criação de senha
/// Coleta: Senha e Confirmação de Senha
class RegistrationPasswordPage extends StatefulWidget {
  const RegistrationPasswordPage({super.key});

  @override
  State<RegistrationPasswordPage> createState() =>
      _RegistrationPasswordPageState();
}

class _RegistrationPasswordPageState extends State<RegistrationPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _senhaController = TextEditingController();
  final _confirmacaoSenhaController = TextEditingController();

  bool _isLoading = false;
  bool _obscureSenha = true;
  bool _obscureConfirmacaoSenha = true;
  int _passwordStrength = 0;

  @override
  void initState() {
    super.initState();
    _senhaController.addListener(_updatePasswordStrength);
  }

  @override
  void dispose() {
    _senhaController.removeListener(_updatePasswordStrength);
    _senhaController.dispose();
    _confirmacaoSenhaController.dispose();
    super.dispose();
  }

  void _updatePasswordStrength() {
    setState(() {
      _passwordStrength =
          Validators.calculatePasswordStrength(_senhaController.text);
    });
  }

  Color _getStrengthColor() {
    switch (_passwordStrength) {
      case 0:
      case 1:
        return Colors.red;
      case 2:
        return Colors.orange;
      case 3:
        return Colors.yellow[700]!;
      case 4:
        return Colors.lightGreen;
      case 5:
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  double _getStrengthProgress() {
    return _passwordStrength / 5.0;
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Verifica se a senha é forte o suficiente
    if (_passwordStrength < 3) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
              'Por favor, escolha uma senha mais forte (mínimo: Média)'),
          backgroundColor: Colors.orange,
          duration: Duration(seconds: 3),
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Salvar senha no RegistrationService
      sl.registrationService.setPassword(_senhaController.text);

      // Executar registro no backend
      final result = await sl.registrationService.register();

      if (!mounted) return;

      if (result.isSuccess) {
        // Sucesso! Token já foi salvo automaticamente pelo service
        setState(() {
          _isLoading = false;
        });

        // Obter email do serviço de registro
        final email = sl.registrationService.email ?? '';

        // Limpar dados do serviço de registro
        sl.registrationService.clear();

        // Redirecionar para tela de verificação de email
        context.go('/email-verification', extra: email);
      } else {
        // Erro no registro
        setState(() {
          _isLoading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result.errorMessage ?? 'Erro ao realizar cadastro'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro inesperado: $e'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 5),
        ),
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveUtils.isMobile(context);

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
              // AppBar
              _buildAppBar(context),

              // Progress indicator
              _buildProgressIndicator(),

              // Form
              Expanded(
                child: Center(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.all(isMobile ? 24.0 : 48.0),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 600),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // Título
                            FadeInDown(
                              delay: const Duration(milliseconds: 200),
                              child: Text(
                                'Crie sua Senha',
                                style: AppTextStyles.h2.copyWith(
                                  color: Colors.white,
                                  fontSize: isMobile ? 24 : 28,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),

                            const SizedBox(height: 12),

                            // Subtítulo
                            FadeInDown(
                              delay: const Duration(milliseconds: 300),
                              child: Text(
                                'Escolha uma senha forte para proteger sua conta',
                                style: AppTextStyles.bodyMedium.copyWith(
                                  color: Colors.white.withValues(alpha: 0.9),
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),

                            const SizedBox(height: 40),

                            // Card do formulário
                            FadeInUp(
                              delay: const Duration(milliseconds: 400),
                              child: Container(
                                padding: const EdgeInsets.all(24),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha: 0.1),
                                      blurRadius: 20,
                                      offset: const Offset(0, 10),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    // Senha
                                    TextFormField(
                                      controller: _senhaController,
                                      obscureText: _obscureSenha,
                                      validator: Validators.validateSenha,
                                      decoration: InputDecoration(
                                        labelText: 'Senha',
                                        hintText: 'Digite sua senha',
                                        prefixIcon: const Icon(
                                            Icons.lock_outline,
                                            color: AppColors.primaryBlue),
                                        suffixIcon: IconButton(
                                          icon: Icon(
                                            _obscureSenha
                                                ? Icons.visibility_outlined
                                                : Icons.visibility_off_outlined,
                                            color: Colors.grey[600],
                                          ),
                                          onPressed: () {
                                            setState(() {
                                              _obscureSenha = !_obscureSenha;
                                            });
                                          },
                                        ),
                                        filled: true,
                                        fillColor: Colors.grey[50],
                                        border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(12),
                                          borderSide: BorderSide.none,
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(12),
                                          borderSide: BorderSide(
                                              color: Colors.grey[200]!),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(12),
                                          borderSide: const BorderSide(
                                              color: AppColors.primaryBlue,
                                              width: 2),
                                        ),
                                        errorBorder: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(12),
                                          borderSide: const BorderSide(
                                              color: Colors.red, width: 1),
                                        ),
                                        focusedErrorBorder: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(12),
                                          borderSide: const BorderSide(
                                              color: Colors.red, width: 2),
                                        ),
                                      ),
                                    ),

                                    const SizedBox(height: 16),

                                    // Indicador de força da senha
                                    if (_senhaController.text.isNotEmpty)
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.stretch,
                                        children: [
                                          // Barra de força
                                          ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(4),
                                            child: LinearProgressIndicator(
                                              value: _getStrengthProgress(),
                                              backgroundColor:
                                                  Colors.grey[200],
                                              valueColor:
                                                  AlwaysStoppedAnimation<Color>(
                                                _getStrengthColor(),
                                              ),
                                              minHeight: 8,
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          // Texto de força
                                          Row(
                                            children: [
                                              Icon(
                                                _passwordStrength >= 3
                                                    ? Icons.check_circle
                                                    : Icons.info_outline,
                                                size: 16,
                                                color: _getStrengthColor(),
                                              ),
                                              const SizedBox(width: 6),
                                              Text(
                                                'Força: ${Validators.getPasswordStrengthText(_passwordStrength)}',
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  color: _getStrengthColor(),
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 12),
                                        ],
                                      ),

                                    // Requisitos da senha
                                    Container(
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: Colors.blue[50],
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const Text(
                                            'Sua senha deve conter:',
                                            style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w600,
                                              color: AppColors.primaryBlue,
                                            ),
                                          ),
                                          const SizedBox(height: 6),
                                          _buildRequirement(
                                              'Mínimo 8 caracteres',
                                              _senhaController.text.length >= 8),
                                          _buildRequirement(
                                              'Letra maiúscula',
                                              RegExp(r'[A-Z]').hasMatch(
                                                  _senhaController.text)),
                                          _buildRequirement(
                                              'Letra minúscula',
                                              RegExp(r'[a-z]').hasMatch(
                                                  _senhaController.text)),
                                          _buildRequirement(
                                              'Número',
                                              RegExp(r'[0-9]').hasMatch(
                                                  _senhaController.text)),
                                          _buildRequirement(
                                              'Caractere especial (!@#\$%)',
                                              RegExp(r'[!@#$%^&*(),.?":{}|<>]')
                                                  .hasMatch(_senhaController
                                                      .text)),
                                        ],
                                      ),
                                    ),

                                    const SizedBox(height: 20),

                                    // Confirmação de Senha
                                    TextFormField(
                                      controller: _confirmacaoSenhaController,
                                      obscureText: _obscureConfirmacaoSenha,
                                      validator: (value) =>
                                          Validators.validateConfirmacaoSenha(
                                        value,
                                        _senhaController.text,
                                      ),
                                      decoration: InputDecoration(
                                        labelText: 'Confirmar Senha',
                                        hintText: 'Digite a senha novamente',
                                        prefixIcon: const Icon(
                                            Icons.lock_outline,
                                            color: AppColors.primaryBlue),
                                        suffixIcon: IconButton(
                                          icon: Icon(
                                            _obscureConfirmacaoSenha
                                                ? Icons.visibility_outlined
                                                : Icons.visibility_off_outlined,
                                            color: Colors.grey[600],
                                          ),
                                          onPressed: () {
                                            setState(() {
                                              _obscureConfirmacaoSenha =
                                                  !_obscureConfirmacaoSenha;
                                            });
                                          },
                                        ),
                                        filled: true,
                                        fillColor: Colors.grey[50],
                                        border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(12),
                                          borderSide: BorderSide.none,
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(12),
                                          borderSide: BorderSide(
                                              color: Colors.grey[200]!),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(12),
                                          borderSide: const BorderSide(
                                              color: AppColors.primaryBlue,
                                              width: 2),
                                        ),
                                        errorBorder: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(12),
                                          borderSide: const BorderSide(
                                              color: Colors.red, width: 1),
                                        ),
                                        focusedErrorBorder: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(12),
                                          borderSide: const BorderSide(
                                              color: Colors.red, width: 2),
                                        ),
                                      ),
                                    ),

                                    const SizedBox(height: 32),

                                    // Botão Finalizar
                                    SizedBox(
                                      width: double.infinity,
                                      height: 56,
                                      child: ElevatedButton(
                                        onPressed:
                                            _isLoading ? null : _submitForm,
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor:
                                              AppColors.primaryBlue,
                                          foregroundColor: Colors.white,
                                          disabledBackgroundColor:
                                              AppColors.primaryBlue
                                                  .withValues(alpha: 0.6),
                                          elevation: 0,
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(12),
                                          ),
                                        ),
                                        child: _isLoading
                                            ? const SizedBox(
                                                width: 24,
                                                height: 24,
                                                child:
                                                    CircularProgressIndicator(
                                                  valueColor:
                                                      AlwaysStoppedAnimation<
                                                          Color>(Colors.white),
                                                  strokeWidth: 2,
                                                ),
                                              )
                                            : Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  Text(
                                                    'Finalizar Cadastro',
                                                    style: AppTextStyles.button
                                                        .copyWith(
                                                      color: Colors.white,
                                                      fontSize: 16,
                                                    ),
                                                  ),
                                                  const SizedBox(width: 8),
                                                  const Icon(Icons.check_rounded,
                                                      size: 20),
                                                ],
                                              ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            const SizedBox(height: 24),

                            // Link para voltar
                            FadeIn(
                              delay: const Duration(milliseconds: 600),
                              child: TextButton(
                                onPressed: () =>
                                    context.go('/registration/address'),
                                child: Text(
                                  'Voltar',
                                  style: AppTextStyles.caption.copyWith(
                                    color: Colors.white.withValues(alpha: 0.9),
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
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => context.go('/registration/address'),
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
          const SizedBox(width: 48),
        ],
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return FadeInDown(
      delay: const Duration(milliseconds: 100),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
        child: Column(
          children: [
            // Barra de progresso
            Row(
              children: [
                Expanded(
                  child: Container(
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Container(
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Container(
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            // Texto do progresso
            Text(
              'Passo 3 de 3',
              style: AppTextStyles.caption.copyWith(
                color: Colors.white.withValues(alpha: 0.9),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRequirement(String text, bool isMet) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Icon(
            isMet ? Icons.check_circle : Icons.radio_button_unchecked,
            size: 16,
            color: isMet ? Colors.green : Colors.grey,
          ),
          const SizedBox(width: 8),
          Text(
            text,
            style: TextStyle(
              fontSize: 12,
              color: isMet ? Colors.green[700] : Colors.grey[600],
              fontWeight: isMet ? FontWeight.w500 : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}
