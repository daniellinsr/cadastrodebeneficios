# Guia: Configurar OAuth Consent Screen e Test Users

Este guia mostra passo a passo como configurar a tela de consentimento OAuth e adicionar usuários de teste no Google Cloud Console.

---

## 📋 Pré-requisitos

- Conta Google ativa
- Acesso ao [Google Cloud Console](https://console.cloud.google.com/)
- Project ID: **403775802042**

---

## 🎯 Passo 1: Acessar OAuth Consent Screen

1. Acesse: https://console.cloud.google.com/apis/credentials/consent?project=403775802042

   Ou manualmente:
   - Vá para [Google Cloud Console](https://console.cloud.google.com/)
   - Selecione o projeto (ID: 403775802042)
   - No menu lateral, clique em **APIs & Services** > **OAuth consent screen**

2. Você verá a tela de configuração do OAuth Consent Screen

---

## 🔧 Passo 2: Escolher Tipo de Usuário (User Type)

Você verá duas opções:

### Opção 1: Internal (Recomendado para empresas com Google Workspace)
- **Quando usar:** Se você tem um domínio Google Workspace (ex: @suaempresa.com)
- **Vantagem:** Não precisa de verificação do Google
- **Limitação:** Apenas usuários do seu domínio podem fazer login

### Opção 2: External (Recomendado para você)
- **Quando usar:** Para testes pessoais ou aplicativos públicos
- **Vantagem:** Qualquer usuário Google pode fazer login
- **Limitação:** Precisa adicionar test users durante desenvolvimento

**👉 Selecione: EXTERNAL**

Clique em **CREATE** (ou **CRIAR**)

---

## 📝 Passo 3: App Information (Página 1/4)

### 3.1 App Information

Preencha os seguintes campos:

| Campo | Valor | Obrigatório |
|-------|-------|-------------|
| **App name** | `Sistema de Cartão de Benefícios` | ✅ Sim |
| **User support email** | `daniellinsr@gmail.com` | ✅ Sim |
| **App logo** | (Opcional) Deixe em branco por enquanto | ❌ Não |

### 3.2 App Domain (Opcional para desenvolvimento)

Você pode deixar esses campos em branco durante desenvolvimento:

- **Application home page**: (deixe vazio)
- **Application privacy policy link**: (deixe vazio)
- **Application terms of service link**: (deixe vazio)

### 3.3 Authorized Domains (Opcional)

Se você tiver um domínio, adicione aqui. Para desenvolvimento local, pode deixar vazio.

### 3.4 Developer Contact Information

| Campo | Valor | Obrigatório |
|-------|-------|-------------|
| **Email addresses** | `daniellinsr@gmail.com` | ✅ Sim |

**👉 Clique em: SAVE AND CONTINUE**

---

## 🔐 Passo 4: Scopes (Página 2/4)

Esta página define quais informações do usuário o app poderá acessar.

### 4.1 Adicionar Scopes

1. Clique no botão **ADD OR REMOVE SCOPES**

2. Na janela que abrir, procure e marque os seguintes scopes:

   | Scope | API | Descrição |
   |-------|-----|-----------|
   | `.../auth/userinfo.email` | Google OAuth2 API | Ver o endereço de e-mail principal |
   | `.../auth/userinfo.profile` | Google OAuth2 API | Ver informações pessoais básicas |

   **Como encontrar:**
   - Role a lista ou use a busca
   - Digite "email" para encontrar `.../auth/userinfo.email`
   - Digite "profile" para encontrar `.../auth/userinfo.profile`

3. Certifique-se de que ambos estão marcados:
   ```
   ✅ .../auth/userinfo.email
   ✅ .../auth/userinfo.profile
   ```

4. Clique em **UPDATE** (ou **ATUALIZAR**)

5. Verifique que a tabela mostra os 2 scopes selecionados

**👉 Clique em: SAVE AND CONTINUE**

---

## 👥 Passo 5: Test Users (Página 3/4) - IMPORTANTE!

Esta é a parte mais importante para você poder testar o app!

### 5.1 Por que adicionar Test Users?

Quando o app está em modo **External** e não verificado pelo Google, apenas usuários adicionados como "Test Users" podem fazer login durante desenvolvimento.

### 5.2 Adicionar Test Users

1. Clique no botão **+ ADD USERS**

2. Na caixa de texto que aparecer, adicione os e-mails dos usuários que poderão testar:

   ```
   daniellinsr@gmail.com
   ```

   **Dica:** Você pode adicionar múltiplos e-mails separados por vírgula ou Enter:
   ```
   daniellinsr@gmail.com
   seuemail2@gmail.com
   amigo@gmail.com
   ```

3. Clique em **ADD** (ou **ADICIONAR**)

4. Verifique que os usuários aparecem na lista:

   ```
   Test users:
   ✅ daniellinsr@gmail.com
   ```

### 5.3 Adicionar/Remover Test Users depois

Você pode adicionar ou remover test users a qualquer momento:
- Volte na página OAuth consent screen
- Role até a seção "Test users"
- Clique em **+ ADD USERS** para adicionar mais
- Clique no ícone de lixeira para remover

**👉 Clique em: SAVE AND CONTINUE**

---

## 📊 Passo 6: Summary (Página 4/4)

Esta página mostra um resumo de todas as configurações.

### 6.1 Revisar Configurações

Verifique se tudo está correto:

```
App Information:
✅ App name: Sistema de Cartão de Benefícios
✅ User support email: daniellinsr@gmail.com
✅ Developer contact: daniellinsr@gmail.com

Scopes:
✅ .../auth/userinfo.email
✅ .../auth/userinfo.profile

Test users:
✅ daniellinsr@gmail.com
```

**👉 Clique em: BACK TO DASHBOARD** (ou **VOLTAR AO PAINEL**)

---

## ✅ Passo 7: Verificar Status

Após configurar, você verá a página principal do OAuth consent screen com estas informações:

```
Publishing status: 🟡 Testing
User type: External
```

### O que significa "Testing"?

- ✅ Apenas test users podem fazer login
- ✅ Perfeito para desenvolvimento
- ❌ Usuários não-testadores verão erro: "This app isn't verified"

### Como publicar para produção? (Futuro)

Quando estiver pronto para lançar o app:
1. Clique em **PUBLISH APP**
2. Google pode solicitar verificação se você usar scopes sensíveis
3. Para scopes básicos (email, profile), pode publicar direto

---

## 🎨 Personalização Opcional

### Adicionar Logo do App (Recomendado)

1. Volte em **OAuth consent screen**
2. Clique em **EDIT APP**
3. Em "App logo", faça upload de uma imagem:
   - Formato: PNG, JPG
   - Tamanho: 120x120 pixels (recomendado)
   - Máximo: 1MB

### Adicionar Links (Recomendado para produção)

Adicione links para:
- **Home page**: Site do seu app
- **Privacy Policy**: Política de privacidade
- **Terms of Service**: Termos de uso

---

## 🧪 Testando a Configuração

Após configurar tudo:

1. **No seu app Flutter**, execute:
   ```bash
   flutter run
   ```

2. **Clique em "Login com Google"**

3. **Você verá uma tela do Google:**
   - Se você for um test user: ✅ Login funcionará
   - Se você NÃO for um test user: ❌ Verá "This app isn't verified"

4. **Durante desenvolvimento, pode aparecer aviso:**
   ```
   Google hasn't verified this app
   ```

   Clique em:
   - **Advanced** (ou **Avançado**)
   - **Go to Sistema de Cartão de Benefícios (unsafe)** (ou **Ir para... (não seguro)**)

---

## 🔧 Troubleshooting

### Erro: "Access blocked: This app's request is invalid"

**Causa:** Scopes não configurados ou Client ID incorreto

**Solução:**
1. Verifique se os scopes estão adicionados
2. Verifique se criou as credenciais OAuth (Android/iOS/Web)
3. Aguarde 5-10 minutos para propagação

### Erro: "This app isn't verified"

**Causa:** Usuário não está na lista de test users

**Solução:**
1. Adicione o e-mail do usuário em Test Users
2. Ou clique em "Advanced" > "Go to app (unsafe)"

### Erro: "Sign in with Google temporarily disabled for this app"

**Causa:** Você excedeu limite de logins ou está em revisão

**Solução:**
1. Aguarde algumas horas
2. Verifique se o app não foi suspendido no Console

---

## 📋 Checklist Final

- [ ] Selecionei "External" como User Type
- [ ] Preenchi App name: "Sistema de Cartão de Benefícios"
- [ ] Adicionei User support email: daniellinsr@gmail.com
- [ ] Adicionei Developer contact: daniellinsr@gmail.com
- [ ] Adicionei scope: `.../auth/userinfo.email`
- [ ] Adicionei scope: `.../auth/userinfo.profile`
- [ ] Adicionei Test User: daniellinsr@gmail.com
- [ ] Status mostra "Testing"
- [ ] Testei login no app

---

## 🔗 Links Úteis

- [OAuth Consent Screen do seu projeto](https://console.cloud.google.com/apis/credentials/consent?project=403775802042)
- [Documentação Google OAuth](https://support.google.com/cloud/answer/6158849)
- [OAuth 2.0 Scopes](https://developers.google.com/identity/protocols/oauth2/scopes)

---

## 📞 Suporte

Se encontrar problemas:

1. Verifique o [GOOGLE_OAUTH_SETUP.md](./GOOGLE_OAUTH_SETUP.md) - Troubleshooting
2. Verifique o [GOOGLE_OAUTH_STATUS.md](./GOOGLE_OAUTH_STATUS.md) - Status geral
3. Consulte os logs do Flutter: `flutter logs`

---

**Última atualização:** 2024-12-13
**Status:** ✅ Guia Completo
