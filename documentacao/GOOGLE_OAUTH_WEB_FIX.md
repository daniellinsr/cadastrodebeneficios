# Solução: Google OAuth na Web

## 🔴 Problema Identificado

**Erro:** `Acesso bloqueado: Storagerelay URI is not allowed for 'NATIVE_IOS' client type. Error 400: invalid_request`

**Causa:** O Client ID configurado no `web/index.html` é do tipo **NATIVE (iOS/Android)**, mas para funcionar na web, é necessário um **Client ID do tipo WEB**.

---

## ✅ Solução Passo a Passo

### 1. Criar Client ID para Web no Google Cloud Console

#### Passo 1.1: Acessar Google Cloud Console
1. Acesse: https://console.cloud.google.com/
2. Selecione seu projeto: **"Sistema de Cartão de Benefícios"**
3. No menu lateral, vá em: **APIs e Serviços** → **Credenciais**

#### Passo 1.2: Criar novo Client ID (Web)
1. Clique em **"+ CRIAR CREDENCIAIS"**
2. Selecione **"ID do cliente OAuth 2.0"**
3. Escolha o tipo: **"Aplicativo da Web"**

#### Passo 1.3: Configurar o Client ID Web
Preencha os campos:

**Nome:**
```
Sistema de Cartão de Benefícios - Web
```

**Origens JavaScript autorizadas:**
```
http://localhost:3000
http://localhost:8080
http://localhost
http://127.0.0.1:3000
http://127.0.0.1:8080
```

**URIs de redirecionamento autorizados:**
```
http://localhost:3000
http://localhost:8080
http://localhost
http://127.0.0.1:3000
http://127.0.0.1:8080
```

**Nota:** Adicione também suas URLs de produção quando tiver:
```
https://seudominio.com
https://www.seudominio.com
```

#### Passo 1.4: Copiar o Client ID
Após criar, você receberá:
- **Client ID (Web)**: algo como `123456789-abcdefg.apps.googleusercontent.com`
- **Client Secret**: guarde em local seguro (não precisa no Flutter Web)

---

### 2. Atualizar o arquivo web/index.html

Abra o arquivo `web/index.html` e **substitua** o Client ID existente pelo novo Client ID Web:

```html
<!-- Antes (INCORRETO - Client ID iOS/Android) -->
<meta name="google-signin-client_id" content="403775802042-dr9hvctbr6qfildd767us0o057m3iu3m.apps.googleusercontent.com">

<!-- Depois (CORRETO - Client ID Web) -->
<meta name="google-signin-client_id" content="SEU_CLIENT_ID_WEB_AQUI.apps.googleusercontent.com">
```

**Exemplo:**
```html
<meta name="google-signin-client_id" content="123456789-abcdefghijklmnop.apps.googleusercontent.com">
```

---

### 3. Verificar Configuração do OAuth Consent Screen

#### Passo 3.1: Acessar OAuth Consent Screen
1. No Google Cloud Console, vá em: **APIs e Serviços** → **Tela de consentimento OAuth**

#### Passo 3.2: Verificar Configurações

**Domínios Autorizados:**
```
localhost
127.0.0.1
```

E adicione seu domínio de produção se tiver.

**Escopos necessários:**
- `email`
- `profile`
- `openid`

Estes são os escopos básicos que já devem estar configurados.

---

### 4. Atualizar GoogleAuthService para Web

#### IMPORTANTE: Adicionar script do Google Identity Services

Adicione o script do Google no `web/index.html` **antes** do `flutter_bootstrap.js`:

```html
<body>
  <!-- Google Identity Services (GIS) -->
  <script src="https://accounts.google.com/gsi/client" async defer></script>

  <script src="flutter_bootstrap.js" async></script>
</body>
```

#### Atualizar arquivo: `lib/core/services/google_auth_service.dart`

Para funcionar na web e obter o `idToken`, é necessário adicionar algumas configurações:

