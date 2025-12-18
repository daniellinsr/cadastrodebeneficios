-- Script para remover colunas duplicadas em português
-- Mantém apenas as colunas em inglês (padrão do projeto)

-- 1. Copiar dados das colunas em português para as em inglês (caso existam dados)
UPDATE users SET name = nome WHERE nome IS NOT NULL AND name IS NULL;
UPDATE users SET phone_number = telefone WHERE telefone IS NOT NULL AND phone_number IS NULL;
UPDATE users SET birth_date = data_nascimento WHERE data_nascimento IS NOT NULL AND birth_date IS NULL;

-- 2. Remover as colunas em português
ALTER TABLE users DROP COLUMN IF EXISTS nome;
ALTER TABLE users DROP COLUMN IF EXISTS telefone;
ALTER TABLE users DROP COLUMN IF EXISTS data_nascimento;

-- 3. Garantir que as colunas em inglês existem e estão corretas
-- Já foram criadas anteriormente, então só vamos verificar

-- 4. Mostrar estrutura final
SELECT column_name, data_type, is_nullable, column_default
FROM information_schema.columns
WHERE table_name = 'users'
AND column_name IN ('name', 'phone_number', 'birth_date', 'email', 'cpf', 'password_hash',
                     'cep', 'street', 'number', 'complement', 'neighborhood', 'city', 'state', 'role')
ORDER BY column_name;
