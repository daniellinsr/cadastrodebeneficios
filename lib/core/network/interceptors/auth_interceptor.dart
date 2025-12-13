import 'package:dio/dio.dart';
import 'package:cadastro_beneficios/core/services/token_service.dart';

/// Interceptor para adicionar token de autenticação nas requisições
///
/// Adiciona automaticamente o header Authorization com Bearer token
class AuthInterceptor extends Interceptor {
  final TokenService _tokenService;

  AuthInterceptor(this._tokenService);

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // Obter access token
    final accessToken = await _tokenService.getAccessToken();

    // Se existir token, adicionar ao header
    if (accessToken != null && accessToken.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $accessToken';
    }

    // Continuar com a requisição
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    // Tratar erros específicos de autenticação
    if (err.response?.statusCode == 401) {
      // Token inválido ou expirado
      // O RefreshTokenInterceptor irá lidar com isso
    }

    handler.next(err);
  }
}
