# Manual do Usuário - Sistema de Cadastro de Benefícios
## Versão 1.0

---

**Data de Publicação:** 18 de Dezembro de 2025
**Versão do Sistema:** 1.0.0
**Plataforma:** Mobile (Android/iOS) e Web

---

## 📑 Índice

1. [Introdução](#1-introdução)
2. [Requisitos do Sistema](#2-requisitos-do-sistema)
3. [Instalação e Primeiro Acesso](#3-instalação-e-primeiro-acesso)
4. [Tela Inicial (Landing Page)](#4-tela-inicial-landing-page)
5. [Cadastro de Novo Usuário](#5-cadastro-de-novo-usuário)
6. [Login no Sistema](#6-login-no-sistema)
7. [Verificação de Email](#7-verificação-de-email)
8. [Perfil do Usuário](#8-perfil-do-usuário)
9. [Recuperação de Senha](#9-recuperação-de-senha)
10. [Regras de Negócio](#10-regras-de-negócio)
11. [Perguntas Frequentes (FAQ)](#11-perguntas-frequentes-faq)
12. [Solução de Problemas](#12-solução-de-problemas)
13. [Suporte Técnico](#13-suporte-técnico)

---

## 1. Introdução

### 1.1 Sobre o Sistema

O **Sistema de Cadastro de Benefícios** é uma plataforma digital desenvolvida para simplificar e modernizar o processo de cadastro de beneficiários. O sistema oferece uma experiência completa e segura, permitindo que os usuários:

- Realizem cadastro completo de forma intuitiva
- Façam login com email/senha ou Google
- Verifiquem identidade por email
- Gerenciem seus dados pessoais
- Acessem benefícios disponíveis

### 1.2 Principais Características

✅ **Interface Intuitiva:** Design moderno e fácil de usar
✅ **Segurança:** Criptografia de dados e autenticação segura
✅ **Multi-plataforma:** Disponível para Android, iOS e Web
✅ **Login Social:** Integração com Google OAuth
✅ **Verificação:** Sistema de verificação por email
✅ **Validação:** Validação automática de CPF, telefone e CEP

### 1.3 Público-Alvo

- Beneficiários que desejam se cadastrar no sistema
- Usuários que precisam gerenciar seus dados pessoais
- Pessoas que buscam acesso a benefícios sociais

---

## 2. Requisitos do Sistema

### 2.1 Dispositivos Móveis

#### Android
- **Versão Mínima:** Android 6.0 (API 23) ou superior
- **Armazenamento:** 100 MB de espaço livre
- **Conexão:** Internet (Wi-Fi ou dados móveis)
- **Resolução:** 720x1280 pixels ou superior

#### iOS
- **Versão Mínima:** iOS 12.0 ou superior
- **Armazenamento:** 100 MB de espaço livre
- **Conexão:** Internet (Wi-Fi ou dados móveis)
- **Dispositivos:** iPhone 6s ou posterior

### 2.2 Web

- **Navegadores Suportados:**
  - Google Chrome 90+
  - Mozilla Firefox 88+
  - Safari 14+
  - Microsoft Edge 90+
- **Resolução Mínima:** 1024x768 pixels
- **Conexão:** Banda larga estável

### 2.3 Dados Necessários para Cadastro

- Nome completo
- Email válido
- Telefone celular com DDD
- CPF (opcional, mas recomendado)
- Data de nascimento
- Endereço completo (CEP, rua, número, bairro, cidade, estado)
- Senha segura (mínimo 8 caracteres)

---

## 3. Instalação e Primeiro Acesso

### 3.1 Download do Aplicativo

#### Android (Google Play Store)
1. Abra a **Google Play Store**
2. Busque por "**Cadastro de Benefícios**"
3. Toque em "**Instalar**"
4. Aguarde o download e instalação
5. Toque em "**Abrir**"

#### iOS (App Store)
1. Abra a **App Store**
2. Busque por "**Cadastro de Benefícios**"
3. Toque em "**Obter**"
4. Autentique com Face ID/Touch ID
5. Aguarde o download e instalação
6. Toque em "**Abrir**"

#### Web
1. Acesse: `https://cadastro.beneficios.gov.br`
2. O sistema carrega automaticamente
3. Nenhuma instalação necessária

### 3.2 Primeiro Acesso

Ao abrir o aplicativo pela primeira vez:

1. **Tela de Boas-Vindas:** Você verá a landing page com informações sobre o sistema
2. **Opções Disponíveis:**
   - **Entrar:** Para usuários já cadastrados
   - **Cadastrar:** Para novos usuários
   - **Saber Mais:** Informações detalhadas sobre benefícios

---

## 4. Tela Inicial (Landing Page)

### 4.1 Visão Geral

A **Landing Page** é a primeira tela que você vê ao acessar o sistema. Ela apresenta:

![Landing Page](images/landing_page.png)

#### Elementos da Tela:

1. **Cabeçalho (Header)**
   - Logo do sistema
   - Botões "Entrar" e "Cadastrar"
   - Menu de navegação (versão web)

2. **Seção Hero (Principal)**
   - Título: "Cadastro de Benefícios Simplificado"
   - Subtítulo explicativo
   - Botão de ação principal: "Começar Agora"
   - Imagem ilustrativa

3. **Seção de Benefícios**
   - Cards explicativos sobre vantagens do sistema:
     - 📱 Acesso Fácil
     - 🔒 Seguro e Confiável
     - ⚡ Rápido e Eficiente
     - ✅ Suporte Completo

4. **Seção "Como Funciona"**
   - Passo 1: Criar conta
   - Passo 2: Preencher dados
   - Passo 3: Verificar email
   - Passo 4: Acessar benefícios

5. **Rodapé (Footer)**
   - Links úteis
   - Informações de contato
   - Política de privacidade
   - Termos de uso

### 4.2 Navegação

- **Botão "Entrar":** Leva à tela de login
- **Botão "Cadastrar":** Inicia o processo de cadastro
- **Scroll para baixo:** Veja mais informações sobre o sistema

---

## 5. Cadastro de Novo Usuário

O processo de cadastro é dividido em **4 etapas** para facilitar o preenchimento.

### 5.1 Etapa 1: Introdução e Login Social

![Registro - Introdução](images/registration_intro.png)

#### Opções Disponíveis:

**A) Cadastro com Google (Recomendado)**

1. Toque no botão **"Continuar com Google"**
2. Selecione sua conta Google
3. Autorize o acesso aos dados básicos (nome e email)
4. O sistema preenche automaticamente:
   - Nome completo
   - Email
5. **Você será direcionado para completar o perfil** (CPF, telefone, endereço)

**B) Cadastro com Email**

1. Toque no botão **"Cadastrar com Email"**
2. Você será direcionado para o formulário de identificação

### 5.2 Etapa 2: Dados de Identificação

![Registro - Identificação](images/registration_identification.png)

#### Campos Obrigatórios:

1. **Nome Completo**
   - Digite seu nome como consta em documentos oficiais
   - Mínimo: 3 caracteres
   - Apenas letras e espaços

2. **Email**
   - Digite um email válido e ativo
   - Formato: nome@dominio.com
   - **Será usado para login e verificação**

3. **Telefone Celular**
   - Formato: (XX) XXXXX-XXXX
   - Exemplo: (11) 98765-4321
   - O sistema formata automaticamente

4. **CPF** (Opcional, mas recomendado)
   - Formato: XXX.XXX.XXX-XX
   - Exemplo: 123.456.789-09
   - O sistema valida automaticamente
   - **Importante:** CPF inválido não será aceito

5. **Data de Nascimento**
   - Formato: DD/MM/AAAA
   - Exemplo: 15/06/1990
   - **Você deve ter pelo menos 18 anos**

#### Validações Automáticas:

✅ **Nome:** Verifica se tem pelo menos 3 caracteres
✅ **Email:** Valida formato (deve conter @ e domínio válido)
✅ **Telefone:** Valida DDD e quantidade de dígitos (10 ou 11)
✅ **CPF:** Valida dígitos verificadores (algoritmo oficial)
✅ **Data:** Valida formato, datas impossíveis e idade mínima (18 anos)

#### Regras Especiais:

- **Data de Nascimento:** O sistema valida:
  - Dia entre 1 e 31
  - Mês entre 1 e 12
  - Ano não pode ser futuro
  - Considera anos bissextos (29 de fevereiro)
  - Idade mínima: 18 anos

- **CPF:** Se informado, deve ser válido. CPFs conhecidos como inválidos não são aceitos (ex: 111.111.111-11, 000.000.000-00)

#### Botões:

- **"Próximo":** Avança para etapa de endereço (só habilitado se todos os campos estiverem válidos)
- **"Voltar":** Retorna para tela anterior

### 5.3 Etapa 3: Endereço

![Registro - Endereço](images/registration_address.png)

#### Campos do Formulário:

1. **CEP**
   - Formato: XXXXX-XXX
   - Exemplo: 01310-100
   - **Busca automática:** Ao digitar CEP válido, o sistema preenche automaticamente os campos de endereço usando ViaCEP

2. **Logradouro** (Rua/Avenida)
   - Preenchido automaticamente pelo CEP
   - Pode ser editado manualmente

3. **Número**
   - Número do imóvel
   - Campo obrigatório

4. **Complemento** (Opcional)
   - Apartamento, bloco, casa, etc.
   - Exemplo: "Apto 101 Bloco A"

5. **Bairro**
   - Preenchido automaticamente pelo CEP
   - Pode ser editado manualmente

6. **Cidade**
   - Preenchida automaticamente pelo CEP
   - Pode ser editada manualmente

7. **Estado (UF)**
   - Preenchido automaticamente pelo CEP
   - Formato: Sigla de 2 letras (SP, RJ, MG, etc.)

#### Como Usar a Busca de CEP:

1. Digite o CEP no campo (com ou sem hífen)
2. Aguarde 2 segundos
3. O sistema busca automaticamente na base dos Correios
4. Campos são preenchidos automaticamente
5. **Se CEP não for encontrado:** Preencha os campos manualmente

#### Indicadores Visuais:

- 🔍 **Ícone de lupa:** Busca em andamento
- ✅ **Campos preenchidos:** CEP encontrado
- ❌ **Mensagem de erro:** CEP inválido ou não encontrado

#### Botões:

- **"Próximo":** Avança para etapa de senha
- **"Voltar":** Retorna para etapa de identificação

### 5.4 Etapa 4: Senha

![Registro - Senha](images/registration_password.png)

#### Campos do Formulário:

1. **Senha**
   - Mínimo: 8 caracteres
   - **Indicador de força da senha:**
     - 🔴 Muito Fraca (0-1): Apenas números ou letras
     - 🟠 Fraca (2): Letras minúsculas e números
     - 🟡 Média (3): Letras maiúsculas, minúsculas e números
     - 🟢 Forte (4): Acima + caracteres especiais
     - 🟢 Muito Forte (5): Acima + mais de 12 caracteres

2. **Confirmar Senha**
   - Digite a mesma senha
   - **Validação:** Deve ser idêntica à senha

#### Requisitos de Senha Segura:

✅ Mínimo 8 caracteres
✅ Pelo menos uma letra maiúscula (A-Z)
✅ Pelo menos uma letra minúscula (a-z)
✅ Pelo menos um número (0-9)
✅ Pelo menos um caractere especial (!@#$%&*)

#### Exemplo de Senha Forte:

```
Senha123!@#
MinhaSenha2025$
C@dastro#Seguro99
```

#### Botões:

- **👁️ Mostrar/Ocultar Senha:** Ícone de olho para visualizar a senha
- **"Concluir Cadastro":** Finaliza o cadastro e envia dados ao servidor
- **"Voltar":** Retorna para etapa de endereço

### 5.5 Processo de Finalização

Após clicar em "**Concluir Cadastro**":

1. **Validação Final:**
   - Sistema verifica todos os dados
   - Valida se email já está cadastrado
   - Valida se CPF já está cadastrado (se informado)

2. **Criação da Conta:**
   - Senha é criptografada (bcrypt)
   - Dados são salvos no banco de dados
   - Token de autenticação é gerado

3. **Mensagens de Sucesso:**
   - Dialog de confirmação aparece
   - "Cadastro realizado com sucesso! 🎉"
   - Botão "Continuar"

4. **Redirecionamento:**
   - Você é automaticamente logado
   - **Redirecionado para verificação de email**

### 5.6 Tratamento de Erros

#### Erros Comuns:

**Email já cadastrado:**
```
"Este email já está cadastrado. Faça login ou use outro email."
```
**Ação:** Use a opção "Esqueci minha senha" ou cadastre com outro email.

**CPF já cadastrado:**
```
"Este CPF já está cadastrado no sistema."
```
**Ação:** Verifique se você já tem uma conta. Entre em contato com o suporte se necessário.

**Telefone já cadastrado:**
```
"Este telefone já está cadastrado."
```
**Ação:** Verifique seus dados ou entre em contato com o suporte.

**Erro de conexão:**
```
"Erro de conexão. Verifique sua internet e tente novamente."
```
**Ação:** Verifique sua conexão e tente novamente.

---

## 6. Login no Sistema

### 6.1 Tela de Login

![Tela de Login](images/login_page.png)

#### Opções de Login:

**A) Login com Email e Senha**

1. Digite seu **email** cadastrado
2. Digite sua **senha**
3. *(Opcional)* Marque "**Lembrar-me**" para manter login
4. Toque em "**Entrar**"

**B) Login com Google**

1. Toque no botão "**Entrar com Google**"
2. Selecione sua conta Google
3. Autorize o acesso
4. Login automático

### 6.2 Campos do Formulário

1. **Email**
   - Email usado no cadastro
   - Formato: nome@dominio.com
   - Não diferencia maiúsculas/minúsculas

2. **Senha**
   - Senha cadastrada
   - **Sensível a maiúsculas/minúsculas**
   - Mínimo 8 caracteres

3. **Lembrar-me** (Checkbox)
   - ✅ Marcado: Mantém login por 30 dias
   - ❌ Desmarcado: Login válido apenas na sessão atual

### 6.3 Links Úteis

- **"Esqueci minha senha":** Recuperação de senha por email
- **"Cadastrar":** Cria nova conta

### 6.4 Processo de Login

1. **Validação de Credenciais:**
   - Sistema verifica email no banco de dados
   - Compara senha criptografada

2. **Autenticação:**
   - Token JWT é gerado (válido por 7 dias)
   - Refresh token é gerado (válido por 30 dias)

3. **Redirecionamento:**
   - **Se email não verificado:** Tela de verificação de email
   - **Se email verificado:** Dashboard/Home do usuário

### 6.5 Erros de Login

**Email não encontrado:**
```
"Email não cadastrado. Verifique ou cadastre-se."
```

**Senha incorreta:**
```
"Email ou senha incorretos."
```
**Nota:** Por segurança, não informamos especificamente qual campo está errado.

**Conta bloqueada:**
```
"Sua conta foi temporariamente bloqueada. Entre em contato com o suporte."
```

**Muitas tentativas:**
```
"Muitas tentativas de login. Aguarde 15 minutos ou redefina sua senha."
```

---

## 7. Verificação de Email

### 7.1 Por que Verificar?

A verificação de email é **obrigatória** para:
- ✅ Confirmar que o email é válido e pertence a você
- ✅ Aumentar a segurança da sua conta
- ✅ Permitir recuperação de senha
- ✅ Receber notificações importantes

### 7.2 Tela de Verificação

![Verificação de Email](images/email_verification.png)

#### Elementos da Tela:

1. **Ícone de Email:** Indicador visual
2. **Título:** "Verifique seu Email"
3. **Descrição:** Informa que código foi enviado
4. **Email Destacado:** Mostra para qual email o código foi enviado
5. **Campos de Código:** 6 campos para código de 6 dígitos
6. **Botão Verificar:** Confirma o código
7. **Link Reenviar:** Envia novo código (com cooldown de 60s)
8. **Aviso de Expiração:** Código expira em 15 minutos

### 7.3 Como Verificar

**Passo 1: Receber o Código**
1. Abra seu email (Gmail, Outlook, Yahoo, etc.)
2. Procure email de "Sistema de Cadastro de Benefícios"
3. **Assunto:** "Código de Verificação - Cadastro de Benefícios"
4. O código tem **6 dígitos** (ex: 123456)

**Passo 2: Digitar o Código**
1. Digite cada dígito em um campo
2. O foco avança automaticamente
3. Ao digitar o 6º dígito, a verificação inicia automaticamente

**Passo 3: Confirmação**
1. Sistema valida o código
2. **Se correto:**
   - ✅ Dialog de sucesso aparece
   - "Email Verificado! 🎉"
   - Redirecionamento automático para dashboard
3. **Se incorreto:**
   - ❌ Mensagem de erro
   - Campos são limpos
   - Tente novamente

### 7.4 Email de Verificação

#### Aparência do Email:

```
┌─────────────────────────────────────────┐
│  📧 Sistema de Cadastro de Benefícios   │
├─────────────────────────────────────────┤
│                                         │
│  Olá, João Silva!                       │
│                                         │
│  Recebemos uma solicitação para         │
│  verificar seu endereço de email.       │
│                                         │
│  Use o código abaixo para completar     │
│  a verificação:                         │
│                                         │
│  ┌─────────────────────────────────┐   │
│  │                                 │   │
│  │        1 2 3 4 5 6              │   │
│  │                                 │   │
│  └─────────────────────────────────┘   │
│                                         │
│  ⏱️ Este código expira em 15 minutos   │
│                                         │
│  Se você não solicitou este código,     │
│  ignore este email.                     │
│                                         │
├─────────────────────────────────────────┤
│  © 2025 Sistema de Cadastro             │
└─────────────────────────────────────────┘
```

### 7.5 Reenviar Código

**Quando usar:**
- Não recebeu o email (aguarde 2-3 minutos primeiro)
- Código expirou (após 15 minutos)
- Email foi para spam/lixo eletrônico

**Como reenviar:**
1. Na tela de verificação, localize "Não recebeu o código?"
2. Clique em "**Reenviar**"
3. **Aguarde 60 segundos** antes de poder reenviar novamente
4. Novo código é enviado, invalidando o anterior

### 7.6 Problemas Comuns

**Não recebi o email:**
1. ✅ Verifique pasta de **Spam/Lixo Eletrônico**
2. ✅ Aguarde até 5 minutos (pode haver atraso)
3. ✅ Verifique se digitou email correto
4. ✅ Tente reenviar código

**Código não funciona:**
1. ✅ Verifique se digitou corretamente (6 dígitos)
2. ✅ Verifique se código não expirou (15 min)
3. ✅ Solicite novo código
4. ✅ Use o código mais recente

**Erro "Código Expirado":**
- Códigos expiram em **15 minutos**
- Solicite novo código
- Digite o novo código imediatamente

**Erro "Código já usado":**
- Cada código só pode ser usado uma vez
- Solicite novo código se necessário

---

## 8. Perfil do Usuário

### 8.1 Visualizar Perfil

Após login bem-sucedido e email verificado, você pode acessar seu perfil.

#### Informações Exibidas:

**Dados Pessoais:**
- Nome completo
- Email (com status de verificação ✅)
- Telefone (com status de verificação ⏳)
- CPF (parcialmente oculto: ***.***.789-09)
- Data de nascimento

**Endereço:**
- CEP
- Logradouro, número, complemento
- Bairro, cidade, estado

**Segurança:**
- Data de criação da conta
- Último login
- Status de verificações

### 8.2 Editar Perfil

*Funcionalidade em desenvolvimento*

### 8.3 Status de Verificação

**Email Verificado ✅**
- Ícone verde com check
- Você pode receber notificações

**Email Não Verificado ⏳**
- Ícone laranja com relógio
- Link "Verificar agora"

**Telefone Verificado ✅**
- Ícone verde com check
- Pode receber SMS

**Telefone Não Verificado ⏳**
- Ícone laranja com relógio
- Link "Verificar agora"

---

## 9. Recuperação de Senha

### 9.1 Quando Usar

Use a recuperação de senha quando:
- Esqueceu sua senha
- Quer alterar senha por segurança
- Suspeita que sua senha foi comprometida

### 9.2 Processo de Recuperação

**Passo 1: Solicitar Recuperação**
1. Na tela de login, clique em "**Esqueci minha senha**"
2. Digite seu **email cadastrado**
3. Clique em "**Enviar**"
4. Mensagem de confirmação aparece

**Passo 2: Verificar Email**
1. Abra seu email
2. Procure por "Redefinição de Senha"
3. Clique no link ou copie o código

**Passo 3: Redefinir Senha**
1. Você será redirecionado para tela de nova senha
2. Digite nova senha (mínimo 8 caracteres)
3. Confirme a nova senha
4. Clique em "**Redefinir Senha**"

**Passo 4: Confirmação**
1. Senha alterada com sucesso
2. Faça login com a nova senha

### 9.3 Email de Recuperação

```
┌─────────────────────────────────────────┐
│  🔐 Sistema de Cadastro de Benefícios   │
├─────────────────────────────────────────┤
│                                         │
│  Olá, João Silva!                       │
│                                         │
│  Recebemos uma solicitação para         │
│  redefinir sua senha.                   │
│                                         │
│  Clique no botão abaixo para            │
│  redefinir sua senha:                   │
│                                         │
│  ┌─────────────────────────────────┐   │
│  │    [ Redefinir Senha ]          │   │
│  └─────────────────────────────────┘   │
│                                         │
│  ⏱️ Este link expira em 1 hora         │
│                                         │
│  Se você não solicitou redefinição,     │
│  ignore este email. Sua senha           │
│  permanecerá inalterada.                │
│                                         │
├─────────────────────────────────────────┤
│  © 2025 Sistema de Cadastro             │
└─────────────────────────────────────────┘
```

### 9.4 Segurança

- 🔒 Link expira em **1 hora**
- 🔒 Cada link só pode ser usado **uma vez**
- 🔒 Senha atual continua válida até redefinição
- 🔒 Você receberá notificação ao alterar senha

---

## 10. Regras de Negócio

### 10.1 Validações de Dados

#### Nome Completo
- ✅ Mínimo: 3 caracteres
- ✅ Máximo: 100 caracteres
- ✅ Apenas letras e espaços
- ✅ Não pode conter números ou caracteres especiais

#### Email
- ✅ Formato válido: nome@dominio.com
- ✅ Deve ter @ e domínio válido
- ✅ Máximo: 100 caracteres
- ✅ Único no sistema (não pode duplicar)

#### Telefone
- ✅ Formato: (XX) XXXXX-XXXX ou (XX) XXXX-XXXX
- ✅ DDD válido (11-99)
- ✅ Celular: 11 dígitos (com 9 no início)
- ✅ Fixo: 10 dígitos
- ✅ Apenas números (formatação automática)

#### CPF
- ✅ Formato: XXX.XXX.XXX-XX
- ✅ Deve ter 11 dígitos
- ✅ Validação de dígitos verificadores
- ✅ Não aceita CPFs inválidos conhecidos:
  - 000.000.000-00
  - 111.111.111-11
  - 222.222.222-22
  - etc.
- ✅ Único no sistema (opcional, mas se informado, não pode duplicar)

#### Data de Nascimento
- ✅ Formato: DD/MM/AAAA
- ✅ Idade mínima: 18 anos
- ✅ Idade máxima: 120 anos
- ✅ Não aceita datas futuras
- ✅ Valida dias por mês (28, 29, 30 ou 31)
- ✅ Considera anos bissextos:
  - Fevereiro tem 29 dias em anos bissextos
  - Anos bissextos: divisíveis por 4, exceto seculares (a menos que divisíveis por 400)

#### CEP
- ✅ Formato: XXXXX-XXX
- ✅ Deve ter 8 dígitos
- ✅ Busca automática no ViaCEP

#### Senha
- ✅ Mínimo: 8 caracteres
- ✅ Máximo: 100 caracteres
- ✅ Recomendado:
  - Pelo menos 1 letra maiúscula
  - Pelo menos 1 letra minúscula
  - Pelo menos 1 número
  - Pelo menos 1 caractere especial (!@#$%&*)

### 10.2 Autenticação e Segurança

#### Tokens de Autenticação
- **Access Token:** Válido por 7 dias
- **Refresh Token:** Válido por 30 dias
- Tokens são criptografados (JWT)
- Renovação automática com refresh token

#### Sessões
- **Com "Lembrar-me":** 30 dias
- **Sem "Lembrar-me":** Até fechar navegador
- Logout automático após expiração
- Pode fazer logout manual a qualquer momento

#### Verificação de Email
- **Código:** 6 dígitos aleatórios
- **Validade:** 15 minutos
- **Uso:** Único (código usado é invalidado)
- **Rate Limiting:** 1 código por minuto por usuário

#### Senha
- Armazenada com **bcrypt** (hash + salt)
- Nunca é armazenada em texto puro
- **10 rounds** de hashing (alta segurança)
- Impossível recuperar senha original

### 10.3 Cadastro via Google OAuth

Quando você usa "Continuar com Google":

1. **Dados Obtidos:**
   - Nome completo
   - Email
   - Foto de perfil (opcional)

2. **Status Inicial:**
   - Email **automaticamente verificado** ✅
   - Perfil **incompleto** (precisa completar)

3. **Dados Necessários:**
   - CPF
   - Telefone
   - Endereço completo
   - Data de nascimento (opcional)

4. **Fluxo:**
   - Login com Google
   - Redireciona para "Completar Perfil"
   - Preenche dados faltantes
   - Salva e acessa dashboard

### 10.4 Limites e Restrições

#### Rate Limiting (Prevenção de Abuso)

**Login:**
- Máximo: 5 tentativas a cada 15 minutos
- Bloqueio temporário após exceder

**Verificação de Email:**
- Máximo: 1 código por minuto
- Máximo: 5 códigos por hora

**Cadastro:**
- Máximo: 3 cadastros por IP por dia

**Recuperação de Senha:**
- Máximo: 3 solicitações por hora

#### Armazenamento

**Dados Pessoais:**
- Mantidos indefinidamente (enquanto conta ativa)
- Podem ser excluídos mediante solicitação (LGPD)

**Logs:**
- Mantidos por 90 dias
- Depois são arquivados

**Tokens:**
- Access Token: 7 dias
- Refresh Token: 30 dias
- Código de verificação: 15 minutos
- Link de recuperação: 1 hora

---

## 11. Perguntas Frequentes (FAQ)

### 11.1 Cadastro

**P: Preciso ter CPF para me cadastrar?**
R: Não, o CPF é opcional. Mas recomendamos informá-lo para maior segurança e validação.

**P: Posso usar o mesmo email para múltiplas contas?**
R: Não. Cada email só pode ser usado em uma conta.

**P: Como sei se minha senha é forte?**
R: O sistema mostra um indicador de força ao digitar. Busque pelo menos "Média" (3/5).

**P: Posso me cadastrar com email temporário/descartável?**
R: Tecnicamente sim, mas não é recomendado. Você precisa do email para recuperação de senha e notificações.

### 11.2 Login

**P: Esqueci qual email usei no cadastro.**
R: Entre em contato com o suporte fornecendo CPF ou telefone cadastrado.

**P: Posso usar login social se cadastrei com email?**
R: Sim, se usar o mesmo email do cadastro, as contas serão vinculadas automaticamente.

**P: Por quanto tempo fico logado?**
R: Com "Lembrar-me" marcado: 30 dias. Sem marcar: até fechar o navegador.

### 11.3 Verificação

**P: É obrigatório verificar o email?**
R: Sim, para ter acesso completo ao sistema e aos benefícios.

**P: Quanto tempo leva para receber o código?**
R: Geralmente instantâneo, mas pode levar até 5 minutos.

**P: O código de verificação expira?**
R: Sim, após 15 minutos. Solicite novo código se necessário.

**P: Posso usar código antigo?**
R: Não. Ao solicitar novo código, os anteriores são invalidados.

### 11.4 Segurança

**P: Meus dados estão seguros?**
R: Sim. Usamos criptografia de ponta e seguimos normas da LGPD.

**P: O que fazer se suspeitar de acesso não autorizado?**
R: Troque sua senha imediatamente e entre em contato com o suporte.

**P: Como excluir minha conta?**
R: Entre em contato com o suporte. Seus dados serão excluídos conforme LGPD.

### 11.5 Técnico

**P: O aplicativo funciona offline?**
R: Não. É necessário conexão com internet para todas as operações.

**P: Em quais plataformas está disponível?**
R: Android, iOS e Web.

**P: O aplicativo consome muitos dados móveis?**
R: Não. Consome menos de 10 MB por sessão típica.

---

## 12. Solução de Problemas

### 12.1 Problemas de Cadastro

#### Erro: "Email já cadastrado"

**Causa:** Você já tem uma conta com este email.

**Soluções:**
1. Tente fazer login
2. Use "Esqueci minha senha" se não lembra
3. Use outro email
4. Contate suporte se necessário

---

#### Erro: "CPF inválido"

**Causa:** CPF digitado não é válido.

**Soluções:**
1. Verifique se digitou corretamente
2. CPF deve ter 11 dígitos
3. Use site da Receita Federal para validar seu CPF
4. Deixe em branco se não tiver certeza

---

#### Erro: "Data de nascimento inválida"

**Causa:** Data impossível ou idade menor que 18 anos.

**Soluções:**
1. Verifique formato: DD/MM/AAAA
2. Verifique se dia/mês são válidos
3. Você deve ter pelo menos 18 anos
4. Não use datas futuras

---

### 12.2 Problemas de Login

#### Erro: "Email ou senha incorretos"

**Soluções:**
1. Verifique se digitou corretamente
2. Lembre-se: senha diferencia maiúsculas/minúsculas
3. Tente "Esqueci minha senha"
4. Verifique se não usou login social (Google) no cadastro

---

#### Erro: "Muitas tentativas. Tente novamente em 15 minutos"

**Causa:** Você tentou logar 5 vezes seguidas com senha errada.

**Soluções:**
1. Aguarde 15 minutos
2. Use "Esqueci minha senha" (não tem limite)
3. Verifique suas credenciais enquanto aguarda

---

### 12.3 Problemas de Verificação

#### Não recebo email de verificação

**Soluções:**
1. ✅ Aguarde 5 minutos
2. ✅ Verifique pasta de **Spam/Lixo Eletrônico**
3. ✅ Verifique se email está correto no perfil
4. ✅ Clique em "Reenviar código"
5. ✅ Tente outro email (Gmail, Outlook)
6. ✅ Entre em contato com suporte

---

#### Erro: "Código inválido"

**Causas e Soluções:**
1. **Código errado:** Verifique email novamente
2. **Código expirado:** Solicite novo (expira em 15 min)
3. **Código antigo:** Use sempre o mais recente
4. **Espaços extras:** Digite apenas os 6 dígitos

---

### 12.4 Problemas de Conexão

#### Erro: "Sem conexão com a internet"

**Soluções:**
1. ✅ Verifique Wi-Fi ou dados móveis
2. ✅ Teste acessando outro site
3. ✅ Reinicie o roteador
4. ✅ Tente trocar entre Wi-Fi e dados móveis
5. ✅ Aguarde alguns minutos e tente novamente

---

#### Erro: "Servidor não respondeu"

**Causas e Soluções:**
1. **Manutenção:** Aguarde alguns minutos
2. **Alta demanda:** Tente em outro horário
3. **Problema no servidor:** Reportado automaticamente

---

### 12.5 Problemas de Performance

#### App lento ou travando

**Soluções:**
1. ✅ Feche outros aplicativos
2. ✅ Limpe cache do app:
   - Android: Configurações > Apps > Cadastro Benefícios > Limpar cache
   - iOS: Desinstale e reinstale
3. ✅ Atualize o app na loja
4. ✅ Reinicie o dispositivo
5. ✅ Verifique espaço de armazenamento (mín. 500MB livre)

---

#### Tela branca ao abrir app

**Soluções:**
1. ✅ Force fechar o app
2. ✅ Limpe cache
3. ✅ Desinstale e reinstale
4. ✅ Verifique se sistema operacional está atualizado

---

## 13. Suporte Técnico

### 13.1 Canais de Atendimento

#### Email
📧 **suporte@cadastro.beneficios.gov.br**
- Tempo de resposta: 24-48 horas úteis
- Inclua prints de tela se possível
- Informe CPF ou email cadastrado

#### WhatsApp
📱 **+55 (11) 9999-9999**
- Horário: Segunda a Sexta, 8h às 18h
- Resposta em até 2 horas
- Envie mensagens de texto (áudio pode demorar)

#### Chat Online
💬 **Disponível no site e app**
- Horário: Segunda a Sexta, 8h às 20h
- Resposta imediata com bot
- Transfere para humano se necessário

#### Central Telefônica
☎️ **0800-123-4567**
- Ligação gratuita
- Horário: Segunda a Sexta, 8h às 18h
- Menu de opções:
  1. Problemas no cadastro
  2. Problemas no login
  3. Recuperação de senha
  4. Verificação de conta
  5. Outros assuntos

### 13.2 Informações Úteis para o Suporte

Ao entrar em contato, tenha em mãos:

✅ **Email cadastrado** (ou CPF)
✅ **Descrição do problema** (seja específico)
✅ **Mensagem de erro** (copie ou tire print)
✅ **Passos para reproduzir** (o que estava fazendo)
✅ **Dispositivo e sistema** (ex: iPhone 12, iOS 15)
✅ **Versão do app** (veja em Configurações > Sobre)

### 13.3 Base de Conhecimento

Acesse artigos detalhados em:
🌐 **https://suporte.cadastro.beneficios.gov.br**

Categorias disponíveis:
- 📖 Primeiros Passos
- 🔐 Segurança e Privacidade
- ❓ Perguntas Frequentes
- 🎥 Vídeos Tutoriais
- 📝 Manuais e Guias

### 13.4 Reportar Bugs

Encontrou um problema técnico?

**GitHub Issues:**
🐛 **github.com/cadastro-beneficios/issues**

**O que incluir:**
1. Descrição clara do bug
2. Passos para reproduzir
3. Comportamento esperado vs. atual
4. Screenshots ou vídeo
5. Informações técnicas (dispositivo, SO, versão)

### 13.5 Sugestões e Feedback

Sua opinião é importante!

**Formulário de Feedback:**
📋 **https://feedback.cadastro.beneficios.gov.br**

**Email de Sugestões:**
💡 **sugestoes@cadastro.beneficios.gov.br**

---

## Apêndices

### Apêndice A: Glossário

**API:** Interface de Programação de Aplicações - permite comunicação entre sistemas

**Bcrypt:** Algoritmo de criptografia para senhas

**CEP:** Código de Endereçamento Postal

**CPF:** Cadastro de Pessoa Física

**JWT:** JSON Web Token - formato de token de autenticação

**LGPD:** Lei Geral de Proteção de Dados

**OAuth:** Protocolo de autorização (usado no login com Google)

**Rate Limiting:** Limitação de taxa - previne abuso do sistema

**Refresh Token:** Token usado para renovar autenticação

**SMS:** Short Message Service - mensagem de texto

**ViaCEP:** API pública dos Correios para consulta de CEP

---

### Apêndice B: Atalhos de Teclado (Web)

| Atalho | Ação |
|--------|------|
| `Tab` | Avançar para próximo campo |
| `Shift + Tab` | Voltar para campo anterior |
| `Enter` | Enviar formulário |
| `Esc` | Fechar modals/dialogs |
| `Ctrl + K` | Abrir busca (se disponível) |

---

### Apêndice C: Códigos de Erro

| Código | Significado | Ação |
|--------|-------------|------|
| 400 | Requisição inválida | Verifique dados |
| 401 | Não autorizado | Faça login novamente |
| 403 | Proibido | Sem permissão para ação |
| 404 | Não encontrado | Recurso não existe |
| 409 | Conflito | Dado duplicado (email/CPF) |
| 422 | Validação falhou | Verifique campos |
| 429 | Muitas requisições | Aguarde alguns minutos |
| 500 | Erro no servidor | Tente novamente mais tarde |
| 503 | Serviço indisponível | Manutenção em andamento |

---

### Apêndice D: Atualizações de Versão

#### Versão 1.0.0 (18/12/2025)
✨ **Lançamento Inicial**
- Cadastro completo (3 etapas)
- Login com email/senha e Google
- Verificação de email
- Validação de CPF, telefone e CEP
- Busca automática de endereço
- Interface responsiva
- Suporte multi-plataforma

#### Próximas Versões (Roadmap)

**Versão 1.1.0 (Prevista: Jan/2026)**
- Verificação de telefone (SMS)
- Edição de perfil
- Upload de foto de perfil
- Notificações push

**Versão 1.2.0 (Prevista: Fev/2026)**
- Dashboard de benefícios
- Solicitação de benefícios
- Histórico de solicitações
- Documentação digital

**Versão 2.0.0 (Prevista: Mar/2026)**
- Modo offline
- Biometria (Face ID/Touch ID)
- Carteira digital
- Integração com gov.br

---

## Informações Legais

### Termos de Uso

Ao usar o Sistema de Cadastro de Benefícios, você concorda com nossos [Termos de Uso](https://cadastro.beneficios.gov.br/termos).

### Política de Privacidade

Leia nossa [Política de Privacidade](https://cadastro.beneficios.gov.br/privacidade) para entender como tratamos seus dados.

### Conformidade LGPD

Este sistema está em conformidade com a Lei Geral de Proteção de Dados (Lei nº 13.709/2018).

**Seus Direitos:**
- ✅ Acesso aos seus dados
- ✅ Correção de dados incorretos
- ✅ Exclusão de dados (direito ao esquecimento)
- ✅ Portabilidade de dados
- ✅ Revogação de consentimento

**Para exercer seus direitos:**
📧 lgpd@cadastro.beneficios.gov.br

---

## Notas de Rodapé

¹ Tempo de resposta do suporte pode variar em períodos de alta demanda.

² Funcionalidades podem variar entre versões Android, iOS e Web.

³ Conexão com internet é obrigatória para todas as operações.

⁴ Screenshots são ilustrativas e podem diferir da versão atual.

---

## Créditos

**Desenvolvido por:** Equipe de Tecnologia - Sistema de Cadastro de Benefícios

**Tecnologias Utilizadas:**
- Frontend: Flutter 3.x
- Backend: Node.js + Express
- Banco de Dados: PostgreSQL
- Email: Nodemailer
- Autenticação: JWT + Google OAuth
- Infraestrutura: AWS

**Colaboradores:**
- Equipe de Desenvolvimento
- Equipe de Design UX/UI
- Equipe de Suporte
- Equipe de Documentação

---

## Feedback sobre este Manual

Este manual foi útil? Deixe seu feedback:
📧 **documentacao@cadastro.beneficios.gov.br**

Encontrou algum erro ou informação desatualizada? Reporte:
🐛 **manual-feedback@cadastro.beneficios.gov.br**

---

<div align="center">

**Manual do Usuário - Sistema de Cadastro de Benefícios**
**Versão 1.0 | Dezembro 2025**

---

*Este documento é propriedade do Sistema de Cadastro de Benefícios.*
*Todos os direitos reservados © 2025*

</div>
