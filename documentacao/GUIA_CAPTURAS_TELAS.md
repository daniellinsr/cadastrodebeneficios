# Guia de Captura de Telas para o Manual

## 🎯 Objetivo

Capturar screenshots de todas as telas do sistema para incluir no Manual do Usuário v1.0.

---

## 📋 Lista de Telas a Capturar

### 1. Landing Page (Tela Inicial)
**Arquivo:** `landing_page.png`
**Dimensões:** 1920x1080 (desktop) ou 390x844 (mobile)
**Como acessar:**
1. Abra http://localhost:8080
2. Capture a tela inicial completa
3. Inclua cabeçalho, seção hero, cards de benefícios

**Elementos importantes:**
- ✅ Logo
- ✅ Botões "Entrar" e "Cadastrar"
- ✅ Título principal
- ✅ Cards de benefícios (4)

---

### 2. Tela de Login
**Arquivo:** `login_page.png`
**Como acessar:**
1. Na landing page, clique em "Entrar"
2. Capture tela de login

**Elementos importantes:**
- ✅ Campos Email e Senha
- ✅ Checkbox "Lembrar-me"
- ✅ Botão "Entrar"
- ✅ Botão "Entrar com Google"
- ✅ Link "Esqueci minha senha"
- ✅ Link "Cadastrar"

---

### 3. Cadastro - Introdução
**Arquivo:** `registration_intro.png`
**Como acessar:**
1. Na landing page, clique em "Cadastrar"
2. Você verá a tela de introdução ao cadastro

**Elementos importantes:**
- ✅ Indicador de progresso "Passo 1 de 3"
- ✅ Botão "Continuar com Google"
- ✅ Botão "Cadastrar com Email"
- ✅ Ilustração/ícone
- ✅ Texto explicativo

---

### 4. Cadastro - Identificação
**Arquivo:** `registration_identification.png`
**Como acessar:**
1. No cadastro, clique em "Cadastrar com Email"
2. Capture a tela de identificação

**Elementos importantes:**
- ✅ Indicador "Passo 2 de 3"
- ✅ 5 campos: Nome, Email, Telefone, CPF, Data de Nascimento
- ✅ Botões "Voltar" e "Próximo"
- ✅ Máscaras formatadas (telefone, CPF, data)

**Dados de exemplo para preencher:**
- Nome: João Silva
- Email: joao.silva@example.com
- Telefone: (11) 98765-4321
- CPF: 123.456.789-09
- Data: 15/06/1990

---

### 5. Cadastro - Endereço
**Arquivo:** `registration_address.png`
**Como acessar:**
1. Continue do passo anterior
2. Preencha todos os campos da identificação
3. Clique em "Próximo"

**Elementos importantes:**
- ✅ Indicador "Passo 3 de 3"
- ✅ 7 campos de endereço
- ✅ Botão de busca CEP (ícone de lupa)
- ✅ Campos preenchidos automaticamente

**Dados de exemplo:**
- CEP: 01310-100
- Aguarde busca automática preencher os campos
- Número: 123
- Complemento: Apto 45

---

### 6. Cadastro - Senha
**Arquivo:** `registration_password.png`
**Como acessar:**
1. Continue do passo anterior
2. Clique em "Próximo"

**Elementos importantes:**
- ✅ Campo "Senha"
- ✅ Campo "Confirmar Senha"
- ✅ Indicador de força da senha (barra colorida)
- ✅ Ícones de "mostrar/ocultar senha" (olho)
- ✅ Botão "Concluir Cadastro"

**Senha de exemplo:**
- Digite: MinhaSenha123!
- Mostra indicador "Forte"

---

### 7. Dialog de Sucesso no Cadastro
**Arquivo:** `registration_success_dialog.png`
**Como acessar:**
1. Complete o cadastro
2. Capture o dialog que aparece

**Elementos importantes:**
- ✅ Ícone de check verde
- ✅ Título "Cadastro realizado com sucesso! 🎉"
- ✅ Botão "Continuar"

---

### 8. Verificação de Email
**Arquivo:** `email_verification.png`
**Como acessar:**
1. Após cadastro, você será redirecionado
2. Capture a tela de verificação

**Elementos importantes:**
- ✅ Ícone de email
- ✅ Título "Verifique seu Email"
- ✅ Email destacado
- ✅ 6 campos para código
- ✅ Botão "Verificar"
- ✅ Link "Reenviar" (com contador)
- ✅ Aviso "Expira em 15 minutos"

**Para simular:**
- Digite código fictício: 123456
- Não clique em verificar (só para screenshot)

---

### 9. Dialog de Email Verificado
**Arquivo:** `email_verified_dialog.png`
**Como acessar:**
1. Use código real do email
2. Capture o dialog de sucesso

**Elementos importantes:**
- ✅ Ícone de check verde grande
- ✅ Título "Email Verificado!"
- ✅ Texto "Seu email foi verificado com sucesso"
- ✅ Botão "Continuar"

---

### 10. Tela de Perfil
**Arquivo:** `profile_page.png`
**Como acessar:**
1. Após login e verificação
2. Acesse menu > Perfil

