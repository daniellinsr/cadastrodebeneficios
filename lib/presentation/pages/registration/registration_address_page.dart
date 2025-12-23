import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:animate_do/animate_do.dart';
import 'package:cadastro_beneficios/core/theme/app_colors.dart';
import 'package:cadastro_beneficios/core/theme/app_text_styles.dart';
import 'package:cadastro_beneficios/core/theme/responsive_utils.dart';
import 'package:cadastro_beneficios/core/utils/validators.dart';
import 'package:cadastro_beneficios/core/utils/input_formatters.dart';
import 'package:cadastro_beneficios/core/services/viacep_service.dart';
import 'package:cadastro_beneficios/core/services/registration_draft_service.dart';
import 'package:cadastro_beneficios/core/di/service_locator.dart';

/// Formulário de endereço completo
/// Coleta: CEP, Logradouro, Número, Complemento, Bairro, Cidade, Estado
class RegistrationAddressPage extends StatefulWidget {
  const RegistrationAddressPage({super.key});

  @override
  State<RegistrationAddressPage> createState() =>
      _RegistrationAddressPageState();
}

class _RegistrationAddressPageState extends State<RegistrationAddressPage> {
  final _formKey = GlobalKey<FormState>();
  final _cepController = TextEditingController();
  final _logradouroController = TextEditingController();
  final _numeroController = TextEditingController();
  final _complementoController = TextEditingController();
  final _bairroController = TextEditingController();
  final _cidadeController = TextEditingController();
  final _estadoController = TextEditingController();
  final _draftService = RegistrationDraftService();

  bool _isLoading = false;
  bool _isSearchingCep = false;

  @override
  void initState() {
    super.initState();
    _loadDraft();
    _setupAutoSave();
  }

  @override
  void dispose() {
    _saveDraft();
    _cepController.dispose();
    _logradouroController.dispose();
    _numeroController.dispose();
    _complementoController.dispose();
    _bairroController.dispose();
    _cidadeController.dispose();
    _estadoController.dispose();
    super.dispose();
  }

