# .gitignore Atualizado - Registro de Alterações

## ✅ O que foi corrigido

O arquivo `.gitignore` foi atualizado para incluir todas as boas práticas de segurança e desenvolvimento Flutter.

---

## 🔒 Adições Importantes de Segurança

### Arquivos Sensíveis que NUNCA devem ser commitados:

```gitignore
# Variáveis de ambiente
*.env
.env*

# Certificados e chaves
*.key
*.keystore
*.jks
*.p12
*.pem
*.mobileprovision
*.certSigningRequest

# Arquivos de configuração do Google/Firebase
google-services.json          # Android Firebase config
GoogleService-Info.plist      # iOS Firebase config
firebase_options.dart          # Flutter Firebase config

# Arquivos de signing Android
/android/key.properties

# Secrets customizados
/lib/core/config/secrets.dart
```

**⚠️ IMPORTANTE:** Esses arquivos contêm:
- API Keys
- Certificados de assinatura
- Tokens de acesso
- Configurações sensíveis

Nunca devem ser commitados no repositório!

---

## 🔧 Arquivos Gerados (Build)

Adicionados arquivos que são gerados automaticamente:

```gitignore
# Arquivos gerados por build_runner
*.g.dart          # json_serializable, hive, etc.
*.freezed.dart    # freezed
*.gr.dart         # auto_route
*.config.dart     # injectable

# Plugins Flutter
.flutter-plugins
.flutter-plugins-dependencies

# Databases locais (Hive)
*.hive
*.lock
```

---

## 📱 iOS Específico

Adicionados padrões completos do iOS:

```gitignore
# Xcode
**/ios/**/xcuserdata
**/ios/**/DerivedData/
**/ios/**/Pods/

# Flutter iOS gerado
**/ios/Flutter/App.framework
**/ios/Flutter/Flutter.framework
**/ios/Flutter/Generated.xcconfig
**/ios/Flutter/ephemeral

# Runner gerado
**/ios/Runner/GeneratedPluginRegistrant.*
```

---

## 🌐 Web Específico

```gitignore
/web/flutter_bootstrap.js
```

---

## 📊 Cobertura de Testes

```gitignore
coverage/
*.lcov
```

---

## ✅ Verificação de Segurança

Executei verificação e **nenhum arquivo sensível foi encontrado** no repositório atual. ✅

---

## 🚨 Ação Necessária SE Você Já Commitou Arquivos Sensíveis

Se você já commitou algum arquivo sensível antes (como `.env`, `*.keystore`, etc.), você precisa:

### 1. Remover do histórico do Git

```bash
# Remover arquivo específico do histórico
git filter-branch --force --index-filter \
  "git rm --cached --ignore-unmatch caminho/para/arquivo-sensivel.env" \
  --prune-empty --tag-name-filter cat -- --all

# Forçar push (CUIDADO: reescreve histórico)
git push origin --force --all
```

### 2. Invalidar credenciais expostas

Se você commitou:
- **API Keys**: Regenere no console da API
- **Keystores**: Crie novos certificados
- **Tokens**: Revogue e crie novos

---

## 📋 Checklist Pré-Commit

Antes de fazer commit, sempre verifique:

- [ ] Nenhum arquivo `.env` está sendo commitado
- [ ] Nenhum arquivo `.keystore`, `.jks`, `.key` está sendo commitado
- [ ] Nenhum `google-services.json` ou `GoogleService-Info.plist`
- [ ] Nenhuma API key hardcoded no código
- [ ] Nenhum token de acesso no código

### Como verificar:

```bash
# Ver o que será commitado
git status

# Ver diff dos arquivos
git diff

# Ver arquivos staged
git diff --cached
```

---

## 🔐 Boas Práticas de Segurança

### 1. Use Variáveis de Ambiente

Crie arquivo `.env` (que está no .gitignore):

```env
# .env (NUNCA commitar!)
GOOGLE_MAPS_API_KEY=AIza...
BACKEND_API_URL=https://api.exemplo.com
```

Carregue com `flutter_dotenv`:

```dart
import 'package:flutter_dotenv/flutter_dotenv.dart';

await dotenv.load();
final apiKey = dotenv.env['GOOGLE_MAPS_API_KEY'];
```

### 2. Use Secrets do GitHub Actions

Para CI/CD, use GitHub Secrets:

```yaml
# .github/workflows/build.yml
env:
  API_KEY: ${{ secrets.API_KEY }}
```

### 3. Arquivo de Exemplo

Crie `.env.example` (pode commitar):

```env
# .env.example
GOOGLE_MAPS_API_KEY=sua_api_key_aqui
BACKEND_API_URL=https://api.exemplo.com
```

---

## 📂 Estrutura Recomendada para Secrets

```
lib/
  core/
    config/
      secrets.dart         # .gitignore ✅
      secrets.example.dart # pode commitar

.env                       # .gitignore ✅
.env.example              # pode commitar ✅
```

**secrets.example.dart:**
```dart
class Secrets {
  static const String googleMapsApiKey = 'YOUR_API_KEY_HERE';
  static const String backendUrl = 'https://api.example.com';
}
```

**secrets.dart (real):**
```dart
class Secrets {
  static const String googleMapsApiKey = 'AIzaSyD...real_key_here';
  static const String backendUrl = 'https://api.exemplo.com';
}
```

---

## 🔍 Verificações Automáticas

### Git Hooks (Recomendado)

Crie `.git/hooks/pre-commit`:

```bash
#!/bin/sh

# Verificar se há arquivos sensíveis sendo commitados
if git diff --cached --name-only | grep -E "\\.env$|\\.key$|\\.keystore$|google-services\\.json|GoogleService-Info\\.plist"; then
    echo "❌ ERRO: Tentando commitar arquivo sensível!"
    echo "Arquivos bloqueados:"
    git diff --cached --name-only | grep -E "\\.env$|\\.key$|\\.keystore$|google-services\\.json|GoogleService-Info\\.plist"
    exit 1
fi

echo "✅ Nenhum arquivo sensível detectado"
```

---

## 📚 Referências

- [Flutter Security Best Practices](https://flutter.dev/security)
- [Git Ignore Patterns](https://git-scm.com/docs/gitignore)
- [GitHub Secrets](https://docs.github.com/en/actions/security-guides/encrypted-secrets)

---

## ✅ Status Atual

- ✅ `.gitignore` atualizado com todas as regras de segurança
- ✅ Nenhum arquivo sensível encontrado no repositório
- ✅ Pronto para commits seguros

---

**Última atualização:** 2024-12-13
**Versão:** 1.1
