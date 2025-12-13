# 🚀 Guia de Início Rápido

## 📖 Visão Geral

Bem-vindo ao projeto **Sistema de Cartão de Benefícios**! Este guia ajudará você a entender rapidamente a estrutura do projeto e por onde começar.

---

## 📂 Documentação Disponível

Você tem acesso a 3 documentos principais:

### 1. [PLANEJAMENTO_COMPLETO.md](PLANEJAMENTO_COMPLETO.md)
**O que contém:**
- 19 módulos detalhados do projeto
- Estrutura de pastas Flutter
- Dependências necessárias
- Cronograma estimado (7-10 meses)
- Prioridades e MVP

**Quando usar:**
- Para entender o escopo completo
- Para planejar sprints
- Para gerenciar tarefas

### 2. [BACKEND_API_SPECS.md](BACKEND_API_SPECS.md)
**O que contém:**
- Schema completo do PostgreSQL (todas as tabelas)
- Especificações de todas as APIs REST
- Autenticação e segurança
- Integrações (pagamento, WhatsApp, etc)
- Webhooks

**Quando usar:**
- Para desenvolver o backend
- Para integrar o Flutter com APIs
- Para entender fluxo de dados

### 3. [QUICK_START.md](QUICK_START.md) (este arquivo)
**O que contém:**
- Resumo executivo
- Ordem de implementação
- Passos práticos para começar

---

## 🎯 Resumo Executivo

### O Projeto
Sistema completo de gestão de benefícios com:
- **Frontend**: Flutter (Android, iOS, Web)
- **Backend**: APIs REST + PostgreSQL
- **Usuários**: Administradores e Beneficiários
- **Destaque**: Cartão virtual, múltiplas formas de pagamento, WhatsApp integrado

### Fluxo Principal do Usuário
```
Tela Inicial
  → Cadastro (8 etapas)
    → Verificação por SMS/WhatsApp
    → Escolha do Plano
    → Pagamento (Cartão/PIX/Débito)
    → Assinatura Digital
    → Confirmação
  → Área do Cliente
    → Cartão Digital
    → Gerenciar Dependentes
    → Pagamentos
    → Mapa de Parceiros
```

---

## 📋 Por Onde Começar?

### Opção 1: MVP Rápido (3-4 meses)
**Objetivo:** Lançar versão funcional básica

**Módulos Prioritários:**
1. ✅ **Módulo 1**: Setup do Projeto Flutter
2. ✅ **Módulo 2**: Design System Básico
3. ✅ **Módulo 3**: Autenticação (Email/Google)
4. ✅ **Módulo 4**: Tela Inicial
5. ✅ **Módulos 5-10**: Fluxo de Cadastro Completo
6. ✅ **Módulo 9**: Pagamento (apenas Cartão + PIX)
7. ✅ **Módulo 11**: Área do Cliente (básica)
   - Cartão Digital
   - Dados cadastrais
   - Lista de parceiros
8. ✅ **Módulo 18**: Deploy (apenas Web e Android)

**Features Adiadas para Versão 2.0:**
- Painel Admin completo (apenas básico)
- Débito em conta
- Analytics avançado
- iOS (se recursos limitados)

### Opção 2: Desenvolvimento Completo (7-10 meses)
**Objetivo:** Sistema robusto e completo

**Seguir ordem dos 19 módulos no [PLANEJAMENTO_COMPLETO.md](PLANEJAMENTO_COMPLETO.md)**

---

## 🛠️ Setup Inicial - Passo a Passo

### Pré-requisitos
```bash
# 1. Flutter SDK (stable channel)
flutter --version  # Deve ser >= 3.16.0

# 2. Dart SDK (incluído no Flutter)

# 3. IDE (VSCode ou Android Studio)
# - VSCode: Instalar extensões Flutter e Dart
# - Android Studio: Instalar plugins Flutter

# 4. Git
git --version

# 5. PostgreSQL (para backend)
psql --version  # >= 15.0
```

### Passo 1: Criar Projeto Flutter
```bash
# Navegar para pasta desejada
cd c:\Users\daniel.rodriguez\Documents\pessoal\cadastrodebeneficios

# Criar projeto Flutter
flutter create --org com.exemplo cadastro_beneficios

# Entrar na pasta
cd cadastro_beneficios

# Testar se está funcionando
flutter run -d chrome  # Para web
# ou
flutter run  # Para Android/iOS
```

