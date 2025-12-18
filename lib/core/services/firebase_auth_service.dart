import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

/// Service para autenticação com Firebase
/// Suporta Google Sign-In em todas as plataformas (Web, Android, iOS)
class FirebaseAuthService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email'],
  );

  /// Retorna o usuário atual autenticado
  User? get currentUser => _firebaseAuth.currentUser;

  /// Stream de mudanças no estado de autenticação
  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  /// Login com Google (funciona em Web, Android e iOS)
  Future<UserCredential?> signInWithGoogle() async {
    try {
      if (kIsWeb) {
        // Web: usa popup do Google
        final GoogleAuthProvider googleProvider = GoogleAuthProvider();
        googleProvider.setCustomParameters({'prompt': 'select_account'});

        return await _firebaseAuth.signInWithPopup(googleProvider);
      } else {
        // Mobile (Android/iOS): usa google_sign_in
        final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

        if (googleUser == null) {
          // Usuário cancelou o login
          return null;
        }

        final GoogleSignInAuthentication googleAuth =
            await googleUser.authentication;

        final credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );

        return await _firebaseAuth.signInWithCredential(credential);
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Login com email e senha
  Future<UserCredential> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      return await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      rethrow;
    }
  }

  /// Criar conta com email e senha
  Future<UserCredential> createUserWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      return await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      rethrow;
    }
  }

  /// Enviar email de recuperação de senha
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email);
    } catch (e) {
      rethrow;
    }
  }

  /// Logout
  Future<void> signOut() async {
    try {
      // Logout do Google se estiver logado
      if (!kIsWeb && await _googleSignIn.isSignedIn()) {
        await _googleSignIn.signOut();
      }

      // Logout do Firebase
      await _firebaseAuth.signOut();
    } catch (e) {
      rethrow;
    }
  }

  /// Atualizar perfil do usuário (nome e foto)
  Future<void> updateProfile({
    String? displayName,
    String? photoURL,
  }) async {
    try {
      await currentUser?.updateDisplayName(displayName);
      await currentUser?.updatePhotoURL(photoURL);
      await currentUser?.reload();
    } catch (e) {
      rethrow;
    }
  }

  /// Verificar se o usuário está autenticado
  bool get isAuthenticated => currentUser != null;

  /// Obter email do usuário atual
  String? get userEmail => currentUser?.email;

  /// Obter nome do usuário atual
  String? get userName => currentUser?.displayName;

  /// Obter foto do usuário atual
  String? get userPhotoUrl => currentUser?.photoURL;
}
