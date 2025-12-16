import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:logger/logger.dart';

/// Configuração de variáveis de ambiente
///
/// Carrega e fornece acesso às variáveis definidas no arquivo .env
class EnvConfig {
  static final Logger _logger = Logger();
  /// Carrega as variáveis de ambiente do arquivo .env
  ///
  /// Deve ser chamado no main() antes de runApp()
  static Future<void> load() async {
    await dotenv.load(fileName: '.env');
  }

  // ===================================
  // Backend API
  // ===================================

  /// URL base da API backend
  static String get backendApiUrl =>
      dotenv.env['BACKEND_API_URL'] ?? 'http://localhost:3000';

  /// Timeout da API em milissegundos
  static int get backendApiTimeout =>
      int.tryParse(dotenv.env['BACKEND_API_TIMEOUT'] ?? '30000') ?? 30000;

  // ===================================
  // Google Services
  // ===================================

  /// Google Maps API Key
  static String get googleMapsApiKey =>
      dotenv.env['GOOGLE_MAPS_API_KEY'] ?? '';

  /// Google OAuth Web Client ID
  static String get googleWebClientId =>
      dotenv.env['GOOGLE_WEB_CLIENT_ID'] ??
      '403775802042-dr9hvctbr6qfildd767us0o057m3iu3m.apps.googleusercontent.com';

  // ===================================
  // Feature Flags
  // ===================================

  /// Login com Google habilitado
  static bool get enableGoogleLogin =>
      dotenv.env['ENABLE_GOOGLE_LOGIN']?.toLowerCase() == 'true';

  /// Autenticação biométrica habilitada
  static bool get enableBiometricAuth =>
      dotenv.env['ENABLE_BIOMETRIC_AUTH']?.toLowerCase() == 'true';

  /// Serviços de localização habilitados
  static bool get enableLocationServices =>
      dotenv.env['ENABLE_LOCATION_SERVICES']?.toLowerCase() == 'true';

  /// Logs de debug habilitados
  static bool get enableDebugLogs =>
      dotenv.env['ENABLE_DEBUG_LOGS']?.toLowerCase() == 'true';

  // ===================================
  // App Configuration
  // ===================================

  /// Nome do aplicativo
  static String get appName =>
      dotenv.env['APP_NAME'] ?? 'Sistema de Cartão de Benefícios';

  /// Versão do aplicativo
  static String get appVersion => dotenv.env['APP_VERSION'] ?? '1.0.0';

  /// Ambiente (development, staging, production)
  static String get environment => dotenv.env['ENVIRONMENT'] ?? 'development';

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

    // Adicionar mais validações conforme necessário
    // if (googleMapsApiKey.isEmpty && enableLocationServices) {
    //   missingVars.add('GOOGLE_MAPS_API_KEY');
    // }

    if (missingVars.isNotEmpty) {
      throw Exception(
        'Variáveis de ambiente obrigatórias faltando: ${missingVars.join(', ')}\n'
        'Verifique o arquivo .env',
      );
    }
  }

  /// Imprime todas as configurações (sem mostrar valores sensíveis)
  ///
  /// Útil para debug
  static void printConfig() {
    if (!enableDebugLogs) return;

    _logger.d('=== Environment Configuration ===');
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
