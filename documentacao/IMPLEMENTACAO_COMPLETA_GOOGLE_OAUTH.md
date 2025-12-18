# 🎯 Implementação Completa: Google OAuth + Completar Perfil

**Status:** ✅ 40% Completo | 🚧 Backend: Pronto para implementar | 🚧 Frontend: Página pendente

---

## ✅ JÁ IMPLEMENTADO (40%)

### 1. Banco de Dados ✅
- Coluna `profile_completion_status` adicionada
- Script: `backend/add_profile_completion_status.sql`

### 2. Domain Layer (Flutter) ✅
- Enum `ProfileCompletionStatus` criado
- Método `user.isProfileComplete` implementado
- Extensão `ProfileCompletionStatusExtension` com conversões

### 3. Data Layer (Flutter) ✅
- `UserModel` atualizado com `profileCompletionStatus`
- Serialização JSON configurada
- Conversão Entity ↔ Model implementada
- Código gerado com `build_runner` ✅

---

## 🚧 IMPLEMENTAÇÕES RESTANTES

### 4. Backend - Types & JWT Utils (15 min)

#### 4.1. Atualizar `backend/src/types/index.ts`
```typescript
export interface AuthToken {
  user: {
    id: string;
    email: string;
    name: string;
    phone_number?: string;
    cpf?: string;
    birth_date?: string;
    role?: string;
    is_email_verified?: boolean;
    is_phone_verified?: boolean;
    profile_completion_status?: string;  // ← ADICIONAR
    created_at?: Date;
  };
  access_token: string;
  refresh_token: string;
  token_type: string;
  expires_in: number;
}
```

#### 4.2. Atualizar `backend/src/utils/jwt.utils.ts`
```typescript
export const generateTokens = async (user: {
  id: string;
  email: string;
  name: string;
  phone_number?: string;
  cpf?: string;
  birth_date?: string;
  role?: string;
  email_verified?: boolean;
  phone_verified?: boolean;
  profile_completion_status?: string;  // ← ADICIONAR
  created_at?: Date;
}): Promise<AuthToken> => {
  // ... código existente ...

  return {
    user: {
      id: user.id,
      email: user.email,
      name: user.name,
      phone_number: user.phone_number,
      cpf: user.cpf,
      birth_date: user.birth_date,
      role: user.role || 'beneficiary',
      is_email_verified: user.email_verified || false,
      is_phone_verified: user.phone_verified || false,
      profile_completion_status: user.profile_completion_status || 'complete',  // ← ADICIONAR
      created_at: user.created_at,
    },
    access_token: accessToken,
    refresh_token: refreshToken,
    token_type: 'Bearer',
    expires_in: expiresInSeconds,
  };
};
```

---

### 5. Backend - Auth Controller (20 min)

#### 5.1. Atualizar `loginWithEmail` (linha ~24)
```typescript
const result = await pool.query(
  `SELECT id, email, name, phone_number, cpf, birth_date, role, password_hash,
          email_verified, phone_verified, created_at, profile_completion_status
   FROM users WHERE email = $1 AND deleted_at IS NULL`,
  [email]
);
```

#### 5.2. Atualizar `loginWithGoogle` - SELECT existente (linha ~102)
```typescript
let result = await pool.query(
  `SELECT id, email, name, phone_number, cpf, birth_date, role,
          created_at, profile_completion_status
   FROM users WHERE google_id = $1 AND deleted_at IS NULL`,
  [payload.sub]
);
```

#### 5.3. Atualizar `loginWithGoogle` - SELECT por email (linha ~110)
```typescript
result = await pool.query(
  `SELECT id, email, name, phone_number, cpf, birth_date, role,
          created_at, profile_completion_status
   FROM users WHERE email = $1 AND deleted_at IS NULL`,
  [payload.email]
);
```

#### 5.4. Atualizar `loginWithGoogle` - INSERT novo usuário (linha ~124-130)
```typescript
const insertResult = await pool.query(
  `INSERT INTO users (id, email, name, google_id, email_verified, phone_number, role, profile_completion_status)
   VALUES ($1, $2, $3, $4, true, '', 'beneficiary', 'incomplete')
   RETURNING id, email, name, phone_number, cpf, birth_date, role,
             email_verified, phone_verified, created_at, profile_completion_status`,
  [userId, payload.email, payload.name || '', payload.sub]
);
```

#### 5.5. Atualizar `refreshToken` (linha ~257)
```typescript
const result = await pool.query(
  `SELECT id, email, name, phone_number, cpf, birth_date, role, created_at, profile_completion_status
   FROM users WHERE id = $1 AND deleted_at IS NULL`,
  [userId]
);
```

