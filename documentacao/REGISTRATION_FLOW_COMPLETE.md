# ✅ Fluxo de Cadastro Completo - Implementação Finalizada

**Data:** 2025-12-18
**Status:** ✅ **COMPLETO**

---

## 📋 Resumo Executivo

O fluxo completo de cadastro de novos usuários foi implementado com sucesso, incluindo:
- ✅ 3 páginas de formulário (Identificação, Endereço, Senha)
- ✅ Integração completa com backend
- ✅ Validações em tempo real
- ✅ Auto-save (rascunho)
- ✅ Indicador de força de senha
- ✅ Busca automática de CEP
- ✅ Design responsivo e animado

---

## 🎯 Páginas Implementadas

### 1. RegistrationIntroPage ✅
**Arquivo:** [registration_intro_page.dart](../lib/presentation/pages/registration/registration_intro_page.dart)

**Funcionalidades:**
- Apresentação dos benefícios do sistema
- Botão "Quero Me Cadastrar Agora"
- Google Sign-In integrado
- Botão de WhatsApp para suporte
- Verificação de rascunho salvo
- Animações suaves (animate_do)

**Navegação:**
- De: Landing Page (`/`)
- Para: Registration Identification (`/registration/identification`)

---

### 2. RegistrationIdentificationPage ✅
**Arquivo:** [registration_identification_page.dart](../lib/presentation/pages/registration/registration_identification_page.dart)

**Campos:**
1. **Nome Completo** (obrigatório)
   - Validação: mínimo 2 palavras, 3 caracteres
2. **CPF** (obrigatório)
   - Máscara: `000.000.000-00`
   - Validação: algoritmo de dígitos verificadores
3. **Data de Nascimento** (obrigatório)
   - Máscara: `DD/MM/AAAA`
   - Validação: idade mínima 18 anos, data válida
4. **Celular** (obrigatório)
   - Máscara: `(00) 00000-0000`
   - Validação: 11 dígitos, DDD válido, inicia com 9
5. **Email** (obrigatório)
   - Validação: formato válido (regex)

**Funcionalidades:**
- Barra de progresso (Passo 1 de 3)
- Auto-save automático
- Loading state no botão
- Design com gradient azul e card branco

**Navegação:**
- De: Registration Intro
- Para: Registration Address (`/registration/address`)

**Salvamento:**
```dart
// Dados salvos em RegistrationDraftService
await _draftService.saveIdentificationDraft(
  nome: _nomeController.text,
  cpf: _cpfController.text,
  dataNascimento: _dataNascimentoController.text,
  celular: _celularController.text,
  email: _emailController.text,
);

// Dados também salvos em RegistrationService para envio final
sl.registrationService.setName(_nomeController.text);
sl.registrationService.setEmail(_emailController.text);
// ... outros campos
```

---

### 3. RegistrationAddressPage ✅
**Arquivo:** [registration_address_page.dart](../lib/presentation/pages/registration/registration_address_page.dart)

**Campos:**
1. **CEP** (obrigatório)
   - Máscara: `00000-000`
   - Busca automática via ViaCEP
   - Botão de buscar manual
2. **Logradouro** (obrigatório)
   - Preenchido automaticamente pelo CEP
3. **Número** (obrigatório)
4. **Complemento** (opcional)
5. **Bairro** (obrigatório)
   - Preenchido automaticamente pelo CEP
6. **Cidade** (obrigatório)
   - Preenchido automaticamente pelo CEP
7. **UF** (obrigatório)
   - Máscara: 2 letras maiúsculas
   - Preenchido automaticamente pelo CEP

**Funcionalidades:**
- Barra de progresso (Passo 2 de 3)
- Busca automática de endereço por CEP
- Auto-save automático
- Loading indicator durante busca de CEP
- Design matching identification page

**Busca de CEP:**
```dart
Future<void> _searchCep() async {
  if (_cepController.text.length != 9) return;

  setState(() => _isLoadingCep = true);

  try {
    final cep = _cepController.text.replaceAll('-', '');
    final address = await ViaCepService.fetchAddress(cep);

    if (address != null && !address.erro) {
      _logradouroController.text = address.logradouro;
      _bairroController.text = address.bairro;
      _cidadeController.text = address.localidade;
      _estadoController.text = address.uf;

      // Foca no campo de número
      FocusScope.of(context).nextFocus();
    }
  } catch (e) {
    // Mostra erro ao usuário
  } finally {
    setState(() => _isLoadingCep = false);
  }
}
```

