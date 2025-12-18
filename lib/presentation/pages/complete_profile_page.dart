import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:animate_do/animate_do.dart';
import 'dart:convert';
import 'package:cadastro_beneficios/core/di/service_locator.dart';
import 'package:cadastro_beneficios/core/theme/app_colors.dart';
import 'package:cadastro_beneficios/core/theme/app_text_styles.dart';
import 'package:cadastro_beneficios/core/theme/responsive_utils.dart';
import 'package:cadastro_beneficios/core/utils/validators.dart';
import 'package:cadastro_beneficios/core/utils/input_formatters.dart';
import 'package:cadastro_beneficios/presentation/bloc/auth/auth_bloc.dart';
import 'package:cadastro_beneficios/presentation/bloc/auth/auth_event.dart';

class CompleteProfilePage extends StatefulWidget {
  const CompleteProfilePage({super.key});

  @override
  State<CompleteProfilePage> createState() => _CompleteProfilePageState();
}

class _CompleteProfilePageState extends State<CompleteProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final _cpfController = TextEditingController();
  final _phoneController = TextEditingController();
  final _birthDateController = TextEditingController();
  final _cepController = TextEditingController();
  final _streetController = TextEditingController();
  final _numberController = TextEditingController();
  final _complementController = TextEditingController();
  final _neighborhoodController = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();

  bool _isLoading = false;
  bool _isLoadingCep = false;

  @override
  void dispose() {
    _cpfController.dispose();
    _phoneController.dispose();
    _birthDateController.dispose();
    _cepController.dispose();
    _streetController.dispose();
    _numberController.dispose();
    _complementController.dispose();
    _neighborhoodController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    super.dispose();
  }

  Future<void> _searchCep() async {
    if (_cepController.text.length != 9) return;

    setState(() => _isLoadingCep = true);

    try {
      final cep = _cepController.text.replaceAll('-', '');
      final response = await http.get(
        Uri.parse('https://viacep.com.br/ws/$cep/json/'),
      );

      if (response.statusCode == 200) {
        final address = json.decode(response.body);
        if (address['erro'] == null && mounted) {
          setState(() {
            _streetController.text = address['logradouro'] ?? '';
            _neighborhoodController.text = address['bairro'] ?? '';
            _cityController.text = address['localidade'] ?? '';
            _stateController.text = address['uf'] ?? '';
          });
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Erro ao buscar CEP'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoadingCep = false);
      }
    }
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      // Remover formatação dos campos
      final cpf = _cpfController.text.replaceAll(RegExp(r'[^\d]'), '');
      final phone = _phoneController.text.replaceAll(RegExp(r'[^\d]'), '');
      final cep = _cepController.text.replaceAll('-', '');

      // Converter data para formato ISO (YYYY-MM-DD)
      String? birthDateISO;
      if (_birthDateController.text.isNotEmpty) {
        final parts = _birthDateController.text.split('/');
        if (parts.length == 3) {
          birthDateISO = '${parts[2]}-${parts[1]}-${parts[0]}';
        }
      }

      final result = await sl.authRepository.completeProfile(
        cpf: cpf,
        phoneNumber: phone,
        cep: cep,
        street: _streetController.text,
        number: _numberController.text,
        complement: _complementController.text.isEmpty ? null : _complementController.text,
        neighborhood: _neighborhoodController.text,
        city: _cityController.text,
        state: _stateController.text,
        birthDate: birthDateISO,
      );

      result.fold(
        (failure) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(failure.message),
                backgroundColor: Colors.red,
              ),
            );
            setState(() => _isLoading = false);
          }
        },
        (user) {
          if (mounted) {
            debugPrint('✅ Perfil completado com sucesso!');
            debugPrint('   User retornado: ${user.email}');
            debugPrint('   isProfileComplete: ${user.isProfileComplete}');
            debugPrint('   profileCompletionStatus: ${user.profileCompletionStatus}');
            debugPrint('📤 Injetando usuário atualizado no AuthBloc...');

            context.read<AuthBloc>().add(AuthUserSet(user));

            // Aguardar um momento para o estado ser atualizado
            Future.delayed(const Duration(milliseconds: 1000), () {
              if (mounted) {
                debugPrint('→ Chamando context.go(\'/home\')...');
                context.go('/home');
                debugPrint('→ context.go(\'/home\') chamado!');
              }
            });
          }
        },
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Erro ao completar perfil. Tente novamente.'),
            backgroundColor: Colors.red,
          ),
        );
        setState(() => _isLoading = false);
      }
    }
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    String? Function(String?)? validator,
    void Function(String)? onChanged,
    Widget? suffixIcon,
    TextCapitalization textCapitalization = TextCapitalization.none,
    String? hintText,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      validator: validator,
      onChanged: onChanged,
      textCapitalization: textCapitalization,
      style: AppTextStyles.bodyLarge,
      decoration: InputDecoration(
        labelText: label,
        hintText: hintText,
        prefixIcon: Icon(icon, color: AppColors.primaryBlue),
        suffixIcon: suffixIcon,
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
        filled: true,
        fillColor: Colors.grey[50],
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => context.go('/'),
          ),
          const SizedBox(width: 16),
          const Text(
            'Complete seu Perfil',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
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

              // Form
              Expanded(
                child: Center(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.all(isMobile ? 24.0 : 48.0),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 800),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // Título
                            FadeInDown(
                              delay: const Duration(milliseconds: 200),
                              child: Text(
                                'Finalize seu Cadastro',
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
                                'Precisamos de mais algumas informações para completar seu perfil',
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
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Seção: Dados Pessoais
                                    Text(
                                      'Dados Pessoais',
                                      style: AppTextStyles.h3.copyWith(
                                        color: AppColors.primaryBlue,
                                      ),
                                    ),
                                    const SizedBox(height: 20),

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

                                    _buildTextField(
                                      controller: _phoneController,
                                      label: 'Telefone',
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

                                    _buildTextField(
                                      controller: _birthDateController,
                                      label: 'Data de Nascimento (Opcional)',
                                      icon: Icons.calendar_today_outlined,
                                      keyboardType: TextInputType.datetime,
                                      inputFormatters: [
                                        FilteringTextInputFormatter.digitsOnly,
                                        DateInputFormatter(),
                                      ],
                                      validator: (value) {
                                        if (value == null || value.isEmpty) return null;
                                        return Validators.validateDataNascimento(value);
                                      },
                                      hintText: 'DD/MM/AAAA',
                                    ),

                                    const SizedBox(height: 32),

                                    // Seção: Endereço
                                    Text(
                                      'Endereço',
                                      style: AppTextStyles.h3.copyWith(
                                        color: AppColors.primaryBlue,
                                      ),
                                    ),
                                    const SizedBox(height: 20),

                                    _buildTextField(
                                      controller: _cepController,
                                      label: 'CEP',
                                      icon: Icons.location_on_outlined,
                                      keyboardType: TextInputType.number,
                                      inputFormatters: [
                                        FilteringTextInputFormatter.digitsOnly,
                                        CepInputFormatter(),
                                      ],
                                      validator: Validators.validateCEP,
                                      onChanged: (value) {
                                        if (value.length == 9) {
                                          _searchCep();
                                        }
                                      },
                                      suffixIcon: _isLoadingCep
                                          ? const Padding(
                                              padding: EdgeInsets.all(12.0),
                                              child: SizedBox(
                                                width: 20,
                                                height: 20,
                                                child: CircularProgressIndicator(
                                                  strokeWidth: 2,
                                                  valueColor: AlwaysStoppedAnimation<Color>(
                                                    AppColors.primaryBlue,
                                                  ),
                                                ),
                                              ),
                                            )
                                          : null,
                                      hintText: '00000-000',
                                    ),

                                    const SizedBox(height: 20),

                                    _buildTextField(
                                      controller: _streetController,
                                      label: 'Logradouro',
                                      icon: Icons.home_outlined,
                                      validator: Validators.validateLogradouro,
                                    ),

                                    const SizedBox(height: 20),

                                    Row(
                                      children: [
                                        Expanded(
                                          flex: 2,
                                          child: _buildTextField(
                                            controller: _numberController,
                                            label: 'Número',
                                            icon: Icons.numbers,
                                            keyboardType: TextInputType.text,
                                            validator: Validators.validateNumero,
                                          ),
                                        ),
                                        const SizedBox(width: 16),
                                        Expanded(
                                          flex: 3,
                                          child: _buildTextField(
                                            controller: _complementController,
                                            label: 'Complemento',
                                            icon: Icons.add_home_outlined,
                                          ),
                                        ),
                                      ],
                                    ),

                                    const SizedBox(height: 20),

                                    _buildTextField(
                                      controller: _neighborhoodController,
                                      label: 'Bairro',
                                      icon: Icons.apartment_outlined,
                                      validator: Validators.validateBairro,
                                    ),

                                    const SizedBox(height: 20),

                                    Row(
                                      children: [
                                        Expanded(
                                          flex: 3,
                                          child: _buildTextField(
                                            controller: _cityController,
                                            label: 'Cidade',
                                            icon: Icons.location_city_outlined,
                                            validator: Validators.validateCidade,
                                          ),
                                        ),
                                        const SizedBox(width: 16),
                                        Expanded(
                                          flex: 1,
                                          child: _buildTextField(
                                            controller: _stateController,
                                            label: 'UF',
                                            icon: Icons.map_outlined,
                                            textCapitalization: TextCapitalization.characters,
                                            inputFormatters: [
                                              FilteringTextInputFormatter.allow(
                                                RegExp(r'[A-Za-z]'),
                                              ),
                                              LengthLimitingTextInputFormatter(2),
                                            ],
                                            validator: Validators.validateEstado,
                                          ),
                                        ),
                                      ],
                                    ),

                                    const SizedBox(height: 32),

                                    // Botão de submit
                                    SizedBox(
                                      width: double.infinity,
                                      height: 56,
                                      child: ElevatedButton(
                                        onPressed: _isLoading ? null : _handleSubmit,
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: AppColors.primaryBlue,
                                          foregroundColor: Colors.white,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          elevation: 0,
                                        ),
                                        child: _isLoading
                                            ? const SizedBox(
                                                height: 24,
                                                width: 24,
                                                child: CircularProgressIndicator(
                                                  strokeWidth: 2,
                                                  valueColor: AlwaysStoppedAnimation<Color>(
                                                    Colors.white,
                                                  ),
                                                ),
                                              )
                                            : Text(
                                                'Completar Cadastro',
                                                style: AppTextStyles.button,
                                              ),
                                      ),
                                    ),
                                  ],
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
}
