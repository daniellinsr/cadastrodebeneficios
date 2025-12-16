// Script Node.js para popular dados de teste com senhas corretamente hasheadas
require('dotenv').config({ path: '../.env' });
const { Pool } = require('pg');
const bcrypt = require('bcrypt');
const { v4: uuidv4 } = require('uuid');

const pool = new Pool({
  host: process.env.DB_HOST,
  port: parseInt(process.env.DB_PORT || '5411'),
  database: process.env.DB_NAME,
  user: process.env.DB_USER,
  password: process.env.DB_PASSWORD,
  ssl: false,
});

async function seedData() {
  console.log('🌱 Populando banco de dados com dados de teste...\n');

  try {
    // Hash das senhas
    const passwordHash = await bcrypt.hash('senha123', 10);

    // 1. Criar usuários
    console.log('👥 Criando usuários de teste...');

    const users = [
      {
        id: uuidv4(),
        email: 'admin@cadastro.com',
        name: 'Administrador Sistema',
        password_hash: await bcrypt.hash('admin123', 10),
        phone_number: '+5511999991111',
        cpf: '12345678901',
        email_verified: true,
        phone_verified: true,
      },
      {
        id: uuidv4(),
        email: 'cliente1@example.com',
        name: 'João da Silva',
        password_hash: passwordHash,
        phone_number: '+5511999992222',
        cpf: '98765432100',
        email_verified: true,
        phone_verified: true,
      },
      {
        id: uuidv4(),
        email: 'cliente2@example.com',
        name: 'Maria Santos',
        password_hash: passwordHash,
        phone_number: '+5511999993333',
        cpf: '11122233344',
        email_verified: true,
        phone_verified: false,
      },
      {
        id: uuidv4(),
        email: 'teste@example.com',
        name: 'Usuário Teste',
        password_hash: passwordHash,
        phone_number: '+5511999994444',
        cpf: '55566677788',
        email_verified: false,
        phone_verified: false,
      },
    ];

    for (const user of users) {
      try {
        await pool.query(
          `INSERT INTO users (id, email, name, password_hash, phone_number, cpf, email_verified, phone_verified)
           VALUES ($1, $2, $3, $4, $5, $6, $7, $8)
           ON CONFLICT (email) DO NOTHING`,
          [user.id, user.email, user.name, user.password_hash, user.phone_number, user.cpf, user.email_verified, user.phone_verified]
        );
        console.log(`   ✅ ${user.name} (${user.email})`);
      } catch (err) {
        console.log(`   ⚠️  ${user.email} - já existe`);
      }
    }

    // 2. Criar endereços
    console.log('\n🏠 Criando endereços de teste...');

    const addresses = [
      {
        email: 'cliente1@example.com',
        type: 'home',
        street: 'Rua das Flores',
        number: '123',
        complement: 'Apto 45',
        neighborhood: 'Centro',
        city: 'São Paulo',
        state: 'SP',
        postal_code: '01310-100',
      },
      {
        email: 'cliente2@example.com',
        type: 'home',
        street: 'Avenida Paulista',
        number: '1000',
        complement: null,
        neighborhood: 'Bela Vista',
        city: 'São Paulo',
        state: 'SP',
        postal_code: '01310-200',
      },
    ];

    for (const addr of addresses) {
      const userResult = await pool.query('SELECT id FROM users WHERE email = $1', [addr.email]);
      if (userResult.rows.length > 0) {
        const userId = userResult.rows[0].id;
        await pool.query(
          `INSERT INTO addresses (id, user_id, type, street, number, complement, neighborhood, city, state, postal_code, country, is_default)
           VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12)`,
          [uuidv4(), userId, addr.type, addr.street, addr.number, addr.complement, addr.neighborhood, addr.city, addr.state, addr.postal_code, 'Brasil', true]
        );
        console.log(`   ✅ Endereço para ${addr.email}`);
      }
    }

    // 3. Criar cartões
    console.log('\n💳 Criando cartões de teste...');

    const cards = [
      {
        email: 'cliente1@example.com',
        card_type: 'virtual',
        card_number: '4111111111111111',
        cardholder_name: 'JOAO DA SILVA',
        expiration_month: 12,
        expiration_year: 2026,
        cvv: '123',
        balance: 1500.00,
        is_default: true,
      },
      {
        email: 'cliente1@example.com',
        card_type: 'physical',
        card_number: '5555555555554444',
        cardholder_name: 'JOAO DA SILVA',
        expiration_month: 6,
        expiration_year: 2027,
        cvv: '456',
        balance: 2500.00,
        is_default: false,
      },
      {
        email: 'cliente2@example.com',
        card_type: 'virtual',
        card_number: '4000000000000002',
        cardholder_name: 'MARIA SANTOS',
        expiration_month: 3,
        expiration_year: 2026,
        cvv: '789',
        balance: 500.00,
        is_default: true,
      },
    ];

    for (const card of cards) {
      const userResult = await pool.query('SELECT id FROM users WHERE email = $1', [card.email]);
      if (userResult.rows.length > 0) {
        const userId = userResult.rows[0].id;
        await pool.query(
          `INSERT INTO cards (id, user_id, card_type, card_number, cardholder_name, expiration_month, expiration_year, cvv, status, balance, is_default)
           VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11)`,
          [uuidv4(), userId, card.card_type, card.card_number, card.cardholder_name, card.expiration_month, card.expiration_year, card.cvv, 'active', card.balance, card.is_default]
        );
        console.log(`   ✅ Cartão ${card.card_type} para ${card.email}`);
      }
    }

    // 4. Criar transações
    console.log('\n💰 Criando transações de teste...');

    const transactions = [
      {
        email: 'cliente1@example.com',
        type: 'deposit',
        status: 'completed',
        category: 'other',
        amount: 1000.00,
        description: 'Depósito inicial',
        merchant_name: null,
        days_ago: 7,
      },
      {
        email: 'cliente1@example.com',
        type: 'purchase',
        status: 'completed',
        category: 'food',
        amount: -45.90,
        description: 'Compra no supermercado',
        merchant_name: 'Supermercado Extra',
        days_ago: 2,
      },
      {
        email: 'cliente1@example.com',
        type: 'purchase',
        status: 'completed',
        category: 'transport',
        amount: -25.00,
        description: 'Recarga Uber',
        merchant_name: 'Uber',
        days_ago: 1,
      },
      {
        email: 'cliente2@example.com',
        type: 'deposit',
        status: 'completed',
        category: 'other',
        amount: 500.00,
        description: 'Depósito inicial',
        merchant_name: null,
        days_ago: 5,
      },
      {
        email: 'cliente2@example.com',
        type: 'purchase',
        status: 'completed',
        category: 'shopping',
        amount: -89.90,
        description: 'Compra na Magazine Luiza',
        merchant_name: 'Magazine Luiza',
        days_ago: 3,
      },
    ];

    for (const txn of transactions) {
      const userResult = await pool.query('SELECT id FROM users WHERE email = $1', [txn.email]);
      if (userResult.rows.length > 0) {
        const userId = userResult.rows[0].id;
        const cardResult = await pool.query('SELECT id FROM cards WHERE user_id = $1 AND is_default = true LIMIT 1', [userId]);
        if (cardResult.rows.length > 0) {
          const cardId = cardResult.rows[0].id;
          const createdAt = new Date();
          createdAt.setDate(createdAt.getDate() - txn.days_ago);

          await pool.query(
            `INSERT INTO transactions (id, user_id, card_id, type, status, category, amount, description, merchant_name, created_at)
             VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10)`,
            [uuidv4(), userId, cardId, txn.type, txn.status, txn.category, txn.amount, txn.description, txn.merchant_name, createdAt]
          );
          console.log(`   ✅ ${txn.description} (${txn.email})`);
        }
      }
    }

    // Verificação
    console.log('\n📊 Verificando dados criados...\n');

    const counts = await pool.query(`
      SELECT 'USUÁRIOS' as tabela, COUNT(*) as total FROM users
      UNION ALL
      SELECT 'ENDEREÇOS', COUNT(*) FROM addresses
      UNION ALL
      SELECT 'CARTÕES', COUNT(*) FROM cards
      UNION ALL
      SELECT 'TRANSAÇÕES', COUNT(*) FROM transactions
    `);

    counts.rows.forEach(row => {
      console.log(`   ${row.tabela}: ${row.total}`);
    });

    console.log('\n🎉 Dados de teste criados com sucesso!\n');
    console.log('📝 Usuários disponíveis:');
    console.log('   - admin@cadastro.com (senha: admin123)');
    console.log('   - cliente1@example.com (senha: senha123)');
    console.log('   - cliente2@example.com (senha: senha123)');
    console.log('   - teste@example.com (senha: senha123)\n');

  } catch (error) {
    console.error('❌ Erro ao popular dados:', error.message);
  } finally {
    await pool.end();
  }
}

seedData();
