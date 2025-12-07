import 'package:dose_certa/Views/_shared/custom_back_button.dart';
import 'package:dose_certa/_Core/theme/app_colors.dart';
import 'package:dose_certa/_Core/theme/app_text_style.dart';
import 'package:flutter/material.dart';

class TermosPage extends StatelessWidget {
  const TermosPage({super.key});

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
              "Termos de Serviço",
              style: AppTextStyles.bold30.copyWith(
                color: AppColors.mainTextColor,
              ),
            ),

            SizedBox(height: 16),
            Text(
              "Aceitação dos Termos",
              style: AppTextStyles.semibold20.copyWith(
                color: AppColors.mainTextColor,
              ),
            ),
            Text(
              "Ao utilizar este aplicativo, você concorda com as condições descritas "
              "neste documento.",
              style: AppTextStyles.medium14.copyWith(color: AppColors.black),
            ),

            SizedBox(height: 16),
            Text(
              "Uso Permitido",
              style: AppTextStyles.semibold20.copyWith(
                color: AppColors.mainTextColor,
              ),
            ),
            Text(
              "O app deve ser utilizado apenas para fins pessoais de organização "
              "e acompanhamento de medicamentos e tarefas.",
              style: AppTextStyles.medium14.copyWith(color: AppColors.black),
            ),

            SizedBox(height: 16),
            Text(
              "Responsabilidades do Usuário",
              style: AppTextStyles.semibold20.copyWith(
                color: AppColors.mainTextColor,
              ),
            ),
            Text(
              "• Inserir dados corretos\n"
              "• Manter o dispositivo seguro\n"
              "• Utilizar o app de forma legal",
              style: AppTextStyles.medium14.copyWith(color: AppColors.black),
            ),

            SizedBox(height: 16),
            Text(
              "Limitação de Responsabilidade",
              style: AppTextStyles.semibold20.copyWith(
                color: AppColors.mainTextColor,
              ),
            ),
            Text(
              "O aplicativo não substitui acompanhamento médico. Decisões de saúde "
              "devem sempre ser tomadas com profissionais habilitados.",
              style: AppTextStyles.medium14.copyWith(color: AppColors.black),
            ),

            SizedBox(height: 16),
            Text(
              "Alterações nos Termos",
              style: AppTextStyles.semibold20.copyWith(
                color: AppColors.mainTextColor,
              ),
            ),
            Text(
              "Os termos podem ser atualizados periodicamente. Alterações relevantes "
              "serão informadas dentro do aplicativo.",
              style: AppTextStyles.medium14.copyWith(color: AppColors.black),
            ),
          ],
        ),
      ),
    );
  }
}
