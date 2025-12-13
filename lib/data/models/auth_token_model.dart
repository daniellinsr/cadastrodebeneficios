import 'package:json_annotation/json_annotation.dart';
import 'package:cadastro_beneficios/domain/entities/auth_token.dart';

part 'auth_token_model.g.dart';

/// Model do AuthToken - Conversão JSON <-> Entity
///
/// Usado para serialização/deserialização de tokens JWT da API
@JsonSerializable()
class AuthTokenModel {
  @JsonKey(name: 'access_token')
  final String accessToken;
  @JsonKey(name: 'refresh_token')
  final String refreshToken;
  @JsonKey(name: 'expires_at')
  final DateTime expiresAt;
  @JsonKey(name: 'token_type')
  final String tokenType;

  AuthTokenModel({
    required this.accessToken,
    required this.refreshToken,
    required this.expiresAt,
    this.tokenType = 'Bearer',
  });

  /// Criar AuthTokenModel a partir de JSON
  factory AuthTokenModel.fromJson(Map<String, dynamic> json) =>
      _$AuthTokenModelFromJson(json);

  /// Converter AuthTokenModel para JSON
  Map<String, dynamic> toJson() => _$AuthTokenModelToJson(this);

  /// Converter Model para Entity (Domain)
  AuthToken toEntity() {
    return AuthToken(
      accessToken: accessToken,
      refreshToken: refreshToken,
      expiresAt: expiresAt,
      tokenType: tokenType,
    );
  }

  /// Criar Model a partir de Entity (Domain)
  factory AuthTokenModel.fromEntity(AuthToken token) {
    return AuthTokenModel(
      accessToken: token.accessToken,
      refreshToken: token.refreshToken,
      expiresAt: token.expiresAt,
      tokenType: token.tokenType,
    );
  }
}
