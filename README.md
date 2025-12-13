# 🏥 Sistema de Cartão de Benefícios

> Sistema completo de gerenciamento de benefícios com cartão virtual, desenvolvido em Flutter para Android, iOS e Web, com backend PostgreSQL.

---

## 📱 Sobre o Projeto

Aplicação multi-plataforma que facilita o acesso a benefícios exclusivos em saúde, bem-estar e serviços essenciais. O sistema oferece cartão virtual para beneficiários utilizarem em uma rede de parceiros.

### ✨ Principais Funcionalidades

- 🔐 **Autenticação Segura**: Login com Google ou email/senha com verificação por SMS/WhatsApp
- 📝 **Cadastro Completo**: Fluxo intuitivo de 8 etapas com validações
- 💳 **Cartão Virtual**: QR Code e dados digitais para uso imediato
- 💰 **Múltiplas Formas de Pagamento**: Cartão de crédito, PIX e débito em conta
- 👨‍👩‍👧‍👦 **Gestão de Dependentes**: Cadastro ilimitado de dependentes
- 🗺️ **Mapa de Parceiros**: Localização GPS de clínicas, farmácias e parceiros
- 📱 **WhatsApp Integrado**: Suporte e comunicação em todas as etapas
- 🔒 **LGPD Compliant**: Conformidade total com Lei Geral de Proteção de Dados

---

## 🎨 Design

Paleta de cores inspirada no Facebook para familiaridade e confiança:

| Cor | Uso | Hex |
|-----|-----|-----|
| 🔵 Azul Facebook | Cabeçalhos, botões primários, links | `#1877F2` |
| ⚪ Branco | Backgrounds | `#FFFFFF` |
| ⚫ Preto/Cinza Escuro | Textos | `#1C1E21` |
| ⚪ Cinza Claro | Divisórias, fundos secundários | `#F0F2F5` |

---

## 🏗️ Arquitetura

### Frontend
```
Flutter 3.16+
├── Clean Architecture
├── BLoC (State Management)
├── Go Router (Navigation)
└── Material Design 3
```

### Backend
```
PostgreSQL 15+
├── REST APIs (JSON)
├── JWT Authentication
├── OAuth 2.0
└── Webhooks
```

### Integrações
- 💳 **Pagamentos**: Stripe / PagSeguro / Mercado Pago
- 📱 **WhatsApp**: Business API / Twilio
- 📧 **Email**: SendGrid / AWS SES
- 📨 **SMS**: Twilio / AWS SNS
- 🗺️ **Mapas**: Google Maps API
- ☁️ **Storage**: AWS S3 / Firebase Storage

---

## 📚 Documentação

| Documento | Descrição |
|-----------|-----------|
| [📋 PLANEJAMENTO_COMPLETO.md](PLANEJAMENTO_COMPLETO.md) | 19 módulos detalhados, cronograma completo |
| [🔧 BACKEND_API_SPECS.md](BACKEND_API_SPECS.md) | Especificações completas de APIs e banco de dados |
| [🚀 QUICK_START.md](QUICK_START.md) | Guia rápido para começar o desenvolvimento |

---

## 🚀 Como Começar

### Pré-requisitos

```bash
# Flutter SDK
flutter --version  # >= 3.16.0

# PostgreSQL
psql --version     # >= 15.0

# Git
git --version
```

### Instalação Rápida

```bash
# 1. Clonar repositório
git clone <url-do-repositorio>
cd cadastrodebeneficios

# 2. Instalar dependências Flutter
cd cadastro_beneficios
flutter pub get

# 3. Rodar aplicação
flutter run -d chrome  # Web
flutter run            # Android/iOS
```

**Para setup completo, veja [QUICK_START.md](QUICK_START.md)**

---

## 📂 Estrutura do Projeto

```
cadastrodebeneficios/
├── 📄 README.md                    # Este arquivo
├── 📋 PLANEJAMENTO_COMPLETO.md     # Planejamento detalhado
├── 🔧 BACKEND_API_SPECS.md         # Specs do backend
├── 🚀 QUICK_START.md               # Guia de início
│
├── cadastro_beneficios/            # App Flutter
│   ├── lib/
│   │   ├── core/
│   │   │   ├── config/
│   │   │   ├── constants/
│   │   │   ├── errors/
│   │   │   ├── network/
│   │   │   ├── theme/
│   │   │   └── utils/
│   │   ├── data/
│   │   │   ├── datasources/
│   │   │   ├── models/
│   │   │   └── repositories/
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   ├── repositories/
│   │   │   └── usecases/
│   │   ├── presentation/
│   │   │   ├── bloc/
│   │   │   ├── pages/
│   │   │   └── widgets/
│   │   └── main.dart
│   ├── test/
│   ├── pubspec.yaml
│   └── ...
│
└── backend/                        # APIs e Banco de Dados
    ├── src/
    ├── migrations/
    ├── config/
    └── ...
```

