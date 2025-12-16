-- ================================================
-- Script de Dados de Teste (Seed Data)
-- ================================================
-- Este script popula o banco com dados de teste
-- para facilitar o desenvolvimento e testes
-- ================================================

-- Limpar dados existentes (cuidado em produção!)
-- TRUNCATE TABLE addresses CASCADE;
-- TRUNCATE TABLE transactions CASCADE;
-- TRUNCATE TABLE cards CASCADE;
-- TRUNCATE TABLE password_reset_tokens CASCADE;
-- TRUNCATE TABLE refresh_tokens CASCADE;
-- TRUNCATE TABLE users CASCADE;

-- ================================================
-- 1. USUÁRIOS DE TESTE
-- ================================================

-- Usuário 1: Admin
INSERT INTO users (id, email, name, password_hash, phone_number, cpf, email_verified, phone_verified)
VALUES (
  gen_random_uuid(),
  'admin@cadastro.com',
  'Administrador Sistema',
  '$2b$10$YourHashedPasswordHere123456789012345678901234567890123', -- senha: admin123
  '+5511999991111',
  '12345678901',
  true,
  true
) ON CONFLICT (email) DO NOTHING;

-- Usuário 2: Cliente Teste 1
INSERT INTO users (id, email, name, password_hash, phone_number, cpf, email_verified, phone_verified)
VALUES (
  gen_random_uuid(),
  'cliente1@example.com',
  'João da Silva',
  '$2b$10$YourHashedPasswordHere123456789012345678901234567890123', -- senha: senha123
  '+5511999992222',
  '98765432100',
  true,
  true
) ON CONFLICT (email) DO NOTHING;

-- Usuário 3: Cliente Teste 2
INSERT INTO users (id, email, name, password_hash, phone_number, cpf, email_verified, phone_verified)
VALUES (
  gen_random_uuid(),
  'cliente2@example.com',
  'Maria Santos',
  '$2b$10$YourHashedPasswordHere123456789012345678901234567890123', -- senha: senha123
  '+5511999993333',
  '11122233344',
  true,
  false
) ON CONFLICT (email) DO NOTHING;

-- Usuário 4: Google OAuth
INSERT INTO users (id, email, name, google_id, phone_number, email_verified, phone_verified)
VALUES (
  gen_random_uuid(),
  'google@example.com',
  'Usuário Google',
  'google_id_123456789',
  '+5511999994444',
  true,
  false
) ON CONFLICT (email) DO NOTHING;

-- ================================================
-- 2. ENDEREÇOS DE TESTE
-- ================================================

-- Endereço do João (cliente1)
INSERT INTO addresses (id, user_id, type, street, number, complement, neighborhood, city, state, postal_code, country, is_default)
SELECT
  gen_random_uuid(),
  u.id,
  'home',
  'Rua das Flores',
  '123',
  'Apto 45',
  'Centro',
  'São Paulo',
  'SP',
  '01310-100',
  'Brasil',
  true
FROM users u WHERE u.email = 'cliente1@example.com'
ON CONFLICT DO NOTHING;

-- Endereço da Maria (cliente2)
INSERT INTO addresses (id, user_id, type, street, number, complement, neighborhood, city, state, postal_code, country, is_default)
SELECT
  gen_random_uuid(),
  u.id,
  'home',
  'Avenida Paulista',
  '1000',
  NULL,
  'Bela Vista',
  'São Paulo',
  'SP',
  '01310-200',
  'Brasil',
  true
FROM users u WHERE u.email = 'cliente2@example.com'
ON CONFLICT DO NOTHING;

-- ================================================
-- 3. CARTÕES DE TESTE
-- ================================================

-- Cartão Virtual do João
INSERT INTO cards (id, user_id, card_type, card_number, cardholder_name, expiration_month, expiration_year, cvv, status, balance, is_default)
SELECT
  gen_random_uuid(),
  u.id,
  'virtual',
  '4111111111111111',
  'JOAO DA SILVA',
  12,
  2026,
  '123',
  'active',
  1500.00,
  true
FROM users u WHERE u.email = 'cliente1@example.com'
ON CONFLICT DO NOTHING;

