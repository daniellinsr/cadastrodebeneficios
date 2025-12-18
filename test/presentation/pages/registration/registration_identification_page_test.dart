import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cadastro_beneficios/presentation/pages/registration/registration_identification_page.dart';
import 'package:cadastro_beneficios/core/theme/app_colors.dart';
import 'package:go_router/go_router.dart';

void main() {
  late GoRouter router;

  setUp(() {
    router = GoRouter(
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => const RegistrationIdentificationPage(),
        ),
        GoRoute(
          path: '/registration/address',
          builder: (context, state) => const Scaffold(
            body: Center(child: Text('Address Page')),
          ),
        ),
      ],
    );
  });

  Widget createWidgetUnderTest() {
    return MaterialApp.router(
      routerConfig: router,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primaryBlue),
        useMaterial3: true,
      ),
    );
  }

  group('RegistrationIdentificationPage Widget Tests', () {
    testWidgets('deve renderizar a página com título', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Verifica se o título está presente
      expect(find.text('Dados Pessoais'), findsOneWidget);
      expect(find.text('Passo 1 de 3'), findsOneWidget);
    });

    testWidgets('deve ter 5 campos de texto', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Verifica se há 5 TextFormField
      expect(find.byType(TextFormField), findsNWidgets(5));
    });

    testWidgets('campo Nome deve aceitar texto', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Encontra o campo de nome pelo hint text
      final nomeField = find.widgetWithText(TextFormField, 'Digite seu nome completo');
      expect(nomeField, findsOneWidget);

      // Digita no campo
      await tester.enterText(nomeField, 'João Silva Santos');
      await tester.pump();

      // Verifica se o texto foi inserido
      expect(find.text('João Silva Santos'), findsOneWidget);
    });

    testWidgets('campo CPF deve formatar automaticamente',
        (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Encontra o campo de CPF
      final cpfField = find.widgetWithText(TextFormField, '000.000.000-00');
      expect(cpfField, findsOneWidget);

      // Digita CPF sem formatação
      await tester.enterText(cpfField, '12345678909');
      await tester.pump();

      // Verifica se o CPF foi formatado
      final textFormField = tester.widget<TextFormField>(cpfField);
      expect(textFormField.controller?.text, '123.456.789-09');
    });

    testWidgets('campo Data deve formatar automaticamente',
        (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Encontra o campo de data
      final dataField = find.widgetWithText(TextFormField, 'DD/MM/AAAA');
      expect(dataField, findsOneWidget);

      // Digita data sem formatação
      await tester.enterText(dataField, '01011990');
      await tester.pump();

      // Verifica se a data foi formatada
      final textFormField = tester.widget<TextFormField>(dataField);
      expect(textFormField.controller?.text, '01/01/1990');
    });

    testWidgets('campo Celular deve formatar automaticamente',
        (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Encontra o campo de celular
      final celularField =
          find.widgetWithText(TextFormField, '(00) 00000-0000');
      expect(celularField, findsOneWidget);

      // Digita celular sem formatação
      await tester.enterText(celularField, '11987654321');
      await tester.pump();

      // Verifica se o celular foi formatado
      final textFormField = tester.widget<TextFormField>(celularField);
      expect(textFormField.controller?.text, '(11) 98765-4321');
    });

    testWidgets('campo Email deve aceitar texto', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Encontra o campo de email
      final emailField =
          find.widgetWithText(TextFormField, 'Digite seu e-mail');
      expect(emailField, findsOneWidget);

      // Digita email
      await tester.enterText(emailField, 'joao@example.com');
      await tester.pump();

      // Verifica se o email foi inserido
      expect(find.text('joao@example.com'), findsOneWidget);
    });

    testWidgets('deve validar campos obrigatórios ao submeter',
        (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Tenta submeter o formulário vazio
      final continueButton = find.text('Continuar');
      await tester.tap(continueButton);
      await tester.pump();

      // Verifica se mensagens de erro aparecem
      expect(find.text('Por favor, informe seu nome completo'), findsOneWidget);
      expect(find.text('Por favor, informe o CPF'), findsOneWidget);
    });

    testWidgets('deve validar CPF inválido', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Preenche com CPF inválido (todos dígitos iguais)
      final cpfField = find.widgetWithText(TextFormField, '000.000.000-00');
      await tester.enterText(cpfField, '11111111111');
      await tester.pump();

      // Tenta submeter
      final continueButton = find.text('Continuar');
      await tester.tap(continueButton);
      await tester.pump();

      // Verifica se mensagem de erro aparece
      expect(find.text('CPF inválido'), findsOneWidget);
    });

    testWidgets('deve validar email inválido', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Preenche com email inválido
      final emailField =
          find.widgetWithText(TextFormField, 'Digite seu e-mail');
      await tester.enterText(emailField, 'email_invalido');
      await tester.pump();

      // Tenta submeter
      final continueButton = find.text('Continuar');
      await tester.tap(continueButton);
      await tester.pump();

      // Verifica se mensagem de erro aparece
      expect(find.text('Por favor, informe um e-mail válido'), findsOneWidget);
    });

    testWidgets('deve mostrar loading ao submeter formulário válido',
        (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Preenche todos os campos com dados válidos
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
      await tester.pump();

      // Tenta submeter
      final continueButton = find.text('Continuar');
      await tester.tap(continueButton);
      await tester.pump();

      // Verifica se o loading aparece
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('deve ter ícones nos campos', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Verifica se há ícones nos campos
      expect(find.byIcon(Icons.person_outline), findsOneWidget);
      expect(find.byIcon(Icons.badge_outlined), findsOneWidget);
      expect(find.byIcon(Icons.cake_outlined), findsOneWidget);
      expect(find.byIcon(Icons.phone_outlined), findsOneWidget);
      expect(find.byIcon(Icons.email_outlined), findsOneWidget);
    });

    testWidgets('deve ter Form widget', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      expect(find.byType(Form), findsOneWidget);
    });

    testWidgets('deve ter SingleChildScrollView', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      expect(find.byType(SingleChildScrollView), findsOneWidget);
    });

    testWidgets('deve ter SafeArea', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      expect(find.byType(SafeArea), findsOneWidget);
    });
  });
}
