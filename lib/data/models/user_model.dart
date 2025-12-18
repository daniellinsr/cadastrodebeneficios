import 'package:json_annotation/json_annotation.dart';
import 'package:cadastro_beneficios/domain/entities/user.dart';

part 'user_model.g.dart';

/// Model do User - Conversão JSON <-> Entity
///
/// Usado para serialização/deserialização de dados da API
@JsonSerializable()
class UserModel {
  final String id;
  final String name;
  final String email;
  @JsonKey(name: 'phone_number')
  final String? phoneNumber;
  final String? cpf;
  @JsonKey(name: 'photo_url')
  final String? photoUrl;
  final String role;
  @JsonKey(name: 'created_at')
  final DateTime createdAt;
  @JsonKey(name: 'updated_at')
  final DateTime? updatedAt;
  @JsonKey(name: 'is_email_verified')
  final bool isEmailVerified;
  @JsonKey(name: 'is_phone_verified')
  final bool isPhoneVerified;
  @JsonKey(name: 'profile_completion_status')
  final String? profileCompletionStatus;

  UserModel({
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
    this.profileCompletionStatus,
  });

  /// Criar UserModel a partir de JSON
  factory UserModel.fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(json);

  /// Converter UserModel para JSON
  Map<String, dynamic> toJson() => _$UserModelToJson(this);

  /// Converter Model para Entity (Domain)
  User toEntity() {
    return User(
      id: id,
      name: name,
      email: email,
      phoneNumber: phoneNumber,
      cpf: cpf,
      photoUrl: photoUrl,
      role: UserRoleExtension.fromString(role),
      createdAt: createdAt,
      updatedAt: updatedAt,
      isEmailVerified: isEmailVerified,
      isPhoneVerified: isPhoneVerified,
      profileCompletionStatus: ProfileCompletionStatusExtension.fromString(
        profileCompletionStatus ?? 'complete',
      ),
    );
  }

  /// Criar Model a partir de Entity (Domain)
  factory UserModel.fromEntity(User user) {
    return UserModel(
      id: user.id,
      name: user.name,
      email: user.email,
      phoneNumber: user.phoneNumber,
      cpf: user.cpf,
      photoUrl: user.photoUrl,
      role: user.role.value,
      createdAt: user.createdAt,
      updatedAt: user.updatedAt,
      isEmailVerified: user.isEmailVerified,
      isPhoneVerified: user.isPhoneVerified,
      profileCompletionStatus: user.profileCompletionStatus.value,
    );
  }
}
