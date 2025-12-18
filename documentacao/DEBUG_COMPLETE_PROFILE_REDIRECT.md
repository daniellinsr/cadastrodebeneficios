# 🔍 Debug: Redirecionamento após Completar Perfil

**Data:** 2025-12-18
**Status:** 🔧 **EM DEBUG**

---

## 🎯 PROBLEMA REPORTADO

Após completar o perfil com sucesso, o usuário **não está sendo redirecionado** para `/home`.

### Comportamento Observado

```
✅ Requisição PUT /api/v1/auth/profile/complete - Status 200 OK
✅ Response: { "profile_completion_status": "complete" }
❌ Nenhum redirecionamento
❌ Usuário permanece na página /complete-profile
```

---

## 🔧 MODIFICAÇÕES PARA DEBUG

### 1. Adicionado Logs em CompleteProfilePage

**Arquivo:** `lib/presentation/pages/complete_profile_page.dart`

```dart
(user) {
  // Atualizar o AuthBloc com o novo usuário (perfil completo)
  if (mounted) {
    debugPrint('✅ Perfil completado com sucesso! Atualizando AuthBloc...');
    context.read<AuthBloc>().add(const AuthUserUpdated());

    // Aguardar um momento para o estado ser atualizado
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        debugPrint('→ Redirecionando para /home...');
        context.go('/home');
      }
    });
  }
},
```

**O que verificar:**
- ✅ Log `✅ Perfil completado com sucesso! Atualizando AuthBloc...` aparece?
- ✅ Log `→ Redirecionando para /home...` aparece após 300ms?

### 2. Adicionado Logs em AuthBloc

**Arquivo:** `lib/presentation/bloc/auth/auth_bloc.dart`

Adicionado import:
```dart
import 'package:flutter/foundation.dart';
```

Handler modificado:
```dart
Future<void> _onUserUpdated(
  AuthUserUpdated event,
  Emitter<AuthState> emit,
) async {
  debugPrint('🔄 [AuthBloc] AuthUserUpdated disparado');
  debugPrint('🔍 [AuthBloc] Buscando dados do usuário atualizado...');

  final result = await getCurrentUserUseCase();

  result.fold(
    (failure) {
      debugPrint('❌ [AuthBloc] Erro ao buscar usuário: ${failure.message}');
      emit(AuthError(
        message: failure.message,
        code: failure.code,
      ));
    },
    (user) {
      debugPrint('✅ [AuthBloc] Usuário carregado: ${user.email}');
      debugPrint('   isProfileComplete: ${user.isProfileComplete}');
      debugPrint('   profileCompletionStatus: ${user.profileCompletionStatus}');
      debugPrint('📤 [AuthBloc] Emitindo AuthAuthenticated...');
      emit(AuthAuthenticated(user: user));
    },
  );
}
```

**O que verificar:**
- ✅ Log `🔄 [AuthBloc] AuthUserUpdated disparado` aparece?
- ✅ Log `🔍 [AuthBloc] Buscando dados do usuário atualizado...` aparece?
- ✅ Log `✅ [AuthBloc] Usuário carregado` com `isProfileComplete: true`?
- ✅ Log `📤 [AuthBloc] Emitindo AuthAuthenticated...` aparece?

---

## 🧪 COMO TESTAR

### 1. Reiniciar Flutter

**IMPORTANTE:** Você DEVE reiniciar o Flutter para aplicar as mudanças:

```bash
# Parar (Ctrl+C ou q)
flutter run -d chrome
```

### 2. Fazer Login com Google

1. Acesse a aplicação
2. Clique em "Cadastre-se Grátis"
3. Clique em "Cadastrar com Google"
4. Faça login com sua conta Google

### 3. Completar Perfil

1. Preencha o formulário de completar perfil:
   - CPF
   - Telefone
   - Data de Nascimento
   - CEP (pode usar busca automática)
   - Endereço completo