```dart
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cadastro_beneficios/core/errors/exceptions.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class GoogleAuthService {
  final GoogleSignIn _googleSignIn;

  GoogleAuthService({
    GoogleSignIn? googleSignIn,
  }) : _googleSignIn = googleSignIn ??
            GoogleSignIn(
              scopes: [
                'email',
                'profile',
                'openid',  // ← IMPORTANTE: adicionar 'openid'
              ],
              // ← IMPORTANTE: Para web, especificar serverClientId
              serverClientId: kIsWeb
                  ? 'SEU_CLIENT_ID_WEB.apps.googleusercontent.com'
                  : null,
            );

  Future<String> signIn() async {
    try {
      final GoogleSignInAccount? account = await _googleSignIn.signIn();

      if (account == null) {
        throw const AuthException(
          message: 'Login cancelado pelo usuário',
          code: 'GOOGLE_SIGN_IN_CANCELLED',
        );
      }

      final GoogleSignInAuthentication auth = await account.authentication;

      if (auth.idToken == null) {
        throw const AuthException(
          message: 'Falha ao obter token do Google',
          code: 'GOOGLE_ID_TOKEN_NULL',
        );
      }

      return auth.idToken!;
    } on AuthException {
      rethrow;
    } catch (e) {
      throw AuthException(
        message: 'Erro ao fazer login com Google: ${e.toString()}',
        code: 'GOOGLE_SIGN_IN_ERROR',
      );
    }
  }
}
```

**Mudanças importantes:**
1. ✅ Adicionado `import 'package:flutter/foundation.dart' show kIsWeb;`
2. ✅ Adicionado scope `'openid'` na lista de escopos
3. ✅ Adicionado `serverClientId` com verificação `kIsWeb`
4. ✅ O `serverClientId` deve ser o mesmo Client ID Web configurado no `index.html`

**Nota:** O `google_sign_in` detecta automaticamente a plataforma (web, iOS, Android) e usa a implementação correta, mas na web precisa do `serverClientId` para requisitar o `idToken`.

---

### 5. Configuração Adicional para Web (Opcional)

Se você quiser ter mais controle sobre a configuração web, pode especificar o Client ID diretamente no código:

```dart
class GoogleAuthService {
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email', 'profile'],
    // Especificar Client ID para web (opcional, pois já está no index.html)
    clientId: kIsWeb
      ? 'SEU_CLIENT_ID_WEB.apps.googleusercontent.com'
      : null,
  );
}
```

Importe o `foundation.dart`:
```dart
import 'package:flutter/foundation.dart' show kIsWeb;
```

---

### 6. Rebuild e Teste

#### Passo 6.1: Limpar e Rebuild
```bash
flutter clean
flutter pub get
```

#### Passo 6.2: Executar na Web
```bash
flutter run -d chrome
# ou
flutter run -d edge
```

#### Passo 6.3: Testar Login
1. Abra a aplicação no navegador
2. Clique em "Cadastrar com Google"
3. Deve abrir o popup de autenticação do Google
4. Após login, deve retornar o ID Token com sucesso

---

## 🔍 Troubleshooting

### Erro: "Origin not allowed"
**Solução:** Adicione a origem (URL) nas "Origens JavaScript autorizadas" no Google Cloud Console.

### Erro: "Redirect URI mismatch"
**Solução:** Adicione a URI de redirecionamento nas "URIs de redirecionamento autorizados".

### Erro: "Client ID not found"
**Solução:** Verifique se o Client ID no `web/index.html` está correto (copie e cole novamente do Google Cloud Console).

### Popup não abre
**Solução:**
1. Verifique se o navegador está bloqueando popups
2. Habilite popups para localhost
3. Tente em modo anônimo/privado

### Erro após login: "Token is null"
**Solução:**
1. Verifique os escopos configurados
2. Certifique-se de que o OAuth Consent Screen está publicado
3. Tente desconectar e reconectar

---

