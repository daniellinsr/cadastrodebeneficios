import 'package:flutter/material.dart';
import 'package:cadastro_beneficios/core/theme/app_colors.dart';
import 'package:cadastro_beneficios/core/theme/app_text_styles.dart';

/// Diálogo para perguntar ao usuário se deseja continuar o cadastro salvo
class RegistrationDraftDialog extends StatelessWidget {
  final String draftSummary;
  final int progressPercentage;
  final VoidCallback onContinue;
  final VoidCallback onStartNew;

  const RegistrationDraftDialog({
    super.key,
    required this.draftSummary,
    required this.progressPercentage,
    required this.onContinue,
    required this.onStartNew,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Ícone
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.primaryBlue.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.description_outlined,
                size: 40,
                color: AppColors.primaryBlue,
              ),
            ),

            const SizedBox(height: 20),

            // Título
            Text(
              'Cadastro em Andamento',
              style: AppTextStyles.h3.copyWith(
                color: AppColors.darkGray,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 12),

            // Descrição
            Text(
              draftSummary,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.gray600,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 20),

            // Barra de progresso
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Progresso',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.gray600,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      '$progressPercentage%',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.primaryBlue,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: progressPercentage / 100,
                    minHeight: 8,
                    backgroundColor: AppColors.gray200,
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      AppColors.primaryBlue,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Botão Continuar
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onContinue,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryBlue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'Continuar Cadastro',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 12),

            // Botão Começar Novo
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: onStartNew,
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.gray700,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  side: BorderSide(
                    color: AppColors.gray300,
                    width: 1.5,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Começar Novo Cadastro',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Mostra o diálogo
  static Future<bool?> show({
    required BuildContext context,
    required String draftSummary,
    required int progressPercentage,
  }) async {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => RegistrationDraftDialog(
        draftSummary: draftSummary,
        progressPercentage: progressPercentage,
        onContinue: () => Navigator.of(context).pop(true),
        onStartNew: () => Navigator.of(context).pop(false),
      ),
    );
  }
}
