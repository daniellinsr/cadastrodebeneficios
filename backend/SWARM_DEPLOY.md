# 🐳 Deploy com Docker Swarm

## ⚠️ Servidor usando Docker Swarm

Este servidor utiliza **Docker Swarm** (não docker-compose standalone). Os comandos são diferentes.

## 📦 Deploy Rápido

### No servidor, execute:

```bash
cd /opt/apps/cadastro/cadastrodebeneficios

# 1. Criar arquivo .env (apenas na primeira vez)
cat > .env << 'EOF'
DB_HOST=77.37.41.41
DB_PORT=5411
DB_NAME=cadastro_db
DB_USER=cadastro_user
DB_PASSWORD=Hno@uw@q
DB_SSL_MODE=disable
JWT_SECRET=cadastro_beneficios_super_secret_key_change_in_production_2024
JWT_EXPIRES_IN=7d
REFRESH_TOKEN_EXPIRES_IN=30d
PORT=3002
NODE_ENV=production
GOOGLE_CLIENT_ID=517374779970-5ltpsdagq2i99j9bab21aigch3opcln0.apps.googleusercontent.com,517374779970-7na2erqfmdntjrr8n41r83m2cusjf1je.apps.googleusercontent.com,403775802042-dr9hvctbr6qfildd767us0o057m3iu3m.apps.googleusercontent.com
FIREBASE_PROJECT_ID=cadastro-beneficios
ALLOWED_ORIGINS=http://cadastro.helthcorp.com.br,https://cadastro.helthcorp.com.br,http://localhost:*,https://localhost:*
SMTP_HOST=smtp.gmail.com
SMTP_PORT=587
SMTP_SECURE=false
SMTP_USER=cartaobeneficios0@gmail.com
SMTP_PASS=uoqbujydmtwcliim
SMTP_FROM="Cartão de Benefícios" <cartaobeneficios0@gmail.com>
FRONTEND_URL=http://cadastro.helthcorp.com.br
EOF

# 2. Exportar variáveis de ambiente
export $(grep -v '^#' .env | xargs)

# 3. Build da imagem
docker build -t cadastrodebeneficios-backend:latest .

# 4. Deploy do stack
docker stack deploy -c docker-stack.yml cadastro

# 5. Verificar
docker stack ps cadastro
docker service ls | grep cadastro
docker service logs cadastro_backend --tail=50
```

## 🔄 Atualizar Aplicação

```bash
cd /opt/apps/cadastro/cadastrodebeneficios

# Exportar variáveis
export $(grep -v '^#' .env | xargs)

# Rebuild da imagem
docker build -t cadastrodebeneficios-backend:latest .

# Atualizar serviço (sem downtime)
docker service update --image cadastrodebeneficios-backend:latest cadastro_backend

# OU remover e recriar stack
docker stack rm cadastro
sleep 10
docker stack deploy -c docker-stack.yml cadastro
```

## 📊 Comandos Úteis Docker Swarm

### Ver stacks
```bash
docker stack ls
```

### Ver serviços do stack cadastro
```bash
docker stack services cadastro
docker service ls | grep cadastro
```

### Ver status detalhado
```bash
docker stack ps cadastro
docker stack ps cadastro --no-trunc
```

### Ver logs do serviço
```bash
docker service logs cadastro_backend
docker service logs -f cadastro_backend  # follow
docker service logs --tail=100 cadastro_backend
```

### Escalar serviço (aumentar réplicas)
```bash
docker service scale cadastro_backend=2
```

### Inspecionar serviço
```bash
docker service inspect cadastro_backend
docker service inspect cadastro_backend --pretty
```

### Remover stack
```bash
docker stack rm cadastro
```

### Ver containers do serviço
```bash
docker ps | grep cadastro
```

### Entrar no container
```bash
# Primeiro, pegue o ID do container
CONTAINER_ID=$(docker ps | grep cadastro_backend | awk '{print $1}')

# Entre no container
docker exec -it $CONTAINER_ID sh
```

## 🔍 Troubleshooting

### Serviço não inicia?
```bash
# Ver logs completos
docker service logs cadastro_backend

# Ver tasks falhas
docker stack ps cadastro --no-trunc --filter "desired-state=running"
```

### Porta ocupada?
```bash
# Ver quem está usando a porta 3002
sudo lsof -i :3002
sudo netstat -tulpn | grep 3002
```

### Remover e recriar tudo
```bash
# Remover stack
docker stack rm cadastro

# Aguardar remoção completa
sleep 10

# Verificar se foi removido
docker stack ls

# Recriar
cd /opt/apps/cadastro/cadastrodebeneficios
export $(grep -v '^#' .env | xargs)
docker stack deploy -c docker-stack.yml cadastro
```

## ⚠️ Diferenças Swarm vs Docker Compose

| Docker Compose | Docker Swarm |
|---------------|--------------|
| `docker-compose up` | `docker stack deploy -c file.yml name` |
| `docker-compose down` | `docker stack rm name` |
| `docker-compose ps` | `docker stack ps name` |
| `docker-compose logs` | `docker service logs name_service` |
| `docker-compose restart` | `docker service update --force name_service` |

## 🎯 Comandos Mais Usados

```bash
# Deploy
cd /opt/apps/cadastro/cadastrodebeneficios
export $(grep -v '^#' .env | xargs)
docker build -t cadastrodebeneficios-backend:latest .
docker stack deploy -c docker-stack.yml cadastro

# Logs
docker service logs -f cadastro_backend

# Status
docker stack ps cadastro
docker service ls | grep cadastro

# Atualizar
docker service update --force cadastro_backend

# Remover
docker stack rm cadastro
```

## 🔐 Segurança - Comandos Seguros

### ✅ SEGUROS (afetam apenas cadastro)
```bash
docker stack rm cadastro
docker service logs cadastro_backend
docker stack ps cadastro
docker service update cadastro_backend
```

### ❌ PERIGOSOS (afetam TUDO)
```bash
docker stack rm $(docker stack ls -q)  # Remove TODOS os stacks
docker service rm $(docker service ls -q)  # Remove TODOS os serviços
docker system prune -a  # Remove TUDO
```

## 📱 Teste Final

```bash
# Health check
curl http://localhost:3002/health

# Externamente
curl http://77.37.41.41:3002/health
```

Deve retornar:
```json
{"status":"ok","timestamp":"...","environment":"production"}
```
