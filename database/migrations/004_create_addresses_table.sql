-- ====================================================================
-- Migration: 004_create_addresses_table
-- Descrição: Cria tabela de endereços dos usuários
-- Data: 2024-12-13
-- ====================================================================

-- Criar enum para tipo de endereço
CREATE TYPE address_type AS ENUM ('home', 'work', 'delivery', 'billing', 'other');

-- Criar tabela de endereços
CREATE TABLE IF NOT EXISTS addresses (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,

    -- Tipo e identificação
    address_type address_type NOT NULL DEFAULT 'home',
    label VARCHAR(100),  -- Ex: "Casa", "Escritório", "Casa da Praia"

    -- Endereço completo
    cep VARCHAR(9) NOT NULL,
    logradouro VARCHAR(255) NOT NULL,  -- Rua, Avenida, etc
    numero VARCHAR(20) NOT NULL,
    complemento VARCHAR(100),
    bairro VARCHAR(100) NOT NULL,
    cidade VARCHAR(100) NOT NULL,
    estado VARCHAR(2) NOT NULL,  -- UF: SP, RJ, etc
    pais VARCHAR(3) DEFAULT 'BRA',  -- Código ISO 3166-1 alpha-3

    -- Informações adicionais
    referencia TEXT,  -- Ponto de referência
    destinatario VARCHAR(255),  -- Nome do destinatário (pode ser diferente do usuário)
    telefone_contato VARCHAR(20),

    -- Geolocalização (opcional, obtida via CEP ou GPS)
    latitude DECIMAL(10, 8),
    longitude DECIMAL(11, 8),

    -- Flags de controle
    is_default BOOLEAN DEFAULT FALSE,
    is_active BOOLEAN DEFAULT TRUE,

    -- Timestamps
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP
);

-- Criar índices
CREATE INDEX idx_addresses_user_id ON addresses(user_id) WHERE deleted_at IS NULL;
CREATE INDEX idx_addresses_cep ON addresses(cep);
CREATE INDEX idx_addresses_type ON addresses(address_type);
CREATE INDEX idx_addresses_default ON addresses(is_default) WHERE is_default = TRUE AND deleted_at IS NULL;
CREATE INDEX idx_addresses_active ON addresses(is_active) WHERE deleted_at IS NULL;
CREATE INDEX idx_addresses_created_at ON addresses(created_at);

-- Garantir que apenas um endereço seja default por usuário
CREATE UNIQUE INDEX idx_addresses_user_default
    ON addresses(user_id)
    WHERE is_default = TRUE AND deleted_at IS NULL;

-- Criar trigger para atualizar updated_at
CREATE TRIGGER update_addresses_updated_at
    BEFORE UPDATE ON addresses
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- Comentários
COMMENT ON TABLE addresses IS 'Endereços dos usuários';
COMMENT ON COLUMN addresses.address_type IS 'Tipo de endereço (casa, trabalho, entrega, etc)';
COMMENT ON COLUMN addresses.label IS 'Nome/label personalizado para o endereço';
COMMENT ON COLUMN addresses.cep IS 'CEP (formato: 12345-678)';
COMMENT ON COLUMN addresses.logradouro IS 'Logradouro (rua, avenida, etc)';
COMMENT ON COLUMN addresses.numero IS 'Número do endereço';
COMMENT ON COLUMN addresses.complemento IS 'Complemento (apto, bloco, etc)';
COMMENT ON COLUMN addresses.estado IS 'UF do estado (SP, RJ, etc)';
COMMENT ON COLUMN addresses.pais IS 'Código ISO 3166-1 alpha-3 do país';
COMMENT ON COLUMN addresses.referencia IS 'Ponto de referência';
COMMENT ON COLUMN addresses.is_default IS 'Indica se é o endereço padrão do usuário';