### Passo 2: Configurar Estrutura de Pastas
```bash
# Dentro de lib/, criar estrutura:
mkdir -p lib/core/config
mkdir -p lib/core/constants
mkdir -p lib/core/errors
mkdir -p lib/core/network
mkdir -p lib/core/theme
mkdir -p lib/core/utils
mkdir -p lib/data/datasources
mkdir -p lib/data/models
mkdir -p lib/data/repositories
mkdir -p lib/domain/entities
mkdir -p lib/domain/repositories
mkdir -p lib/domain/usecases
mkdir -p lib/presentation/bloc
mkdir -p lib/presentation/pages
mkdir -p lib/presentation/widgets
```

### Passo 3: Adicionar Dependências Básicas
Editar `pubspec.yaml`:

```yaml
dependencies:
  flutter:
    sdk: flutter

  # State Management
  flutter_bloc: ^8.1.3
  equatable: ^2.0.5

  # Network
  dio: ^5.4.0
  retrofit: ^4.0.3
  pretty_dio_logger: ^1.3.1

  # Navigation
  go_router: ^13.0.0

  # UI
  flutter_svg: ^2.0.9
  cached_network_image: ^3.3.0

  # Forms
  flutter_form_builder: ^9.1.1
  form_builder_validators: ^9.1.0

  # Utils
  intl: ^0.18.1
  logger: ^2.0.2

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^3.0.0
```

```bash
# Instalar dependências
flutter pub get
```

### Passo 4: Criar Tema (Design System)
Criar arquivo `lib/core/theme/app_theme.dart`:

```dart
import 'package:flutter/material.dart';

class AppTheme {
  // Cores (Paleta Facebook)
  static const Color primaryBlue = Color(0xFF1877F2);
  static const Color white = Color(0xFFFFFFFF);
  static const Color darkGray = Color(0xFF1C1E21);
  static const Color lightGray = Color(0xFFF0F2F5);

  // Theme Light
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.light(
      primary: primaryBlue,
      onPrimary: white,
      surface: white,
      onSurface: darkGray,
      background: lightGray,
    ),
    scaffoldBackgroundColor: white,
    appBarTheme: AppBarTheme(
      backgroundColor: primaryBlue,
      foregroundColor: white,
      elevation: 0,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryBlue,
        foregroundColor: white,
        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: lightGray),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: primaryBlue, width: 2),
      ),
    ),
  );
}
```

### Passo 5: Criar Tela Inicial (Landing)
Criar arquivo `lib/presentation/pages/landing_page.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class LandingPage extends StatelessWidget {
  const LandingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo
              Icon(
                Icons.card_membership,
                size: 100,
                color: Theme.of(context).primaryColor,
              ),
              SizedBox(height: 32),

              // Mensagem de boas-vindas
              Text(
                'Bem-vindo ao Sistema de Benefícios',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 16),
              Text(
                'Facilitamos seu acesso a benefícios exclusivos em saúde, bem-estar e serviços essenciais.',
                style: TextStyle(fontSize: 16),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 48),

              // Botões
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => context.go('/login'),
                  child: Text('Já sou cadastrado'),
                ),
              ),
              SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => context.go('/register'),
                  child: Text('Cadastre-se'),
                ),
              ),
              SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => context.go('/partners'),
                  child: Text('Lista de Parceiros'),
                ),
              ),
            ],
          ),
        ),
      ),

      // Botão WhatsApp flutuante
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // Abrir WhatsApp
        },
        icon: Icon(Icons.chat),
        label: Text('WhatsApp'),
        backgroundColor: Color(0xFF25D366), // Verde WhatsApp
      ),
    );
  }
}
```

### Passo 6: Configurar Rotas
Criar arquivo `lib/core/router/app_router.dart`:

```dart
import 'package:go_router/go_router.dart';
import 'package:cadastro_beneficios/presentation/pages/landing_page.dart';

final appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => LandingPage(),
    ),
    // Adicionar outras rotas conforme necessário
  ],
);
```

### Passo 7: Atualizar main.dart
Editar `lib/main.dart`:

