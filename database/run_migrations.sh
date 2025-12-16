#!/bin/bash

# ====================================================================
# Script: run_migrations.sh
# Descrição: Executa todas as migrations do banco de dados PostgreSQL
# Data: 2024-12-13
# ====================================================================

# Cores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Configurações do banco (lidas do .env)
if [ -f .env ]; then
    export $(cat .env | grep -v '#' | grep -v '^$' | xargs)
fi

DB_HOST="${DB_HOST:-77.37.41.41}"
DB_PORT="${DB_PORT:-5432}"
DB_NAME="${DB_NAME:-cadastro_db}"
DB_USER="${DB_USER:-cadastro_user}"
DB_PASSWORD="${DB_PASSWORD:-}"

# Exportar senha para evitar prompt
export PGPASSWORD="$DB_PASSWORD"

echo -e "${YELLOW}========================================${NC}"
echo -e "${YELLOW}  PostgreSQL Migrations Runner${NC}"
echo -e "${YELLOW}========================================${NC}"
echo ""
echo -e "Host:     ${GREEN}$DB_HOST${NC}"
echo -e "Database: ${GREEN}$DB_NAME${NC}"
echo -e "User:     ${GREEN}$DB_USER${NC}"
echo ""

# Verificar se psql está instalado
if ! command -v psql &> /dev/null; then
    echo -e "${RED}✗ ERRO: psql não está instalado${NC}"
    echo ""
    echo "Instale o PostgreSQL client:"
    echo "  Ubuntu/Debian: sudo apt-get install postgresql-client"
    echo "  macOS: brew install postgresql"
    echo "  Fedora/RHEL: sudo dnf install postgresql"
    exit 1
fi

# Verificar conexão com o banco
echo -e "${YELLOW}Testando conexão com o banco...${NC}"
if psql -h "$DB_HOST" -p "$DB_PORT" -U "$DB_USER" -d "$DB_NAME" -c "SELECT 1;" > /dev/null 2>&1; then
    echo -e "${GREEN}✓ Conexão estabelecida com sucesso${NC}"
    echo ""
else
    echo -e "${RED}✗ ERRO: Não foi possível conectar ao banco${NC}"
    echo ""
    echo "Verifique:"
    echo "  1. Credenciais no arquivo .env"
    echo "  2. Conectividade com o host $DB_HOST"
    echo "  3. Se o banco $DB_NAME existe"
    exit 1
fi

# Contador
TOTAL=0
SUCCESS=0
FAILED=0

# Executar cada migration
echo -e "${YELLOW}Executando migrations...${NC}"
echo ""

for file in database/migrations/*.sql; do
    if [ -f "$file" ]; then
        TOTAL=$((TOTAL + 1))
        filename=$(basename "$file")

        echo -e "${YELLOW}[${TOTAL}] Executando: ${filename}...${NC}"

        if psql -h "$DB_HOST" -p "$DB_PORT" -U "$DB_USER" -d "$DB_NAME" -f "$file" > /dev/null 2>&1; then
            echo -e "${GREEN}    ✓ Sucesso${NC}"
            SUCCESS=$((SUCCESS + 1))
        else
            echo -e "${RED}    ✗ Falhou${NC}"
            FAILED=$((FAILED + 1))

            # Mostrar erro
            psql -h "$DB_HOST" -p "$DB_PORT" -U "$DB_USER" -d "$DB_NAME" -f "$file"
        fi
        echo ""
    fi
done

# Resumo
echo -e "${YELLOW}========================================${NC}"
echo -e "${YELLOW}  Resumo${NC}"
echo -e "${YELLOW}========================================${NC}"
echo -e "Total:    ${TOTAL}"
echo -e "Sucesso:  ${GREEN}${SUCCESS}${NC}"
echo -e "Falhas:   ${RED}${FAILED}${NC}"
echo ""

if [ $FAILED -eq 0 ]; then
    echo -e "${GREEN}✓ Todas as migrations foram executadas com sucesso!${NC}"
    exit 0
else
    echo -e "${RED}✗ Algumas migrations falharam. Verifique os erros acima.${NC}"
    exit 1
fi
