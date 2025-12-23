# Script de Deploy para VPS Hostinger - PowerShell
# IP: 77.37.41.41
# Domínio: http://cadastro.helthcorp.com.br

Write-Host "🚀 Iniciando deploy do backend..." -ForegroundColor Green

# Configurações
$VPS_IP = "77.37.41.41"
$VPS_USER = "root"
$DEPLOY_PATH = "/opt/apps/cadastro/cadastrodebeneficios"

Write-Host "📦 Preparando arquivos para deploy..." -ForegroundColor Yellow

# Criar diretório temporário para build
$BUILD_DIR = ".\deploy-build"
if (Test-Path $BUILD_DIR) {
    Remove-Item -Recurse -Force $BUILD_DIR
}
New-Item -ItemType Directory -Path $BUILD_DIR | Out-Null

# Copiar arquivos necessários
Copy-Item -Recurse -Force "src" "$BUILD_DIR\"
Copy-Item -Force "package*.json" "$BUILD_DIR\"
Copy-Item -Force "tsconfig.json" "$BUILD_DIR\"
Copy-Item -Force "Dockerfile" "$BUILD_DIR\"
Copy-Item -Force ".dockerignore" "$BUILD_DIR\"
Copy-Item -Force "docker-compose.yml" "$BUILD_DIR\"
Copy-Item -Force ".env.production" "$BUILD_DIR\.env"

Write-Host "✅ Arquivos preparados" -ForegroundColor Green

Write-Host "📤 Conecte-se ao servidor e execute os seguintes comandos:" -ForegroundColor Yellow
Write-Host ""
Write-Host "1. Conectar ao servidor:" -ForegroundColor Cyan
Write-Host "   ssh $VPS_USER@$VPS_IP" -ForegroundColor White
Write-Host ""
Write-Host "2. Criar diretório (se não existir):" -ForegroundColor Cyan
Write-Host "   mkdir -p $DEPLOY_PATH" -ForegroundColor White
Write-Host ""
Write-Host "3. No seu computador, envie os arquivos com SCP:" -ForegroundColor Cyan
Write-Host "   cd $BUILD_DIR" -ForegroundColor White
Write-Host "   scp -r * $VPS_USER@${VPS_IP}:$DEPLOY_PATH/" -ForegroundColor White
Write-Host ""
Write-Host "4. De volta ao servidor, faça o deploy (APENAS do cadastro-beneficios):" -ForegroundColor Cyan
Write-Host "   cd $DEPLOY_PATH" -ForegroundColor White
Write-Host "   docker-compose stop backend" -ForegroundColor White
Write-Host "   docker-compose rm -f backend" -ForegroundColor White
Write-Host "   docker-compose build --no-cache backend" -ForegroundColor White
Write-Host "   docker-compose up -d backend" -ForegroundColor White
Write-Host "   docker-compose ps backend" -ForegroundColor White
Write-Host "   docker-compose logs --tail=50 backend" -ForegroundColor White
Write-Host ""
Write-Host "🎉 Após o deploy, o backend estará disponível em:" -ForegroundColor Green
Write-Host "   http://$VPS_IP:3002" -ForegroundColor Cyan
Write-Host "   http://cadastro.helthcorp.com.br:3002" -ForegroundColor Cyan
Write-Host ""
Write-Host "💡 Arquivos prontos em: $BUILD_DIR" -ForegroundColor Yellow

# Perguntar se quer abrir o SSH
$response = Read-Host "Deseja abrir conexão SSH agora? (S/N)"
if ($response -eq "S" -or $response -eq "s") {
    ssh "$VPS_USER@$VPS_IP"
}
