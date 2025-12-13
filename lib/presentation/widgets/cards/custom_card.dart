import 'package:flutter/material.dart';
import 'package:cadastro_beneficios/core/theme/app_colors.dart';
import 'package:cadastro_beneficios/core/theme/app_spacing.dart';
import 'package:cadastro_beneficios/core/theme/app_text_styles.dart';

/// Card customizado básico
class CustomCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  final VoidCallback? onTap;
  final Color? color;
  final double? elevation;

  const CustomCard({
    super.key,
    required this.child,
    this.padding,
    this.onTap,
    this.color,
    this.elevation,
  });

  @override
  Widget build(BuildContext context) {
    final card = Card(
      color: color,
      elevation: elevation ?? AppSpacing.elevation2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      ),
      child: Padding(
        padding: padding ?? const EdgeInsets.all(AppSpacing.md),
        child: child,
      ),
    );

    if (onTap != null) {
      return InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        child: card,
      );
    }

    return card;
  }
}

/// Card de plano de benefícios
class PlanCard extends StatelessWidget {
  final String planName;
  final String description;
  final double monthlyPrice;
  final double? adhesionFee;
  final List<String> benefits;
  final bool isHighlight;
  final bool isSelected;
  final VoidCallback? onTap;

  const PlanCard({
    super.key,
    required this.planName,
    required this.description,
    required this.monthlyPrice,
    this.adhesionFee,
    required this.benefits,
    this.isHighlight = false,
    this.isSelected = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return CustomCard(
      onTap: onTap,
      color: isSelected ? AppColors.primaryBlueWithOpacity(0.1) : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Badge de destaque
          if (isHighlight)
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.sm,
                vertical: AppSpacing.xs,
              ),
              decoration: BoxDecoration(
                color: AppColors.success,
                borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
              ),
              child: Text(
                'MAIS POPULAR',
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          if (isHighlight) const SizedBox(height: AppSpacing.sm),

          // Nome do plano
          Text(
            planName,
            style: AppTextStyles.h3,
          ),
          const SizedBox(height: AppSpacing.xs),

          // Descrição
          Text(
            description,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.darkGrayWithOpacity(0.7),
            ),
          ),
          const SizedBox(height: AppSpacing.md),

          // Preço
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'R\$',
                style: AppTextStyles.bodyLarge.copyWith(
                  color: AppColors.primaryBlue,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: AppSpacing.xs),
              Text(
                monthlyPrice.toStringAsFixed(2).replaceAll('.', ','),
                style: AppTextStyles.h2.copyWith(
                  color: AppColors.primaryBlue,
                ),
              ),
              const SizedBox(width: AppSpacing.xs),
              Text(
                '/mês',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.darkGrayWithOpacity(0.7),
                ),
              ),
            ],
          ),

          // Taxa de adesão
          if (adhesionFee != null && adhesionFee! > 0) ...[
            const SizedBox(height: AppSpacing.xs),
            Text(
              'Taxa de adesão: R\$ ${adhesionFee!.toStringAsFixed(2).replaceAll('.', ',')}',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.darkGrayWithOpacity(0.6),
              ),
            ),
          ],

          const SizedBox(height: AppSpacing.lg),

          // Benefícios
          Text(
            'Benefícios inclusos:',
            style: AppTextStyles.bodyMedium.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),

          ...benefits.map((benefit) => Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.xs),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.check_circle,
                      size: 20,
                      color: AppColors.success,
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Text(
                        benefit,
                        style: AppTextStyles.bodyMedium,
                      ),
                    ),
                  ],
                ),
              )),

          const SizedBox(height: AppSpacing.lg),

          // Botão de seleção
          if (onTap != null)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onTap,
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      isSelected ? AppColors.success : AppColors.primaryBlue,
                ),
                child: Text(
                  isSelected ? 'SELECIONADO' : 'SELECIONAR PLANO',
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Card de parceiro
class PartnerCard extends StatelessWidget {
  final String name;
  final String category;
  final String? address;
  final String? phone;
  final double? distance;
  final String? imageUrl;
  final VoidCallback? onTap;

  const PartnerCard({
    super.key,
    required this.name,
    required this.category,
    this.address,
    this.phone,
    this.distance,
    this.imageUrl,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return CustomCard(
      onTap: onTap,
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Imagem (se houver)
          if (imageUrl != null)
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(AppSpacing.radiusMd),
              ),
              child: Image.network(
                imageUrl!,
                height: 120,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  height: 120,
                  color: AppColors.lightGray,
                  child: const Icon(
                    Icons.store,
                    size: 48,
                    color: AppColors.darkGray,
                  ),
                ),
              ),
            ),

          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Categoria + Distância
                Row(
                  children: [
                    Chip(
                      label: Text(category),
                      labelStyle: AppTextStyles.caption,
                      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
                    ),
                    if (distance != null) ...[
                      const Spacer(),
                      Icon(
                        Icons.location_on,
                        size: 16,
                        color: AppColors.primaryBlue,
                      ),
                      const SizedBox(width: AppSpacing.xs),
                      Text(
                        '${distance!.toStringAsFixed(1)} km',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.primaryBlue,
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),

                // Nome
                Text(
                  name,
                  style: AppTextStyles.h4,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),

                // Endereço
                if (address != null) ...[
                  const SizedBox(height: AppSpacing.xs),
                  Row(
                    children: [
                      Icon(
                        Icons.place_outlined,
                        size: 16,
                        color: AppColors.darkGrayWithOpacity(0.6),
                      ),
                      const SizedBox(width: AppSpacing.xs),
                      Expanded(
                        child: Text(
                          address!,
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.darkGrayWithOpacity(0.7),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],

                // Telefone
                if (phone != null) ...[
                  const SizedBox(height: AppSpacing.xs),
                  Row(
                    children: [
                      Icon(
                        Icons.phone_outlined,
                        size: 16,
                        color: AppColors.darkGrayWithOpacity(0.6),
                      ),
                      const SizedBox(width: AppSpacing.xs),
                      Text(
                        phone!,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.darkGrayWithOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Card de benefício
class BenefitCard extends StatelessWidget {
  final String title;
  final String description;
  final String? discount;
  final IconData icon;
  final VoidCallback? onTap;

  const BenefitCard({
    super.key,
    required this.title,
    required this.description,
    this.discount,
    required this.icon,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return CustomCard(
      onTap: onTap,
      child: Row(
        children: [
          // Ícone
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.primaryBlueWithOpacity(0.1),
              borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
            ),
            child: Icon(
              icon,
              size: 32,
              color: AppColors.primaryBlue,
            ),
          ),
          const SizedBox(width: AppSpacing.md),

          // Conteúdo
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.h4,
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  description,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.darkGrayWithOpacity(0.7),
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),

          // Desconto
          if (discount != null) ...[
            const SizedBox(width: AppSpacing.sm),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.sm,
                vertical: AppSpacing.xs,
              ),
              decoration: BoxDecoration(
                color: AppColors.success,
                borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
              ),
              child: Text(
                discount!,
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
