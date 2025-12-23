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
cp docker-compose.yml $BUILD_DIR/
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

# Parar APENAS o container do cadastro-beneficios
echo "⏹️  Parando container cadastro-beneficios-backend..."
docker-compose stop backend || true
docker-compose rm -f backend || true

# Remover APENAS a imagem antiga deste projeto (não todas as imagens)
echo "🗑️  Removendo imagem antiga do cadastro-beneficios..."
OLD_IMAGE=$(docker images cadastrodebeneficios-backend -q)
if [ ! -z "$OLD_IMAGE" ]; then
  docker rmi -f $OLD_IMAGE || true
fi

# Build da nova imagem com nome específico
echo "🔨 Fazendo build da nova imagem..."
docker-compose build --no-cache backend

# Iniciar APENAS o container do cadastro-beneficios
echo "▶️  Iniciando container cadastro-beneficios-backend..."
docker-compose up -d backend

# Aguardar alguns segundos
sleep 5

# Verificar status APENAS deste container
echo "📊 Status do container cadastro-beneficios:"
docker-compose ps backend

# Verificar logs APENAS deste container
echo "📋 Últimos logs do cadastro-beneficios:"
docker-compose logs --tail=50 backend

# Verificar se está rodando
echo "🔍 Verificando se o container está rodando..."
if docker-compose ps backend | grep -q "Up"; then
  echo "✅ Container cadastro-beneficios-backend está rodando!"
else
  echo "❌ ERRO: Container não está rodando. Verificar logs acima."
fi
ENDSSH

echo -e "${GREEN}✅ Deploy concluído!${NC}"

# Limpar diretório temporário
rm -rf $BUILD_DIR

echo -e "${GREEN}🎉 Backend disponível em: http://${VPS_IP}:3002${NC}"
echo -e "${GREEN}🎉 Domínio: http://cadastro.helthcorp.com.br:3002${NC}"
echo -e "${YELLOW}💡 Para ver os logs: ssh ${VPS_USER}@${VPS_IP} 'cd ${DEPLOY_PATH} && docker-compose logs -f'${NC}"
