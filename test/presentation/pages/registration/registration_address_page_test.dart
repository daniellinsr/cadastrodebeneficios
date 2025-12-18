import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cadastro_beneficios/presentation/pages/registration/registration_address_page.dart';
import 'package:cadastro_beneficios/core/theme/app_colors.dart';
import 'package:go_router/go_router.dart';

void main() {
  late GoRouter router;

  setUp(() {
    router = GoRouter(
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => const RegistrationAddressPage(),
        ),
        GoRoute(
          path: '/registration/password',
          builder: (context, state) => const Scaffold(
            body: Center(child: Text('Password Page')),
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

  group('RegistrationAddressPage Widget Tests', () {
    testWidgets('deve renderizar a página com título', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Verifica se o título e progresso estão presentes
      expect(find.text('Endereço'), findsOneWidget);
      expect(find.text('Passo 2 de 3'), findsOneWidget);
    });

    testWidgets('deve ter 7 campos de texto', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      expect(find.byType(TextFormField), findsNWidgets(7));
    });

    testWidgets('campo CEP deve formatar automaticamente',
        (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Encontra o campo de CEP
      final cepField = find.widgetWithText(TextFormField, '00000-000');
      expect(cepField, findsOneWidget);

      // Digita CEP sem formatação
      await tester.enterText(cepField, '12345678');
      await tester.pump();

      // Verifica se o CEP foi formatado
      final textFormField = tester.widget<TextFormField>(cepField);
      expect(textFormField.controller?.text, '12345-678');
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
      expect(find.text('Por favor, informe o CEP'), findsOneWidget);
    });

    testWidgets('deve validar CEP inválido', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Preenche com CEP inválido (menos de 8 dígitos)
      final cepField = find.widgetWithText(TextFormField, '00000-000');
      await tester.enterText(cepField, '12345');
      await tester.pump();

      // Tenta submeter
      final continueButton = find.text('Continuar');
      await tester.tap(continueButton);
      await tester.pump();

      // Verifica se mensagem de erro aparece
      expect(find.text('CEP deve conter 8 dígitos'), findsOneWidget);
    });

    testWidgets('deve ter botão de buscar CEP', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Verifica se há um botão com ícone de busca
      expect(find.byIcon(Icons.search), findsOneWidget);
    });

    testWidgets('deve ter ícones nos campos', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Verifica se os ícones estão presentes
      expect(find.byIcon(Icons.pin_drop_outlined), findsOneWidget);
      expect(find.byIcon(Icons.home_outlined), findsOneWidget);
      expect(find.byIcon(Icons.numbers), findsOneWidget);
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
