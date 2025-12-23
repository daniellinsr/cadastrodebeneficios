# 🚀 Guia Rápido de Deploy

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
mkdir -p /opt/cadastro-beneficios
exit

# Enviar arquivos
cd deploy-build
scp -r * root@77.37.41.41:/opt/cadastro-beneficios/
```

#### 3️⃣ Iniciar no servidor

```bash
# Conectar novamente
ssh root@77.37.41.41

# Ir para o diretório
cd /opt/cadastro-beneficios

# Parar versão antiga (se existir)
docker-compose down

# Construir e iniciar
docker-compose build
docker-compose up -d

# Verificar
docker-compose ps
docker-compose logs -f
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

### Ver logs
```bash
ssh root@77.37.41.41
cd /opt/cadastro-beneficios
docker-compose logs -f
```

### Parar backend
```bash
docker-compose down
```

### Reiniciar backend
```bash
docker-compose restart
```

### Atualizar código
```bash
# 1. Envie novos arquivos
# 2. No servidor:
cd /opt/cadastro-beneficios
docker-compose down
docker-compose build --no-cache
docker-compose up -d
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
