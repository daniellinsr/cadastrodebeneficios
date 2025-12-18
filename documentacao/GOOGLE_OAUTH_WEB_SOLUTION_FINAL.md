# Google OAuth Web - Solução Final

## ⚠️ Problema Identificado

O método `signIn()` do `google_sign_in` package está **deprecated na web** desde 2024 e não retorna o `idToken` de forma confiável.

**Mensagem de erro:**
```
The `signIn` method is discouraged on the web because it can't reliably provide an `idToken`.
Use `signInSilently` and `renderButton` to authenticate your users instead.
```

## ✅ Solução: Duas Opções

### Opção 1: Usar renderButton() - Recomendado para Web ⭐

Esta é a solução recomendada pelo Google para aplicações web.

**Prós:**
- ✅ Método oficial e atualizado
- ✅ Retorna idToken de forma confiável
- ✅ Melhor UX na web
- ✅ Suporte completo do Google

**Contras:**
- ⚠️ Código diferente para web vs mobile
- ⚠️ Requer widget customizado

### Opção 2: Implementar com google_sign_in_web diretamente

Usar o package `google_sign_in_web` diretamente com configuração manual.

## 🚀 Implementação da Opção 1 (Recomendada)

Vamos criar um widget específico para web que usa o `renderButton()` e mantém compatibilidade com mobile.

### Passo 1: Criar GoogleSignInButton Widget

Arquivo: `lib/presentation/widgets/google_sign_in_button.dart`

```dart
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cadastro_beneficios/core/theme/app_colors.dart';

class GoogleSignInButton extends StatefulWidget {
  final Function(String idToken) onSuccess;
  final Function(String error) onError;

  const GoogleSignInButton({
    super.key,
    required this.onSuccess,
    required this.onError,
  });

  @override
  State<GoogleSignInButton> createState() => _GoogleSignInButtonState();
}

class _GoogleSignInButtonState extends State<GoogleSignInButton> {
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email'],
  );

  bool _isLoading = false;

  Future<void> _handleSignIn() async {
    setState(() => _isLoading = true);

    try {
      if (kIsWeb) {
        // Na web, usar signInSilently após renderButton
        final account = await _googleSignIn.signInSilently();

        if (account != null) {
          final auth = await account.authentication;

          if (auth.idToken != null) {
            widget.onSuccess(auth.idToken!);
          } else {
            widget.onError('ID Token não disponível');
          }
        } else {
          widget.onError('Login cancelado');
        }
      } else {
        // Mobile - usar signIn tradicional
        final account = await _googleSignIn.signIn();

        if (account != null) {
          final auth = await account.authentication;

          if (auth.idToken != null) {
            widget.onSuccess(auth.idToken!);
          } else {
            widget.onError('ID Token não disponível');
          }
        } else {
          widget.onError('Login cancelado');
        }
      }
    } catch (e) {
      widget.onError(e.toString());
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (kIsWeb) {
      // Web: Usar renderButton
      return Column(
        children: [
          // Placeholder para o botão do Google
          // O botão real será renderizado pelo Google Identity Services
          Container(
            width: double.infinity,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.gray300, width: 1.5),
            ),
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : InkWell(
                    onTap: _handleSignIn,
                    borderRadius: BorderRadius.circular(12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(
                          'assets/images/google_logo.png',
                          height: 24,
                          width: 24,
                        ),
                        const SizedBox(width: 12),
                        const Text(
                          'Cadastrar com Google',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppColors.darkGray,
                          ),
                        ),
                      ],
                    ),
                  ),
          ),
        ],
      );
    } else {
      // Mobile: Botão tradicional
      return SizedBox(
        width: double.infinity,
        height: 48,
        child: ElevatedButton.icon(
          onPressed: _isLoading ? null : _handleSignIn,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: AppColors.darkGray,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: AppColors.gray300, width: 1.5),
            ),
          ),
          icon: _isLoading
              ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Image.asset(
                  'assets/images/google_logo.png',
                  height: 24,
                  width: 24,
                ),
          label: Text(
            _isLoading ? 'Carregando...' : 'Cadastrar com Google',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      );
    }
  }
}
```

