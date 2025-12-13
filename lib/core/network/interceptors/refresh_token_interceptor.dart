import 'dart:async';
import 'package:dio/dio.dart';
import 'package:cadastro_beneficios/core/services/token_service.dart';
import 'package:cadastro_beneficios/core/network/api_endpoints.dart';
import 'package:cadastro_beneficios/data/models/auth_token_model.dart';

/// Interceptor para refresh automático de token
///
/// Quando recebe erro 401, tenta renovar o token automaticamente
class RefreshTokenInterceptor extends Interceptor {
  final TokenService _tokenService;
  final Dio _dio;
  bool _isRefreshing = false;
  final List<_PendingRequest> _pendingRequests = [];

  RefreshTokenInterceptor(this._tokenService, this._dio);

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    // Verificar se é erro 401 (Unauthorized)
    if (err.response?.statusCode != 401) {
      return handler.next(err);
    }

    // Verificar se não é a própria rota de refresh
    if (err.requestOptions.path == ApiEndpoints.refreshToken) {
      // Falha no refresh, fazer logout
      await _tokenService.deleteToken();
      return handler.next(err);
    }

    // Verificar se já está fazendo refresh
    if (_isRefreshing) {
      // Adicionar requisição à fila
      try {
        final response = await _addToQueue(err.requestOptions);
        return handler.resolve(response);
      } catch (e) {
        return handler.next(err);
      }
    }

    // Iniciar processo de refresh
    _isRefreshing = true;

    try {
      // Obter refresh token
      final refreshToken = await _tokenService.getRefreshToken();

      if (refreshToken == null) {
        await _tokenService.deleteToken();
        return handler.next(err);
      }

      // Fazer request de refresh (sem interceptors para evitar loop)
      final response = await Dio(BaseOptions(
        baseUrl: _dio.options.baseUrl,
      )).post(
        ApiEndpoints.refreshToken,
        data: {'refresh_token': refreshToken},
      );

      // Parsear novo token
      final newToken = AuthTokenModel.fromJson(response.data);

      // Salvar novo token
      await _tokenService.saveToken(newToken.toEntity());

      // Processar requisições pendentes
      await _processQueue();

      // Retentar requisição original
      final retryResponse = await _retry(err.requestOptions);

      return handler.resolve(retryResponse);
    } on DioException catch (e) {
      // Falha no refresh, fazer logout
      await _tokenService.deleteToken();

      // Limpar fila
      _pendingRequests.clear();

      return handler.next(e);
    } finally {
      _isRefreshing = false;
    }
  }

  /// Adicionar requisição à fila de pendentes
  Future<Response> _addToQueue(RequestOptions requestOptions) {
    final completer = _PendingRequest();
    _pendingRequests.add(completer);

    return completer.completer.future.then((_) {
      return _retry(requestOptions);
    });
  }

  /// Processar fila de requisições pendentes
  Future<void> _processQueue() async {
    for (final request in _pendingRequests) {
      request.completer.complete();
    }
    _pendingRequests.clear();
  }

  /// Retentar requisição com novo token
  Future<Response> _retry(RequestOptions requestOptions) async {
    // Obter novo access token
    final accessToken = await _tokenService.getAccessToken();

    // Atualizar header
    requestOptions.headers['Authorization'] = 'Bearer $accessToken';

    // Retentar requisição
    return await _dio.request(
      requestOptions.path,
      data: requestOptions.data,
      queryParameters: requestOptions.queryParameters,
      options: Options(
        method: requestOptions.method,
        headers: requestOptions.headers,
      ),
    );
  }
}

/// Classe auxiliar para gerenciar requisições pendentes
class _PendingRequest {
  final completer = Completer<void>();
}
