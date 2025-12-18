import 'package:cadastro_beneficios/core/network/dio_client.dart';
import 'package:cadastro_beneficios/core/network/api_endpoints.dart';
import 'package:cadastro_beneficios/data/models/auth_token_model.dart';
import 'package:cadastro_beneficios/data/models/user_model.dart';
import 'package:cadastro_beneficios/data/models/registration_response_model.dart';
import 'package:cadastro_beneficios/domain/repositories/auth_repository.dart';

/// DataSource remoto para autenticação
///
/// Responsável por toda comunicação com API de autenticação
abstract class AuthRemoteDataSource {
  Future<AuthTokenModel> loginWithEmail({
    required String email,
    required String password,
  });

  Future<AuthTokenModel> loginWithGoogle({required String idToken});

  Future<AuthTokenModel> register({
    required String name,
    required String email,
    required String password,
    required String phoneNumber,
    String? cpf,
    String? birthDate,
    String? cep,
    String? logradouro,
    String? numero,
    String? complemento,
    String? bairro,
    String? cidade,
    String? estado,
  });

  Future<void> logout();

  Future<void> forgotPassword({required String email});

  Future<void> resetPassword({
    required String token,
    required String newPassword,
  });

  Future<AuthTokenModel> refreshToken({required String refreshToken});

  Future<UserModel> getCurrentUser();

  Future<void> sendVerificationCode({
    required String phoneNumber,
    required VerificationMethod method,
  });

  Future<void> verifyCode({
    required String phoneNumber,
    required String code,
  });

  Future<UserModel> completeProfile({
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
  });

  Future<void> sendVerificationCodeV2(String type);

  Future<void> verifyCodeV2(String type, String code);

  Future<Map<String, bool>> getVerificationStatus();
}

/// Implementação do AuthRemoteDataSource
class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final DioClient _dioClient;

  AuthRemoteDataSourceImpl(this._dioClient);

  @override
  Future<AuthTokenModel> loginWithEmail({
    required String email,
    required String password,
  }) async {
    final response = await _dioClient.post(
      ApiEndpoints.login,
      data: {
        'email': email,
        'password': password,
      },
    );

    return AuthTokenModel.fromJson(response.data);
  }

  @override
  Future<AuthTokenModel> loginWithGoogle({required String idToken}) async {
    final response = await _dioClient.post(
      ApiEndpoints.loginGoogle,
      data: {
        'id_token': idToken,
      },
    );

    return AuthTokenModel.fromJson(response.data);
  }

  @override
  Future<AuthTokenModel> register({
    required String name,
    required String email,
    required String password,
    required String phoneNumber,
    String? cpf,
    String? birthDate,
    String? cep,
    String? logradouro,
    String? numero,
    String? complemento,
    String? bairro,
    String? cidade,
    String? estado,
  }) async {
    final response = await _dioClient.post(
      ApiEndpoints.register,
      data: {
        'name': name,
        'email': email,
        'password': password,
        'phone_number': phoneNumber,
        if (cpf != null) 'cpf': cpf,
        if (birthDate != null) 'birth_date': birthDate,
        if (cep != null) 'cep': cep,
        if (logradouro != null) 'street': logradouro,
        if (numero != null) 'number': numero,
        if (complemento != null) 'complement': complemento,
        if (bairro != null) 'neighborhood': bairro,
        if (cidade != null) 'city': cidade,
        if (estado != null) 'state': estado,
      },
    );

    // Usar RegistrationResponseModel para processar a resposta completa
    final registrationResponse = RegistrationResponseModel.fromJson(response.data);

    // Converter para AuthTokenModel
    return registrationResponse.toAuthToken();
  }

  @override
  Future<void> logout() async {
    await _dioClient.post(ApiEndpoints.logout);
  }

  @override
  Future<void> forgotPassword({required String email}) async {
    await _dioClient.post(
      ApiEndpoints.forgotPassword,
      data: {'email': email},
    );
  }

  @override
  Future<void> resetPassword({
    required String token,
    required String newPassword,
  }) async {
    await _dioClient.post(
      ApiEndpoints.resetPassword,
      data: {
        'token': token,
        'password': newPassword,
      },
    );
  }

  @override
  Future<AuthTokenModel> refreshToken({required String refreshToken}) async {
    final response = await _dioClient.post(
      ApiEndpoints.refreshToken,
      data: {'refresh_token': refreshToken},
    );

    return AuthTokenModel.fromJson(response.data);
  }

  @override
  Future<UserModel> getCurrentUser() async {
    final response = await _dioClient.get(ApiEndpoints.me);

    return UserModel.fromJson(response.data);
  }

  @override
  Future<void> sendVerificationCode({
    required String phoneNumber,
    required VerificationMethod method,
  }) async {
    await _dioClient.post(
      ApiEndpoints.sendVerificationCode,
      data: {
        'phone_number': phoneNumber,
        'method': method == VerificationMethod.sms ? 'sms' : 'whatsapp',
      },
    );
  }

  @override
  Future<void> verifyCode({
    required String phoneNumber,
    required String code,
  }) async {
    await _dioClient.post(
      ApiEndpoints.verifyCode,
      data: {
        'phone_number': phoneNumber,
        'code': code,
      },
    );
  }

  @override
  Future<UserModel> completeProfile({
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
  }) async {
    final response = await _dioClient.put(
      ApiEndpoints.completeProfile,
      data: {
        'cpf': cpf,
        'phone_number': phoneNumber,
        'cep': cep,
        'street': street,
        'number': number,
        'complement': complement,
        'neighborhood': neighborhood,
        'city': city,
        'state': state,
        'birth_date': birthDate,
      },
    );

    return UserModel.fromJson(response.data['user']);
  }

  @override
  Future<void> sendVerificationCodeV2(String type) async {
    await _dioClient.post(
      ApiEndpoints.sendVerificationCode,
      data: {
        'type': type,
      },
    );
  }

  @override
  Future<void> verifyCodeV2(String type, String code) async {
    await _dioClient.post(
      ApiEndpoints.verifyCodeEndpoint,
      data: {
        'type': type,
        'code': code,
      },
    );
  }

  @override
  Future<Map<String, bool>> getVerificationStatus() async {
    final response = await _dioClient.get(
      ApiEndpoints.verificationStatus,
    );

    return {
      'emailVerified': response.data['emailVerified'] as bool? ?? false,
      'phoneVerified': response.data['phoneVerified'] as bool? ?? false,
    };
  }
}
