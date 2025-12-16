// Script para popular dados de teste - configuração hardcoded
const { Pool } = require('pg');
const bcrypt = require('bcrypt');
const { v4: uuidv4 } = require('uuid');

// Configuração hardcoded (porta correta!)
const pool = new Pool({
  host: '77.37.41.41',
  port: 5411, // Porta correta!
  database: 'cadastro_db',
  user: 'cadastro_user',
  password: 'Hno@uw@q',
  ssl: false,
});

async function seedData() {
  console.log('🌱 Populando banco de dados com dados de teste...\n');
  console.log('📊 Configuração: 77.37.41.41:5411/cadastro_db\n');

  try {
    // Hash das senhas
    const passwordHash = await bcrypt.hash('senha123', 10);
    const adminHash = await bcrypt.hash('admin123', 10);

    // 1. Criar usuários
    console.log('👥 Criando usuários de teste...');

    const users = [
      { email: 'admin@cadastro.com', name: 'Administrador Sistema', hash: adminHash, phone: '+5511999991111', cpf: '12345678901' },
      { email: 'cliente1@example.com', name: 'João da Silva', hash: passwordHash, phone: '+5511999992222', cpf: '98765432100' },
      { email: 'cliente2@example.com', name: 'Maria Santos', hash: passwordHash, phone: '+5511999993333', cpf: '11122233344' },
      { email: 'teste@example.com', name: 'Usuário Teste', hash: passwordHash, phone: '+5511999994444', cpf: '55566677788' },
    ];

    for (const user of users) {
      const result = await pool.query(
        `INSERT INTO users (id, email, name, password_hash, phone_number, cpf, email_verified, phone_verified)
         VALUES ($1, $2, $3, $4, $5, $6, true, true)
         ON CONFLICT (email) DO UPDATE SET updated_at = NOW()
         RETURNING id`,
        [uuidv4(), user.email, user.name, user.hash, user.phone, user.cpf]
      );
      console.log(`   ✅ ${user.name} (${user.email})`);
    }

    // 2. Criar endereços
    console.log('\n🏠 Criando endereços de teste...');

    for (const userEmail of ['cliente1@example.com', 'cliente2@example.com']) {
      const userResult = await pool.query('SELECT id FROM users WHERE email = $1', [userEmail]);
      if (userResult.rows.length > 0) {
        const userId = userResult.rows[0].id;
        const street = userEmail.includes('cliente1') ? 'Rua das Flores' : 'Avenida Paulista';
        await pool.query(
          `INSERT INTO addresses (id, user_id, type, street, number, neighborhood, city, state, postal_code, country, is_default)
           VALUES ($1, $2, 'home', $3, '123', 'Centro', 'São Paulo', 'SP', '01310-100', 'Brasil', true)
           ON CONFLICT DO NOTHING`,
          [uuidv4(), userId, street]
        );
        console.log(`   ✅ Endereço para ${userEmail}`);
      }
    }

    // 3. Criar cartões
    console.log('\n💳 Criando cartões de teste...');

    for (const userEmail of ['cliente1@example.com', 'cliente2@example.com']) {
      const userResult = await pool.query('SELECT id FROM users WHERE email = $1', [userEmail]);
      if (userResult.rows.length > 0) {
        const userId = userResult.rows[0].id;
        await pool.query(
          `INSERT INTO cards (id, user_id, card_type, card_number, cardholder_name, expiration_month, expiration_year, cvv, status, balance, is_default)
           VALUES ($1, $2, 'virtual', '4111111111111111', 'TITULAR', 12, 2026, '123', 'active', 1500.00, true)
           ON CONFLICT DO NOTHING`,
          [uuidv4(), userId]
        );
        console.log(`   ✅ Cartão para ${userEmail}`);
      }
    }

    // 4. Criar transações
    console.log('\n💰 Criando transações de teste...');

    for (const userEmail of ['cliente1@example.com', 'cliente2@example.com']) {
      const userResult = await pool.query('SELECT id FROM users WHERE email = $1', [userEmail]);
      if (userResult.rows.length > 0) {
        const userId = userResult.rows[0].id;
        const cardResult = await pool.query('SELECT id FROM cards WHERE user_id = $1 LIMIT 1', [userId]);
        if (cardResult.rows.length > 0) {
          const cardId = cardResult.rows[0].id;

          // Depósito
          await pool.query(
            `INSERT INTO transactions (id, user_id, card_id, type, status, category, amount, description, created_at)
             VALUES ($1, $2, $3, 'deposit', 'completed', 'other', 1000.00, 'Depósito inicial', NOW() - INTERVAL '7 days')`,
            [uuidv4(), userId, cardId]
          );

          // Compra
          await pool.query(
            `INSERT INTO transactions (id, user_id, card_id, type, status, category, amount, description, merchant_name, created_at)
             VALUES ($1, $2, $3, 'purchase', 'completed', 'food', -45.90, 'Compra no supermercado', 'Extra', NOW() - INTERVAL '2 days')`,
            [uuidv4(), userId, cardId]
          );

          console.log(`   ✅ Transações para ${userEmail}`);
        }
      }
    }

    // Verificação
    console.log('\n📊 Verificando dados criados...\n');

    const counts = await pool.query(`
      SELECT 'USUÁRIOS' as tabela, COUNT(*) as total FROM users
      UNION ALL SELECT 'ENDEREÇOS', COUNT(*) FROM addresses
      UNION ALL SELECT 'CARTÕES', COUNT(*) FROM cards
      UNION ALL SELECT 'TRANSAÇÕES', COUNT(*) FROM transactions
    `);

    counts.rows.forEach(row => {
      console.log(`   ${row.tabela}: ${row.total}`);
    });

    console.log('\n🎉 Dados de teste criados com sucesso!\n');
    console.log('📝 Usuários disponíveis para login:');
    console.log('   - admin@cadastro.com (senha: admin123)');
    console.log('   - cliente1@example.com (senha: senha123)');
    console.log('   - cliente2@example.com (senha: senha123)');
    console.log('   - teste@example.com (senha: senha123)\n');

  } catch (error) {
    console.error('❌ Erro:', error.message);
    console.error(error);
  } finally {
    await pool.end();
  }
}

seedData();
