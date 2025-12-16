-- ====================================================================
-- Migration: 003_create_transactions_table
-- Descrição: Cria tabela de transações
-- Data: 2024-12-13
-- ====================================================================

-- Criar enum para tipo de transação
CREATE TYPE transaction_type AS ENUM (
    'purchase',           -- Compra
    'refund',            -- Estorno
    'transfer',          -- Transferência
    'deposit',           -- Depósito
    'withdrawal',        -- Saque
    'payment',           -- Pagamento de conta
    'cashback',          -- Cashback
    'fee'                -- Taxa
);

-- Criar enum para status da transação
CREATE TYPE transaction_status AS ENUM (
    'pending',           -- Pendente
    'processing',        -- Processando
    'completed',         -- Concluída
    'failed',            -- Falhou
    'cancelled',         -- Cancelada
    'refunded'           -- Estornada
);

-- Criar enum para categoria de transação
CREATE TYPE transaction_category AS ENUM (
    'food',              -- Alimentação
    'transport',         -- Transporte
    'health',            -- Saúde
    'education',         -- Educação
    'entertainment',     -- Entretenimento
    'shopping',          -- Compras
    'bills',             -- Contas
    'services',          -- Serviços
    'other'              -- Outros
);

-- Criar tabela de transações
CREATE TABLE IF NOT EXISTS transactions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    card_id UUID NOT NULL REFERENCES cards(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,

    -- Informações da transação
    amount DECIMAL(10, 2) NOT NULL CHECK (amount >= 0),
    transaction_type transaction_type NOT NULL,
    status transaction_status NOT NULL DEFAULT 'pending',
    category transaction_category DEFAULT 'other',

    -- Descrição e detalhes
    description TEXT NOT NULL,
    merchant_name VARCHAR(255),
    merchant_category VARCHAR(100),
    merchant_location VARCHAR(255),

    -- Geolocalização
    latitude DECIMAL(10, 8),
    longitude DECIMAL(11, 8),

    -- Informações adicionais
    receipt_url TEXT,
    authorization_code VARCHAR(100),
    reference_number VARCHAR(100),

    -- Cashback
    cashback_amount DECIMAL(10, 2) DEFAULT 0.00,
    cashback_percentage DECIMAL(5, 2),

    -- Transação relacionada (para estornos, por exemplo)
    related_transaction_id UUID REFERENCES transactions(id),

    -- Informações de processamento
    processed_at TIMESTAMP,
    failed_reason TEXT,
    cancelled_reason TEXT,

    -- Timestamps
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP
);

-- Criar índices
CREATE INDEX idx_transactions_card_id ON transactions(card_id) WHERE deleted_at IS NULL;
CREATE INDEX idx_transactions_user_id ON transactions(user_id) WHERE deleted_at IS NULL;
CREATE INDEX idx_transactions_type ON transactions(transaction_type);
CREATE INDEX idx_transactions_status ON transactions(status);
CREATE INDEX idx_transactions_category ON transactions(category);
CREATE INDEX idx_transactions_created_at ON transactions(created_at DESC);
CREATE INDEX idx_transactions_amount ON transactions(amount);
CREATE INDEX idx_transactions_merchant ON transactions(merchant_name);
CREATE INDEX idx_transactions_processed_at ON transactions(processed_at);

-- Índice para buscar transações relacionadas
CREATE INDEX idx_transactions_related ON transactions(related_transaction_id) WHERE related_transaction_id IS NOT NULL;

-- Índice composto para queries comuns
CREATE INDEX idx_transactions_user_date ON transactions(user_id, created_at DESC) WHERE deleted_at IS NULL;
CREATE INDEX idx_transactions_card_date ON transactions(card_id, created_at DESC) WHERE deleted_at IS NULL;

-- Criar trigger para atualizar updated_at
CREATE TRIGGER update_transactions_updated_at
    BEFORE UPDATE ON transactions
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- Comentários
COMMENT ON TABLE transactions IS 'Tabela de transações de cartões';
COMMENT ON COLUMN transactions.amount IS 'Valor da transação';
COMMENT ON COLUMN transactions.transaction_type IS 'Tipo de transação (compra, estorno, etc)';
COMMENT ON COLUMN transactions.status IS 'Status atual da transação';
COMMENT ON COLUMN transactions.category IS 'Categoria da transação';
COMMENT ON COLUMN transactions.merchant_name IS 'Nome do estabelecimento';
COMMENT ON COLUMN transactions.cashback_amount IS 'Valor do cashback';
COMMENT ON COLUMN transactions.related_transaction_id IS 'ID da transação relacionada (para estornos)';
