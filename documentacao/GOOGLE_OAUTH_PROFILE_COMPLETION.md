# 🎯 Implementação: Completar Perfil Obrigatório (Google OAuth)

**Data:** 2025-12-17
**Status:** 🚧 **EM ANDAMENTO** (25% completo)

---

## 📋 OBJETIVO

Garantir que usuários que fazem login via Google OAuth completem seus perfis com dados obrigatórios (CPF, telefone, endereço) antes de acessar o sistema.

---

## ✅ PROGRESSO

### 1. Banco de Dados ✅
**Arquivo:** `backend/add_profile_completion_status.sql`

```sql
ALTER TABLE users ADD COLUMN profile_completion_status VARCHAR(20) DEFAULT 'complete';
```

**Status:** ✅ Executado com sucesso
- Coluna `profile_completion_status` adicionada
- Default: `'complete'` para usuários existentes
- Valores possíveis: `'incomplete'` ou `'complete'`

### 2. Domain Entity ✅
**Arquivo:** `lib/domain/entities/user.dart`

**Adicionado:**
```dart
enum ProfileCompletionStatus {
  incomplete, // Perfil incompleto (faltam dados obrigatórios)
  complete,   // Perfil completo (todos dados obrigatórios preenchidos)
}

extension ProfileCompletionStatusExtension on ProfileCompletionStatus {
  String get value {
    switch (this) {
      case ProfileCompletionStatus.incomplete:
        return 'incomplete';
      case ProfileCompletionStatus.complete:
        return 'complete';
    }
  }

  static ProfileCompletionStatus fromString(String value) {
    switch (value.toLowerCase()) {
      case 'incomplete':
        return ProfileCompletionStatus.incomplete;
      case 'complete':
        return ProfileCompletionStatus.complete;
      default:
        return ProfileCompletionStatus.complete;
    }
  }
}

class User {
  // ... campos existentes
  final ProfileCompletionStatus profileCompletionStatus;

  // Método helper
  bool get isProfileComplete => profileCompletionStatus == ProfileCompletionStatus.complete;
}
```

---

## 🚧 PRÓXIMAS TAREFAS

### 3. UserModel (Frontend) 🔄
**Arquivo a modificar:** `lib/data/models/user_model.dart`

**O que fazer:**
1. Adicionar campo `profile_completion_status`
2. Adicionar ao `fromJson` e `toJson`
3. Adicionar ao `fromEntity` e `toEntity`
4. Regenerar código com `dart run build_runner build`

**Código a adicionar:**
```dart
@JsonSerializable()
class UserModel {
  // ... campos existentes

  @JsonKey(name: 'profile_completion_status')
  final String? profileCompletionStatus;

  UserModel({
    // ... parâmetros existentes
    this.profileCompletionStatus,
  });

  User toEntity() {
    return User(
      // ... campos existentes
      profileCompletionStatus: ProfileCompletionStatusExtension.fromString(
        profileCompletionStatus ?? 'complete'
      ),
    );
  }

  factory UserModel.fromEntity(User user) {
    return UserModel(
      // ... campos existentes
      profileCompletionStatus: user.profileCompletionStatus.value,
    );
  }
}
```

### 4. Backend - Login Google 🔄
**Arquivo a modificar:** `backend/src/controllers/auth.controller.ts`

**O que fazer:**
1. Atualizar INSERT do novo usuário Google para definir `profile_completion_status = 'incomplete'`
2. Atualizar SELECT para incluir `profile_completion_status` no RETURNING

**Código a modificar (linha ~124-130):**
```typescript
const insertResult = await pool.query(
  `INSERT INTO users (id, email, name, google_id, email_verified, phone_number, role, profile_completion_status)
   VALUES ($1, $2, $3, $4, true, '', 'beneficiary', 'incomplete')
   RETURNING id, email, name, phone_number, cpf, birth_date, role,
             email_verified, phone_verified, created_at, profile_completion_status`,
  [userId, payload.email, payload.name || '', payload.sub]
);
```

**Também atualizar SELECTs em:**
- `loginWithEmail` (linha ~24)
- `loginWithGoogle` (linhas ~102 e ~111)
- `refreshToken` (linha ~257)

### 5. Backend Types 🔄
**Arquivo a modificar:** `backend/src/types/index.ts`

**O que fazer:**
Adicionar `profile_completion_status` à interface AuthToken:

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

### 6. Backend JWT Utils 🔄
**Arquivo a modificar:** `backend/src/utils/jwt.utils.ts`

**O que fazer:**
```typescript
export const generateTokens = async (user: {
  // ... campos existentes
  profile_completion_status?: string;  // ← ADICIONAR
}): Promise<AuthToken> => {
  // ...
  return {
    user: {
      // ... campos existentes
      profile_completion_status: user.profile_completion_status || 'complete',  // ← ADICIONAR
      created_at: user.created_at,
    },
    // ... resto
  };
};
```

