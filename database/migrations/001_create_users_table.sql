-- ====================================================================
-- Migration: 001_create_users_table
-- Descrição: Cria tabela de usuários e estrutura relacionada
-- Data: 2024-12-13
-- ====================================================================

-- Criar extensão para UUID (se não existir)
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Criar tabela de usuários
CREATE TABLE IF NOT EXISTS users (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    nome VARCHAR(255) NOT NULL,
    email VARCHAR(255) NOT NULL UNIQUE,
    email_verified BOOLEAN DEFAULT FALSE,
    email_verified_at TIMESTAMP,
    password_hash VARCHAR(255) NOT NULL,
    cpf VARCHAR(14) UNIQUE,
    telefone VARCHAR(20) NOT NULL,
    data_nascimento DATE,

    -- Google OAuth
    google_id VARCHAR(255) UNIQUE,
    google_access_token TEXT,
    google_refresh_token TEXT,

    -- Avatar
    avatar_url TEXT,

    -- Status e controle
    is_active BOOLEAN DEFAULT TRUE,
    is_admin BOOLEAN DEFAULT FALSE,
    last_login_at TIMESTAMP,

    -- Timestamps
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP
);

-- Criar índices para melhor performance
CREATE INDEX idx_users_email ON users(email) WHERE deleted_at IS NULL;
CREATE INDEX idx_users_cpf ON users(cpf) WHERE deleted_at IS NULL AND cpf IS NOT NULL;
CREATE INDEX idx_users_google_id ON users(google_id) WHERE deleted_at IS NULL AND google_id IS NOT NULL;
CREATE INDEX idx_users_active ON users(is_active) WHERE deleted_at IS NULL;
CREATE INDEX idx_users_created_at ON users(created_at);

-- Criar tabela de refresh tokens
CREATE TABLE IF NOT EXISTS refresh_tokens (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    token VARCHAR(500) NOT NULL UNIQUE,
    expires_at TIMESTAMP NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    revoked_at TIMESTAMP,

    -- Device info (opcional, para rastreamento)
    device_name VARCHAR(255),
    device_type VARCHAR(50),
    ip_address INET,
    user_agent TEXT
);

-- Índices para refresh tokens
CREATE INDEX idx_refresh_tokens_user_id ON refresh_tokens(user_id);
CREATE INDEX idx_refresh_tokens_token ON refresh_tokens(token) WHERE revoked_at IS NULL;
CREATE INDEX idx_refresh_tokens_expires_at ON refresh_tokens(expires_at);

-- Criar tabela de tokens de reset de senha
CREATE TABLE IF NOT EXISTS password_reset_tokens (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    token VARCHAR(500) NOT NULL UNIQUE,
    expires_at TIMESTAMP NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    used_at TIMESTAMP
);

-- Índices para password reset tokens
CREATE INDEX idx_password_reset_user_id ON password_reset_tokens(user_id);
CREATE INDEX idx_password_reset_token ON password_reset_tokens(token) WHERE used_at IS NULL;
CREATE INDEX idx_password_reset_expires_at ON password_reset_tokens(expires_at);

-- Criar função para atualizar updated_at automaticamente
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Criar trigger para atualizar updated_at na tabela users
CREATE TRIGGER update_users_updated_at
    BEFORE UPDATE ON users
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- Comentários nas tabelas (documentação)
COMMENT ON TABLE users IS 'Tabela principal de usuários do sistema';
COMMENT ON COLUMN users.id IS 'ID único do usuário (UUID)';
COMMENT ON COLUMN users.nome IS 'Nome completo do usuário';
COMMENT ON COLUMN users.email IS 'Email do usuário (único)';
COMMENT ON COLUMN users.email_verified IS 'Indica se o email foi verificado';
COMMENT ON COLUMN users.password_hash IS 'Hash bcrypt da senha do usuário';
COMMENT ON COLUMN users.cpf IS 'CPF do usuário (opcional, único)';
COMMENT ON COLUMN users.telefone IS 'Telefone do usuário';
COMMENT ON COLUMN users.google_id IS 'ID do usuário no Google (para OAuth)';
COMMENT ON COLUMN users.is_active IS 'Indica se o usuário está ativo';
COMMENT ON COLUMN users.is_admin IS 'Indica se o usuário é administrador';
COMMENT ON COLUMN users.deleted_at IS 'Data de exclusão (soft delete)';

COMMENT ON TABLE refresh_tokens IS 'Tokens de refresh para renovação de access tokens';
COMMENT ON COLUMN refresh_tokens.token IS 'Token de refresh (JWT)';
COMMENT ON COLUMN refresh_tokens.expires_at IS 'Data de expiração do token';
COMMENT ON COLUMN refresh_tokens.revoked_at IS 'Data de revogação do token';

COMMENT ON TABLE password_reset_tokens IS 'Tokens para reset de senha';
COMMENT ON COLUMN password_reset_tokens.token IS 'Token único para reset';
COMMENT ON COLUMN password_reset_tokens.expires_at IS 'Data de expiração do token (geralmente 1 hora)';
COMMENT ON COLUMN password_reset_tokens.used_at IS 'Data em que o token foi usado';