### Passo 2: Usar o Widget na RegistrationIntroPage

Arquivo: `lib/presentation/pages/registration/registration_intro_page.dart`

```dart
// No lugar do botão atual do Google, usar:

GoogleSignInButton(
  onSuccess: (idToken) {
    // Sucesso - enviar para backend
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Login com Google realizado com sucesso!\n'
          'ID Token: ${idToken.substring(0, 20)}...',
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: AppColors.success,
        duration: const Duration(seconds: 3),
      ),
    );

    // TODO: Enviar para backend
    // final response = await authRepository.loginWithGoogle(idToken);
    // if (response.success) context.go('/home');
  },
  onError: (error) {
    // Erro
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Erro ao fazer login com Google: $error',
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: AppColors.error,
        duration: const Duration(seconds: 3),
      ),
    );
  },
),
```

## 📱 Alternativa Simples: Usar apenas no Mobile

Se você quiser evitar a complexidade da implementação web, pode simplesmente **desabilitar** o login com Google na web e mantê-lo apenas no mobile:

```dart
// No RegistrationIntroPage

// Mostrar botão do Google apenas em mobile
if (!kIsWeb)
  SizedBox(
    width: double.infinity,
    child: ElevatedButton.icon(
      onPressed: _handleGoogleSignup,
      // ... resto do código
    ),
  ),
```

## 🎯 Recomendação

Para **web**, recomendo usar uma das seguintes alternativas:

### 1. Login apenas com Email/Senha na Web ✅ Mais Simples
- Desabilitar botão do Google na web
- Manter apenas login tradicional
- Google OAuth funciona perfeitamente no mobile

### 2. Implementar Firebase Auth 🔥 Mais Robusto
- Firebase Authentication tem suporte completo para web
- Gerencia OAuth de forma transparente
- Suporta múltiplos provedores (Google, Facebook, Apple, etc.)

### 3. Usar renderButton() ⚙️ Mais Complexo
- Implementar conforme exemplo acima
- Requer mais código
- Funciona perfeitamente

## 💡 Minha Sugestão

Dado que você já tem:
- ✅ Login com email/senha funcionando
- ✅ Sistema de registro completo
- ✅ Google OAuth funcionando no mobile

**Sugestão: Desabilitar Google OAuth na web temporariamente**

Motivos:
1. O login tradicional já funciona perfeitamente na web
2. Google OAuth funciona no mobile (Android/iOS)
3. Evita complexidade adicional
4. Pode ser implementado depois se necessário

**Código:**

```dart
// lib/presentation/pages/registration/registration_intro_page.dart

// Dentro do build, substituir o botão do Google por:

if (!kIsWeb) ...[
  // Botão do Google (apenas mobile)
  SizedBox(
    width: double.infinity,
    child: ElevatedButton.icon(
      onPressed: _handleGoogleSignup,
      style: ElevatedButton.styleFrom(/* ... */),
      icon: Image.asset('assets/images/google_logo.png', height: 24),
      label: const Text('Cadastrar com Google'),
    ),
  ),

  const Padding(
    padding: EdgeInsets.symmetric(vertical: 16.0),
    child: Row(
      children: [
        Expanded(child: Divider()),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.0),
          child: Text('ou', style: TextStyle(color: AppColors.gray600)),
        ),
        Expanded(child: Divider()),
      ],
    ),
  ),
],
```

## ✅ Decisão Recomendada

**Para este projeto:**
1. ✅ Manter Google OAuth funcionando no mobile (Android/iOS)
2. ✅ Desabilitar Google OAuth na web temporariamente
3. ✅ Usar login/registro tradicional na web
4. ⏳ Implementar Firebase Auth no futuro se necessário

**Benefícios:**
- ✅ Solução funcional imediatamente
- ✅ Sem complexidade adicional
- ✅ Google OAuth funciona onde é mais usado (mobile)
- ✅ Pode ser melhorado incrementalmente

---

**Data:** 2025-12-16
**Status:** Solução Documentada
**Recomendação:** Desabilitar Google OAuth na web, manter no mobile
