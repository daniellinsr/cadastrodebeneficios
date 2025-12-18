import 'package:flutter/foundation.dart';
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

  // Fallback em memória caso storage falhe (comum na web)
  AuthToken? _inMemoryToken;

  // Flag para logar erro de storage apenas uma vez
  bool _storageFailureLogged = false;

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
    // Sempre salvar em memória primeiro (fallback)
    _inMemoryToken = token;

    try {
      await Future.wait([
        _secureStorage.write(key: _accessTokenKey, value: token.accessToken),
        _secureStorage.write(key: _refreshTokenKey, value: token.refreshToken),
        _secureStorage.write(
          key: _expiresAtKey,
          value: token.expiresAt.toIso8601String(),
        ),
        _secureStorage.write(key: _tokenTypeKey, value: token.tokenType),
      ]);
    } catch (e) {
      // Se falhar ao salvar (comum na web com storage bloqueado), usar fallback em memória
      debugPrint('⚠️ Erro ao salvar token no storage: $e');
      debugPrint('✅ Token salvo em memória como fallback');
    }
  }

  /// Obter token
  Future<AuthToken?> getToken() async {
    try {
      final accessToken = await _secureStorage.read(key: _accessTokenKey);
      final refreshToken = await _secureStorage.read(key: _refreshTokenKey);
      final expiresAtString = await _secureStorage.read(key: _expiresAtKey);
      final tokenType = await _secureStorage.read(key: _tokenTypeKey);

      if (accessToken == null ||
          refreshToken == null ||
          expiresAtString == null) {
        // Se não tiver no storage, tentar fallback em memória (silencioso)
        return _inMemoryToken;
      }

      return AuthToken(
        accessToken: accessToken,
        refreshToken: refreshToken,
        expiresAt: DateTime.parse(expiresAtString),
        tokenType: tokenType ?? 'Bearer',
      );
    } catch (e) {
      // Logar apenas na primeira vez
      if (!_storageFailureLogged) {
        debugPrint('⚠️ Storage não disponível (web): usando autenticação em memória');
        _storageFailureLogged = true;
      }
      return _inMemoryToken;
    }
  }

  /// Obter apenas access token
  Future<String?> getAccessToken() async {
    try {
      final token = await _secureStorage.read(key: _accessTokenKey);
      if (token == null) {
        // Fallback para memória (silencioso)
        return _inMemoryToken?.accessToken;
      }
      return token;
    } catch (e) {
      // Logar apenas na primeira vez
      if (!_storageFailureLogged) {
        debugPrint('⚠️ Storage não disponível (web): usando autenticação em memória');
        _storageFailureLogged = true;
      }
      return _inMemoryToken?.accessToken;
    }
  }

  /// Obter apenas refresh token
  Future<String?> getRefreshToken() async {
    try {
      final token = await _secureStorage.read(key: _refreshTokenKey);
      if (token == null) {
        // Fallback para memória (silencioso)
        return _inMemoryToken?.refreshToken;
      }
      return token;
    } catch (e) {
      // Logar apenas na primeira vez
      if (!_storageFailureLogged) {
        debugPrint('⚠️ Storage não disponível (web): usando autenticação em memória');
        _storageFailureLogged = true;
      }
      return _inMemoryToken?.refreshToken;
    }
  }

  /// Verificar se existe token salvo
  Future<bool> hasToken() async {
    try {
      final accessToken = await _secureStorage.read(key: _accessTokenKey);
      if (accessToken != null) {
        return true;
      }
      // Fallback para memória (silencioso para não poluir logs)
      return _inMemoryToken != null;
    } catch (e) {
      // Logar erro apenas uma vez para não poluir console
      if (!_storageFailureLogged) {
        debugPrint('⚠️ Storage não disponível (web): usando autenticação em memória');
        _storageFailureLogged = true;
      }
      // Fallback para memória
      return _inMemoryToken != null;
    }
  }

  /// Deletar token (logout)
  Future<void> deleteToken() async {
    // Limpar memória
    _inMemoryToken = null;

    try {
      await Future.wait([
        _secureStorage.delete(key: _accessTokenKey),
        _secureStorage.delete(key: _refreshTokenKey),
        _secureStorage.delete(key: _expiresAtKey),
        _secureStorage.delete(key: _tokenTypeKey),
      ]);
    } catch (e) {
      debugPrint('⚠️ Erro ao deletar token do storage: $e');
    }
  }

  /// Limpar todo o armazenamento
  Future<void> deleteAll() async {
    // Limpar memória
    _inMemoryToken = null;

    try {
      await _secureStorage.deleteAll();
    } catch (e) {
      debugPrint('⚠️ Erro ao limpar armazenamento: $e');
    }
  }
}
