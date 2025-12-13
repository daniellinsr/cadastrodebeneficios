import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:cadastro_beneficios/data/models/auth_token_model.dart';
import 'package:cadastro_beneficios/domain/entities/auth_token.dart';

void main() {
  final tAuthTokenModel = AuthTokenModel(
    accessToken: 'access_token_123',
    refreshToken: 'refresh_token_456',
    expiresAt: DateTime(2024, 12, 31, 23, 59),
    tokenType: 'Bearer',
  );

  final tAuthTokenJson = {
    'access_token': 'access_token_123',
    'refresh_token': 'refresh_token_456',
    'expires_at': '2024-12-31T23:59:00.000',
    'token_type': 'Bearer',
  };

  group('AuthTokenModel', () {
    test('deve ser uma subclasse de objeto', () {
      // Assert
      expect(tAuthTokenModel, isA<Object>());
    });

    test('fromJson deve criar AuthTokenModel a partir de JSON', () {
      // Act
      final result = AuthTokenModel.fromJson(tAuthTokenJson);

      // Assert
      expect(result.accessToken, 'access_token_123');
      expect(result.refreshToken, 'refresh_token_456');
      expect(result.expiresAt, DateTime(2024, 12, 31, 23, 59));
      expect(result.tokenType, 'Bearer');
    });

    test('toJson deve converter AuthTokenModel para JSON', () {
      // Act
      final result = tAuthTokenModel.toJson();

      // Assert
      expect(result['access_token'], 'access_token_123');
      expect(result['refresh_token'], 'refresh_token_456');
      expect(result['expires_at'], '2024-12-31T23:59:00.000');
      expect(result['token_type'], 'Bearer');
    });

    test('fromJson deve lidar com token_type padrão Bearer', () {
      // Arrange
      final jsonWithoutTokenType = {
        'access_token': 'access_token_123',
        'refresh_token': 'refresh_token_456',
        'expires_at': '2024-12-31T23:59:00.000',
      };

      // Act
      final result = AuthTokenModel.fromJson(jsonWithoutTokenType);

      // Assert
      expect(result.tokenType, 'Bearer');
    });

    test('toEntity deve converter AuthTokenModel para AuthToken entity',
        () {
      // Act
      final result = tAuthTokenModel.toEntity();

      // Assert
      expect(result, isA<AuthToken>());
      expect(result.accessToken, tAuthTokenModel.accessToken);
      expect(result.refreshToken, tAuthTokenModel.refreshToken);
      expect(result.expiresAt, tAuthTokenModel.expiresAt);
      expect(result.tokenType, tAuthTokenModel.tokenType);
    });

    test('fromEntity deve criar AuthTokenModel a partir de AuthToken entity',
        () {
      // Arrange
      final tAuthToken = AuthToken(
        accessToken: 'access_token_123',
        refreshToken: 'refresh_token_456',
        expiresAt: DateTime(2024, 12, 31, 23, 59),
        tokenType: 'Bearer',
      );

      // Act
      final result = AuthTokenModel.fromEntity(tAuthToken);

      // Assert
      expect(result, isA<AuthTokenModel>());
      expect(result.accessToken, tAuthToken.accessToken);
      expect(result.refreshToken, tAuthToken.refreshToken);
      expect(result.expiresAt, tAuthToken.expiresAt);
      expect(result.tokenType, tAuthToken.tokenType);
    });

    test('deve serializar e desserializar corretamente via JSON', () {
      // Arrange
      final jsonString = jsonEncode(tAuthTokenModel.toJson());

      // Act
      final decoded = jsonDecode(jsonString) as Map<String, dynamic>;
      final model = AuthTokenModel.fromJson(decoded);

      // Assert
      expect(model.accessToken, tAuthTokenModel.accessToken);
      expect(model.refreshToken, tAuthTokenModel.refreshToken);
      expect(model.tokenType, tAuthTokenModel.tokenType);
    });

    test('deve preservar expiresAt ao converter para entity e voltar', () {
      // Arrange
      final expiresAt = DateTime(2025, 6, 15, 14, 30, 45);
      final model = AuthTokenModel(
        accessToken: 'token',
        refreshToken: 'refresh',
        expiresAt: expiresAt,
      );

      // Act
      final entity = model.toEntity();
      final backToModel = AuthTokenModel.fromEntity(entity);

      // Assert
      expect(backToModel.expiresAt, expiresAt);
      expect(entity.expiresAt, expiresAt);
    });

    test('deve criar instâncias diferentes com dados diferentes', () {
      // Arrange
      final model1 = AuthTokenModel(
        accessToken: 'token1',
        refreshToken: 'refresh1',
        expiresAt: DateTime(2024, 1, 1),
      );
      final model2 = AuthTokenModel(
        accessToken: 'token2',
        refreshToken: 'refresh2',
        expiresAt: DateTime(2024, 1, 2),
      );

      // Assert
      expect(model1.accessToken, 'token1');
      expect(model2.accessToken, 'token2');
      expect(model1.refreshToken, 'refresh1');
      expect(model2.refreshToken, 'refresh2');
    });

    test('deve lidar com diferentes formatos de data no JSON', () {
      // Arrange
      final jsonWithIsoDate = {
        'access_token': 'token',
        'refresh_token': 'refresh',
        'expires_at': '2024-12-31T23:59:00.000Z',
      };

      // Act
      final result = AuthTokenModel.fromJson(jsonWithIsoDate);

      // Assert
      expect(result.accessToken, 'token');
      expect(result.expiresAt, isA<DateTime>());
    });

    test('deve converter corretamente entre model e entity múltiplas vezes',
        () {
      // Act
      final entity1 = tAuthTokenModel.toEntity();
      final model1 = AuthTokenModel.fromEntity(entity1);
      final entity2 = model1.toEntity();
      final model2 = AuthTokenModel.fromEntity(entity2);

      // Assert
      expect(model1.accessToken, tAuthTokenModel.accessToken);
      expect(model2.accessToken, tAuthTokenModel.accessToken);
      expect(entity1.accessToken, tAuthTokenModel.accessToken);
      expect(entity2.accessToken, tAuthTokenModel.accessToken);
    });
  });
}
