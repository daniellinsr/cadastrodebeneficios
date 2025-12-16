// Script de teste de conexão PostgreSQL
const { Pool } = require('pg');

// Configuração direta (sem .env para evitar cache)
const pool = new Pool({
  host: '77.37.41.41',
  port: 5411,
  database: 'cadastro_db',
  user: 'cadastro_user',
  password: 'Hno@uw@q',
  ssl: false, // Desabilitado
});

async function testConnection() {
  console.log('🔍 Testando conexão com PostgreSQL...\n');
  console.log('📊 Configuração:');
  console.log('   Host: 77.37.41.41');
  console.log('   Port: 5411');
  console.log('   Database: cadastro_db');
  console.log('   User: cadastro_user');
  console.log('   SSL: disabled\n');

  try {
    // Teste 1: Conectar ao banco
    console.log('1️⃣ Testando conexão básica...');
    const result1 = await pool.query('SELECT NOW() as current_time, version()');
    console.log('✅ Conexão estabelecida com sucesso!');
    console.log(`   Horário do servidor: ${result1.rows[0].current_time}`);
    console.log(`   Versão: ${result1.rows[0].version.split(',')[0]}\n`);

    // Teste 2: Listar tabelas
    console.log('2️⃣ Listando tabelas criadas...');
    const result2 = await pool.query(`
      SELECT table_name
      FROM information_schema.tables
      WHERE table_schema = 'public'
      ORDER BY table_name
    `);

    if (result2.rows.length > 0) {
      console.log(`✅ ${result2.rows.length} tabelas encontradas:`);
      result2.rows.forEach(row => {
        console.log(`   - ${row.table_name}`);
      });
      console.log('');
    } else {
      console.log('⚠️  Nenhuma tabela encontrada. Execute as migrations primeiro.\n');
    }

    // Teste 3: Contar usuários
    console.log('3️⃣ Verificando tabela de usuários...');
    const result3 = await pool.query('SELECT COUNT(*) as total FROM users');
    console.log(`✅ Tabela users: ${result3.rows[0].total} usuário(s) cadastrado(s)\n`);

    // Teste 4: Verificar ENUMs
    console.log('4️⃣ Verificando ENUMs criados...');
    const result4 = await pool.query(`
      SELECT typname
      FROM pg_type
      WHERE typtype = 'e'
      ORDER BY typname
    `);

    if (result4.rows.length > 0) {
      console.log(`✅ ${result4.rows.length} ENUMs encontrados:`);
      result4.rows.forEach(row => {
        console.log(`   - ${row.typname}`);
      });
      console.log('');
    }

    console.log('🎉 Todos os testes passaram!\n');
    console.log('✅ O banco de dados está funcionando corretamente.');
    console.log('✅ As migrations foram executadas com sucesso.');
    console.log('✅ Pronto para usar!\n');

  } catch (error) {
    console.error('❌ Erro ao conectar ao banco de dados:\n');
    console.error(`   ${error.message}\n`);
  } finally {
    await pool.end();
  }
}

testConnection();
