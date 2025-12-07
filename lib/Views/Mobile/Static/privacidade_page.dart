import 'package:dose_certa/Views/_shared/custom_back_button.dart';
import 'package:dose_certa/_Core/theme/app_colors.dart';
import 'package:dose_certa/_Core/theme/app_text_style.dart';
import 'package:flutter/material.dart';

class PrivacidadePage extends StatelessWidget {
  const PrivacidadePage({super.key});

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
              "Privacidade",
              style: AppTextStyles.bold30.copyWith(
                color: AppColors.mainTextColor,
              ),
            ),

            SizedBox(height: 16),
            Text(
              "Coleta de Dados",
              style: AppTextStyles.semibold20.copyWith(
                color: AppColors.mainTextColor,
              ),
            ),
            Text(
              "O aplicativo coleta apenas informações necessárias para o "
              "funcionamento adequado, como tarefas, medicamentos e lembretes.",
              style: AppTextStyles.medium14.copyWith(color: AppColors.black),
            ),

            SizedBox(height: 16),
            Text(
              "Uso das Informações",
              style: AppTextStyles.semibold20.copyWith(
                color: AppColors.mainTextColor,
              ),
            ),
            Text(
              "Os dados são usados exclusivamente para melhorar sua experiência "
              "no acompanhamento do tratamento e geração de relatórios.",
              style: AppTextStyles.medium14.copyWith(color: AppColors.black),
            ),

            SizedBox(height: 16),
            Text(
              "Compartilhamento",
              style: AppTextStyles.semibold20.copyWith(
                color: AppColors.mainTextColor,
              ),
            ),
            Text(
              "Nenhuma informação pessoal é compartilhada com terceiros sem sua "
              "autorização expressa.",
              style: AppTextStyles.medium14.copyWith(color: AppColors.black),
            ),

            SizedBox(height: 16),
            Text(
              "Armazenamento e Retenção",
              style: AppTextStyles.semibold20.copyWith(
                color: AppColors.mainTextColor,
              ),
            ),
            Text(
              "Seus dados são armazenados de forma segura e podem ser removidos "
              "definitivamente mediante solicitação.",
              style: AppTextStyles.medium14.copyWith(color: AppColors.black),
            ),

            SizedBox(height: 16),
            Text(
              "Direitos do Usuário (LGPD)",
              style: AppTextStyles.semibold20.copyWith(
                color: AppColors.mainTextColor,
              ),
            ),
            Text(
              "• Acessar seus dados\n"
              "• Corrigir informações\n"
              "• Solicitar exclusão\n"
              "• Revogar consentimento",
              style: AppTextStyles.medium14.copyWith(color: AppColors.black),
            ),
          ],
        ),
      ),
    );
  }
}