2. Clique em "Completar Cadastro"
3. **OBSERVAR O CONSOLE**

### 4. Logs Esperados (Sucesso)

```
✅ Perfil completado com sucesso! Atualizando AuthBloc...
🔄 [AuthBloc] AuthUserUpdated disparado
🔍 [AuthBloc] Buscando dados do usuário atualizado...
⚠️ Storage não disponível (web): usando autenticação em memória
✅ [AuthBloc] Usuário carregado: daniellinsr@gmail.com
   isProfileComplete: true
   profileCompletionStatus: complete
📤 [AuthBloc] Emitindo AuthAuthenticated...
→ Redirecionando para /home...
```

### 5. Possíveis Cenários de Erro

#### Cenário A: Nenhum Log Aparece
**Possível causa:** O callback de sucesso não está sendo executado
**Debug:** Verificar se `result.fold` está indo para o lado de erro (failure)

#### Cenário B: Logs do AuthBloc Não Aparecem
**Possível causa:** Evento `AuthUserUpdated` não está sendo disparado
**Debug:** Verificar se `context.read<AuthBloc>()` está encontrando o BLoC

#### Cenário C: AuthBloc Retorna Erro
**Possível causa:** Erro ao buscar usuário atualizado do backend
**Debug:** Ver mensagem de erro no log `❌ [AuthBloc] Erro ao buscar usuário`

#### Cenário D: isProfileComplete = false
**Possível causa:** Backend não atualizou o status ou cache local está desatualizado
**Debug:** Verificar resposta do backend e cache

#### Cenário E: Logs Aparecem mas Não Redireciona
**Possível causa:** Router está bloqueando navegação
**Debug:** Verificar logs do router e regras de redirect

---

## 📋 CHECKLIST DE VERIFICAÇÃO

Quando você testar, marque os itens que funcionaram:

- [ ] Requisição PUT retorna 200 OK
- [ ] Response contém `"profile_completion_status": "complete"`
- [ ] Log `✅ Perfil completado com sucesso! Atualizando AuthBloc...` aparece
- [ ] Log `🔄 [AuthBloc] AuthUserUpdated disparado` aparece
- [ ] Log `🔍 [AuthBloc] Buscando dados do usuário atualizado...` aparece
- [ ] Log `✅ [AuthBloc] Usuário carregado` aparece
- [ ] `isProfileComplete: true` aparece no log
- [ ] `profileCompletionStatus: complete` aparece no log
- [ ] Log `📤 [AuthBloc] Emitindo AuthAuthenticated...` aparece
- [ ] Log `→ Redirecionando para /home...` aparece
- [ ] Navegação para /home ocorre
- [ ] Página /home é exibida

---

## 🔍 PRÓXIMOS PASSOS

### Se Todos os Logs Aparecem mas Não Redireciona

Verificar:
1. Router está interceptando navegação?
2. Router detecta perfil completo corretamente?
3. Há algum erro silencioso no router?

### Se AuthBloc Retorna isProfileComplete = false

Verificar:
1. Backend está salvando corretamente?
2. GET /me retorna dados atualizados?
3. Cache local está sendo atualizado?

### Se Nenhum Log Aparece

Verificar:
1. `result.fold` está indo para lado de erro?
2. `completeProfile` no repository está retornando erro?
3. Há exceção sendo capturada no try-catch?

---

## 📝 ARQUIVOS MODIFICADOS

1. ✅ `lib/presentation/pages/complete_profile_page.dart`
   - Adicionado logs de debug no callback de sucesso

2. ✅ `lib/presentation/bloc/auth/auth_bloc.dart`
   - Adicionado import `package:flutter/foundation.dart`
   - Adicionado logs detalhados em `_onUserUpdated`

---

**Implementado em:** 2025-12-18
**Status:** 🔧 AGUARDANDO TESTE
**Próximo passo:** Reiniciar Flutter e testar fluxo completo com observação dos logs!
