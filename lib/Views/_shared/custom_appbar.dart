import 'package:flutter/material.dart';

import 'package:dose_certa/_Core/theme/app_colors.dart';
import 'package:dose_certa/_Core/theme/app_text_style.dart';
import 'package:dose_certa/_Core/utils/utils.dart';

/// Barra de aplicativo customizada usada nas telas principais.
///
/// Exibe uma saudação ao usuário (nome capitalizado) e um ícone de
/// notificações que navega para a rota `/notificacoes` ao ser tocado.
///
/// Observações:
/// - Mantive a implementação e comportamento originais; as mudanças
///   aqui são apenas de legibilidade e documentação.
class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  /// Nome do usuário exibido na saudação.
  final String name;

  const CustomAppBar({super.key, required this.name});

  @override
  Widget build(BuildContext context) {
    final String userName = Utils.capitalize(name);

    return AppBar(
      backgroundColor: AppColors.mainBackground,
      title: RichText(
        text: TextSpan(
          style: TextStyle(color: AppColors.mainTextColor),
          children: [
            TextSpan(text: 'Olá, ', style: AppTextStyles.medium20),
            TextSpan(text: '$userName!', style: AppTextStyles.bold20),
          ],
        ),
      ),
      actions: [_buildNotificationIcon(context)],
    );
  }

  /// Constrói o botão de notificações com estilo consistente.
  ///
  /// Ao pressionar, realiza navegação para a rota de notificações.
  Widget _buildNotificationIcon(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 28),
      child: InkWell(
        onTap: () => Navigator.pushNamed(context, '/notificacoes'),
        child: Ink(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: AppColors.gray400,
            border: Border.all(color: AppColors.gray200),
          ),
          child: Image.asset(
            'assets/icons/notification.png',
            scale: 1.2,
            color: AppColors.grayDarkest,
          ),
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
