-- Adicionar coluna phone_verified à tabela users
-- Execute com: PGPASSWORD=Hno@uw@q psql -h 77.37.41.41 -U cadastro_user -p 5411 -d cadastro_db -f add_phone_verified_column.sql

-- Verificar se a coluna já existe antes de adicionar
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns
                   WHERE table_name='users' AND column_name='phone_verified') THEN
        ALTER TABLE users ADD COLUMN phone_verified BOOLEAN DEFAULT FALSE;
        RAISE NOTICE 'Coluna phone_verified adicionada com sucesso';
    ELSE
        RAISE NOTICE 'Coluna phone_verified já existe';
    END IF;
END $$;

-- Verificar estrutura atualizada
SELECT column_name, data_type, is_nullable, column_default
FROM information_schema.columns
WHERE table_name = 'users'
AND column_name IN ('email_verified', 'phone_verified')
ORDER BY column_name;
