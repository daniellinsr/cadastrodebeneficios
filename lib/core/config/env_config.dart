import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:logger/logger.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

// ignore: avoid_web_libraries_in_flutter
import 'dart:js_interop';
import 'dart:js_interop_unsafe';

@JS('ENV_CONFIG')
external JSObject? get envConfig;

/// Configuração de variáveis de ambiente
///
/// Carrega e fornece acesso às variáveis definidas no arquivo .env (mobile/desktop)
/// ou window.ENV_CONFIG (web)
class EnvConfig {
  static final Logger _logger = Logger();

  /// Carrega as variáveis de ambiente
  ///
  /// Deve ser chamado no main() antes de runApp()
  static Future<void> load() async {
    if (!kIsWeb) {
      await dotenv.load(fileName: '.env');
    }
    // Para web, as variáveis são carregadas do env.js via window.ENV_CONFIG
  }

  /// Obtém uma variável de ambiente
  static String _getEnv(String key, String defaultValue) {
    if (kIsWeb) {
      try {
        final config = envConfig;
        if (config != null) {
          final value = config.getProperty(key.toJS);
          if (value != null && !value.isUndefined && !value.isNull) {
            return value.dartify().toString();
          }
        }
      } catch (e) {
        _logger.w('Error reading ENV_CONFIG.$key: $e');
      }
      return defaultValue;
    } else {
      return dotenv.env[key] ?? defaultValue;
    }
  }

  // ===================================
  // Backend API
  // ===================================

  /// URL base da API backend
  static String get backendApiUrl =>
      _getEnv('BACKEND_API_URL', 'http://localhost:3000');

  /// Timeout da API em milissegundos
  static int get backendApiTimeout =>
      int.tryParse(_getEnv('BACKEND_API_TIMEOUT', '30000')) ?? 30000;

  // ===================================
  // Google Services
  // ===================================

  /// Google Maps API Key
  static String get googleMapsApiKey =>
      _getEnv('GOOGLE_MAPS_API_KEY', '');

  /// Google OAuth Web Client ID
  static String get googleWebClientId =>
      _getEnv('GOOGLE_WEB_CLIENT_ID',
          '403775802042-dr9hvctbr6qfildd767us0o057m3iu3m.apps.googleusercontent.com');

  // ===================================
  // Feature Flags
  // ===================================

  /// Login com Google habilitado
  static bool get enableGoogleLogin =>
      _getEnv('ENABLE_GOOGLE_LOGIN', 'false').toLowerCase() == 'true';

  /// Autenticação biométrica habilitada
  static bool get enableBiometricAuth =>
      _getEnv('ENABLE_BIOMETRIC_AUTH', 'false').toLowerCase() == 'true';

  /// Serviços de localização habilitados
  static bool get enableLocationServices =>
      _getEnv('ENABLE_LOCATION_SERVICES', 'false').toLowerCase() == 'true';

  /// Logs de debug habilitados
  static bool get enableDebugLogs =>
      _getEnv('ENABLE_DEBUG_LOGS', 'false').toLowerCase() == 'true';

  // ===================================
  // App Configuration
  // ===================================

  /// Nome do aplicativo
  static String get appName =>
      _getEnv('APP_NAME', 'Sistema de Cartão de Benefícios');

  /// Versão do aplicativo
  static String get appVersion => _getEnv('APP_VERSION', '1.0.0');

  /// Ambiente (development, staging, production)
  static String get environment => _getEnv('ENVIRONMENT', 'development');

  /// Verifica se está em modo de desenvolvimento
  static bool get isDevelopment => environment == 'development';

  /// Verifica se está em modo de staging
  static bool get isStaging => environment == 'staging';

  /// Verifica se está em modo de produção
  static bool get isProduction => environment == 'production';

  // ===================================
  // Validação
  // ===================================

  /// Valida se todas as variáveis obrigatórias estão configuradas
  ///
  /// Throws [Exception] se alguma variável obrigatória estiver faltando
  static void validate() {
    final missingVars = <String>[];

    if (backendApiUrl.isEmpty) {
      missingVars.add('BACKEND_API_URL');
    }

    if (missingVars.isNotEmpty) {
      throw Exception(
        'Variáveis de ambiente obrigatórias faltando: ${missingVars.join(', ')}\n'
        'Verifique o arquivo .env ou window.ENV_CONFIG',
      );
    }
  }

  /// Imprime todas as configurações (sem mostrar valores sensíveis)
  ///
  /// Útil para debug
  static void printConfig() {
    if (!enableDebugLogs) return;

    _logger.d('=== Environment Configuration ===');
    _logger.d('Platform: ${kIsWeb ? "Web" : "Native"}');
    _logger.d('Environment: $environment');
    _logger.d('App Name: $appName');
    _logger.d('App Version: $appVersion');
    _logger.d('Backend API URL: $backendApiUrl');
    _logger.d('Backend API Timeout: ${backendApiTimeout}ms');
    _logger.d('Google Maps API Key: ${googleMapsApiKey.isNotEmpty ? '***configured***' : 'NOT SET'}');
    _logger.d('Google Web Client ID: ${googleWebClientId.isNotEmpty ? '***configured***' : 'NOT SET'}');
    _logger.d('--- Feature Flags ---');
    _logger.d('Enable Google Login: $enableGoogleLogin');
    _logger.d('Enable Biometric Auth: $enableBiometricAuth');
    _logger.d('Enable Location Services: $enableLocationServices');
    _logger.d('Enable Debug Logs: $enableDebugLogs');
    _logger.d('================================');
  }
}
