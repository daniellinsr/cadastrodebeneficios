# 🔧 Troubleshooting - Conexão com PostgreSQL

## ❌ Problema Atual

```
Erro: connect ECONNREFUSED 77.37.41.41:5432
```

Isso significa que **não conseguimos conectar** ao servidor PostgreSQL no IP `77.37.41.41`.

---

## 🔍 Diagnóstico

### 1. Verificar se o IP está correto

O IP `77.37.41.41` é um IP público. Algumas perguntas:

- ✅ Este é um servidor na nuvem (AWS, DigitalOcean, etc)?
- ✅ Você tem acesso VPN para este servidor?
- ✅ Este servidor está ativo/online?
- ✅ O firewall do servidor permite conexões na porta 5432?

### 2. Testar conectividade básica

**Windows PowerShell:**
```powershell
Test-NetConnection -ComputerName 77.37.41.41 -Port 5432
```

**Resultado esperado:**
```
TcpTestSucceeded : True
```

Se retornar `False`, o servidor não está acessível.

---

## 💡 Soluções

### Opção 1: Usar PostgreSQL Local

Se você não tem acesso ao servidor remoto, instale o PostgreSQL localmente:

#### Instalar PostgreSQL no Windows

1. **Baixar:**
   - https://www.postgresql.org/download/windows/
   - Ou via chocolatey: `choco install postgresql`

2. **Instalar:**
   - Execute o instalador
   - Senha padrão: `postgres`
   - Porta: `5432`

3. **Criar banco de dados:**

```powershell
# Conectar ao PostgreSQL
psql -U postgres

# No prompt do psql:
CREATE DATABASE cadastro_db;
CREATE USER cadastro_user WITH PASSWORD 'Hno@uw@q';
GRANT ALL PRIVILEGES ON DATABASE cadastro_db TO cadastro_user;
\q
```

4. **Atualizar .env:**

```env
DB_HOST=localhost
DB_PORT=5432
DB_NAME=cadastro_db
DB_USER=cadastro_user
DB_PASSWORD=Hno@uw@q
DB_SSL_MODE=disable
```

5. **Executar migrations:**

```powershell
cd database
.\run_migrations.ps1
```

---

### Opção 2: Usar Docker

Se você tem Docker instalado:

#### 1. Criar container PostgreSQL

```powershell
docker run --name postgres-cadastro `
  -e POSTGRES_PASSWORD=Hno@uw@q `
  -e POSTGRES_USER=cadastro_user `
  -e POSTGRES_DB=cadastro_db `
  -p 5432:5432 `
  -d postgres:15
```

#### 2. Verificar se está rodando

```powershell
docker ps
```

Deve aparecer:
```
CONTAINER ID   IMAGE         STATUS         PORTS
abc123         postgres:15   Up 2 minutes   0.0.0.0:5432->5432/tcp
```

#### 3. Atualizar .env

```env
DB_HOST=localhost
DB_PORT=5432
DB_NAME=cadastro_db
DB_USER=cadastro_user
DB_PASSWORD=Hno@uw@q
DB_SSL_MODE=disable
```

#### 4. Executar migrations

```powershell
cd database
.\run_migrations.ps1
```

---

### Opção 3: Usar Serviço em Nuvem Gratuito

#### Supabase (PostgreSQL gratuito)

1. **Criar conta:**
   - https://supabase.com/

2. **Criar projeto:**
   - Nome: cadastro-beneficios
   - Senha do banco: Hno@uw@q
   - Região: South America

3. **Copiar credenciais:**
   - Vá em **Settings** > **Database**
   - Copie:
     - Host
     - Port
     - Database
     - User
     - Password

4. **Atualizar .env:**

```env
DB_HOST=db.xxxxx.supabase.co
DB_PORT=5432
DB_NAME=postgres
DB_USER=postgres
DB_PASSWORD=sua_senha_aqui
DB_SSL_MODE=require
```

5. **Executar migrations:**

```powershell
cd database
.\run_migrations.ps1
```

---

### Opção 4: Resolver problema do servidor remoto

Se o servidor `77.37.41.41` é seu e você tem acesso:

#### 1. Verificar se PostgreSQL está rodando

SSH no servidor:
```bash
ssh usuario@77.37.41.41
sudo systemctl status postgresql
```

#### 2. Verificar firewall

```bash
# UFW (Ubuntu)
sudo ufw allow 5432/tcp

# Firewalld (CentOS)
sudo firewall-cmd --permanent --add-port=5432/tcp
sudo firewall-cmd --reload
```

#### 3. Configurar PostgreSQL para aceitar conexões remotas

Editar `postgresql.conf`:
```bash
sudo nano /etc/postgresql/15/main/postgresql.conf
```

Alterar:
```
listen_addresses = '*'
```

Editar `pg_hba.conf`:
```bash
sudo nano /etc/postgresql/15/main/pg_hba.conf
```

Adicionar:
```
host    all             all             0.0.0.0/0               md5
```

Reiniciar:
```bash
sudo systemctl restart postgresql
```

---

## 🧪 Testar Conexão

Depois de escolher uma opção, teste:

### Teste 1: Via script Node.js

```bash
cd backend
node test-connection.js
```

### Teste 2: Via backend (porta 3000)

```bash
cd backend
npm run dev
```

Abra outro terminal:
```bash
curl http://localhost:3000/health
```

Resultado esperado:
```json
{
  "status": "ok",
  "timestamp": "2024-12-15T...",
  "environment": "development"
}
```

---

## 📊 Resumo das Opções

| Opção | Prós | Contras | Recomendado para |
|-------|------|---------|------------------|
| **PostgreSQL Local** | Sem dependências externas | Consome recursos locais | Desenvolvimento offline |
| **Docker** | Fácil de limpar/recriar | Requer Docker instalado | Desenvolvimento e testes |
| **Supabase** | Gratuito, gerenciado | Requer internet | Desenvolvimento remoto |
| **Servidor próprio** | Controle total | Requer gerenciamento | Produção |

---

## ✅ Checklist

Depois que a conexão funcionar:

- [ ] Testar conexão: `node backend/test-connection.js`
- [ ] Executar migrations: `.\database\run_migrations.ps1`
- [ ] Iniciar backend: `cd backend && npm run dev`
- [ ] Testar health check: `curl http://localhost:3000/health`
- [ ] Executar Flutter app: `flutter run`
- [ ] Testar login no app

---

## 💬 Qual opção escolher?

**Recomendo começar com Docker (Opção 2)** se você tiver Docker instalado, pois é:
- ✅ Rápido de configurar (1 comando)
- ✅ Isolado (não afeta seu sistema)
- ✅ Fácil de resetar (docker rm -f postgres-cadastro)

Se não tiver Docker, use **PostgreSQL Local (Opção 1)**.

---

**Última atualização:** 15/12/2024
