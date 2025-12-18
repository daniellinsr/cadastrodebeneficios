# Database Setup - PostgreSQL

## 📋 Informações do Banco de Dados

### Configuração Atual:
- **Host:** `77.37.41.41`
- **Port:** `5432` (padrão PostgreSQL)
- **Database:** `cadastro_db`
- **User:** `cadastro_user`
- **Password:** `Hno@uw@q`
- **SSL Mode:** `require`

⚠️ **IMPORTANTE**: Essas credenciais estão no arquivo `.env` que **NÃO deve ser commitado** no Git!

---

## 🗂️ Estrutura do Banco de Dados

### Tabelas Principais:

1. **`users`** - Usuários do sistema
2. **`refresh_tokens`** - Tokens de refresh para renovação de acesso
3. **`password_reset_tokens`** - Tokens para reset de senha
4. **`cards`** - Cartões de benefícios (virtuais e físicos)
5. **`transactions`** - Transações dos cartões
6. **`addresses`** - Endereços dos usuários

---

## 📁 Migrations

As migrations estão localizadas em: `database/migrations/`

### Lista de Migrations:

| # | Arquivo | Descrição |
|---|---------|-----------|
| 001 | `001_create_users_table.sql` | Tabelas de usuários, refresh tokens e password reset |
| 002 | `002_create_cards_table.sql` | Tabela de cartões de benefícios |
| 003 | `003_create_transactions_table.sql` | Tabela de transações |
| 004 | `004_create_addresses_table.sql` | Tabela de endereços |

---

## 🚀 Como Executar as Migrations

### Opção 1: Usando psql (Command Line)

#### Windows:

```bash
# Navegar para a pasta do projeto
cd c:\Users\daniel.rodriguez\Documents\pessoal\cadastrodebeneficios

# Executar cada migration
psql -h 77.37.41.41 -U cadastro_user -d cadastro_db -f database/migrations/001_create_users_table.sql
psql -h 77.37.41.41 -U cadastro_user -d cadastro_db -f database/migrations/002_create_cards_table.sql
psql -h 77.37.41.41 -U cadastro_user -d cadastro_db -f database/migrations/003_create_transactions_table.sql
psql -h 77.37.41.41 -U cadastro_user -d cadastro_db -f database/migrations/004_create_addresses_table.sql
```

Quando solicitado, digite a senha: `Hno@uw@q`

#### Linux/Mac:

```bash
# Navegar para a pasta do projeto
cd ~/path/to/cadastrodebeneficios

# Exportar senha (evitar digitar múltiplas vezes)
export PGPASSWORD='Hno@uw@q'

# Executar todas as migrations de uma vez
for file in database/migrations/*.sql; do
    psql -h 77.37.41.41 -U cadastro_user -d cadastro_db -f "$file"
done
```

### Opção 2: Usando Script Automatizado

Criamos um script que executa todas as migrations automaticamente:

```bash
# Windows PowerShell
.\database\run_migrations.ps1

# Linux/Mac
bash database/run_migrations.sh
```

### Opção 3: Usando Cliente GUI

#### DBeaver / pgAdmin:

1. Conectar ao banco:
   - Host: `77.37.41.41`
   - Port: `5432`
   - Database: `cadastro_db`
   - User: `cadastro_user`
   - Password: `Hno@uw@q`
   - SSL: Enable

2. Abrir cada arquivo `.sql` em `database/migrations/`
3. Executar na ordem (001, 002, 003, 004)

---

## 📊 Estrutura Detalhada das Tabelas

### 1. Tabela `users`

```sql
id                    UUID PRIMARY KEY
nome                  VARCHAR(255) NOT NULL
email                 VARCHAR(255) NOT NULL UNIQUE
email_verified        BOOLEAN DEFAULT FALSE
password_hash         VARCHAR(255) NOT NULL
cpf                   VARCHAR(14) UNIQUE
telefone              VARCHAR(20) NOT NULL
google_id             VARCHAR(255) UNIQUE
is_active             BOOLEAN DEFAULT TRUE
created_at            TIMESTAMP
updated_at            TIMESTAMP
deleted_at            TIMESTAMP  -- Soft delete
```

