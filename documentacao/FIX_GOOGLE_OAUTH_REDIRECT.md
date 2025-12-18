# 🐛 Fix: Redirecionamento após Login Google OAuth

**Data:** 2025-12-17
**Problema:** Após login com Google, usuário não é redirecionado para `/complete-profile`

---

## 🔍 ANÁLISE DO PROBLEMA

### Fluxo Atual (Com Problema)
```
1. Usuário clica "Login com Google"
   ↓
2. AuthBloc → AuthAuthenticated
   ↓
3. LoginPage: context.go('/home')
   ↓
4. Router guard executa
   ↓
5. Router guard chama getCurrentUser()
   ↓
6. ❌ PROBLEMA: getCurrentUser() pode estar retornando dados em cache
   ou não está incluindo profile_completion_status
   ↓
7. Usuário fica em /home ao invés de /complete-profile
```

### Possíveis Causas

1. **Cache do AuthBloc:** O AuthBloc pode estar guardando o user em cache sem o campo `profile_completion_status` atualizado

2. **getCurrentUser() do backend:** Pode não estar retornando o campo correto

3. **Timing:** O router guard executa antes do token ser salvo corretamente

4. **Deserialização:** O `profile_completion_status` pode não estar sendo deserializado corretamente no UserModel

---

## 🔧 SOLUÇÃO PROPOSTA

### Opção 1: Forçar Fetch após Login (RECOMENDADO)

Modificar o AuthBloc para buscar o usuário atualizado do backend imediatamente após o login com Google.

**Arquivo:** `lib/presentation/bloc/auth/auth_bloc.dart`

**Modificação no `AuthLoginWithGoogleRequested`:**

```dart
on<AuthLoginWithGoogleRequested>((event, emit) async {
  try {
    emit(AuthLoading());

    // 1. Login com Google
    final result = await _loginWithGoogle();

    result.fold(
      (failure) => emit(AuthError(message: failure.message)),
      (authToken) async {
        // 2. Salvar tokens
        await _tokenService.saveAccessToken(authToken.accessToken);
        await _tokenService.saveRefreshToken(authToken.refreshToken);
        await _tokenService.saveTokenExpiration(authToken.expiresAt);

        // 3. BUSCAR USUÁRIO ATUALIZADO DO BACKEND
        final userResult = await _authRepository.getCurrentUser();

        userResult.fold(
          (failure) => emit(AuthError(message: failure.message)),
          (user) {
            // 4. Emitir com usuário atualizado
            emit(AuthAuthenticated(user: user));
          },
        );
      },
    );
  } catch (e) {
    emit(AuthError(message: 'Erro ao fazer login com Google'));
  }
});
```

### Opção 2: Router Guard com Verificação Direta do Token

Ao invés de chamar `getCurrentUser()` no router guard, podemos verificar diretamente os dados do token.

**Arquivo:** `lib/core/router/app_router.dart`

```dart
redirect: (context, state) async {
  if (state.matchedLocation == '/splash') {
    return null;
  }

  final isAuthenticated = await _isAuthenticated();
  // ... lógica existente ...

  if (isAuthenticated) {
    try {
      // Buscar usuário do backend (não do cache)
      final userResult = await sl.authRepository.getCurrentUser();

      return userResult.fold(
        (failure) {
          print('❌ Erro ao buscar usuário: ${failure.message}');
          return '/login';
        },
        (user) {
          print('✅ Usuário carregado: ${user.email}');
          print('   isProfileComplete: ${user.isProfileComplete}');
          print('   profileCompletionStatus: ${user.profileCompletionStatus}');

          // Lógica de redirecionamento...
          if (!user.isProfileComplete && !isCompleteProfileRoute) {
            print('🔀 Redirecionando para /complete-profile');
            return '/complete-profile';
          }

          // ... resto da lógica
        },
      );
    } catch (e) {
      print('❌ Exception no router guard: $e');
      return null;
    }
  }

  // ... resto
}
```

### Opção 3: Alterar LoginPage para Verificar Perfil

Modificar o LoginPage para verificar o perfil do usuário após autenticação e decidir o redirecionamento.

**Arquivo:** `lib/presentation/pages/auth/login_page.dart`

```dart
listener: (context, state) {
  if (state is AuthError) {
    CustomSnackBar.show(
      context,
      message: state.message,
      type: SnackBarType.error,
    );
  } else if (state is AuthAuthenticated) {
    // Verificar se perfil está completo
    if (state.user.isProfileComplete) {
      context.go('/home');
    } else {
      context.go('/complete-profile');
    }
  }
},
```

---

## ✅ IMPLEMENTAÇÃO RECOMENDADA

Vamos combinar **Opção 1 + Opção 3**:

1. **AuthBloc busca usuário atualizado** após login Google
2. **LoginPage verifica isProfileComplete** e redireciona apropriadamente
3. **Router guard serve como backup** para prevenir bypass

---

## 🧪 TESTE DE VALIDAÇÃO

Após implementar a solução, testar:

1. ✅ Novo usuário Google → deve ir para `/complete-profile`
2. ✅ Usuário com perfil completo → deve ir para `/home`
3. ✅ Tentar acessar `/home` manualmente → deve ser bloqueado se perfil incompleto
4. ✅ Logs no console devem mostrar status correto

---

## 🔍 DEBUG: O QUE VERIFICAR AGORA

Para diagnosticar o problema atual:

### 1. Verificar Response do Backend

Abrir DevTools do navegador (F12) → Network → Filtrar `/api/auth/login/google`

**Verificar se o response inclui:**
```json
{
  "user": {
    "id": "...",
    "email": "...",
    "profile_completion_status": "incomplete"  // ← VERIFICAR ESTE CAMPO
  },
  "access_token": "...",
  "refresh_token": "..."
}
```

### 2. Verificar Logs do AuthBloc

Adicionar prints temporários no AuthBloc para ver o que está sendo recebido:

```dart
print('🔐 Login Google - User: ${authToken.user.email}');
print('🔐 Profile Status: ${authToken.user.profileCompletionStatus}');
```

### 3. Verificar Router Guard

Adicionar prints no router guard:

```dart
print('🔀 Router Guard - isAuthenticated: $isAuthenticated');
print('🔀 Router Guard - location: ${state.matchedLocation}');
print('🔀 Router Guard - user.isProfileComplete: ${user.isProfileComplete}');
```

---

## 📝 PRÓXIMOS PASSOS

1. [ ] Adicionar logs de debug conforme sugerido acima
2. [ ] Executar teste de login com Google
3. [ ] Verificar logs no console
4. [ ] Identificar onde o `profile_completion_status` está sendo perdido
5. [ ] Implementar a solução apropriada
