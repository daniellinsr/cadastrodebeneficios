import 'package:equatable/equatable.dart';

/// Entidade User - Representa um usuário autenticado no sistema
///
/// Esta é uma entidade de domínio pura, sem dependências de frameworks
class User extends Equatable {
  final String id;
  final String name;
  final String email;
  final String? phoneNumber;
  final String? cpf;
  final String? photoUrl;
  final UserRole role;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final bool isEmailVerified;
  final bool isPhoneVerified;
  final ProfileCompletionStatus profileCompletionStatus;

  const User({
    required this.id,
    required this.name,
    required this.email,
    this.phoneNumber,
    this.cpf,
    this.photoUrl,
    required this.role,
    required this.createdAt,
    this.updatedAt,
    this.isEmailVerified = false,
    this.isPhoneVerified = false,
    this.profileCompletionStatus = ProfileCompletionStatus.complete,
  });

  /// Verifica se o perfil está completo
  bool get isProfileComplete => profileCompletionStatus == ProfileCompletionStatus.complete;

  /// Cria cópia do usuário com campos atualizados
  User copyWith({
    String? id,
    String? name,
    String? email,
    String? phoneNumber,
    String? cpf,
    String? photoUrl,
    UserRole? role,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isEmailVerified,
    bool? isPhoneVerified,
    ProfileCompletionStatus? profileCompletionStatus,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      cpf: cpf ?? this.cpf,
      photoUrl: photoUrl ?? this.photoUrl,
      role: role ?? this.role,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isEmailVerified: isEmailVerified ?? this.isEmailVerified,
      isPhoneVerified: isPhoneVerified ?? this.isPhoneVerified,
      profileCompletionStatus: profileCompletionStatus ?? this.profileCompletionStatus,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        email,
        phoneNumber,
        cpf,
        photoUrl,
        role,
        createdAt,
        updatedAt,
        isEmailVerified,
        isPhoneVerified,
        profileCompletionStatus,
      ];
}

/// Papel do usuário no sistema
enum UserRole {
  admin,       // Administrador (acesso total)
  beneficiary, // Beneficiário (usuário padrão)
  partner,     // Parceiro (clínicas, farmácias, etc)
}

/// Status de completude do perfil
enum ProfileCompletionStatus {
  incomplete, // Perfil incompleto (faltam dados obrigatórios)
  complete,   // Perfil completo (todos dados obrigatórios preenchidos)
}

/// Extensão para facilitar conversão e display
extension UserRoleExtension on UserRole {
  String get displayName {
    switch (this) {
      case UserRole.admin:
        return 'Administrador';
      case UserRole.beneficiary:
        return 'Beneficiário';
      case UserRole.partner:
        return 'Parceiro';
    }
  }

  String get value {
    switch (this) {
      case UserRole.admin:
        return 'admin';
      case UserRole.beneficiary:
        return 'beneficiary';
      case UserRole.partner:
        return 'partner';
    }
  }

  static UserRole fromString(String value) {
    switch (value.toLowerCase()) {
      case 'admin':
        return UserRole.admin;
      case 'beneficiary':
        return UserRole.beneficiary;
      case 'partner':
        return UserRole.partner;
      default:
        return UserRole.beneficiary; // Default
    }
  }
}

/// Extensão para ProfileCompletionStatus
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
        return ProfileCompletionStatus.complete; // Default seguro
    }
  }
}
