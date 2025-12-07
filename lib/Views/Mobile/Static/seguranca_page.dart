import 'package:dose_certa/Views/_shared/custom_back_button.dart';
import 'package:dose_certa/_Core/theme/app_colors.dart';
import 'package:dose_certa/_Core/theme/app_text_style.dart';
import 'package:flutter/material.dart';

class SegurancaPage extends StatelessWidget {
  const SegurancaPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.mainBackground,
      appBar: AppBar(
        leading: CustomBackButton(),
        backgroundColor: AppColors.mainBackground,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(30, 16, 30, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Segurança",
              style: AppTextStyles.bold30.copyWith(
                color: AppColors.mainTextColor,
              ),
            ),

            SizedBox(height: 16),
            Text(
              "Proteção dos Dados",
              style: AppTextStyles.semibold20.copyWith(
                color: AppColors.mainTextColor,
              ),
            ),
            SizedBox(height: 8),
            Text(
              "Todos os dados armazenados no aplicativo são criptografados durante o trânsito e em repouso, garantindo confidencialidade.",
              style: AppTextStyles.medium14.copyWith(color: AppColors.black),
            ),

            SizedBox(height: 16),
            Text(
              "Acesso Seguro",
              style: AppTextStyles.semibold20.copyWith(
                color: AppColors.mainTextColor,
              ),
            ),
            SizedBox(height: 8),
            Text(
              "O app utiliza métodos seguros de autenticação e validação, impedindo acessos não autorizados à sua conta.",
              style: AppTextStyles.medium14.copyWith(color: AppColors.black),
            ),

            SizedBox(height: 16),
            Text(
              "Armazenamento Local",
              style: AppTextStyles.semibold20.copyWith(
                color: AppColors.mainTextColor,
              ),
            ),
            SizedBox(height: 8),
            Text(
              "Nenhuma informação sensível é armazenada sem proteção no dispositivo do usuário.",
              style: AppTextStyles.medium14.copyWith(color: AppColors.black),
            ),

            SizedBox(height: 16),
            Text(
              "Boas Práticas Recomendadas",
              style: AppTextStyles.semibold20.copyWith(
                color: AppColors.mainTextColor,
              ),
            ),
            SizedBox(height: 8),
            Text(
              "• Utilize senha forte no dispositivo\n"
              "• Mantenha o sistema atualizado\n"
              "• Não compartilhe seu aparelho com terceiros",
              style: AppTextStyles.medium14.copyWith(color: AppColors.black),
            ),
          ],
        ),
      ),
    );
  }
}
