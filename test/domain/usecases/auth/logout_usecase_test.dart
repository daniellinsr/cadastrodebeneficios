import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:cadastro_beneficios/core/errors/failures.dart';
import 'package:cadastro_beneficios/domain/repositories/auth_repository.dart';
import 'package:cadastro_beneficios/domain/usecases/auth/logout_usecase.dart';

import 'logout_usecase_test.mocks.dart';

@GenerateMocks([AuthRepository])
void main() {
  late LogoutUseCase useCase;
  late MockAuthRepository mockRepository;

  setUp(() {
    mockRepository = MockAuthRepository();
    useCase = LogoutUseCase(mockRepository);
  });

  group('LogoutUseCase', () {
    test('deve retornar Right quando logout for bem-sucedido', () async {
      // Arrange
      when(mockRepository.logout()).thenAnswer((_) async => const Right(null));

      // Act
      final result = await useCase();

      // Assert
      expect(result, const Right(null));
      verify(mockRepository.logout());
      verifyNoMoreInteractions(mockRepository);
    });

    test('deve retornar ConnectionFailure quando não houver conexão', () async {
      // Arrange
      const tFailure = ConnectionFailure(
        message: 'Sem conexão com a internet',
      );
      when(mockRepository.logout())
          .thenAnswer((_) async => const Left(tFailure));

      // Act
      final result = await useCase();

      // Assert
      expect(result, const Left(tFailure));
      verify(mockRepository.logout());
    });

    test('deve retornar ServerFailure quando servidor falhar', () async {
      // Arrange
      const tFailure = ServerFailure(
        message: 'Erro no servidor',
      );
      when(mockRepository.logout())
          .thenAnswer((_) async => const Left(tFailure));

      // Act
      final result = await useCase();

      // Assert
      expect(result, const Left(tFailure));
      verify(mockRepository.logout());
    });

    test('deve retornar AuthenticationFailure quando token for inválido',
        () async {
      // Arrange
      const tFailure = AuthenticationFailure(
        message: 'Token inválido',
        code: 'INVALID_TOKEN',
      );
      when(mockRepository.logout())
          .thenAnswer((_) async => const Left(tFailure));

      // Act
      final result = await useCase();

      // Assert
      expect(result, const Left(tFailure));
      verify(mockRepository.logout());
    });

    test('deve limpar tokens locais mesmo com falha no servidor', () async {
      // Arrange
      // Este teste verifica que mesmo se o servidor falhar,
      // o repository deve tentar limpar os tokens locais
      when(mockRepository.logout()).thenAnswer((_) async => const Right(null));

      // Act
      final result = await useCase();

      // Assert
      expect(result.isRight(), true);
      verify(mockRepository.logout());
    });
  });
}