#### 5.6. Adicionar endpoint `completeProfile`

**Adicionar no final de `auth.controller.ts`:**
```typescript
export const completeProfile = async (req: AuthRequest, res: Response): Promise<void> => {
  try {
    if (!req.user) {
      res.status(401).json({
        error: 'UNAUTHORIZED',
        message: 'User not authenticated',
      });
      return;
    }

    const {
      cpf,
      phone_number,
      birth_date,
      cep,
      street,
      number,
      complement,
      neighborhood,
      city,
      state,
    } = req.body;

    // Validar campos obrigatórios
    if (!cpf || !phone_number || !cep || !street || !number || !neighborhood || !city || !state) {
      res.status(400).json({
        error: 'INVALID_REQUEST',
        message: 'CPF, phone number, and complete address are required',
      });
      return;
    }

    // Atualizar perfil
    const result = await pool.query(
      `UPDATE users
       SET cpf = $1, phone_number = $2, birth_date = $3,
           cep = $4, street = $5, number = $6, complement = $7,
           neighborhood = $8, city = $9, state = $10,
           profile_completion_status = 'complete',
           updated_at = NOW()
       WHERE id = $11
       RETURNING id, email, name, phone_number, cpf, birth_date, role,
                 email_verified, phone_verified, created_at, profile_completion_status`,
      [
        cpf,
        phone_number,
        birth_date || null,
        cep,
        street,
        number,
        complement || null,
        neighborhood,
        city,
        state,
        req.user.id,
      ]
    );

    if (result.rows.length === 0) {
      res.status(404).json({
        error: 'USER_NOT_FOUND',
        message: 'User not found',
      });
      return;
    }

    const user = result.rows[0];

    const userWithFormattedDate = {
      ...user,
      created_at: user.created_at ? new Date(user.created_at).toISOString() : new Date().toISOString(),
    };

    const tokens = await generateTokens(userWithFormattedDate);

    res.json(tokens);
  } catch (error) {
    console.error('Complete profile error:', error);
    res.status(500).json({
      error: 'SERVER_ERROR',
      message: 'Internal server error',
    });
  }
};
```

#### 5.7. Adicionar rota `backend/src/routes/auth.routes.ts`
```typescript
import { authMiddleware } from '../middleware/auth.middleware';
import { completeProfile } from '../controllers/auth.controller';

// Adicionar esta linha
router.put('/profile/complete', authMiddleware, completeProfile);
```

---

### 6. Frontend - Página CompleteProfilePage (45 min)

**Criar arquivo:** `lib/presentation/pages/complete_profile_page.dart`

```dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:cadastro_beneficios/core/di/service_locator.dart';
import 'package:cadastro_beneficios/core/utils/validators.dart';
import 'package:cadastro_beneficios/core/widgets/custom_text_field.dart';
import 'package:cadastro_beneficios/core/widgets/custom_button.dart';
import 'package:cadastro_beneficios/core/services/viacep_service.dart';

class CompleteProfilePage extends StatefulWidget {
  const CompleteProfilePage({super.key});

  @override
  State<CompleteProfilePage> createState() => _CompleteProfilePageState();
}

class _CompleteProfilePageState extends State<CompleteProfilePage> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  // Controllers
  final _cpfController = TextEditingController();
  final _celularController = TextEditingController();
  final _dataNascimentoController = TextEditingController();
  final _cepController = TextEditingController();
  final _logradouroController = TextEditingController();
  final _numeroController = TextEditingController();
  final _complementoController = TextEditingController();
  final _bairroController = TextEditingController();
  final _cidadeController = TextEditingController();
  final _estadoController = TextEditingController();

  @override
  void dispose() {
    _cpfController.dispose();
    _celularController.dispose();
    _dataNascimentoController.dispose();
    _cepController.dispose();
    _logradouroController.dispose();
    _numeroController.dispose();
    _complementoController.dispose();
    _bairroController.dispose();
    _cidadeController.dispose();
    _estadoController.dispose();
    super.dispose();
  }

  Future<void> _buscarCep() async {
    final cep = _cepController.text.replaceAll(RegExp(r'[^0-9]'), '');
    if (cep.length != 8) return;

    setState(() => _isLoading = true);

    try {
      final endereco = await ViaCepService.buscarCep(cep);
      if (endereco != null) {
        _logradouroController.text = endereco['logradouro'] ?? '';
        _bairroController.text = endereco['bairro'] ?? '';
        _cidadeController.text = endereco['localidade'] ?? '';
        _estadoController.text = endereco['uf'] ?? '';
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao buscar CEP: $e')),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      // Remover formatação
      final cpfClean = _cpfController.text.replaceAll(RegExp(r'[^0-9]'), '');
      final phoneClean = _celularController.text.replaceAll(RegExp(r'[^0-9]'), '');
      final cepClean = _cepController.text.replaceAll(RegExp(r'[^0-9]'), '');

      // Converter data DD/MM/YYYY → YYYY-MM-DD
      String? birthDateISO;
      if (_dataNascimentoController.text.isNotEmpty) {
        final parts = _dataNascimentoController.text.split('/');
        if (parts.length == 3) {
          birthDateISO = '${parts[2]}-${parts[1]}-${parts[0]}';
        }
      }

      // Chamar endpoint (você precisa criar isso no repository)
      final result = await sl.authRepository.completeProfile(
        cpf: cpfClean,
        phoneNumber: phoneClean,
        birthDate: birthDateISO,
        cep: cepClean,
        street: _logradouroController.text,
        number: _numeroController.text,
        complement: _complementoController.text.isEmpty ? null : _complementoController.text,
        neighborhood: _bairroController.text,
        city: _cidadeController.text,
        state: _estadoController.text,
      );

      result.fold(
        (failure) {
          setState(() => _isLoading = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(failure.message)),
          );
        },
        (authToken) {
          setState(() => _isLoading = false);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Perfil completado com sucesso!')),
          );
          context.go('/home');
        },
      );
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro inesperado: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Complete seu Perfil'),
        automaticallyImplyLeading: false, // Não permitir voltar
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      'Para acessar o sistema, precisamos de algumas informações adicionais',
                      style: TextStyle(fontSize: 16),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 32),

                    const Text('Dados Pessoais', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),

                    CustomTextField(
                      label: 'CPF',
                      controller: _cpfController,
                      mask: '###.###.###-##',
                      keyboardType: TextInputType.number,
                      validator: Validators.cpf,
                    ),
                    const SizedBox(height: 16),

                    CustomTextField(
                      label: 'Celular',
                      controller: _celularController,
                      mask: '(##) #####-####',
                      keyboardType: TextInputType.phone,
                      validator: Validators.celular,
                    ),
                    const SizedBox(height: 16),

                    CustomTextField(
                      label: 'Data de Nascimento (opcional)',
                      controller: _dataNascimentoController,
                      mask: '##/##/####',
                      keyboardType: TextInputType.datetime,
                    ),
                    const SizedBox(height: 32),

                    const Text('Endereço', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),

                    CustomTextField(
                      label: 'CEP',
                      controller: _cepController,
                      mask: '#####-###',
                      keyboardType: TextInputType.number,
                      validator: Validators.cep,
                      onChanged: (value) {
                        if (value.replaceAll(RegExp(r'[^0-9]'), '').length == 8) {
                          _buscarCep();
                        }
                      },
                    ),
                    const SizedBox(height: 16),

                    CustomTextField(
                      label: 'Logradouro',
                      controller: _logradouroController,
                      validator: Validators.required,
                    ),
                    const SizedBox(height: 16),

                    Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: CustomTextField(
                            label: 'Número',
                            controller: _numeroController,
                            keyboardType: TextInputType.text,
                            validator: Validators.required,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          flex: 3,
                          child: CustomTextField(
                            label: 'Complemento (opcional)',
                            controller: _complementoController,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    CustomTextField(
                      label: 'Bairro',
                      controller: _bairroController,
                      validator: Validators.required,
                    ),
                    const SizedBox(height: 16),

                    Row(
                      children: [
                        Expanded(
                          flex: 3,
                          child: CustomTextField(
                            label: 'Cidade',
                            controller: _cidadeController,
                            validator: Validators.required,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: CustomTextField(
                            label: 'UF',
                            controller: _estadoController,
                            maxLength: 2,
                            textCapitalization: TextCapitalization.characters,
                            validator: Validators.required,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),

                    CustomButton(
                      text: 'Completar Cadastro',
                      onPressed: _submit,
                      isLoading: _isLoading,
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
```

---

### 7. Frontend - Repository Method (10 min)

**Adicionar em `lib/domain/repositories/auth_repository.dart`:**
```dart
Future<Either<Failure, AuthToken>> completeProfile({
  required String cpf,
  required String phoneNumber,
  String? birthDate,
  required String cep,
  required String street,
  required String number,
  String? complement,
  required String neighborhood,
  required String city,
  required String state,
});
```

