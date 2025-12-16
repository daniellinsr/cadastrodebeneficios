# ================================================
# Script de Backup Automático do PostgreSQL
# ================================================
# Este script cria um backup completo do banco de dados
# ================================================

# Configuração
$ENV_FILE = Join-Path (Join-Path $PSScriptRoot "..") ".env"
$BACKUP_DIR = Join-Path $PSScriptRoot "backups"
$DATE = Get-Date -Format "yyyy-MM-dd_HH-mm-ss"
$BACKUP_FILE = Join-Path $BACKUP_DIR "cadastro_db_backup_$DATE.sql"

# Criar diretório de backups se não existir
if (!(Test-Path $BACKUP_DIR)) {
    New-Item -ItemType Directory -Path $BACKUP_DIR | Out-Null
}

Write-Host "================================================" -ForegroundColor Cyan
Write-Host " Backup do Banco de Dados PostgreSQL" -ForegroundColor Cyan
Write-Host "================================================" -ForegroundColor Cyan
Write-Host ""

# Ler variáveis do .env
if (Test-Path $ENV_FILE) {
    Write-Host "Lendo configurações do .env..." -ForegroundColor Yellow
    Get-Content $ENV_FILE | ForEach-Object {
        if ($_ -match "^DB_HOST=(.*)") { $DB_HOST = $matches[1] }
        if ($_ -match "^DB_PORT=(.*)") { $DB_PORT = $matches[1] }
        if ($_ -match "^DB_NAME=(.*)") { $DB_NAME = $matches[1] }
        if ($_ -match "^DB_USER=(.*)") { $DB_USER = $matches[1] }
        if ($_ -match "^DB_PASSWORD=(.*)") { $DB_PASSWORD = $matches[1] }
    }
} else {
    Write-Host "Arquivo .env não encontrado!" -ForegroundColor Red
    exit 1
}

Write-Host "Host: $DB_HOST" -ForegroundColor Gray
Write-Host "Porta: $DB_PORT" -ForegroundColor Gray
Write-Host "Banco: $DB_NAME" -ForegroundColor Gray
Write-Host "Usuário: $DB_USER" -ForegroundColor Gray
Write-Host "Destino: $BACKUP_FILE" -ForegroundColor Gray
Write-Host ""

# Configurar senha como variável de ambiente temporária
$env:PGPASSWORD = $DB_PASSWORD

# Executar backup
Write-Host "Criando backup..." -ForegroundColor Yellow

try {
    # Tentar usar pg_dump do PostgreSQL instalado
    $PG_DUMP = "C:\Program Files\PostgreSQL\18\bin\pg_dump.exe"

    if (Test-Path $PG_DUMP) {
        & $PG_DUMP -h $DB_HOST -p $DB_PORT -U $DB_USER -d $DB_NAME -F p -b -v -f $BACKUP_FILE 2>&1 | Out-Null

        if ($LASTEXITCODE -eq 0) {
            $FileSize = (Get-Item $BACKUP_FILE).Length / 1KB
            Write-Host ""
            Write-Host "✅ Backup criado com sucesso!" -ForegroundColor Green
            Write-Host "   Arquivo: $BACKUP_FILE" -ForegroundColor Gray
            Write-Host "   Tamanho: $([math]::Round($FileSize, 2)) KB" -ForegroundColor Gray

            # Listar backups existentes
            Write-Host ""
            Write-Host "Backups disponíveis:" -ForegroundColor Cyan
            Get-ChildItem $BACKUP_DIR -Filter "*.sql" | Sort-Object LastWriteTime -Descending | Select-Object -First 5 | ForEach-Object {
                $size = [math]::Round($_.Length / 1KB, 2)
                Write-Host "   $($_.Name) ($size KB) - $($_.LastWriteTime)" -ForegroundColor Gray
            }

            # Limpar backups antigos (manter últimos 10)
            Write-Host ""
            Write-Host "Limpando backups antigos (manter últimos 10)..." -ForegroundColor Yellow
            Get-ChildItem $BACKUP_DIR -Filter "*.sql" | Sort-Object LastWriteTime -Descending | Select-Object -Skip 10 | Remove-Item -Force
            Write-Host "✅ Limpeza concluída!" -ForegroundColor Green

        } else {
            Write-Host "❌ Erro ao criar backup!" -ForegroundColor Red
            exit 1
        }
    } else {
        Write-Host "❌ pg_dump não encontrado em: $PG_DUMP" -ForegroundColor Red
        Write-Host "Instale o PostgreSQL Client ou ajuste o caminho no script." -ForegroundColor Yellow
        exit 1
    }
} finally {
    # Limpar variável de senha
    Remove-Item Env:\PGPASSWORD
}

Write-Host ""
Write-Host "================================================" -ForegroundColor Cyan
Write-Host " Backup concluído!" -ForegroundColor Cyan
Write-Host "================================================" -ForegroundColor Cyan
