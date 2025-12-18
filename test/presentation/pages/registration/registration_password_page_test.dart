import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cadastro_beneficios/presentation/pages/registration/registration_password_page.dart';
import 'package:cadastro_beneficios/core/theme/app_colors.dart';
import 'package:go_router/go_router.dart';

void main() {
  late GoRouter router;

  setUp(() {
    router = GoRouter(
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => const RegistrationPasswordPage(),
        ),
        GoRoute(
          path: '/login',
          builder: (context, state) => const Scaffold(
            body: Center(child: Text('Login Page')),
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

  group('RegistrationPasswordPage Widget Tests', () {
    testWidgets('deve renderizar a página com título', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Verifica se o título e progresso estão presentes
      expect(find.text('Crie sua Senha'), findsOneWidget);
      expect(find.text('Passo 3 de 3'), findsOneWidget);
    });

    testWidgets('deve ter 2 campos de senha', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      expect(find.byType(TextFormField), findsNWidgets(2));
    });

    testWidgets('deve ter botões de toggle de visibilidade',
        (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Verifica se há ícones de visibilidade
      expect(find.byIcon(Icons.visibility_outlined), findsNWidgets(2));
    });

    testWidgets('deve mostrar indicador de força da senha ao digitar',
        (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Digita uma senha no primeiro campo
      final senhaField = find.byType(TextFormField).first;
      await tester.enterText(senhaField, 'Teste123!');
      await tester.pump();

      // Verifica se o indicador de força aparece
      expect(find.textContaining('Força:'), findsOneWidget);
    });

    testWidgets('deve mostrar requisitos da senha ao digitar', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Digita uma senha
      final senhaField = find.byType(TextFormField).first;
      await tester.enterText(senhaField, 'Teste123!');
      await tester.pump();

      // Verifica se os requisitos estão presentes
      expect(find.textContaining('Mínimo 8 caracteres'), findsOneWidget);
      expect(find.textContaining('Letra maiúscula'), findsOneWidget);
      expect(find.textContaining('Letra minúscula'), findsOneWidget);
      expect(find.textContaining('Número'), findsOneWidget);
      expect(find.textContaining('Caractere especial'), findsOneWidget);
    });

    testWidgets('requisitos devem mostrar checkmarks quando atendidos',
        (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Digita uma senha forte
      final senhaField = find.byType(TextFormField).first;
      await tester.enterText(senhaField, 'SenhaForte123!@#');
      await tester.pump();

      // Verifica se há checkmarks (ícones de check_circle)
      expect(find.byIcon(Icons.check_circle), findsWidgets);
    });

    testWidgets('deve validar senha vazia', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Tenta submeter sem preencher
      final finalizarButton = find.text('Finalizar Cadastro');
      await tester.tap(finalizarButton);
      await tester.pump();

      // Verifica se mensagem de erro aparece
      expect(find.text('Por favor, crie uma senha'), findsOneWidget);
    });

    testWidgets('deve validar confirmação de senha vazia',
        (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Preenche só a primeira senha
      final senhaField = find.byType(TextFormField).first;
      await tester.enterText(senhaField, 'SenhaForte123!');
      await tester.pump();

      // Tenta submeter sem confirmar
      final finalizarButton = find.text('Finalizar Cadastro');
      await tester.tap(finalizarButton);
      await tester.pump();

      // Verifica se mensagem de erro aparece
      expect(find.text('Por favor, confirme sua senha'), findsOneWidget);
    });

    testWidgets('deve validar senhas diferentes', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Preenche as senhas com valores diferentes
      final senhaFields = find.byType(TextFormField);
      await tester.enterText(senhaFields.at(0), 'SenhaForte123!');
      await tester.enterText(senhaFields.at(1), 'SenhaDiferente123!');
      await tester.pump();

      // Tenta submeter
      final finalizarButton = find.text('Finalizar Cadastro');
      await tester.tap(finalizarButton);
      await tester.pump();

      // Verifica se mensagem de erro aparece
      expect(find.text('As senhas não coincidem'), findsOneWidget);
    });

    testWidgets('deve ter ícones de cadeado nos campos',
        (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Verifica se há ícones de cadeado
      expect(find.byIcon(Icons.lock_outline), findsNWidgets(2));
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
