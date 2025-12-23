import nodemailer from 'nodemailer';

// Email configuration - using environment variables for security
const createTransporter = () => {
  // Usar Gmail SMTP em todos os ambientes
  const config = {
    host: process.env.SMTP_HOST || 'smtp.gmail.com',
    port: parseInt(process.env.SMTP_PORT || '587'),
    secure: process.env.SMTP_SECURE === 'true', // false para porta 587
    auth: {
      user: process.env.SMTP_USER,
      pass: process.env.SMTP_PASS,
    },
  };

  console.log(`📧 Configurando transporter de email: ${config.auth.user}`);

  return nodemailer.createTransport(config);
};

/**
 * Send verification code email
 */
export const sendVerificationEmail = async (
  to: string,
  code: string,
  userName?: string
): Promise<void> => {
  const transporter = createTransporter();

  const mailOptions = {
    from: process.env.SMTP_FROM || '"Sistema de Cadastro" <noreply@cadastro.com>',
    to,
    subject: 'Código de Verificação - Cadastro de Benefícios',
    html: `
      <!DOCTYPE html>
      <html>
      <head>
        <meta charset="utf-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <style>
          body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            line-height: 1.6;
            color: #333;
            max-width: 600px;
            margin: 0 auto;
            padding: 20px;
            background-color: #f4f4f4;
          }
          .container {
            background-color: white;
            border-radius: 10px;
            padding: 40px;
            box-shadow: 0 2px 10px rgba(0,0,0,0.1);
          }
          .header {
            text-align: center;
            margin-bottom: 30px;
          }
          .header h1 {
            color: #2196F3;
            margin: 0;
          }
          .code-container {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            border-radius: 8px;
            padding: 20px;
            text-align: center;
            margin: 30px 0;
          }
          .code {
            font-size: 32px;
            font-weight: bold;
            color: white;
            letter-spacing: 8px;
            font-family: 'Courier New', monospace;
          }
          .info {
            background-color: #fff3cd;
            border-left: 4px solid #ffc107;
            padding: 15px;
            margin: 20px 0;
            border-radius: 4px;
          }
          .footer {
            text-align: center;
            margin-top: 30px;
            padding-top: 20px;
            border-top: 1px solid #eee;
            color: #666;
            font-size: 14px;
          }
        </style>
      </head>
      <body>
        <div class="container">
          <div class="header">
            <h1>📧 Verificação de Email</h1>
          </div>

          ${userName ? `<p>Olá, <strong>${userName}</strong>!</p>` : '<p>Olá!</p>'}

          <p>Recebemos uma solicitação para verificar seu endereço de email no <strong>Sistema de Cadastro de Benefícios</strong>.</p>

          <p>Use o código abaixo para completar a verificação:</p>

          <div class="code-container">
            <div class="code">${code}</div>
          </div>

          <div class="info">
            <strong>⏱️ Importante:</strong> Este código expira em <strong>15 minutos</strong>.
          </div>

          <p>Se você não solicitou este código, por favor ignore este email.</p>

          <div class="footer">
            <p>Este é um email automático, por favor não responda.</p>
            <p>&copy; 2025 Sistema de Cadastro de Benefícios</p>
          </div>
        </div>
      </body>
      </html>
    `,
    text: `
      Olá${userName ? `, ${userName}` : ''}!

      Recebemos uma solicitação para verificar seu endereço de email no Sistema de Cadastro de Benefícios.

      Seu código de verificação é: ${code}

      Este código expira em 15 minutos.

      Se você não solicitou este código, por favor ignore este email.

      ---
      Sistema de Cadastro de Benefícios
    `,
  };

  try {
    const info = await transporter.sendMail(mailOptions);

    if (process.env.NODE_ENV !== 'production') {
      console.log('📧 Email de verificação enviado');
      console.log('Message ID:', info.messageId);
      console.log('Preview URL:', nodemailer.getTestMessageUrl(info));
    }
  } catch (error) {
    console.error('❌ Erro ao enviar email:', error);
    throw new Error('Falha ao enviar email de verificação');
  }
};

