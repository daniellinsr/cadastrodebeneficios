import 'package:flutter/material.dart';
import 'package:cadastro_beneficios/core/theme/app_colors.dart';
import 'package:cadastro_beneficios/core/theme/app_spacing.dart';

/// Tipos de botão disponíveis
enum CustomButtonType {
  primary,
  secondary,
  outline,
  text,
  whatsapp,
  success,
  error,
}

/// Tamanhos de botão
enum CustomButtonSize {
  small,
  medium,
  large,
}

/// Botão customizado com variações de estilo
class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final CustomButtonType type;
  final CustomButtonSize size;
  final IconData? icon;
  final bool isLoading;
  final bool isFullWidth;
  final bool isEnabled;

  const CustomButton({
    super.key,
    required this.text,
    this.onPressed,
    this.type = CustomButtonType.primary,
    this.size = CustomButtonSize.medium,
    this.icon,
    this.isLoading = false,
    this.isFullWidth = false,
    this.isEnabled = true,
  });

  /// Botão primário (atalho)
  const CustomButton.primary({
    super.key,
    required this.text,
    this.onPressed,
    this.size = CustomButtonSize.medium,
    this.icon,
    this.isLoading = false,
    this.isFullWidth = false,
    this.isEnabled = true,
  }) : type = CustomButtonType.primary;

  /// Botão outline (atalho)
  const CustomButton.outline({
    super.key,
    required this.text,
    this.onPressed,
    this.size = CustomButtonSize.medium,
    this.icon,
    this.isLoading = false,
    this.isFullWidth = false,
    this.isEnabled = true,
  }) : type = CustomButtonType.outline;

  /// Botão WhatsApp (atalho)
  const CustomButton.whatsapp({
    super.key,
    required this.text,
    this.onPressed,
    this.size = CustomButtonSize.medium,
    this.icon,
    this.isLoading = false,
    this.isFullWidth = false,
    this.isEnabled = true,
  }) : type = CustomButtonType.whatsapp;

  /// Botão de sucesso (atalho)
  const CustomButton.success({
    super.key,
    required this.text,
    this.onPressed,
    this.size = CustomButtonSize.medium,
    this.icon,
    this.isLoading = false,
    this.isFullWidth = false,
    this.isEnabled = true,
  }) : type = CustomButtonType.success;

  @override
  Widget build(BuildContext context) {
    final buttonChild = _buildButtonChild();
    final buttonStyle = _getButtonStyle();
    final effectiveOnPressed = (isEnabled && !isLoading) ? onPressed : null;

    Widget button;

    // Escolhe o tipo de botão baseado no type
    switch (type) {
      case CustomButtonType.outline:
        button = OutlinedButton(
          onPressed: effectiveOnPressed,
          style: buttonStyle,
          child: buttonChild,
        );
        break;
      case CustomButtonType.text:
        button = TextButton(
          onPressed: effectiveOnPressed,
          style: buttonStyle,
          child: buttonChild,
        );
        break;
      default:
        button = ElevatedButton(
          onPressed: effectiveOnPressed,
          style: buttonStyle,
          child: buttonChild,
        );
    }

    return isFullWidth
        ? SizedBox(
            width: double.infinity,
            child: button,
          )
        : button;
  }

  Widget _buildButtonChild() {
    if (isLoading) {
      return SizedBox(
        height: _getIconSize(),
        width: _getIconSize(),
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(
            _getLoadingColor(),
          ),
        ),
      );
    }

    if (icon != null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: _getIconSize()),
          const SizedBox(width: AppSpacing.sm),
          Text(text),
        ],
      );
    }

    return Text(text);
  }

  ButtonStyle _getButtonStyle() {
    final colors = _getColors();
    final padding = _getPadding();
    final textStyle = _getTextStyle();

    return ElevatedButton.styleFrom(
      backgroundColor: colors.background,
      foregroundColor: colors.foreground,
      disabledBackgroundColor: colors.disabledBackground,
      disabledForegroundColor: colors.disabledForeground,
      padding: padding,
      textStyle: textStyle,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
        side: colors.borderSide ?? BorderSide.none,
      ),
      elevation: type == CustomButtonType.outline || type == CustomButtonType.text
          ? 0
          : AppSpacing.elevation2,
    );
  }

  _ButtonColors _getColors() {
    switch (type) {
      case CustomButtonType.primary:
        return _ButtonColors(
          background: AppColors.primaryBlue,
          foreground: AppColors.white,
          disabledBackground: AppColors.primaryBlueWithOpacity(0.5),
          disabledForeground: AppColors.whiteWithOpacity(0.7),
        );
      case CustomButtonType.secondary:
        return _ButtonColors(
          background: AppColors.darkGray,
          foreground: AppColors.white,
          disabledBackground: AppColors.darkGrayWithOpacity(0.5),
          disabledForeground: AppColors.whiteWithOpacity(0.7),
        );
      case CustomButtonType.outline:
        return _ButtonColors(
          background: Colors.transparent,
          foreground: AppColors.primaryBlue,
          disabledBackground: Colors.transparent,
          disabledForeground: AppColors.primaryBlueWithOpacity(0.5),
          borderSide: const BorderSide(color: AppColors.primaryBlue, width: 2),
        );
      case CustomButtonType.text:
        return _ButtonColors(
          background: Colors.transparent,
          foreground: AppColors.primaryBlue,
          disabledBackground: Colors.transparent,
          disabledForeground: AppColors.primaryBlueWithOpacity(0.5),
        );
      case CustomButtonType.whatsapp:
        return _ButtonColors(
          background: AppColors.whatsapp,
          foreground: AppColors.white,
          disabledBackground: AppColors.whatsapp.withValues(alpha: 0.5),
          disabledForeground: AppColors.whiteWithOpacity(0.7),
        );
      case CustomButtonType.success:
        return _ButtonColors(
          background: AppColors.success,
          foreground: AppColors.white,
          disabledBackground: AppColors.success.withValues(alpha: 0.5),
          disabledForeground: AppColors.whiteWithOpacity(0.7),
        );
      case CustomButtonType.error:
        return _ButtonColors(
          background: AppColors.error,
          foreground: AppColors.white,
          disabledBackground: AppColors.error.withValues(alpha: 0.5),
          disabledForeground: AppColors.whiteWithOpacity(0.7),
        );
    }
  }

  EdgeInsets _getPadding() {
    switch (size) {
      case CustomButtonSize.small:
        return const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        );
      case CustomButtonSize.medium:
        return const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        );
      case CustomButtonSize.large:
        return const EdgeInsets.symmetric(
          horizontal: AppSpacing.xl,
          vertical: AppSpacing.lg,
        );
    }
  }

  TextStyle _getTextStyle() {
    final fontSize = size == CustomButtonSize.small
        ? 14.0
        : size == CustomButtonSize.medium
            ? 16.0
            : 18.0;

    return TextStyle(
      fontSize: fontSize,
      fontWeight: FontWeight.w600,
    );
  }

  double _getIconSize() {
    switch (size) {
      case CustomButtonSize.small:
        return 16.0;
      case CustomButtonSize.medium:
        return 20.0;
      case CustomButtonSize.large:
        return 24.0;
    }
  }

  Color _getLoadingColor() {
    if (type == CustomButtonType.outline || type == CustomButtonType.text) {
      return AppColors.primaryBlue;
    }
    return AppColors.white;
  }
}

/// Classe auxiliar para cores do botão
class _ButtonColors {
  final Color background;
  final Color foreground;
  final Color disabledBackground;
  final Color disabledForeground;
  final BorderSide? borderSide;

  _ButtonColors({
    required this.background,
    required this.foreground,
    required this.disabledBackground,
    required this.disabledForeground,
    this.borderSide,
  });
}
