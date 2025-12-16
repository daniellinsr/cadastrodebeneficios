# .env QuickStart - Início Rápido

## ✅ O que já está pronto

1. ✅ Pacote `flutter_dotenv` instalado
2. ✅ Arquivo `.env` criado com valores iniciais
3. ✅ Arquivo `.env.example` criado como modelo
4. ✅ Classe `EnvConfig` criada
5. ✅ `.env` adicionado aos assets do pubspec.yaml
6. ✅ `.env` adicionado ao .gitignore

---

## 🚀 Próximo Passo: Atualizar o main.dart

Adicione estas linhas no seu `main.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:cadastro_beneficios/core/config/env_config.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ← ADICIONAR: Carregar .env
  await EnvConfig.load();

  // ← ADICIONAR: Validar configuração
  EnvConfig.validate();

  // ← ADICIONAR: Mostrar config em debug
  EnvConfig.printConfig();

  runApp(const MyApp());
}
```

---

## 💡 Como usar no código

### Backend API:
```dart
import 'package:cadastro_beneficios/core/config/env_config.dart';

final apiUrl = EnvConfig.backendApiUrl;  // http://localhost:3000
```

### Feature Flags:
```dart
if (EnvConfig.enableGoogleLogin) {
  // Mostrar botão Google Sign-In
}

if (EnvConfig.enableDebugLogs) {
  // Adicionar logger
}
```

### Ambiente:
```dart
if (EnvConfig.isDevelopment) {
  // Código de desenvolvimento
}

if (EnvConfig.isProduction) {
  // Código de produção
}
```

---

## 📝 Variáveis Disponíveis

| Variável | Como acessar |
|----------|--------------|
| URL da API | `EnvConfig.backendApiUrl` |
| Timeout da API | `EnvConfig.backendApiTimeout` |
| Google Maps Key | `EnvConfig.googleMapsApiKey` |
| Google Web Client ID | `EnvConfig.googleWebClientId` |
| Enable Google Login | `EnvConfig.enableGoogleLogin` |
| Enable Biometric | `EnvConfig.enableBiometricAuth` |
| Enable Location | `EnvConfig.enableLocationServices` |
| Enable Debug Logs | `EnvConfig.enableDebugLogs` |
| App Name | `EnvConfig.appName` |
| App Version | `EnvConfig.appVersion` |
| Environment | `EnvConfig.environment` |
| Is Development | `EnvConfig.isDevelopment` |
| Is Production | `EnvConfig.isProduction` |

---

## 🔧 Editar variáveis

Edite o arquivo `.env` na raiz do projeto:

```env
BACKEND_API_URL=http://localhost:3000
GOOGLE_MAPS_API_KEY=sua_chave_aqui
ENABLE_GOOGLE_LOGIN=true
ENABLE_DEBUG_LOGS=true
ENVIRONMENT=development
```

---

## 📚 Documentação Completa

Ver: [ENV_SETUP_GUIDE.md](./ENV_SETUP_GUIDE.md)

---

**Status:** ✅ Pronto para usar!
