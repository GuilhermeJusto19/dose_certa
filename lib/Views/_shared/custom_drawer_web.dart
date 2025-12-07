import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'package:dose_certa/viewmodels/mobile/clinica_viewmodel.dart';
import 'package:dose_certa/Views/_shared/custom_snackbars.dart';
import 'package:dose_certa/_Core/theme/app_colors.dart';
import 'package:dose_certa/_Core/theme/app_text_style.dart';

/// Drawer personalizado para a versão Web da aplicação.
///
/// Contém menu lateral com informações da clínica logada e opções
/// de logout e exclusão de conta.
class CustomDrawerWeb extends StatelessWidget {
  CustomDrawerWeb({super.key, required this.buildContext});

  final BuildContext buildContext;
  final ClinicaViewModel _clinicaController = ClinicaViewModel();

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [_buildDrawerHeader(), _buildDrawerOptions()],
      ),
    );
  }

  /// Cabeçalho do drawer com informações da clínica.
  Widget _buildDrawerHeader() {
    final clinica = _clinicaController.currentClinica;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 80, 8, 10),
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 25,
                backgroundColor: AppColors.gray200,
                child: const Icon(
                  Icons.business,
                  size: 30,
                  color: AppColors.bluePrimary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  clinica?.name ?? 'Clínica',
                  style: AppTextStyles.semibold20,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Text(
                "ID: ${clinica?.id ?? ''}",
                style: AppTextStyles.semibold11.copyWith(
                  color: AppColors.gray600,
                ),
              ),
              IconButton(
                padding: EdgeInsets.zero,
                icon: Icon(Icons.copy, color: AppColors.mainTextColor),
                onPressed: () {
                  if (clinica?.id != null) {
                    // Copiar ID para área de transferência
                    // Nota: na web, pode ser necessário usar package específico
                    CustomSnackbars().successSnackbar(
                      message: "ID: ${clinica!.id}",
                      context: buildContext,
                    );
                  }
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Opções do drawer: Sair e Deletar Conta.
  Widget _buildDrawerOptions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 8),
          child: Divider(color: AppColors.gray600),
        ),
        const Padding(
          padding: EdgeInsets.only(top: 30, left: 25, bottom: 20),
          child: Text("Conta", style: AppTextStyles.semibold20),
        ),
        _optionRow(
          icon: Icons.logout_outlined,
          label: 'Sair',
          onTap: _onLogoutTap,
        ),
        _optionRow(
          icon: Icons.delete_outline,
          label: 'Deletar Conta',
          onTap: _onDeleteAccountTap,
        ),
      ],
    );
  }

  /// Helper reutilizável para uma linha de opção do drawer.
  Widget _optionRow({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Row(
      children: [
        const SizedBox(width: 25),
        Icon(icon, color: AppColors.bluePrimary),
        TextButton(
          onPressed: onTap,
          child: Text(
            label,
            style: AppTextStyles.semibold16.copyWith(
              color: AppColors.mainTextColor,
            ),
          ),
        ),
      ],
    );
  }

  /// Efetua logout da clínica.
  void _onLogoutTap() async {
    _clinicaController
        .logout()
        .then((_) {
          if (!buildContext.mounted) return;
          if (Navigator.canPop(buildContext)) {
            Navigator.popUntil(buildContext, (route) => route.isFirst);
            Navigator.pushReplacementNamed(buildContext, '/home');
          } else {
            Navigator.pushReplacementNamed(buildContext, '/home');
          }
        })
        .catchError((error) {
          if (!buildContext.mounted) return;
          CustomSnackbars().errorSnackbar(
            message: (error is FirebaseAuthException)
                ? (error.message ?? 'Erro ao sair')
                : error.toString(),
            context: buildContext,
          );
        });
  }

  /// Solicita confirmação e deleta a conta da clínica.
  void _onDeleteAccountTap() async {
    final confirmed = await showDialog<bool>(
      context: buildContext,
      builder: (context) => AlertDialog(
        title: const Text('Deletar Conta'),
        content: const Text(
          'Tem certeza que deseja deletar sua conta? Esta ação não pode ser desfeita.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Deletar'),
          ),
        ],
      ),
    );

    if (confirmed != true || !buildContext.mounted) return;

    _clinicaController
        .deleteAccount()
        .then((_) {
          if (!buildContext.mounted) return;
          CustomSnackbars().successSnackbar(
            message: 'Conta deletada com sucesso',
            context: buildContext,
          );
          Navigator.pushReplacementNamed(buildContext, '/home');
        })
        .catchError((error) {
          if (!buildContext.mounted) return;
          CustomSnackbars().errorSnackbar(
            message: (error is FirebaseAuthException)
                ? (error.message ?? 'Erro ao deletar conta')
                : error.toString(),
            context: buildContext,
          );
        });
  }
}
