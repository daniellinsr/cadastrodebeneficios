import 'package:flutter/material.dart';
import 'package:cadastro_beneficios/core/theme/app_theme.dart';
import 'package:cadastro_beneficios/core/router/app_router.dart';
import 'package:cadastro_beneficios/core/config/env_config.dart';

void main() async {
  // Garantir que os bindings do Flutter estejam inicializados
  WidgetsFlutterBinding.ensureInitialized();

  // Carregar variáveis de ambiente do arquivo .env
  await EnvConfig.load();

  // Validar se todas as variáveis obrigatórias estão configuradas
  EnvConfig.validate();

  // Imprimir configuração (apenas se ENABLE_DEBUG_LOGS=true no .env)
  EnvConfig.printConfig();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Sistema de Cartão de Benefícios',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      routerConfig: AppRouter.router,
    );
  }
}
