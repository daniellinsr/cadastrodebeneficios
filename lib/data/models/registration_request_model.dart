import 'package:json_annotation/json_annotation.dart';

part 'registration_request_model.g.dart';

/// Model de requisição de registro
///
/// Agrega todos os dados coletados no fluxo de cadastro
@JsonSerializable()
class RegistrationRequestModel {
  // Dados de identificação
  final String name;
  final String email;
  final String password;
  @JsonKey(name: 'phone_number')
  final String phoneNumber;
  final String? cpf;
  @JsonKey(name: 'birth_date')
  final String? birthDate; // Formato: YYYY-MM-DD

  // Dados de endereço (opcionais)
  final String? cep;
  @JsonKey(name: 'street')
  final String? logradouro;
  @JsonKey(name: 'number')
  final String? numero;
  @JsonKey(name: 'complement')
  final String? complemento;
  @JsonKey(name: 'neighborhood')
  final String? bairro;
  @JsonKey(name: 'city')
  final String? cidade;
  @JsonKey(name: 'state')
  final String? estado;

  RegistrationRequestModel({
    required this.name,
    required this.email,
    required this.password,
    required this.phoneNumber,
    this.cpf,
    this.birthDate,
    this.cep,
    this.logradouro,
    this.numero,
    this.complemento,
    this.bairro,
    this.cidade,
    this.estado,
  });

  /// Criar a partir de JSON
  factory RegistrationRequestModel.fromJson(Map<String, dynamic> json) =>
      _$RegistrationRequestModelFromJson(json);

  /// Converter para JSON
  Map<String, dynamic> toJson() => _$RegistrationRequestModelToJson(this);

  /// Converter data DD/MM/YYYY para YYYY-MM-DD (formato ISO)
  static String convertDateToISO(String ddmmyyyy) {
    final parts = ddmmyyyy.split('/');
    if (parts.length != 3) return ddmmyyyy;
    return '${parts[2]}-${parts[1]}-${parts[0]}';
  }

  /// Remove formatação de campos (CPF, telefone, CEP)
  static String removeFormatting(String value) {
    return value.replaceAll(RegExp(r'[^0-9]'), '');
  }
}
