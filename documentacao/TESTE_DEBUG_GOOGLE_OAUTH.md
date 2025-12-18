# 🔍 Instruções de Teste - Debug Google OAuth

**Data:** 2025-12-17
**Objetivo:** Diagnosticar por que o redirecionamento não está funcionando após login Google

---

## 🚀 COMO TESTAR

### 1. Abrir DevTools do Navegador
- Pressione `F12` no Chrome/Edge
- Vá para a aba **Console**

### 2. Executar o App
```bash
flutter run -d chrome
```

### 3. Fazer Login com Google
1. Clicar no botão "Continuar com Google"
2. Selecionar/logar com sua conta Google
3. **OBSERVAR OS LOGS NO CONSOLE**

---

## 📊 LOGS ESPERADOS

### ✅ Fluxo Correto (O que DEVERIA aparecer)

```
🔐 [AuthBloc] Iniciando login com Google...
✅ [AuthBloc] Login Google bem-sucedido!
✅ [AuthBloc] Token salvo
🔍 [AuthBloc] Buscando dados do usuário...
✅ [AuthBloc] Usuário carregado: seu-email@gmail.com
   isProfileComplete: false
   profileCompletionStatus: ProfileCompletionStatus.incomplete
📤 [AuthBloc] Emitindo AuthAuthenticated...
🎯 [LoginPage] Estado recebido: AuthAuthenticated
✅ [LoginPage] AuthAuthenticated recebido!
   User: seu-email@gmail.com
   isProfileComplete: false
🔀 [LoginPage] Redirecionando para /complete-profile...
```

### ❌ Possíveis Problemas

#### Problema 1: Erro ao buscar usuário
```
🔐 [AuthBloc] Iniciando login com Google...
✅ [AuthBloc] Login Google bem-sucedido!
✅ [AuthBloc] Token salvo
🔍 [AuthBloc] Buscando dados do usuário...
❌ [AuthBloc] Erro ao buscar usuário: [mensagem de erro]
🎯 [LoginPage] Estado recebido: AuthError
❌ [LoginPage] Erro: [mensagem de erro]
```

**Solução:** Verificar se o endpoint `/api/auth/me` está funcionando

#### Problema 2: Estado não chega no LoginPage
```
🔐 [AuthBloc] Iniciando login com Google...
✅ [AuthBloc] Login Google bem-sucedido!
✅ [AuthBloc] Token salvo
🔍 [AuthBloc] Buscando dados do usuário...
✅ [AuthBloc] Usuário carregado: seu-email@gmail.com
   isProfileComplete: false
📤 [AuthBloc] Emitindo AuthAuthenticated...
[... NADA MAIS APARECE ...]
```

**Solução:** Problema no BlocConsumer do LoginPage

#### Problema 3: profile_completion_status não está vindo do backend
```
🔐 [AuthBloc] Iniciando login com Google...
✅ [AuthBloc] Login Google bem-sucedido!
✅ [AuthBloc] Token salvo
🔍 [AuthBloc] Buscando dados do usuário...
✅ [AuthBloc] Usuário carregado: seu-email@gmail.com
   isProfileComplete: true  ← DEVERIA SER false PARA NOVO USUÁRIO!
   profileCompletionStatus: ProfileCompletionStatus.complete
```

**Solução:** Backend não está retornando `profile_completion_status='incomplete'`

---

## 🔍 VERIFICAÇÕES ADICIONAIS

### Verificar Response do Backend

Na aba **Network** do DevTools:

#### 1. Verificar POST `/api/auth/login/google`
**Filtrar:** `login/google`

**Response esperado:**
```json
{
  "user": {
    "id": "uuid...",
    "email": "seu-email@gmail.com",
    "name": "Seu Nome",
    "profile_completion_status": "incomplete"  ← VERIFICAR!
  },
  "access_token": "jwt...",
  "refresh_token": "uuid...",
  "token_type": "Bearer",
  "expires_in": 604800
}
```

#### 2. Verificar GET `/api/auth/me`
**Filtrar:** `/me`

**Response esperado:**
```json
{
  "id": "uuid...",
  "email": "seu-email@gmail.com",
  "name": "Seu Nome",
  "phone_number": "",
  "cpf": null,
  "birth_date": null,
  "role": "beneficiary",
  "email_verified": true,
  "phone_verified": false,
  "profile_completion_status": "incomplete",  ← VERIFICAR!
  "created_at": "2025-12-17T..."
}
```

---

## 🐛 POSSÍVEIS CAUSAS E SOLUÇÕES

### Causa 1: Backend não está retornando profile_completion_status

**Verificar:**
```bash
# Verificar se a coluna existe no banco
psql -h 77.37.41.41 -U cadastro_user -p 5411 -d cadastro_db \
  -c "SELECT column_name FROM information_schema.columns
      WHERE table_name='users' AND column_name='profile_completion_status';"
```

**Deve retornar:**
```
       column_name
--------------------------
 profile_completion_status
```

### Causa 2: UserModel não está deserializando corretamente

**Verificar se o build_runner foi executado:**
```bash
dart run build_runner build --delete-conflicting-outputs
```

### Causa 3: AuthBloc não está emitindo o estado

**Verificar se o LoginPage está usando BlocProvider:**

O LoginPage deve estar dentro de um `BlocProvider<AuthBloc>` no widget tree.

---

## 📝 O QUE FAZER COM OS LOGS

Após fazer o teste de login com Google, **copie TODOS os logs do console** e me envie. Isso me ajudará a identificar exatamente onde está o problema.

**Como copiar os logs:**
1. Clique com botão direito no console
2. "Save as..." ou "Copy all"
3. Cole aqui na conversa

---

## 🎯 PRÓXIMOS PASSOS

Baseado nos logs que você me enviar, poderei:

1. ✅ Identificar se o problema é no backend ou frontend
2. ✅ Ver exatamente onde o fluxo está quebrando
3. ✅ Aplicar a correção específica necessária

---

**Execute o teste e me envie os logs do console! 🔍**