**Navegação:**
- De: Registration Identification
- Para: Registration Password (`/registration/password`)

**Salvamento:**
```dart
// Salva em RegistrationService
sl.registrationService.setCep(_cepController.text);
sl.registrationService.setLogradouro(_logradouroController.text);
sl.registrationService.setNumero(_numeroController.text);
sl.registrationService.setComplemento(_complementoController.text);
sl.registrationService.setBairro(_bairroController.text);
sl.registrationService.setCidade(_cidadeController.text);
sl.registrationService.setEstado(_estadoController.text);
```

---

### 4. RegistrationPasswordPage ✅
**Arquivo:** [registration_password_page.dart](../lib/presentation/pages/registration/registration_password_page.dart)

**Campos:**
1. **Senha** (obrigatório)
   - Validação de força (Fraca, Média, Forte, Muito Forte)
   - Indicador visual de força
   - Toggle para mostrar/ocultar
   - Mínimo: senha "Média"
2. **Confirmar Senha** (obrigatório)
   - Validação: deve ser igual à senha
   - Toggle para mostrar/ocultar

**Funcionalidades:**
- Barra de progresso (Passo 3 de 3)
- Indicador de força da senha em tempo real
- Cores do indicador: vermelho (fraca) → verde (muito forte)
- Validação de força mínima antes de submit
- **Execução do registro no backend**
- Dialog de sucesso após cadastro
- Redirecionamento automático para login

**Indicador de Força:**
```dart
Widget _buildPasswordStrengthIndicator() {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      // Barra de progresso
      LinearProgressIndicator(
        value: _getStrengthProgress(),
        backgroundColor: Colors.grey[300],
        valueColor: AlwaysStoppedAnimation<Color>(_getStrengthColor()),
        minHeight: 6,
        borderRadius: BorderRadius.circular(3),
      ),
      const SizedBox(height: 8),
      // Texto descritivo
      Text(
        _getStrengthText(),
        style: AppTextStyles.caption.copyWith(
          color: _getStrengthColor(),
          fontWeight: FontWeight.w600,
        ),
      ),
    ],
  );
}
```

**Submit e Registro:**
```dart
Future<void> _submitForm() async {
  if (!_formKey.currentState!.validate()) return;

  // Verifica força mínima
  if (_passwordStrength < 3) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Por favor, escolha uma senha mais forte (mínimo: Média)'),
        backgroundColor: Colors.orange,
      ),
    );
    return;
  }

  setState(() => _isLoading = true);

  try {
    // Salvar senha no RegistrationService
    sl.registrationService.setPassword(_senhaController.text);

    // EXECUTAR REGISTRO NO BACKEND
    final result = await sl.registrationService.register();

    if (result.isSuccess) {
      // Token já foi salvo automaticamente pelo service
      _showSuccessDialog();
    } else {
      // Mostra erro
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result.errorMessage ?? 'Erro ao realizar cadastro'),
          backgroundColor: Colors.red,
        ),
      );
    }
  } catch (e) {
    // Erro inesperado
  } finally {
    setState(() => _isLoading = false);
  }
}
```

**Navegação:**
- De: Registration Address
- Para: Login (`/login`) após sucesso

---

## 🔧 Serviços Implementados

### RegistrationService ✅
**Arquivo:** [registration_service.dart](../lib/core/services/registration_service.dart)

**Responsabilidade:**
Gerencia o fluxo completo de cadastro, armazenando temporariamente os dados coletados nas 3 etapas e executando o registro final.

**Dados Armazenados:**
```dart
// Identificação
String? _name;
String? _email;
String? _cpf;
String? _birthDate; // DD/MM/YYYY
String? _phoneNumber;

// Endereço
String? _cep;
String? _logradouro;
String? _numero;
String? _complemento;
String? _bairro;
String? _cidade;
String? _estado;

// Senha
String? _password;
```

