import 'dart:convert';
import 'package:http/http.dart' as http;

/// Modelo de dados do endereço retornado pela API ViaCEP
class ViaCepAddress {
  final String cep;
  final String logradouro;
  final String complemento;
  final String bairro;
  final String localidade;
  final String uf;
  final String ibge;
  final String gia;
  final String ddd;
  final String siafi;
  final bool erro;

  ViaCepAddress({
    required this.cep,
    required this.logradouro,
    required this.complemento,
    required this.bairro,
    required this.localidade,
    required this.uf,
    required this.ibge,
    required this.gia,
    required this.ddd,
    required this.siafi,
    this.erro = false,
  });

  factory ViaCepAddress.fromJson(Map<String, dynamic> json) {
    return ViaCepAddress(
      cep: json['cep'] ?? '',
      logradouro: json['logradouro'] ?? '',
      complemento: json['complemento'] ?? '',
      bairro: json['bairro'] ?? '',
      localidade: json['localidade'] ?? '',
      uf: json['uf'] ?? '',
      ibge: json['ibge'] ?? '',
      gia: json['gia'] ?? '',
      ddd: json['ddd'] ?? '',
      siafi: json['siafi'] ?? '',
      erro: json['erro'] == true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'cep': cep,
      'logradouro': logradouro,
      'complemento': complemento,
      'bairro': bairro,
      'localidade': localidade,
      'uf': uf,
      'ibge': ibge,
      'gia': gia,
      'ddd': ddd,
      'siafi': siafi,
      'erro': erro,
    };
  }
}

/// Serviço para buscar endereço por CEP usando a API ViaCEP
class ViaCepService {
  static const String _baseUrl = 'https://viacep.com.br/ws';

  /// Busca endereço por CEP
  ///
  /// Retorna um [ViaCepAddress] com os dados do endereço ou null em caso de erro
  ///
  /// Exemplo:
  /// ```dart
  /// final address = await ViaCepService.fetchAddress('01310100');
  /// if (address != null && !address.erro) {
  ///   print('Rua: ${address.logradouro}');
  /// }
  /// ```
  static Future<ViaCepAddress?> fetchAddress(String cep) async {
    try {
      // Remove caracteres não numéricos
      final cleanCep = cep.replaceAll(RegExp(r'[^0-9]'), '');

      // Valida formato do CEP
      if (cleanCep.length != 8) {
        return null;
      }

      // Faz a requisição
      final url = Uri.parse('$_baseUrl/$cleanCep/json/');
      final response = await http.get(url).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw Exception('Timeout ao buscar CEP');
        },
      );

      // Verifica se a resposta foi bem-sucedida
      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        // Verifica se a API retornou erro
        if (data['erro'] == true) {
          return ViaCepAddress(
            cep: cleanCep,
            logradouro: '',
            complemento: '',
            bairro: '',
            localidade: '',
            uf: '',
            ibge: '',
            gia: '',
            ddd: '',
            siafi: '',
            erro: true,
          );
        }

        return ViaCepAddress.fromJson(data);
      }

      return null;
    } catch (e) {
      // Em caso de erro, retorna null
      // TODO: Usar logger em vez de print
      return null;
    }
  }

  /// Verifica se o CEP existe
  ///
  /// Retorna true se o CEP existe, false caso contrário
  static Future<bool> cepExists(String cep) async {
    final address = await fetchAddress(cep);
    return address != null && !address.erro;
  }

  /// Formata o CEP no padrão 00000-000
  static String formatCep(String cep) {
    final cleanCep = cep.replaceAll(RegExp(r'[^0-9]'), '');

    if (cleanCep.length != 8) {
      return cep;
    }

    return '${cleanCep.substring(0, 5)}-${cleanCep.substring(5)}';
  }
}
