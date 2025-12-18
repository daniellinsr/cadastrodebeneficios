import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Serviço para gerenciar rascunhos de cadastro
///
/// Salva automaticamente os dados do formulário de cadastro
/// para que o usuário possa continuar de onde parou.
class RegistrationDraftService {
  static const String _draftKey = 'registration_draft';
  static const String _draftTimestampKey = 'registration_draft_timestamp';

  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  /// Salva os dados de identificação
  Future<void> saveIdentificationDraft({
    required String nome,
    required String cpf,
    required String dataNascimento,
    required String celular,
    required String email,
  }) async {
    final draft = await _loadDraft();

    draft['identification'] = {
      'name': nome,
      'cpf': cpf,
      'birthDate': dataNascimento,
      'phoneNumber': celular,
      'email': email,
    };

    await _saveDraft(draft);
  }

  /// Salva os dados de endereço
  Future<void> saveAddressDraft({
    required String cep,
    required String logradouro,
    required String numero,
    String? complemento,
    required String bairro,
    required String cidade,
    required String estado,
  }) async {
    final draft = await _loadDraft();

    draft['address'] = {
      'cep': cep,
      'logradouro': logradouro,
      'numero': numero,
      'complemento': complemento,
      'bairro': bairro,
      'cidade': cidade,
      'estado': estado,
    };

    await _saveDraft(draft);
  }

  /// Carrega os dados de identificação salvos
  Future<Map<String, String>?> loadIdentificationDraft() async {
    final draft = await _loadDraft();

    if (draft.containsKey('identification')) {
      return Map<String, String>.from(draft['identification']);
    }

    return null;
  }

  /// Carrega os dados de endereço salvos
  Future<Map<String, String?>?> loadAddressDraft() async {
    final draft = await _loadDraft();

    if (draft.containsKey('address')) {
      final address = Map<String, dynamic>.from(draft['address']);
      return {
        'cep': address['cep'] as String?,
        'logradouro': address['logradouro'] as String?,
        'numero': address['numero'] as String?,
        'complemento': address['complemento'] as String?,
        'bairro': address['bairro'] as String?,
        'cidade': address['cidade'] as String?,
        'estado': address['estado'] as String?,
      };
    }

    return null;
  }

  /// Verifica se existe um rascunho salvo
  Future<bool> hasDraft() async {
    try {
      final draftJson = await _storage.read(key: _draftKey);
      return draftJson != null && draftJson.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  /// Retorna a data/hora do último salvamento
  Future<DateTime?> getDraftTimestamp() async {
    try {
      final timestampStr = await _storage.read(key: _draftTimestampKey);
      if (timestampStr != null) {
        return DateTime.parse(timestampStr);
      }
    } catch (e) {
      return null;
    }
    return null;
  }

  /// Limpa o rascunho salvo
  Future<void> clearDraft() async {
    await _storage.delete(key: _draftKey);
    await _storage.delete(key: _draftTimestampKey);
  }

  /// Verifica se o rascunho expirou (7 dias)
  Future<bool> isDraftExpired() async {
    final timestamp = await getDraftTimestamp();
    if (timestamp == null) return true;

    final now = DateTime.now();
    final difference = now.difference(timestamp);

    return difference.inDays > 7;
  }

  /// Carrega todo o rascunho
  Future<Map<String, dynamic>> _loadDraft() async {
    try {
      final draftJson = await _storage.read(key: _draftKey);

      if (draftJson != null && draftJson.isNotEmpty) {
        return Map<String, dynamic>.from(json.decode(draftJson));
      }
    } catch (e) {
      // Se houver erro ao ler, retorna um mapa vazio
      return {};
    }

    return {};
  }

  /// Salva o rascunho completo
  Future<void> _saveDraft(Map<String, dynamic> draft) async {
    try {
      final draftJson = json.encode(draft);
      await _storage.write(key: _draftKey, value: draftJson);

      // Salva timestamp
      final timestamp = DateTime.now().toIso8601String();
      await _storage.write(key: _draftTimestampKey, value: timestamp);
    } catch (e) {
      // Ignora erros de salvamento
    }
  }

  /// Retorna um resumo do rascunho para exibir ao usuário
  Future<String?> getDraftSummary() async {
    final draft = await _loadDraft();

    if (draft.isEmpty) return null;

    final identification = draft['identification'];
    if (identification != null && identification['name'] != null) {
      final nome = identification['name'] as String;
      final timestamp = await getDraftTimestamp();

      if (timestamp != null) {
        final now = DateTime.now();
        final difference = now.difference(timestamp);

        String timeAgo;
        if (difference.inMinutes < 1) {
          timeAgo = 'agora mesmo';
        } else if (difference.inMinutes < 60) {
          timeAgo = 'há ${difference.inMinutes} minuto${difference.inMinutes > 1 ? 's' : ''}';
        } else if (difference.inHours < 24) {
          timeAgo = 'há ${difference.inHours} hora${difference.inHours > 1 ? 's' : ''}';
        } else {
          timeAgo = 'há ${difference.inDays} dia${difference.inDays > 1 ? 's' : ''}';
        }

        return 'Cadastro de $nome iniciado $timeAgo';
      }

      return 'Cadastro de $nome em andamento';
    }

    return null;
  }

  /// Obtém o progresso do cadastro (0-100%)
  Future<int> getDraftProgress() async {
    final draft = await _loadDraft();

    if (draft.isEmpty) return 0;

    int completedSteps = 0;
    const totalSteps = 2; // Identificação e Endereço (senha não é salva)

    if (draft.containsKey('identification')) {
      final identification = draft['identification'];
      if (identification != null &&
          identification['name'] != null &&
          identification['name'].toString().isNotEmpty) {
        completedSteps++;
      }
    }

    if (draft.containsKey('address')) {
      final address = draft['address'];
      if (address != null &&
          address['cep'] != null &&
          address['cep'].toString().isNotEmpty) {
        completedSteps++;
      }
    }

    return ((completedSteps / totalSteps) * 100).round();
  }
}
