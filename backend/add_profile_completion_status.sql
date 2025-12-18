-- Adicionar coluna profile_completion_status à tabela users
-- Execute com: PGPASSWORD=Hno@uw@q psql -h 77.37.41.41 -U cadastro_user -p 5411 -d cadastro_db -f add_profile_completion_status.sql

-- Adicionar coluna se não existir
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns
                   WHERE table_name='users' AND column_name='profile_completion_status') THEN
        ALTER TABLE users ADD COLUMN profile_completion_status VARCHAR(20) DEFAULT 'complete';
        RAISE NOTICE 'Coluna profile_completion_status adicionada com sucesso';
    ELSE
        RAISE NOTICE 'Coluna profile_completion_status já existe';
    END IF;
END $$;

-- Atualizar usuários existentes que não têm CPF ou telefone para 'incomplete'
UPDATE users
SET profile_completion_status = 'incomplete'
WHERE (cpf IS NULL OR phone_number IS NULL OR cep IS NULL);

-- Verificar estrutura atualizada
SELECT column_name, data_type, is_nullable, column_default
FROM information_schema.columns
WHERE table_name = 'users'
AND column_name = 'profile_completion_status';

-- Mostrar estatísticas
SELECT
    profile_completion_status,
    COUNT(*) as total
FROM users
GROUP BY profile_completion_status;