**Índices:**
- `email` (único, onde deleted_at IS NULL)
- `cpf` (único, onde deleted_at IS NULL)
- `google_id` (único, onde deleted_at IS NULL)

### 2. Tabela `refresh_tokens`

```sql
id             UUID PRIMARY KEY
user_id        UUID REFERENCES users(id)
token          VARCHAR(500) UNIQUE
expires_at     TIMESTAMP NOT NULL
revoked_at     TIMESTAMP
device_name    VARCHAR(255)
ip_address     INET
created_at     TIMESTAMP
```

### 3. Tabela `password_reset_tokens`

```sql
id             UUID PRIMARY KEY
user_id        UUID REFERENCES users(id)
token          VARCHAR(500) UNIQUE
expires_at     TIMESTAMP NOT NULL
used_at        TIMESTAMP
created_at     TIMESTAMP
```

### 4. Tabela `cards`

```sql
id                    UUID PRIMARY KEY
user_id               UUID REFERENCES users(id)
card_number           VARCHAR(16) UNIQUE
card_holder_name      VARCHAR(255)
expiry_month          SMALLINT (1-12)
expiry_year           SMALLINT
cvv                   VARCHAR(4)
card_type             ENUM('virtual', 'physical')
status                ENUM('active', 'blocked', 'cancelled', 'pending')
balance               DECIMAL(10,2)
credit_limit          DECIMAL(10,2)
is_default            BOOLEAN
allow_online_purchases BOOLEAN
allow_contactless     BOOLEAN
allow_international   BOOLEAN
created_at            TIMESTAMP
updated_at            TIMESTAMP
deleted_at            TIMESTAMP
```

**Constraints:**
- Apenas 1 cartão default por usuário

### 5. Tabela `transactions`

```sql
id                      UUID PRIMARY KEY
card_id                 UUID REFERENCES cards(id)
user_id                 UUID REFERENCES users(id)
amount                  DECIMAL(10,2)
transaction_type        ENUM (purchase, refund, transfer, etc)
status                  ENUM (pending, completed, failed, etc)
category                ENUM (food, transport, health, etc)
description             TEXT
merchant_name           VARCHAR(255)
cashback_amount         DECIMAL(10,2)
latitude                DECIMAL(10,8)
longitude               DECIMAL(11,8)
created_at              TIMESTAMP
updated_at              TIMESTAMP
```

**Índices importantes:**
- `user_id + created_at DESC` (queries comuns)
- `card_id + created_at DESC` (histórico do cartão)

### 6. Tabela `addresses`

```sql
id                UUID PRIMARY KEY
user_id           UUID REFERENCES users(id)
address_type      ENUM('home', 'work', 'delivery', 'billing', 'other')
label             VARCHAR(100)
cep               VARCHAR(9)
logradouro        VARCHAR(255)
numero            VARCHAR(20)
complemento       VARCHAR(100)
bairro            VARCHAR(100)
cidade            VARCHAR(100)
estado            VARCHAR(2)
pais              VARCHAR(3)
is_default        BOOLEAN
latitude          DECIMAL(10,8)
longitude         DECIMAL(11,8)
created_at        TIMESTAMP
updated_at        TIMESTAMP
deleted_at        TIMESTAMP
```

---

## 🔧 Recursos Especiais do Banco

### 1. UUID como Primary Key

Todas as tabelas usam UUID v4 para IDs:
- Seguro para ambientes distribuídos
- Dificulta enumeração de recursos
- Compatível com sistemas externos

### 2. Soft Delete

Tabelas principais suportam soft delete via coluna `deleted_at`:
- Permite recuperação de dados
- Histórico completo
- Queries devem filtrar `WHERE deleted_at IS NULL`

### 3. Timestamps Automáticos

- `created_at`: Definido automaticamente na inserção
- `updated_at`: Atualizado automaticamente via trigger

### 4. ENUMs

