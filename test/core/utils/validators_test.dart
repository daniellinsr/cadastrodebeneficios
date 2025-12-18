import 'package:flutter_test/flutter_test.dart';
import 'package:cadastro_beneficios/core/utils/validators.dart';

void main() {
  group('Validators.validateNome', () {
    test('deve retornar erro quando nome estiver vazio', () {
      expect(Validators.validateNome(''), isNotNull);
      expect(Validators.validateNome(null), isNotNull);
      expect(Validators.validateNome('   '), isNotNull);
    });

    test('deve retornar erro quando nome tiver menos de 3 caracteres', () {
      expect(Validators.validateNome('Jo'), isNotNull);
      expect(Validators.validateNome('A'), isNotNull);
    });

    test('deve retornar erro quando não tiver sobrenome', () {
      expect(Validators.validateNome('João'), isNotNull);
      expect(Validators.validateNome('Maria'), isNotNull);
    });

    test('deve retornar erro quando tiver apenas espaços', () {
      expect(Validators.validateNome('João  '), isNotNull);
      expect(Validators.validateNome('  Silva'), isNotNull);
    });

    test('deve retornar null quando nome for válido', () {
      expect(Validators.validateNome('João Silva'), isNull);
      expect(Validators.validateNome('Maria da Silva Santos'), isNull);
      expect(Validators.validateNome('José Carlos'), isNull);
    });
  });

  group('Validators.validateCPF', () {
    test('deve retornar erro quando CPF estiver vazio', () {
      expect(Validators.validateCPF(''), isNotNull);
      expect(Validators.validateCPF(null), isNotNull);
    });

    test('deve retornar erro quando CPF tiver menos de 11 dígitos', () {
      expect(Validators.validateCPF('123456789'), isNotNull);
      expect(Validators.validateCPF('12345'), isNotNull);
    });

    test('deve retornar erro quando CPF tiver mais de 11 dígitos', () {
      expect(Validators.validateCPF('123456789012'), isNotNull);
    });

    test('deve retornar erro quando todos os dígitos forem iguais', () {
      expect(Validators.validateCPF('11111111111'), isNotNull);
      expect(Validators.validateCPF('111.111.111-11'), isNotNull);
      expect(Validators.validateCPF('00000000000'), isNotNull);
    });

    test('deve retornar erro quando CPF for inválido', () {
      expect(Validators.validateCPF('12345678900'), isNotNull);
      expect(Validators.validateCPF('123.456.789-00'), isNotNull);
      // Removido 98765432100 pois esse CPF é válido
    });

    test('deve retornar null quando CPF for válido', () {
      expect(Validators.validateCPF('12345678909'), isNull);
      expect(Validators.validateCPF('123.456.789-09'), isNull);
      expect(Validators.validateCPF('11144477735'), isNull);
      expect(Validators.validateCPF('111.444.777-35'), isNull);
    });
  });

  group('Validators.validateDataNascimento', () {
    test('deve retornar erro quando data estiver vazia', () {
      expect(Validators.validateDataNascimento(''), isNotNull);
      expect(Validators.validateDataNascimento(null), isNotNull);
    });

    test('deve retornar erro quando data tiver formato inválido', () {
      expect(Validators.validateDataNascimento('1234'), isNotNull);
      expect(Validators.validateDataNascimento('12345678901'), isNotNull);
    });

    test('deve retornar erro quando mês for inválido', () {
      expect(Validators.validateDataNascimento('15/13/2000'), isNotNull);
      expect(Validators.validateDataNascimento('15/00/2000'), isNotNull);
    });

    test('deve retornar erro quando dia for inválido', () {
      expect(Validators.validateDataNascimento('00/06/2000'), isNotNull);
      expect(Validators.validateDataNascimento('32/06/2000'), isNotNull);
    });

    test('deve retornar erro quando dia for inválido para o mês', () {
      expect(Validators.validateDataNascimento('31/04/2000'), isNotNull);
      expect(Validators.validateDataNascimento('31/06/2000'), isNotNull);
    });

    test('deve validar corretamente fevereiro em ano não bissexto', () {
      expect(Validators.validateDataNascimento('29/02/2023'), isNotNull);
    });

    test('deve validar corretamente fevereiro em ano bissexto', () {
      // 2000 tem 25 anos agora, então é válido
      expect(Validators.validateDataNascimento('29/02/2000'), isNull);
      // 2004 tem 21 anos, também é válido
      expect(Validators.validateDataNascimento('29/02/2004'), isNull);
    });

    test('deve retornar erro quando data for futura', () {
      final futureDate =
          DateTime.now().add(const Duration(days: 1));
      final dateStr =
          '${futureDate.day.toString().padLeft(2, '0')}/${futureDate.month.toString().padLeft(2, '0')}/${futureDate.year}';
      expect(Validators.validateDataNascimento(dateStr), isNotNull);
    });

    test('deve retornar erro quando idade for menor que 18 anos', () {
      final now = DateTime.now();
      final date17YearsAgo = DateTime(now.year - 17, now.month, now.day);
      final dateStr =
          '${date17YearsAgo.day.toString().padLeft(2, '0')}/${date17YearsAgo.month.toString().padLeft(2, '0')}/${date17YearsAgo.year}';
      expect(Validators.validateDataNascimento(dateStr), isNotNull);
    });

    test('deve retornar null quando idade for exatamente 18 anos', () {
      final now = DateTime.now();
      final date18YearsAgo = DateTime(now.year - 18, now.month, now.day);
      final dateStr =
          '${date18YearsAgo.day.toString().padLeft(2, '0')}/${date18YearsAgo.month.toString().padLeft(2, '0')}/${date18YearsAgo.year}';
      expect(Validators.validateDataNascimento(dateStr), isNull);
    });

    test('deve retornar null quando data for válida', () {
      expect(Validators.validateDataNascimento('15/06/2000'), isNull);
      expect(Validators.validateDataNascimento('01/01/1990'), isNull);
      expect(Validators.validateDataNascimento('31/12/1985'), isNull);
    });
  });

  group('Validators.validateCelular', () {
    test('deve retornar erro quando celular estiver vazio', () {
      expect(Validators.validateCelular(''), isNotNull);
      expect(Validators.validateCelular(null), isNotNull);
    });

    test('deve retornar erro quando celular tiver menos de 11 dígitos', () {
      expect(Validators.validateCelular('1199999999'), isNotNull);
      expect(Validators.validateCelular('119999'), isNotNull);
    });

    test('deve retornar erro quando DDD for inválido', () {
      expect(Validators.validateCelular('0199999999'), isNotNull);
      expect(Validators.validateCelular('(01) 99999-9999'), isNotNull);
    });

    test('deve retornar erro quando não começar com 9', () {
      expect(Validators.validateCelular('11899999999'), isNotNull);
      expect(Validators.validateCelular('(11) 89999-9999'), isNotNull);
    });

    test('deve retornar null quando celular for válido', () {
      expect(Validators.validateCelular('11999999999'), isNull);
      expect(Validators.validateCelular('(11) 99999-9999'), isNull);
      expect(Validators.validateCelular('21987654321'), isNull);
      expect(Validators.validateCelular('(21) 98765-4321'), isNull);
    });
  });

  group('Validators.validateEmail', () {
    test('deve retornar erro quando email estiver vazio', () {
      expect(Validators.validateEmail(''), isNotNull);
      expect(Validators.validateEmail(null), isNotNull);
      expect(Validators.validateEmail('   '), isNotNull);
    });

    test('deve retornar erro quando email for inválido', () {
      expect(Validators.validateEmail('joao'), isNotNull);
      expect(Validators.validateEmail('joao@'), isNotNull);
      expect(Validators.validateEmail('joao@dominio'), isNotNull);
      expect(Validators.validateEmail('@dominio.com'), isNotNull);
      expect(Validators.validateEmail('joao@.com'), isNotNull);
    });

    test('deve retornar null quando email for válido', () {
      expect(Validators.validateEmail('joao@dominio.com'), isNull);
      expect(Validators.validateEmail('joao.silva@empresa.com.br'), isNull);
      expect(Validators.validateEmail('usuario+teste@email.com'), isNull);
      expect(Validators.validateEmail('teste_123@dominio.org'), isNull);
    });
  });

  group('Validators.validateCEP', () {
    test('deve retornar erro quando CEP estiver vazio', () {
      expect(Validators.validateCEP(''), isNotNull);
      expect(Validators.validateCEP(null), isNotNull);
    });

    test('deve retornar erro quando CEP tiver menos de 8 dígitos', () {
      expect(Validators.validateCEP('0131010'), isNotNull);
      expect(Validators.validateCEP('12345'), isNotNull);
    });

    test('deve retornar null quando CEP for válido', () {
      expect(Validators.validateCEP('01310100'), isNull);
      expect(Validators.validateCEP('01310-100'), isNull);
      expect(Validators.validateCEP('12345678'), isNull);
    });
  });

  group('Validators.validateLogradouro', () {
    test('deve retornar erro quando logradouro estiver vazio', () {
      expect(Validators.validateLogradouro(''), isNotNull);
      expect(Validators.validateLogradouro(null), isNotNull);
      expect(Validators.validateLogradouro('   '), isNotNull);
    });

    test('deve retornar erro quando logradouro tiver menos de 3 caracteres',
        () {
      expect(Validators.validateLogradouro('Ru'), isNotNull);
      expect(Validators.validateLogradouro('A'), isNotNull);
    });

    test('deve retornar null quando logradouro for válido', () {
      expect(Validators.validateLogradouro('Rua das Flores'), isNull);
      expect(Validators.validateLogradouro('Avenida Paulista'), isNull);
      expect(Validators.validateLogradouro('Travessa A'), isNull);
    });
  });

  group('Validators.validateNumero', () {
    test('deve retornar erro quando número estiver vazio', () {
      expect(Validators.validateNumero(''), isNotNull);
      expect(Validators.validateNumero(null), isNotNull);
      expect(Validators.validateNumero('   '), isNotNull);
    });

    test('deve retornar erro quando não tiver dígitos', () {
      expect(Validators.validateNumero('ABC'), isNotNull);
      expect(Validators.validateNumero('sem numero'), isNotNull);
    });

    test('deve retornar null quando for S/N', () {
      expect(Validators.validateNumero('S/N'), isNull);
      expect(Validators.validateNumero('s/n'), isNull);
      expect(Validators.validateNumero('S/n'), isNull);
    });

    test('deve retornar null quando número for válido', () {
      expect(Validators.validateNumero('123'), isNull);
      expect(Validators.validateNumero('123A'), isNull);
      expect(Validators.validateNumero('Lote 5'), isNull);
    });
  });

  group('Validators.validateBairro', () {
    test('deve retornar erro quando bairro estiver vazio', () {
      expect(Validators.validateBairro(''), isNotNull);
      expect(Validators.validateBairro(null), isNotNull);
      expect(Validators.validateBairro('   '), isNotNull);
    });

    test('deve retornar erro quando bairro tiver menos de 2 caracteres', () {
      expect(Validators.validateBairro('A'), isNotNull);
    });

    test('deve retornar null quando bairro for válido', () {
      expect(Validators.validateBairro('Centro'), isNull);
      expect(Validators.validateBairro('Vila Nova'), isNull);
      expect(Validators.validateBairro('Jardim América'), isNull);
    });
  });

  group('Validators.validateCidade', () {
    test('deve retornar erro quando cidade estiver vazia', () {
      expect(Validators.validateCidade(''), isNotNull);
      expect(Validators.validateCidade(null), isNotNull);
      expect(Validators.validateCidade('   '), isNotNull);
    });

    test('deve retornar erro quando cidade tiver menos de 2 caracteres', () {
      expect(Validators.validateCidade('A'), isNotNull);
    });

    test('deve retornar null quando cidade for válida', () {
      expect(Validators.validateCidade('São Paulo'), isNull);
      expect(Validators.validateCidade('Rio de Janeiro'), isNull);
      expect(Validators.validateCidade('Belo Horizonte'), isNull);
    });
  });

  group('Validators.validateEstado', () {
    test('deve retornar erro quando estado estiver vazio', () {
      expect(Validators.validateEstado(''), isNotNull);
      expect(Validators.validateEstado(null), isNotNull);
      expect(Validators.validateEstado('   '), isNotNull);
    });

    test('deve retornar erro quando UF for inválida', () {
      expect(Validators.validateEstado('XX'), isNotNull);
      expect(Validators.validateEstado('ZZ'), isNotNull);
      expect(Validators.validateEstado('AB'), isNotNull);
    });

    test('deve retornar null quando UF for válida', () {
      expect(Validators.validateEstado('SP'), isNull);
      expect(Validators.validateEstado('RJ'), isNull);
      expect(Validators.validateEstado('MG'), isNull);
      expect(Validators.validateEstado('RS'), isNull);
      expect(Validators.validateEstado('DF'), isNull);
      // Testa maiúsculas e minúsculas
      expect(Validators.validateEstado('sp'), isNull);
      expect(Validators.validateEstado('Sp'), isNull);
    });

    test('deve validar todos os 27 estados', () {
      const ufsValidas = [
        'AC',
        'AL',
        'AP',
        'AM',
        'BA',
        'CE',
        'DF',
        'ES',
        'GO',
        'MA',
        'MT',
        'MS',
        'MG',
        'PA',
        'PB',
        'PR',
        'PE',
        'PI',
        'RJ',
        'RN',
        'RS',
        'RO',
        'RR',
        'SC',
        'SP',
        'SE',
        'TO'
      ];

      for (final uf in ufsValidas) {
        expect(Validators.validateEstado(uf), isNull,
            reason: 'UF $uf deve ser válida');
      }
    });
  });

  group('Validators.validateSenha', () {
    test('deve retornar erro quando senha estiver vazia', () {
      expect(Validators.validateSenha(''), isNotNull);
      expect(Validators.validateSenha(null), isNotNull);
    });

    test('deve retornar erro quando senha tiver menos de 8 caracteres', () {
      expect(Validators.validateSenha('Abc12!'), isNotNull);
      expect(Validators.validateSenha('Pass1!'), isNotNull);
    });

    test('deve retornar erro quando não tiver letra maiúscula', () {
      expect(Validators.validateSenha('password123!'), isNotNull);
    });

    test('deve retornar erro quando não tiver letra minúscula', () {
      expect(Validators.validateSenha('PASSWORD123!'), isNotNull);
    });

    test('deve retornar erro quando não tiver número', () {
      expect(Validators.validateSenha('Password!'), isNotNull);
    });

    test('deve retornar erro quando não tiver caractere especial', () {
      expect(Validators.validateSenha('Password123'), isNotNull);
    });

    test('deve retornar null quando senha for válida', () {
      expect(Validators.validateSenha('Password123!'), isNull);
      expect(Validators.validateSenha('Senh@Forte123'), isNull);
      expect(Validators.validateSenha('M1nh@S3nh@'), isNull);
    });
  });

  group('Validators.validateConfirmacaoSenha', () {
    test('deve retornar erro quando confirmação estiver vazia', () {
      expect(Validators.validateConfirmacaoSenha('', 'Password123!'),
          isNotNull);
      expect(Validators.validateConfirmacaoSenha(null, 'Password123!'),
          isNotNull);
    });

    test('deve retornar erro quando senhas não coincidirem', () {
      expect(Validators.validateConfirmacaoSenha(
              'Password123!', 'Password123'),
          isNotNull);
      expect(Validators.validateConfirmacaoSenha('Senha1!', 'Senha2!'),
          isNotNull);
    });

    test('deve retornar null quando senhas coincidirem', () {
      expect(
          Validators.validateConfirmacaoSenha('Password123!', 'Password123!'),
          isNull);
      expect(Validators.validateConfirmacaoSenha('Senha@123', 'Senha@123'),
          isNull);
    });
  });

  group('Validators.calculatePasswordStrength', () {
    test('deve retornar 0 para senha vazia', () {
      expect(Validators.calculatePasswordStrength(''), 0);
    });

    test('deve calcular força corretamente para senha só com letras minúsculas', () {
      // 8+ caracteres (1) + minúsculas (1) = 2
      expect(Validators.calculatePasswordStrength('password'), 2);
    });

    test('deve calcular força para senha com minúsculas e números', () {
      // 8+ caracteres (1) + minúsculas (1) + números (1) = 3
      expect(Validators.calculatePasswordStrength('password1'), 3);
    });

    test('deve calcular força para senha com mai, min e números', () {
      // 8+ caracteres (1) + minúsculas (1) + maiúsculas (1) + números (1) = 4
      expect(Validators.calculatePasswordStrength('Password1'), 4);
    });

    test('deve calcular força para senha com todos os tipos', () {
      // 8+ caracteres (1) + minúsculas (1) + maiúsculas (1) + números (1) + especiais (1) = 5
      expect(Validators.calculatePasswordStrength('Password1!'), 5);
    });

    test('deve retornar 5 (máximo) para senhas muito fortes', () {
      // 8+ (1) + 12+ (1) + minúsculas (1) + maiúsculas (1) + números (1) + especiais (1) = 6, mas max é 5
      expect(Validators.calculatePasswordStrength('Password123!'), 5);
      expect(Validators.calculatePasswordStrength('M1nh@S3nh@F0rt3!'), 5);
    });

    test('deve considerar comprimento >= 12 como ponto extra', () {
      // Pass1! tem 6 caracteres: não atinge 8, então 0 + min (1) + mai (1) + num (1) + esp (1) = 4
      expect(Validators.calculatePasswordStrength('Pass1!'), 4);
      // Password123! tem 12: 8+ (1) + 12+ (1) + min (1) + mai (1) + num (1) + esp (1) = 6, max 5
      expect(Validators.calculatePasswordStrength('Password123!'), 5);
    });
  });

  group('Validators.getPasswordStrengthText', () {
    test('deve retornar texto correto para cada nível', () {
      expect(Validators.getPasswordStrengthText(0), '');
      expect(Validators.getPasswordStrengthText(1), 'Muito fraca');
      expect(Validators.getPasswordStrengthText(2), 'Fraca');
      expect(Validators.getPasswordStrengthText(3), 'Média');
      expect(Validators.getPasswordStrengthText(4), 'Forte');
      expect(Validators.getPasswordStrengthText(5), 'Muito forte');
    });
  });
}
