# 🌐 Deploy Flutter Web - Docker Swarm

## 📋 Pré-requisitos

- Backend já deve estar rodando em `http://77.37.41.41:3002`
- Docker e Docker Swarm configurados no servidor
- SSH configurado para acesso ao servidor

## 🚀 Deploy Rápido

### Opção 1: Script Automático (Recomendado)

```bash
# Na raiz do projeto
chmod +x deploy-web.sh
./deploy-web.sh
```

### Opção 2: Deploy Manual

#### 1️⃣ No servidor, criar diretório

```bash
ssh root@77.37.41.41
mkdir -p /opt/apps/cadastro/cadastrodebeneficios-web
```

#### 2️⃣ Build e Deploy

```bash
# No servidor
cd /opt/apps/cadastro/cadastrodebeneficios-web

# Build da imagem
docker build -f Dockerfile -t cadastrodebeneficios-web:latest .

# Deploy do stack
docker stack deploy -c docker-stack.yml cadastro

# Verificar status
docker service ls | grep cadastro
docker service ps cadastro_web
docker service logs cadastro_web --tail=50
```

## ✅ Verificar se funcionou

### Teste 1: Health Check

```bash
curl http://77.37.41.41/health
# Deve retornar: healthy
```

### Teste 2: Página principal

Abra no navegador:
- http://77.37.41.41
- http://cadastro.helthcorp.com.br

## 🔧 Comandos Úteis

### Ver logs do web
```bash
ssh root@77.37.41.41
docker service logs -f cadastro_web
```

### Atualizar aplicação web
```bash
cd /opt/apps/cadastro/cadastrodebeneficios-web

# Rebuild da imagem
docker build -f Dockerfile -t cadastrodebeneficios-web:latest .

# Atualizar serviço (sem downtime)
docker service update --image cadastrodebeneficios-web:latest cadastro_web
```

### Ver status de todos os serviços
```bash
docker service ls | grep cadastro
# Deve mostrar:
# - cadastro_backend (porta 3002)
# - cadastro_web (porta 80)
# - cadastro_postgres (porta 5411)
```

### Escalar serviço web (se necessário)
```bash
docker service scale cadastro_web=2
```

## 🌐 URLs da Aplicação

- **Frontend Web**: http://77.37.41.41 ou http://cadastro.helthcorp.com.br
- **Backend API**: http://77.37.41.41:3002
- **Health Check Web**: http://77.37.41.41/health
- **Health Check API**: http://77.37.41.41:3002/health

## 🔍 Troubleshooting

### Web não carrega?

```bash
# Ver logs
docker service logs cadastro_web --tail=100

# Ver status detalhado
docker service ps cadastro_web --no-trunc

# Verificar se porta 80 está livre
netstat -tulpn | grep :80
```

### Erro de conexão com backend?

Verifique se o arquivo `.env.production` tem a URL correta:
```
BACKEND_API_URL=http://77.37.41.41:3002
```

### Rebuild completo

```bash
cd /opt/apps/cadastro/cadastrodebeneficios-web

# Remover serviço
docker service rm cadastro_web

# Aguardar
sleep 5

# Rebuild
docker build -f Dockerfile -t cadastrodebeneficios-web:latest . --no-cache

# Redeploy
docker stack deploy -c docker-stack.yml cadastro
```

## 📊 Arquitetura Final

```
┌─────────────────────────────────────────┐
│         Servidor 77.37.41.41            │
├─────────────────────────────────────────┤
│                                         │
│  ┌─────────────┐  Porta 80             │
│  │ Flutter Web │  (HTTP)               │
│  │   (nginx)   │                       │
│  └──────┬──────┘                       │
│         │                               │
│         │ Consome API                   │
│         ▼                               │
│  ┌─────────────┐  Porta 3002           │
│  │   Backend   │  (Node.js/Express)    │
│  │  TypeScript │                       │
│  └──────┬──────┘                       │
│         │                               │
│         │ Conecta                       │
│         ▼                               │
│  ┌─────────────┐  Porta 5411           │
│  │  PostgreSQL │  (Database)           │
│  │     18      │                       │
│  └─────────────┘                       │
│                                         │
│  Rede: cadastro_cadastro-beneficios    │
│  Stack: cadastro (Docker Swarm)        │
└─────────────────────────────────────────┘
```

## ⚠️ Importante

- Porta 80 será usada pelo frontend
- Certifique-se de que a porta 80 não está sendo usada por outro serviço
- O backend DEVE estar rodando antes de fazer deploy do frontend
- Todos os serviços estão na mesma rede overlay do Docker Swarm
