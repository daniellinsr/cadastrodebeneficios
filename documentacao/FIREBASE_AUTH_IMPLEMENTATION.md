# Firebase Authentication - Solução Completa para Web + Mobile

## ✅ Por que Firebase Auth?

### Vantagens
- ✅ Funciona perfeitamente em **Web, Android e iOS**
- ✅ Gerencia tokens automaticamente
- ✅ Suporte nativo para Google, Facebook, Apple, Twitter, GitHub, etc.
- ✅ Backend gratuito do Google (até 50k usuários/mês)
- ✅ Sem complexidade de OAuth manual
- ✅ Integração simples com Flutter
- ✅ Documentação excelente

### Desvantagens
- ⚠️ Adiciona dependência do Firebase
- ⚠️ Migração do código atual necessária

---

## 📦 Passo 1: Adicionar Dependências

### pubspec.yaml

```yaml
dependencies:
  # Firebase Core (obrigatório)
  firebase_core: ^3.6.0

  # Firebase Authentication
  firebase_auth: ^5.3.1

  # Google Sign-In (ainda necessário)
  google_sign_in: ^6.2.1

  # Opcional: Cloud Firestore para salvar dados
  cloud_firestore: ^5.4.4
```

```bash
flutter pub get
```

---

## 🔧 Passo 2: Configurar Firebase Console

### 2.1 Criar Projeto Firebase

1. Acesse: https://console.firebase.google.com/
2. Clique em **"Adicionar projeto"**
3. Nome: `Sistema de Cartão de Benefícios`
4. Habilite Google Analytics (opcional)
5. Clique em **"Criar projeto"**

### 2.2 Configurar Web App

1. No console do Firebase, clique no ícone **Web** (</>)
2. Apelido: `cadastro-beneficios-web`
3. Marque: **"Configure Firebase Hosting"** (opcional)
4. Copie a configuração (você vai precisar depois)

```javascript
// Exemplo da configuração Firebase Web
const firebaseConfig = {
  apiKey: "AIzaSy...",
  authDomain: "seu-projeto.firebaseapp.com",
  projectId: "seu-projeto",
  storageBucket: "seu-projeto.appspot.com",
  messagingSenderId: "123456789",
  appId: "1:123456789:web:abcdef"
};
```

### 2.3 Configurar Android App

1. Clique em **Adicionar app** → **Android**
2. Package name: `com.example.cadastro_beneficios`
3. Download `google-services.json`
4. Coloque em: `android/app/google-services.json`

### 2.4 Configurar iOS App

1. Clique em **Adicionar app** → **iOS**
2. Bundle ID: `com.example.cadastroBeneficios`
3. Download `GoogleService-Info.plist`
4. Coloque em: `ios/Runner/GoogleService-Info.plist`

### 2.5 Habilitar Google Sign-In no Firebase

1. No Firebase Console, vá em **Authentication** → **Sign-in method**
2. Clique em **Google**
3. Clique em **Habilitar**
4. Configure o email de suporte do projeto
5. Salve

---

## 📝 Passo 3: Configurar Firebase no Flutter

### 3.1 Criar arquivo de configuração: `lib/firebase_options.dart`

```dart
// firebase_options.dart
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSy...',  // ← Cole sua API Key aqui
    appId: '1:123456789:web:abcdef',  // ← Cole seu App ID aqui
    messagingSenderId: '123456789',  // ← Cole aqui
    projectId: 'seu-projeto',  // ← Cole aqui
    authDomain: 'seu-projeto.firebaseapp.com',  // ← Cole aqui
    storageBucket: 'seu-projeto.appspot.com',  // ← Cole aqui
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSy...',  // ← Android API Key
    appId: '1:123456789:android:abcdef',  // ← Android App ID
    messagingSenderId: '123456789',
    projectId: 'seu-projeto',
    storageBucket: 'seu-projeto.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSy...',  // ← iOS API Key
    appId: '1:123456789:ios:abcdef',  // ← iOS App ID
    messagingSenderId: '123456789',
    projectId: 'seu-projeto',
    storageBucket: 'seu-projeto.appspot.com',
    iosBundleId: 'com.example.cadastroBeneficios',
  );
}
```

**Dica:** Use o FlutterFire CLI para gerar automaticamente:
```bash
dart pub global activate flutterfire_cli
flutterfire configure
```

### 3.2 Inicializar Firebase: `lib/main.dart`

```dart
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializar Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}
```

---

## 🔐 Passo 4: Criar FirebaseAuthService

### `lib/core/services/firebase_auth_service.dart`

```dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cadastro_beneficios/core/errors/exceptions.dart';

class FirebaseAuthService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email', 'profile'],
  );

  /// Login com Google usando Firebase Auth
  /// Funciona em Web, Android e iOS
  Future<UserCredential> signInWithGoogle() async {
    try {
      // 1. Trigger do fluxo de autenticação
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        throw const AuthException(
          message: 'Login cancelado pelo usuário',
          code: 'GOOGLE_SIGN_IN_CANCELLED',
        );
      }

      // 2. Obter detalhes de autenticação
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // 3. Criar credencial do Firebase
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // 4. Fazer login no Firebase
      final UserCredential userCredential =
          await _firebaseAuth.signInWithCredential(credential);

      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw AuthException(
        message: _handleFirebaseAuthError(e.code),
        code: e.code,
      );
    } catch (e) {
      throw AuthException(
        message: 'Erro ao fazer login com Google: ${e.toString()}',
        code: 'GOOGLE_SIGN_IN_ERROR',
      );
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
    } on FirebaseAuthException catch (e) {
      throw AuthException(
        message: _handleFirebaseAuthError(e.code),
        code: e.code,
      );
    }
  }

  /// Registrar com email e senha
  Future<UserCredential> createUserWithEmailAndPassword({
    required String email,
    required String password,
    required String displayName,
  }) async {
    try {
      final userCredential =
          await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Atualizar nome do usuário
      await userCredential.user?.updateDisplayName(displayName);

      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw AuthException(
        message: _handleFirebaseAuthError(e.code),
        code: e.code,
      );
    }
  }

  /// Logout
  Future<void> signOut() async {
    try {
      await Future.wait([
        _firebaseAuth.signOut(),
        _googleSignIn.signOut(),
      ]);
    } catch (e) {
      throw const AuthException(
        message: 'Erro ao fazer logout',
        code: 'SIGN_OUT_ERROR',
      );
    }
  }

  /// Obter usuário atual
  User? get currentUser => _firebaseAuth.currentUser;

  /// Stream de mudanças de autenticação
  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  /// Resetar senha
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw AuthException(
        message: _handleFirebaseAuthError(e.code),
        code: e.code,
      );
    }
  }

  /// Tratamento de erros do Firebase
  String _handleFirebaseAuthError(String code) {
    switch (code) {
      case 'user-not-found':
        return 'Usuário não encontrado';
      case 'wrong-password':
        return 'Senha incorreta';
      case 'email-already-in-use':
        return 'Email já está em uso';
      case 'invalid-email':
        return 'Email inválido';
      case 'weak-password':
        return 'Senha muito fraca';
      case 'user-disabled':
        return 'Usuário desabilitado';
      case 'operation-not-allowed':
        return 'Operação não permitida';
      case 'account-exists-with-different-credential':
        return 'Já existe uma conta com este email';
      default:
        return 'Erro de autenticação: $code';
    }
  }
}
```

---

## 🎨 Passo 5: Atualizar RegistrationIntroPage

### Modificar `lib/presentation/pages/registration/registration_intro_page.dart`

```dart
import 'package:cadastro_beneficios/core/services/firebase_auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

class _RegistrationIntroPageState extends State<RegistrationIntroPage> {
  final RegistrationDraftService _draftService = RegistrationDraftService();
  final FirebaseAuthService _authService = FirebaseAuthService(); // ← Novo

  // Atualizar método de Google Sign-In
  Future<void> _handleGoogleSignup() async {
    if (!mounted) return;

    // Mostra loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
        ),
      ),
    );

    try {
      // Autentica com Google usando Firebase
      final UserCredential userCredential =
          await _authService.signInWithGoogle();

      final User? user = userCredential.user;

      if (!mounted) return;
      Navigator.of(context).pop();

      if (user != null) {
        // Sucesso - usuário autenticado
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Login realizado com sucesso!\n'
              'Bem-vindo, ${user.displayName ?? user.email}!',
              style: const TextStyle(color: Colors.white),
            ),
            backgroundColor: AppColors.success,
            duration: const Duration(seconds: 3),
          ),
        );

        // TODO: Navegar para home ou sincronizar com backend
        // context.go('/home');
      }
    } on AuthException catch (e) {
      if (!mounted) return;
      Navigator.of(context).pop();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            e.message,
            style: const TextStyle(color: Colors.white),
          ),
          backgroundColor: AppColors.error,
          duration: const Duration(seconds: 3),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      Navigator.of(context).pop();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Erro inesperado: ${e.toString()}',
            style: const TextStyle(color: Colors.white),
          ),
          backgroundColor: AppColors.error,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        // ... código existente
        child: Column(
          children: [
            // ... código existente

            // Botão Google - AGORA FUNCIONA EM WEB E MOBILE!
            SizedBox(
              width: double.infinity,
              height: 56,
              child: OutlinedButton(
                onPressed: _handleGoogleSignup,
                style: OutlinedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: AppColors.darkGray,
                  side: BorderSide.none,
                  elevation: 2,
                  shadowColor: Colors.black.withValues(alpha: 0.1),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      'assets/icons/google_logo.png',
                      height: 24,
                      width: 24,
                      errorBuilder: (context, error, stackTrace) {
                        return const Icon(
                          Icons.login,
                          size: 24,
                          color: AppColors.primaryBlue,
                        );
                      },
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Cadastrar com Google',
                      style: AppTextStyles.button.copyWith(
                        color: AppColors.darkGray,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
```