### 7. Página CompleteProfilePage 📝
**Arquivo a criar:** `lib/presentation/pages/complete_profile_page.dart`

**Funcionalidade:**
- Formulário com 3 campos obrigatórios:
  - CPF (com validação e máscara)
  - Telefone (com máscara)
  - CEP + campos de endereço (com busca automática)
- Botão "Completar Cadastro"
- Chamada ao endpoint de atualização de perfil

**Layout sugerido:**
```
┌─────────────────────────────────┐
│  Complete seu Perfil           │
│                                 │
│  Para acessar o sistema,        │
│  precisamos de mais algumas     │
│  informações                    │
│                                 │
│  [ CPF: ___.___.___ - __ ]     │
│  [ Telefone: (__) _____-____ ]  │
│  [ CEP: _____-___ ]             │
│  [ Logradouro: __________ ]     │
│  [ Número: ____ ]               │
│  [ Bairro: __________ ]         │
│  [ Cidade: __________ ]         │
│  [ Estado: __ ]                 │
│                                 │
│  [  Completar Cadastro  ]       │
└─────────────────────────────────┘
```

### 8. Endpoint Backend - Update Profile 📝
**Arquivo a criar:** Novo método em `backend/src/controllers/auth.controller.ts`

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
    if (!cpf || !phone_number || !cep) {
      res.status(400).json({
        error: 'INVALID_REQUEST',
        message: 'CPF, phone number, and CEP are required',
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

    res.json({ user: userWithFormattedDate });
  } catch (error) {
    console.error('Complete profile error:', error);
    res.status(500).json({
      error: 'SERVER_ERROR',
      message: 'Internal server error',
    });
  }
};
```

**Adicionar rota:** `backend/src/routes/auth.routes.ts`
```typescript
router.put('/profile/complete', authMiddleware, completeProfile);
```

### 9. Router Guard 📝
**Arquivo a modificar:** `lib/core/router/app_router.dart`

**O que fazer:**
Adicionar lógica de redirecionamento:

```dart
redirect: (context, state) async {
  // Verificar se usuário está autenticado
  final hasToken = await sl.tokenService.hasValidAccessToken();

  if (!hasToken && state.location != '/login') {
    return '/login';
  }

  if (hasToken) {
    // Buscar usuário atual
    final userResult = await sl.authRepository.getCurrentUser();

    return userResult.fold(
      (failure) => '/login',
      (user) {
        // Se perfil incompleto e não está na página de completar
        if (!user.isProfileComplete && state.location != '/complete-profile') {
          return '/complete-profile';
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
```

### 10. Serviço de Atualização de Perfil 📝
**Arquivo a criar:** `lib/domain/usecases/complete_profile.dart`

```dart
class CompleteProfile {
  final AuthRepository repository;

  CompleteProfile(this.repository);

  Future<Either<Failure, User>> call({
    required String cpf,
    required String phoneNumber,
    required String cep,
    required String street,
    required String number,
    String? complement,
    required String neighborhood,
    required String city,
    required String state,
    String? birthDate,
  }) {
    return repository.completeProfile(
      cpf: cpf,
      phoneNumber: phoneNumber,
      cep: cep,
      street: street,
      number: number,
      complement: complement,
      neighborhood: neighborhood,
      city: city,
      state: state,
      birthDate: birthDate,
    );
  }
}
```

---

## 📊 CHECKLIST GERAL

- [x] 1. Banco de dados - coluna `profile_completion_status`
- [x] 2. Entity - enum ProfileCompletionStatus + isProfileComplete
- [ ] 3. UserModel - adicionar campo e serialização
- [ ] 4. Backend loginWithGoogle - definir status 'incomplete'
- [ ] 5. Backend types - adicionar campo ao AuthToken
- [ ] 6. Backend JWT - incluir profile_completion_status
- [ ] 7. Página CompleteProfilePage
- [ ] 8. Endpoint backend completeProfile
- [ ] 9. Router guard para redirecionar perfis incompletos
- [ ] 10. Use case CompleteProfile

---

## 🎯 FLUXO FINAL ESPERADO

1. **Usuário faz login via Google** → Backend cria usuário com `profile_completion_status = 'incomplete'`
2. **Frontend recebe token** → Detecta `isProfileComplete = false`
3. **Router guard redireciona** → `/complete-profile`
4. **Usuário preenche dados** → CPF, telefone, endereço
5. **Submit** → Chama endpoint `PUT /api/auth/profile/complete`
6. **Backend atualiza** → Define `profile_completion_status = 'complete'`
7. **Frontend redireciona** → `/home`
8. **Próximos logins** → Vai direto para `/home`

---

**Progresso Atual:** 2/10 tarefas completas (20%)
**Próximo:** Atualizar UserModel

