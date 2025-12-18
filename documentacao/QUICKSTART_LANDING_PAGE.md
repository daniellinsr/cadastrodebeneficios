# 🚀 Guia Rápido - Landing Page e Navegação

**Como testar tudo que foi implementado em 5 minutos**

---

## ⚡ Início Rápido

### 1️⃣ Instalar Dependências (se ainda não instalou)

```bash
flutter pub get
```

### 2️⃣ Executar o App

```bash
flutter run
```

**Escolha a plataforma:**
- `1` para Android
- `2` para iOS
- `3` para Chrome (web)
- `4` para Windows

---

## 🎬 O Que Você Verá

### 1. Splash Screen (2 segundos)

✅ Logo animado com efeito de escala
✅ Título "Cadastro de Benefícios" com fade-in
✅ Loading indicator
✅ Redirecionamento automático

**Onde:** Primeira tela ao abrir o app

---

### 2. Landing Page (Tela Inicial)

✅ Hero section com animação
✅ 4 cards de funcionalidades (Saúde, Bem-estar, Compras, Alimentação)
✅ 3 benefícios (Digital, Seguro, Economia)
✅ Call-to-action com gradiente
✅ Footer completo
✅ Botão flutuante do WhatsApp

**Navegação disponível:**
- **"Começar agora"** → Vai para `/register`
- **"Fazer login"** → Vai para `/login`
- **Logo no header** → Volta para `/`

---

### 3. Responsividade

**Teste redimensionando a janela:**

| Tamanho | Layout |
|---------|--------|
| < 600px | Mobile (1 coluna) |
| 600-1024px | Tablet (2 colunas) |
| > 1024px | Desktop (3+ colunas) |

---

## 🧪 Testar Funcionalidades

### ✅ 1. Animações de Entrada

**Como testar:**
1. Abra o app
2. Observe o splash screen
3. Veja a landing page carregar com animações
4. Role a página para baixo

**O que esperar:**
- Título desce com fade (FadeInDown)
- Subtítulo sobe com fade (FadeInUp)
- Botões aparecem em sequência
- Cards animam ao aparecer

---

### ✅ 2. Navegação (GoRouter)

**Como testar:**

```dart
// Teste 1: Clicar em "Começar agora"
1. Landing Page → Botão "Começar agora"
2. Deve ir para /register

// Teste 2: Clicar em "Fazer login"
1. Landing Page → Botão "Fazer login"
2. Deve ir para /login

// Teste 3: Voltar com logo
1. Qualquer página → Clicar no logo
2. Deve voltar para landing page
```

---

### ✅ 3. Route Guards (Proteção de Rotas)

**Como testar:**

```bash
# Teste 1: Acessar rota protegida SEM login
1. Abrir app (não logado)
2. Tentar acessar /home manualmente
3. Deve redirecionar para /login

# Teste 2: Fazer login e tentar acessar /login
1. Fazer login (salvar token)
2. Tentar acessar /login
3. Deve redirecionar para /home
```

**Para simular login:**
```dart
// Use o TokenService para salvar um token de teste
final tokenService = TokenService();
await tokenService.saveToken('test_token_123');
```

---

### ✅ 4. Deep Linking

#### Android (usando ADB)

```bash
# Teste 1: Custom scheme
adb shell am start -W -a android.intent.action.VIEW \
  -d "cadastrobeneficios://login" \
  com.example.cadastro_beneficios

# Teste 2: HTTPS
adb shell am start -W -a android.intent.action.VIEW \
  -d "https://cadastrobeneficios.com/register" \
  com.example.cadastro_beneficios
```

#### iOS (Simulador)

```bash
# Custom scheme
xcrun simctl openurl booted "cadastrobeneficios://login"
```

#### Web (navegador)

```bash
# Abra no navegador
http://localhost:PORT/#/login
http://localhost:PORT/#/register
```

---

### ✅ 5. Splash Screen

**Como testar:**

1. **Feche o app completamente**
2. **Abra novamente**
3. **Observe:**
   - Logo aparece com animação de escala
   - Título e subtítulo fazem fade-in
   - Loading indicator aparece
   - Após 2 segundos, redireciona

**Para testar redirecionamento:**

