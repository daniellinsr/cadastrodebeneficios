# Backend API - Sistema de Cadastro de Benefícios

Backend em Node.js/Express com TypeScript para o sistema de cadastro de benefícios.

## Tecnologias

- Node.js + Express
- TypeScript
- PostgreSQL
- JWT para autenticação
- Google OAuth 2.0
- Bcrypt para hashing de senhas

## Instalação

```bash
cd backend
npm install
```

## Configuração

1. Copie o arquivo `.env.example` para `.env`:
```bash
cp .env.example .env
```

2. Configure as variáveis de ambiente no arquivo `.env`

## Executar

### Desenvolvimento
```bash
npm run dev
```

### Produção
```bash
npm run build
npm start
```

## Endpoints Implementados

### Autenticação (`/api/v1/auth`)

#### POST `/login`
Login com email e senha
```json
{
  "email": "usuario@example.com",
  "password": "senha123"
}
```

#### POST `/login/google`
Login com Google OAuth
```json
{
  "id_token": "google_id_token_aqui"
}
```

#### POST `/register`
Registro de novo usuário
```json
{
  "name": "Nome do Usuário",
  "email": "usuario@example.com",
  "password": "senha123",
  "phone_number": "+5511999999999",
  "cpf": "12345678900"
}
```

#### POST `/refresh`
Renovar access token
```json
{
  "refresh_token": "refresh_token_aqui"
}
```

#### POST `/logout`
Fazer logout (revoga refresh token)
```json
{
  "refresh_token": "refresh_token_aqui"
}
```

#### POST `/forgot-password`
Solicitar reset de senha
```json
{
  "email": "usuario@example.com"
}
```

#### GET `/me`
Obter dados do usuário autenticado (requer Bearer token)

Headers:
```
Authorization: Bearer <access_token>
```

## Health Check

```bash
GET /health
```

Retorna:
```json
{
  "status": "ok",
  "timestamp": "2024-12-13T10:00:00.000Z",
  "environment": "development"
}
```

## Estrutura de Pastas

```
backend/
├── src/
│   ├── config/
│   │   ├── database.ts       # Configuração PostgreSQL
│   │   └── jwt.ts            # Configuração JWT
│   ├── controllers/
│   │   └── auth.controller.ts # Controllers de autenticação
│   ├── middleware/
│   │   └── auth.middleware.ts # Middleware de autenticação JWT
│   ├── routes/
│   │   └── auth.routes.ts    # Rotas de autenticação
│   ├── types/
│   │   └── index.ts          # TypeScript types
│   ├── utils/
│   │   └── jwt.utils.ts      # Utilitários JWT
│   └── server.ts             # Servidor principal
├── .env                      # Variáveis de ambiente (não commitado)
├── .env.example              # Template de variáveis
├── package.json
├── tsconfig.json
└── README.md
```

## Banco de Dados

O backend se conecta ao PostgreSQL já configurado. Certifique-se de que as migrations foram executadas:

```bash
cd ../database
./run_migrations.ps1  # Windows
# ou
./run_migrations.sh   # Linux/Mac
```

## Segurança

- Senhas são hasheadas com bcrypt (10 rounds)
- JWT com expiração de 7 dias
- Refresh tokens armazenados no banco
- Headers de segurança com Helmet
- CORS configurável
- SSL obrigatório no PostgreSQL

## Testes

Para testar os endpoints, você pode usar:

### cURL
```bash
curl -X POST http://localhost:3000/api/v1/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"test@example.com","password":"senha123"}'
```

### Postman
Importe a collection de endpoints disponível em `/docs/postman_collection.json` (a ser criado)

## Próximos Passos

- [ ] Implementar envio de email (forgot password)
- [ ] Implementar verificação de telefone (SMS/WhatsApp)
- [ ] Adicionar rate limiting
- [ ] Adicionar logs estruturados
- [ ] Adicionar testes unitários
- [ ] Adicionar testes de integração
- [ ] Documentação Swagger/OpenAPI