```dart
import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';
import 'core/router/app_router.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Sistema de Benefícios',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      routerConfig: appRouter,
    );
  }
}
```

### Passo 8: Rodar o App
```bash
# Web
flutter run -d chrome

# Android (com emulador ou device conectado)
flutter run

# iOS (apenas em Mac)
flutter run -d ios
```

---

## 🗃️ Setup do Backend (PostgreSQL)

### Opção 1: Local com Docker
```bash
# Criar docker-compose.yml na raiz do projeto
version: '3.8'
services:
  postgres:
    image: postgres:15
    environment:
      POSTGRES_USER: beneficios
      POSTGRES_PASSWORD: senha123
      POSTGRES_DB: cadastro_beneficios
    ports:
      - "5432:5432"
    volumes:
      - postgres_data:/var/lib/postgresql/data

volumes:
  postgres_data:

# Rodar
docker-compose up -d
```

### Opção 2: PostgreSQL Instalado Localmente
```bash
# Windows (após instalar PostgreSQL)
psql -U postgres

# Criar database
CREATE DATABASE cadastro_beneficios;
CREATE USER beneficios WITH PASSWORD 'senha123';
GRANT ALL PRIVILEGES ON DATABASE cadastro_beneficios TO beneficios;
```

### Criar Tabelas
Use os schemas SQL do arquivo [BACKEND_API_SPECS.md](BACKEND_API_SPECS.md) na seção "Banco de Dados PostgreSQL".

---

## 🔗 Próximos Passos Detalhados

### Semana 1-2: Fundação
- ✅ Setup do projeto Flutter (feito acima)
- [ ] Criar todos os componentes do Design System
- [ ] Implementar navegação completa
- [ ] Setup do backend (Node.js/Python/Go)
- [ ] Criar migrations do banco

### Semana 3-4: Autenticação
- [ ] Tela de login
- [ ] Login com Google
- [ ] Login com email/senha
- [ ] Recuperação de senha
- [ ] Armazenamento seguro de tokens

### Semana 5-8: Fluxo de Cadastro
- [ ] Etapa 1: Identificação inicial
- [ ] Etapa 2: Verificação por código
- [ ] Etapa 3: Endereço (CEP)
- [ ] Etapa 4: Dados pessoais
- [ ] Etapa 5: Dependentes
- [ ] Etapa 6: Escolha do plano

### Semana 9-12: Pagamento
- [ ] Integração com gateway
- [ ] Pagamento por cartão
- [ ] Pagamento por PIX
- [ ] Recorrência
- [ ] Webhooks

### Semana 13-16: Finalização e Área do Cliente
- [ ] Assinatura digital
- [ ] Confirmação
- [ ] Dashboard do cliente
- [ ] Cartão digital
- [ ] Mapa de parceiros

---

## 📚 Recursos Úteis

### Documentação Oficial
- [Flutter](https://flutter.dev/docs)
- [Dart](https://dart.dev/guides)
- [PostgreSQL](https://www.postgresql.org/docs/)

### Tutoriais Recomendados
- Flutter & Firebase: [Tutorial Completo](https://firebase.google.com/docs/flutter/setup)
- Clean Architecture Flutter: [Resocoder](https://resocoder.com/flutter-clean-architecture-tdd/)
- BLoC Pattern: [Documentação Oficial](https://bloclibrary.dev/)

### Comunidades
- [Flutter Brasil - Discord](https://discord.gg/flutter-brasil)
- [Stack Overflow - Flutter](https://stackoverflow.com/questions/tagged/flutter)

---

## 🎉 Conclusão

Agora você tem:
1. ✅ Planejamento completo em 19 módulos
2. ✅ Especificação completa do backend e APIs
3. ✅ Setup inicial do projeto Flutter funcionando
4. ✅ Tela inicial criada
5. ✅ Estrutura de pastas organizada
6. ✅ Tema configurado

**Próximo Passo Recomendado:**
Escolha entre MVP (Opção 1) ou Desenvolvimento Completo (Opção 2) e comece a desenvolver módulo por módulo seguindo o [PLANEJAMENTO_COMPLETO.md](PLANEJAMENTO_COMPLETO.md).

---

## 💬 Dúvidas?

Entre em contato ou abra uma issue no repositório.

**Vamos construir esse caso de sucesso juntos! 🚀**
