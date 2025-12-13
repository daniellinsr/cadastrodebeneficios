import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:cadastro_beneficios/domain/entities/auth_token.dart';

/// Serviço para gerenciar tokens de autenticação
///
/// Usa FlutterSecureStorage para armazenamento seguro
class TokenService {
  final FlutterSecureStorage _secureStorage;

  // Keys para armazenamento
  static const String _accessTokenKey = 'access_token';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _expiresAtKey = 'expires_at';
  static const String _tokenTypeKey = 'token_type';

  TokenService({
    FlutterSecureStorage? secureStorage,
  }) : _secureStorage = secureStorage ??
            const FlutterSecureStorage(
              aOptions: AndroidOptions(
                encryptedSharedPreferences: true,
              ),
            );

  /// Salvar token
  Future<void> saveToken(AuthToken token) async {
    await Future.wait([
      _secureStorage.write(key: _accessTokenKey, value: token.accessToken),
      _secureStorage.write(key: _refreshTokenKey, value: token.refreshToken),
      _secureStorage.write(
        key: _expiresAtKey,
        value: token.expiresAt.toIso8601String(),
      ),
      _secureStorage.write(key: _tokenTypeKey, value: token.tokenType),
    ]);
  }

  /// Obter token
  Future<AuthToken?> getToken() async {
    final accessToken = await _secureStorage.read(key: _accessTokenKey);
    final refreshToken = await _secureStorage.read(key: _refreshTokenKey);
    final expiresAtString = await _secureStorage.read(key: _expiresAtKey);
    final tokenType = await _secureStorage.read(key: _tokenTypeKey);

    if (accessToken == null ||
        refreshToken == null ||
        expiresAtString == null) {
      return null;
    }

    return AuthToken(
      accessToken: accessToken,
      refreshToken: refreshToken,
      expiresAt: DateTime.parse(expiresAtString),
      tokenType: tokenType ?? 'Bearer',
    );
  }

  /// Obter apenas access token
  Future<String?> getAccessToken() async {
    return await _secureStorage.read(key: _accessTokenKey);
  }

  /// Obter apenas refresh token
  Future<String?> getRefreshToken() async {
    return await _secureStorage.read(key: _refreshTokenKey);
  }

  /// Verificar se existe token salvo
  Future<bool> hasToken() async {
    final accessToken = await _secureStorage.read(key: _accessTokenKey);
    return accessToken != null;
  }

  /// Deletar token (logout)
  Future<void> deleteToken() async {
    await Future.wait([
      _secureStorage.delete(key: _accessTokenKey),
      _secureStorage.delete(key: _refreshTokenKey),
      _secureStorage.delete(key: _expiresAtKey),
      _secureStorage.delete(key: _tokenTypeKey),
    ]);
  }

  /// Limpar todo o armazenamento
  Future<void> deleteAll() async {
    await _secureStorage.deleteAll();
  }
}
