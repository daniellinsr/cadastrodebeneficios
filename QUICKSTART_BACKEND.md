# 🚀 QuickStart - Backend + Frontend

Guia rápido para colocar o sistema completo funcionando em menos de 5 minutos!

---

## ✅ Pré-requisitos

Certifique-se de ter instalado:
- ✅ Node.js (v18+)
- ✅ Flutter (v3.16+)
- ✅ PostgreSQL Client (psql)

---

## 🎯 Passo a Passo

### 1️⃣ Executar Migrations do PostgreSQL

**Windows:**
```powershell
cd database
.\run_migrations.ps1
```

**Linux/Mac:**
```bash
cd database
chmod +x run_migrations.sh
./run_migrations.sh
```

**Resultado esperado:**
```
✅ Migration 001: users tables - SUCCESS
✅ Migration 002: cards table - SUCCESS
✅ Migration 003: transactions table - SUCCESS
✅ Migration 004: addresses table - SUCCESS
```

---

### 2️⃣ Instalar Dependências do Backend

```bash
cd backend
npm install
```

**Aguarde a instalação...**

---

### 3️⃣ Iniciar o Backend

```bash
npm run dev
```

**Resultado esperado:**
```
✅ Database connection successful
🚀 Server running on http://localhost:3000
📊 Environment: development
🔗 Health check: http://localhost:3000/health
```

**Deixe este terminal aberto!**

---

### 4️⃣ Testar o Backend (Opcional)

Abra outro terminal e execute:

```bash
# Windows (PowerShell)
Invoke-WebRequest -Uri http://localhost:3000/health

# Linux/Mac
curl http://localhost:3000/health
```

**Resultado esperado:**
```json
{
  "status": "ok",
  "timestamp": "2024-12-15T10:00:00.000Z",
  "environment": "development"
}
```

---

### 5️⃣ Executar o Flutter App

Em outro terminal (não feche o do backend!):

```bash
# Voltar para a raiz do projeto
cd ..

# Executar o app
flutter run
```

**Escolha o dispositivo quando solicitado:**
```
[1]: Windows (desktop)
[2]: Chrome (web)
[3]: Edge (web)
```

Digite o número e pressione Enter.

---

### 6️⃣ Testar o Sistema

#### Teste 1: Verificar URL do Backend

Nos logs do Flutter, procure por:
```
Backend API URL: http://localhost:3000
```

✅ Se aparecer, está tudo configurado corretamente!

#### Teste 2: Criar uma Conta

1. Abra o app
2. Clique em "Cadastre-se" ou "Criar conta"
3. Preencha:
   - Nome: Seu Nome
   - Email: test@example.com
   - Senha: senha123
   - Telefone: +5511999999999
4. Clique em "Cadastrar"

✅ Deve criar a conta e redirecionar para `/home`

#### Teste 3: Fazer Login

1. Faça logout (se estiver logado)
2. Clique em "Entrar"
3. Preencha:
   - Email: test@example.com
   - Senha: senha123
4. Clique em "Entrar"

✅ Deve fazer login e redirecionar para `/home`

#### Teste 4: Route Guards

1. Faça logout
2. Tente acessar `/home` diretamente (digite na URL ou use navegação)
3. ✅ Deve redirecionar automaticamente para `/login`

4. Faça login
5. Tente acessar `/login` novamente
6. ✅ Deve redirecionar automaticamente para `/home`

---

## 🎉 Pronto!

Se todos os testes passaram, você tem:

- ✅ Backend Node.js rodando
- ✅ PostgreSQL conectado
- ✅ Flutter app funcionando
- ✅ Route guards protegendo rotas
- ✅ Autenticação completa

---

## 🔥 Comandos Úteis

### Backend

```bash
cd backend

# Desenvolvimento (com hot reload)
npm run dev

# Build de produção
npm run build

# Executar produção
npm start

# Ver logs
# (os logs aparecem no terminal onde executou npm run dev)
```

### Flutter

```bash
# Executar no emulador/navegador
flutter run

# Executar em dispositivo específico
flutter devices           # listar dispositivos
flutter run -d <device-id>

# Hot reload (durante execução)
# Pressione 'r' no terminal

# Hot restart (durante execução)
# Pressione 'R' no terminal

# Limpar cache
flutter clean
flutter pub get
```

### PostgreSQL

```bash
# Conectar ao banco
psql -h 77.37.41.41 -U cadastro_user -d cadastro_db

# Listar tabelas
\dt

# Ver estrutura de uma tabela
\d users

# Contar usuários
SELECT COUNT(*) FROM users;

# Ver últimos usuários criados
SELECT id, email, name, created_at FROM users ORDER BY created_at DESC LIMIT 5;
```

---

## ❌ Problemas Comuns

### Backend não inicia

**Erro:** `Error: connect ECONNREFUSED`

**Solução:**
1. Verifique se o PostgreSQL está acessível:
```bash
psql -h 77.37.41.41 -U cadastro_user -d cadastro_db
```

2. Verifique as credenciais no arquivo `backend/.env`

---

### Flutter não conecta ao backend

**Erro:** `DioError [DioErrorType.connectTimeout]`

**Solução:**
1. Verifique se o backend está rodando:
```bash
curl http://localhost:3000/health
```

2. Verifique a URL no arquivo `.env` (raiz do projeto):
```env
BACKEND_API_URL=http://localhost:3000
```

---

### Erro de CORS

**Erro:** `Access to XMLHttpRequest has been blocked by CORS policy`

**Solução:**
O backend já está configurado para aceitar CORS. Mas se aparecer, verifique `backend/.env`:
```env
ALLOWED_ORIGINS=http://localhost:*,https://localhost:*
```

---

### Migrations falham

**Erro:** `psql: FATAL: password authentication failed`

**Solução:**
1. Verifique as credenciais no arquivo `.env` (raiz do projeto)
2. Teste a conexão manualmente:
```bash
psql -h 77.37.41.41 -U cadastro_user -d cadastro_db
```

---

## 📚 Próximos Passos

Depois que tudo estiver funcionando:

1. ✅ Leia [IMPLEMENTATION_SUMMARY.md](./IMPLEMENTATION_SUMMARY.md) - Resumo da implementação
2. ✅ Leia [DEVICE_TESTING_GUIDE.md](./DEVICE_TESTING_GUIDE.md) - Testes em dispositivos reais
3. ✅ Leia [backend/README.md](./backend/README.md) - Documentação do backend
4. ✅ Explore os endpoints com Postman ou Insomnia
5. ✅ Implemente as telas de `/home` e `/admin`

---

## 📞 Ajuda

Se encontrar problemas:

1. Verifique os logs do backend (terminal onde executou `npm run dev`)
2. Verifique os logs do Flutter (terminal onde executou `flutter run`)
3. Consulte [DEVICE_TESTING_GUIDE.md](./DEVICE_TESTING_GUIDE.md) - Seção de Troubleshooting

---

**Tempo total estimado:** 5-10 minutos
**Última atualização:** 15/12/2024
