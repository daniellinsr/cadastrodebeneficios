# 🚀 Guia Rápido de Deploy

## ⚠️ IMPORTANTE - Servidor Compartilhado

Este servidor tem OUTRAS APLICAÇÕES rodando. Os scripts foram configurados para afetar APENAS o container `cadastro-beneficios-backend`. Não use comandos genéricos como `docker stop $(docker ps -q)` ou `docker-compose down` sem especificar o serviço.

**Diretório da aplicação**: `/opt/apps/cadastro/cadastrodebeneficios`

## Deploy em 5 Minutos

### Opção 1: Usando PowerShell (Windows)

```powershell
cd backend
.\deploy.ps1
```

Siga as instruções na tela.

### Opção 2: Deploy Manual Simples

#### 1️⃣ Preparar arquivos

No PowerShell:
```powershell
cd backend

# Criar pasta de deploy
mkdir deploy-build

# Copiar arquivos
cp -r src deploy-build\
cp package*.json deploy-build\
cp tsconfig.json deploy-build\
cp Dockerfile deploy-build\
cp .dockerignore deploy-build\
cp docker-compose.yml deploy-build\
cp .env.production deploy-build\.env
```

#### 2️⃣ Enviar para servidor

```powershell
# Conectar ao servidor
ssh root@77.37.41.41

# No servidor, criar diretório
mkdir -p /opt/apps/cadastro/cadastrodebeneficios
exit

# Enviar arquivos
cd deploy-build
scp -r * root@77.37.41.41:/opt/apps/cadastro/cadastrodebeneficios/
```

#### 3️⃣ Iniciar no servidor

```bash
# Conectar novamente
ssh root@77.37.41.41

# Ir para o diretório
cd /opt/apps/cadastro/cadastrodebeneficios

# Parar APENAS o container do cadastro (NÃO afeta outras aplicações)
docker-compose stop backend
docker-compose rm -f backend

# Construir e iniciar APENAS o cadastro-beneficios
docker-compose build --no-cache backend
docker-compose up -d backend

# Verificar APENAS este container
docker-compose ps backend
docker-compose logs -f backend
```

## ✅ Verificar se funcionou

### Teste 1: Health Check

```bash
curl http://77.37.41.41:3002/health
```

Deve retornar:
```json
{"status":"ok","timestamp":"...","environment":"production"}
```

### Teste 2: Pelo navegador

Abra: http://77.37.41.41:3002/health

## 🔧 Comandos Úteis

### Ver logs (APENAS cadastro-beneficios)
```bash
ssh root@77.37.41.41
cd /opt/apps/cadastro/cadastrodebeneficios
docker-compose logs -f backend
```

### Parar backend (APENAS cadastro-beneficios)
```bash
docker-compose stop backend
```

### Reiniciar backend (APENAS cadastro-beneficios)
```bash
docker-compose restart backend
```

### Atualizar código (APENAS cadastro-beneficios)
```bash
# 1. Envie novos arquivos
# 2. No servidor:
cd /opt/apps/cadastro/cadastrodebeneficios
docker-compose stop backend
docker-compose rm -f backend
docker-compose build --no-cache backend
docker-compose up -d backend
```

### ⚠️ NUNCA USE (afetaria TODAS as aplicações):
```bash
# ❌ NÃO FAÇA ISSO:
docker-compose down  # Para TODOS os serviços do docker-compose
docker stop $(docker ps -q)  # Para TODOS os containers do servidor
docker system prune -a  # Remove TODAS as imagens
```

## 🌐 URLs Importantes

- **API Health**: http://77.37.41.41:3002/health
- **API Auth**: http://77.37.41.41:3002/api/v1/auth
- **API Verification**: http://77.37.41.41:3002/api/v1/verification
- **Domínio**: http://cadastro.helthcorp.com.br:3002

## 🆘 Problemas Comuns

### Container não inicia?
```bash
docker-compose logs backend
```

### Porta ocupada?
```bash
sudo lsof -i :3002
sudo kill -9 <PID>
```

### Erro de permissão?
```bash
sudo chown -R 1001:1001 /opt/cadastro-beneficios
```

## 📱 Atualizar Frontend

Após deploy do backend, atualize no Flutter:

**Arquivo: `lib/core/config/api_config.dart`**

```dart
class ApiConfig {
  static const String baseUrl = 'http://cadastro.helthcorp.com.br:3002/api/v1';
  // ou
  static const String baseUrl = 'http://77.37.41.41:3002/api/v1';
}
```

Depois:
```bash
flutter clean
flutter pub get
flutter run
```

## ✨ Pronto!

Seu backend está rodando em produção! 🎉