Tipos personalizados para:
- `card_type`: virtual, physical
- `card_status`: active, blocked, cancelled, pending
- `transaction_type`: purchase, refund, transfer, etc
- `transaction_status`: pending, completed, failed, etc
- `transaction_category`: food, transport, health, etc
- `address_type`: home, work, delivery, billing, other

### 5. Constraints e Validações

- Email único por usuário
- CPF único (quando fornecido)
- Apenas 1 cartão default por usuário
- Apenas 1 endereço default por usuário
- Saldo não pode ser negativo
- Mês de expiração entre 1-12
- Ano de expiração >= ano atual

---

## 🔍 Queries Úteis

### Verificar se as tabelas foram criadas:

```sql
SELECT table_name
FROM information_schema.tables
WHERE table_schema = 'public'
ORDER BY table_name;
```

### Ver todos os índices:

```sql
SELECT tablename, indexname, indexdef
FROM pg_indexes
WHERE schemaname = 'public'
ORDER BY tablename, indexname;
```

### Ver todas as constraints:

```sql
SELECT conname, contype, conrelid::regclass AS table_name
FROM pg_constraint
WHERE connamespace = 'public'::regnamespace
ORDER BY table_name;
```

### Verificar quantidade de registros:

```sql
SELECT 'users' AS table, COUNT(*) FROM users
UNION ALL
SELECT 'cards', COUNT(*) FROM cards
UNION ALL
SELECT 'transactions', COUNT(*) FROM transactions
UNION ALL
SELECT 'addresses', COUNT(*) FROM addresses;
```

### Limpar todas as tabelas (CUIDADO!):

```sql
TRUNCATE TABLE transactions CASCADE;
TRUNCATE TABLE cards CASCADE;
TRUNCATE TABLE addresses CASCADE;
TRUNCATE TABLE password_reset_tokens CASCADE;
TRUNCATE TABLE refresh_tokens CASCADE;
TRUNCATE TABLE users CASCADE;
```

---

## 🛡️ Segurança

### Boas Práticas Implementadas:

1. ✅ **Senhas Hasheadas**: Armazenamos apenas hash bcrypt
2. ✅ **Soft Delete**: Dados não são perdidos permanentemente
3. ✅ **Índices Únicos**: Previnem duplicatas
4. ✅ **Foreign Keys**: Integridade referencial garantida
5. ✅ **SSL Obrigatório**: Conexão criptografada
6. ✅ **Validações no Banco**: Constraints e checks
7. ✅ **Timestamps**: Auditoria de alterações

### Recomendações Adicionais:

- [ ] Configurar backup automático diário
- [ ] Implementar replicação (se necessário)
- [ ] Configurar monitoramento de performance
- [ ] Limitar conexões simultâneas por aplicação
- [ ] Rotacionar tokens periodicamente

---

## 🧪 Dados de Teste

Para popular o banco com dados de teste, use:

```sql
-- Inserir usuário de teste
INSERT INTO users (nome, email, password_hash, telefone)
VALUES (
    'Usuário Teste',
    'teste@example.com',
    '$2a$10$example_hash',  -- Substitua por um hash bcrypt real
    '(11) 98765-4321'
);
```

---

## 📚 Referências

- [PostgreSQL Documentation](https://www.postgresql.org/docs/)
- [UUID Best Practices](https://www.postgresql.org/docs/current/uuid-ossp.html)
- [Soft Delete Pattern](https://en.wikipedia.org/wiki/Soft_deletion)
- [Database Indexing](https://www.postgresql.org/docs/current/indexes.html)

---

## 🆘 Troubleshooting

### Erro: "FATAL: password authentication failed"

**Solução:** Verifique se a senha está correta no arquivo `.env`

### Erro: "FATAL: no pg_hba.conf entry for host"

**Solução:** Verifique se o SSL está habilitado (`DB_SSL_MODE=require`)

### Erro: "relation already exists"

**Solução:** A tabela já existe. Use `DROP TABLE` ou `CREATE TABLE IF NOT EXISTS`

### Erro: "permission denied"

**Solução:** Verifique se o usuário `cadastro_user` tem permissões adequadas

---

**Última Atualização:** 2024-12-13
**Status:** ✅ Migrations criadas e prontas para execução
