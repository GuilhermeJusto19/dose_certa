import 'package:flutter/material.dart';

import 'package:dose_certa/_Core/theme/app_text_style.dart';

class EmptyScreen extends StatelessWidget {
  const EmptyScreen({
    super.key,
    this.imagePath,
    this.scale,
    this.title,
    this.message,
  });

  final String? imagePath;
  final double? scale;
  final String? title;
  final String? message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            (imagePath != null) ? imagePath! : "assets/images/empty_screen.png",
            scale: (scale != null) ? scale! : 0.8,
          ),
          const SizedBox(height: 20),
          Text(
            (title != null) ? title! : "Vamos Começar",
            style: AppTextStyles.bold20,
          ),
          Padding(
            padding: EdgeInsets.symmetric(vertical: 10, horizontal: 60),
            child: Text(
              (message != null)
                  ? message!
                  : "Adicione novos itens para receber lembretes, acompanhar seu estoque, visualizar seu progresso e muito mais",
              style: AppTextStyles.medium14,
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}
