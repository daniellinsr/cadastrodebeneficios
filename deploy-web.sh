#!/bin/bash

# Script de Deploy para Flutter Web - VPS Hostinger
# IP: 77.37.41.41
# Domínio: http://cadastro.helthcorp.com.br

echo "🚀 Iniciando deploy do frontend Flutter Web..."

# Cores para output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Configurações
VPS_IP="77.37.41.41"
VPS_USER="root"
DEPLOY_PATH="/opt/apps/cadastro/cadastrodebeneficios-web"
APP_NAME="cadastro-beneficios-web"

echo -e "${YELLOW}📦 Preparando arquivos para deploy...${NC}"

# Criar diretório temporário para build
BUILD_DIR="./deploy-build-web"
rm -rf $BUILD_DIR
mkdir -p $BUILD_DIR

# Copiar arquivos necessários
echo "Copiando arquivos..."
cp -r lib $BUILD_DIR/
cp -r assets $BUILD_DIR/ 2>/dev/null || echo "Pasta assets não encontrada, continuando..."
cp -r web $BUILD_DIR/
cp pubspec.yaml $BUILD_DIR/
cp pubspec.lock $BUILD_DIR/
cp analysis_options.yaml $BUILD_DIR/ 2>/dev/null || true
cp Dockerfile.web $BUILD_DIR/Dockerfile
cp nginx.conf $BUILD_DIR/
cp docker-stack-web.yml $BUILD_DIR/docker-stack.yml
cp .env.production $BUILD_DIR/.env
cp .dockerignore $BUILD_DIR/

echo -e "${GREEN}✅ Arquivos preparados${NC}"

echo -e "${YELLOW}📤 Enviando arquivos para o servidor...${NC}"

# Criar diretório no servidor se não existir
ssh $VPS_USER@$VPS_IP "mkdir -p $DEPLOY_PATH"

# Enviar arquivos via rsync
rsync -avz --delete \
  --exclude '.git' \
  --exclude 'build' \
  --exclude '.dart_tool' \
  --exclude 'android' \
  --exclude 'ios' \
  --exclude 'backend' \
  $BUILD_DIR/ $VPS_USER@$VPS_IP:$DEPLOY_PATH/

echo -e "${GREEN}✅ Arquivos enviados${NC}"

echo -e "${YELLOW}🐳 Fazendo build e iniciando containers no servidor...${NC}"

# Executar comandos no servidor
ssh $VPS_USER@$VPS_IP << 'ENDSSH'
cd /opt/apps/cadastro/cadastrodebeneficios-web

# Build da nova imagem
echo "🔨 Fazendo build da nova imagem Flutter Web..."
docker build -f Dockerfile -t cadastrodebeneficios-web:latest .

# Verificar se o stack web já existe
STACK_EXISTS=$(docker service ls | grep cadastro_web || true)

if [ ! -z "$STACK_EXISTS" ]; then
  echo "⏹️  Atualizando serviço web..."
  docker service update --image cadastrodebeneficios-web:latest cadastro_web
else
  echo "🚀 Fazendo deploy do stack web..."
  docker stack deploy -c docker-stack.yml cadastro
fi

# Aguardar alguns segundos
echo "⏳ Aguardando serviço iniciar..."
sleep 10

# Verificar serviços
echo "📊 Serviços do stack cadastro:"
docker service ls | grep cadastro

# Verificar logs do serviço web
echo "📋 Últimos logs do cadastro_web:"
docker service logs --tail=50 cadastro_web || true

# Verificar se o serviço está rodando
echo "🔍 Verificando se o serviço está rodando..."
SERVICE_STATUS=$(docker service ls | grep cadastro_web | awk '{print $4}')
if [[ "$SERVICE_STATUS" == *"1/1"* ]]; then
  echo "✅ Serviço cadastro_web está rodando!"
else
  echo "⚠️  Status do serviço: $SERVICE_STATUS"
  echo "Aguarde alguns segundos para o serviço inicializar completamente..."
fi
ENDSSH

echo -e "${GREEN}✅ Deploy concluído!${NC}"

# Limpar diretório temporário
rm -rf $BUILD_DIR

echo -e "${GREEN}🎉 Frontend disponível em: http://${VPS_IP}${NC}"
echo -e "${GREEN}🎉 Domínio: http://cadastro.helthcorp.com.br${NC}"
echo -e "${YELLOW}💡 Para ver os logs: ssh ${VPS_USER}@${VPS_IP} 'docker service logs -f cadastro_web'${NC}"
