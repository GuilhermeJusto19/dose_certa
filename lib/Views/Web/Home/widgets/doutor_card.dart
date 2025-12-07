import 'package:dose_certa/_Core/utils/utils.dart';
import 'package:flutter/material.dart';

import 'package:dose_certa/Models/Models/doutor.dart';
import 'package:dose_certa/_Core/theme/app_colors.dart';
import 'package:dose_certa/_Core/theme/app_text_style.dart';

/// Card que exibe informações de um doutor.
///
/// Contém nome, especialidade, botão de deletar e ação de editar ao clicar.
class DoutorCard extends StatelessWidget {
  const DoutorCard({
    super.key,
    required this.doutor,
    required this.onDelete,
    required this.onEdit,
  });

  final Doutor doutor;
  final VoidCallback onDelete;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onEdit,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      Utils.capitalizeTitle(doutor.nome),
                      style: AppTextStyles.semibold16.copyWith(
                        color: AppColors.mainTextColor,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      Utils.capitalizeTitle(doutor.especialidade),
                      style: AppTextStyles.medium14.copyWith(
                        color: AppColors.gray600,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline, color: Colors.red),
                onPressed: onDelete,
                tooltip: 'Deletar doutor',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