---

## 🎯 Roadmap

### Fase 1: MVP (3-4 meses)
- [x] Planejamento completo
- [x] Documentação de APIs
- [ ] Setup inicial Flutter
- [ ] Autenticação
- [ ] Fluxo de cadastro
- [ ] Pagamento (Cartão + PIX)
- [ ] Área do cliente básica
- [ ] Deploy Web + Android

### Fase 2: Versão 1.0 (7-10 meses)
- [ ] Painel administrativo
- [ ] Todas as integrações
- [ ] iOS
- [ ] Testes completos
- [ ] Documentação de usuário
- [ ] Deploy completo

### Fase 3: Versão 2.0
- [ ] Analytics avançado
- [ ] Gamificação
- [ ] Programa de indicação
- [ ] App para parceiros
- [ ] Notificações push

---

## 👥 Perfis de Usuário

### 1. Administrador
- Dashboard com métricas
- Gestão de usuários
- Gestão de planos
- Gestão de parceiros
- Relatórios financeiros
- Central de comunicação

### 2. Beneficiário
- Cartão digital com QR Code
- Gerenciamento de dependentes
- Histórico de pagamentos
- Mapa de parceiros
- Benefícios disponíveis
- Suporte via WhatsApp

---

## 📊 Fluxo de Cadastro

```
Tela Inicial
    ↓
┌───────────────┐
│   Escolha     │
└───────┬───────┘
        │
    ┌───┴───┐
    │       │       │
    ↓       ↓       ↓
Login  Cadastrar  Parceiros
    │       │
    │   Identificação
    │       ↓
    │   Verificação
    │       ↓
    │   Endereço
    │       ↓
    │   Dados Pessoais
    │       ↓
    │   Dependentes
    │       ↓
    │   Plano
    │       ↓
    │   Pagamento
    │       ↓
    │   Assinatura
    │       ↓
    └──→ Área do Cliente
```

---

## 🔒 Segurança

- ✅ HTTPS/TLS obrigatório
- ✅ JWT com expiração curta
- ✅ Refresh tokens seguros
- ✅ Passwords hasheados (bcrypt/argon2)
- ✅ Rate limiting
- ✅ Validação de entrada
- ✅ SQL injection prevention
- ✅ XSS prevention
- ✅ PCI-DSS compliance (pagamentos)
- ✅ LGPD compliance
- ✅ Auditoria completa

---

## 🧪 Testes

```bash
# Testes unitários
flutter test

# Testes de integração
flutter test integration_test

# Cobertura
flutter test --coverage

# Ver cobertura
genhtml coverage/lcov.info -o coverage/html
open coverage/html/index.html
```

---

## 📦 Deploy

### Web
```bash
flutter build web --release
# Deploy para Firebase Hosting, Vercel, ou Netlify
```

### Android
```bash
flutter build appbundle --release
# Upload para Google Play Console
```

### iOS
```bash
flutter build ipa --release
# Upload para App Store Connect
```

---

## 🛠️ Tecnologias Utilizadas

### Frontend
- Flutter 3.16+
- Dart 3.0+
- flutter_bloc
- go_router
- dio
- hive
- google_maps_flutter
- firebase

### Backend
- Node.js / Python / Go (a definir)
- PostgreSQL 15+
- Redis
- RabbitMQ / AWS SQS
- Docker

### DevOps
- Git / GitHub
- Docker / Docker Compose
- CI/CD (GitHub Actions)
- AWS / GCP / Azure (a definir)

---

## 📈 Métricas de Qualidade

- 🎯 Cobertura de testes: > 80%
- ⚡ Performance: < 300ms p95
- 📱 Responsividade: 100%
- ♿ Acessibilidade: WCAG 2.1 AA
- 🔒 Segurança: OWASP Top 10

---

## 🤝 Contribuindo

Contribuições são bem-vindas! Por favor:

1. Fork o projeto
2. Crie uma branch para sua feature (`git checkout -b feature/AmazingFeature`)
3. Commit suas mudanças (`git commit -m 'Add some AmazingFeature'`)
4. Push para a branch (`git push origin feature/AmazingFeature`)
5. Abra um Pull Request

---

## 📝 Licença

Este projeto está sob a licença MIT. Veja o arquivo [LICENSE](LICENSE) para mais detalhes.

---

## 📞 Contato

**Equipe de Desenvolvimento**
- 📧 Email: contato@exemplo.com
- 💬 WhatsApp: +55 (61) 99999-9999

---

## 🎉 Agradecimentos

Este projeto foi planejado e desenvolvido com o objetivo de criar um caso de sucesso na gestão de benefícios. Obrigado por fazer parte dessa jornada!

---

**Feito com ❤️ e Flutter**