**Elementos importantes:**
- ✅ Dados pessoais
- ✅ Status de verificação (email ✅, telefone ⏳)
- ✅ Endereço
- ✅ Botão "Editar"

---

### 11. Recuperação de Senha
**Arquivo:** `forgot_password.png`
**Como acessar:**
1. Na tela de login
2. Clique em "Esqueci minha senha"

**Elementos importantes:**
- ✅ Campo Email
- ✅ Botão "Enviar"
- ✅ Texto explicativo

---

### 12. Google OAuth - Seleção de Conta
**Arquivo:** `google_oauth.png`
**Como acessar:**
1. Clique em "Entrar com Google"
2. Capture a tela do Google

**Elementos importantes:**
- ✅ Logo do Google
- ✅ "Escolher uma conta"
- ✅ Lista de contas

---

## 🛠️ Ferramentas para Captura

### Windows
- **Ferramenta Recorte:** Win + Shift + S
- **Print Screen:** PrtScn (tela inteira)
- **Snipping Tool:** Busque no menu Iniciar

### Chrome DevTools (Para simular mobile)
1. Pressione F12
2. Clique no ícone de dispositivo (Ctrl+Shift+M)
3. Selecione "iPhone 12 Pro" ou "Pixel 5"
4. Capture com Win + Shift + S

---

## 📐 Dimensões Recomendadas

### Desktop
- **Largura:** 1920px ou 1366px
- **Altura:** Completa (scroll se necessário)
- **Formato:** PNG (melhor qualidade)

### Mobile
- **Largura:** 390px (iPhone) ou 412px (Android)
- **Altura:** 844px (iPhone) ou 915px (Android)
- **Formato:** PNG

---

## 🎨 Dicas de Qualidade

1. **Resolução:**
   - Use tela com boa resolução
   - Evite zoom (mantenha 100%)

2. **Sem informações pessoais:**
   - Use dados fictícios
   - Não mostre emails reais

3. **Consistência:**
   - Use mesmo usuário em todas as telas
   - Use mesmos dados de exemplo

4. **Fundo:**
   - Capture sem distrações
   - Fundo limpo

5. **Iluminação:**
   - Tela com bom contraste
   - Sem reflexos

---

## 📁 Organização dos Arquivos

Salve todos os arquivos em:
```
cadastrodebeneficios/
└── documentacao/
    └── images/
        ├── landing_page.png
        ├── login_page.png
        ├── registration_intro.png
        ├── registration_identification.png
        ├── registration_address.png
        ├── registration_password.png
        ├── registration_success_dialog.png
        ├── email_verification.png
        ├── email_verified_dialog.png
        ├── profile_page.png
        ├── forgot_password.png
        └── google_oauth.png
```

---

## ✅ Checklist de Capturas

Após capturar cada tela, marque:

- [ ] 1. Landing Page
- [ ] 2. Tela de Login
- [ ] 3. Cadastro - Introdução
- [ ] 4. Cadastro - Identificação
- [ ] 5. Cadastro - Endereço
- [ ] 6. Cadastro - Senha
- [ ] 7. Dialog de Sucesso no Cadastro
- [ ] 8. Verificação de Email
- [ ] 9. Dialog de Email Verificado
- [ ] 10. Tela de Perfil
- [ ] 11. Recuperação de Senha
- [ ] 12. Google OAuth

---

## 🔄 Após Capturar

1. **Verifique qualidade:**
   - Todas as imagens estão nítidas?
   - Elementos importantes visíveis?
   - Sem informações sensíveis?

2. **Otimize (opcional):**
   - Use TinyPNG para reduzir tamanho
   - Mantenha qualidade

3. **Atualize o manual:**
   - As imagens já estão referenciadas
   - Só precisa ter os arquivos no lugar

---

## 🚀 Script Rápido de Verificação

Execute no terminal para verificar se todas as imagens existem:

```bash
cd documentacao/images

# Lista de arquivos esperados
$images = @(
    "landing_page.png",
    "login_page.png",
    "registration_intro.png",
    "registration_identification.png",
    "registration_address.png",
    "registration_password.png",
    "registration_success_dialog.png",
    "email_verification.png",
    "email_verified_dialog.png",
    "profile_page.png",
    "forgot_password.png",
    "google_oauth.png"
)

# Verifica cada imagem
foreach ($img in $images) {
    if (Test-Path $img) {
        Write-Host "✅ $img" -ForegroundColor Green
    } else {
        Write-Host "❌ $img (FALTANDO)" -ForegroundColor Red
    }
}
```

---

## 📝 Notas Importantes

1. **Não precisa capturar todas de uma vez**
   - Capture em sessões
   - Salve progressivamente

2. **Use dados consistentes**
   - Mesmo usuário: João Silva
   - Mesmo email: joao.silva@example.com
   - Mesmo CPF: 123.456.789-09

3. **Prioridade**
   - Capturas mais importantes:
     1. Landing Page
     2. Login
     3. Cadastro (3 telas)
     4. Verificação de Email

---

## 🆘 Ajuda

Se tiver dificuldades:
1. Verifique se app está rodando (http://localhost:8080)
2. Use DevTools (F12) para simular mobile
3. Tire print de área específica (Win+Shift+S)

---

**Boas capturas! 📸**
