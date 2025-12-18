import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cadastro_beneficios/core/errors/exceptions.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

/// Serviço para autenticação com Google
///
/// Gerencia o fluxo OAuth do Google Sign In
/// Na web, usa Firebase Auth para obter idToken de forma confiável
class GoogleAuthService {
  final GoogleSignIn _googleSignIn;
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  GoogleAuthService({
    GoogleSignIn? googleSignIn,
  }) : _googleSignIn = googleSignIn ??
            GoogleSignIn(
              scopes: [
                'email',
                'profile',
                'openid',
              ],
              // Na web, o Client ID vem do meta tag no index.html
              // IMPORTANTE: 'openid' é necessário para obter o idToken
            );

  /// Fazer login com Google
  ///
  /// Retorna o ID Token para enviar ao backend
  Future<String> signIn() async {
    try {
      // Na web, usar Firebase Auth que funciona melhor
      if (kIsWeb) {
        return await _signInWithFirebase();
      }

      // Em mobile, usar google_sign_in que funciona corretamente
      return await _signInWithGoogleSignIn();
    } on AuthException {
      rethrow;
    } catch (e) {
      throw AuthException(
        message: 'Erro ao fazer login com Google: ${e.toString()}',
        code: 'GOOGLE_SIGN_IN_ERROR',
      );
    }
  }

  /// Login usando Firebase Auth (Web)
  Future<String> _signInWithFirebase() async {
    final GoogleAuthProvider googleProvider = GoogleAuthProvider();

    // Garantir que openid scope está incluído
    googleProvider.addScope('email');
    googleProvider.addScope('profile');
    googleProvider.setCustomParameters({
      'prompt': 'select_account',
    });

    // Fazer login via popup
    final UserCredential userCredential =
        await _firebaseAuth.signInWithPopup(googleProvider);

    if (userCredential.user == null) {
      throw const AuthException(
        message: 'Login cancelado pelo usuário',
        code: 'GOOGLE_SIGN_IN_CANCELLED',
      );
    }

    // Obter ID Token do Firebase
    final String? idToken = await userCredential.user!.getIdToken();

    if (idToken == null) {
      throw const AuthException(
        message: 'Falha ao obter token do Google',
        code: 'GOOGLE_ID_TOKEN_NULL',
      );
    }

    return idToken;
  }

  /// Login usando google_sign_in (Mobile)
  Future<String> _signInWithGoogleSignIn() async {
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
