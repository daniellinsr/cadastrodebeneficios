import dotenv from 'dotenv';
import axios from 'axios';

// Carregar variáveis de ambiente
dotenv.config();

const API_URL = 'http://localhost:3000/api/v1';

/**
 * Teste completo do fluxo de registro e verificação de email
 */
async function testRegistrationFlow() {
  console.log('🧪 Testando fluxo completo de registro e verificação de email\n');

  // Dados de teste - usar um email único para cada teste
  const timestamp = Date.now();
  const randomCpf = String(timestamp).substring(3, 14).padEnd(11, '0');
  const testUser = {
    name: 'João Silva Teste',
    email: `teste${timestamp}@example.com`, // Email único
    password: 'SenhaForte123!',
    phone_number: `119${timestamp.toString().substring(5, 13)}`,
    cpf: randomCpf, // CPF único para cada teste
    birth_date: '1990-01-01',
    cep: '01310-100',
    street: 'Av. Paulista',
    number: '1000',
    neighborhood: 'Bela Vista',
    city: 'São Paulo',
    state: 'SP',
  };

  let accessToken = '';
  let userId = '';

  try {
    // Passo 1: Registrar novo usuário
    console.log('📝 Passo 1: Registrando novo usuário...');
    const registerResponse = await axios.post(`${API_URL}/auth/register`, testUser);

    accessToken = registerResponse.data.access_token || registerResponse.data.accessToken;
    console.log('✅ Usuário registrado com sucesso!');
    console.log('   Access Token:', accessToken ? accessToken.substring(0, 20) + '...' : 'N/A');
    console.log('   Email:', testUser.email);
    console.log('   Dados retornados:', JSON.stringify(registerResponse.data, null, 2));
    console.log('');

    // Aguardar 1 segundo
    await new Promise(resolve => setTimeout(resolve, 1000));

    // Passo 2: Obter usuário atual (para verificar status)
    console.log('👤 Passo 2: Verificando dados do usuário...');
    const userResponse = await axios.get(`${API_URL}/auth/me`, {
      headers: {
        Authorization: `Bearer ${accessToken}`,
      },
    });

    userId = userResponse.data.id;
    console.log('✅ Dados do usuário obtidos:');
    console.log('   ID:', userId);
    console.log('   Nome:', userResponse.data.name);
    console.log('   Email:', userResponse.data.email);
    console.log('   Email Verificado:', userResponse.data.emailVerified);
    console.log('   Telefone Verificado:', userResponse.data.phoneVerified);
    console.log('');

    // Aguardar 1 segundo
    await new Promise(resolve => setTimeout(resolve, 1000));

    // Passo 3: Solicitar código de verificação por email
    console.log('📧 Passo 3: Solicitando código de verificação por email...');
    console.log('   ⚠️ IMPORTANTE: Email será enviado para cartaobeneficios0@gmail.com');
    console.log('   ⚠️ (configurado no email.service.ts para desenvolvimento)');
    console.log('');

    const sendCodeResponse = await axios.post(
      `${API_URL}/verification/send`,
      { type: 'email' },
      {
        headers: {
          Authorization: `Bearer ${accessToken}`,
        },
      }
    );

    console.log('✅ Código de verificação enviado!');
    console.log('   Expira em:', new Date(sendCodeResponse.data.expiresAt).toLocaleString());
    console.log('');
    console.log('📬 Verifique o email: cartaobeneficios0@gmail.com');
    console.log('   O código tem 6 dígitos numéricos');
    console.log('');

    // Instruções para o usuário
    console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    console.log('📝 PRÓXIMOS PASSOS MANUAIS:');
    console.log('');
    console.log('1. Abra o email em: cartaobeneficios0@gmail.com');
    console.log('2. Copie o código de 6 dígitos');
    console.log('3. Execute o comando abaixo para verificar:');
    console.log('');
    console.log(`   curl -X POST ${API_URL}/verification/verify \\`);
    console.log(`     -H "Authorization: Bearer ${accessToken}" \\`);
    console.log(`     -H "Content-Type: application/json" \\`);
    console.log(`     -d '{"type": "email", "code": "CODIGO_AQUI"}'`);
    console.log('');
    console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    console.log('');

    // Passo 4: Verificar status de verificação
    console.log('🔍 Passo 4: Verificando status de verificação...');
    const statusResponse = await axios.get(`${API_URL}/verification/status`, {
      headers: {
        Authorization: `Bearer ${accessToken}`,
      },
    });

    console.log('✅ Status de verificação:');
    console.log('   Email Verificado:', statusResponse.data.emailVerified);
    console.log('   Telefone Verificado:', statusResponse.data.phoneVerified);
    console.log('');

    console.log('🎉 Teste de fluxo de registro completado com sucesso!');
    console.log('');
    console.log('📊 Resumo:');
    console.log('   ✅ Usuário registrado');
    console.log('   ✅ Email de verificação enviado');
    console.log('   ⏳ Aguardando verificação manual do código');
    console.log('');

  } catch (error: any) {
    console.error('❌ Erro durante o teste:', error.response?.data || error.message);
    if (error.response) {
      console.error('Status:', error.response.status);
      console.error('Data:', JSON.stringify(error.response.data, null, 2));
    }
    process.exit(1);
  }
}

// Verificar se o servidor está rodando
async function checkServer() {
  try {
    await axios.get('http://localhost:3000/health');
    console.log('✅ Servidor backend está rodando\n');
    return true;
  } catch (error) {
    console.error('❌ Servidor backend NÃO está rodando!');
    console.error('   Execute: cd backend && npm run dev');
    console.error('');
    return false;
  }
}

// Executar testes
(async () => {
  const serverRunning = await checkServer();
  if (serverRunning) {
    await testRegistrationFlow();
  } else {
    process.exit(1);
  }
})();
