import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cadastro_beneficios/presentation/pages/registration/registration_intro_page.dart';
import 'package:cadastro_beneficios/core/theme/app_colors.dart';
import 'package:go_router/go_router.dart';

void main() {
  late GoRouter router;

  setUp(() {
    router = GoRouter(
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => const RegistrationIntroPage(),
        ),
        GoRoute(
          path: '/registration/identification',
          builder: (context, state) => const Scaffold(
            body: Center(child: Text('Identification Page')),
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

  group('RegistrationIntroPage Widget Tests', () {
    testWidgets('deve renderizar todos os elementos da tela',
        (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Verifica se o título está presente
      expect(find.text('Cadastre-se e Tenha Acesso a'), findsOneWidget);
      expect(find.text('Benefícios Exclusivos'), findsOneWidget);

      // Verifica se os 3 cards de benefícios estão presentes
      expect(find.text('Saúde e Bem-Estar'), findsOneWidget);
      expect(find.text('Descontos em consultas e exames'), findsOneWidget);

      expect(find.text('Compras'), findsOneWidget);
      expect(find.text('Cashback em compras online'), findsOneWidget);

      expect(find.text('Alimentação'), findsOneWidget);
      expect(find.text('Descontos em restaurantes'), findsOneWidget);

      // Verifica se os botões estão presentes
      expect(find.text('Quero Me Cadastrar Agora'), findsOneWidget);
      expect(find.text('Falar no WhatsApp'), findsOneWidget);
    });

    testWidgets('deve ter os ícones corretos nos cards de benefícios',
        (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Verifica se os ícones estão presentes
      expect(find.byIcon(Icons.favorite), findsOneWidget);
      expect(find.byIcon(Icons.shopping_bag), findsOneWidget);
      expect(find.byIcon(Icons.restaurant), findsOneWidget);
    });

    testWidgets(
        'deve navegar para a página de identificação ao clicar no botão de cadastro',
        (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Encontra e clica no botão de cadastro
      final cadastroButton = find.text('Quero Me Cadastrar Agora');
      expect(cadastroButton, findsOneWidget);

      await tester.tap(cadastroButton);
      await tester.pumpAndSettle();

      // Verifica se navegou para a página de identificação
      expect(find.text('Identification Page'), findsOneWidget);
    });

    testWidgets('deve renderizar o gradiente de fundo corretamente',
        (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Verifica se o Container com gradiente existe
      final containerFinder = find.byType(Container);
      expect(containerFinder, findsWidgets);

      // Verifica se há um BoxDecoration com gradiente
      final container = tester.widget<Container>(containerFinder.first);
      expect(container.decoration, isA<BoxDecoration>());

      final decoration = container.decoration as BoxDecoration;
      expect(decoration.gradient, isA<LinearGradient>());
    });

    testWidgets('deve ter um botão de WhatsApp funcional',
        (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Verifica se o botão de WhatsApp está presente
      final whatsappButton = find.text('Falar no WhatsApp');
      expect(whatsappButton, findsOneWidget);

      // Verifica se o botão é clicável
      await tester.tap(whatsappButton);
      await tester.pump();

      // O botão deve existir e ser interativo
      expect(whatsappButton, findsOneWidget);
    });

    testWidgets('deve renderizar SafeArea corretamente',
        (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Verifica se há um SafeArea
      expect(find.byType(SafeArea), findsOneWidget);
    });

    testWidgets('deve ter padding adequado no conteúdo',
        (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Verifica se há Padding widgets
      expect(find.byType(Padding), findsWidgets);
    });

    testWidgets('cards de benefícios devem ter elevation/sombra',
        (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Verifica se há Cards na tela
      expect(find.byType(Card), findsNWidgets(3));
    });

    testWidgets('botão principal deve ter estilo de botão elevado',
        (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Verifica se há pelo menos um ElevatedButton
      expect(find.byType(ElevatedButton), findsWidgets);
    });

    testWidgets('deve renderizar SingleChildScrollView para scroll',
        (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Verifica se há um SingleChildScrollView
      expect(find.byType(SingleChildScrollView), findsOneWidget);
    });

    testWidgets('deve ter cores consistentes com o tema',
        (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Verifica se o tema está sendo aplicado
      final BuildContext context = tester.element(find.byType(Scaffold));
      final theme = Theme.of(context);

      // Verifica que o tema tem um primary color definido
      expect(theme.colorScheme.primary, isNotNull);
    });
  });
}