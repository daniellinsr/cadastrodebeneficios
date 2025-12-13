import 'package:equatable/equatable.dart';

/// Entidade AuthToken - Representa os tokens de autenticação JWT
///
/// Contém access token e refresh token para autenticação segura
class AuthToken extends Equatable {
  final String accessToken;
  final String refreshToken;
  final DateTime expiresAt;
  final String tokenType;

  const AuthToken({
    required this.accessToken,
    required this.refreshToken,
    required this.expiresAt,
    this.tokenType = 'Bearer',
  });

  /// Verifica se o token está expirado
  bool get isExpired {
    return DateTime.now().isAfter(expiresAt);
  }

  /// Verifica se o token está próximo de expirar (5 minutos)
  bool get isNearExpiry {
    final fiveMinutesFromNow = DateTime.now().add(const Duration(minutes: 5));
    return fiveMinutesFromNow.isAfter(expiresAt);
  }

  /// Tempo restante até expiração
  Duration get timeUntilExpiry {
    return expiresAt.difference(DateTime.now());
  }

  /// Cria cópia do token com campos atualizados
  AuthToken copyWith({
    String? accessToken,
    String? refreshToken,
    DateTime? expiresAt,
    String? tokenType,
  }) {
    return AuthToken(
      accessToken: accessToken ?? this.accessToken,
      refreshToken: refreshToken ?? this.refreshToken,
      expiresAt: expiresAt ?? this.expiresAt,
      tokenType: tokenType ?? this.tokenType,
    );
  }

  @override
  List<Object?> get props => [
        accessToken,
        refreshToken,
        expiresAt,
        tokenType,
      ];
}
