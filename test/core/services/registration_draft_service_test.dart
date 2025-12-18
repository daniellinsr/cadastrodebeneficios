import 'package:flutter_test/flutter_test.dart';
import 'package:cadastro_beneficios/core/services/registration_draft_service.dart';
import 'package:flutter/services.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late RegistrationDraftService service;
  final Map<String, String> storage = {};

  setUp(() {
    service = RegistrationDraftService();
    storage.clear();

    // Mock do FlutterSecureStorage usando MethodChannel
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel('plugins.it_nomads.com/flutter_secure_storage'),
      (MethodCall methodCall) async {
        switch (methodCall.method) {
          case 'write':
            final args = methodCall.arguments as Map;
            storage[args['key'] as String] = args['value'] as String;
            return null;
          case 'read':
            final args = methodCall.arguments as Map;
            return storage[args['key'] as String];
          case 'delete':
            final args = methodCall.arguments as Map;
            storage.remove(args['key'] as String);
            return null;
          case 'readAll':
            return storage;
          case 'deleteAll':
            storage.clear();
            return null;
          default:
            return null;
        }
      },
    );
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel('plugins.it_nomads.com/flutter_secure_storage'),
      null,
    );
  });

  group('RegistrationDraftService - saveIdentificationDraft', () {
    test('deve salvar dados de identificação corretamente', () async {
      // Arrange
      const nome = 'João Silva Santos';
      const cpf = '12345678909';
      const dataNascimento = '01/01/1990';
      const celular = '11987654321';
      const email = 'joao@example.com';

      // Act
      await service.saveIdentificationDraft(
        nome: nome,
        cpf: cpf,
        dataNascimento: dataNascimento,
        celular: celular,
        email: email,
      );

      // Assert
      final loaded = await service.loadIdentificationDraft();

      expect(loaded, isNotNull);
      expect(loaded!['nome'], nome);
      expect(loaded['cpf'], cpf);
      expect(loaded['dataNascimento'], dataNascimento);
      expect(loaded['celular'], celular);
      expect(loaded['email'], email);
    });

    test('deve atualizar dados existentes', () async {
      // Arrange - Salva primeiro conjunto de dados
      await service.saveIdentificationDraft(
        nome: 'Nome Antigo',
        cpf: '11111111111',
        dataNascimento: '01/01/1980',
        celular: '11111111111',
        email: 'antigo@example.com',
      );

      // Act - Salva novo conjunto de dados
      const novoNome = 'Nome Novo';
      await service.saveIdentificationDraft(
        nome: novoNome,
        cpf: '22222222222',
        dataNascimento: '02/02/1990',
        celular: '22222222222',
        email: 'novo@example.com',
      );

      // Assert
      final loaded = await service.loadIdentificationDraft();
      expect(loaded!['nome'], novoNome);
    });
  });

  group('RegistrationDraftService - saveAddressDraft', () {
    test('deve salvar dados de endereço corretamente', () async {
      // Arrange
      const cep = '01310100';
      const logradouro = 'Avenida Paulista';
      const numero = '1000';
      const complemento = 'Apto 101';
      const bairro = 'Bela Vista';
      const cidade = 'São Paulo';
      const estado = 'SP';

      // Act
      await service.saveAddressDraft(
        cep: cep,
        logradouro: logradouro,
        numero: numero,
        complemento: complemento,
        bairro: bairro,
        cidade: cidade,
        estado: estado,
      );

      // Assert
      final loaded = await service.loadAddressDraft();

      expect(loaded, isNotNull);
      expect(loaded!['cep'], cep);
      expect(loaded['logradouro'], logradouro);
      expect(loaded['numero'], numero);
      expect(loaded['complemento'], complemento);
      expect(loaded['bairro'], bairro);
      expect(loaded['cidade'], cidade);
      expect(loaded['estado'], estado);
    });

    test('deve permitir complemento null', () async {
      // Act
      await service.saveAddressDraft(
        cep: '01310100',
        logradouro: 'Avenida Paulista',
        numero: '1000',
        complemento: null,
        bairro: 'Bela Vista',
        cidade: 'São Paulo',
        estado: 'SP',
      );

      // Assert
      final loaded = await service.loadAddressDraft();
      expect(loaded!['complemento'], isNull);
    });
  });

  group('RegistrationDraftService - loadIdentificationDraft', () {
    test('deve retornar null quando não há dados salvos', () async {
      // Arrange - Limpa qualquer dado existente
      await service.clearDraft();

      // Act
      final loaded = await service.loadIdentificationDraft();

      // Assert
      expect(loaded, isNull);
    });

    test('deve carregar dados salvos corretamente', () async {
      // Arrange
      await service.saveIdentificationDraft(
        nome: 'Teste',
        cpf: '12345678909',
        dataNascimento: '01/01/1990',
        celular: '11987654321',
        email: 'teste@example.com',
      );

      // Act
      final loaded = await service.loadIdentificationDraft();

      // Assert
      expect(loaded, isNotNull);
      expect(loaded!['nome'], 'Teste');
    });
  });

  group('RegistrationDraftService - loadAddressDraft', () {
    test('deve retornar null quando não há dados de endereço', () async {
      // Arrange - Limpa dados
      await service.clearDraft();

      // Act
      final loaded = await service.loadAddressDraft();

      // Assert
      expect(loaded, isNull);
    });
  });

  group('RegistrationDraftService - hasDraft', () {
    test('deve retornar false quando não há draft', () async {
      // Arrange
      await service.clearDraft();

      // Act
      final result = await service.hasDraft();

      // Assert
      expect(result, isFalse);
    });

    test('deve retornar true quando há draft', () async {
      // Arrange
      await service.saveIdentificationDraft(
        nome: 'Teste',
        cpf: '12345678909',
        dataNascimento: '01/01/1990',
        celular: '11987654321',
        email: 'teste@example.com',
      );

      // Act
      final result = await service.hasDraft();

      // Assert
      expect(result, isTrue);
    });
  });

  group('RegistrationDraftService - getDraftTimestamp', () {
    test('deve retornar timestamp após salvar draft', () async {
      // Arrange
      await service.saveIdentificationDraft(
        nome: 'Teste',
        cpf: '12345678909',
        dataNascimento: '01/01/1990',
        celular: '11987654321',
        email: 'teste@example.com',
      );

      // Act
      final timestamp = await service.getDraftTimestamp();

      // Assert
      expect(timestamp, isNotNull);
      expect(timestamp!.isBefore(DateTime.now()), isTrue);
    });

    test('deve retornar null quando não há draft', () async {
      // Arrange
      await service.clearDraft();

      // Act
      final timestamp = await service.getDraftTimestamp();

      // Assert
      expect(timestamp, isNull);
    });
  });

  group('RegistrationDraftService - clearDraft', () {
    test('deve limpar draft existente', () async {
      // Arrange - Salva draft
      await service.saveIdentificationDraft(
        nome: 'Teste',
        cpf: '12345678909',
        dataNascimento: '01/01/1990',
        celular: '11987654321',
        email: 'teste@example.com',
      );

      // Verifica que existe
      expect(await service.hasDraft(), isTrue);

      // Act
      await service.clearDraft();

      // Assert
      expect(await service.hasDraft(), isFalse);
    });
  });

  group('RegistrationDraftService - isDraftExpired', () {
    test('deve retornar true quando não há draft', () async {
      // Arrange
      await service.clearDraft();

      // Act
      final result = await service.isDraftExpired();

      // Assert
      expect(result, isTrue);
    });

    test('deve retornar false para draft recém criado', () async {
      // Arrange
      await service.saveIdentificationDraft(
        nome: 'Teste',
        cpf: '12345678909',
        dataNascimento: '01/01/1990',
        celular: '11987654321',
        email: 'teste@example.com',
      );

      // Act
      final result = await service.isDraftExpired();

      // Assert
      expect(result, isFalse);
    });
  });

  group('RegistrationDraftService - getDraftSummary', () {
    test('deve retornar null quando não há draft', () async {
      // Arrange
      await service.clearDraft();

      // Act
      final summary = await service.getDraftSummary();

      // Assert
      expect(summary, isNull);
    });

    test('deve retornar resumo com nome do usuário', () async {
      // Arrange
      await service.saveIdentificationDraft(
        nome: 'João Silva',
        cpf: '12345678909',
        dataNascimento: '01/01/1990',
        celular: '11987654321',
        email: 'joao@example.com',
      );

      // Act
      final summary = await service.getDraftSummary();

      // Assert
      expect(summary, isNotNull);
      expect(summary, contains('João Silva'));
    });
  });

  group('RegistrationDraftService - getDraftProgress', () {
    test('deve retornar 0 quando não há dados', () async {
      // Arrange
      await service.clearDraft();

      // Act
      final progress = await service.getDraftProgress();

      // Assert
      expect(progress, 0);
    });

    test('deve retornar 50 quando há apenas identificação', () async {
      // Arrange
      await service.saveIdentificationDraft(
        nome: 'Teste',
        cpf: '12345678909',
        dataNascimento: '01/01/1990',
        celular: '11987654321',
        email: 'teste@example.com',
      );

      // Act
      final progress = await service.getDraftProgress();

      // Assert
      expect(progress, 50);
    });

    test('deve retornar 100 quando há identificação e endereço', () async {
      // Arrange
      await service.saveIdentificationDraft(
        nome: 'Teste',
        cpf: '12345678909',
        dataNascimento: '01/01/1990',
        celular: '11987654321',
        email: 'teste@example.com',
      );

      await service.saveAddressDraft(
        cep: '01310100',
        logradouro: 'Avenida Paulista',
        numero: '1000',
        complemento: null,
        bairro: 'Bela Vista',
        cidade: 'São Paulo',
        estado: 'SP',
      );

      // Act
      final progress = await service.getDraftProgress();

      // Assert
      expect(progress, 100);
    });
  });
}
