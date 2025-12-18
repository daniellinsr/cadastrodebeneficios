# 🔧 Backend e Especificações de API

## 📋 Índice
1. [Arquitetura do Backend](#arquitetura-do-backend)
2. [Banco de Dados PostgreSQL](#banco-de-dados-postgresql)
3. [Especificações de API REST](#especificações-de-api-rest)
4. [Autenticação e Segurança](#autenticação-e-segurança)
5. [Integrações](#integrações)
6. [Webhooks](#webhooks)
7. [Monitoramento](#monitoramento)

---

## 🏗️ Arquitetura do Backend

### Stack Tecnológico Recomendado
```
Backend Framework: Node.js (NestJS) ou Python (FastAPI) ou Go
Database: PostgreSQL 15+
Cache: Redis
Queue: RabbitMQ ou AWS SQS
Storage: AWS S3 ou Google Cloud Storage
```

### Princípios Arquiteturais
- **REST JSON**: APIs stateless
- **Idempotência**: Operações críticas com `Idempotency-Key`
- **Versionamento**: Prefixo `/v1` em todas as rotas
- **Correlação**: Header `X-Request-Id` para rastreamento
- **OAuth 2.0/OIDC**: Autenticação com JWT
- **LGPD Compliant**: Mascaramento, consentimentos, retenção

### Estrutura de Microserviços (Opcional)
```
services/
├── auth-service/          # Autenticação e autorização
├── registration-service/  # Fluxo de cadastro
├── payment-service/       # Processamento de pagamentos
├── customer-service/      # Gestão de clientes
├── communication-service/ # Email, SMS, WhatsApp
├── admin-service/         # Painel administrativo
└── partner-service/       # Gestão de parceiros
```

---

## 🗄️ Banco de Dados PostgreSQL

### Schema Principal

#### Tabela: users
```sql
CREATE TABLE users (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    email VARCHAR(255) UNIQUE NOT NULL,
    password_hash VARCHAR(255), -- NULL se login social
    google_id VARCHAR(255) UNIQUE,
    phone VARCHAR(20) NOT NULL,
    phone_verified_at TIMESTAMP,
    email_verified_at TIMESTAMP,
    role VARCHAR(50) NOT NULL DEFAULT 'customer', -- customer, admin
    status VARCHAR(50) NOT NULL DEFAULT 'active', -- active, inactive, suspended
    last_login_at TIMESTAMP,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW(),
    deleted_at TIMESTAMP -- Soft delete
);

CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_users_phone ON users(phone);
CREATE INDEX idx_users_google_id ON users(google_id);
```

#### Tabela: registration_sessions
```sql
CREATE TABLE registration_sessions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    session_id VARCHAR(255) UNIQUE NOT NULL,
    status VARCHAR(50) NOT NULL, -- started, identity_verified, address_verified, plan_selected, payment_pending, paid, signed, approved
    user_id UUID REFERENCES users(id),
    current_step INTEGER DEFAULT 1,
    expires_at TIMESTAMP NOT NULL,
    utm_source VARCHAR(100),
    utm_campaign VARCHAR(100),
    ip_address INET,
    user_agent TEXT,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

CREATE INDEX idx_registration_sessions_status ON registration_sessions(status);
CREATE INDEX idx_registration_sessions_user_id ON registration_sessions(user_id);
```

#### Tabela: customers
```sql
CREATE TABLE customers (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES users(id) UNIQUE NOT NULL,
    membership_number VARCHAR(50) UNIQUE NOT NULL, -- CT-########
    full_name VARCHAR(255) NOT NULL,
    cpf VARCHAR(11) UNIQUE NOT NULL,
    birth_date DATE NOT NULL,
    gender VARCHAR(10), -- M, F, O
    marital_status VARCHAR(50),
    profession VARCHAR(100),
    status VARCHAR(50) NOT NULL DEFAULT 'active', -- active, inactive, suspended, canceled
    plan_id UUID REFERENCES plans(id),
    digital_card_url TEXT,
    qr_code_data TEXT,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW(),
    deleted_at TIMESTAMP
);

CREATE INDEX idx_customers_cpf ON customers(cpf);
CREATE INDEX idx_customers_membership_number ON customers(membership_number);
CREATE INDEX idx_customers_plan_id ON customers(plan_id);
```

#### Tabela: addresses
```sql
CREATE TABLE addresses (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    customer_id UUID REFERENCES customers(id) NOT NULL,
    cep VARCHAR(9) NOT NULL,
    street VARCHAR(255) NOT NULL,
    number VARCHAR(20) NOT NULL,
    complement VARCHAR(100),
    neighborhood VARCHAR(100) NOT NULL,
    city VARCHAR(100) NOT NULL,
    state VARCHAR(2) NOT NULL,
    latitude DECIMAL(10, 8),
    longitude DECIMAL(11, 8),
    is_primary BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

CREATE INDEX idx_addresses_customer_id ON addresses(customer_id);
CREATE INDEX idx_addresses_cep ON addresses(cep);
```

#### Tabela: dependents
```sql
CREATE TABLE dependents (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    customer_id UUID REFERENCES customers(id) NOT NULL,
    full_name VARCHAR(255) NOT NULL,
    relationship VARCHAR(50) NOT NULL, -- spouse, child, parent, other
    birth_date DATE NOT NULL,
    cpf VARCHAR(11),
    status VARCHAR(50) DEFAULT 'active', -- active, inactive
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW(),
    deleted_at TIMESTAMP
);

CREATE INDEX idx_dependents_customer_id ON dependents(customer_id);
```

#### Tabela: plans
```sql
CREATE TABLE plans (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(255) NOT NULL,
    slug VARCHAR(100) UNIQUE NOT NULL,
    description TEXT,
    category VARCHAR(50), -- individual, family, premium
    monthly_price DECIMAL(10, 2) NOT NULL,
    adhesion_fee DECIMAL(10, 2) DEFAULT 0,
    average_savings DECIMAL(10, 2),
    is_highlight BOOLEAN DEFAULT FALSE,
    is_active BOOLEAN DEFAULT TRUE,
    max_dependents INTEGER,
    version INTEGER DEFAULT 1,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

CREATE INDEX idx_plans_slug ON plans(slug);
CREATE INDEX idx_plans_is_active ON plans(is_active);
```

#### Tabela: plan_benefits
```sql
CREATE TABLE plan_benefits (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    plan_id UUID REFERENCES plans(id) NOT NULL,
    benefit_name VARCHAR(255) NOT NULL,
    benefit_description TEXT,
    discount_percentage DECIMAL(5, 2),
    sort_order INTEGER DEFAULT 0,
    created_at TIMESTAMP DEFAULT NOW()
);

CREATE INDEX idx_plan_benefits_plan_id ON plan_benefits(plan_id);
```

#### Tabela: payment_intents
```sql
CREATE TABLE payment_intents (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    registration_id UUID REFERENCES registration_sessions(id),
    customer_id UUID REFERENCES customers(id),
    method VARCHAR(50) NOT NULL, -- card, pix, debit
    amount DECIMAL(10, 2) NOT NULL,
    currency VARCHAR(3) DEFAULT 'BRL',
    status VARCHAR(50) NOT NULL, -- pending, requires_action, succeeded, failed, canceled, expired
    provider VARCHAR(50), -- stripe, pagseguro, mercadopago
    provider_intent_id VARCHAR(255),
    provider_payment_id VARCHAR(255),
    is_recurrence BOOLEAN DEFAULT FALSE,
    recurrence_cycle VARCHAR(50), -- monthly, yearly
    metadata JSONB,
    error_message TEXT,
    expires_at TIMESTAMP,
    paid_at TIMESTAMP,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

CREATE INDEX idx_payment_intents_registration_id ON payment_intents(registration_id);
CREATE INDEX idx_payment_intents_customer_id ON payment_intents(customer_id);
CREATE INDEX idx_payment_intents_status ON payment_intents(status);
```

#### Tabela: payment_methods
```sql
CREATE TABLE payment_methods (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    customer_id UUID REFERENCES customers(id) NOT NULL,
    type VARCHAR(50) NOT NULL, -- card, debit
    provider VARCHAR(50) NOT NULL,
    provider_method_id VARCHAR(255),
    card_brand VARCHAR(50),
    card_last4 VARCHAR(4),
    card_exp_month INTEGER,
    card_exp_year INTEGER,
    bank_name VARCHAR(100),
    is_default BOOLEAN DEFAULT FALSE,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

CREATE INDEX idx_payment_methods_customer_id ON payment_methods(customer_id);
```

#### Tabela: invoices
```sql
CREATE TABLE invoices (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    customer_id UUID REFERENCES customers(id) NOT NULL,
    invoice_number VARCHAR(50) UNIQUE NOT NULL,
    amount DECIMAL(10, 2) NOT NULL,
    due_date DATE NOT NULL,
    paid_date DATE,
    status VARCHAR(50) NOT NULL, -- open, paid, overdue, canceled
    payment_intent_id UUID REFERENCES payment_intents(id),
    boleto_url TEXT,
    pix_qr_code TEXT,
    pix_copy_paste_key TEXT,
    pdf_url TEXT,
    notes TEXT,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

CREATE INDEX idx_invoices_customer_id ON invoices(customer_id);
CREATE INDEX idx_invoices_status ON invoices(status);
CREATE INDEX idx_invoices_due_date ON invoices(due_date);
```

#### Tabela: contracts
```sql
CREATE TABLE contracts (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    version VARCHAR(20) NOT NULL UNIQUE, -- v1.0, v1.1, etc
    title VARCHAR(255) NOT NULL,
    content TEXT NOT NULL,
    summary JSONB, -- { "rights": [...], "duties": [...], "benefits": [...] }
    document_url TEXT,
    is_active BOOLEAN DEFAULT TRUE,
    effective_from DATE NOT NULL,
    effective_until DATE,
    created_at TIMESTAMP DEFAULT NOW()
);
```

#### Tabela: contract_signatures
```sql
CREATE TABLE contract_signatures (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    contract_id UUID REFERENCES contracts(id) NOT NULL,
    registration_id UUID REFERENCES registration_sessions(id),
    customer_id UUID REFERENCES customers(id) NOT NULL,
    method VARCHAR(50) NOT NULL, -- draw, code
    signature_image_url TEXT,
    verification_code VARCHAR(10),
    ip_address INET NOT NULL,
    user_agent TEXT,
    document_hash VARCHAR(255), -- Hash do documento assinado
    signed_at TIMESTAMP DEFAULT NOW()
);

CREATE INDEX idx_contract_signatures_customer_id ON contract_signatures(customer_id);
CREATE INDEX idx_contract_signatures_contract_id ON contract_signatures(contract_id);
```

#### Tabela: partners
```sql
CREATE TABLE partners (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(255) NOT NULL,
    slug VARCHAR(100) UNIQUE NOT NULL,
    category VARCHAR(100) NOT NULL, -- health, wellness, pharmacy, services
    description TEXT,
    logo_url TEXT,
    phone VARCHAR(20),
    email VARCHAR(255),
    website VARCHAR(255),
    status VARCHAR(50) DEFAULT 'active', -- active, inactive
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

CREATE INDEX idx_partners_slug ON partners(slug);
CREATE INDEX idx_partners_category ON partners(category);
```

#### Tabela: partner_locations
```sql
CREATE TABLE partner_locations (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    partner_id UUID REFERENCES partners(id) NOT NULL,
    name VARCHAR(255),
    cep VARCHAR(9) NOT NULL,
    street VARCHAR(255) NOT NULL,
    number VARCHAR(20) NOT NULL,
    complement VARCHAR(100),
    neighborhood VARCHAR(100) NOT NULL,
    city VARCHAR(100) NOT NULL,
    state VARCHAR(2) NOT NULL,
    latitude DECIMAL(10, 8) NOT NULL,
    longitude DECIMAL(11, 8) NOT NULL,
    phone VARCHAR(20),
    opening_hours JSONB, -- { "mon": "08:00-18:00", ... }
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

CREATE INDEX idx_partner_locations_partner_id ON partner_locations(partner_id);
CREATE INDEX idx_partner_locations_coordinates ON partner_locations USING GIST (
    point(longitude, latitude)
);
```

#### Tabela: benefits
```sql
CREATE TABLE benefits (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(255) NOT NULL,
    description TEXT,
    category VARCHAR(100) NOT NULL,
    discount_percentage DECIMAL(5, 2),
    discount_description TEXT,
    icon_url TEXT,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);
```

#### Tabela: verification_codes
```sql
CREATE TABLE verification_codes (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    registration_id UUID REFERENCES registration_sessions(id),
    user_id UUID REFERENCES users(id),
    channel VARCHAR(50) NOT NULL, -- sms, whatsapp, email
    purpose VARCHAR(50) NOT NULL, -- identity, signature, password_reset
    code VARCHAR(10) NOT NULL,
    phone VARCHAR(20),
    email VARCHAR(255),
    attempts INTEGER DEFAULT 0,
    max_attempts INTEGER DEFAULT 5,
    expires_at TIMESTAMP NOT NULL,
    verified_at TIMESTAMP,
    created_at TIMESTAMP DEFAULT NOW()
);

CREATE INDEX idx_verification_codes_registration_id ON verification_codes(registration_id);
CREATE INDEX idx_verification_codes_user_id ON verification_codes(user_id);
```

#### Tabela: communications
```sql
CREATE TABLE communications (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES users(id),
    customer_id UUID REFERENCES customers(id),
    channel VARCHAR(50) NOT NULL, -- email, sms, whatsapp
    template VARCHAR(100) NOT NULL,
    recipient VARCHAR(255) NOT NULL,
    subject VARCHAR(255),
    content TEXT,
    variables JSONB,
    status VARCHAR(50) NOT NULL, -- queued, sent, delivered, failed
    provider VARCHAR(50),
    provider_message_id VARCHAR(255),
    error_message TEXT,
    sent_at TIMESTAMP,
    delivered_at TIMESTAMP,
    created_at TIMESTAMP DEFAULT NOW()
);

CREATE INDEX idx_communications_user_id ON communications(user_id);
CREATE INDEX idx_communications_customer_id ON communications(customer_id);
CREATE INDEX idx_communications_status ON communications(status);
```

#### Tabela: consents (LGPD)
```sql
CREATE TABLE consents (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES users(id) NOT NULL,
    customer_id UUID REFERENCES customers(id),
    consent_type VARCHAR(100) NOT NULL, -- terms, privacy, marketing, data_sharing
    version VARCHAR(20) NOT NULL,
    granted BOOLEAN NOT NULL,
    ip_address INET,
    user_agent TEXT,
    granted_at TIMESTAMP,
    revoked_at TIMESTAMP,
    created_at TIMESTAMP DEFAULT NOW()
);

CREATE INDEX idx_consents_user_id ON consents(user_id);
CREATE INDEX idx_consents_customer_id ON consents(customer_id);
```

#### Tabela: audit_logs
```sql
CREATE TABLE audit_logs (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES users(id),
    entity_type VARCHAR(100) NOT NULL, -- customer, payment, plan, etc
    entity_id UUID NOT NULL,
    action VARCHAR(50) NOT NULL, -- create, update, delete, view
    changes JSONB, -- Before/after values
    ip_address INET,
    user_agent TEXT,
    created_at TIMESTAMP DEFAULT NOW()
);

CREATE INDEX idx_audit_logs_user_id ON audit_logs(user_id);
CREATE INDEX idx_audit_logs_entity ON audit_logs(entity_type, entity_id);
CREATE INDEX idx_audit_logs_created_at ON audit_logs(created_at DESC);
```

#### Tabela: support_tickets
```sql
CREATE TABLE support_tickets (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    customer_id UUID REFERENCES customers(id) NOT NULL,
    topic VARCHAR(100), -- billing, benefits, technical
    subject VARCHAR(255) NOT NULL,
    message TEXT NOT NULL,
    status VARCHAR(50) DEFAULT 'open', -- open, in_progress, resolved, closed
    priority VARCHAR(50) DEFAULT 'normal', -- low, normal, high, urgent
    assigned_to UUID REFERENCES users(id),
    resolved_at TIMESTAMP,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

CREATE INDEX idx_support_tickets_customer_id ON support_tickets(customer_id);
CREATE INDEX idx_support_tickets_status ON support_tickets(status);
```

---

## 🔌 Especificações de API REST

### Headers Padrão

**Request Headers:**
```
Authorization: Bearer {jwt_token}
Content-Type: application/json
X-Request-Id: {uuid}
Idempotency-Key: {uuid}  // Para operações críticas
```

**Response Headers:**
```
Content-Type: application/json
X-Request-Id: {uuid}
X-RateLimit-Limit: 100
X-RateLimit-Remaining: 95
X-RateLimit-Reset: 1234567890
```

### Estrutura de Resposta Padrão

**Sucesso:**
```json
{
  "success": true,
  "data": { ... },
  "meta": {
    "requestId": "uuid",
    "timestamp": "2024-01-15T10:30:00Z"
  }
}
```

**Erro:**
```json
{
  "success": false,
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "Dados inválidos",
    "details": [
      {
        "field": "cpf",
        "message": "CPF inválido"
      }
    ]
  },
  "meta": {
    "requestId": "uuid",
    "timestamp": "2024-01-15T10:30:00Z"
  }
}
```

### Códigos de Status HTTP

```
200 OK              - Sucesso
201 Created         - Recurso criado
204 No Content      - Sucesso sem retorno
400 Bad Request     - Validação falhou
401 Unauthorized    - Não autenticado
403 Forbidden       - Sem permissão
404 Not Found       - Recurso não encontrado
409 Conflict        - Conflito (ex: duplicado)
422 Unprocessable   - Regra de negócio violada
429 Too Many Req    - Rate limit excedido
500 Server Error    - Erro interno
502 Bad Gateway     - Serviço externo falhou
503 Unavailable     - Serviço temporariamente indisponível
504 Timeout         - Timeout em integração
```

---

## 🔐 Autenticação e Segurança

### JWT Structure
```json
{
  "sub": "user_id",
  "email": "user@example.com",
  "role": "customer",
  "iat": 1234567890,
  "exp": 1234571490,
  "customerId": "uuid"
}
```

### Endpoints de Autenticação

#### POST /v1/auth/session
Criar sessão anônima para cadastro

**Request:**
```json
{
  "channel": "app",
  "utm": {
    "source": "facebook",
    "campaign": "jan2024"
  }
}
```

**Response:**
```json
{
  "sessionId": "uuid",
  "expiresAt": "2024-01-15T11:00:00Z"
}
```

#### POST /v1/auth/register
Registrar novo usuário

**Request:**
```json
{
  "email": "user@example.com",
  "password": "SecurePass123!",
  "phone": {
    "country": "55",
    "ddd": "61",
    "number": "912345678"
  }
}
```

**Response:**
```json
{
  "userId": "uuid",
  "email": "user@example.com",
  "verificationRequired": true
}
```

#### POST /v1/auth/login
Login com email/senha

**Request:**
```json
{
  "email": "user@example.com",
  "password": "SecurePass123!"
}
```

**Response:**
```json
{
  "accessToken": "jwt_token",
  "refreshToken": "refresh_token",
  "expiresIn": 3600,
  "user": {
    "id": "uuid",
    "email": "user@example.com",
    "role": "customer",
    "customerId": "uuid"
  }
}
```

#### POST /v1/auth/google
Login com Google OAuth

**Request:**
```json
{
  "idToken": "google_id_token"
}
```

**Response:**
```json
{
  "accessToken": "jwt_token",
  "refreshToken": "refresh_token",
  "expiresIn": 3600,
  "user": { ... }
}
```

#### POST /v1/auth/refresh-token
Renovar token

**Request:**
```json
{
  "refreshToken": "refresh_token"
}
```

**Response:**
```json
{
  "accessToken": "new_jwt_token",
  "expiresIn": 3600
}
```

#### POST /v1/auth/forgot-password
Solicitar recuperação de senha

**Request:**
```json
{
  "email": "user@example.com"
}
```

**Response:**
```json
{
  "message": "Se o email existir, você receberá instruções"
}
```

#### POST /v1/auth/reset-password
Resetar senha

**Request:**
```json
{
  "token": "reset_token",
  "newPassword": "NewSecurePass123!"
}
```

**Response:**
```json
{
  "message": "Senha alterada com sucesso"
}
```

---

## 📋 Endpoints Completos por Módulo

### 1. Cadastro (Registration)

#### POST /v1/registration
Iniciar cadastro

**Request:**
```json
{
  "fullName": "João Silva",
  "cpf": "12345678901",
  "birthDate": "1990-05-15",
  "phone": {
    "country": "55",
    "ddd": "61",
    "number": "912345678"
  },
  "email": "joao@example.com"
}
```

**Response:**
```json
{
  "registrationId": "uuid",
  "status": "started",
  "nextStep": "verification"
}
```

#### POST /v1/registration/{id}/verification/code
Enviar código de verificação

**Request:**
```json
{
  "channel": "whatsapp",
  "purpose": "identity"
}
```

**Response:**
```json
{
  "sent": true,
  "expiresInSeconds": 300,
  "channel": "whatsapp"
}
```

#### POST /v1/registration/{id}/verification/confirm
Confirmar código

**Request:**
```json
{
  "code": "123456"
}
```

**Response:**
```json
{
  "verified": true,
  "status": "identity_verified",
  "nextStep": "address"
}
```

#### GET /v1/registration/{id}/prefill
Buscar dados existentes por CPF

**Response:**
```json
{
  "exists": true,
  "data": {
    "fullName": "João Silva",
    "email": "joao@example.com",
    "phone": "61912345678"
  }
}
```

#### GET /v1/address/cep/{cep}
Buscar endereço por CEP

**Response:**
```json
{
  "cep": "70000-000",
  "street": "Esplanada dos Ministérios",
  "neighborhood": "Zona Cívico-Administrativa",
  "city": "Brasília",
  "state": "DF",
  "geo": {
    "lat": -15.7942,
    "lng": -47.8822
  }
}
```

#### PUT /v1/registration/{id}/address
Salvar endereço

**Request:**
```json
{
  "cep": "70000-000",
  "street": "Esplanada dos Ministérios",
  "number": "S/N",
  "complement": "Bloco A",
  "neighborhood": "Zona Cívico-Administrativa",
  "city": "Brasília",
  "state": "DF",
  "confirmGeo": true
}
```

**Response:**
```json
{
  "status": "address_verified",
  "nextStep": "holder_info"
}
```

#### PUT /v1/registration/{id}/holder
Atualizar dados do titular

**Request:**
```json
{
  "gender": "M",
  "maritalStatus": "married",
  "profession": "Engenheiro"
}
```

**Response:**
```json
{
  "status": "holder_updated",
  "nextStep": "dependents"
}
```

#### POST /v1/registration/{id}/dependents
Adicionar dependente

**Request:**
```json
{
  "fullName": "Maria Silva",
  "relationship": "spouse",
  "birthDate": "1992-08-20",
  "cpf": "98765432100"
}
```

**Response:**
```json
{
  "dependentId": "uuid",
  "message": "Dependente adicionado com sucesso"
}
```

#### GET /v1/registration/{id}/dependents
Listar dependentes

**Response:**
```json
{
  "items": [
    {
      "dependentId": "uuid",
      "fullName": "Maria Silva",
      "relationship": "spouse",
      "birthDate": "1992-08-20",
      "age": 31
    }
  ]
}
```

#### DELETE /v1/registration/{id}/dependents/{dependentId}
Remover dependente

**Response:** 204 No Content

### 2. Planos (Plans)

#### GET /v1/plans
Listar planos

**Query Params:**
- category: individual|family|premium
- active: true|false

**Response:**
```json
{
  "items": [
    {
      "planId": "uuid",
      "name": "Plano Familiar",
      "slug": "plano-familiar",
      "category": "family",
      "description": "Plano completo para toda a família",
      "monthlyPrice": 69.90,
      "adhesionFee": 29.90,
      "averageSavings": 120.00,
      "maxDependents": 5,
      "isHighlight": true,
      "benefits": [
        {
          "name": "Consultas médicas",
          "description": "Até 50% de desconto",
          "discountPercentage": 50
        }
      ]
    }
  ]
}
```

#### POST /v1/registration/{id}/plan
Selecionar plano

**Request:**
```json
{
  "planId": "uuid",
  "addons": ["pharmacy", "wellness"]
}
```

**Response:**
```json
{
  "status": "plan_selected",
  "pricing": {
    "monthly": 69.90,
    "adhesionFee": 29.90,
    "totalDueNow": 29.90,
    "addonsTotal": 10.00
  },
  "nextStep": "payment"
}
```

### 3. Pagamento (Payment)

#### POST /v1/registration/{id}/payment/intents
Criar intenção de pagamento

**Request:**
```json
{
  "method": "card",
  "recurrence": {
    "enabled": true,
    "cycle": "monthly"
  }
}
```

**Response:**
```json
{
  "paymentIntentId": "uuid",
  "status": "requires_action",
  "amount": 29.90,
  "currency": "BRL",
  "clientSecret": "secret_key"
}
```

#### POST /v1/payment/intents/{intentId}/confirm-card
Confirmar pagamento com cartão

**Request:**
```json
{
  "card": {
    "holderName": "JOAO SILVA",
    "number": "4111111111111111",
    "expMonth": 12,
    "expYear": 2027,
    "cvv": "123"
  },
  "saveForRecurrence": true,
  "3ds": true
}
```

**Response:**
```json
{
  "status": "succeeded",
  "paymentMethodId": "uuid",
  "message": "Pagamento aprovado"
}
```

#### POST /v1/payment/intents/{intentId}/create-pix
Gerar PIX

**Response:**
```json
{
  "status": "pending",
  "qrCode": "base64_image",
  "copyPasteKey": "00020126580014br.gov.bcb.pix...",
  "expiresAt": "2024-01-15T11:00:00Z",
  "amount": 29.90
}
```

#### GET /v1/payment/intents/{intentId}/status
Verificar status do pagamento

**Response:**
```json
{
  "status": "succeeded",
  "paidAt": "2024-01-15T10:35:00Z"
}
```

### 4. Contratos (Contracts)

#### GET /v1/contracts/current
Obter contrato vigente

**Response:**
```json
{
  "contractId": "uuid",
  "version": "v2.0",
  "title": "Termo de Adesão ao Plano de Benefícios",
  "summary": {
    "rights": [
      "Acesso a rede credenciada",
      "Descontos em serviços"
    ],
    "duties": [
      "Pagamento mensal em dia",
      "Informações verídicas"
    ],
    "benefits": [...],
    "cancellation": "Cancelamento a qualquer momento...",
    "privacy": "Seus dados serão tratados conforme LGPD..."
  },
  "documentUrl": "https://..."
}
```

#### POST /v1/contracts/{contractId}/sign
Assinar contrato

**Request (assinatura com dedo):**
```json
{
  "registrationId": "uuid",
  "method": "draw",
  "signatureImage": "base64_image",
  "signedAt": "2024-01-15T10:40:00Z"
}
```

**Request (código WhatsApp):**
```json
{
  "registrationId": "uuid",
  "method": "code",
  "code": "123456"
}
```

**Response:**
```json
{
  "status": "signed",
  "signatureId": "uuid",
  "nextStep": "approval"
}
```

### 5. Aprovação e Confirmação

#### POST /v1/registration/{id}/approve
Aprovar cadastro (após pagamento e assinatura)

**Response:**
```json
{
  "status": "approved",
  "customerId": "uuid",
  "membershipNumber": "CT-00001234",
  "digitalCardUrl": "https://...",
  "message": "Cadastro aprovado com sucesso!"
}
```

#### GET /v1/registration/{id}/confirmation
Obter dados de confirmação

**Response:**
```json
{
  "holderName": "João Silva",
  "membershipNumber": "CT-00001234",
  "status": "approved",
  "digitalCardUrl": "https://...",
  "plan": {
    "name": "Plano Familiar",
    "monthlyPrice": 69.90
  },
  "links": {
    "portal": "https://app.example.com/home",
    "whatsappShare": "https://wa.me/..."
  }
}
```

### 6. Área do Cliente (Customer)

#### GET /v1/customers/{id}/card
Obter cartão digital

**Response:**
```json
{
  "cardId": "uuid",
  "membershipNumber": "CT-00001234",
  "holderName": "João Silva",
  "cpf": "123.***.***-01",
  "plan": "Plano Familiar",
  "validity": "2025-12-31",
  "digitalCardUrl": "https://...",
  "qrData": "encoded_data",
  "qrCodeImage": "base64_qr"
}
```

#### GET /v1/customers/{id}
Obter dados do cliente

**Response:**
```json
{
  "customerId": "uuid",
  "membershipNumber": "CT-00001234",
  "holder": {
    "fullName": "João Silva",
    "cpf": "123.***.***-01",
    "birthDate": "1990-05-15",
    "age": 33,
    "gender": "M",
    "maritalStatus": "married",
    "profession": "Engenheiro",
    "email": "joao@example.com",
    "phone": "61912345678"
  },
  "address": {
    "cep": "70000-000",
    "street": "Esplanada dos Ministérios",
    "number": "S/N",
    "city": "Brasília",
    "state": "DF"
  },
  "dependents": [
    {
      "dependentId": "uuid",
      "fullName": "Maria Silva",
      "relationship": "spouse",
      "birthDate": "1992-08-20",
      "age": 31
    }
  ],
  "plan": {
    "planId": "uuid",
    "name": "Plano Familiar",
    "monthlyPrice": 69.90
  },
  "status": "active",
  "createdAt": "2024-01-15T10:45:00Z"
}
```

#### PUT /v1/customers/{id}
Atualizar dados do cliente

**Request:**
```json
{
  "phone": "61987654321",
  "profession": "Arquiteto",
  "address": {
    "complement": "Apto 101"
  }
}
```

**Response:**
```json
{
  "updated": true,
  "message": "Dados atualizados com sucesso"
}
```

#### GET /v1/customers/{id}/invoices
Listar faturas

**Query Params:**
- status: open|paid|overdue
- limit: 10
- offset: 0

**Response:**
```json
{
  "items": [
    {
      "invoiceId": "uuid",
      "invoiceNumber": "INV-001234",
      "amount": 69.90,
      "dueDate": "2024-02-15",
      "paidDate": null,
      "status": "open",
      "downloadUrl": "https://..."
    }
  ],
  "total": 12,
  "limit": 10,
  "offset": 0
}
```

#### POST /v1/invoices/{invoiceId}/duplicate
Gerar segunda via

**Response:**
```json
{
  "invoiceId": "uuid",
  "boletoUrl": "https://...",
  "pix": {
    "qrCode": "base64_image",
    "copyPasteKey": "00020126..."
  },
  "expiresAt": "2024-02-15T23:59:59Z"
}
```

#### GET /v1/customers/{id}/payments/history
Histórico de pagamentos

**Response:**
```json
{
  "items": [
    {
      "paymentId": "uuid",
      "amount": 69.90,
      "method": "card",
      "status": "succeeded",
      "paidAt": "2024-01-15T10:35:00Z",
      "invoiceNumber": "INV-001234"
    }
  ]
}
```

#### GET /v1/benefits
Listar benefícios

**Response:**
```json
{
  "items": [
    {
      "benefitId": "uuid",
      "name": "Consultas Médicas",
      "category": "health",
      "description": "Descontos em consultas",
      "discountPercentage": 50,
      "iconUrl": "https://...",
      "howToUse": "Apresente seu cartão digital..."
    }
  ]
}
```

#### GET /v1/partners/clinics
Buscar parceiros

**Query Params:**
- lat: -15.7942
- lng: -47.8822
- radius: 5000 (metros)
- category: health|pharmacy|wellness

**Response:**
```json
{
  "items": [
    {
      "partnerId": "uuid",
      "name": "Clínica Saúde Total",
      "category": "health",
      "distance": 1200,
      "address": {
        "street": "Rua das Flores",
        "number": "123",
        "neighborhood": "Centro",
        "city": "Brasília",
        "state": "DF"
      },
      "geo": {
        "lat": -15.7950,
        "lng": -47.8830
      },
      "phone": "6133334444",
      "openingHours": {
        "mon": "08:00-18:00",
        "tue": "08:00-18:00"
      },
      "specialties": ["Clínica Geral", "Cardiologia"]
    }
  ]
}
```

#### POST /v1/support/whatsapp
Abrir ticket de suporte

**Request:**
```json
{
  "customerId": "uuid",
  "topic": "billing",
  "message": "Não consegui gerar a segunda via"
}
```

**Response:**
```json
{
  "ticketId": "uuid",
  "status": "opened",
  "whatsappUrl": "https://wa.me/..."
}
```

### 7. Comunicação (Communication)

#### POST /v1/communication/whatsapp/send
Enviar mensagem WhatsApp

**Request:**
```json
{
  "to": "5561912345678",
  "template": "welcome",
  "variables": {
    "name": "João",
    "membershipNumber": "CT-00001234",
    "portalLink": "https://...",
    "digitalCardUrl": "https://..."
  }
}
```

**Response:**
```json
{
  "messageId": "uuid",
  "status": "queued",
  "estimatedDelivery": "2024-01-15T10:46:00Z"
}
```

#### POST /v1/communication/email/send
Enviar email

**Request:**
```json
{
  "to": "joao@example.com",
  "template": "confirmation",
  "variables": {
    "name": "João",
    "membershipNumber": "CT-00001234"
  },
  "attachments": ["invoice.pdf"]
}
```

**Response:**
```json
{
  "messageId": "uuid",
  "status": "queued"
}
```

#### POST /v1/communication/whatsapp/deeplink
Gerar link WhatsApp contextual

**Request:**
```json
{
  "sessionId": "uuid",
  "context": "payment"
}
```

**Response:**
```json
{
  "url": "https://wa.me/5561999999999?text=Ol%C3%A1%2C..."
}
```

### 8. Admin - Endpoints

#### GET /v1/admin/dashboard/metrics
Dashboard de métricas

**Response:**
```json
{
  "totalCustomers": 1234,
  "newCustomersThisMonth": 89,
  "conversionRate": 0.67,
  "monthlyRevenue": 85678.00,
  "churnRate": 0.03,
  "defaultRate": 0.05,
  "popularPlans": [
    {
      "planName": "Plano Familiar",
      "count": 567
    }
  ]
}
```

#### GET /v1/admin/customers
Listar todos os clientes (paginado)

**Query Params:**
- search: termo de busca
- status: active|inactive
- plan: planId
- limit: 50
- offset: 0

**Response:**
```json
{
  "items": [...],
  "total": 1234,
  "limit": 50,
  "offset": 0
}
```

#### POST /v1/admin/plans
Criar novo plano

**Request:**
```json
{
  "name": "Plano Premium Plus",
  "category": "premium",
  "monthlyPrice": 99.90,
  "adhesionFee": 49.90,
  "maxDependents": 10,
  "benefits": [
    {
      "name": "Consultas ilimitadas",
      "description": "Sem limite de consultas"
    }
  ]
}
```

**Response:**
```json
{
  "planId": "uuid",
  "message": "Plano criado com sucesso"
}
```

---

## 🔗 Integrações

### Gateway de Pagamento (Stripe exemplo)

#### Webhook: /v1/webhooks/payments
Receber notificações de pagamento

**Request do Gateway:**
```json
{
  "paymentIntentId": "uuid",
  "status": "succeeded",
  "provider": "stripe",
  "providerRef": "pi_3xxx",
  "amount": 29.90,
  "paidAt": "2024-01-15T10:35:00Z"
}
```

**Response:**
```json
{
  "received": true
}
```

### WhatsApp Business API

**Configuração:**
- Provider: Twilio / Meta Cloud API
- Templates aprovados
- Webhook para status de entrega

### Email (SendGrid)

**Configuração:**
- API Key
- Templates HTML
- Tracking de abertura
- Bounce handling

### SMS (Twilio)

**Configuração:**
- Account SID
- Auth Token
- Phone numbers

---

## 📊 Monitoramento e Observabilidade

### Logs Estruturados
```json
{
  "timestamp": "2024-01-15T10:30:00Z",
  "level": "info",
  "requestId": "uuid",
  "userId": "uuid",
  "action": "registration.payment.success",
  "duration": 1234,
  "metadata": { ... }
}
```

### Métricas Importantes
- Taxa de conversão por etapa
- Tempo médio de cadastro
- Taxa de abandono
- Falhas de pagamento
- Tempo de resposta de APIs
- Taxa de erros
- Uptime

### Alertas
- Taxa de erro > 5%
- Tempo de resposta > 2s
- Falhas de pagamento > 10%
- Serviço externo down

---

## 🔒 Segurança

### Checklist
- [ ] TLS/HTTPS obrigatório
- [ ] Rate limiting (100 req/min por IP)
- [ ] Validação de entrada (todos endpoints)
- [ ] SQL injection prevention (prepared statements)
- [ ] XSS prevention (sanitização)
- [ ] CSRF tokens
- [ ] JWT com expiração curta
- [ ] Refresh tokens seguros
- [ ] Passwords: bcrypt/argon2
- [ ] Sensitive data: mascaramento em logs
- [ ] PCI-DSS compliance (pagamentos)
- [ ] LGPD compliance
- [ ] Backup diário
- [ ] Disaster recovery plan

---

## 📚 Documentação da API

**Ferramentas Sugeridas:**
- OpenAPI/Swagger
- Postman Collections
- API Blueprint

**Exemplo de documentação:**
```yaml
openapi: 3.0.0
info:
  title: Sistema de Cartão de Benefícios API
  version: 1.0.0
  description: API completa para gestão de benefícios

servers:
  - url: https://api.example.com/v1
    description: Produção
  - url: https://staging-api.example.com/v1
    description: Staging

paths:
  /registration:
    post:
      summary: Iniciar cadastro
      tags:
        - Registration
      security:
        - sessionAuth: []
      requestBody:
        content:
          application/json:
            schema:
              $ref: '#/components/schemas/RegistrationRequest'
      responses:
        '201':
          description: Cadastro iniciado
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/RegistrationResponse'
```

---

Esse documento cobre toda a especificação do backend. Próximos passos seriam:
1. Implementar o backend
2. Criar migrations do banco
3. Desenvolver o app Flutter
4. Integrar tudo