**Métodos Principais:**
```dart
// Setters para cada campo
void setName(String value);
void setEmail(String value);
void setCpf(String value);
// ... (14 setters no total)

// Validações
bool isIdentificationComplete();
bool isAddressComplete();
bool isPasswordComplete();
bool isComplete();

// Progresso
int getProgress(); // Retorna 0-100%

// Registro final
Future<RegistrationResult> register();

// Limpeza
void clear();
```

**Método `register()`:**
```dart
Future<RegistrationResult> register() async {
  // 1. Validar se todos os dados estão completos
  if (!isComplete()) {
    return RegistrationResult.error('Dados incompletos');
  }

  // 2. Converter data de DD/MM/YYYY para YYYY-MM-DD
  final birthDateISO = _convertDateToISO(_birthDate!);

  // 3. Remover formatação de CPF, telefone e CEP
  final cpfClean = _removeFormatting(_cpf!);
  final phoneClean = _removeFormatting(_phoneNumber!);
  final cepClean = _removeFormatting(_cep!);

  // 4. Chamar AuthRepository.register()
  final result = await _authRepository.register(
    name: _name!,
    email: _email!,
    password: _password!,
    phoneNumber: phoneClean,
    cpf: cpfClean,
    birthDate: birthDateISO,
    cep: cepClean,
    logradouro: _logradouro!,
    numero: _numero!,
    complemento: _complemento,
    bairro: _bairro!,
    cidade: _cidade!,
    estado: _estado!,
  );

  // 5. Processar resultado
  return result.fold(
    (failure) => RegistrationResult.error(failure.message),
    (authToken) async {
      // Salvar token automaticamente
      await _tokenService.saveToken(authToken);
      return RegistrationResult.success(authToken: authToken);
    },
  );
}
```

---

### RegistrationDraftService ✅
**Arquivo:** [registration_draft_service.dart](../lib/core/services/registration_draft_service.dart)

**Responsabilidade:**
Salva automaticamente os dados do formulário em cache local (Hive) para recuperação em caso de interrupção.

**Métodos:**
```dart
// Salvar rascunhos
Future<void> saveIdentificationDraft({...});
Future<void> saveAddressDraft({...});

// Carregar rascunhos
Future<Map<String, dynamic>?> loadIdentificationDraft();
Future<Map<String, dynamic>?> loadAddressDraft();

// Verificações
Future<bool> hasDraft();
Future<bool> isDraftExpired(); // Expira em 7 dias

// Progresso e resumo
Future<int> getProgressPercentage();
Future<String> getDraftSummary();

// Limpeza
Future<void> clearDraft();
```

**Uso:**
```dart
// No initState() da página
@override
void initState() {
  super.initState();
  _loadDraft();      // Carrega dados salvos
  _setupAutoSave();  // Configura listeners
}

// Setup de auto-save
void _setupAutoSave() {
  _nomeController.addListener(_saveDraft);
  _cpfController.addListener(_saveDraft);
  // ... outros controllers
}

// Salvamento automático
Future<void> _saveDraft() async {
  if (_nomeController.text.isEmpty) return;

  await _draftService.saveIdentificationDraft(
    nome: _nomeController.text,
    cpf: _cpfController.text,
    // ... outros campos
  );
}
```

---

### ViaCepService ✅
**Arquivo:** [viacep_service.dart](../lib/core/services/viacep_service.dart)

**Responsabilidade:**
Busca endereço automaticamente via API ViaCEP quando usuário digita o CEP.

**Uso:**
```dart
final address = await ViaCepService.fetchAddress(cep);

if (address != null && !address.erro) {
  _logradouroController.text = address.logradouro;
  _bairroController.text = address.bairro;
  _cidadeController.text = address.localidade;
  _estadoController.text = address.uf;
}
```

---

## 🔗 Integração com Backend

### Fluxo Completo

