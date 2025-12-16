# ====================================================================
# Script: run_migrations.ps1
# Descrição: Executa todas as migrations do banco de dados PostgreSQL (Windows)
# Data: 2024-12-13
# ====================================================================

# Configurações
$ErrorActionPreference = "Stop"

# Cores
function Write-ColorOutput($ForegroundColor) {
    $fc = $host.UI.RawUI.ForegroundColor
    $host.UI.RawUI.ForegroundColor = $ForegroundColor
    if ($args) {
        Write-Output $args
    }
    $host.UI.RawUI.ForegroundColor = $fc
}

Write-ColorOutput Yellow "========================================"
Write-ColorOutput Yellow "  PostgreSQL Migrations Runner"
Write-ColorOutput Yellow "========================================"
Write-Output ""

# Ler variáveis do .env
$envFile = ".env"
if (Test-Path $envFile) {
    Get-Content $envFile | ForEach-Object {
        if ($_ -match '^\s*([^#][^=]+)=(.+)$') {
            $key = $matches[1].Trim()
            $value = $matches[2].Trim()
            Set-Variable -Name $key -Value $value -Scope Script
        }
    }
}

# Configurações do banco (com fallback para valores padrão)
$DB_HOST = if ($DB_HOST) { $DB_HOST } else { "77.37.41.41" }
$DB_PORT = if ($DB_PORT) { $DB_PORT } else { "5432" }
$DB_NAME = if ($DB_NAME) { $DB_NAME } else { "cadastro_db" }
$DB_USER = if ($DB_USER) { $DB_USER } else { "cadastro_user" }
$DB_PASSWORD = if ($DB_PASSWORD) { $DB_PASSWORD } else { "" }

Write-Output "Host:     $DB_HOST"
Write-Output "Database: $DB_NAME"
Write-Output "User:     $DB_USER"
Write-Output ""

# Exportar senha como variável de ambiente
$env:PGPASSWORD = $DB_PASSWORD

# Verificar se psql está instalado
try {
    $null = Get-Command psql -ErrorAction Stop
    Write-ColorOutput Green "✓ psql encontrado"
} catch {
    Write-ColorOutput Red "✗ ERRO: psql não está instalado"
    Write-Output ""
    Write-Output "Instale o PostgreSQL client:"
    Write-Output "  Baixe em: https://www.postgresql.org/download/windows/"
    Write-Output "  Ou use o instalador: https://www.enterprisedb.com/downloads/postgres-postgresql-downloads"
    exit 1
}

# Testar conexão
Write-Output ""
Write-ColorOutput Yellow "Testando conexão com o banco..."

try {
    $testQuery = "SELECT 1;"
    $null = psql -h $DB_HOST -p $DB_PORT -U $DB_USER -d $DB_NAME -c $testQuery 2>&1

    if ($LASTEXITCODE -eq 0) {
        Write-ColorOutput Green "✓ Conexão estabelecida com sucesso"
    } else {
        throw "Erro ao conectar"
    }
} catch {
    Write-ColorOutput Red "✗ ERRO: Não foi possível conectar ao banco"
    Write-Output ""
    Write-Output "Verifique:"
    Write-Output "  1. Credenciais no arquivo .env"
    Write-Output "  2. Conectividade com o host $DB_HOST"
    Write-Output "  3. Se o banco $DB_NAME existe"
    Write-Output "  4. Firewall e regras de rede"
    exit 1
}

# Contadores
$TOTAL = 0
$SUCCESS = 0
$FAILED = 0

# Executar migrations
Write-Output ""
Write-ColorOutput Yellow "Executando migrations..."
Write-Output ""

# Obter todos os arquivos .sql em ordem
$migrationFiles = Get-ChildItem -Path "database\migrations\*.sql" | Sort-Object Name

foreach ($file in $migrationFiles) {
    $TOTAL++
    $filename = $file.Name

    Write-ColorOutput Yellow "[$TOTAL] Executando: $filename..."

    try {
        # Executar migration
        $output = psql -h $DB_HOST -p $DB_PORT -U $DB_USER -d $DB_NAME -f $file.FullName 2>&1

        if ($LASTEXITCODE -eq 0) {
            Write-ColorOutput Green "    ✓ Sucesso"
            $SUCCESS++
        } else {
            Write-ColorOutput Red "    ✗ Falhou"
            Write-Output $output
            $FAILED++
        }
    } catch {
        Write-ColorOutput Red "    ✗ Falhou com exceção"
        Write-Output $_.Exception.Message
        $FAILED++
    }

    Write-Output ""
}

# Resumo
Write-ColorOutput Yellow "========================================"
Write-ColorOutput Yellow "  Resumo"
Write-ColorOutput Yellow "========================================"
Write-Output "Total:    $TOTAL"
Write-ColorOutput Green "Sucesso:  $SUCCESS"
Write-ColorOutput Red "Falhas:   $FAILED"
Write-Output ""

if ($FAILED -eq 0) {
    Write-ColorOutput Green "✓ Todas as migrations foram executadas com sucesso!"
    exit 0
} else {
    Write-ColorOutput Red "✗ Algumas migrations falharam. Verifique os erros acima."
    exit 1
}
