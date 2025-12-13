import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:cadastro_beneficios/core/errors/failures.dart';
import 'package:cadastro_beneficios/domain/entities/auth_token.dart';
import 'package:cadastro_beneficios/domain/repositories/auth_repository.dart';
import 'package:cadastro_beneficios/domain/usecases/auth/register_usecase.dart';

import 'register_usecase_test.mocks.dart';

@GenerateMocks([AuthRepository])
void main() {
  late RegisterUseCase useCase;
  late MockAuthRepository mockRepository;

  setUp(() {
    mockRepository = MockAuthRepository();
    useCase = RegisterUseCase(mockRepository);
  });

  final tName = 'João Silva';
  final tEmail = 'joao@exemplo.com';
  final tPassword = 'senha123456';
  final tPhoneNumber = '11987654321';
  final tCpf = '12345678900';
  final tAuthToken = AuthToken(
    accessToken: 'access_token',
    refreshToken: 'refresh_token',
    expiresAt: DateTime.now().add(const Duration(hours: 1)),
  );

  group('RegisterUseCase', () {
    test('deve retornar AuthToken quando registro for bem-sucedido', () async {
      // Arrange
      when(mockRepository.register(
        name: anyNamed('name'),
        email: anyNamed('email'),
        password: anyNamed('password'),
        phoneNumber: anyNamed('phoneNumber'),
        cpf: anyNamed('cpf'),
      )).thenAnswer((_) async => Right(tAuthToken));

      // Act
      final result = await useCase(
        name: tName,
        email: tEmail,
        password: tPassword,
        phoneNumber: tPhoneNumber,
        cpf: tCpf,
      );

      // Assert
      expect(result, Right(tAuthToken));
      verify(mockRepository.register(
        name: tName,
        email: tEmail,
        password: tPassword,
        phoneNumber: tPhoneNumber,
        cpf: tCpf,
      ));
      verifyNoMoreInteractions(mockRepository);
    });

    test('deve retornar AuthToken quando registro sem CPF for bem-sucedido',
        () async {
      // Arrange
      when(mockRepository.register(
        name: anyNamed('name'),
        email: anyNamed('email'),
        password: anyNamed('password'),
        phoneNumber: anyNamed('phoneNumber'),
        cpf: anyNamed('cpf'),
      )).thenAnswer((_) async => Right(tAuthToken));

      // Act
      final result = await useCase(
        name: tName,
        email: tEmail,
        password: tPassword,
        phoneNumber: tPhoneNumber,
      );

      // Assert
      expect(result, Right(tAuthToken));
      verify(mockRepository.register(
        name: tName,
        email: tEmail,
        password: tPassword,
        phoneNumber: tPhoneNumber,
        cpf: null,
      ));
    });

    test('deve retornar ValidationFailure quando nome estiver vazio', () async {
      // Act
      final result = await useCase(
        name: '',
        email: tEmail,
        password: tPassword,
        phoneNumber: tPhoneNumber,
      );

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (failure) {
          expect(failure, isA<ValidationFailure>());
          expect(failure.message, 'Nome é obrigatório');
          expect(failure.code, 'NAME_REQUIRED');
        },
        (_) => fail('Deveria retornar Left'),
      );
      verifyZeroInteractions(mockRepository);
    });

    test('deve retornar ValidationFailure quando email estiver vazio',
        () async {
      // Act
      final result = await useCase(
        name: tName,
        email: '',
        password: tPassword,
        phoneNumber: tPhoneNumber,
      );

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (failure) {
          expect(failure, isA<ValidationFailure>());
          expect(failure.message, 'Email é obrigatório');
          expect(failure.code, 'EMAIL_REQUIRED');
        },
        (_) => fail('Deveria retornar Left'),
      );
      verifyZeroInteractions(mockRepository);
    });

    test('deve retornar ValidationFailure quando senha estiver vazia',
        () async {
      // Act
      final result = await useCase(
        name: tName,
        email: tEmail,
        password: '',
        phoneNumber: tPhoneNumber,
      );

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (failure) {
          expect(failure, isA<ValidationFailure>());
          expect(failure.message, 'Senha é obrigatória');
          expect(failure.code, 'PASSWORD_REQUIRED');
        },
        (_) => fail('Deveria retornar Left'),
      );
      verifyZeroInteractions(mockRepository);
    });

    test('deve retornar ValidationFailure quando telefone estiver vazio',
        () async {
      // Act
      final result = await useCase(
        name: tName,
        email: tEmail,
        password: tPassword,
        phoneNumber: '',
      );

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (failure) {
          expect(failure, isA<ValidationFailure>());
          expect(failure.message, 'Telefone é obrigatório');
          expect(failure.code, 'PHONE_REQUIRED');
        },
        (_) => fail('Deveria retornar Left'),
      );
      verifyZeroInteractions(mockRepository);
    });

    test('deve retornar ValidationFailure quando email for inválido', () async {
      // Act
      final result = await useCase(
        name: tName,
        email: 'email_invalido',
        password: tPassword,
        phoneNumber: tPhoneNumber,
      );

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (failure) {
          expect(failure, isA<ValidationFailure>());
          expect(failure.message, 'Email inválido');
          expect(failure.code, 'INVALID_EMAIL');
        },
        (_) => fail('Deveria retornar Left'),
      );
      verifyZeroInteractions(mockRepository);
    });

    test('deve retornar WeakPasswordFailure quando senha for muito curta',
        () async {
      // Act
      final result = await useCase(
        name: tName,
        email: tEmail,
        password: 'abc123',
        phoneNumber: tPhoneNumber,
      );

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (failure) {
          expect(failure, isA<WeakPasswordFailure>());
          expect(failure.code, 'PASSWORD_TOO_SHORT');
        },
        (_) => fail('Deveria retornar Left'),
      );
      verifyZeroInteractions(mockRepository);
    });

    test('deve retornar ValidationFailure quando nome for muito curto',
        () async {
      // Act
      final result = await useCase(
        name: 'Jo',
        email: tEmail,
        password: tPassword,
        phoneNumber: tPhoneNumber,
      );

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (failure) {
          expect(failure, isA<ValidationFailure>());
          expect(failure.message, 'Nome deve ter pelo menos 3 caracteres');
          expect(failure.code, 'NAME_TOO_SHORT');
        },
        (_) => fail('Deveria retornar Left'),
      );
      verifyZeroInteractions(mockRepository);
    });

    test('deve retornar Failure quando repository retornar erro', () async {
      // Arrange
      const tFailure = EmailAlreadyExistsFailure(
        message: 'Email já cadastrado',
      );
      when(mockRepository.register(
        name: anyNamed('name'),
        email: anyNamed('email'),
        password: anyNamed('password'),
        phoneNumber: anyNamed('phoneNumber'),
        cpf: anyNamed('cpf'),
      )).thenAnswer((_) async => const Left(tFailure));

      // Act
      final result = await useCase(
        name: tName,
        email: tEmail,
        password: tPassword,
        phoneNumber: tPhoneNumber,
      );

      // Assert
      expect(result, const Left(tFailure));
      verify(mockRepository.register(
        name: tName,
        email: tEmail,
        password: tPassword,
        phoneNumber: tPhoneNumber,
        cpf: null,
      ));
    });

    test('deve aceitar senha com exatamente 8 caracteres', () async {
      // Arrange
      when(mockRepository.register(
        name: anyNamed('name'),
        email: anyNamed('email'),
        password: anyNamed('password'),
        phoneNumber: anyNamed('phoneNumber'),
        cpf: anyNamed('cpf'),
      )).thenAnswer((_) async => Right(tAuthToken));

      // Act
      final result = await useCase(
        name: tName,
        email: tEmail,
        password: '12345678',
        phoneNumber: tPhoneNumber,
      );

      // Assert
      expect(result.isRight(), true);
    });

    test('deve aceitar nome com exatamente 3 caracteres', () async {
      // Arrange
      when(mockRepository.register(
        name: anyNamed('name'),
        email: anyNamed('email'),
        password: anyNamed('password'),
        phoneNumber: anyNamed('phoneNumber'),
        cpf: anyNamed('cpf'),
      )).thenAnswer((_) async => Right(tAuthToken));

      // Act
      final result = await useCase(
        name: 'Ana',
        email: tEmail,
        password: tPassword,
        phoneNumber: tPhoneNumber,
      );

      // Assert
      expect(result.isRight(), true);
    });
  });
}
