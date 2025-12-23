import dotenv from 'dotenv';
import { sendVerificationEmail, sendWelcomeEmail } from './services/email.service';

// Carregar variáveis de ambiente
dotenv.config();

/**
 * Script de teste para envio de emails
 */
async function testEmailService() {
  console.log('🧪 Iniciando testes de envio de email...\n');

  const testEmail = 'cartaobeneficios0@gmail.com'; // Email de teste (mesmo remetente)
  const testCode = '123456';
  const testName = 'João Silva';

  try {
    // Teste 1: Email de verificação
    console.log('📧 Teste 1: Enviando email de verificação...');
    await sendVerificationEmail(testEmail, testCode, testName);
    console.log('✅ Email de verificação enviado com sucesso!\n');

    // Aguardar 2 segundos antes do próximo teste
    await new Promise(resolve => setTimeout(resolve, 2000));

    // Teste 2: Email de boas-vindas
    console.log('📧 Teste 2: Enviando email de boas-vindas...');
    await sendWelcomeEmail(testEmail, testName);
    console.log('✅ Email de boas-vindas enviado com sucesso!\n');

    console.log('🎉 Todos os testes de email passaram!');
    console.log('\n📬 Verifique a caixa de entrada de:', testEmail);
    console.log('⚠️ Nota: Os emails podem estar na pasta de SPAM na primeira vez.');
  } catch (error) {
    console.error('❌ Erro ao testar emails:', error);
    process.exit(1);
  }
}

// Executar testes
testEmailService();
