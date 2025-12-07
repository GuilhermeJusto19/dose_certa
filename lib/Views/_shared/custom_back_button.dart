import 'package:flutter/material.dart';

import 'package:dose_certa/_Core/theme/app_colors.dart';

/// Botão de voltar customizado usado nas telas do app.
///
/// Implementação simples que preserva o comportamento original: chama
/// `Navigator.pop(context)` quando pressionado. Melhorei a legibilidade e
/// organizei imports sem alterar o comportamento.
class CustomBackButton extends StatelessWidget {
  const CustomBackButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Container(
        width: 38,
        height: 36,
        decoration: BoxDecoration(
          color: AppColors.gray400,
          borderRadius: BorderRadius.circular(15),
        ),
        child: Center(
          child: IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back_ios),
            color: AppColors.grayDarkest,
            iconSize: 18,
            padding: const EdgeInsets.only(left: 4),
            constraints: const BoxConstraints(),
          ),
        ),
      ),
    );
  }
}
