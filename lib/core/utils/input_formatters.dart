import 'package:flutter/services.dart';

/// Formatador de CPF (000.000.000-00)
class CpfInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');

    if (text.length > 11) {
      return oldValue;
    }

    String formatted = '';
    for (int i = 0; i < text.length; i++) {
      if (i == 3 || i == 6) {
        formatted += '.';
      } else if (i == 9) {
        formatted += '-';
      }
      formatted += text[i];
    }

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

/// Formatador de data (DD/MM/AAAA)
class DateInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');

    if (text.length > 8) {
      return oldValue;
    }

    String formatted = '';
    for (int i = 0; i < text.length; i++) {
      if (i == 2 || i == 4) {
        formatted += '/';
      }
      formatted += text[i];
    }

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

/// Formatador de telefone ((00) 00000-0000)
class PhoneInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');

    if (text.length > 11) {
      return oldValue;
    }

    String formatted = '';

    if (text.isNotEmpty) {
      formatted += '(';
      formatted += text.substring(0, text.length.clamp(0, 2));

      if (text.length >= 2) {
        formatted += ') ';
        formatted += text.substring(2, text.length.clamp(2, 7));

        if (text.length >= 7) {
          formatted += '-';
          formatted += text.substring(7, text.length.clamp(7, 11));
        }
      }
    }

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

/// Formatador de CEP (00000-000)
class CepInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');

    if (text.length > 8) {
      return oldValue;
    }

    String formatted = '';
    for (int i = 0; i < text.length; i++) {
      if (i == 5) {
        formatted += '-';
      }
      formatted += text[i];
    }

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}
