# Firebase - Setup Passo a Passo

## 🎯 Configuração Completa do Firebase

**Tempo estimado:** 15-20 minutos

---

## 📋 PARTE 1: Criar Projeto no Firebase

### Passo 1.1: Acessar Firebase Console

1. Acesse: https://console.firebase.google.com/
2. Faça login com sua conta Google
3. Clique em **"Adicionar projeto"** ou **"Create a project"**

### Passo 1.2: Configurar Projeto

**Nome do projeto:**
```
cadastro-beneficios
```

Clique em **Continuar**

### Passo 1.3: Google Analytics (Opcional)

- Você pode **desabilitar** por enquanto (mais simples)
- Ou habilitar se quiser analytics (recomendado para produção)

Clique em **Criar projeto**

Aguarde ~30 segundos até o projeto ser criado.

Clique em **Continuar** quando estiver pronto.

---

## 📱 PARTE 2: Adicionar Apps ao Projeto

### Passo 2.1: Adicionar App Web

1. Na página inicial do projeto, clique no ícone **Web** (`</>`)
2. **Apelido do app:** `cadastro-beneficios-web`
3. **NÃO** marque "Firebase Hosting" por enquanto
4. Clique em **Registrar app**

**IMPORTANTE:** Você verá um código JavaScript assim:

```javascript
const firebaseConfig = {
  apiKey: "AIzaSyXXXXXXXXXXXXXXXXXXXXXXXXXXXXX",
  authDomain: "cadastro-beneficios-xxxxx.firebaseapp.com",
  projectId: "cadastro-beneficios-xxxxx",
  storageBucket: "cadastro-beneficios-xxxxx.appspot.com",
  messagingSenderId: "123456789012",
  appId: "1:123456789012:web:abcdef0123456789abcdef"
};
```

**COPIE ESSE CÓDIGO!** Você vai precisar dele.

Clique em **Continuar no console**

### Passo 2.2: Adicionar App Android

1. Na página inicial do projeto, clique no ícone **Android**
2. **Package name:** `com.example.cadastro_beneficios`

   ⚠️ **IMPORTANTE:** Esse nome deve ser EXATAMENTE igual ao do seu app!

   Para verificar, abra: `android/app/build.gradle`
   ```gradle
   defaultConfig {
       applicationId "com.example.cadastro_beneficios" // ← Este aqui!
   }
   ```

3. **App nickname (opcional):** `Cadastro Benefícios Android`
4. **SHA-1 (opcional por enquanto):** Deixe vazio (pode adicionar depois)
5. Clique em **Registrar app**

### Passo 2.3: Download google-services.json (Android)

1. Clique em **Fazer download do google-services.json**
2. Salve o arquivo
3. **COPIE** o arquivo para: `android/app/google-services.json`

   ```
   seu-projeto/
   └── android/
       └── app/
           └── google-services.json  ← Aqui!
   ```

Clique em **Próximo** → **Próximo** → **Continuar no console**

### Passo 2.4: Adicionar App iOS

1. Na página inicial do projeto, clique no ícone **iOS**
2. **Bundle ID:** `com.beneficios.cadastroBeneficios`

   Para verificar, abra: `ios/Runner.xcodeproj/project.pbxproj` e procure por `PRODUCT_BUNDLE_IDENTIFIER`

3. **App nickname (opcional):** `Cadastro Benefícios iOS`
4. Clique em **Registrar app**

### Passo 2.5: Download GoogleService-Info.plist (iOS)

1. Clique em **Fazer download do GoogleService-Info.plist**
2. Salve o arquivo
3. **COPIE** o arquivo para: `ios/Runner/GoogleService-Info.plist`

   ```
   seu-projeto/
   └── ios/
       └── Runner/
           └── GoogleService-Info.plist  ← Aqui!
   ```

Clique em **Próximo** → **Próximo** → **Continuar no console**

---

## 🔐 PARTE 3: Habilitar Autenticação

### Passo 3.1: Acessar Authentication

1. No menu lateral, clique em **Authentication** (ícone de cadeado)
2. Clique em **Começar** ou **Get started**

### Passo 3.2: Habilitar Google Sign-In

1. Clique na aba **Sign-in method** (Método de login)
2. Na lista de provedores, encontre **Google**
3. Clique em **Google**
4. Clique no switch para **Ativar**
5. **Email de suporte do projeto:** Coloque seu email
6. Clique em **Salvar**

### Passo 3.3: Habilitar Email/Password (Opcional)