```
┌─────────────────────────────────────────────────────────────┐
│                   FRONTEND (Flutter)                        │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  1. Usuário preenche 3 formulários                         │
│     ├─ RegistrationIdentificationPage                      │
│     ├─ RegistrationAddressPage                             │
│     └─ RegistrationPasswordPage                            │
│                                                             │
│  2. Dados salvos em RegistrationService                    │
│                                                             │
│  3. Ao clicar "Finalizar Cadastro":                        │
│     └─ RegistrationService.register()                      │
│                                                             │
│  4. Chama AuthRepository.register()                        │
│     └─ Passa todos os dados coletados                      │
│                                                             │
│  5. AuthRepository chama AuthRemoteDataSource              │
│     └─ Converte dados para formato de API                  │
│                                                             │
│  6. AuthRemoteDataSource faz POST para backend             │
│     ├─ Endpoint: POST /auth/register                       │
│     └─ DioClient envia request HTTP                        │
│                                                             │
└─────────────────────────────────────────────────────────────┘
                           │
                           │ HTTP POST
                           ▼
┌─────────────────────────────────────────────────────────────┐
│                   BACKEND (Node.js)                         │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  1. Route: POST /auth/register                             │
│     └─ auth.routes.ts                                      │
│                                                             │
│  2. Controller: register()                                 │
│     └─ auth.controller.ts                                  │
│     ├─ Valida dados obrigatórios                           │
│     ├─ Verifica se email/CPF já existe                     │
│     ├─ Faz hash da senha (bcrypt)                          │
│     └─ Insere usuário no banco                             │
│                                                             │
│  3. Database: PostgreSQL                                    │
│     └─ INSERT INTO users (...)                             │
│                                                             │
│  4. Gera tokens JWT                                        │
│     ├─ accessToken (15min)                                 │
│     └─ refreshToken (7 dias)                               │
│                                                             │
│  5. Retorna resposta                                       │
│     └─ { user, accessToken, refreshToken }                 │
│                                                             │
└─────────────────────────────────────────────────────────────┘
                           │
                           │ HTTP Response 200
                           ▼
┌─────────────────────────────────────────────────────────────┐
│                   FRONTEND (Flutter)                        │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  1. AuthRemoteDataSource recebe resposta                   │
│     └─ RegistrationResponseModel.fromJson()                │
│                                                             │
│  2. Converte para AuthTokenModel                           │
│                                                             │
│  3. AuthRepository retorna Right(AuthToken)                │
│                                                             │
│  4. RegistrationService processa sucesso                   │
│     ├─ Salva token com TokenService                        │
│     └─ Retorna RegistrationResult.success()                │
│                                                             │
│  5. RegistrationPasswordPage mostra dialog de sucesso      │
│     └─ Redireciona para /login                             │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

---

### Endpoint do Backend

**URL:** `POST http://localhost:3000/api/auth/register`

**Payload:**
```json
{
  "name": "João Silva Santos",
  "email": "joao@email.com",
  "password": "SenhaForte@123",
  "phone_number": "11999999999",
  "cpf": "12345678909",
  "birth_date": "2000-06-15",
  "cep": "01310100",
  "street": "Av. Paulista",
  "number": "1000",
  "complement": "Apto 101",
  "neighborhood": "Bela Vista",
  "city": "São Paulo",
  "state": "SP"
}
```

**Resposta de Sucesso (200):**
```json
{
  "user": {
    "id": "uuid",
    "email": "joao@email.com",
    "name": "João Silva Santos",
    "phone_number": "11999999999",
    "cpf": "12345678909",
    "birth_date": "2000-06-15",
    "role": "beneficiary",
    "email_verified": false,
    "phone_verified": false,
    "profile_completion_status": "complete",
    "created_at": "2025-12-18T..."
  },
  "accessToken": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "refreshToken": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
}
```

**Resposta de Erro (409 - Já existe):**
```json
{
  "error": "USER_EXISTS",
  "message": "User with this email or CPF already exists"
}
```

**Resposta de Erro (400 - Dados inválidos):**
```json
{
  "error": "INVALID_REQUEST",
  "message": "Name, email, password, and phone number are required"
}
```

---

## 📊 Arquivos Envolvidos

### Frontend (Flutter)

