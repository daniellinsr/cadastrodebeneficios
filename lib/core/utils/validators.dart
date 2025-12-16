/// Validadores para formulários
class Validators {
  Validators._();

  /// Valida nome completo
  static String? validateNome(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Por favor, informe seu nome completo';
    }

    if (value.trim().length < 3) {
      return 'Nome deve ter pelo menos 3 caracteres';
    }

    // Verifica se tem pelo menos nome e sobrenome
    final parts = value.trim().split(' ');
    if (parts.length < 2) {
      return 'Por favor, informe nome e sobrenome';
    }

    // Verifica se não é só espaços
    if (parts.any((part) => part.isEmpty)) {
      return 'Nome inválido';
    }

    return null;
  }

  /// Valida CPF
  static String? validateCPF(String? value) {
    if (value == null || value.isEmpty) {
      return 'Por favor, informe o CPF';
    }

    // Remove caracteres não numéricos
    final cpf = value.replaceAll(RegExp(r'[^0-9]'), '');

    if (cpf.length != 11) {
      return 'CPF deve conter 11 dígitos';
    }

    // Verifica se todos os dígitos são iguais
    if (RegExp(r'^(\d)\1{10}$').hasMatch(cpf)) {
      return 'CPF inválido';
    }

    // Validação do primeiro dígito verificador
    int sum = 0;
    for (int i = 0; i < 9; i++) {
      sum += int.parse(cpf[i]) * (10 - i);
    }
    int firstDigit = 11 - (sum % 11);
    if (firstDigit >= 10) firstDigit = 0;

    if (int.parse(cpf[9]) != firstDigit) {
      return 'CPF inválido';
    }

    // Validação do segundo dígito verificador
    sum = 0;
    for (int i = 0; i < 10; i++) {
      sum += int.parse(cpf[i]) * (11 - i);
    }
    int secondDigit = 11 - (sum % 11);
    if (secondDigit >= 10) secondDigit = 0;

    if (int.parse(cpf[10]) != secondDigit) {
      return 'CPF inválido';
    }

    return null;
  }

  /// Valida data de nascimento
  static String? validateDataNascimento(String? value) {
    if (value == null || value.isEmpty) {
      return 'Por favor, informe a data de nascimento';
    }

    // Remove caracteres não numéricos
    final dateStr = value.replaceAll(RegExp(r'[^0-9]'), '');

    if (dateStr.length != 8) {
      return 'Data inválida';
    }

    final day = int.tryParse(dateStr.substring(0, 2));
    final month = int.tryParse(dateStr.substring(2, 4));
    final year = int.tryParse(dateStr.substring(4, 8));

    if (day == null || month == null || year == null) {
      return 'Data inválida';
    }

    if (month < 1 || month > 12) {
      return 'Mês inválido';
    }

    if (day < 1 || day > 31) {
      return 'Dia inválido';
    }

    // Verifica dias por mês
    final daysInMonth = [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31];

    // Verifica ano bissexto
    if (month == 2 && _isLeapYear(year)) {
      if (day > 29) {
        return 'Dia inválido para fevereiro';
      }
    } else if (day > daysInMonth[month - 1]) {
      return 'Dia inválido para este mês';
    }

    // Verifica se a data não é futura
    final birthDate = DateTime(year, month, day);
    final now = DateTime.now();

    if (birthDate.isAfter(now)) {
      return 'Data de nascimento não pode ser futura';
    }

    // Verifica idade mínima (18 anos)
    final age = now.year - birthDate.year;
    if (age < 18 || (age == 18 && now.month < birthDate.month) ||
        (age == 18 && now.month == birthDate.month && now.day < birthDate.day)) {
      return 'Você deve ter pelo menos 18 anos';
    }

    // Verifica idade máxima razoável (150 anos)
    if (age > 150) {
      return 'Data de nascimento inválida';
    }

    return null;
  }

  /// Valida celular
  static String? validateCelular(String? value) {
    if (value == null || value.isEmpty) {
      return 'Por favor, informe o celular';
    }

    // Remove caracteres não numéricos
    final phone = value.replaceAll(RegExp(r'[^0-9]'), '');

    if (phone.length != 11) {
      return 'Celular deve ter 11 dígitos';
    }

    // Verifica se o DDD é válido (11-99)
    final ddd = int.tryParse(phone.substring(0, 2));
    if (ddd == null || ddd < 11 || ddd > 99) {
      return 'DDD inválido';
    }

    // Verifica se o primeiro dígito do número é 9 (celular)
    if (phone[2] != '9') {
      return 'Número de celular deve começar com 9';
    }

    return null;
  }

  /// Valida email
  static String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Por favor, informe o email';
    }

    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );

    if (!emailRegex.hasMatch(value.trim())) {
      return 'Email inválido';
    }

    return null;
  }

  /// Valida CEP
  static String? validateCEP(String? value) {
    if (value == null || value.isEmpty) {
      return 'Por favor, informe o CEP';
    }

    // Remove caracteres não numéricos
    final cep = value.replaceAll(RegExp(r'[^0-9]'), '');

    if (cep.length != 8) {
      return 'CEP deve conter 8 dígitos';
    }

    return null;
  }

  /// Valida logradouro (rua, avenida, etc)
  static String? validateLogradouro(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Por favor, informe o logradouro';
    }

    if (value.trim().length < 3) {
      return 'Logradouro deve ter pelo menos 3 caracteres';
    }

    return null;
  }

  /// Valida número do endereço
  static String? validateNumero(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Por favor, informe o número';
    }

    // Aceita "S/N" para sem número
    if (value.trim().toUpperCase() == 'S/N') {
      return null;
    }

    // Verifica se tem pelo menos um dígito
    if (!RegExp(r'\d').hasMatch(value)) {
      return 'Número inválido';
    }

    return null;
  }

  /// Valida bairro
  static String? validateBairro(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Por favor, informe o bairro';
    }

    if (value.trim().length < 2) {
      return 'Bairro deve ter pelo menos 2 caracteres';
    }

    return null;
  }

  /// Valida cidade
  static String? validateCidade(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Por favor, informe a cidade';
    }

    if (value.trim().length < 2) {
      return 'Cidade deve ter pelo menos 2 caracteres';
    }

    return null;
  }

  /// Valida estado (UF)
  static String? validateEstado(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Por favor, informe o estado';
    }

    final uf = value.trim().toUpperCase();

    // Lista de UFs válidas
    final ufsValidas = [
      'AC', 'AL', 'AP', 'AM', 'BA', 'CE', 'DF', 'ES', 'GO', 'MA',
      'MT', 'MS', 'MG', 'PA', 'PB', 'PR', 'PE', 'PI', 'RJ', 'RN',
      'RS', 'RO', 'RR', 'SC', 'SP', 'SE', 'TO'
    ];

    if (!ufsValidas.contains(uf)) {
      return 'Estado inválido';
    }

    return null;
  }

  /// Valida senha forte
  static String? validateSenha(String? value) {
    if (value == null || value.isEmpty) {
      return 'Por favor, informe a senha';
    }

    if (value.length < 8) {
      return 'Senha deve ter pelo menos 8 caracteres';
    }

    // Verifica se tem pelo menos uma letra maiúscula
    if (!RegExp(r'[A-Z]').hasMatch(value)) {
      return 'Senha deve conter pelo menos uma letra maiúscula';
    }

    // Verifica se tem pelo menos uma letra minúscula
    if (!RegExp(r'[a-z]').hasMatch(value)) {
      return 'Senha deve conter pelo menos uma letra minúscula';
    }

    // Verifica se tem pelo menos um número
    if (!RegExp(r'[0-9]').hasMatch(value)) {
      return 'Senha deve conter pelo menos um número';
    }

    // Verifica se tem pelo menos um caractere especial
    if (!RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(value)) {
      return 'Senha deve conter pelo menos um caractere especial';
    }

    return null;
  }

  /// Valida confirmação de senha
  static String? validateConfirmacaoSenha(String? value, String senha) {
    if (value == null || value.isEmpty) {
      return 'Por favor, confirme a senha';
    }

    if (value != senha) {
      return 'As senhas não coincidem';
    }

    return null;
  }

  /// Calcula a força da senha (0 a 5)
  static int calculatePasswordStrength(String password) {
    int strength = 0;

    if (password.isEmpty) return 0;

    // +1 para comprimento >= 8
    if (password.length >= 8) strength++;

    // +1 para comprimento >= 12
    if (password.length >= 12) strength++;

    // +1 para letra minúscula
    if (RegExp(r'[a-z]').hasMatch(password)) strength++;

    // +1 para letra maiúscula
    if (RegExp(r'[A-Z]').hasMatch(password)) strength++;

    // +1 para número
    if (RegExp(r'[0-9]').hasMatch(password)) strength++;

    // +1 para caractere especial
    if (RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(password)) strength++;

    return strength > 5 ? 5 : strength;
  }

  /// Retorna a descrição da força da senha
  static String getPasswordStrengthText(int strength) {
    switch (strength) {
      case 0:
        return '';
      case 1:
        return 'Muito fraca';
      case 2:
        return 'Fraca';
      case 3:
        return 'Média';
      case 4:
        return 'Forte';
      case 5:
        return 'Muito forte';
      default:
        return '';
    }
  }

  /// Verifica se o ano é bissexto
  static bool _isLeapYear(int year) {
    if (year % 4 != 0) return false;
    if (year % 100 != 0) return true;
    if (year % 400 != 0) return false;
    return true;
  }
}
