import 'package:dose_certa/Views/_shared/primary_button.dart';
import 'package:dose_certa/_Core/theme/app_colors.dart';
import 'package:dose_certa/_Core/theme/app_text_style.dart';
import 'package:flutter/material.dart';

//* Tela Finalizada: Welcome Page, redireciona para o Login.
class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Ink(
        decoration: _buildBackgroundDecoration(),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 26),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildImage(),
                const SizedBox(height: 20),
                _buildDescription(),
                const SizedBox(height: 20),
                _buildStartButton(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  BoxDecoration _buildBackgroundDecoration() {
    return const BoxDecoration(color: AppColors.bluePrimary);
  }

  Widget _buildImage() {
    return Image.asset(
      "assets/images/logo.png",
      semanticLabel: "Welcome Image",
    );
  }

  Widget _buildDescription() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Text(
        "Seu cuidado com a saúde começa aqui: organize seus medicamentos com facilidade.",
        style: AppTextStyles.medium20.copyWith(color: Colors.white),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildStartButton(BuildContext context) {
    return PrimaryButton(
      text: "Quero começar !",
      color: AppColors.white,
      textColor: AppColors.mainTextColor,
      onTap: () => Navigator.pushReplacementNamed(context, "Login"),
    );
  }
}