1. Na mesma lista, encontre **Email/senha**
2. Clique em **Email/senha**
3. Clique no switch para **Ativar**
4. Clique em **Salvar**

---

## 🔧 PARTE 4: Configurar Domínios Autorizados (Web)

### Passo 4.1: Adicionar localhost

1. Ainda em **Authentication** → **Settings** (Configurações)
2. Vá até **Authorized domains** (Domínios autorizados)
3. Clique em **Add domain** (Adicionar domínio)
4. Adicione: `localhost`
5. Clique em **Add** (Adicionar)

**Nota:** `localhost` já deve estar lá por padrão, mas verifique!

---

## 📝 PARTE 5: Copiar Configurações

### Passo 5.1: Configurações Web

As configurações Web você já copiou no **Passo 2.1**. Elas são assim:

```javascript
const firebaseConfig = {
  apiKey: "AIzaSyXXXXXXXXXXXXXXXXXXXXXXXXXXXXX",
  authDomain: "cadastro-beneficios-xxxxx.firebaseapp.com",
  projectId: "cadastro-beneficios-xxxxx",
  storageBucket: "cadastro-beneficios-xxxxx.appspot.com",
  messagingSenderId: "123456789012",
  appId: "1:123456789012:web:abcdef0123456789abcdef"
};
```

**Onde usar:**
- `lib/firebase_options.dart` (vamos criar)
- `web/index.html` (vamos atualizar)

### Passo 5.2: Arquivos Baixados

Certifique-se de que você tem:

✅ `android/app/google-services.json`
✅ `ios/Runner/GoogleService-Info.plist`

---

## ✅ CHECKLIST DE CONFIGURAÇÃO

### Firebase Console
- [ ] Projeto criado
- [ ] App Web registrado
- [ ] App Android registrado (com google-services.json)
- [ ] App iOS registrado (com GoogleService-Info.plist)
- [ ] Google Sign-In habilitado
- [ ] Email/Password habilitado (opcional)
- [ ] localhost nos domínios autorizados

### Arquivos
- [ ] `android/app/google-services.json` copiado
- [ ] `ios/Runner/GoogleService-Info.plist` copiado
- [ ] Configurações Web copiadas (firebaseConfig)

---

## 🚀 Próximos Passos

Depois de concluir essas configurações, você pode:

1. **Instalar dependências** no Flutter
2. **Criar firebase_options.dart** com as configurações
3. **Atualizar main.dart** para inicializar Firebase
4. **Criar FirebaseAuthService**
5. **Testar!**

---

## 🆘 Problemas Comuns

### Problema 1: "Project not found"
**Solução:** Verifique se está usando o projeto correto no console

### Problema 2: "google-services.json not found"
**Solução:** Certifique-se de que o arquivo está em `android/app/google-services.json`

### Problema 3: "Package name mismatch"
**Solução:** O package name no Firebase deve ser igual ao do `build.gradle`

### Problema 4: "Authentication disabled"
**Solução:** Verifique se habilitou Google Sign-In em Authentication → Sign-in method

---

## 📸 Screenshots Importantes

### 1. Criar Projeto
```
Firebase Console → Adicionar projeto → [Nome] → Criar
```

### 2. Adicionar App
```
Visão geral do projeto → Ícone Web/Android/iOS → Configurar
```

### 3. Habilitar Authentication
```
Menu lateral → Authentication → Get started → Sign-in method → Google → Ativar
```

---

## 🔍 Como Verificar se Está Tudo Certo

### No Firebase Console

1. **Projeto criado:**
   - Você deve ver o nome do projeto no topo da página

2. **Apps registrados:**
   - Em "Visão geral do projeto", você deve ver 3 ícones (Web, Android, iOS)

3. **Authentication habilitado:**
   - Em Authentication → Sign-in method, deve mostrar Google como "Ativado"

4. **Arquivos baixados:**
   ```bash
   # Verificar Android
   ls android/app/google-services.json

   # Verificar iOS
   ls ios/Runner/GoogleService-Info.plist
   ```

---

## 📚 Links Úteis

- **Firebase Console:** https://console.firebase.google.com/
- **FlutterFire Docs:** https://firebase.flutter.dev/
- **Firebase Auth Docs:** https://firebase.google.com/docs/auth

---

**Quando terminar essas configurações, me avise que eu implemento o código no Flutter! 🚀**

---

**Data:** 2025-12-16
**Autor:** Claude Sonnet 4.5
**Status:** Guia de Configuração Completo