---

## 🔒 Passo 6: Gerenciar Estado de Autenticação

### Criar `lib/presentation/bloc/firebase_auth_bloc.dart` (opcional)

Ou usar um listener simples:

```dart
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          // Se usuário está logado
          if (snapshot.hasData && snapshot.data != null) {
            return const HomePage();  // ou seu dashboard
          }

          // Se não está logado
          return const LoginPage();
        },
      ),
    );
  }
}
```

---

## 🌐 Passo 7: Configuração Web Adicional

### 7.1 Atualizar `web/index.html`

```html
<!DOCTYPE html>
<html>
<head>
  <base href="$FLUTTER_BASE_HREF">
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">

  <title>Cadastro de Benefícios</title>
  <link rel="manifest" href="manifest.json">
</head>
<body>
  <!-- Firebase SDK -->
  <script src="https://www.gstatic.com/firebasejs/10.7.0/firebase-app-compat.js"></script>
  <script src="https://www.gstatic.com/firebasejs/10.7.0/firebase-auth-compat.js"></script>

  <script>
    // Configuração do Firebase (copie do Firebase Console)
    const firebaseConfig = {
      apiKey: "AIzaSy...",
      authDomain: "seu-projeto.firebaseapp.com",
      projectId: "seu-projeto",
      storageBucket: "seu-projeto.appspot.com",
      messagingSenderId: "123456789",
      appId: "1:123456789:web:abcdef"
    };

    // Inicializar Firebase
    firebase.initializeApp(firebaseConfig);
  </script>

  <script src="flutter_bootstrap.js" async></script>
</body>
</html>
```

---

## ✅ Passo 8: Testar

### Web
```bash
flutter run -d chrome
```

### Android
```bash
flutter run -d <device_id>
```

### iOS
```bash
flutter run -d <device_id>
```

---

## 📊 Comparação: Antes vs Depois

### Antes (google_sign_in apenas)
```
Web: ❌ Não funciona
Android: ✅ Funciona
iOS: ✅ Funciona
```

### Depois (Firebase Auth)
```
Web: ✅ Funciona perfeitamente!
Android: ✅ Funciona perfeitamente!
iOS: ✅ Funciona perfeitamente!
```

---

## 🎯 Benefícios Adicionais do Firebase

### 1. Múltiplos Provedores
```dart
// Google
await _authService.signInWithGoogle();

// Facebook
await FirebaseAuth.instance.signInWithProvider(FacebookAuthProvider());

// Apple
await FirebaseAuth.instance.signInWithProvider(AppleAuthProvider());

// Email/Senha
await _authService.signInWithEmailAndPassword(email, password);
```

### 2. Backend Gratuito
- Firestore para salvar dados dos usuários
- Cloud Storage para fotos
- Cloud Functions para lógica de backend
- Analytics integrado

### 3. Gerenciamento de Usuários
```dart
// Atualizar perfil
await user.updateDisplayName('Novo Nome');
await user.updatePhotoURL('https://...');

// Enviar email de verificação
await user.sendEmailVerification();

// Deletar conta
await user.delete();
```

---

## 💰 Custos

### Plano Gratuito (Spark)
- ✅ 50.000 verificações/mês
- ✅ 1 GB de dados Firestore
- ✅ 5 GB de armazenamento
- ✅ 10 GB de transferência/mês

**Para maioria dos apps, o plano gratuito é suficiente!**

---

## 📚 Referências

- [Firebase Auth Documentation](https://firebase.google.com/docs/auth)
- [FlutterFire](https://firebase.flutter.dev/)
- [Firebase Console](https://console.firebase.google.com/)

---

**Data:** 2025-12-16
**Autor:** Claude Sonnet 4.5
**Status:** Guia Completo de Implementação