import 'package:flutter/material.dart';
import 'package:cadastro_beneficios/core/theme/app_colors.dart';
import 'package:cadastro_beneficios/core/theme/app_spacing.dart';
import 'package:cadastro_beneficios/core/theme/app_text_styles.dart';

/// Indicador de carregamento simples
class CustomLoadingIndicator extends StatelessWidget {
  final Color? color;
  final double size;

  const CustomLoadingIndicator({
    super.key,
    this.color,
    this.size = 40,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: size,
        height: size,
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(
            color ?? AppColors.primaryBlue,
          ),
          strokeWidth: 3,
        ),
      ),
    );
  }
}

/// Loading com mensagem
class CustomLoadingWithMessage extends StatelessWidget {
  final String message;
  final Color? color;

  const CustomLoadingWithMessage({
    super.key,
    required this.message,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CustomLoadingIndicator(color: color),
          const SizedBox(height: AppSpacing.lg),
          Text(
            message,
            style: AppTextStyles.bodyMedium,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

/// Overlay de loading em tela cheia
class CustomFullScreenLoading extends StatelessWidget {
  final String? message;

  const CustomFullScreenLoading({
    super.key,
    this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.darkGrayWithOpacity(0.7),
      child: Center(
        child: Card(
          margin: const EdgeInsets.all(AppSpacing.xxl),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.xxl),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CustomLoadingIndicator(),
                if (message != null) ...[
                  const SizedBox(height: AppSpacing.lg),
                  Text(
                    message!,
                    style: AppTextStyles.bodyLarge,
                    textAlign: TextAlign.center,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Mostra loading em overlay
  static void show(BuildContext context, {String? message}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => CustomFullScreenLoading(message: message),
    );
  }

  /// Esconde loading
  static void hide(BuildContext context) {
    Navigator.of(context).pop();
  }
}

/// Skeleton loader para cards
class CustomSkeletonLoader extends StatefulWidget {
  final double height;
  final double? width;
  final BorderRadius? borderRadius;

  const CustomSkeletonLoader({
    super.key,
    required this.height,
    this.width,
    this.borderRadius,
  });

  @override
  State<CustomSkeletonLoader> createState() => _CustomSkeletonLoaderState();
}

class _CustomSkeletonLoaderState extends State<CustomSkeletonLoader>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();

    _animation = Tween<double>(begin: -2, end: 2).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          height: widget.height,
          width: widget.width,
          decoration: BoxDecoration(
            borderRadius: widget.borderRadius ??
                BorderRadius.circular(AppSpacing.radiusSm),
            gradient: LinearGradient(
              begin: Alignment(_animation.value, 0),
              end: const Alignment(2, 0),
              colors: [
                AppColors.lightGray,
                AppColors.white,
                AppColors.lightGray,
              ],
              stops: const [0.0, 0.5, 1.0],
            ),
          ),
        );
      },
    );
  }
}

/// Card skeleton para listas
class CustomCardSkeleton extends StatelessWidget {
  const CustomCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Título
            CustomSkeletonLoader(
              height: 20,
              width: MediaQuery.of(context).size.width * 0.6,
            ),
            const SizedBox(height: AppSpacing.sm),
            // Subtítulo
            CustomSkeletonLoader(
              height: 16,
              width: MediaQuery.of(context).size.width * 0.8,
            ),
            const SizedBox(height: AppSpacing.xs),
            CustomSkeletonLoader(
              height: 16,
              width: MediaQuery.of(context).size.width * 0.4,
            ),
            const SizedBox(height: AppSpacing.md),
            // Botão
            CustomSkeletonLoader(
              height: 40,
              width: MediaQuery.of(context).size.width * 0.3,
            ),
          ],
        ),
      ),
    );
  }
}

/// Lista de skeletons para telas de loading
class CustomListSkeleton extends StatelessWidget {
  final int itemCount;

  const CustomListSkeleton({
    super.key,
    this.itemCount = 3,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.all(AppSpacing.md),
      itemCount: itemCount,
      separatorBuilder: (context, index) => const SizedBox(height: AppSpacing.md),
      itemBuilder: (context, index) => const CustomCardSkeleton(),
    );
  }
}