```dart
// Sem token → vai para landing page
// Com token → vai para /home
```

---

## 🎯 Testes Rápidos (Checklist)

Marque cada item conforme testa:

### Splash Screen
- [ ] Logo aparece com animação
- [ ] Título faz fade-in
- [ ] Loading indicator aparece
- [ ] Redireciona após 2 segundos
- [ ] Vai para landing page (sem login)

### Landing Page
- [ ] Hero section com animação
- [ ] 4 cards de funcionalidades
- [ ] 3 benefícios
- [ ] Botão "Começar agora" funciona
- [ ] Botão "Fazer login" funciona
- [ ] WhatsApp button visível
- [ ] Footer completo

### Responsividade
- [ ] Mobile (< 600px) - 1 coluna
- [ ] Tablet (600-1024px) - 2 colunas
- [ ] Desktop (> 1024px) - layout desktop
- [ ] Scroll funciona em todos os tamanhos

### Navegação
- [ ] Rota `/splash` funciona
- [ ] Rota `/` (landing) funciona
- [ ] Rota `/login` funciona
- [ ] Rota `/register` funciona
- [ ] Logo redireciona para `/`
- [ ] Route guards funcionam

### Deep Linking (Android)
- [ ] Custom scheme funciona
- [ ] HTTPS scheme funciona
- [ ] Abre a rota correta

### Animações
- [ ] FadeInDown no título
- [ ] FadeInUp nos botões
- [ ] Cards animam ao aparecer
- [ ] Transições suaves

---

## 🐛 Troubleshooting

### Problema: Splash screen não aparece

**Solução:**
```bash
# Verificar se a rota inicial está correta
# Em app_router.dart:
initialLocation: '/splash'  ← Deve ser /splash
```

### Problema: Animações não funcionam

**Solução:**
```bash
# Verificar se o pacote foi instalado
flutter pub get

# Verificar importação
import 'package:animate_do/animate_do.dart';
```

### Problema: Deep linking não funciona

**Solução Android:**
```bash
# Rebuild do app após modificar AndroidManifest.xml
flutter clean
flutter run
```

**Solução iOS:**
```bash
# Rebuild após modificar Info.plist
cd ios
pod install
cd ..
flutter run
```

### Problema: Route guards não funcionam

**Solução:**
```dart
// Verificar se TokenService está funcionando
final hasToken = await TokenService().hasToken();
print('Has token: $hasToken');  // Debug
```

---

## 📱 Testando em Dispositivo Real

### Android

```bash
# 1. Conectar dispositivo USB
# 2. Habilitar USB debugging
# 3. Executar
flutter run
```

### iOS

```bash
# 1. Conectar iPhone
# 2. Confiar no computador
# 3. Executar
flutter run
```

### Web

```bash
flutter run -d chrome
```

---

## 🎨 Customizar Cores/Textos

### Mudar Cor do Acento

**Arquivo:** `lib/core/theme/app_colors.dart`

```dart
static const Color accentOrange = Color(0xFFFF6B35);  // ← Altere aqui
```

### Mudar Textos da Landing Page

**Arquivo:** `lib/presentation/pages/landing_page_new.dart`

```dart
// Hero section (linha ~140)
'Seu Cartão de Benefícios Digital'  // Título
'Acesse descontos exclusivos...'     // Subtítulo
```

### Mudar Tempo do Splash Screen

**Arquivo:** `lib/presentation/pages/splash_screen.dart`

```dart
// Linha ~53
await Future.delayed(const Duration(seconds: 2));  // ← Altere aqui
```

---

## 📊 Métricas de Performance

Execute e observe:

```bash
flutter run --profile

# Para web
flutter run -d chrome --profile
```

**Valores esperados:**
- Splash screen: < 100ms para renderizar
- Landing page: < 200ms para primeira renderização
- Animações: 60 FPS constante
- Navegação: < 50ms entre rotas

---

## 🎉 Pronto!

Se todos os itens do checklist estão marcados, **tudo está funcionando perfeitamente!** 🚀

---

**Documentação completa:** [LANDING_PAGE_IMPLEMENTATION.md](LANDING_PAGE_IMPLEMENTATION.md)

**Dúvidas?** Verifique os logs do Flutter:
```bash
flutter logs
```
