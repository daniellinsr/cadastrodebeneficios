# Database QuickStart

## ✅ Banco de Dados Configurado

**Host:** `77.37.41.41`
**Database:** `cadastro_db`
**User:** `cadastro_user`

---

## 🚀 Executar Migrations (3 opções)

### Opção 1: Script Automático (Recomendado)

**Windows (PowerShell):**
```powershell
.\database\run_migrations.ps1
```

**Linux/Mac:**
```bash
chmod +x database/run_migrations.sh
./database/run_migrations.sh
```

### Opção 2: psql Manual

```bash
psql -h 77.37.41.41 -U cadastro_user -d cadastro_db -f database/migrations/001_create_users_table.sql
psql -h 77.37.41.41 -U cadastro_user -d cadastro_db -f database/migrations/002_create_cards_table.sql
psql -h 77.37.41.41 -U cadastro_user -d cadastro_db -f database/migrations/003_create_transactions_table.sql
psql -h 77.37.41.41 -U cadastro_user -d cadastro_db -f database/migrations/004_create_addresses_table.sql
```

### Opção 3: GUI (DBeaver, pgAdmin)

1. Conectar ao banco com as credenciais do `.env`
2. Executar cada arquivo `.sql` em ordem

---

## 📊 Tabelas Criadas

1. ✅ **users** - Usuários
2. ✅ **refresh_tokens** - Tokens de autenticação
3. ✅ **password_reset_tokens** - Reset de senha
4. ✅ **cards** - Cartões de benefícios
5. ✅ **transactions** - Transações
6. ✅ **addresses** - Endereços

---

## 🔍 Verificar Instalação

```sql
-- Ver todas as tabelas
SELECT table_name FROM information_schema.tables WHERE table_schema = 'public';

-- Contar registros
SELECT 'users' AS table, COUNT(*) FROM users;
```

---

## 📚 Documentação Completa

Ver: [DATABASE_SETUP.md](./DATABASE_SETUP.md)

---

**Status:** ✅ Pronto para usar
