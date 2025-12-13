# 🔐 Configuração do Google OAuth - Sistema de Cartão de Benefícios

Este documento descreve como configurar o Google OAuth para autenticação no aplicativo Flutter.

## 📋 Índice

1. [Visão Geral](#visão-geral)
2. [Pré-requisitos](#pré-requisitos)
3. [Configuração do Google Cloud Console](#configuração-do-google-cloud-console)
4. [Configuração Android](#configuração-android)
5. [Configuração iOS](#configuração-ios)
6. [Configuração Web (Opcional)](#configuração-web-opcional)
7. [Testando a Integração](#testando-a-integração)
8. [Fluxo de Autenticação](#fluxo-de-autenticação)
9. [Troubleshooting](#troubleshooting)

---

## 🎯 Visão Geral

O sistema usa Google Sign-In para permitir que usuários façam login usando suas contas Google. O fluxo completo envolve:

1. **Frontend (Flutter)**: Usa `google_sign_in` para obter ID Token
2. **Backend**: Valida o ID Token com Google e retorna AuthToken do sistema

### Arquitetura Implementada

```
┌─────────────┐      ┌──────────────────┐      ┌─────────────┐
│   Flutter   │─────>│ GoogleAuthService│─────>│   Google    │
│     App     │      │  (ID Token)      │      │   OAuth     │
└─────────────┘      └──────────────────┘      └─────────────┘
       │                                               │
       │ ID Token                                      │
       ↓                                               │
┌─────────────┐      ┌──────────────────┐            │
│   Backend   │<─────│  ID Token        │<───────────┘
│     API     │      │  Validation      │
└─────────────┘      └──────────────────┘
       │
       │ AuthToken (JWT)
       ↓
┌─────────────┐
│   Flutter   │
│     App     │
└─────────────┘
```

---

## 📦 Pré-requisitos

- Conta Google Cloud Platform
- Projeto criado no Google Cloud Console
- Flutter SDK instalado
- Android Studio (para Android)
- Xcode (para iOS, apenas no macOS)

---

## ⚙️ Configuração do Google Cloud Console

### 1. Criar Projeto no Google Cloud

1. Acesse [Google Cloud Console](https://console.cloud.google.com/)
2. Crie um novo projeto ou selecione um existente
3. Anote o **Project ID**
-> 403775802042

### 2. Ativar Google Sign-In API

1. No menu lateral, vá para **APIs & Services** > **Library**
2. Procure por "Google Sign-In API" ou "Google+ API"
3. Clique em **Enable**

### 3. Configurar OAuth Consent Screen

1. Vá para **APIs & Services** > **OAuth consent screen**
2. Selecione **External** (para testes) ou **Internal** (para uso empresarial)
3. Preencha as informações obrigatórias:
   - **App name**: Sistema de Cartão de Benefícios
   - **User support email**: daniellinsr@gmail.com
   - **Developer contact**: daniellinsr@gmail.com
4. Clique em **Save and Continue**
5. Em **Scopes**, adicione:
   - `../auth/userinfo.email`
   - `../auth/userinfo.profile`
6. Adicione **Test users** (para desenvolvimento)

### 4. Criar Credenciais OAuth

#### Para Android:

1. Vá para **APIs & Services** > **Credentials**
2. Clique em **Create Credentials** > **OAuth client ID**
3. Selecione **Android**
4. Preencha:
   - **Name**: `Android OAuth Cliente`
   - **Package name**: `com.exemplo.cadastro_beneficios` (seu package name)
   - **SHA-1 certificate fingerprint**

**Obter SHA-1 (Debug):**
```bash
# Windows
keytool -list -v -keystore "%USERPROFILE%\.android\debug.keystore" -alias androiddebugkey -storepass android -keypass android

# macOS/Linux
keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android
```

**Obter SHA-1 (Release):**
```bash
keytool -list -v -keystore caminho/para/sua/keystore.jks -alias sua-alias
```

5. Clique em **Create**
6. **IMPORTANTE**: Anote o **Client ID** gerado

#### Para iOS:

1. Clique em **Create Credentials** > **OAuth client ID**
2. Selecione **iOS**
3. Preencha:
   - **Name**: `iOS OAuth Cliente`
   - **Bundle ID**: `com.beneficios.cadastroBeneficios`
4. Clique em **Create**
5. **IMPORTANTE**: Anote o **Client ID** gerado
6. Baixe o arquivo `GoogleService-Info.plist`

#### Cliente Web (para backend validation):

1. Crie um **Web application** OAuth client
2. Este será usado pelo backend para validar o ID token

---

## 🤖 Configuração Android

### 1. Atualizar `android/app/build.gradle`

```gradle
android {
    defaultConfig {
        applicationId "com.exemplo.cadastro_beneficios"
        minSdkVersion 21  // Mínimo para Google Sign In
        targetSdkVersion 34
        // ...
    }
}
```

### 2. Adicionar dependências (já feito no pubspec.yaml)

```yaml
dependencies:
  google_sign_in: ^6.2.1
```

### 3. Não é necessário adicionar google-services.json

O Google Sign-In para Android não requer `google-services.json`. Ele usa apenas o SHA-1 configurado no Console.

### 4. Verificar Permissões (android/app/src/main/AndroidManifest.xml)

As permissões de internet já devem estar configuradas:

```xml
<uses-permission android:name="android.permission.INTERNET"/>
```

---

## 🍎 Configuração iOS

### 1. Atualizar Info.plist

Adicione o seguinte em `ios/Runner/Info.plist`:

```xml
<!-- Adicione dentro do <dict> principal -->
<key>CFBundleURLTypes</key>
<array>
    <dict>
        <key>CFBundleTypeRole</key>
        <string>Editor</string>
        <key>CFBundleURLSchemes</key>
        <array>
            <!-- Reversed client ID do GoogleService-Info.plist -->
            <string>com.googleusercontent.apps.SEU-CLIENT-ID-AQUI</string>
        </array>
    </dict>
</array>

<!-- Google Sign In Configuration -->
<key>GIDClientID</key>
<string>SEU-CLIENT-ID-AQUI.apps.googleusercontent.com</string>
```

**Como obter o Reversed Client ID:**
1. Abra o arquivo `GoogleService-Info.plist` baixado do Console
2. Procure por `REVERSED_CLIENT_ID`
3. Copie o valor

### 2. Atualizar Podfile

Em `ios/Podfile`, certifique-se que a versão do iOS é 12.0+:

```ruby
platform :ios, '12.0'
```

### 3. Instalar Pods

```bash
cd ios
pod install
cd ..
```

### 4. Configurar Signing

No Xcode:
1. Abra `ios/Runner.xcworkspace`
2. Selecione o target **Runner**
3. Em **Signing & Capabilities**, configure seu Team e Bundle Identifier

---

## 🌐 Configuração Web (Opcional)

### 1. Adicionar meta tag no index.html

Em `web/index.html`, adicione dentro do `<head>`:

```html
<meta name="google-signin-client_id" content="SEU-WEB-CLIENT-ID.apps.googleusercontent.com">
```

### 2. Configurar domínios autorizados

No Google Cloud Console:
1. Vá para **Credentials**
2. Edite o **Web client**
3. Em **Authorized JavaScript origins**, adicione:
   - `http://localhost:8080` (desenvolvimento)
   - `https://seu-dominio.com` (produção)

---

## 🧪 Testando a Integração

### 1. Código de Teste Simples

```dart
import 'package:cadastro_beneficios/core/services/google_auth_service.dart';

void testGoogleSignIn() async {
  final googleAuthService = GoogleAuthService();

  try {
    final idToken = await googleAuthService.signIn();
    print('✅ Login bem-sucedido! ID Token: ${idToken.substring(0, 20)}...');
  } catch (e) {
    print('❌ Erro no login: $e');
  }
}
```

### 2. Executar no Dispositivo

```bash
# Android
flutter run

# iOS
flutter run -d ios

# Web
flutter run -d chrome
```

### 3. Verificar Logs

**Android:**
```bash
adb logcat | grep GoogleAuth
```

**iOS:**
```bash
flutter logs
```

---

## 🔄 Fluxo de Autenticação

### Frontend (Flutter)

```dart
// 1. Usuário clica em "Login com Google"
authBloc.add(const AuthLoginWithGoogleRequested());

// 2. GoogleAuthService obtém ID Token
final idToken = await googleAuthService.signIn();

// 3. LoginWithGoogleUseCase envia ID Token para backend
final result = await loginWithGoogleUseCase();

// 4. Backend valida e retorna AuthToken
// 5. AuthBloc salva token e busca dados do usuário
// 6. App navega para tela principal
```

### Backend (API)

O backend deve implementar o endpoint `POST /auth/google/login`:

```json
// Request
{
  "id_token": "eyJhbGciOiJSUzI1NiIsImtpZCI6..."
}

// Response (sucesso)
{
  "access_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6...",
  "refresh_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6...",
  "expires_at": "2024-12-13T15:30:00Z",
  "token_type": "Bearer"
}
```

**Validação do ID Token no Backend (Node.js exemplo):**

```javascript
const { OAuth2Client } = require('google-auth-library');
const client = new OAuth2Client(process.env.GOOGLE_CLIENT_ID);

async function verifyGoogleToken(idToken) {
  const ticket = await client.verifyIdToken({
    idToken: idToken,
    audience: process.env.GOOGLE_CLIENT_ID,
  });

  const payload = ticket.getPayload();
  const userId = payload['sub'];
  const email = payload['email'];
  const name = payload['name'];
  const picture = payload['picture'];

  // Criar ou atualizar usuário no banco de dados
  // Gerar JWT token do sistema
  // Retornar AuthToken
}
```

---

## 🔧 Troubleshooting

### Erro: "Sign in failed" no Android

**Causas comuns:**
1. SHA-1 incorreto ou não configurado
2. Package name diferente do configurado
3. Usuário não adicionado como test user

**Solução:**
```bash
# Verificar SHA-1 atual
keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android

# Comparar com o configurado no Console
# Recriar credencial com SHA-1 correto se necessário
```

### Erro: "The operation couldn't be completed" no iOS

**Causas:**
1. URL Scheme não configurado corretamente
2. GIDClientID ausente ou incorreto no Info.plist
3. Pods não instalados

**Solução:**
```bash
cd ios
pod deintegrate
pod install
cd ..
flutter clean
flutter pub get
```

### Erro: "API not enabled"

**Solução:**
1. Acesse Google Cloud Console
2. Vá para **APIs & Services** > **Library**
3. Procure "Google Sign-In API"
4. Clique em **Enable**
5. Aguarde alguns minutos para propagação

### Erro: "This app is not verified"

Durante desenvolvimento, se aparecer tela de aviso do Google:

1. Clique em **Advanced**
2. Clique em **Go to [App Name] (unsafe)**
3. Para remover em produção:
   - Complete o processo de verificação do app no Google Cloud Console
   - Ou use domínio corporativo (Google Workspace)

### Usuário cancela o login

```dart
try {
  final idToken = await googleAuthService.signIn();
} catch (e) {
  if (e is AuthException && e.code == 'GOOGLE_SIGN_IN_CANCELLED') {
    // Usuário cancelou - não mostrar erro
    print('Login cancelado pelo usuário');
  } else {
    // Erro real - mostrar mensagem
    print('Erro: ${e.message}');
  }
}
```

---

## 📚 Referências

- [Google Sign-In Flutter Plugin](https://pub.dev/packages/google_sign_in)
- [Google Identity Documentation](https://developers.google.com/identity)
- [OAuth 2.0 Documentation](https://developers.google.com/identity/protocols/oauth2)
- [Validating ID Tokens](https://developers.google.com/identity/sign-in/android/backend-auth)

---

## ✅ Checklist de Configuração

- [ ] Projeto criado no Google Cloud Console
- [ ] Google Sign-In API habilitada
- [ ] OAuth Consent Screen configurado
- [ ] Credencial Android criada com SHA-1
- [ ] Credencial iOS criada com Bundle ID
- [ ] Info.plist atualizado (iOS)
- [ ] Pods instalados (iOS)
- [ ] Package name correto (Android)
- [ ] Test users adicionados
- [ ] Backend preparado para validar ID token
- [ ] Testado em dispositivo real
- [ ] Tratamento de erros implementado

---

**Última atualização:** Dezembro 2024
**Status:** ✅ Documentação Completa
