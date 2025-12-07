import 'package:flutter/material.dart';

import 'package:dose_certa/_Core/theme/app_colors.dart';
import 'package:dose_certa/_Core/theme/app_text_style.dart';

/// Botão primário reutilizável usado na interface.
class PrimaryButton extends StatelessWidget {
  /// Texto exibido no botão.
  final String text;

  /// Ícone opcional exibido ao lado do texto.
  final IconData? icon;

  /// Habilita visualmente (ou não) a interação. Mantido para compatibilidade.
  ///
  final bool isEnabled;

  /// Callback executado quando o botão é pressionado.
  final VoidCallback onTap;

  /// Cor de fundo opcional do botão.
  final Color? color;

  /// Cor do texto opcional.
  final Color? textColor;

  const PrimaryButton({
    super.key,
    required this.text,
    this.icon,
    this.isEnabled = true,
    required this.onTap,
    this.color,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        // Mantém a chamada original como antes (compatibilidade).
        onTap();
      },
      child: Ink(
        height: 50,
        width: 360,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(11),
          color: color ?? AppColors.bluePrimary,
          boxShadow: kElevationToShadow[3],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              text,
              style: AppTextStyles.semibold20.copyWith(
                color: textColor ?? AppColors.white,
              ),
            ),
            if (icon != null) ...[
              const SizedBox(width: 8),
              Icon(icon, color: AppColors.grayDarkest),
            ] else
              const SizedBox.shrink(),
          ],
        ),
      ),
    );
  }
}
