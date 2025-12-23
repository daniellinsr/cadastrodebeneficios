#!/bin/bash

# Script de Deploy para VPS Hostinger
# IP: 77.37.41.41
# Domínio: http://cadastro.helthcorp.com.br

echo "🚀 Iniciando deploy do backend..."

# Cores para output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Configurações
VPS_IP="77.37.41.41"
VPS_USER="root"  # Altere se necessário
DEPLOY_PATH="/opt/apps/cadastro/cadastrodebeneficios"
APP_NAME="cadastro-beneficios-backend"

echo -e "${YELLOW}📦 Preparando arquivos para deploy...${NC}"

# Criar diretório temporário para build
BUILD_DIR="./deploy-build"
rm -rf $BUILD_DIR
mkdir -p $BUILD_DIR

# Copiar arquivos necessários
cp -r src $BUILD_DIR/
cp package*.json $BUILD_DIR/
cp tsconfig.json $BUILD_DIR/
cp Dockerfile $BUILD_DIR/
cp .dockerignore $BUILD_DIR/
cp docker-stack.yml $BUILD_DIR/
cp .env.production $BUILD_DIR/.env

echo -e "${GREEN}✅ Arquivos preparados${NC}"

echo -e "${YELLOW}📤 Enviando arquivos para o servidor...${NC}"

# Criar diretório no servidor se não existir
ssh $VPS_USER@$VPS_IP "mkdir -p $DEPLOY_PATH"

# Enviar arquivos via rsync
rsync -avz --delete \
  --exclude 'node_modules' \
  --exclude 'dist' \
  --exclude '.git' \
  $BUILD_DIR/ $VPS_USER@$VPS_IP:$DEPLOY_PATH/

echo -e "${GREEN}✅ Arquivos enviados${NC}"

echo -e "${YELLOW}🐳 Fazendo build e iniciando containers no servidor...${NC}"

# Executar comandos no servidor
ssh $VPS_USER@$VPS_IP << 'ENDSSH'
cd /opt/apps/cadastro/cadastrodebeneficios

# Exportar variáveis de ambiente do .env
export $(grep -v '^#' .env | xargs)

# Build da nova imagem
echo "🔨 Fazendo build da nova imagem..."
docker build -t cadastrodebeneficios-backend:latest .

# Verificar se o stack já existe
STACK_EXISTS=$(docker stack ls | grep cadastro || true)

if [ ! -z "$STACK_EXISTS" ]; then
  echo "⏹️  Removendo stack antigo do cadastro-beneficios..."
  docker stack rm cadastro
  echo "⏳ Aguardando stack ser removido completamente..."
  sleep 10
fi

# Deploy do novo stack
echo "🚀 Fazendo deploy do stack cadastro-beneficios..."
docker stack deploy -c docker-stack.yml cadastro

# Aguardar alguns segundos
echo "⏳ Aguardando serviços iniciarem..."
sleep 10

# Verificar status do stack
echo "📊 Status do stack cadastro:"
docker stack ps cadastro

# Verificar serviços
echo "📊 Serviços do stack:"
docker service ls | grep cadastro

# Verificar logs do serviço
echo "📋 Últimos logs do cadastro_backend:"
docker service logs --tail=50 cadastro_backend || true

# Verificar se o serviço está rodando
echo "🔍 Verificando se o serviço está rodando..."
SERVICE_STATUS=$(docker service ls | grep cadastro_backend | awk '{print $4}')
if [[ "$SERVICE_STATUS" == *"1/1"* ]]; then
  echo "✅ Serviço cadastro_backend está rodando!"
else
  echo "⚠️  Status do serviço: $SERVICE_STATUS"
  echo "Aguarde alguns segundos para o serviço inicializar completamente..."
fi
ENDSSH

echo -e "${GREEN}✅ Deploy concluído!${NC}"

# Limpar diretório temporário
rm -rf $BUILD_DIR

echo -e "${GREEN}🎉 Backend disponível em: http://${VPS_IP}:3002${NC}"
echo -e "${GREEN}🎉 Domínio: http://cadastro.helthcorp.com.br:3002${NC}"
echo -e "${YELLOW}💡 Para ver os logs: ssh ${VPS_USER}@${VPS_IP} 'cd ${DEPLOY_PATH} && docker-compose logs -f'${NC}"
