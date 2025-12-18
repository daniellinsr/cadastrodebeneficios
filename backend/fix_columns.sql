-- Corrigir colunas duplicadas na tabela users
-- Vamos usar as colunas em inglês como padrão e remover as constraints das em português

-- Remover NOT NULL da coluna 'nome' (vamos usar 'name')
ALTER TABLE users ALTER COLUMN nome DROP NOT NULL;

-- Remover NOT NULL da coluna 'telefone' (vamos usar 'phone_number')
ALTER TABLE users ALTER COLUMN telefone DROP NOT NULL;

-- Copiar dados de name para nome (se houver)
UPDATE users SET nome = name WHERE name IS NOT NULL AND nome IS NULL;

-- Copiar dados de phone_number para telefone (se houver)
UPDATE users SET telefone = phone_number WHERE phone_number IS NOT NULL AND telefone IS NULL;

-- Copiar dados de birth_date para data_nascimento (se houver)
UPDATE users SET data_nascimento = birth_date WHERE birth_date IS NOT NULL AND data_nascimento IS NULL;

-- Mostrar estrutura
\d users
