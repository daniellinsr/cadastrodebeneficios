import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:animate_do/animate_do.dart';
import 'package:cadastro_beneficios/core/theme/app_colors.dart';
import 'package:cadastro_beneficios/core/theme/app_text_styles.dart';
import 'package:cadastro_beneficios/core/theme/responsive_utils.dart';
import 'package:cadastro_beneficios/core/utils/validators.dart';
import 'package:cadastro_beneficios/core/utils/input_formatters.dart';
import 'package:cadastro_beneficios/core/services/registration_draft_service.dart';
import 'package:cadastro_beneficios/core/di/service_locator.dart';

/// Formulário de identificação inicial
/// Coleta: Nome, CPF, Data de Nascimento, Celular, Email
class RegistrationIdentificationPage extends StatefulWidget {
  const RegistrationIdentificationPage({super.key});

  @override
  State<RegistrationIdentificationPage> createState() =>
      _RegistrationIdentificationPageState();
}

class _RegistrationIdentificationPageState
    extends State<RegistrationIdentificationPage> {
  final _formKey = GlobalKey<FormState>();
  final _nomeController = TextEditingController();
  final _cpfController = TextEditingController();
  final _dataNascimentoController = TextEditingController();
  final _celularController = TextEditingController();
  final _emailController = TextEditingController();
  final _draftService = RegistrationDraftService();

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadDraft();
    _setupAutoSave();
  }

  @override
  void dispose() {
    _saveDraft();
    _nomeController.dispose();
    _cpfController.dispose();
    _dataNascimentoController.dispose();
    _celularController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  /// Carrega dados salvos automaticamente
  Future<void> _loadDraft() async {
    final data = await _draftService.loadIdentificationDraft();

    if (data != null && mounted) {
      setState(() {
        _nomeController.text = data['name'] ?? '';
        _cpfController.text = data['cpf'] ?? '';
        _dataNascimentoController.text = data['birthDate'] ?? '';
        _celularController.text = data['phoneNumber'] ?? '';
        _emailController.text = data['email'] ?? '';
      });

      // Mostra feedback ao usuário
      if (data['name']?.isNotEmpty ?? false) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Dados carregados automaticamente'),
            backgroundColor: AppColors.success,
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
  }

  /// Configura salvamento automático a cada mudança
  void _setupAutoSave() {
    _nomeController.addListener(_saveDraft);
    _cpfController.addListener(_saveDraft);
    _dataNascimentoController.addListener(_saveDraft);
    _celularController.addListener(_saveDraft);
    _emailController.addListener(_saveDraft);
  }

  /// Salva dados automaticamente
  Future<void> _saveDraft() async {
    // Só salva se houver algum dado preenchido
    if (_nomeController.text.isEmpty &&
        _cpfController.text.isEmpty &&
        _dataNascimentoController.text.isEmpty &&
        _celularController.text.isEmpty &&
        _emailController.text.isEmpty) {
      return;
    }

    await _draftService.saveIdentificationDraft(
      nome: _nomeController.text,
      cpf: _cpfController.text,
      dataNascimento: _dataNascimentoController.text,
      celular: _celularController.text,
      email: _emailController.text,
    );
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    // Salva antes de navegar
    await _saveDraft();

    // Salvar dados no RegistrationService
    sl.registrationService.setName(_nomeController.text);
    sl.registrationService.setEmail(_emailController.text);
    sl.registrationService.setCpf(_cpfController.text);
    sl.registrationService.setBirthDate(_dataNascimentoController.text);
    sl.registrationService.setPhoneNumber(_celularController.text);

    if (!mounted) return;

    setState(() {
      _isLoading = false;
    });

    // Navega para próxima tela
    context.go('/registration/address');
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
                                'Dados Pessoais',
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
                                'Preencha seus dados para iniciar o cadastro',
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
                                  children: [
                                    // Nome Completo
                                    _buildTextField(
                                      controller: _nomeController,
                                      label: 'Nome Completo',
                                      icon: Icons.person_outline,
                                      keyboardType: TextInputType.name,
                                      textCapitalization: TextCapitalization.words,
                                      validator: Validators.validateNome,
                                    ),

                                    const SizedBox(height: 20),

                                    // CPF
                                    _buildTextField(
                                      controller: _cpfController,
                                      label: 'CPF',
                                      icon: Icons.badge_outlined,
                                      keyboardType: TextInputType.number,
                                      inputFormatters: [
                                        FilteringTextInputFormatter.digitsOnly,
                                        CpfInputFormatter(),
                                      ],
                                      validator: Validators.validateCPF,
                                      hintText: '000.000.000-00',
                                    ),

                                    const SizedBox(height: 20),

                                    // Data de Nascimento
                                    _buildTextField(
                                      controller: _dataNascimentoController,
                                      label: 'Data de Nascimento',
                                      icon: Icons.calendar_today_outlined,
                                      keyboardType: TextInputType.number,
                                      inputFormatters: [
                                        FilteringTextInputFormatter.digitsOnly,
                                        DateInputFormatter(),
                                      ],
                                      validator: Validators.validateDataNascimento,
                                      hintText: 'DD/MM/AAAA',
                                    ),

                                    const SizedBox(height: 20),

                                    // Celular
                                    _buildTextField(
                                      controller: _celularController,
                                      label: 'Celular',
                                      icon: Icons.phone_outlined,
                                      keyboardType: TextInputType.phone,
                                      inputFormatters: [
                                        FilteringTextInputFormatter.digitsOnly,
                                        PhoneInputFormatter(),
                                      ],
                                      validator: Validators.validateCelular,
                                      hintText: '(00) 00000-0000',
                                    ),

                                    const SizedBox(height: 20),

                                    // Email
                                    _buildTextField(
                                      controller: _emailController,
                                      label: 'Email',
                                      icon: Icons.email_outlined,
                                      keyboardType: TextInputType.emailAddress,
                                      validator: Validators.validateEmail,
                                      hintText: 'seu@email.com',
                                    ),

                                    const SizedBox(height: 32),

                                    // Botão Continuar
                                    SizedBox(
                                      width: double.infinity,
                                      height: 56,
                                      child: ElevatedButton(
                                        onPressed: _isLoading ? null : _submitForm,
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: AppColors.primaryBlue,
                                          foregroundColor: Colors.white,
                                          disabledBackgroundColor:
                                              AppColors.primaryBlue.withValues(alpha: 0.6),
                                          elevation: 0,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                        ),
                                        child: _isLoading
                                            ? const SizedBox(
                                                width: 24,
                                                height: 24,
                                                child: CircularProgressIndicator(
                                                  valueColor:
                                                      AlwaysStoppedAnimation<Color>(
                                                          Colors.white),
                                                  strokeWidth: 2,
                                                ),
                                              )
                                            : Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  Text(
                                                    'Continuar',
                                                    style: AppTextStyles.button.copyWith(
                                                      color: Colors.white,
                                                      fontSize: 16,
                                                    ),
                                                  ),
                                                  const SizedBox(width: 8),
                                                  const Icon(
                                                      Icons.arrow_forward_rounded,
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
                                onPressed: () => context.go('/registration'),
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
            onPressed: () => context.go('/registration'),
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
                      color: Colors.white.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Container(
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            // Texto do progresso
            Text(
              'Passo 1 de 3',
              style: AppTextStyles.caption.copyWith(
                color: Colors.white.withValues(alpha: 0.9),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required String? Function(String?) validator,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    TextCapitalization textCapitalization = TextCapitalization.none,
    String? hintText,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      textCapitalization: textCapitalization,
      inputFormatters: inputFormatters,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        hintText: hintText,
        prefixIcon: Icon(icon, color: AppColors.primaryBlue),
        filled: true,
        fillColor: Colors.grey[50],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[200]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primaryBlue, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red, width: 2),
        ),
      ),
    );
  }
}
