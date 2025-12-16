import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cadastro_beneficios/core/services/google_auth_service.dart';
import 'package:cadastro_beneficios/core/errors/exceptions.dart';

import 'google_auth_service_test.mocks.dart';

// Generate mocks
@GenerateMocks([GoogleSignIn, GoogleSignInAccount, GoogleSignInAuthentication])
void main() {
  group('GoogleAuthService', () {
    late GoogleAuthService googleAuthService;
    late MockGoogleSignIn mockGoogleSignIn;
    late MockGoogleSignInAccount mockAccount;
    late MockGoogleSignInAuthentication mockAuthentication;

    setUp(() {
      mockGoogleSignIn = MockGoogleSignIn();
      mockAccount = MockGoogleSignInAccount();
      mockAuthentication = MockGoogleSignInAuthentication();
      googleAuthService = GoogleAuthService(googleSignIn: mockGoogleSignIn);
    });

    group('signIn', () {
      const testIdToken = 'test_id_token_123456789';

      test('deve retornar ID token quando login é bem-sucedido', () async {
        // Arrange
        when(mockGoogleSignIn.signOut()).thenAnswer((_) async => null);
        when(mockGoogleSignIn.signIn()).thenAnswer((_) async => mockAccount);
        when(mockAccount.authentication)
            .thenAnswer((_) async => mockAuthentication);
        when(mockAuthentication.idToken).thenReturn(testIdToken);

        // Act
        final result = await googleAuthService.signIn();

        // Assert
        expect(result, testIdToken);
        verify(mockGoogleSignIn.signOut()).called(1);
        verify(mockGoogleSignIn.signIn()).called(1);
        verify(mockAccount.authentication).called(1);
      });

      test('deve lançar AuthException quando usuário cancela login', () async {
        // Arrange
        when(mockGoogleSignIn.signOut()).thenAnswer((_) async => null);
        when(mockGoogleSignIn.signIn()).thenAnswer((_) async => null);

        // Act & Assert
        expect(
          () => googleAuthService.signIn(),
          throwsA(isA<AuthException>().having(
            (e) => e.code,
            'code',
            'GOOGLE_SIGN_IN_CANCELLED',
          )),
        );
      });

      test('deve lançar AuthException quando ID token é null', () async {
        // Arrange
        when(mockGoogleSignIn.signOut()).thenAnswer((_) async => null);
        when(mockGoogleSignIn.signIn()).thenAnswer((_) async => mockAccount);
        when(mockAccount.authentication)
            .thenAnswer((_) async => mockAuthentication);
        when(mockAuthentication.idToken).thenReturn(null);

        // Act & Assert
        expect(
          () => googleAuthService.signIn(),
          throwsA(isA<AuthException>().having(
            (e) => e.code,
            'code',
            'GOOGLE_ID_TOKEN_NULL',
          )),
        );
      });

      test('deve lançar AuthException quando ocorre erro no Google Sign-In',
          () async {
        // Arrange
        when(mockGoogleSignIn.signOut()).thenAnswer((_) async => null);
        when(mockGoogleSignIn.signIn()).thenThrow(Exception('Network error'));

        // Act & Assert
        expect(
          () => googleAuthService.signIn(),
          throwsA(isA<AuthException>().having(
            (e) => e.code,
            'code',
            'GOOGLE_SIGN_IN_ERROR',
          )),
        );
      });
    });

    group('signOut', () {
      test('deve fazer logout com sucesso', () async {
        // Arrange
        when(mockGoogleSignIn.signOut()).thenAnswer((_) async => null);

        // Act
        await googleAuthService.signOut();

        // Assert
        verify(mockGoogleSignIn.signOut()).called(1);
      });

      test('deve ignorar erros de logout silenciosamente', () async {
        // Arrange
        when(mockGoogleSignIn.signOut()).thenThrow(Exception('Logout error'));

        // Act & Assert - não deve lançar exceção
        await expectLater(
          googleAuthService.signOut(),
          completes,
        );
      });
    });

    group('isSignedIn', () {
      test('deve retornar true quando usuário está logado', () async {
        // Arrange
        when(mockGoogleSignIn.isSignedIn()).thenAnswer((_) async => true);

        // Act
        final result = await googleAuthService.isSignedIn();

        // Assert
        expect(result, true);
        verify(mockGoogleSignIn.isSignedIn()).called(1);
      });

      test('deve retornar false quando usuário não está logado', () async {
        // Arrange
        when(mockGoogleSignIn.isSignedIn()).thenAnswer((_) async => false);

        // Act
        final result = await googleAuthService.isSignedIn();

        // Assert
        expect(result, false);
      });
    });

    group('getCurrentAccount', () {
      test('deve retornar conta atual quando usuário está logado', () async {
        // Arrange
        when(mockGoogleSignIn.currentUser).thenReturn(mockAccount);

        // Act
        final result = await googleAuthService.getCurrentAccount();

        // Assert
        expect(result, mockAccount);
      });

      test('deve retornar null quando usuário não está logado', () async {
        // Arrange
        when(mockGoogleSignIn.currentUser).thenReturn(null);

        // Act
        final result = await googleAuthService.getCurrentAccount();

        // Assert
        expect(result, null);
      });
    });

    group('disconnect', () {
      test('deve desconectar usuário com sucesso', () async {
        // Arrange
        when(mockGoogleSignIn.disconnect()).thenAnswer((_) async => null);

        // Act
        await googleAuthService.disconnect();

        // Assert
        verify(mockGoogleSignIn.disconnect()).called(1);
      });
    });
  });
}
