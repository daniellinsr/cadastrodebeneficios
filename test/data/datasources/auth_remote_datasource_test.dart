import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:dio/dio.dart';
import 'package:cadastro_beneficios/core/network/dio_client.dart';
import 'package:cadastro_beneficios/core/network/api_endpoints.dart';
import 'package:cadastro_beneficios/data/datasources/auth_remote_datasource.dart';
import 'package:cadastro_beneficios/data/models/auth_token_model.dart';
import 'package:cadastro_beneficios/data/models/user_model.dart';
import 'package:cadastro_beneficios/domain/repositories/auth_repository.dart';

import 'auth_remote_datasource_test.mocks.dart';

@GenerateMocks([DioClient])
void main() {
  late AuthRemoteDataSourceImpl dataSource;
  late MockDioClient mockDioClient;

  setUp(() {
    mockDioClient = MockDioClient();
    dataSource = AuthRemoteDataSourceImpl(mockDioClient);
  });

  final tAuthTokenJson = {
    'access_token': 'access_token_123',
    'refresh_token': 'refresh_token_456',
    'expires_at': '2024-12-31T23:59:00.000',
    'token_type': 'Bearer',
  };

  final tUserJson = {
    'id': '123',
    'name': 'João Silva',
    'email': 'joao@exemplo.com',
    'phone_number': '11987654321',
    'role': 'beneficiary',
    'created_at': '2024-01-01T00:00:00.000',
    'is_email_verified': true,
    'is_phone_verified': false,
  };

  group('AuthRemoteDataSource - loginWithEmail', () {
    test('deve retornar AuthTokenModel quando login for bem-sucedido', () async {
      // Arrange
      when(mockDioClient.post(
        ApiEndpoints.login,
        data: anyNamed('data'),
      )).thenAnswer((_) async => Response(
            data: tAuthTokenJson,
            statusCode: 200,
            requestOptions: RequestOptions(path: ApiEndpoints.login),
          ));

      // Act
      final result = await dataSource.loginWithEmail(
        email: 'joao@exemplo.com',
        password: 'senha123',
      );

      // Assert
      expect(result, isA<AuthTokenModel>());
      expect(result.accessToken, 'access_token_123');
      expect(result.refreshToken, 'refresh_token_456');
      verify(mockDioClient.post(
        ApiEndpoints.login,
        data: {
          'email': 'joao@exemplo.com',
          'password': 'senha123',
        },
      ));
    });

    test('deve enviar email e password corretos no body', () async {
      // Arrange
      when(mockDioClient.post(
        any,
        data: anyNamed('data'),
      )).thenAnswer((_) async => Response(
            data: tAuthTokenJson,
            statusCode: 200,
            requestOptions: RequestOptions(path: ApiEndpoints.login),
          ));

      // Act
      await dataSource.loginWithEmail(
        email: 'teste@exemplo.com',
        password: 'minhasenha',
      );

      // Assert
      verify(mockDioClient.post(
        ApiEndpoints.login,
        data: {
          'email': 'teste@exemplo.com',
          'password': 'minhasenha',
        },
      ));
    });
  });

  group('AuthRemoteDataSource - register', () {
    test('deve retornar AuthTokenModel quando registro for bem-sucedido',
        () async {
      // Arrange
      when(mockDioClient.post(
        ApiEndpoints.register,
        data: anyNamed('data'),
      )).thenAnswer((_) async => Response(
            data: tAuthTokenJson,
            statusCode: 201,
            requestOptions: RequestOptions(path: ApiEndpoints.register),
          ));

      // Act
      final result = await dataSource.register(
        name: 'João Silva',
        email: 'joao@exemplo.com',
        password: 'senha123456',
        phoneNumber: '11987654321',
        cpf: '12345678900',
      );

      // Assert
      expect(result, isA<AuthTokenModel>());
      expect(result.accessToken, 'access_token_123');
      verify(mockDioClient.post(
        ApiEndpoints.register,
        data: {
          'name': 'João Silva',
          'email': 'joao@exemplo.com',
          'password': 'senha123456',
          'phone_number': '11987654321',
          'cpf': '12345678900',
        },
      ));
    });

    test('deve registrar sem CPF quando CPF for null', () async {
      // Arrange
      when(mockDioClient.post(
        ApiEndpoints.register,
        data: anyNamed('data'),
      )).thenAnswer((_) async => Response(
            data: tAuthTokenJson,
            statusCode: 201,
            requestOptions: RequestOptions(path: ApiEndpoints.register),
          ));

      // Act
      await dataSource.register(
        name: 'João Silva',
        email: 'joao@exemplo.com',
        password: 'senha123456',
        phoneNumber: '11987654321',
      );

      // Assert
      verify(mockDioClient.post(
        ApiEndpoints.register,
        data: {
          'name': 'João Silva',
          'email': 'joao@exemplo.com',
          'password': 'senha123456',
          'phone_number': '11987654321',
        },
      ));
    });
  });

  group('AuthRemoteDataSource - getCurrentUser', () {
    test('deve retornar UserModel quando busca for bem-sucedida', () async {
      // Arrange
      when(mockDioClient.get(ApiEndpoints.me))
          .thenAnswer((_) async => Response(
                data: tUserJson,
                statusCode: 200,
                requestOptions: RequestOptions(path: ApiEndpoints.me),
              ));

      // Act
      final result = await dataSource.getCurrentUser();

      // Assert
      expect(result, isA<UserModel>());
      expect(result.id, '123');
      expect(result.name, 'João Silva');
      expect(result.email, 'joao@exemplo.com');
      verify(mockDioClient.get(ApiEndpoints.me));
    });
  });

  group('AuthRemoteDataSource - logout', () {
    test('deve chamar endpoint de logout com sucesso', () async {
      // Arrange
      when(mockDioClient.post(ApiEndpoints.logout))
          .thenAnswer((_) async => Response(
                data: {'message': 'Logout successful'},
                statusCode: 200,
                requestOptions: RequestOptions(path: ApiEndpoints.logout),
              ));

      // Act
      await dataSource.logout();

      // Assert
      verify(mockDioClient.post(ApiEndpoints.logout));
    });
  });

  group('AuthRemoteDataSource - forgotPassword', () {
    test('deve enviar email para recuperação de senha', () async {
      // Arrange
      when(mockDioClient.post(
        ApiEndpoints.forgotPassword,
        data: anyNamed('data'),
      )).thenAnswer((_) async => Response(
            data: {'message': 'Email sent'},
            statusCode: 200,
            requestOptions: RequestOptions(path: ApiEndpoints.forgotPassword),
          ));

      // Act
      await dataSource.forgotPassword(email: 'joao@exemplo.com');

      // Assert
      verify(mockDioClient.post(
        ApiEndpoints.forgotPassword,
        data: {'email': 'joao@exemplo.com'},
      ));
    });
  });

  group('AuthRemoteDataSource - resetPassword', () {
    test('deve resetar senha com token e nova senha', () async {
      // Arrange
      when(mockDioClient.post(
        ApiEndpoints.resetPassword,
        data: anyNamed('data'),
      )).thenAnswer((_) async => Response(
            data: {'message': 'Password reset successful'},
            statusCode: 200,
            requestOptions: RequestOptions(path: ApiEndpoints.resetPassword),
          ));

      // Act
      await dataSource.resetPassword(
        token: 'reset_token_123',
        newPassword: 'novasenha123',
      );

      // Assert
      verify(mockDioClient.post(
        ApiEndpoints.resetPassword,
        data: {
          'token': 'reset_token_123',
          'password': 'novasenha123',
        },
      ));
    });
  });

  group('AuthRemoteDataSource - refreshToken', () {
    test('deve retornar novo AuthTokenModel ao renovar token', () async {
      // Arrange
      final newTokenJson = {
        'access_token': 'new_access_token',
        'refresh_token': 'new_refresh_token',
        'expires_at': '2025-01-31T23:59:00.000',
        'token_type': 'Bearer',
      };

      when(mockDioClient.post(
        ApiEndpoints.refreshToken,
        data: anyNamed('data'),
      )).thenAnswer((_) async => Response(
            data: newTokenJson,
            statusCode: 200,
            requestOptions: RequestOptions(path: ApiEndpoints.refreshToken),
          ));

      // Act
      final result = await dataSource.refreshToken(
        refreshToken: 'old_refresh_token',
      );

      // Assert
      expect(result, isA<AuthTokenModel>());
      expect(result.accessToken, 'new_access_token');
      expect(result.refreshToken, 'new_refresh_token');
      verify(mockDioClient.post(
        ApiEndpoints.refreshToken,
        data: {'refresh_token': 'old_refresh_token'},
      ));
    });
  });

  group('AuthRemoteDataSource - sendVerificationCode', () {
    test('deve enviar código de verificação via SMS', () async {
      // Arrange
      when(mockDioClient.post(
        ApiEndpoints.sendVerificationCode,
        data: anyNamed('data'),
      )).thenAnswer((_) async => Response(
            data: {'message': 'Code sent'},
            statusCode: 200,
            requestOptions:
                RequestOptions(path: ApiEndpoints.sendVerificationCode),
          ));

      // Act
      await dataSource.sendVerificationCode(
        phoneNumber: '11987654321',
        method: VerificationMethod.sms,
      );

      // Assert
      verify(mockDioClient.post(
        ApiEndpoints.sendVerificationCode,
        data: {
          'phone_number': '11987654321',
          'method': 'sms',
        },
      ));
    });

    test('deve enviar código de verificação via WhatsApp', () async {
      // Arrange
      when(mockDioClient.post(
        ApiEndpoints.sendVerificationCode,
        data: anyNamed('data'),
      )).thenAnswer((_) async => Response(
            data: {'message': 'Code sent'},
            statusCode: 200,
            requestOptions:
                RequestOptions(path: ApiEndpoints.sendVerificationCode),
          ));

      // Act
      await dataSource.sendVerificationCode(
        phoneNumber: '11987654321',
        method: VerificationMethod.whatsapp,
      );

      // Assert
      verify(mockDioClient.post(
        ApiEndpoints.sendVerificationCode,
        data: {
          'phone_number': '11987654321',
          'method': 'whatsapp',
        },
      ));
    });
  });

  group('AuthRemoteDataSource - verifyCode', () {
    test('deve verificar código com sucesso', () async {
      // Arrange
      when(mockDioClient.post(
        ApiEndpoints.verifyCode,
        data: anyNamed('data'),
      )).thenAnswer((_) async => Response(
            data: {'message': 'Code verified'},
            statusCode: 200,
            requestOptions: RequestOptions(path: ApiEndpoints.verifyCode),
          ));

      // Act
      await dataSource.verifyCode(
        phoneNumber: '11987654321',
        code: '123456',
      );

      // Assert
      verify(mockDioClient.post(
        ApiEndpoints.verifyCode,
        data: {
          'phone_number': '11987654321',
          'code': '123456',
        },
      ));
    });
  });
}