/**
 * Send password reset email
 */
export const sendPasswordResetEmail = async (
  to: string,
  resetToken: string,
  userName?: string
): Promise<void> => {
  const transporter = createTransporter();

  // In production, this would be your frontend URL
  const resetUrl = `${process.env.FRONTEND_URL || 'http://localhost:3000'}/reset-password?token=${resetToken}`;

  const mailOptions = {
    from: process.env.SMTP_FROM || '"Sistema de Cadastro" <noreply@cadastro.com>',
    to,
    subject: 'Redefinição de Senha - Cadastro de Benefícios',
    html: `
      <!DOCTYPE html>
      <html>
      <head>
        <meta charset="utf-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <style>
          body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            line-height: 1.6;
            color: #333;
            max-width: 600px;
            margin: 0 auto;
            padding: 20px;
            background-color: #f4f4f4;
          }
          .container {
            background-color: white;
            border-radius: 10px;
            padding: 40px;
            box-shadow: 0 2px 10px rgba(0,0,0,0.1);
          }
          .header {
            text-align: center;
            margin-bottom: 30px;
          }
          .header h1 {
            color: #f44336;
            margin: 0;
          }
          .button {
            display: inline-block;
            padding: 15px 30px;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            text-decoration: none;
            border-radius: 8px;
            font-weight: bold;
            text-align: center;
            margin: 20px 0;
          }
          .info {
            background-color: #ffebee;
            border-left: 4px solid #f44336;
            padding: 15px;
            margin: 20px 0;
            border-radius: 4px;
          }
          .footer {
            text-align: center;
            margin-top: 30px;
            padding-top: 20px;
            border-top: 1px solid #eee;
            color: #666;
            font-size: 14px;
          }
        </style>
      </head>
      <body>
        <div class="container">
          <div class="header">
            <h1>🔐 Redefinição de Senha</h1>
          </div>

          ${userName ? `<p>Olá, <strong>${userName}</strong>!</p>` : '<p>Olá!</p>'}

          <p>Recebemos uma solicitação para redefinir sua senha no <strong>Sistema de Cadastro de Benefícios</strong>.</p>

          <p style="text-align: center;">
            <a href="${resetUrl}" class="button">Redefinir Senha</a>
          </p>

          <div class="info">
            <strong>⏱️ Importante:</strong> Este link expira em <strong>1 hora</strong>.
          </div>

          <p>Se você não solicitou a redefinição de senha, por favor ignore este email. Sua senha permanecerá inalterada.</p>

          <p style="font-size: 12px; color: #666;">
            Se o botão não funcionar, copie e cole o seguinte link no seu navegador:<br>
            <code style="background: #f5f5f5; padding: 5px; border-radius: 3px; word-break: break-all;">${resetUrl}</code>
          </p>

          <div class="footer">
            <p>Este é um email automático, por favor não responda.</p>
            <p>&copy; 2025 Sistema de Cadastro de Benefícios</p>
          </div>
        </div>
      </body>
      </html>
    `,
    text: `
      Olá${userName ? `, ${userName}` : ''}!

      Recebemos uma solicitação para redefinir sua senha no Sistema de Cadastro de Benefícios.

      Para redefinir sua senha, acesse o seguinte link:
      ${resetUrl}

      Este link expira em 1 hora.

      Se você não solicitou a redefinição de senha, por favor ignore este email. Sua senha permanecerá inalterada.

      ---
      Sistema de Cadastro de Benefícios
    `,
  };

  try {
    const info = await transporter.sendMail(mailOptions);

    if (process.env.NODE_ENV !== 'production') {
      console.log('📧 Email de redefinição de senha enviado');
      console.log('Message ID:', info.messageId);
      console.log('Preview URL:', nodemailer.getTestMessageUrl(info));
    }
  } catch (error) {
    console.error('❌ Erro ao enviar email:', error);
    throw new Error('Falha ao enviar email de redefinição de senha');
  }
};

/**
 * Send welcome email after successful registration
 */