## 📋 Checklist de Configuração

### Google Cloud Console
- [ ] Projeto criado
- [ ] OAuth Consent Screen configurado
- [ ] Client ID Web criado
- [ ] Origens JavaScript autorizadas adicionadas
- [ ] URIs de redirecionamento autorizados adicionadas
- [ ] Escopos email e profile configurados

### Código Flutter
- [ ] Client ID Web atualizado em `web/index.html`
- [ ] `google_sign_in` package instalado
- [ ] `GoogleAuthService` implementado
- [ ] Botão de login configurado

### Testes
- [ ] `flutter clean` executado
- [ ] `flutter pub get` executado
- [ ] App rodando na web (chrome/edge)
- [ ] Popup de autenticação abre
- [ ] Login retorna ID Token
- [ ] Sem erros no console

---

## 🎯 Exemplo Completo

### Google Cloud Console

**Client ID criado:**
```
Nome: Sistema de Cartão de Benefícios - Web
Tipo: Aplicativo da Web
Client ID: 123456789-abc123xyz789.apps.googleusercontent.com
```

**Origens JavaScript:**
```
http://localhost
http://localhost:3000
http://localhost:8080
http://127.0.0.1
http://127.0.0.1:3000
http://127.0.0.1:8080
https://meuapp.com
https://www.meuapp.com
```

**URIs de Redirecionamento:**
```
http://localhost
http://localhost:3000
http://localhost:8080
https://meuapp.com
https://www.meuapp.com
```

### web/index.html

```html
<!DOCTYPE html>
<html>
<head>
  <base href="$FLUTTER_BASE_HREF">
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">

  <!-- Google Sign-In Web Client ID -->
  <meta name="google-signin-client_id" content="123456789-abc123xyz789.apps.googleusercontent.com">

  <title>Sistema de Cartão de Benefícios</title>
  <link rel="manifest" href="manifest.json">
</head>
<body>
  <script src="flutter_bootstrap.js" async></script>
</body>
</html>
```

---

## 📱 Diferenças entre Client IDs

### Client ID iOS/Android (NATIVE)
```
403775802042-dr9hvctbr6qfildd767us0o057m3iu3m.apps.googleusercontent.com
```
- ✅ Funciona em: Apps iOS e Android
- ❌ NÃO funciona em: Web
- Configuração: AndroidManifest.xml, Info.plist

### Client ID Web
```
123456789-abc123xyz789.apps.googleusercontent.com
```
- ✅ Funciona em: Navegadores web
- ❌ NÃO funciona em: Apps nativos
- Configuração: web/index.html, origens JavaScript

**IMPORTANTE:** Você pode (e deve) ter ambos os Client IDs no mesmo projeto do Google Cloud Console:
- Um para iOS/Android
- Um para Web

---

## 🚀 Próximos Passos

Após configurar o Google OAuth para web:

1. **Testar em diferentes navegadores:**
   - Chrome
   - Edge
   - Firefox
   - Safari

2. **Configurar produção:**
   - Adicionar domínio de produção
   - Configurar HTTPS
   - Atualizar origens autorizadas

3. **Implementar backend:**
   - Validar ID Token no servidor
   - Criar/atualizar usuário no banco
   - Retornar JWT próprio

4. **Melhorias opcionais:**
   - Adicionar loading state
   - Implementar logout
   - Sincronizar dados do perfil
   - Adicionar avatar do Google

---

## 📚 Referências

- [Google Sign-In for Web](https://developers.google.com/identity/sign-in/web)
- [Flutter google_sign_in Package](https://pub.dev/packages/google_sign_in)
- [Google OAuth 2.0 Documentation](https://developers.google.com/identity/protocols/oauth2)
- [Flutter Web Support](https://flutter.dev/multi-platform/web)

---

**Data:** 2025-12-16
**Status:** 📋 Guia de Solução Pronto
**Próximo Passo:** Criar Client ID Web no Google Cloud Console
