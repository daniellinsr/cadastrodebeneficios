-- Script para criar/atualizar tabela users
-- Execute com: psql -h 77.37.41.41 -U cadastro_user -p 5411 -d cadastro_db -f create_users_table.sql

-- Dropar tabela se existir (CUIDADO: isso apaga os dados!)
-- DROP TABLE IF EXISTS users CASCADE;

-- Criar tabela users com estrutura completa
CREATE TABLE IF NOT EXISTS users (
    id UUID PRIMARY KEY,
    email VARCHAR(255) UNIQUE NOT NULL,
    name VARCHAR(255) NOT NULL,
    password_hash VARCHAR(255),
    phone_number VARCHAR(20),
    cpf VARCHAR(14) UNIQUE,
    photo_url VARCHAR(500),
    role VARCHAR(50) DEFAULT 'beneficiary',
    birth_date DATE,

    -- Endereço
    cep VARCHAR(10),
    street VARCHAR(255),
    number VARCHAR(20),
    complement VARCHAR(100),
    neighborhood VARCHAR(100),
    city VARCHAR(100),
    state VARCHAR(2),

    -- Verificações
    email_verified BOOLEAN DEFAULT FALSE,
    phone_verified BOOLEAN DEFAULT FALSE,

    -- Timestamps
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    last_login_at TIMESTAMP,
    deleted_at TIMESTAMP,

    -- Google OAuth
    google_id VARCHAR(255) UNIQUE
);

-- Criar índices para melhor performance
CREATE INDEX IF NOT EXISTS idx_users_email ON users(email);
CREATE INDEX IF NOT EXISTS idx_users_cpf ON users(cpf);
CREATE INDEX IF NOT EXISTS idx_users_phone ON users(phone_number);
CREATE INDEX IF NOT EXISTS idx_users_google_id ON users(google_id);
CREATE INDEX IF NOT EXISTS idx_users_deleted_at ON users(deleted_at);

-- Comentários nas colunas
COMMENT ON TABLE users IS 'Tabela de usuários do sistema';
COMMENT ON COLUMN users.id IS 'ID único do usuário (UUID)';
COMMENT ON COLUMN users.email IS 'Email do usuário (único)';
COMMENT ON COLUMN users.name IS 'Nome completo do usuário';
COMMENT ON COLUMN users.password_hash IS 'Hash da senha (bcrypt)';
COMMENT ON COLUMN users.phone_number IS 'Telefone celular';
COMMENT ON COLUMN users.cpf IS 'CPF do usuário (único)';
COMMENT ON COLUMN users.role IS 'Papel do usuário (admin, beneficiary, partner)';
COMMENT ON COLUMN users.birth_date IS 'Data de nascimento';
COMMENT ON COLUMN users.google_id IS 'Google ID para OAuth';
