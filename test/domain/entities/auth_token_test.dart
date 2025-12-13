import 'package:flutter_test/flutter_test.dart';
import 'package:cadastro_beneficios/domain/entities/auth_token.dart';

void main() {
  group('AuthToken Entity', () {
    test('deve criar um AuthToken válido', () {
      // Arrange & Act
      final token = AuthToken(
        accessToken: 'access_token_123',
        refreshToken: 'refresh_token_456',
        expiresAt: DateTime(2024, 12, 31, 23, 59),
        tokenType: 'Bearer',
      );

      // Assert
      expect(token.accessToken, 'access_token_123');
      expect(token.refreshToken, 'refresh_token_456');
      expect(token.expiresAt, DateTime(2024, 12, 31, 23, 59));
      expect(token.tokenType, 'Bearer');
    });

    test('tokenType deve ter valor padrão Bearer', () {
      // Arrange & Act
      final token = AuthToken(
        accessToken: 'access_token_123',
        refreshToken: 'refresh_token_456',
        expiresAt: DateTime(2024, 12, 31),
      );

      // Assert
      expect(token.tokenType, 'Bearer');
    });

    test('isExpired deve retornar true para token expirado', () {
      // Arrange
      final token = AuthToken(
        accessToken: 'access_token_123',
        refreshToken: 'refresh_token_456',
        expiresAt: DateTime.now().subtract(const Duration(days: 1)),
      );

      // Act & Assert
      expect(token.isExpired, true);
    });

    test('isExpired deve retornar false para token válido', () {
      // Arrange
      final token = AuthToken(
        accessToken: 'access_token_123',
        refreshToken: 'refresh_token_456',
        expiresAt: DateTime.now().add(const Duration(days: 1)),
      );

      // Act & Assert
      expect(token.isExpired, false);
    });

    test('isNearExpiry deve retornar true para token próximo de expirar', () {
      // Arrange
      final token = AuthToken(
        accessToken: 'access_token_123',
        refreshToken: 'refresh_token_456',
        expiresAt: DateTime.now().add(const Duration(minutes: 3)),
      );

      // Act & Assert
      expect(token.isNearExpiry, true);
    });

    test('isNearExpiry deve retornar false para token com tempo suficiente',
        () {
      // Arrange
      final token = AuthToken(
        accessToken: 'access_token_123',
        refreshToken: 'refresh_token_456',
        expiresAt: DateTime.now().add(const Duration(hours: 1)),
      );

      // Act & Assert
      expect(token.isNearExpiry, false);
    });

    test('timeUntilExpiry deve retornar duração correta', () {
      // Arrange
      final expiresAt = DateTime.now().add(const Duration(hours: 2));
      final token = AuthToken(
        accessToken: 'access_token_123',
        refreshToken: 'refresh_token_456',
        expiresAt: expiresAt,
      );

      // Act
      final timeUntilExpiry = token.timeUntilExpiry;

      // Assert
      expect(timeUntilExpiry.inHours, 2); // Aproximadamente 2 horas
      expect(timeUntilExpiry.isNegative, false);
    });

    test('timeUntilExpiry deve retornar duração negativa para token expirado',
        () {
      // Arrange
      final token = AuthToken(
        accessToken: 'access_token_123',
        refreshToken: 'refresh_token_456',
        expiresAt: DateTime.now().subtract(const Duration(hours: 1)),
      );

      // Act
      final timeUntilExpiry = token.timeUntilExpiry;

      // Assert
      expect(timeUntilExpiry.isNegative, true);
    });

    test('copyWith deve criar nova instância com valores atualizados', () {
      // Arrange
      final token = AuthToken(
        accessToken: 'access_token_123',
        refreshToken: 'refresh_token_456',
        expiresAt: DateTime(2024, 12, 31),
      );

      // Act
      final newToken = token.copyWith(
        accessToken: 'new_access_token',
        expiresAt: DateTime(2025, 12, 31),
      );

      // Assert
      expect(newToken.accessToken, 'new_access_token');
      expect(newToken.refreshToken, token.refreshToken);
      expect(newToken.expiresAt, DateTime(2025, 12, 31));
    });

    test('dois AuthTokens com mesmos dados devem ser iguais (Equatable)', () {
      // Arrange
      final expiresAt = DateTime(2024, 12, 31);
      final token1 = AuthToken(
        accessToken: 'access_token_123',
        refreshToken: 'refresh_token_456',
        expiresAt: expiresAt,
      );

      final token2 = AuthToken(
        accessToken: 'access_token_123',
        refreshToken: 'refresh_token_456',
        expiresAt: expiresAt,
      );

      // Assert
      expect(token1, equals(token2));
      expect(token1.hashCode, equals(token2.hashCode));
    });

    test('dois AuthTokens com dados diferentes não devem ser iguais', () {
      // Arrange
      final token1 = AuthToken(
        accessToken: 'access_token_123',
        refreshToken: 'refresh_token_456',
        expiresAt: DateTime(2024, 12, 31),
      );

      final token2 = AuthToken(
        accessToken: 'access_token_789',
        refreshToken: 'refresh_token_012',
        expiresAt: DateTime(2025, 12, 31),
      );

      // Assert
      expect(token1, isNot(equals(token2)));
    });
  });
}
