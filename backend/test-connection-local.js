// Script para testar conexão com PostgreSQL LOCAL
// Use este se você tiver PostgreSQL instalado localmente

const { Pool } = require('pg');

// Configuração para PostgreSQL LOCAL
const pool = new Pool({
  host: 'localhost',
  port: 5432,
  database: 'postgres', // banco padrão
  user: 'postgres',     // usuário padrão
  password: 'postgres', // ALTERE PARA SUA SENHA
});

async function testLocalConnection() {
  console.log('🔍 Testando conexão com PostgreSQL LOCAL...\n');
  console.log('📊 Configuração:');
  console.log(`   Host: localhost`);
  console.log(`   Port: 5432`);
  console.log(`   Database: postgres`);
  console.log(`   User: postgres\n`);

  try {
    const result = await pool.query('SELECT NOW() as current_time, version()');
    console.log('✅ Conexão LOCAL estabelecida com sucesso!');
    console.log(`   Horário do servidor: ${result.rows[0].current_time}`);
    console.log(`   Versão: ${result.rows[0].version.split(',')[0]}\n`);

    console.log('💡 Para usar o banco local, você precisa:');
    console.log('   1. Criar o banco: CREATE DATABASE cadastro_db;');
    console.log('   2. Criar o usuário: CREATE USER cadastro_user WITH PASSWORD \'sua_senha\';');
    console.log('   3. Dar permissões: GRANT ALL PRIVILEGES ON DATABASE cadastro_db TO cadastro_user;');
    console.log('   4. Atualizar o arquivo .env com host=localhost\n');

  } catch (error) {
    console.error('❌ Erro ao conectar ao PostgreSQL local:\n');
    console.error(`   ${error.message}\n`);
    console.log('💡 Você tem PostgreSQL instalado localmente?');
    console.log('   - Windows: https://www.postgresql.org/download/windows/');
    console.log('   - Ou use Docker: docker run --name postgres -e POSTGRES_PASSWORD=postgres -p 5432:5432 -d postgres\n');
  } finally {
    await pool.end();
    process.exit();
  }
}

testLocalConnection();
