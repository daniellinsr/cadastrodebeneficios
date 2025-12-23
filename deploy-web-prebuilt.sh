#!/bin/bash

# Script de Deploy para Flutter Web - Build Local + Deploy
# IP: 77.37.41.41
# Domínio: http://cadastro.helthcorp.com.br

echo "🚀 Iniciando deploy do frontend Flutter Web (build local)..."

# Cores para output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Configurações
VPS_IP="77.37.41.41"
VPS_USER="root"
DEPLOY_PATH="/opt/apps/cadastro/cadastrodebeneficios-web"

echo -e "${YELLOW}🔨 Fazendo build do Flutter Web localmente...${NC}"

# Copiar .env.production para .env
if [ -f .env.production ]; then
    cp .env.production .env
    echo "✅ Arquivo .env.production copiado para .env"
else
    echo -e "${YELLOW}⚠️  .env.production não encontrado, usando .env atual${NC}"
fi

# Build Flutter Web
echo "Executando flutter build web..."
flutter build web --release

if [ $? -ne 0 ]; then
    echo -e "${RED}❌ Erro no build do Flutter Web${NC}"
    exit 1
fi

echo -e "${GREEN}✅ Build concluído${NC}"

echo -e "${YELLOW}📦 Preparando arquivos para deploy...${NC}"

# Criar diretório temporário
BUILD_DIR="./deploy-build-web"
rm -rf $BUILD_DIR
mkdir -p $BUILD_DIR

# Copiar apenas os arquivos necessários
cp -r build/web $BUILD_DIR/
cp nginx.conf $BUILD_DIR/
cp docker-stack-web.yml $BUILD_DIR/docker-stack.yml

# Criar Dockerfile simplificado (apenas nginx)
cat > $BUILD_DIR/Dockerfile << 'EOF'
FROM nginx:1.25-alpine

# Copiar arquivos do build para o nginx
COPY web /usr/share/nginx/html

# Copiar configuração customizada do nginx
COPY nginx.conf /etc/nginx/conf.d/default.conf

# Expor porta 80
EXPOSE 80

# Healthcheck
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD wget --quiet --tries=1 --spider http://localhost/health || exit 1

CMD ["nginx", "-g", "daemon off;"]
EOF

echo -e "${GREEN}✅ Arquivos preparados${NC}"

echo -e "${YELLOW}📤 Enviando arquivos para o servidor...${NC}"

# Criar diretório no servidor se não existir
ssh $VPS_USER@$VPS_IP "mkdir -p $DEPLOY_PATH"

# Enviar arquivos via rsync
rsync -avz --delete \
  $BUILD_DIR/ $VPS_USER@$VPS_IP:$DEPLOY_PATH/

echo -e "${GREEN}✅ Arquivos enviados${NC}"

echo -e "${YELLOW}🐳 Fazendo build e iniciando containers no servidor...${NC}"

# Executar comandos no servidor
ssh $VPS_USER@$VPS_IP << 'ENDSSH'
cd /opt/apps/cadastro/cadastrodebeneficios-web

# Build da nova imagem
echo "🔨 Fazendo build da imagem nginx..."
docker build -f Dockerfile -t cadastrodebeneficios-web:latest .

# Verificar se o serviço web já existe
SERVICE_EXISTS=$(docker service ls | grep cadastro_web || true)

if [ ! -z "$SERVICE_EXISTS" ]; then
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

echo -e "${GREEN}🎉 Frontend disponível em: http://${VPS_IP}:8080${NC}"
echo -e "${GREEN}🎉 Domínio: http://cadastro.helthcorp.com.br:8080${NC}"
echo -e "${YELLOW}💡 Para ver os logs: ssh ${VPS_USER}@${VPS_IP} 'docker service logs -f cadastro_web'${NC}"
echo -e "${YELLOW}💡 Para testar: curl http://${VPS_IP}:8080/health${NC}"
