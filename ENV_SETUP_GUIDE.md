# Guia de Configuração: Variáveis de Ambiente (.env)

## 📋 O que foi criado

Sistema completo de gerenciamento de variáveis de ambiente usando `flutter_dotenv`.

### Arquivos Criados:

1. **`.env`** - Arquivo com variáveis reais (NÃO commitar)
2. **`.env.example`** - Arquivo modelo (pode commitar)
3. **`lib/core/config/env_config.dart`** - Classe para acessar as variáveis
4. **`pubspec.yaml`** - Adicionado `flutter_dotenv: ^5.1.0`

---

## 🚀 Como Usar

### 1. Configurar o arquivo .env

O arquivo `.env` já foi criado com valores iniciais. Edite conforme necessário:

```env
# Backend API
BACKEND_API_URL=http://localhost:3000
BACKEND_API_TIMEOUT=30000

# Google Services
GOOGLE_MAPS_API_KEY=
GOOGLE_WEB_CLIENT_ID=403775802042-dr9hvctbr6qfildd767us0o057m3iu3m.apps.googleusercontent.com

# Feature Flags
ENABLE_GOOGLE_LOGIN=true
ENABLE_BIOMETRIC_AUTH=true
ENABLE_LOCATION_SERVICES=true
ENABLE_DEBUG_LOGS=true

# App Configuration
APP_NAME=Sistema de Cartão de Benefícios
APP_VERSION=1.0.0
ENVIRONMENT=development
```

### 2. Inicializar no main.dart

Carregue as variáveis ANTES de iniciar o app:

```dart
import 'package:flutter/material.dart';
import 'package:cadastro_beneficios/core/config/env_config.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Carregar variáveis de ambiente
  await EnvConfig.load();

  // Validar variáveis obrigatórias
  EnvConfig.validate();

  // Imprimir configuração (apenas em debug)
  EnvConfig.printConfig();

  runApp(const MyApp());
}
```

### 3. Acessar as variáveis no código

Use a classe `EnvConfig` para acessar as variáveis:

```dart
import 'package:cadastro_beneficios/core/config/env_config.dart';

// Backend API
final apiUrl = EnvConfig.backendApiUrl;
final timeout = EnvConfig.backendApiTimeout;

// Google Services
final mapsKey = EnvConfig.googleMapsApiKey;
final webClientId = EnvConfig.googleWebClientId;

// Feature Flags
if (EnvConfig.enableGoogleLogin) {
  // Mostrar botão de login Google
}

if (EnvConfig.enableBiometricAuth) {
  // Habilitar autenticação biométrica
}

// App Info
final appName = EnvConfig.appName;
final version = EnvConfig.appVersion;

// Ambiente
if (EnvConfig.isDevelopment) {
  // Código específico de desenvolvimento
}

if (EnvConfig.isProduction) {
  // Código específico de produção
}
```

---

## 📱 Exemplo de Uso em DioClient

Atualize o `DioClient` para usar variáveis de ambiente:

```dart
import 'package:dio/dio.dart';
import 'package:cadastro_beneficios/core/config/env_config.dart';

class DioClient {
  late final Dio _dio;

  DioClient() {
    _dio = Dio(
      BaseOptions(
        baseUrl: EnvConfig.backendApiUrl,  // ← Usa .env
        connectTimeout: Duration(milliseconds: EnvConfig.backendApiTimeout),
        receiveTimeout: Duration(milliseconds: EnvConfig.backendApiTimeout),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    // Adicionar logger apenas em desenvolvimento
    if (EnvConfig.enableDebugLogs) {
      _dio.interceptors.add(LogInterceptor(
        requestBody: true,
        responseBody: true,
      ));
    }
  }

  Dio get instance => _dio;
}
```

---

## 🌍 Ambientes Diferentes

### Development (Desenvolvimento)

```env
BACKEND_API_URL=http://localhost:3000
ENABLE_DEBUG_LOGS=true
ENVIRONMENT=development
```

### Staging (Homologação)

Crie `.env.staging`:

```env
BACKEND_API_URL=https://api-staging.exemplo.com
ENABLE_DEBUG_LOGS=true
ENVIRONMENT=staging
```

### Production (Produção)

Crie `.env.production`:

```env
BACKEND_API_URL=https://api.exemplo.com
ENABLE_DEBUG_LOGS=false
ENVIRONMENT=production
```

**Carregar ambiente específico:**

```dart
// Desenvolvimento (padrão)
await dotenv.load(fileName: '.env');

// Staging
await dotenv.load(fileName: '.env.staging');

// Production
await dotenv.load(fileName: '.env.production');
```

---

## 🔐 Segurança

### ✅ O que PODE ser commitado:

- ✅ `.env.example` - Arquivo modelo sem valores reais
- ✅ `env_config.dart` - Classe de configuração
- ✅ `pubspec.yaml` - Dependências

### ❌ O que NUNCA deve ser commitado:

- ❌ `.env` - Arquivo com valores reais
- ❌ `.env.production` - Configuração de produção
- ❌ `.env.staging` - Configuração de staging

**Já está no .gitignore:**

```gitignore
*.env
.env*
```

---

## 🔑 Variáveis Disponíveis

### Backend API

