import 'package:cadastro_beneficios/core/services/registration_service.dart';
import 'package:cadastro_beneficios/core/services/token_service.dart';
import 'package:cadastro_beneficios/core/services/google_auth_service.dart';
import 'package:cadastro_beneficios/core/network/dio_client.dart';
import 'package:cadastro_beneficios/data/datasources/auth_remote_datasource.dart';
import 'package:cadastro_beneficios/data/datasources/auth_local_datasource.dart';
import 'package:cadastro_beneficios/data/repositories/auth_repository_impl.dart';
import 'package:cadastro_beneficios/domain/repositories/auth_repository.dart';

/// Service Locator simples para Dependency Injection
///
/// Centraliza a criação de instâncias dos serviços da aplicação
class ServiceLocator {
  static final ServiceLocator _instance = ServiceLocator._internal();
  factory ServiceLocator() => _instance;
  ServiceLocator._internal();

  // Instâncias lazy-loaded
  late final TokenService tokenService;
  late final GoogleAuthService googleAuthService;
  late final DioClient dioClient;
  late final AuthRemoteDataSource authRemoteDataSource;
  late final AuthLocalDataSource authLocalDataSource;
  late final AuthRepository authRepository;
  late final RegistrationService registrationService;

  /// Inicializa todos os serviços
  Future<void> init() async {
    // 1. Token Service (secure storage)
    tokenService = TokenService();

    // 2. Google Auth Service
    googleAuthService = GoogleAuthService();

    // 3. Dio Client (HTTP client)
    dioClient = DioClient(tokenService: tokenService);

    // 4. DataSources
    authRemoteDataSource = AuthRemoteDataSourceImpl(dioClient);
    authLocalDataSource = AuthLocalDataSourceImpl();

    // 5. Repositories
    authRepository = AuthRepositoryImpl(
      remoteDataSource: authRemoteDataSource,
      localDataSource: authLocalDataSource,
      tokenService: tokenService,
    );

    // 6. Registration Service
    registrationService = RegistrationService(
      authRepository: authRepository,
      tokenService: tokenService,
    );
  }
}

/// Helper para acessar o service locator
final sl = ServiceLocator();
