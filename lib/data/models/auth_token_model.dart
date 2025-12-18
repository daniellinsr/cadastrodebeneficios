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
  final DateTime? expiresAt;
  @JsonKey(name: 'expires_in')
  final int? expiresIn;
  @JsonKey(name: 'token_type')
  final String tokenType;

  AuthTokenModel({
    required this.accessToken,
    required this.refreshToken,
    this.expiresAt,
    this.expiresIn,
    this.tokenType = 'Bearer',
  });

  /// Criar AuthTokenModel a partir de JSON
  factory AuthTokenModel.fromJson(Map<String, dynamic> json) {
    final model = _$AuthTokenModelFromJson(json);

    // Se não tiver expires_at mas tiver expires_in, calcular expires_at
    if (model.expiresAt == null && model.expiresIn != null) {
      final calculatedExpiresAt = DateTime.now().add(Duration(seconds: model.expiresIn!));
      return AuthTokenModel(
        accessToken: model.accessToken,
        refreshToken: model.refreshToken,
        expiresAt: calculatedExpiresAt,
        expiresIn: model.expiresIn,
        tokenType: model.tokenType,
      );
    }

    return model;
  }

  /// Converter AuthTokenModel para JSON
  Map<String, dynamic> toJson() => _$AuthTokenModelToJson(this);

  /// Converter Model para Entity (Domain)
  AuthToken toEntity() {
    // Garantir que expiresAt nunca seja null
    final effectiveExpiresAt = expiresAt ??
        (expiresIn != null
            ? DateTime.now().add(Duration(seconds: expiresIn!))
            : DateTime.now().add(const Duration(days: 7)));

    return AuthToken(
      accessToken: accessToken,
      refreshToken: refreshToken,
      expiresAt: effectiveExpiresAt,
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
