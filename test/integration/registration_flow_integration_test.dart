import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:cadastro_beneficios/main.dart' as app;
import 'package:cadastro_beneficios/core/theme/app_colors.dart';

/// Testes de integração para o fluxo completo de cadastro
///
/// Estes testes simulam a jornada completa do usuário desde
/// a tela de introdução até a finalização do cadastro.
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Fluxo de Cadastro Completo', () {
    testWidgets('deve completar o fluxo de cadastro com sucesso',
        (WidgetTester tester) async {
      // Inicia o app
      app.main();
      await tester.pumpAndSettle();

      // PASSO 1: Navegar para o cadastro
      // Assumindo que há um botão para ir ao cadastro na tela inicial
      final cadastroButton = find.text('Cadastrar');
      if (cadastroButton.evaluate().isNotEmpty) {
        await tester.tap(cadastroButton);
        await tester.pumpAndSettle();
      }

      // PASSO 2: Tela de Introdução
      // Verifica se está na tela de introdução
      expect(find.text('Benefícios Exclusivos'), findsOneWidget);

      // Clica no botão "Quero Me Cadastrar Agora"
      final comecarButton = find.text('Quero Me Cadastrar Agora');
      await tester.tap(comecarButton);
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // PASSO 3: Formulário de Identificação
      // Verifica se está na tela de dados pessoais
      expect(find.text('Dados Pessoais'), findsOneWidget);
      expect(find.text('Passo 1 de 3'), findsOneWidget);

      // Preenche nome completo
      final nomeField = find.widgetWithText(TextFormField, 'Digite seu nome completo');
      await tester.enterText(nomeField, 'João Silva Santos');
      await tester.pumpAndSettle();

      // Preenche CPF
      final cpfField = find.widgetWithText(TextFormField, '000.000.000-00');
      await tester.enterText(cpfField, '12345678909');
      await tester.pumpAndSettle();

      // Preenche data de nascimento
      final dataField = find.widgetWithText(TextFormField, 'DD/MM/AAAA');
      await tester.enterText(dataField, '01011990');
      await tester.pumpAndSettle();

      // Preenche celular
      final celularField = find.widgetWithText(TextFormField, '(00) 00000-0000');
      await tester.enterText(celularField, '11987654321');
      await tester.pumpAndSettle();

      // Preenche email
      final emailField = find.widgetWithText(TextFormField, 'Digite seu e-mail');
      await tester.enterText(emailField, 'joao.silva@example.com');
      await tester.pumpAndSettle();

      // Clica no botão Continuar
      final continuarButton1 = find.text('Continuar');
      await tester.tap(continuarButton1);
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // PASSO 4: Formulário de Endereço
      // Verifica se está na tela de endereço
      expect(find.text('Endereço'), findsOneWidget);
      expect(find.text('Passo 2 de 3'), findsOneWidget);

      // Preenche CEP
      final cepField = find.widgetWithText(TextFormField, '00000-000');
      await tester.enterText(cepField, '01310100');
      await tester.pumpAndSettle(const Duration(seconds: 2)); // Aguarda busca do CEP

      // Preenche logradouro (caso não seja preenchido automaticamente)
      final logradouroField = find.widgetWithText(TextFormField, 'Digite o logradouro');
      if (logradouroField.evaluate().isNotEmpty) {
        await tester.enterText(logradouroField, 'Avenida Paulista');
        await tester.pumpAndSettle();
      }

      // Preenche número
      final numeroField = find.widgetWithText(TextFormField, 'Ex: 123 ou S/N');
      await tester.enterText(numeroField, '1000');
      await tester.pumpAndSettle();

      // Preenche complemento (opcional)
      final complementoField = find.widgetWithText(TextFormField, 'Apto, Bloco, etc (opcional)');
      await tester.enterText(complementoField, 'Apto 101');
      await tester.pumpAndSettle();

      // Preenche bairro
      final bairroField = find.widgetWithText(TextFormField, 'Digite o bairro');
      if (bairroField.evaluate().isNotEmpty) {
        await tester.enterText(bairroField, 'Bela Vista');
        await tester.pumpAndSettle();
      }

      // Preenche cidade
      final cidadeField = find.widgetWithText(TextFormField, 'Digite a cidade');
      if (cidadeField.evaluate().isNotEmpty) {
        await tester.enterText(cidadeField, 'São Paulo');
        await tester.pumpAndSettle();
      }

      // Preenche estado
      final estadoField = find.widgetWithText(TextFormField, 'Ex: SP, RJ, MG');
      if (estadoField.evaluate().isNotEmpty) {
        await tester.enterText(estadoField, 'SP');
        await tester.pumpAndSettle();
      }

      // Clica no botão Continuar
      final continuarButton2 = find.text('Continuar');
      await tester.tap(continuarButton2);
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // PASSO 5: Formulário de Senha
      // Verifica se está na tela de criar senha
      expect(find.text('Crie sua Senha'), findsOneWidget);
      expect(find.text('Passo 3 de 3'), findsOneWidget);

      // Preenche senha
      final senhaFields = find.byType(TextFormField);
      await tester.enterText(senhaFields.at(0), 'SenhaForte123!@#');
      await tester.pumpAndSettle();

      // Verifica se o indicador de força aparece
      expect(find.textContaining('Força:'), findsOneWidget);

      // Preenche confirmação de senha
      await tester.enterText(senhaFields.at(1), 'SenhaForte123!@#');
      await tester.pumpAndSettle();

      // Clica no botão Finalizar Cadastro
      final finalizarButton = find.text('Finalizar Cadastro');
      await tester.tap(finalizarButton);
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // PASSO 6: Verificar conclusão
      // Verifica se o diálogo de sucesso aparece
      expect(find.text('Cadastro Concluído!'), findsOneWidget);

      // Fecha o diálogo
      final fazerLoginButton = find.text('Fazer Login');
      await tester.tap(fazerLoginButton);
      await tester.pumpAndSettle();

      // Verifica se navegou para a tela de login
      // (pode variar dependendo da implementação)
    });

    testWidgets('deve validar campos obrigatórios em cada etapa',
        (WidgetTester tester) async {
      // Inicia o app
      app.main();
      await tester.pumpAndSettle();

      // Navegar para o cadastro
      final cadastroButton = find.text('Cadastrar');
      if (cadastroButton.evaluate().isNotEmpty) {
        await tester.tap(cadastroButton);
        await tester.pumpAndSettle();
      }

      // Clicar no botão "Quero Me Cadastrar Agora"
      final comecarButton = find.text('Quero Me Cadastrar Agora');
      await tester.tap(comecarButton);
      await tester.pumpAndSettle();

      // TESTE 1: Tentar avançar sem preencher dados pessoais
      final continuarButton = find.text('Continuar');
      await tester.tap(continuarButton);
      await tester.pump();

      // Verifica se mensagens de erro aparecem
      expect(find.text('Por favor, informe seu nome completo'), findsOneWidget);
      expect(find.text('Por favor, informe o CPF'), findsOneWidget);

      // Preenche os dados corretamente para avançar
      await tester.enterText(
          find.widgetWithText(TextFormField, 'Digite seu nome completo'),
          'João Silva Santos');
      await tester.enterText(
          find.widgetWithText(TextFormField, '000.000.000-00'), '12345678909');
      await tester.enterText(
          find.widgetWithText(TextFormField, 'DD/MM/AAAA'), '01011990');
      await tester.enterText(
          find.widgetWithText(TextFormField, '(00) 00000-0000'), '11987654321');
      await tester.enterText(
          find.widgetWithText(TextFormField, 'Digite seu e-mail'),
          'joao@example.com');
      await tester.pumpAndSettle();

      // Avança para endereço
      await tester.tap(continuarButton);
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // TESTE 2: Tentar avançar sem preencher endereço
      final continuarButton2 = find.text('Continuar');
      await tester.tap(continuarButton2);
      await tester.pump();

      // Verifica se mensagem de erro aparece
      expect(find.text('Por favor, informe o CEP'), findsOneWidget);
    });

    testWidgets('deve formatar os campos automaticamente',
        (WidgetTester tester) async {
      // Inicia o app
      app.main();
      await tester.pumpAndSettle();

      // Navegar até o formulário de identificação
      final cadastroButton = find.text('Cadastrar');
      if (cadastroButton.evaluate().isNotEmpty) {
        await tester.tap(cadastroButton);
        await tester.pumpAndSettle();
      }

      final comecarButton = find.text('Quero Me Cadastrar Agora');
      await tester.tap(comecarButton);
      await tester.pumpAndSettle();

      // Testa formatação do CPF
      final cpfField = find.widgetWithText(TextFormField, '000.000.000-00');
      await tester.enterText(cpfField, '12345678909');
      await tester.pumpAndSettle();

      final cpfWidget = tester.widget<TextFormField>(cpfField);
      expect(cpfWidget.controller?.text, '123.456.789-09');

      // Testa formatação da data
      final dataField = find.widgetWithText(TextFormField, 'DD/MM/AAAA');
      await tester.enterText(dataField, '01011990');
      await tester.pumpAndSettle();

      final dataWidget = tester.widget<TextFormField>(dataField);
      expect(dataWidget.controller?.text, '01/01/1990');

      // Testa formatação do celular
      final celularField = find.widgetWithText(TextFormField, '(00) 00000-0000');
      await tester.enterText(celularField, '11987654321');
      await tester.pumpAndSettle();

      final celularWidget = tester.widget<TextFormField>(celularField);
      expect(celularWidget.controller?.text, '(11) 98765-4321');
    });

    testWidgets('deve mostrar indicador de progresso em cada etapa',
        (WidgetTester tester) async {
      // Inicia o app
      app.main();
      await tester.pumpAndSettle();

      // Navegar para identificação
      final cadastroButton = find.text('Cadastrar');
      if (cadastroButton.evaluate().isNotEmpty) {
        await tester.tap(cadastroButton);
        await tester.pumpAndSettle();
      }

      final comecarButton = find.text('Quero Me Cadastrar Agora');
      await tester.tap(comecarButton);
      await tester.pumpAndSettle();

      // Verifica passo 1 de 3
      expect(find.text('Passo 1 de 3'), findsOneWidget);

      // Preenche e avança
      await tester.enterText(
          find.widgetWithText(TextFormField, 'Digite seu nome completo'),
          'João Silva Santos');
      await tester.enterText(
          find.widgetWithText(TextFormField, '000.000.000-00'), '12345678909');
      await tester.enterText(
          find.widgetWithText(TextFormField, 'DD/MM/AAAA'), '01011990');
      await tester.enterText(
          find.widgetWithText(TextFormField, '(00) 00000-0000'), '11987654321');
      await tester.enterText(
          find.widgetWithText(TextFormField, 'Digite seu e-mail'),
          'joao@example.com');
      await tester.pumpAndSettle();

      final continuarButton1 = find.text('Continuar');
      await tester.tap(continuarButton1);
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Verifica passo 2 de 3
      expect(find.text('Passo 2 de 3'), findsOneWidget);

      // Preenche endereço e avança
      await tester.enterText(
          find.widgetWithText(TextFormField, '00000-000'), '01310100');
      await tester.enterText(
          find.widgetWithText(TextFormField, 'Ex: 123 ou S/N'), '1000');
      await tester.pumpAndSettle();

      final continuarButton2 = find.text('Continuar');
      await tester.tap(continuarButton2);
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Verifica passo 3 de 3
      expect(find.text('Passo 3 de 3'), findsOneWidget);
    });
  });
}
