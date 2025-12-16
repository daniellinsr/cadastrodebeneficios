-- ====================================================================
-- Migration: 002_create_cards_table
-- Descrição: Cria tabela de cartões de benefícios
-- Data: 2024-12-13
-- ====================================================================

-- Criar enum para tipo de cartão
CREATE TYPE card_type AS ENUM ('virtual', 'physical');

-- Criar enum para status do cartão
CREATE TYPE card_status AS ENUM ('active', 'blocked', 'cancelled', 'pending');

-- Criar tabela de cartões
CREATE TABLE IF NOT EXISTS cards (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,

    -- Informações do cartão
    card_number VARCHAR(16) NOT NULL UNIQUE,
    card_holder_name VARCHAR(255) NOT NULL,
    expiry_month SMALLINT NOT NULL CHECK (expiry_month BETWEEN 1 AND 12),
    expiry_year SMALLINT NOT NULL CHECK (expiry_year >= EXTRACT(YEAR FROM CURRENT_DATE)),
    cvv VARCHAR(4) NOT NULL,

    -- Tipo e status
    card_type card_type NOT NULL DEFAULT 'virtual',
    status card_status NOT NULL DEFAULT 'pending',

    -- Saldo e limites
    balance DECIMAL(10, 2) DEFAULT 0.00 CHECK (balance >= 0),
    credit_limit DECIMAL(10, 2) DEFAULT 0.00 CHECK (credit_limit >= 0),
    daily_limit DECIMAL(10, 2),
    monthly_limit DECIMAL(10, 2),

    -- Flags de controle
    is_default BOOLEAN DEFAULT FALSE,
    allow_online_purchases BOOLEAN DEFAULT TRUE,
    allow_contactless BOOLEAN DEFAULT TRUE,
    allow_international BOOLEAN DEFAULT FALSE,

    -- Informações de ativação
    activated_at TIMESTAMP,
    blocked_at TIMESTAMP,
    blocked_reason TEXT,
    cancelled_at TIMESTAMP,
    cancelled_reason TEXT,

    -- Endereço de entrega (para cartões físicos)
    delivery_address TEXT,
    delivery_date DATE,

    -- Timestamps
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP
);

-- Criar índices
CREATE INDEX idx_cards_user_id ON cards(user_id) WHERE deleted_at IS NULL;
CREATE INDEX idx_cards_card_number ON cards(card_number) WHERE deleted_at IS NULL;
CREATE INDEX idx_cards_status ON cards(status) WHERE deleted_at IS NULL;
CREATE INDEX idx_cards_type ON cards(card_type);
CREATE INDEX idx_cards_default ON cards(is_default) WHERE is_default = TRUE AND deleted_at IS NULL;
CREATE INDEX idx_cards_created_at ON cards(created_at);

-- Criar trigger para atualizar updated_at
CREATE TRIGGER update_cards_updated_at
    BEFORE UPDATE ON cards
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- Garantir que apenas um cartão seja default por usuário
CREATE UNIQUE INDEX idx_cards_user_default
    ON cards(user_id)
    WHERE is_default = TRUE AND deleted_at IS NULL;

-- Comentários
COMMENT ON TABLE cards IS 'Tabela de cartões de benefícios (virtuais e físicos)';
COMMENT ON COLUMN cards.card_number IS 'Número do cartão (16 dígitos)';
COMMENT ON COLUMN cards.cvv IS 'Código de segurança (3 ou 4 dígitos)';
COMMENT ON COLUMN cards.balance IS 'Saldo disponível no cartão';
COMMENT ON COLUMN cards.credit_limit IS 'Limite de crédito do cartão';
COMMENT ON COLUMN cards.is_default IS 'Indica se é o cartão padrão do usuário';
COMMENT ON COLUMN cards.allow_online_purchases IS 'Permite compras online';
COMMENT ON COLUMN cards.allow_contactless IS 'Permite pagamento por aproximação';
COMMENT ON COLUMN cards.allow_international IS 'Permite transações internacionais';
