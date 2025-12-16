# ================================================
# Script de Restauração do Backup PostgreSQL
# ================================================
# Este script restaura um backup do banco de dados
# ================================================

param(
    [string]$BackupFile = ""
)

# Configuração
$ENV_FILE = Join-Path $PSScriptRoot ".." ".env"
$BACKUP_DIR = Join-Path $PSScriptRoot "backups"

Write-Host "================================================" -ForegroundColor Cyan
Write-Host " Restauração do Banco de Dados PostgreSQL" -ForegroundColor Cyan
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
    Write-Host "❌ Arquivo .env não encontrado!" -ForegroundColor Red
    exit 1
}

# Selecionar backup
if ($BackupFile -eq "") {
    Write-Host "Backups disponíveis:" -ForegroundColor Cyan
    $backups = Get-ChildItem $BACKUP_DIR -Filter "*.sql" | Sort-Object LastWriteTime -Descending

    if ($backups.Count -eq 0) {
        Write-Host "❌ Nenhum backup encontrado em: $BACKUP_DIR" -ForegroundColor Red
        exit 1
    }

    $i = 1
    $backups | ForEach-Object {
        $size = [math]::Round($_.Length / 1KB, 2)
        Write-Host "  [$i] $($_.Name) ($size KB) - $($_.LastWriteTime)" -ForegroundColor Gray
        $i++
    }

    Write-Host ""
    $selection = Read-Host "Selecione o backup (1-$($backups.Count)) ou pressione Enter para cancelar"

    if ($selection -eq "") {
        Write-Host "Operação cancelada." -ForegroundColor Yellow
        exit 0
    }

    $BackupFile = $backups[$selection - 1].FullName
}

if (!(Test-Path $BackupFile)) {
    Write-Host "❌ Arquivo de backup não encontrado: $BackupFile" -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "⚠️  ATENÇÃO: Esta operação irá SOBRESCREVER o banco de dados atual!" -ForegroundColor Yellow
Write-Host "Host: $DB_HOST" -ForegroundColor Gray
Write-Host "Banco: $DB_NAME" -ForegroundColor Gray
Write-Host "Backup: $BackupFile" -ForegroundColor Gray
Write-Host ""
$confirm = Read-Host "Tem certeza? (digite 'sim' para confirmar)"

if ($confirm -ne "sim") {
    Write-Host "Operação cancelada." -ForegroundColor Yellow
    exit 0
}

# Configurar senha
$env:PGPASSWORD = $DB_PASSWORD

Write-Host ""
Write-Host "Restaurando backup..." -ForegroundColor Yellow

try {
    $PSQL = "C:\Program Files\PostgreSQL\18\bin\psql.exe"

    if (Test-Path $PSQL) {
        & $PSQL -h $DB_HOST -p $DB_PORT -U $DB_USER -d $DB_NAME -f $BackupFile 2>&1 | Out-Null

        if ($LASTEXITCODE -eq 0) {
            Write-Host ""
            Write-Host "✅ Backup restaurado com sucesso!" -ForegroundColor Green
        } else {
            Write-Host "❌ Erro ao restaurar backup!" -ForegroundColor Red
            exit 1
        }
    } else {
        Write-Host "❌ psql não encontrado em: $PSQL" -ForegroundColor Red
        exit 1
    }
} finally {
    Remove-Item Env:\PGPASSWORD
}

Write-Host ""
Write-Host "================================================" -ForegroundColor Cyan
Write-Host " Restauração concluída!" -ForegroundColor Cyan
Write-Host "================================================" -ForegroundColor Cyan