-- Cartão Físico do João
INSERT INTO cards (id, user_id, card_type, card_number, cardholder_name, expiration_month, expiration_year, cvv, status, balance, is_default)
SELECT
  gen_random_uuid(),
  u.id,
  'physical',
  '5555555555554444',
  'JOAO DA SILVA',
  6,
  2027,
  '456',
  'active',
  2500.00,
  false
FROM users u WHERE u.email = 'cliente1@example.com'
ON CONFLICT DO NOTHING;

-- Cartão Virtual da Maria
INSERT INTO cards (id, user_id, card_type, card_number, cardholder_name, expiration_month, expiration_year, cvv, status, balance, is_default)
SELECT
  gen_random_uuid(),
  u.id,
  'virtual',
  '4000000000000002',
  'MARIA SANTOS',
  3,
  2026,
  '789',
  'active',
  500.00,
  true
FROM users u WHERE u.email = 'cliente2@example.com'
ON CONFLICT DO NOTHING;

-- ================================================
-- 4. TRANSAÇÕES DE TESTE
-- ================================================

-- Transações do João
INSERT INTO transactions (
  id, user_id, card_id, type, status, category,
  amount, description, merchant_name,
  created_at
)
SELECT
  gen_random_uuid(),
  u.id,
  c.id,
  'purchase',
  'completed',
  'food',
  -45.90,
  'Compra no supermercado',
  'Supermercado Extra',
  NOW() - INTERVAL '2 days'
FROM users u
JOIN cards c ON c.user_id = u.id AND c.is_default = true
WHERE u.email = 'cliente1@example.com'
LIMIT 1;

INSERT INTO transactions (
  id, user_id, card_id, type, status, category,
  amount, description, merchant_name,
  created_at
)
SELECT
  gen_random_uuid(),
  u.id,
  c.id,
  'purchase',
  'completed',
  'transport',
  -25.00,
  'Recarga Uber',
  'Uber',
  NOW() - INTERVAL '1 day'
FROM users u
JOIN cards c ON c.user_id = u.id AND c.is_default = true
WHERE u.email = 'cliente1@example.com'
LIMIT 1;

INSERT INTO transactions (
  id, user_id, card_id, type, status, category,
  amount, description, merchant_name,
  created_at
)
SELECT
  gen_random_uuid(),
  u.id,
  c.id,
  'deposit',
  'completed',
  'other',
  1000.00,
  'Depósito inicial',
  NULL,
  NOW() - INTERVAL '7 days'
FROM users u
JOIN cards c ON c.user_id = u.id AND c.is_default = true
WHERE u.email = 'cliente1@example.com'
LIMIT 1;

-- Transações da Maria
INSERT INTO transactions (
  id, user_id, card_id, type, status, category,
  amount, description, merchant_name,
  created_at
)
SELECT
  gen_random_uuid(),
  u.id,
  c.id,
  'purchase',
  'completed',
  'shopping',
  -89.90,
  'Compra na Magazine Luiza',
  'Magazine Luiza',
  NOW() - INTERVAL '3 days'
FROM users u
JOIN cards c ON c.user_id = u.id AND c.is_default = true
WHERE u.email = 'cliente2@example.com'
LIMIT 1;

INSERT INTO transactions (
  id, user_id, card_id, type, status, category,
  amount, description, merchant_name,
  created_at
)
SELECT
  gen_random_uuid(),
  u.id,
  c.id,
  'deposit',
  'completed',
  'other',
  500.00,
  'Depósito inicial',
  NULL,
  NOW() - INTERVAL '5 days'
FROM users u
JOIN cards c ON c.user_id = u.id AND c.is_default = true
WHERE u.email = 'cliente2@example.com'
LIMIT 1;

-- ================================================
-- VERIFICAÇÃO
-- ================================================

-- Contar registros criados
SELECT 'USUÁRIOS' as tabela, COUNT(*) as total FROM users
UNION ALL
SELECT 'ENDEREÇOS', COUNT(*) FROM addresses
UNION ALL
SELECT 'CARTÕES', COUNT(*) FROM cards
UNION ALL
SELECT 'TRANSAÇÕES', COUNT(*) FROM transactions;

-- Mostrar usuários criados
SELECT id, email, name, email_verified, phone_verified, created_at
FROM users
ORDER BY created_at DESC;
