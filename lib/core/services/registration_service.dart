import 'package:cadastro_beneficios/domain/repositories/auth_repository.dart';
import 'package:cadastro_beneficios/core/services/token_service.dart';
import 'package:cadastro_beneficios/core/utils/validators.dart';

/// Serviço de gerenciamento do fluxo de cadastro
///
/// Armazena temporariamente os dados coletados nas diferentes etapas
/// e executa o registro final quando todos os dados estiverem completos
class RegistrationService {
  final AuthRepository _authRepository;
  final TokenService _tokenService;

  // Dados de identificação
  String? _name;
  String? _email;
  String? _cpf;
  String? _birthDate; // Formato: DD/MM/YYYY
  String? _phoneNumber;

  // Dados de endereço
  String? _cep;
  String? _logradouro;
  String? _numero;
  String? _complemento;
  String? _bairro;
  String? _cidade;
  String? _estado;

  // Senha
  String? _password;

  RegistrationService({
    required AuthRepository authRepository,
    required TokenService tokenService,
  })  : _authRepository = authRepository,
        _tokenService = tokenService;

  // ===== Setters para dados de identificação =====

  void setName(String value) => _name = value;
  void setEmail(String value) => _email = value;
  void setCpf(String value) => _cpf = value;
  void setBirthDate(String value) => _birthDate = value;
  void setPhoneNumber(String value) => _phoneNumber = value;

  // ===== Setters para dados de endereço =====

  void setCep(String value) => _cep = value;
  void setLogradouro(String value) => _logradouro = value;
  void setNumero(String value) => _numero = value;
  void setComplemento(String? value) => _complemento = value;
  void setBairro(String value) => _bairro = value;
  void setCidade(String value) => _cidade = value;
  void setEstado(String value) => _estado = value;

  // ===== Setter para senha =====

  void setPassword(String value) => _password = value;

  // ===== Getters =====

  String? get name => _name;
  String? get email => _email;
  String? get cpf => _cpf;
  String? get birthDate => _birthDate;
  String? get phoneNumber => _phoneNumber;
  String? get cep => _cep;
  String? get logradouro => _logradouro;
  String? get numero => _numero;
  String? get complemento => _complemento;
  String? get bairro => _bairro;
  String? get cidade => _cidade;
  String? get estado => _estado;

  // ===== Métodos de validação de etapas =====

  /// Verifica se os dados de identificação estão completos e válidos
  bool isIdentificationComplete() {
    if (_name == null || _name!.isEmpty) return false;
    if (_email == null || _email!.isEmpty) return false;
    if (_cpf == null || _cpf!.isEmpty) return false;
    if (_birthDate == null || _birthDate!.isEmpty) return false;
    if (_phoneNumber == null || _phoneNumber!.isEmpty) return false;

    // Validações
    if (Validators.validateNome(_name) != null) return false;
    if (Validators.validateEmail(_email) != null) return false;
    if (Validators.validateCPF(_cpf) != null) return false;
    if (Validators.validateDataNascimento(_birthDate) != null) return false;
    if (Validators.validateCelular(_phoneNumber) != null) return false;

    return true;
  }

  /// Verifica se os dados de endereço estão completos e válidos
  bool isAddressComplete() {
    if (_cep == null || _cep!.isEmpty) return false;
    if (_logradouro == null || _logradouro!.isEmpty) return false;
    if (_numero == null || _numero!.isEmpty) return false;
    if (_bairro == null || _bairro!.isEmpty) return false;
    if (_cidade == null || _cidade!.isEmpty) return false;
    if (_estado == null || _estado!.isEmpty) return false;

    // Validações
    if (Validators.validateCEP(_cep) != null) return false;
    if (Validators.validateLogradouro(_logradouro) != null) return false;
    if (Validators.validateNumero(_numero) != null) return false;
    if (Validators.validateBairro(_bairro) != null) return false;
    if (Validators.validateCidade(_cidade) != null) return false;
    if (Validators.validateEstado(_estado) != null) return false;

    return true;
  }

  /// Verifica se a senha foi definida e é válida
  bool isPasswordComplete() {
    if (_password == null || _password!.isEmpty) return false;
    if (Validators.validateSenha(_password) != null) return false;
    return true;
  }

  /// Verifica se todos os dados obrigatórios foram preenchidos
  bool isComplete() {
    return isIdentificationComplete() &&
           isAddressComplete() &&
           isPasswordComplete();
  }

  /// Calcula o progresso do cadastro (0-100%)
  int getProgress() {
    int completed = 0;
    const int totalSteps = 3;

    if (isIdentificationComplete()) completed++;
    if (isAddressComplete()) completed++;
    if (isPasswordComplete()) completed++;

    return (completed / totalSteps * 100).round();
  }

  // ===== Execução do registro =====

  /// Executa o registro no backend
  ///
  /// Retorna Either com Failure ou AuthToken
  /// Salva automaticamente o token se o registro for bem-sucedido
  Future<RegistrationResult> register() async {
    // Validar se todos os dados estão completos
    if (!isComplete()) {
      return RegistrationResult.error(
        'Dados incompletos. Preencha todos os campos obrigatórios.',
      );
    }

    // Converter data de DD/MM/YYYY para YYYY-MM-DD
    final birthDateISO = _convertDateToISO(_birthDate!);

    // Remover formatação de CPF, telefone e CEP
    final cpfClean = _removeFormatting(_cpf!);
    final phoneClean = _removeFormatting(_phoneNumber!);
    final cepClean = _removeFormatting(_cep!);

    // Executar registro
    final result = await _authRepository.register(
      name: _name!,
      email: _email!,
      password: _password!,
      phoneNumber: phoneClean,
      cpf: cpfClean,
      birthDate: birthDateISO,
      cep: cepClean,
      logradouro: _logradouro!,
      numero: _numero!,
      complemento: _complemento,
      bairro: _bairro!,
      cidade: _cidade!,
      estado: _estado!,
    );

    return result.fold(
      // Erro
      (failure) => RegistrationResult.error(failure.message),
      // Sucesso
      (authToken) async {
        // Salvar token automaticamente
        await _tokenService.saveToken(authToken);
        return RegistrationResult.success(authToken: authToken);
      },
    );
  }

  /// Limpa todos os dados do serviço
  void clear() {
    _name = null;
    _email = null;
    _cpf = null;
    _birthDate = null;
    _phoneNumber = null;
    _cep = null;
    _logradouro = null;
    _numero = null;
    _complemento = null;
    _bairro = null;
    _cidade = null;
    _estado = null;
    _password = null;
  }

  // ===== Métodos auxiliares =====

  /// Converte data de DD/MM/YYYY para YYYY-MM-DD
  String _convertDateToISO(String ddmmyyyy) {
    final parts = ddmmyyyy.split('/');
    if (parts.length != 3) return ddmmyyyy;
    return '${parts[2]}-${parts[1]}-${parts[0]}';
  }

  /// Remove formatação de campos (CPF, telefone, CEP)
  String _removeFormatting(String value) {
    return value.replaceAll(RegExp(r'[^0-9]'), '');
  }
}

/// Resultado do registro
class RegistrationResult {
  final bool isSuccess;
  final String? errorMessage;
  final dynamic authToken;

  RegistrationResult._({
    required this.isSuccess,
    this.errorMessage,
    this.authToken,
  });

  factory RegistrationResult.success({required dynamic authToken}) {
    return RegistrationResult._(
      isSuccess: true,
      authToken: authToken,
    );
  }

  factory RegistrationResult.error(String message) {
    return RegistrationResult._(
      isSuccess: false,
      errorMessage: message,
    );
  }
}
