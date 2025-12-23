#!/bin/bash

# Script de Deploy para Flutter Web - Build no Servidor
# Para executar NO SERVIDOR: 77.37.41.41

echo "🚀 Iniciando deploy do frontend Flutter Web (build no servidor)..."

# Cores para output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Configurações
DEPLOY_PATH="/opt/apps/cadastro/cadastrodebeneficios-web"
FLUTTER_VERSION="3.38.3"
FLUTTER_HOME="/opt/flutter"

echo -e "${YELLOW}📦 Preparando ambiente...${NC}"

# Criar diretório se não existir
mkdir -p $DEPLOY_PATH
cd $DEPLOY_PATH

# Verificar se Flutter está instalado
if [ ! -d "$FLUTTER_HOME" ]; then
    echo -e "${YELLOW}📥 Instalando Flutter ${FLUTTER_VERSION}...${NC}"

    # Instalar dependências
    apt-get update
    apt-get install -y curl git unzip xz-utils zip libglu1-mesa wget

    # Baixar Flutter
    cd /opt
    wget -q https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_${FLUTTER_VERSION}-stable.tar.xz
    tar xf flutter_linux_${FLUTTER_VERSION}-stable.tar.xz
    rm flutter_linux_${FLUTTER_VERSION}-stable.tar.xz

    # Configurar Flutter
    export PATH="$FLUTTER_HOME/bin:$PATH"
    flutter doctor -v
    flutter config --enable-web --no-analytics

    echo -e "${GREEN}✅ Flutter instalado${NC}"
else
    echo -e "${GREEN}✅ Flutter já está instalado${NC}"
fi

# Adicionar Flutter ao PATH
export PATH="$FLUTTER_HOME/bin:$PATH"

# Corrigir permissões do Git para Flutter
echo "🔧 Configurando permissões..."
git config --global --add safe.directory /opt/flutter

echo -e "${YELLOW}🔨 Fazendo build do Flutter Web...${NC}"

# Ir para o diretório do código
cd $DEPLOY_PATH

# Verificar se temos os arquivos necessários
if [ ! -f "pubspec.yaml" ]; then
    echo -e "${RED}❌ Erro: pubspec.yaml não encontrado${NC}"
    echo "Execute os seguintes comandos para copiar os arquivos:"
    echo "  git clone <seu-repositorio> $DEPLOY_PATH"
    echo "  ou copie manualmente os arquivos do projeto"
    exit 1
fi

# Criar .env se não existir
if [ ! -f ".env" ]; then
    echo "📝 Criando .env de produção..."
    cat > .env << 'EOF'
BACKEND_API_URL=http://77.37.41.41:3002
BACKEND_API_TIMEOUT=30000
GOOGLE_WEB_CLIENT_ID=403775802042-dr9hvctbr6qfildd767us0o057m3iu3m.apps.googleusercontent.com
ENABLE_GOOGLE_LOGIN=true
ENABLE_DEBUG_LOGS=false
APP_NAME=Sistema de Cartão de Benefícios
APP_VERSION=1.0.0
ENVIRONMENT=production
EOF
fi

# Limpar build anterior
rm -rf build/web

# Instalar dependências
echo "📦 Instalando dependências..."
flutter pub get

# Gerar arquivos necessários com build_runner
echo "🔄 Gerando arquivos com build_runner..."
flutter pub run build_runner build --delete-conflicting-outputs

# Configurar Firebase (criar arquivo vazio se não existir)
if [ ! -f "lib/firebase_options.dart" ]; then
    echo "📝 Criando firebase_options.dart vazio..."
    mkdir -p lib
    cat > lib/firebase_options.dart << 'FIREBASEEOF'
// Firebase Options - Placeholder for Web
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart' show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    throw UnsupportedError('DefaultFirebaseOptions are not supported for this platform.');
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyDummy',
    appId: '1:000000000000:web:0000000000000000000000',
    messagingSenderId: '000000000000',
    projectId: 'cadastro-beneficios',
    authDomain: 'cadastro-beneficios.firebaseapp.com',
    storageBucket: 'cadastro-beneficios.appspot.com',
  );
}
FIREBASEEOF
fi

# Build
echo "🔨 Compilando Flutter Web..."
flutter build web --release

if [ $? -ne 0 ]; then
    echo -e "${RED}❌ Erro no build do Flutter Web${NC}"
    exit 1
fi

echo -e "${GREEN}✅ Build concluído${NC}"

echo -e "${YELLOW}🐳 Criando imagem Docker...${NC}"

# Criar Dockerfile simplificado
cat > Dockerfile << 'DOCKEREOF'
FROM nginx:1.25-alpine

# Copiar arquivos do build para o nginx
COPY build/web /usr/share/nginx/html

# Copiar configuração customizada do nginx
COPY nginx.conf /etc/nginx/conf.d/default.conf

# Expor porta 80
EXPOSE 80

# Healthcheck
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD wget --quiet --tries=1 --spider http://localhost/health || exit 1

CMD ["nginx", "-g", "daemon off;"]
DOCKEREOF

# Build da imagem Docker
docker build -t cadastrodebeneficios-web:latest .

if [ $? -ne 0 ]; then
    echo -e "${RED}❌ Erro ao criar imagem Docker${NC}"
    exit 1
fi

echo -e "${GREEN}✅ Imagem Docker criada${NC}"

echo -e "${YELLOW}🚀 Fazendo deploy no Docker Swarm...${NC}"

# Verificar se o serviço já existe
SERVICE_EXISTS=$(docker service ls | grep cadastro_web || true)

if [ ! -z "$SERVICE_EXISTS" ]; then
    echo "⏹️  Atualizando serviço web..."
    docker service update --image cadastrodebeneficios-web:latest cadastro_web
else
    echo "🚀 Criando serviço web..."
    docker stack deploy -c docker-stack.yml cadastro
fi

# Aguardar alguns segundos
echo "⏳ Aguardando serviço iniciar..."
sleep 10

# Verificar serviços
echo "📊 Serviços do stack cadastro:"
docker service ls | grep cadastro

# Verificar logs
echo "📋 Últimos logs do cadastro_web:"
docker service logs --tail=50 cadastro_web 2>/dev/null || echo "Serviço ainda não tem logs"

# Verificar se o serviço está rodando
echo "🔍 Verificando status..."
SERVICE_STATUS=$(docker service ls | grep cadastro_web | awk '{print $4}')
if [[ "$SERVICE_STATUS" == *"1/1"* ]]; then
    echo -e "${GREEN}✅ Serviço cadastro_web está rodando!${NC}"
    echo -e "${GREEN}🎉 Frontend disponível em: http://77.37.41.41:8080${NC}"
    echo -e "${GREEN}🎉 Domínio: http://cadastro.helthcorp.com.br:8080${NC}"
else
    echo -e "${YELLOW}⚠️  Status do serviço: $SERVICE_STATUS${NC}"
    echo "Aguarde alguns segundos para o serviço inicializar completamente..."
    echo "Para ver logs: docker service logs -f cadastro_web"
fi

echo ""
echo "💡 Comandos úteis:"
echo "  - Ver logs: docker service logs -f cadastro_web"
echo "  - Ver status: docker service ps cadastro_web"
echo "  - Testar: curl http://localhost:8080/health"
