// Script para popular dados de teste
const { Pool } = require('pg');
const bcrypt = require('bcrypt');
const { v4: uuidv4 } = require('uuid');

const pool = new Pool({
  host: '77.37.41.41',
  port: 5411,
  database: 'cadastro_db',
  user: 'cadastro_user',
  password: 'Hno@uw@q',
  ssl: false,
});

async function seedData() {
  console.log('🌱 Populando banco de dados com dados de teste...\n');

  try {
    const passwordHash = await bcrypt.hash('senha123', 10);
    const adminHash = await bcrypt.hash('admin123', 10);

    // Criar usuários
    console.log('👥 Criando usuários de teste...');

    const users = [
      { email: 'admin@cadastro.com', nome: 'Administrador Sistema', hash: adminHash, telefone: '+5511999991111', cpf: '12345678901' },
      { email: 'cliente1@example.com', nome: 'João da Silva', hash: passwordHash, telefone: '+5511999992222', cpf: '98765432100' },
      { email: 'cliente2@example.com', nome: 'Maria Santos', hash: passwordHash, telefone: '+5511999993333', cpf: '11122233344' },
      { email: 'teste@example.com', nome: 'Usuário Teste', hash: passwordHash, telefone: '+5511999994444', cpf: '55566677788' },
    ];

    for (const user of users) {
      await pool.query(
        `INSERT INTO users (id, email, nome, password_hash, telefone, cpf, email_verified)
         VALUES ($1, $2, $3, $4, $5, $6, true)
         ON CONFLICT (email) DO UPDATE SET updated_at = NOW()`,
        [uuidv4(), user.email, user.nome, user.hash, user.telefone, user.cpf]
      );
      console.log(`   ✅ ${user.nome}`);
    }

    console.log('\n📊 Verificando dados...\n');

    const counts = await pool.query('SELECT COUNT(*) as total FROM users');
    console.log(`   USUÁRIOS: ${counts.rows[0].total}`);

    console.log('\n🎉 Dados criados!\n');
    console.log('📝 Usuários:');
    console.log('   - admin@cadastro.com (senha: admin123)');
    console.log('   - cliente1@example.com (senha: senha123)');
    console.log('   - cliente2@example.com (senha: senha123)');
    console.log('   - teste@example.com (senha: senha123)\n');

  } catch (error) {
    console.error('❌ Erro:', error.message);
  } finally {
    await pool.end();
  }
}

seedData();
