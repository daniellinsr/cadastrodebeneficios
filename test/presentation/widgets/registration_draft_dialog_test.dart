import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cadastro_beneficios/presentation/widgets/registration_draft_dialog.dart';
import 'package:cadastro_beneficios/core/theme/app_colors.dart';

void main() {
  group('RegistrationDraftDialog', () {
    testWidgets('deve exibir corretamente com todos os elementos',
        (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: RegistrationDraftDialog(
              draftSummary: 'Cadastro de João Silva iniciado há 2 horas',
              progressPercentage: 50,
              onContinue: () {},
              onStartNew: () {},
            ),
          ),
        ),
      );

      // Assert
      expect(find.text('Cadastro em Andamento'), findsOneWidget);
      expect(
          find.text('Cadastro de João Silva iniciado há 2 horas'), findsOneWidget);
      expect(find.text('Progresso'), findsOneWidget);
      expect(find.text('50%'), findsOneWidget);
      expect(find.text('Continuar Cadastro'), findsOneWidget);
      expect(find.text('Começar Novo Cadastro'), findsOneWidget);
      expect(find.byIcon(Icons.description_outlined), findsOneWidget);
      expect(find.byType(LinearProgressIndicator), findsOneWidget);
    });

    testWidgets('deve chamar onContinue quando botão é pressionado',
        (WidgetTester tester) async {
      // Arrange
      bool continueCalled = false;

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: RegistrationDraftDialog(
              draftSummary: 'Cadastro de João Silva iniciado há 2 horas',
              progressPercentage: 50,
              onContinue: () => continueCalled = true,
              onStartNew: () {},
            ),
          ),
        ),
      );

      await tester.tap(find.text('Continuar Cadastro'));
      await tester.pumpAndSettle();

      // Assert
      expect(continueCalled, isTrue);
    });

    testWidgets('deve chamar onStartNew quando botão é pressionado',
        (WidgetTester tester) async {
      // Arrange
      bool startNewCalled = false;

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: RegistrationDraftDialog(
              draftSummary: 'Cadastro de João Silva iniciado há 2 horas',
              progressPercentage: 50,
              onContinue: () {},
              onStartNew: () => startNewCalled = true,
            ),
          ),
        ),
      );

      await tester.tap(find.text('Começar Novo Cadastro'));
      await tester.pumpAndSettle();

      // Assert
      expect(startNewCalled, isTrue);
    });

    testWidgets('deve exibir progresso correto na barra',
        (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: RegistrationDraftDialog(
              draftSummary: 'Teste',
              progressPercentage: 75,
              onContinue: () {},
              onStartNew: () {},
            ),
          ),
        ),
      );

      // Assert
      expect(find.text('75%'), findsOneWidget);

      final progressBar =
          tester.widget<LinearProgressIndicator>(find.byType(LinearProgressIndicator));
      expect(progressBar.value, 0.75);
    });

    testWidgets('deve usar cores corretas do tema',
        (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: RegistrationDraftDialog(
              draftSummary: 'Teste',
              progressPercentage: 50,
              onContinue: () {},
              onStartNew: () {},
            ),
          ),
        ),
      );

      // Assert - verifica ícone com cor primária
      final icon = tester.widget<Icon>(find.byIcon(Icons.description_outlined));
      expect(icon.color, AppColors.primaryBlue);

      // Assert - verifica barra de progresso
      final progressBar =
          tester.widget<LinearProgressIndicator>(find.byType(LinearProgressIndicator));
      expect(progressBar.backgroundColor, AppColors.gray200);
    });

    testWidgets('deve funcionar com progresso 0%',
        (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: RegistrationDraftDialog(
              draftSummary: 'Cadastro iniciado',
              progressPercentage: 0,
              onContinue: () {},
              onStartNew: () {},
            ),
          ),
        ),
      );

      // Assert
      expect(find.text('0%'), findsOneWidget);

      final progressBar =
          tester.widget<LinearProgressIndicator>(find.byType(LinearProgressIndicator));
      expect(progressBar.value, 0.0);
    });

    testWidgets('deve funcionar com progresso 100%',
        (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: RegistrationDraftDialog(
              draftSummary: 'Cadastro quase completo',
              progressPercentage: 100,
              onContinue: () {},
              onStartNew: () {},
            ),
          ),
        ),
      );

      // Assert
      expect(find.text('100%'), findsOneWidget);

      final progressBar =
          tester.widget<LinearProgressIndicator>(find.byType(LinearProgressIndicator));
      expect(progressBar.value, 1.0);
    });

    testWidgets('deve exibir dialog usando método estático show',
        (WidgetTester tester) async {
      // Arrange
      bool? result;

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => Scaffold(
              body: ElevatedButton(
                onPressed: () async {
                  result = await RegistrationDraftDialog.show(
                    context: context,
                    draftSummary: 'Cadastro de Maria Silva',
                    progressPercentage: 50,
                  );
                },
                child: const Text('Mostrar Dialog'),
              ),
            ),
          ),
        ),
      );

      // Toca no botão para mostrar o dialog
      await tester.tap(find.text('Mostrar Dialog'));
      await tester.pumpAndSettle();

      // Assert - verifica que o dialog foi exibido
      expect(find.text('Cadastro em Andamento'), findsOneWidget);
      expect(find.text('Cadastro de Maria Silva'), findsOneWidget);
      expect(find.text('50%'), findsOneWidget);

      // Toca em "Continuar Cadastro"
      await tester.tap(find.text('Continuar Cadastro'));
      await tester.pumpAndSettle();

      // Assert - verifica que retornou true
      expect(result, isTrue);
    });

    testWidgets('deve retornar false quando clicar em Começar Novo',
        (WidgetTester tester) async {
      // Arrange
      bool? result;

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => Scaffold(
              body: ElevatedButton(
                onPressed: () async {
                  result = await RegistrationDraftDialog.show(
                    context: context,
                    draftSummary: 'Cadastro de Maria Silva',
                    progressPercentage: 50,
                  );
                },
                child: const Text('Mostrar Dialog'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Mostrar Dialog'));
      await tester.pumpAndSettle();

      // Toca em "Começar Novo Cadastro"
      await tester.tap(find.text('Começar Novo Cadastro'));
      await tester.pumpAndSettle();

      // Assert - verifica que retornou false
      expect(result, isFalse);
    });

    testWidgets('dialog não deve ser dismissível ao tocar fora',
        (WidgetTester tester) async {
      // Arrange
      bool? result;

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => Scaffold(
              body: ElevatedButton(
                onPressed: () async {
                  result = await RegistrationDraftDialog.show(
                    context: context,
                    draftSummary: 'Teste',
                    progressPercentage: 50,
                  );
                },
                child: const Text('Mostrar Dialog'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Mostrar Dialog'));
      await tester.pumpAndSettle();

      // Tenta tocar fora do dialog (na barrier)
      await tester.tapAt(const Offset(10, 10));
      await tester.pumpAndSettle();

      // Assert - verifica que o dialog ainda está visível
      expect(find.text('Cadastro em Andamento'), findsOneWidget);
      expect(result, isNull); // O dialog não foi fechado
    });
  });
}
