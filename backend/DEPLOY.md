# 🚀 Guia de Deploy - Backend Cadastro de Benefícios

## 📋 Informações do Servidor

- **IP do Servidor**: 77.37.41.41
- **Domínio**: http://cadastro.helthcorp.com.br
- **Porta do Backend**: 3002
- **URL da API**: http://cadastro.helthcorp.com.br:3002

## 🔧 Pré-requisitos no Servidor VPS

1. **Docker instalado**
```bash
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh
```

2. **Docker Compose instalado**
```bash
sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
```

3. **Porta 3002 liberada no firewall**
```bash
sudo ufw allow 3002/tcp
```

## 📦 Métodos de Deploy

### Método 1: Deploy Automático (Recomendado)

**No Windows (usando Git Bash ou WSL):**

```bash
cd backend
chmod +x deploy.sh
./deploy.sh
```

### Método 2: Deploy Manual

#### Passo 1: Conectar ao servidor

```bash
ssh root@77.37.41.41
```

#### Passo 2: Criar diretório da aplicação

```bash
mkdir -p /opt/cadastro-beneficios
cd /opt/cadastro-beneficios
```

#### Passo 3: Enviar arquivos para o servidor

**No seu computador local:**

```bash
cd backend
scp -r src package*.json tsconfig.json Dockerfile .dockerignore docker-compose.yml .env.production root@77.37.41.41:/opt/cadastro-beneficios/
```

#### Passo 4: No servidor, renomear .env.production

```bash
cd /opt/cadastro-beneficios
mv .env.production .env
```

#### Passo 5: Build e iniciar containers

```bash
docker-compose build
docker-compose up -d
```

#### Passo 6: Verificar status

```bash
docker-compose ps
docker-compose logs -f
```

## 🔍 Verificar se o Backend está funcionando

### Teste de Health Check

```bash
curl http://77.37.41.41:3002/health
```

**Resposta esperada:**
```json
{
  "status": "ok",
  "timestamp": "2024-12-23T...",
  "environment": "production"
}
```

### Teste de conexão com banco de dados

O servidor já testa a conexão automaticamente ao iniciar. Verifique os logs:

```bash
docker-compose logs backend
```

Deve aparecer: `✅ Database connection successful`

## 📊 Comandos Úteis

### Ver logs em tempo real
```bash
ssh root@77.37.41.41
cd /opt/cadastro-beneficios
docker-compose logs -f backend
```

### Parar o backend
```bash
docker-compose down
```

### Reiniciar o backend
```bash
docker-compose restart
```

### Reconstruir e reiniciar (após mudanças no código)
```bash
docker-compose down
docker-compose build --no-cache
docker-compose up -d
```

### Ver status dos containers
```bash
docker-compose ps
```

### Acessar shell do container
```bash
docker-compose exec backend sh
```

## 🔐 Configuração de HTTPS (Opcional - Recomendado)

### Instalar Nginx como Reverse Proxy

1. Instalar Nginx:
```bash
sudo apt update
sudo apt install nginx
```

2. Criar configuração:
```bash
sudo nano /etc/nginx/sites-available/cadastro
```

3. Adicionar configuração:
```nginx
server {
    listen 80;
    server_name cadastro.helthcorp.com.br;

    location / {
        proxy_pass http://localhost:3002;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_cache_bypass $http_upgrade;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
```

4. Ativar site:
```bash
sudo ln -s /etc/nginx/sites-available/cadastro /etc/nginx/sites-enabled/
sudo nginx -t
sudo systemctl restart nginx
```

5. Instalar SSL com Let's Encrypt:
```bash
sudo apt install certbot python3-certbot-nginx
sudo certbot --nginx -d cadastro.helthcorp.com.br
```

## 🔄 Atualizar o Frontend

Após o deploy do backend, atualize a URL da API no frontend:

**Arquivo: `lib/core/config/api_config.dart`**

```dart
static const String baseUrl = 'http://cadastro.helthcorp.com.br:3002/api/v1';
```

## 🐛 Troubleshooting

### Problema: Container não inicia

**Verificar logs:**
```bash
docker-compose logs backend
```

**Soluções comuns:**
- Verificar se a porta 3002 não está em uso: `sudo lsof -i :3002`
- Verificar se o arquivo .env existe: `ls -la .env`
- Verificar permissões: `sudo chown -R 1001:1001 /opt/cadastro-beneficios`

### Problema: Erro de conexão com banco de dados

**Verificar conectividade:**
```bash
telnet 77.37.41.41 5411
```

**Verificar variáveis de ambiente:**
```bash
docker-compose exec backend env | grep DB_
```

### Problema: CORS Error no frontend

**Verificar ALLOWED_ORIGINS no .env:**
```bash
cat .env | grep ALLOWED_ORIGINS
```

Deve incluir o domínio do frontend.

## 📝 Notas Importantes

1. **Backup**: Sempre faça backup antes de atualizar:
   ```bash
   docker-compose exec backend sh -c "pg_dump -h \$DB_HOST -U \$DB_USER \$DB_NAME > /tmp/backup.sql"
   docker cp cadastro-beneficios-backend:/tmp/backup.sql ./backup-$(date +%Y%m%d).sql
   ```

2. **Variáveis de Ambiente**: Nunca comite o arquivo `.env` no Git

3. **Logs**: Configure rotação de logs para evitar disco cheio:
   ```bash
   docker-compose logs --tail=1000 > logs.txt
   ```

4. **Monitoramento**: Configure alertas para monitorar a saúde do servidor

## 🆘 Suporte

Em caso de problemas, verifique:
1. Logs do container: `docker-compose logs -f`
2. Status do container: `docker-compose ps`
3. Conectividade de rede: `curl http://localhost:3002/health`
4. Espaço em disco: `df -h`
5. Memória disponível: `free -h`