export const sendWelcomeEmail = async (
  to: string,
  userName: string
): Promise<void> => {
  const transporter = createTransporter();

  const mailOptions = {
    from: process.env.SMTP_FROM || '"Sistema de Cadastro" <noreply@cadastro.com>',
    to,
    subject: 'Bem-vindo ao Sistema de Cadastro de Benefícios! 🎉',
    html: `
      <!DOCTYPE html>
      <html>
      <head>
        <meta charset="utf-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <style>
          body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            line-height: 1.6;
            color: #333;
            max-width: 600px;
            margin: 0 auto;
            padding: 20px;
            background-color: #f4f4f4;
          }
          .container {
            background-color: white;
            border-radius: 10px;
            padding: 40px;
            box-shadow: 0 2px 10px rgba(0,0,0,0.1);
          }
          .header {
            text-align: center;
            margin-bottom: 30px;
          }
          .header h1 {
            color: #4CAF50;
            margin: 0;
          }
          .welcome-banner {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            border-radius: 8px;
            padding: 30px;
            text-align: center;
            color: white;
            margin: 30px 0;
          }
          .features {
            display: grid;
            grid-template-columns: 1fr;
            gap: 15px;
            margin: 20px 0;
          }
          .feature {
            padding: 15px;
            background: #f5f5f5;
            border-radius: 8px;
            border-left: 4px solid #2196F3;
          }
          .footer {
            text-align: center;
            margin-top: 30px;
            padding-top: 20px;
            border-top: 1px solid #eee;
            color: #666;
            font-size: 14px;
          }
        </style>
      </head>
      <body>
        <div class="container">
          <div class="header">
            <h1>🎉 Bem-vindo!</h1>
          </div>

          <div class="welcome-banner">
            <h2 style="margin: 0;">Olá, ${userName}!</h2>
            <p style="margin: 10px 0 0 0;">Seu cadastro foi concluído com sucesso!</p>
          </div>

          <p>Estamos felizes em ter você conosco no <strong>Sistema de Cadastro de Benefícios</strong>.</p>

          <div class="features">
            <div class="feature">
              <strong>✅ Perfil Completo</strong><br>
              Seu perfil está pronto e você já pode acessar todos os recursos do sistema.
            </div>
            <div class="feature">
              <strong>🔒 Segurança</strong><br>
              Seus dados estão protegidos com as melhores práticas de segurança.
            </div>
            <div class="feature">
              <strong>📱 Acesso Rápido</strong><br>
              Acesse o sistema a qualquer momento através do nosso aplicativo.
            </div>
          </div>

          <p>Se você tiver alguma dúvida ou precisar de ajuda, não hesite em entrar em contato conosco.</p>

          <div class="footer">
            <p>Este é um email automático, por favor não responda.</p>
            <p>&copy; 2025 Sistema de Cadastro de Benefícios</p>
          </div>
        </div>
      </body>
      </html>
    `,
    text: `
      Bem-vindo, ${userName}!

      Seu cadastro foi concluído com sucesso no Sistema de Cadastro de Benefícios.

      Estamos felizes em ter você conosco!

      ✅ Perfil Completo - Seu perfil está pronto e você já pode acessar todos os recursos do sistema.
      🔒 Segurança - Seus dados estão protegidos com as melhores práticas de segurança.
      📱 Acesso Rápido - Acesse o sistema a qualquer momento através do nosso aplicativo.

      Se você tiver alguma dúvida ou precisar de ajuda, não hesite em entrar em contato conosco.

      ---
      Sistema de Cadastro de Benefícios
    `,
  };

  try {
    const info = await transporter.sendMail(mailOptions);

    if (process.env.NODE_ENV !== 'production') {
      console.log('📧 Email de boas-vindas enviado');
      console.log('Message ID:', info.messageId);
      console.log('Preview URL:', nodemailer.getTestMessageUrl(info));
    }
  } catch (error) {
    console.error('❌ Erro ao enviar email:', error);
    // Don't throw error for welcome email - it's not critical
  }
};
