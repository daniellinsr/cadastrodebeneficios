import 'package:flutter_test/flutter_test.dart';
import 'package:cadastro_beneficios/domain/entities/user.dart';

void main() {
  group('User Entity', () {
    test('deve criar um User válido', () {
      // Arrange & Act
      final user = User(
        id: '123',
        name: 'João Silva',
        email: 'joao@exemplo.com',
        phoneNumber: '61999999999',
        cpf: '12345678901',
        photoUrl: 'https://exemplo.com/photo.jpg',
        role: UserRole.beneficiary,
        createdAt: DateTime(2024, 1, 1),
        isEmailVerified: true,
        isPhoneVerified: true,
      );

      // Assert
      expect(user.id, '123');
      expect(user.name, 'João Silva');
      expect(user.email, 'joao@exemplo.com');
      expect(user.role, UserRole.beneficiary);
      expect(user.isEmailVerified, true);
    });

    test('deve criar um User com valores opcionais null', () {
      // Arrange & Act
      final user = User(
        id: '123',
        name: 'João Silva',
        email: 'joao@exemplo.com',
        role: UserRole.beneficiary,
        createdAt: DateTime(2024, 1, 1),
      );

      // Assert
      expect(user.phoneNumber, isNull);
      expect(user.cpf, isNull);
      expect(user.photoUrl, isNull);
      expect(user.updatedAt, isNull);
      expect(user.isEmailVerified, false);
      expect(user.isPhoneVerified, false);
    });

    test('copyWith deve criar nova instância com valores atualizados', () {
      // Arrange
      final user = User(
        id: '123',
        name: 'João Silva',
        email: 'joao@exemplo.com',
        role: UserRole.beneficiary,
        createdAt: DateTime(2024, 1, 1),
      );

      // Act
      final updatedUser = user.copyWith(
        name: 'João Santos',
        isEmailVerified: true,
      );

      // Assert
      expect(updatedUser.id, user.id);
      expect(updatedUser.name, 'João Santos');
      expect(updatedUser.email, user.email);
      expect(updatedUser.isEmailVerified, true);
    });

    test('dois Users com mesmos dados devem ser iguais (Equatable)', () {
      // Arrange
      final user1 = User(
        id: '123',
        name: 'João Silva',
        email: 'joao@exemplo.com',
        role: UserRole.beneficiary,
        createdAt: DateTime(2024, 1, 1),
      );

      final user2 = User(
        id: '123',
        name: 'João Silva',
        email: 'joao@exemplo.com',
        role: UserRole.beneficiary,
        createdAt: DateTime(2024, 1, 1),
      );

      // Assert
      expect(user1, equals(user2));
      expect(user1.hashCode, equals(user2.hashCode));
    });

    test('dois Users com dados diferentes não devem ser iguais', () {
      // Arrange
      final user1 = User(
        id: '123',
        name: 'João Silva',
        email: 'joao@exemplo.com',
        role: UserRole.beneficiary,
        createdAt: DateTime(2024, 1, 1),
      );

      final user2 = User(
        id: '456',
        name: 'Maria Silva',
        email: 'maria@exemplo.com',
        role: UserRole.admin,
        createdAt: DateTime(2024, 1, 1),
      );

      // Assert
      expect(user1, isNot(equals(user2)));
    });
  });

  group('UserRole Extension', () {
    test('displayName deve retornar nome correto', () {
      expect(UserRole.admin.displayName, 'Administrador');
      expect(UserRole.beneficiary.displayName, 'Beneficiário');
      expect(UserRole.partner.displayName, 'Parceiro');
    });

    test('value deve retornar string correta', () {
      expect(UserRole.admin.value, 'admin');
      expect(UserRole.beneficiary.value, 'beneficiary');
      expect(UserRole.partner.value, 'partner');
    });

    test('fromString deve converter string para UserRole', () {
      expect(UserRoleExtension.fromString('admin'), UserRole.admin);
      expect(UserRoleExtension.fromString('beneficiary'), UserRole.beneficiary);
      expect(UserRoleExtension.fromString('partner'), UserRole.partner);
    });

    test('fromString deve retornar beneficiary para string inválida', () {
      expect(UserRoleExtension.fromString('invalid'), UserRole.beneficiary);
      expect(UserRoleExtension.fromString(''), UserRole.beneficiary);
    });

    test('fromString deve ser case insensitive', () {
      expect(UserRoleExtension.fromString('ADMIN'), UserRole.admin);
      expect(UserRoleExtension.fromString('Beneficiary'), UserRole.beneficiary);
    });
  });
}