| Arquivo | Tipo | Linhas | Descrição |
|---------|------|--------|-----------|
| **Presentation** | | | |
| `registration_intro_page.dart` | Page | ~400 | Página de introdução |
| `registration_identification_page.dart` | Page | ~300 | Formulário de dados pessoais |
| `registration_address_page.dart` | Page | ~700 | Formulário de endereço |
| `registration_password_page.dart` | Page | ~500 | Formulário de senha |
| **Services** | | | |
| `registration_service.dart` | Service | ~250 | Gerencia fluxo de cadastro |
| `registration_draft_service.dart` | Service | ~200 | Auto-save de rascunho |
| `viacep_service.dart` | Service | ~50 | Busca CEP |
| **Domain** | | | |
| `auth_repository.dart` | Interface | ~80 | Contrato do repositório |
| **Data** | | | |
| `auth_repository_impl.dart` | Repository | ~350 | Implementação do repositório |
| `auth_remote_datasource.dart` | DataSource | ~400 | Comunicação HTTP com backend |
| `registration_response_model.dart` | Model | ~100 | Modelo de resposta |
| **Core** | | | |
| `validators.dart` | Utils | ~400 | Validadores de formulário |
| `input_formatters.dart` | Utils | ~200 | Máscaras de entrada |
| **Total** | | **~3,930** | |

### Backend (Node.js)

| Arquivo | Tipo | Linhas | Descrição |
|---------|------|--------|-----------|
| `auth.routes.ts` | Routes | ~30 | Rotas de autenticação |
| `auth.controller.ts` | Controller | ~800 | Lógica de autenticação/registro |
| `jwt.utils.ts` | Utils | ~150 | Geração e validação de tokens |
| `database.ts` | Config | ~50 | Configuração do PostgreSQL |
| **Total** | | **~1,030** | |

---

## ✅ Checklist de Implementação

### Páginas ✅
- [x] RegistrationIntroPage
- [x] RegistrationIdentificationPage
- [x] RegistrationAddressPage
- [x] RegistrationPasswordPage

### Funcionalidades ✅
- [x] Validações em tempo real
- [x] Máscaras de entrada (CPF, telefone, CEP, data)
- [x] Auto-save (rascunho)
- [x] Busca automática de CEP
- [x] Indicador de força de senha
- [x] Barra de progresso
- [x] Animações suaves
- [x] Design responsivo
- [x] Loading states
- [x] Feedback visual (snackbars, dialogs)

### Backend ✅
- [x] Endpoint POST /auth/register
- [x] Validação de dados
- [x] Verificação de duplicação (email, CPF)
- [x] Hash de senha (bcrypt)
- [x] Inserção no banco de dados
- [x] Geração de tokens JWT
- [x] Tratamento de erros

### Integração ✅
- [x] RegistrationService completo
- [x] AuthRepository.register()
- [x] AuthRemoteDataSource.register()
- [x] RegistrationResponseModel
- [x] Salvamento automático de token
- [x] Navegação após sucesso

---

## 🧪 Como Testar

### 1. Teste Manual do Fluxo Completo

**Pré-requisitos:**
- Backend rodando: `cd backend && npm run dev`
- Database PostgreSQL rodando
- Frontend rodando: `flutter run`

**Passos:**
1. Abra o app
2. Clique em "Começar agora" na landing page
3. Clique em "Quero Me Cadastrar Agora"

**Passo 1 - Identificação:**
4. Preencha:
   - Nome: "João Silva Santos"
   - CPF: "123.456.789-09" (CPF válido de teste)
   - Data: "15/06/2000"
   - Celular: "(11) 99999-9999"
   - Email: "joao@teste.com"
5. Clique em "Continuar"

**Passo 2 - Endereço:**
6. Digite CEP: "01310-100"
7. Aguarde preenchimento automático
8. Preencha número: "1000"
9. Complemento: "Apto 101" (opcional)
10. Clique em "Continuar"

**Passo 3 - Senha:**
11. Digite senha forte: "SenhaForte@123"
12. Confirme a senha
13. Observe indicador de força (deve mostrar "Forte" ou "Muito Forte")
14. Clique em "Finalizar Cadastro"

**Resultado Esperado:**
- ✅ Loading no botão
- ✅ Requisição POST para backend
- ✅ Dialog de sucesso
- ✅ Redirecionamento para /login
- ✅ Token salvo automaticamente

---

### 2. Teste de Validações

