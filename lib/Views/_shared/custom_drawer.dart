import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'package:dose_certa/viewmodels/mobile/user_viewmodel.dart';
import 'package:dose_certa/Views/_shared/custom_snackbars.dart';
import 'package:dose_certa/_Core/theme/app_colors.dart';
import 'package:dose_certa/_Core/theme/app_text_style.dart';
import 'package:dose_certa/_Core/utils/utils.dart';

/// Drawer personalizado usado nas telas que precisam expor o menu lateral
/// com opções de navegação relacionadas à conta do usuário.
///
/// Observações:
/// - Esta implementação preserva a lógica original de navegação e de logout.
/// - Não altera comportamento: apenas melhora legibilidade, organização de
///   imports e extrai um pequeno helper para linhas de opção.
class CustomDrawer extends StatelessWidget {
  /// Cria um [CustomDrawer].
  ///
  /// Os parâmetros devem ser fornecidos pelo widget chamador. `buildContext`
  /// é o contexto do widget pai usado para navegação e exibição de snackbars
  /// (preservado para compatibilidade com o código existente).
  CustomDrawer({
    super.key,
    required this.name,
    required this.photoURL,
    required this.buildContext,
    required this.id,
  });

  final String name;
  final String id;
  final String? photoURL;
  final BuildContext buildContext;

  final UserViewModel _userController = UserViewModel();

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [_buildUserAccountHeader(), _buildOptionsTiles()],
      ),
    );
  }

  /// Cabeçalho com avatar, nome e opção de editar perfil.
  Widget _buildUserAccountHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 80, 8, 10),
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 25,
                backgroundColor: AppColors.gray200,
                backgroundImage: (photoURL != null && photoURL!.isNotEmpty)
                    ? NetworkImage(photoURL!)
                    : null,
                child: (photoURL == null || photoURL!.isEmpty)
                    ? const Icon(Icons.person, size: 30)
                    : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  Utils.capitalize(name),
                  style: AppTextStyles.semibold20,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              IconButton(
                icon: Icon(Icons.edit_outlined, color: AppColors.mainTextColor),
                onPressed: () {
                  Navigator.pushNamed(buildContext, '/perfil');
                },
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Text(
                "ID: $id",
                style: AppTextStyles.semibold11.copyWith(
                  color: AppColors.gray600,
                ),
              ),
              IconButton(
                padding: EdgeInsets.zero,
                icon: Icon(Icons.copy, color: AppColors.mainTextColor),
                onPressed: () {
                  Utils.copyToClipboard(id);
                  CustomSnackbars().successSnackbar(
                    message: "ID copiado para a área de transferência",
                    context: buildContext,
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Constrói a lista de opções do menu.
  Widget _buildOptionsTiles() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 8),
          child: Divider(color: AppColors.gray600),
        ),
        const Padding(
          padding: EdgeInsets.only(top: 10, left: 25, bottom: 10),
          child: Text("Cuidadores", style: AppTextStyles.semibold20),
        ),
        _optionRow(
          icon: Icons.handshake_outlined,
          label: 'Cuidador',
          onTap: () => Navigator.pushNamed(buildContext, '/cuidadores'),
        ),
        const Padding(
          padding: EdgeInsets.only(top: 10, left: 25, bottom: 10),
          child: Text("Clínica", style: AppTextStyles.semibold20),
        ),
        _optionRow(
          icon: Icons.local_hospital_outlined,
          label: 'Minha Clínica',
          onTap: () => Navigator.pushNamed(buildContext, '/clinica'),
        ),
        const Padding(
          padding: EdgeInsets.only(top: 10, left: 25, bottom: 10),
          child: Text("Conta", style: AppTextStyles.semibold20),
        ),
        _optionRow(
          icon: Icons.security_sharp,
          label: 'Segurança',
          onTap: () => Navigator.pushNamed(buildContext, '/seguranca'),
        ),
        _optionRow(
          icon: Icons.lock_outline,
          label: 'Privacidade',
          onTap: () => Navigator.pushNamed(buildContext, '/privacidade'),
        ),
        _optionRow(
          icon: Icons.logout_outlined,
          label: 'Sair',
          onTap: _onExitTap,
        ),
        const Padding(
          padding: EdgeInsets.only(top: 10, left: 25, bottom: 10),
          child: Text("Suporte & Sobre", style: AppTextStyles.semibold20),
        ),
        _optionRow(
          icon: Icons.help_outline,
          label: 'Ajuda & Suporte',
          onTap: () => Navigator.pushNamed(buildContext, '/ajuda'),
        ),
        _optionRow(
          icon: Icons.info_outline,
          label: 'Termos de Serviço',
          onTap: () => Navigator.pushNamed(buildContext, '/termos'),
        ),
        const SizedBox(height: 30),
        Center(
          child: InkWell(
            onTap: () {
              Navigator.pushNamed(buildContext, '/relatorio');
            },
            child: Ink(
              padding: const EdgeInsets.symmetric(vertical: 9, horizontal: 16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                gradient: const LinearGradient(
                  colors: [
                    AppColors.bluePrimary,
                    Color.fromARGB(255, 39, 114, 173),
                  ],
                ),
                boxShadow: kElevationToShadow[3],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "Relatório de Adesão",
                    style: AppTextStyles.semibold15.copyWith(
                      color: AppColors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// Helper reutilizável para uma linha de opção do drawer.
  /// Mantém a mesma disposição visual do código original.
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

  /// Efetua logout através do [UserController] e navega para a tela de Login.
  ///
  /// Observação: mantém a lógica existente que usa [buildContext] e trata
  /// erros exibindo uma snackbar. Não alterei o fluxo para preservar
  /// comportamento anterior.
  void _onExitTap() async {
    _userController
        .logout()
        .then((_) {
          if (!buildContext.mounted) return;
          if (Navigator.canPop(buildContext)) {
            Navigator.popUntil(buildContext, (route) => route.isFirst);
            Navigator.pushReplacementNamed(buildContext, 'Login');
          } else {
            Navigator.pushReplacementNamed(buildContext, 'Login');
          }
        })
        .catchError((error) {
          if (!buildContext.mounted) return;
          CustomSnackbars().errorSnackbar(
            message: (error is FirebaseAuthException) ? error.message : error,
            context: buildContext,
          );
        });
  }
}