**Implementar em `lib/data/repositories/auth_repository_impl.dart`:**
```dart
@override
Future<Either<Failure, AuthToken>> completeProfile({
  required String cpf,
  required String phoneNumber,
  String? birthDate,
  required String cep,
  required String street,
  required String number,
  String? complement,
  required String neighborhood,
  required String city,
  required String state,
}) async {
  try {
    final authToken = await _remoteDataSource.completeProfile(
      cpf: cpf,
      phoneNumber: phoneNumber,
      birthDate: birthDate,
      cep: cep,
      street: street,
      number: number,
      complement: complement,
      neighborhood: neighborhood,
      city: city,
      state: state,
    );

    await _tokenService.saveToken(authToken);

    return Right(authToken.toEntity());
  } on DioException catch (e) {
    return Left(ServerFailure(e.response?.data['message'] ?? 'Erro ao completar perfil'));
  } catch (e) {
    return Left(ServerFailure(e.toString()));
  }
}
```

**Adicionar em `lib/data/datasources/auth_remote_datasource.dart`:**
```dart
Future<AuthTokenModel> completeProfile({
  required String cpf,
  required String phoneNumber,
  String? birthDate,
  required String cep,
  required String street,
  required String number,
  String? complement,
  required String neighborhood,
  required String city,
  required String state,
});
```

**Implementar em `lib/data/datasources/auth_remote_datasource_impl.dart`:**
```dart
@override
Future<AuthTokenModel> completeProfile({
  required String cpf,
  required String phoneNumber,
  String? birthDate,
  required String cep,
  required String street,
  required String number,
  String? complement,
  required String neighborhood,
  required String city,
  required String state,
}) async {
  final response = await _dioClient.put(
    '${ApiEndpoints.baseUrl}/profile/complete',
    data: {
      'cpf': cpf,
      'phone_number': phoneNumber,
      if (birthDate != null) 'birth_date': birthDate,
      'cep': cep,
      'street': street,
      'number': number,
      if (complement != null) 'complement': complement,
      'neighborhood': neighborhood,
      'city': city,
      'state': state,
    },
  );

  final registrationResponse = RegistrationResponseModel.fromJson(response.data);
  return registrationResponse.toAuthToken();
}
```

---

### 8. Router Guard (15 min)

**Modificar `lib/core/router/app_router.dart`:**
```dart
redirect: (context, state) async {
  // Verificar se usuário está autenticado
  final hasToken = await sl.tokenService.hasValidAccessToken();

  if (!hasToken && state.location != '/login' && !state.location.startsWith('/registration')) {
    return '/login';
  }

  if (hasToken) {
    // Buscar usuário atual
    final userResult = await sl.authRepository.getCurrentUser();

    return userResult.fold(
      (failure) {
        // Token inválido, redirecionar para login
        if (state.location != '/login') {
          return '/login';
        }
        return null;
      },
      (user) {
        // Se perfil incompleto e não está na página de completar
        if (!user.isProfileComplete && state.location != '/complete-profile') {
          return '/complete-profile';
        }

        // Se perfil completo e está tentando acessar complete-profile
        if (user.isProfileComplete && state.location == '/complete-profile') {
          return '/home';
        }

        // Se está tentando acessar login/register estando autenticado com perfil completo
        if (user.isProfileComplete &&
            (state.location == '/login' || state.location.startsWith('/registration'))) {
          return '/home';
        }

        return null;
      },
    );
  }

  return null;
},

// Adicionar rota
GoRoute(
  path: '/complete-profile',
  builder: (context, state) => const CompleteProfilePage(),
),
```

---

## 🎯 FLUXO FINAL

1. **Login via Google** → Usuário criado com `profile_completion_status = 'incomplete'`
2. **Token retornado** → Frontend detecta `isProfileComplete = false`
3. **Router redireciona** → `/complete-profile`
4. **Usuário preenche** → CPF, telefone, endereço
5. **Submit** → `PUT /api/auth/profile/complete`
6. **Backend atualiza** → `profile_completion_status = 'complete'`
7. **Novo token** → Com `profile_completion_status = 'complete'`
8. **Redireciona** → `/home`
9. **Próximos logins** → Direto para `/home`

---

## ✅ CHECKLIST FINAL

- [x] 1. Banco - coluna `profile_completion_status`
- [x] 2. Entity - enum + isProfileComplete
- [x] 3. UserModel - campo + serialização
- [ ] 4. Backend types + jwt.utils
- [ ] 5. Backend loginWithGoogle + outros SELECTs
- [ ] 6. Backend endpoint completeProfile
- [ ] 7. Frontend CompleteProfilePage
- [ ] 8. Frontend repository methods
- [ ] 9. Router guard

**Progresso:** 3/9 (33%)

---

**PRÓXIMO PASSO:** Implementar backend (itens 4, 5, 6) - estimativa: 50 minutos

