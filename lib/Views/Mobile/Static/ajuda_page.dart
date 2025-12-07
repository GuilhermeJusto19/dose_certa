import 'package:dose_certa/Views/_shared/custom_back_button.dart';
import 'package:dose_certa/_Core/theme/app_colors.dart';
import 'package:dose_certa/_Core/theme/app_text_style.dart';
import 'package:flutter/material.dart';

class AjudaPage extends StatelessWidget {
  const AjudaPage({super.key});

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
              "Ajuda & Suporte",
              style: AppTextStyles.bold30.copyWith(
                color: AppColors.mainTextColor,
              ),
            ),

            SizedBox(height: 16),
            Text(
              "Perguntas Frequentes",
              style: AppTextStyles.semibold20.copyWith(
                color: AppColors.mainTextColor,
              ),
            ),
            Text(
              "• Como cadastrar um medicamento?\n"
              "• Como funcionam os lembretes?\n"
              "• É possível gerar relatórios em PDF?",
              style: AppTextStyles.medium14.copyWith(color: AppColors.black),
            ),

            SizedBox(height: 16),
            Text(
              "Contato com Suporte",
              style: AppTextStyles.semibold20.copyWith(
                color: AppColors.mainTextColor,
              ),
            ),
            Text(
              "Em caso de dúvidas ou problemas, entre em contato através de:",
              style: AppTextStyles.medium14.copyWith(color: AppColors.black),
            ),
            Text(
              "• E-mail: suporte@app.com\n"
              "• WhatsApp: (00) 90000-0000",
              style: AppTextStyles.medium14.copyWith(color: AppColors.black),
            ),

            SizedBox(height: 16),
            Text(
              "Guia Rápido",
              style: AppTextStyles.semibold20.copyWith(
                color: AppColors.mainTextColor,
              ),
            ),
            Text(
              "• Adicione seus medicamentos\n"
              "• Ative notificações de lembrete\n"
              "• Registre as tarefas realizadas\n"
              "• Gere relatórios para acompanhamento médico",
              style: AppTextStyles.medium14.copyWith(color: AppColors.black),
            ),

            SizedBox(height: 16),
            Text(
              "Feedback",
              style: AppTextStyles.semibold20.copyWith(
                color: AppColors.mainTextColor,
              ),
            ),
            Text(
              "Ajude-nos a melhorar enviando sugestões diretamente pelo aplicativo.",
              style: AppTextStyles.medium14.copyWith(color: AppColors.black),
            ),
          ],
        ),
      ),
    );
  }
}
