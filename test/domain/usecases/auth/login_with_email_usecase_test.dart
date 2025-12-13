import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:cadastro_beneficios/core/errors/failures.dart';
import 'package:cadastro_beneficios/domain/entities/auth_token.dart';
import 'package:cadastro_beneficios/domain/repositories/auth_repository.dart';
import 'package:cadastro_beneficios/domain/usecases/auth/login_with_email_usecase.dart';

import 'login_with_email_usecase_test.mocks.dart';

@GenerateMocks([AuthRepository])
void main() {
  late LoginWithEmailUseCase useCase;
  late MockAuthRepository mockRepository;

  setUp(() {
    mockRepository = MockAuthRepository();
    useCase = LoginWithEmailUseCase(mockRepository);
  });

  final tEmail = 'teste@exemplo.com';
  final tPassword = 'senha123';
  final tAuthToken = AuthToken(
    accessToken: 'access_token',
    refreshToken: 'refresh_token',
    expiresAt: DateTime.now().add(const Duration(hours: 1)),
  );

  group('LoginWithEmailUseCase', () {
    test('deve retornar AuthToken quando login for bem-sucedido', () async {
      // Arrange
      when(mockRepository.loginWithEmail(
        email: anyNamed('email'),
        password: anyNamed('password'),
      )).thenAnswer((_) async => Right(tAuthToken));

      // Act
      final result = await useCase(email: tEmail, password: tPassword);

      // Assert
      expect(result, Right(tAuthToken));
      verify(mockRepository.loginWithEmail(
        email: tEmail,
        password: tPassword,
      ));
      verifyNoMoreInteractions(mockRepository);
    });

    test('deve retornar ValidationFailure quando email estiver vazio',
        () async {
      // Act
      final result = await useCase(email: '', password: tPassword);

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
      final result = await useCase(email: tEmail, password: '');

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

    test('deve retornar ValidationFailure quando email for inválido',
        () async {
      // Act
      final result = await useCase(email: 'email_invalido', password: tPassword);

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

    test('deve retornar Failure quando repository retornar erro', () async {
      // Arrange
      const tFailure = AuthenticationFailure(
        message: 'Credenciais inválidas',
      );
      when(mockRepository.loginWithEmail(
        email: anyNamed('email'),
        password: anyNamed('password'),
      )).thenAnswer((_) async => const Left(tFailure));

      // Act
      final result = await useCase(email: tEmail, password: tPassword);

      // Assert
      expect(result, const Left(tFailure));
      verify(mockRepository.loginWithEmail(
        email: tEmail,
        password: tPassword,
      ));
    });

    test('deve aceitar emails válidos com diferentes formatos', () async {
      // Arrange
      final validEmails = [
        'teste@exemplo.com',
        'usuario.teste@exemplo.com.br',
        'usuario+tag@exemplo.co.uk',
        'teste123@sub.exemplo.com',
      ];

      when(mockRepository.loginWithEmail(
        email: anyNamed('email'),
        password: anyNamed('password'),
      )).thenAnswer((_) async => Right(tAuthToken));

      // Act & Assert
      for (final email in validEmails) {
        final result = await useCase(email: email, password: tPassword);
        expect(result.isRight(), true, reason: 'Email $email should be valid');
      }
    });
  });
}
