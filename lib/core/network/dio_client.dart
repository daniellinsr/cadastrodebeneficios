import 'package:dio/dio.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import 'package:cadastro_beneficios/core/network/api_endpoints.dart';
import 'package:cadastro_beneficios/core/network/interceptors/auth_interceptor.dart';
import 'package:cadastro_beneficios/core/network/interceptors/refresh_token_interceptor.dart';
import 'package:cadastro_beneficios/core/services/token_service.dart';

/// Cliente Dio configurado para comunicação com API
///
/// Singleton que gerencia todas as requisições HTTP
class DioClient {
  static DioClient? _instance;
  late final Dio _dio;

  DioClient._internal({
    required TokenService tokenService,
  }) {
    _dio = Dio(
      BaseOptions(
        baseUrl: ApiEndpoints.baseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    // Adicionar interceptors na ordem correta
    _dio.interceptors.addAll([
      // 1. Auth Interceptor (adiciona token nas requests)
      AuthInterceptor(tokenService),

      // 2. Refresh Token Interceptor (renova token quando expira)
      RefreshTokenInterceptor(tokenService, _dio),

      // 3. Logger (último para ver requisição final)
      PrettyDioLogger(
        requestHeader: true,
        requestBody: true,
        responseBody: true,
        responseHeader: false,
        error: true,
        compact: true,
        maxWidth: 90,
      ),
    ]);
  }

  /// Factory constructor para singleton
  factory DioClient({required TokenService tokenService}) {
    _instance ??= DioClient._internal(tokenService: tokenService);
    return _instance!;
  }

  /// Obter instância do Dio
  Dio get dio => _dio;

  // ===== Métodos HTTP =====

  /// GET request
  Future<Response> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    return await _dio.get(
      path,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
    );
  }

  /// POST request
  Future<Response> post(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    return await _dio.post(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
    );
  }

  /// PUT request
  Future<Response> put(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    return await _dio.put(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
    );
  }

  /// PATCH request
  Future<Response> patch(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    return await _dio.patch(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
    );
  }

  /// DELETE request
  Future<Response> delete(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    return await _dio.delete(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
    );
  }
}