| Variável | Tipo | Padrão | Descrição |
|----------|------|--------|-----------|
| `BACKEND_API_URL` | String | `http://localhost:3000` | URL base da API |
| `BACKEND_API_TIMEOUT` | int | `30000` | Timeout em ms |

**Acesso:**
```dart
EnvConfig.backendApiUrl
EnvConfig.backendApiTimeout
```

### Google Services

| Variável | Tipo | Padrão | Descrição |
|----------|------|--------|-----------|
| `GOOGLE_MAPS_API_KEY` | String | `''` | API Key do Google Maps |
| `GOOGLE_WEB_CLIENT_ID` | String | (configurado) | OAuth Web Client ID |

**Acesso:**
```dart
EnvConfig.googleMapsApiKey
EnvConfig.googleWebClientId
```

### Feature Flags

| Variável | Tipo | Padrão | Descrição |
|----------|------|--------|-----------|
| `ENABLE_GOOGLE_LOGIN` | bool | `false` | Habilita login Google |
| `ENABLE_BIOMETRIC_AUTH` | bool | `false` | Habilita biometria |
| `ENABLE_LOCATION_SERVICES` | bool | `false` | Habilita localização |
| `ENABLE_DEBUG_LOGS` | bool | `false` | Habilita logs debug |

**Acesso:**
```dart
EnvConfig.enableGoogleLogin
EnvConfig.enableBiometricAuth
EnvConfig.enableLocationServices
EnvConfig.enableDebugLogs
```

### App Configuration

| Variável | Tipo | Padrão | Descrição |
|----------|------|--------|-----------|
| `APP_NAME` | String | `Sistema de Cartão de Benefícios` | Nome do app |
| `APP_VERSION` | String | `1.0.0` | Versão do app |
| `ENVIRONMENT` | String | `development` | Ambiente atual |

**Acesso:**
```dart
EnvConfig.appName
EnvConfig.appVersion
EnvConfig.environment
EnvConfig.isDevelopment
EnvConfig.isStaging
EnvConfig.isProduction
```

---

## 🛠️ Métodos Úteis

### Validar Configuração

Valida se todas as variáveis obrigatórias estão configuradas:

```dart
try {
  EnvConfig.validate();
} catch (e) {
  print('Erro de configuração: $e');
  // Mostrar tela de erro ou usar valores padrão
}
```

### Imprimir Configuração

Imprime todas as configurações (apenas se `ENABLE_DEBUG_LOGS=true`):

```dart
EnvConfig.printConfig();
```

**Output:**
```
=== Environment Configuration ===
Environment: development
App Name: Sistema de Cartão de Benefícios
App Version: 1.0.0
Backend API URL: http://localhost:3000
Backend API Timeout: 30000ms
Google Maps API Key: NOT SET
Google Web Client ID: ***configured***
--- Feature Flags ---
Enable Google Login: true
Enable Biometric Auth: true
Enable Location Services: true
Enable Debug Logs: true
================================
```

---

## 📦 CI/CD (GitHub Actions)

### Criar secrets no GitHub

1. Vá em: `Settings` > `Secrets and variables` > `Actions`
2. Clique em `New repository secret`
3. Adicione cada variável:
   - `BACKEND_API_URL`
   - `GOOGLE_MAPS_API_KEY`
   - etc.

### Usar no workflow

```yaml
# .github/workflows/build.yml
name: Build

on: [push]

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2

      - name: Create .env file
        run: |
          echo "BACKEND_API_URL=${{ secrets.BACKEND_API_URL }}" >> .env
          echo "GOOGLE_MAPS_API_KEY=${{ secrets.GOOGLE_MAPS_API_KEY }}" >> .env
          echo "ENABLE_DEBUG_LOGS=false" >> .env
          echo "ENVIRONMENT=production" >> .env

      - name: Build app
        run: flutter build apk
```

---

## 🧪 Testes

### Mockar variáveis em testes

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() {
  setUp(() async {
    // Carregar .env de teste
    dotenv.testLoad(fileInput: '''
      BACKEND_API_URL=http://test-api.com
      ENABLE_DEBUG_LOGS=false
      ENVIRONMENT=test
    ''');
  });

  test('deve carregar configuração de teste', () {
    expect(EnvConfig.backendApiUrl, 'http://test-api.com');
    expect(EnvConfig.environment, 'test');
  });
}
```

---

## ✅ Checklist de Setup

- [x] Instalado `flutter_dotenv: ^5.1.0`
- [x] Criado `.env` com valores iniciais
- [x] Criado `.env.example` como modelo
- [x] Criado `lib/core/config/env_config.dart`
- [x] Adicionado `.env` em `pubspec.yaml` assets
- [x] Adicionado `*.env` no `.gitignore`
- [ ] Carregado `EnvConfig.load()` no `main.dart`
- [ ] Atualizado `DioClient` para usar `EnvConfig`
- [ ] Testado no app

---

## 📚 Referências

- [flutter_dotenv](https://pub.dev/packages/flutter_dotenv)
- [The Twelve-Factor App - Config](https://12factor.net/config)
- [Flutter Environment Variables](https://flutter.dev/docs/deployment/flavors)

---

**Última atualização:** 2024-12-13
**Status:** ✅ Configuração completa
