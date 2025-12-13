import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:cadastro_beneficios/data/models/user_model.dart';
import 'package:cadastro_beneficios/domain/entities/user.dart';

void main() {
  final tUserModel = UserModel(
    id: '123',
    name: 'João Silva',
    email: 'joao@exemplo.com',
    phoneNumber: '11987654321',
    cpf: '12345678900',
    role: 'beneficiary',
    isEmailVerified: true,
    isPhoneVerified: false,
    createdAt: DateTime(2024, 1, 1),
    updatedAt: DateTime(2024, 1, 2),
  );

  final tUserJson = {
    'id': '123',
    'name': 'João Silva',
    'email': 'joao@exemplo.com',
    'phone_number': '11987654321',
    'cpf': '12345678900',
    'role': 'beneficiary',
    'is_email_verified': true,
    'is_phone_verified': false,
    'created_at': '2024-01-01T00:00:00.000',
    'updated_at': '2024-01-02T00:00:00.000',
  };

  group('UserModel', () {
    test('deve ser uma subclasse de User entity', () {
      // Assert
      expect(tUserModel, isA<Object>());
    });

    test('fromJson deve criar UserModel a partir de JSON', () {
      // Act
      final result = UserModel.fromJson(tUserJson);

      // Assert
      expect(result.id, '123');
      expect(result.name, 'João Silva');
      expect(result.email, 'joao@exemplo.com');
      expect(result.phoneNumber, '11987654321');
      expect(result.cpf, '12345678900');
      expect(result.role, 'beneficiary');
      expect(result.isEmailVerified, true);
      expect(result.isPhoneVerified, false);
      expect(result.createdAt, DateTime(2024, 1, 1));
      expect(result.updatedAt, DateTime(2024, 1, 2));
    });

    test('toJson deve converter UserModel para JSON', () {
      // Act
      final result = tUserModel.toJson();

      // Assert
      expect(result['id'], '123');
      expect(result['name'], 'João Silva');
      expect(result['email'], 'joao@exemplo.com');
      expect(result['phone_number'], '11987654321');
      expect(result['cpf'], '12345678900');
      expect(result['role'], 'beneficiary');
      expect(result['is_email_verified'], true);
      expect(result['is_phone_verified'], false);
      expect(result['created_at'], '2024-01-01T00:00:00.000');
      expect(result['updated_at'], '2024-01-02T00:00:00.000');
    });

    test('fromJson deve lidar com valores null opcionais', () {
      // Arrange
      final jsonWithNulls = {
        'id': '123',
        'name': 'João Silva',
        'email': 'joao@exemplo.com',
        'phone_number': null,
        'cpf': null,
        'role': 'beneficiary',
        'is_email_verified': false,
        'is_phone_verified': false,
        'created_at': '2024-01-01T00:00:00.000',
        'updated_at': '2024-01-02T00:00:00.000',
      };

      // Act
      final result = UserModel.fromJson(jsonWithNulls);

      // Assert
      expect(result.phoneNumber, null);
      expect(result.cpf, null);
      expect(result.name, 'João Silva');
    });

    test('toEntity deve converter UserModel para User entity', () {
      // Act
      final result = tUserModel.toEntity();

      // Assert
      expect(result, isA<User>());
      expect(result.id, tUserModel.id);
      expect(result.name, tUserModel.name);
      expect(result.email, tUserModel.email);
      expect(result.phoneNumber, tUserModel.phoneNumber);
      expect(result.cpf, tUserModel.cpf);
      expect(result.role, UserRole.beneficiary);
      expect(result.isEmailVerified, tUserModel.isEmailVerified);
      expect(result.isPhoneVerified, tUserModel.isPhoneVerified);
      expect(result.createdAt, tUserModel.createdAt);
      expect(result.updatedAt, tUserModel.updatedAt);
    });

    test('fromEntity deve criar UserModel a partir de User entity', () {
      // Arrange
      final tUser = User(
        id: '123',
        name: 'João Silva',
        email: 'joao@exemplo.com',
        phoneNumber: '11987654321',
        cpf: '12345678900',
        role: UserRole.beneficiary,
        isEmailVerified: true,
        isPhoneVerified: false,
        createdAt: DateTime(2024, 1, 1),
        updatedAt: DateTime(2024, 1, 2),
      );

      // Act
      final result = UserModel.fromEntity(tUser);

      // Assert
      expect(result, isA<UserModel>());
      expect(result.id, tUser.id);
      expect(result.name, tUser.name);
      expect(result.email, tUser.email);
      expect(result.role, 'beneficiary');
    });

    test('toEntity deve converter role string para UserRole enum', () {
      // Arrange
      final adminModel = UserModel(
        id: '1',
        name: 'Admin',
        email: 'admin@exemplo.com',
        role: 'admin',
        createdAt: DateTime(2024, 1, 1),
      );
      final partnerModel = UserModel(
        id: '2',
        name: 'Partner',
        email: 'partner@exemplo.com',
        role: 'partner',
        createdAt: DateTime(2024, 1, 1),
      );
      final beneficiaryModel = UserModel(
        id: '3',
        name: 'Beneficiary',
        email: 'beneficiary@exemplo.com',
        role: 'beneficiary',
        createdAt: DateTime(2024, 1, 1),
      );

      // Act
      final adminEntity = adminModel.toEntity();
      final partnerEntity = partnerModel.toEntity();
      final beneficiaryEntity = beneficiaryModel.toEntity();

      // Assert
      expect(adminEntity.role, UserRole.admin);
      expect(partnerEntity.role, UserRole.partner);
      expect(beneficiaryEntity.role, UserRole.beneficiary);
    });

    test('deve serializar e desserializar corretamente via JSON', () {
      // Arrange
      final jsonString = jsonEncode(tUserModel.toJson());

      // Act
      final decoded = jsonDecode(jsonString) as Map<String, dynamic>;
      final model = UserModel.fromJson(decoded);

      // Assert
      expect(model.id, tUserModel.id);
      expect(model.name, tUserModel.name);
      expect(model.email, tUserModel.email);
      expect(model.role, tUserModel.role);
    });

    test('deve criar instâncias diferentes com dados diferentes', () {
      // Arrange
      final model1 = UserModel(
        id: '123',
        name: 'João Silva',
        email: 'joao@exemplo.com',
        role: 'beneficiary',
        createdAt: DateTime(2024, 1, 1),
      );
      final model2 = UserModel(
        id: '456',
        name: 'Maria Silva',
        email: 'maria@exemplo.com',
        role: 'admin',
        createdAt: DateTime(2024, 1, 2),
      );

      // Assert
      expect(model1.id, '123');
      expect(model2.id, '456');
      expect(model1.name, 'João Silva');
      expect(model2.name, 'Maria Silva');
      expect(model1.role, 'beneficiary');
      expect(model2.role, 'admin');
    });
  });
}