  /// Carrega dados salvos automaticamente
  Future<void> _loadDraft() async {
    final data = await _draftService.loadAddressDraft();

    if (data != null && mounted) {
      setState(() {
        _cepController.text = data['cep'] ?? '';
        _logradouroController.text = data['logradouro'] ?? '';
        _numeroController.text = data['numero'] ?? '';
        _complementoController.text = data['complemento'] ?? '';
        _bairroController.text = data['bairro'] ?? '';
        _cidadeController.text = data['cidade'] ?? '';
        _estadoController.text = data['estado'] ?? '';
      });

      // Mostra feedback ao usuário
      if (data['cep']?.isNotEmpty ?? false) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Dados de endereço carregados automaticamente'),
            backgroundColor: AppColors.success,
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
  }

  /// Configura salvamento automático a cada mudança
  void _setupAutoSave() {
    _cepController.addListener(_saveDraft);
    _logradouroController.addListener(_saveDraft);
    _numeroController.addListener(_saveDraft);
    _complementoController.addListener(_saveDraft);
    _bairroController.addListener(_saveDraft);
    _cidadeController.addListener(_saveDraft);
    _estadoController.addListener(_saveDraft);
  }

  /// Salva dados automaticamente
  Future<void> _saveDraft() async {
    // Só salva se houver algum dado preenchido
    if (_cepController.text.isEmpty &&
        _logradouroController.text.isEmpty &&
        _numeroController.text.isEmpty &&
        _bairroController.text.isEmpty &&
        _cidadeController.text.isEmpty &&
        _estadoController.text.isEmpty) {
      return;
    }

    await _draftService.saveAddressDraft(
      cep: _cepController.text,
      logradouro: _logradouroController.text,
      numero: _numeroController.text,
      complemento: _complementoController.text,
      bairro: _bairroController.text,
      cidade: _cidadeController.text,
      estado: _estadoController.text,
    );
  }

  /// Busca endereço pelo CEP na API ViaCEP
  Future<void> _searchCep() async {
    final cep = _cepController.text.replaceAll(RegExp(r'[^0-9]'), '');

    if (cep.length != 8) {
      return;
    }

    setState(() {
      _isSearchingCep = true;
    });

    try {
      final address = await ViaCepService.fetchAddress(cep);

      if (!mounted) return;

      if (address != null && !address.erro) {
        // Preenche os campos com os dados retornados
        _logradouroController.text = address.logradouro;
        _bairroController.text = address.bairro;
        _cidadeController.text = address.localidade;
        _estadoController.text = address.uf;

        // Foca no campo de número
        FocusScope.of(context).nextFocus();
      } else {
        // CEP não encontrado
        // Limpa os campos
        _logradouroController.clear();
        _bairroController.clear();
        _cidadeController.clear();
        _estadoController.clear();

        // Mostra mensagem
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('CEP não encontrado. Preencha manualmente.'),
              backgroundColor: Colors.orange,
              duration: Duration(seconds: 3),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Erro ao buscar CEP. Verifique sua conexão.'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 3),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSearchingCep = false;
        });
      }
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    // Salvar dados no RegistrationService
    sl.registrationService.setCep(_cepController.text);
    sl.registrationService.setLogradouro(_logradouroController.text);
    sl.registrationService.setNumero(_numeroController.text);
    sl.registrationService.setComplemento(
      _complementoController.text.isEmpty ? null : _complementoController.text,
    );
    sl.registrationService.setBairro(_bairroController.text);
    sl.registrationService.setCidade(_cidadeController.text);
    sl.registrationService.setEstado(_estadoController.text);

    if (!mounted) return;

    setState(() {
      _isLoading = false;
    });

    // Navega para próxima tela
    context.go('/registration/password');
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveUtils.isMobile(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final useColumnForAddress = screenWidth < 450;

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
                                'Endereço',
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
                                'Informe seu endereço completo',
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
                                    // CEP com botão de busca
                                    Row(
                                      children: [
                                        Expanded(
                                          child: _buildTextField(
                                            controller: _cepController,
                                            label: 'CEP',
                                            icon: Icons.location_on_outlined,
                                            keyboardType: TextInputType.number,
                                            inputFormatters: [
                                              FilteringTextInputFormatter
                                                  .digitsOnly,
                                              CepInputFormatter(),
                                            ],
                                            validator: Validators.validateCEP,
                                            hintText: '00000-000',
                                            onChanged: (value) {
                                              // Auto-busca quando completa 8 dígitos
                                              final cep = value.replaceAll(
                                                  RegExp(r'[^0-9]'), '');
                                              if (cep.length == 8) {
                                                _searchCep();
                                              }
                                            },
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        // Botão de buscar CEP
                                        SizedBox(
                                          height: 56,
                                          width: 56,
                                          child: ElevatedButton(
                                            onPressed:
                                                _isSearchingCep ? null : _searchCep,
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor:
                                                  AppColors.primaryBlue,
                                              foregroundColor: Colors.white,
                                              padding: EdgeInsets.zero,
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                              ),
                                            ),
                                            child: _isSearchingCep
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
                                                : const Icon(Icons.search,
                                                    size: 24),
                                          ),
                                        ),
                                      ],
                                    ),

                                    const SizedBox(height: 20),

                                    // Logradouro
                                    _buildTextField(
                                      controller: _logradouroController,
                                      label: 'Logradouro',
                                      icon: Icons.home_outlined,
                                      keyboardType: TextInputType.streetAddress,
                                      textCapitalization:
                                          TextCapitalization.words,
                                      validator: Validators.validateLogradouro,
                                      hintText: 'Rua, Avenida, etc.',
                                    ),

                                    const SizedBox(height: 20),

                                    // Número e Complemento
                                    Row(
                                      children: [
                                        // Número
                                        Expanded(
                                          flex: 2,
                                          child: _buildTextField(
                                            controller: _numeroController,
                                            label: 'Número',
                                            icon: Icons.pin_outlined,
                                            keyboardType: TextInputType.text,
                                            validator: Validators.validateNumero,
                                            hintText: '123',
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        // Complemento (opcional)
                                        Expanded(
                                          flex: 3,
                                          child: _buildTextField(
                                            controller: _complementoController,
                                            label: 'Complemento',
                                            icon: Icons.other_houses_outlined,
                                            keyboardType: TextInputType.text,
                                            textCapitalization:
                                                TextCapitalization.words,
                                            validator: null, // Opcional
                                            hintText: 'Apto, Bloco, etc.',
                                          ),
                                        ),
                                      ],
                                    ),

                                    const SizedBox(height: 20),

                                    // Bairro
                                    _buildTextField(
                                      controller: _bairroController,
                                      label: 'Bairro',
                                      icon: Icons.location_city_outlined,
                                      keyboardType: TextInputType.text,
                                      textCapitalization:
                                          TextCapitalization.words,
                                      validator: Validators.validateBairro,
                                      hintText: 'Nome do bairro',
                                    ),

                                    const SizedBox(height: 20),

                                    // Cidade e Estado - Layout responsivo
                                    // < 450px: campos em linhas separadas
                                    // >= 450px: campos na mesma linha
                                    if (useColumnForAddress) ...[
                                      // COLUMN: Campos em linhas separadas
                                      _buildTextField(
                                        controller: _cidadeController,
                                        label: 'Cidade',
                                        keyboardType: TextInputType.text,
                                        textCapitalization:
                                            TextCapitalization.words,
                                        validator: Validators.validateCidade,
                                        hintText: 'Nome da cidade',
                                      ),
                                      const SizedBox(height: 20),
                                      _buildTextField(
                                        controller: _estadoController,
                                        label: 'UF',
                                        keyboardType: TextInputType.text,
                                        textCapitalization:
                                            TextCapitalization.characters,
                                        validator: Validators.validateEstado,
                                        hintText: 'SP',
                                        inputFormatters: [
                                          FilteringTextInputFormatter.allow(
                                              RegExp(r'[A-Za-z]')),
                                          LengthLimitingTextInputFormatter(2),
                                          UpperCaseTextFormatter(),
                                        ],
                                      ),
                                    ] else ...[
                                      // ROW: Campos na mesma linha
                                      Row(
                                        children: [
                                          Expanded(
                                            flex: 3,
                                            child: _buildTextField(
                                              controller: _cidadeController,
                                              label: 'Cidade',
                                              keyboardType: TextInputType.text,
                                              textCapitalization:
                                                  TextCapitalization.words,
                                              validator: Validators.validateCidade,
                                              hintText: 'Nome da cidade',
                                            ),
                                          ),
                                          const SizedBox(width: 16),
                                          Expanded(
                                            flex: 2,
                                            child: _buildTextField(
                                              controller: _estadoController,
                                              label: 'UF',
                                              keyboardType: TextInputType.text,
                                              textCapitalization:
                                                  TextCapitalization.characters,
                                              validator: Validators.validateEstado,
                                              hintText: 'SP',
                                              inputFormatters: [
                                                FilteringTextInputFormatter.allow(
                                                    RegExp(r'[A-Za-z]')),
                                                LengthLimitingTextInputFormatter(2),
                                                UpperCaseTextFormatter(),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],

                                    const SizedBox(height: 32),

                                    // Botão Continuar
                                    SizedBox(
                                      width: double.infinity,
                                      height: 56,
                                      child: ElevatedButton(
                                        onPressed:
                                            _isLoading ? null : _submitForm,
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: AppColors.primaryBlue,
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
                                                    'Continuar',
                                                    style: AppTextStyles.button
                                                        .copyWith(
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
                                onPressed: () =>
                                    context.go('/registration/identification'),
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
            onPressed: () => context.go('/registration/identification'),
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
              'Passo 2 de 3',
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
    IconData? icon,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    TextCapitalization textCapitalization = TextCapitalization.none,
    String? hintText,
    void Function(String)? onChanged,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      textCapitalization: textCapitalization,
      inputFormatters: inputFormatters,
      validator: validator,
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        hintText: hintText,
        prefixIcon: icon != null ? Icon(icon, color: AppColors.primaryBlue) : null,
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

/// Formatter para converter texto em maiúsculas
class UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    return TextEditingValue(
      text: newValue.text.toUpperCase(),
      selection: newValue.selection,
    );
  }
}
