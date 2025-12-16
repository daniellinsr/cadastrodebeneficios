// Script simples para testar conexão com PostgreSQL
require('dotenv').config();
const { Pool } = require('pg');

const pool = new Pool({
  host: process.env.DB_HOST,
  port: parseInt(process.env.DB_PORT || '5432'),
  database: process.env.DB_NAME,
  user: process.env.DB_USER,
  password: process.env.DB_PASSWORD,
  ssl: process.env.DB_SSL_MODE === 'require' ? { rejectUnauthorized: false } : false,
});

async function testConnection() {
  console.log('🔍 Testando conexão com PostgreSQL...\n');
  console.log('📊 Configuração:');
  console.log(`   Host: ${process.env.DB_HOST}`);
  console.log(`   Port: ${process.env.DB_PORT}`);
  console.log(`   Database: ${process.env.DB_NAME}`);
  console.log(`   User: ${process.env.DB_USER}`);
  console.log(`   SSL: ${process.env.DB_SSL_MODE}\n`);

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

    if (error.code === 'ECONNREFUSED') {
      console.log('💡 Dica: Verifique se o host e porta estão corretos.');
    } else if (error.code === '28P01') {
      console.log('💡 Dica: Verifique o usuário e senha no arquivo .env');
    } else if (error.code === '3D000') {
      console.log('💡 Dica: O banco de dados não existe. Verifique o nome no arquivo .env');
    }
  } finally {
    await pool.end();
    process.exit();
  }
}

testConnection();
