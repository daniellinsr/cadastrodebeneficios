import 'package:google_sign_in/google_sign_in.dart';
import 'package:cadastro_beneficios/core/errors/exceptions.dart';

/// Serviço para autenticação com Google
///
/// Gerencia o fluxo OAuth do Google Sign In
class GoogleAuthService {
  final GoogleSignIn _googleSignIn;

  GoogleAuthService({
    GoogleSignIn? googleSignIn,
  }) : _googleSignIn = googleSignIn ??
            GoogleSignIn(
              scopes: [
                'email',
                'profile',
              ],
            );

  /// Fazer login com Google
  ///
  /// Retorna o ID Token para enviar ao backend
  Future<String> signIn() async {
    try {
      // Fazer logout silencioso primeiro para garantir seleção de conta
      await _googleSignIn.signOut();

      // Iniciar fluxo de login
      final GoogleSignInAccount? account = await _googleSignIn.signIn();

      if (account == null) {
        // Usuário cancelou o login
        throw const AuthException(
          message: 'Login cancelado pelo usuário',
          code: 'GOOGLE_SIGN_IN_CANCELLED',
        );
      }

      // Obter autenticação
      final GoogleSignInAuthentication authentication =
          await account.authentication;

      // Verificar se temos ID token
      final String? idToken = authentication.idToken;

      if (idToken == null) {
        throw const AuthException(
          message: 'Falha ao obter token do Google',
          code: 'GOOGLE_ID_TOKEN_NULL',
        );
      }

      return idToken;
    } on AuthException {
      rethrow;
    } catch (e) {
      throw AuthException(
        message: 'Erro ao fazer login com Google: ${e.toString()}',
        code: 'GOOGLE_SIGN_IN_ERROR',
      );
    }
  }

  /// Fazer logout do Google
  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
    } catch (e) {
      // Ignorar erros de logout - não é crítico
    }
  }

  /// Verificar se usuário está autenticado
  Future<bool> isSignedIn() async {
    try {
      return await _googleSignIn.isSignedIn();
    } catch (e) {
      return false;
    }
  }

  /// Obter conta atual do Google (se existir)
  Future<GoogleSignInAccount?> getCurrentAccount() async {
    try {
      return _googleSignIn.currentUser ?? await _googleSignIn.signInSilently();
    } catch (e) {
      return null;
    }
  }

  /// Desconectar conta do Google (revoga acesso)
  Future<void> disconnect() async {
    try {
      await _googleSignIn.disconnect();
    } catch (e) {
      // Ignorar erros - conta pode já estar desconectada
    }
  }
}