**Campos Obrigatórios:**
- [ ] Tentar avançar sem preencher nome → "Por favor, informe seu nome completo"
- [ ] Tentar avançar com CPF inválido → "CPF inválido"
- [ ] Tentar avançar com data inválida → "Data inválida"
- [ ] Tentar avançar com celular inválido → "Número de celular deve começar com 9"
- [ ] Tentar avançar com email inválido → "Email inválido"

**Máscaras:**
- [ ] Digite "12345678909" no CPF → Formata para "123.456.789-09"
- [ ] Digite "15062000" na data → Formata para "15/06/2000"
- [ ] Digite "11999999999" no celular → Formata para "(11) 99999-9999"
- [ ] Digite "01310100" no CEP → Formata para "01310-100"

**Busca de CEP:**
- [ ] Digite CEP válido → Preenche logradouro, bairro, cidade, estado
- [ ] Digite CEP inválido → Mostra mensagem "CEP não encontrado"

**Força de Senha:**
- [ ] Digite "123" → Indicador vermelho "Muito Fraca"
- [ ] Digite "senha123" → Indicador laranja "Fraca"
- [ ] Digite "Senha@123" → Indicador amarelo "Média"
- [ ] Digite "SenhaForte@123" → Indicador verde "Forte"

---

### 3. Teste de Auto-Save

1. Preencha parcialmente o formulário de identificação
2. Feche o app
3. Reabra o app
4. Vá para "Quero Me Cadastrar"
5. Deve mostrar snackbar: "Dados carregados automaticamente"
6. Campos devem estar preenchidos

---

### 4. Teste de Erros

**Email Duplicado:**
1. Cadastre um usuário com email "teste@email.com"
2. Tente cadastrar outro usuário com mesmo email
3. Deve mostrar erro: "User with this email or CPF already exists"

**CPF Duplicado:**
1. Cadastre um usuário com CPF "123.456.789-09"
2. Tente cadastrar outro usuário com mesmo CPF
3. Deve mostrar erro: "User with this email or CPF already exists"

**Senha Fraca:**
1. Preencha formulários até a tela de senha
2. Digite senha fraca: "123456"
3. Tente finalizar cadastro
4. Deve mostrar: "Por favor, escolha uma senha mais forte (mínimo: Média)"

---

## 🐛 Troubleshooting

### Erro: "User with this email or CPF already exists"

**Causa:** Email ou CPF já cadastrado no banco de dados

**Solução:**
1. Use email/CPF diferentes
2. Ou limpe o banco: `DELETE FROM users WHERE email = 'teste@email.com';`

---

### Erro: CEP não preenche automaticamente

**Causa:** CEP inválido ou erro de conexão com ViaCEP

**Solução:**
1. Verifique conexão com internet
2. Use CEP válido (ex: 01310-100)
3. Preencha manualmente se necessário

---

### Erro: Token não é salvo

**Causa:** TokenService não está inicializado corretamente

**Solução:**
Verificar em `service_locator.dart`:
```dart
sl.registerLazySingleton(() => TokenService());
```

---

## 📝 Próximos Passos

### Melhorias Recomendadas

1. **Verificação de Email** ⏳
   - Enviar código de verificação por email
   - Validar email antes de permitir login

2. **Verificação de Telefone** ⏳
   - Enviar SMS com código
   - Ou enviar WhatsApp com código

3. **Upload de Foto** ⏳
   - Permitir foto de perfil
   - Validação de documento (frente e verso do CPF)

4. **Testes Automatizados** ⏳
   - Testes unitários de validators
   - Testes de widget
   - Testes de integração do fluxo completo

5. **Melhorias UX** ⏳
   - Permitir voltar para etapas anteriores
   - Mostrar resumo antes de finalizar
   - Adicionar tutorial/tooltips

---

## 📄 Documentação Relacionada

- [PLANEJAMENTO_COMPLETO.md](PLANEJAMENTO_COMPLETO.md) - Planejamento geral do projeto
- [MODULO5_COMPLETO.md](MODULO5_COMPLETO.md) - Detalhes do Módulo 5
- [REVISAO_PLANEJAMENTO_2025_12_18.md](REVISAO_PLANEJAMENTO_2025_12_18.md) - Revisão recente

---

**Documento criado em:** 2025-12-18
**Versão:** 1.0.0
**Status:** ✅ IMPLEMENTAÇÃO COMPLETA
