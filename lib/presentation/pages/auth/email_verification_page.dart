import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:cadastro_beneficios/core/theme/app_colors.dart';
import 'package:cadastro_beneficios/core/theme/app_text_styles.dart';
import 'package:cadastro_beneficios/core/di/service_locator.dart';
import 'package:cadastro_beneficios/domain/repositories/auth_repository.dart';
import 'package:cadastro_beneficios/presentation/bloc/auth/auth_bloc.dart';
import 'package:cadastro_beneficios/presentation/bloc/auth/auth_event.dart';
import 'dart:async';

/// Página de verificação de email
///
/// Exibe um campo para inserir o código de 6 dígitos
/// enviado por email após o cadastro
class EmailVerificationPage extends StatefulWidget {
  final String email;

  const EmailVerificationPage({
    super.key,
    required this.email,
  });

  @override
  State<EmailVerificationPage> createState() => _EmailVerificationPageState();
}

class _EmailVerificationPageState extends State<EmailVerificationPage> {
  final TextEditingController _codeController = TextEditingController();
  final AuthRepository _authRepository = sl.authRepository;

  bool _isLoading = false;
  bool _isResending = false;
  int _remainingTime = 300; // 5 minutos em segundos
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startTimer();
    // Enviar código automaticamente ao abrir a tela
    _sendVerificationCode();
  }

  @override
  void dispose() {
    _timer?.cancel();
    // NÃO descartar _codeController aqui - o PinCodeTextField gerencia seu ciclo de vida
    super.dispose();
  }

  void _startTimer() {
    _timer?.cancel();
    _remainingTime = 900; // 15 minutos
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingTime > 0) {
        setState(() {
          _remainingTime--;
        });
      } else {
        timer.cancel();
      }
    });
  }

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  Future<void> _sendVerificationCode() async {
    setState(() {
      _isResending = true;
    });

    try {
      final result = await _authRepository.sendVerificationCodeV2('email');

      if (!mounted) return;

      result.fold(
        (failure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(failure.message),
              backgroundColor: Colors.red,
            ),
          );
        },
        (_) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Código enviado para seu email!'),
              backgroundColor: Colors.green,
            ),
          );
          _startTimer();
        },
      );
    } finally {
      if (mounted) {
        setState(() {
          _isResending = false;
        });
      }
    }
  }

  Future<void> _verifyCode() async {
    if (_codeController.text.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor, insira o código de 6 dígitos'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final result = await _authRepository.verifyCodeV2(
        'email',
        _codeController.text,
      );

      if (!mounted) return;

      result.fold(
        (failure) {
          if (mounted) {
            setState(() {
              _isLoading = false;
            });
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(failure.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        (_) {
          // Sucesso! Atualizar AuthBloc e redirecionar para home
          if (mounted) {
            // Disparar evento para recarregar dados do usuário
            context.read<AuthBloc>().add(const AuthUserUpdated());
            // Redirecionar para home
            context.go('/home');
          }
        },
      );
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightGray,
      appBar: AppBar(
        backgroundColor: AppColors.primaryBlue,
        title: const Text(
          'Verificação de Email',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 500),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Ícone de email
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: AppColors.primaryBlue.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.email_outlined,
                      size: 50,
                      color: AppColors.primaryBlue,
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Título
                  Text(
                    'Verifique seu Email',
                    style: AppTextStyles.h2.copyWith(
                      color: AppColors.primaryBlue,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 16),

                  // Descrição
                  Text(
                    'Enviamos um código de 6 dígitos para',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: Colors.grey[600],
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 8),

                  Text(
                    widget.email,
                    style: AppTextStyles.bodyLarge.copyWith(
                      color: AppColors.primaryBlue,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 40),

                  // Campo de código PIN
                  PinCodeTextField(
                    appContext: context,
                    length: 6,
                    controller: _codeController,
                    keyboardType: TextInputType.number,
                    animationType: AnimationType.fade,
                    pinTheme: PinTheme(
                      shape: PinCodeFieldShape.box,
                      borderRadius: BorderRadius.circular(12),
                      fieldHeight: 56,
                      fieldWidth: 48,
                      activeFillColor: Colors.white,
                      selectedFillColor: Colors.white,
                      inactiveFillColor: Colors.grey[100],
                      activeColor: AppColors.primaryBlue,
                      selectedColor: AppColors.primaryBlue,
                      inactiveColor: Colors.grey[300]!,
                    ),
                    enableActiveFill: true,
                    onCompleted: (code) {
                      // Auto-verificar quando completar os 6 dígitos
                      _verifyCode();
                    },
                    onChanged: (value) {
                      setState(() {});
                    },
                  ),

                  const SizedBox(height: 24),

                  // Timer e botão de reenviar
                  if (_remainingTime > 0)
                    Text(
                      'Código expira em: ${_formatTime(_remainingTime)}',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: Colors.grey[600],
                      ),
                    )
                  else
                    Text(
                      'Código expirado',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: Colors.red,
                      ),
                    ),

                  const SizedBox(height: 16),

                  // Botão de reenviar
                  TextButton.icon(
                    onPressed: _isResending ? null : _sendVerificationCode,
                    icon: _isResending
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.refresh),
                    label: Text(
                      _isResending ? 'Reenviando...' : 'Reenviar código',
                    ),
                  ),

                  const SizedBox(height: 40),

                  // Botão de verificar
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _isLoading || _codeController.text.length != 6
                          ? null
                          : _verifyCode,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryBlue,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: _isLoading
                          ? const CircularProgressIndicator(
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white),
                            )
                          : const Text(
                              'Verificar Código',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Instruções
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.blue[50],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.blue[200]!,
                        width: 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: Colors.blue[700],
                          size: 24,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Verifique sua caixa de spam caso não encontre o email',
                            style: AppTextStyles.bodySmall.copyWith(
                              color: Colors.blue[900],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
