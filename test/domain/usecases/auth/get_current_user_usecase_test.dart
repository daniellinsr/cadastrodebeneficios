import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:cadastro_beneficios/core/errors/failures.dart';
import 'package:cadastro_beneficios/domain/entities/user.dart';
import 'package:cadastro_beneficios/domain/repositories/auth_repository.dart';
import 'package:cadastro_beneficios/domain/usecases/auth/get_current_user_usecase.dart';

import 'get_current_user_usecase_test.mocks.dart';

@GenerateMocks([AuthRepository])
void main() {
  late GetCurrentUserUseCase useCase;
  late MockAuthRepository mockRepository;

  setUp(() {
    mockRepository = MockAuthRepository();
    useCase = GetCurrentUserUseCase(mockRepository);
  });

  final tUser = User(
    id: '123',
    name: 'João Silva',
    email: 'joao@exemplo.com',
    role: UserRole.beneficiary,
    createdAt: DateTime(2024, 1, 1),
  );

  group('GetCurrentUserUseCase', () {
    test('deve retornar User quando busca for bem-sucedida', () async {
      // Arrange
      when(mockRepository.getCurrentUser())
          .thenAnswer((_) async => Right(tUser));

      // Act
      final result = await useCase();

      // Assert
      expect(result, Right(tUser));
      verify(mockRepository.getCurrentUser());
      verifyNoMoreInteractions(mockRepository);
    });

    test('deve retornar AuthenticationFailure quando não houver token',
        () async {
      // Arrange
      const tFailure = AuthenticationFailure(
        message: 'Token não encontrado',
        code: 'TOKEN_NOT_FOUND',
      );
      when(mockRepository.getCurrentUser())
          .thenAnswer((_) async => const Left(tFailure));

      // Act
      final result = await useCase();

      // Assert
      expect(result, const Left(tFailure));
      verify(mockRepository.getCurrentUser());
    });

    test('deve retornar TokenExpiredFailure quando token expirar', () async {
      // Arrange
      const tFailure = TokenExpiredFailure(
        message: 'Token expirado',
      );
      when(mockRepository.getCurrentUser())
          .thenAnswer((_) async => const Left(tFailure));

      // Act
      final result = await useCase();

      // Assert
      expect(result, const Left(tFailure));
      verify(mockRepository.getCurrentUser());
    });

    test('deve retornar ConnectionFailure quando não houver conexão', () async {
      // Arrange
      const tFailure = ConnectionFailure(
        message: 'Sem conexão com a internet',
      );
      when(mockRepository.getCurrentUser())
          .thenAnswer((_) async => const Left(tFailure));

      // Act
      final result = await useCase();

      // Assert
      expect(result, const Left(tFailure));
      verify(mockRepository.getCurrentUser());
    });

    test('deve retornar ServerFailure quando servidor falhar', () async {
      // Arrange
      const tFailure = ServerFailure(
        message: 'Erro no servidor',
      );
      when(mockRepository.getCurrentUser())
          .thenAnswer((_) async => const Left(tFailure));

      // Act
      final result = await useCase();

      // Assert
      expect(result, const Left(tFailure));
      verify(mockRepository.getCurrentUser());
    });
  });
}
