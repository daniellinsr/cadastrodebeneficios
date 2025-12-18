import 'package:json_annotation/json_annotation.dart';
import 'package:cadastro_beneficios/data/models/user_model.dart';
import 'package:cadastro_beneficios/data/models/auth_token_model.dart';

part 'registration_response_model.g.dart';

/// Model de resposta do registro
///
/// Contém o usuário criado e os tokens de autenticação
@JsonSerializable()
class RegistrationResponseModel {
  final UserModel user;
  @JsonKey(name: 'access_token')
  final String accessToken;
  @JsonKey(name: 'refresh_token')
  final String refreshToken;
  @JsonKey(name: 'token_type')
  final String tokenType;
  @JsonKey(name: 'expires_in')
  final int expiresIn; // segundos até expiração

  RegistrationResponseModel({
    required this.user,
    required this.accessToken,
    required this.refreshToken,
    this.tokenType = 'Bearer',
    required this.expiresIn,
  });

  /// Criar a partir de JSON
  factory RegistrationResponseModel.fromJson(Map<String, dynamic> json) =>
      _$RegistrationResponseModelFromJson(json);

  /// Converter para JSON
  Map<String, dynamic> toJson() => _$RegistrationResponseModelToJson(this);

  /// Converter para AuthTokenModel
  AuthTokenModel toAuthToken() {
    // Calcula expiresAt baseado em expiresIn (segundos)
    final expiresAt = DateTime.now().add(Duration(seconds: expiresIn));

    return AuthTokenModel(
      accessToken: accessToken,
      refreshToken: refreshToken,
      tokenType: tokenType,
      expiresAt: expiresAt,
    );
  }
}
