import 'package:flutter_test/flutter_test.dart';
import 'package:cadastro_beneficios/core/utils/input_formatters.dart';

void main() {
  group('CpfInputFormatter', () {
    late CpfInputFormatter formatter;

    setUp(() {
      formatter = CpfInputFormatter();
    });

    test('deve formatar CPF com máscara', () {
      const oldValue = TextEditingValue(text: '');
      const newValue = TextEditingValue(text: '12345678909');

      final result = formatter.formatEditUpdate(oldValue, newValue);

      expect(result.text, '123.456.789-09');
    });

    test('deve formatar parcialmente enquanto digita', () {
      const oldValue = TextEditingValue(text: '');
      const newValue = TextEditingValue(text: '123');

      final result = formatter.formatEditUpdate(oldValue, newValue);

      expect(result.text, '123');
    });

    test('deve adicionar ponto após 3 dígitos', () {
      const oldValue = TextEditingValue(text: '123');
      const newValue = TextEditingValue(text: '1234');

      final result = formatter.formatEditUpdate(oldValue, newValue);

      expect(result.text, '123.4');
    });

    test('deve adicionar segundo ponto após 6 dígitos', () {
      const oldValue = TextEditingValue(text: '123.456');
      const newValue = TextEditingValue(text: '1234567');

      final result = formatter.formatEditUpdate(oldValue, newValue);

      expect(result.text, '123.456.7');
    });

    test('deve adicionar traço após 9 dígitos', () {
      const oldValue = TextEditingValue(text: '123.456.789');
      const newValue = TextEditingValue(text: '123456789');

      final result = formatter.formatEditUpdate(oldValue, newValue);

      expect(result.text, '123.456.789');

      const newValue2 = TextEditingValue(text: '1234567890');
      final result2 = formatter.formatEditUpdate(result, newValue2);

      expect(result2.text, '123.456.789-0');
    });

    test('não deve permitir mais de 11 dígitos', () {
      const oldValue = TextEditingValue(text: '123.456.789-09');
      const newValue = TextEditingValue(text: '123456789091');

      final result = formatter.formatEditUpdate(oldValue, newValue);

      expect(result.text, '123.456.789-09');
    });

    test('deve remover caracteres não numéricos', () {
      const oldValue = TextEditingValue(text: '');
      const newValue = TextEditingValue(text: '123abc456');

      final result = formatter.formatEditUpdate(oldValue, newValue);

      expect(result.text, '123.456');
    });
  });

  group('DateInputFormatter', () {
    late DateInputFormatter formatter;

    setUp(() {
      formatter = DateInputFormatter();
    });

    test('deve formatar data com máscara', () {
      const oldValue = TextEditingValue(text: '');
      const newValue = TextEditingValue(text: '15062000');

      final result = formatter.formatEditUpdate(oldValue, newValue);

      expect(result.text, '15/06/2000');
    });

    test('deve adicionar barra após 2 dígitos', () {
      const oldValue = TextEditingValue(text: '15');
      const newValue = TextEditingValue(text: '156');

      final result = formatter.formatEditUpdate(oldValue, newValue);

      expect(result.text, '15/6');
    });

    test('deve adicionar segunda barra após 4 dígitos', () {
      const oldValue = TextEditingValue(text: '15/06');
      const newValue = TextEditingValue(text: '15062');

      final result = formatter.formatEditUpdate(oldValue, newValue);

      expect(result.text, '15/06/2');
    });

    test('não deve permitir mais de 8 dígitos', () {
      const oldValue = TextEditingValue(text: '15/06/2000');
      const newValue = TextEditingValue(text: '150620001');

      final result = formatter.formatEditUpdate(oldValue, newValue);

      expect(result.text, '15/06/2000');
    });

    test('deve remover caracteres não numéricos', () {
      const oldValue = TextEditingValue(text: '');
      const newValue = TextEditingValue(text: '15abc06');

      final result = formatter.formatEditUpdate(oldValue, newValue);

      expect(result.text, '15/06');
    });
  });

  group('PhoneInputFormatter', () {
    late PhoneInputFormatter formatter;

    setUp(() {
      formatter = PhoneInputFormatter();
    });

    test('deve formatar telefone com máscara', () {
      const oldValue = TextEditingValue(text: '');
      const newValue = TextEditingValue(text: '11999999999');

      final result = formatter.formatEditUpdate(oldValue, newValue);

      expect(result.text, '(11) 99999-9999');
    });

    test('deve adicionar parênteses no início', () {
      const oldValue = TextEditingValue(text: '');
      const newValue = TextEditingValue(text: '1');

      final result = formatter.formatEditUpdate(oldValue, newValue);

      expect(result.text, '(1');
    });

    test('deve adicionar parêntese de fechamento e espaço após DDD', () {
      const oldValue = TextEditingValue(text: '(11');
      const newValue = TextEditingValue(text: '119');

      final result = formatter.formatEditUpdate(oldValue, newValue);

      expect(result.text, '(11) 9');
    });

    test('deve adicionar traço após 5 dígitos do número', () {
      const oldValue = TextEditingValue(text: '(11) 99999');
      const newValue = TextEditingValue(text: '1199999');

      final result = formatter.formatEditUpdate(oldValue, newValue);

      // O formatter já adiciona o traço quando tem 7 dígitos
      expect(result.text, '(11) 99999-');

      const newValue2 = TextEditingValue(text: '11999999');
      final result2 = formatter.formatEditUpdate(oldValue, newValue2);

      expect(result2.text, '(11) 99999-9');
    });

    test('não deve permitir mais de 11 dígitos', () {
      const oldValue = TextEditingValue(text: '(11) 99999-9999');
      const newValue = TextEditingValue(text: '119999999991');

      final result = formatter.formatEditUpdate(oldValue, newValue);

      expect(result.text, '(11) 99999-9999');
    });

    test('deve remover caracteres não numéricos', () {
      const oldValue = TextEditingValue(text: '');
      const newValue = TextEditingValue(text: '11abc999');

      final result = formatter.formatEditUpdate(oldValue, newValue);

      expect(result.text, '(11) 999');
    });
  });

  group('CepInputFormatter', () {
    late CepInputFormatter formatter;

    setUp(() {
      formatter = CepInputFormatter();
    });

    test('deve formatar CEP com máscara', () {
      const oldValue = TextEditingValue(text: '');
      const newValue = TextEditingValue(text: '01310100');

      final result = formatter.formatEditUpdate(oldValue, newValue);

      expect(result.text, '01310-100');
    });

    test('deve adicionar traço após 5 dígitos', () {
      const oldValue = TextEditingValue(text: '01310');
      const newValue = TextEditingValue(text: '013101');

      final result = formatter.formatEditUpdate(oldValue, newValue);

      expect(result.text, '01310-1');
    });

    test('não deve permitir mais de 8 dígitos', () {
      const oldValue = TextEditingValue(text: '01310-100');
      const newValue = TextEditingValue(text: '013101001');

      final result = formatter.formatEditUpdate(oldValue, newValue);

      expect(result.text, '01310-100');
    });

    test('deve remover caracteres não numéricos', () {
      const oldValue = TextEditingValue(text: '');
      const newValue = TextEditingValue(text: '01310abc');

      final result = formatter.formatEditUpdate(oldValue, newValue);

      expect(result.text, '01310');
    });
  });
}
