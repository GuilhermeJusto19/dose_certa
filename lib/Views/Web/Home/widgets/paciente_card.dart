import 'package:flutter/material.dart';

import 'package:dose_certa/Models/Models/paciente.dart';
import 'package:dose_certa/_Core/theme/app_colors.dart';
import 'package:dose_certa/_Core/theme/app_text_style.dart';
import 'package:dose_certa/_Core/utils/utils.dart';

/// Card que exibe informações de um paciente.
///
/// Contém nome, sobrenome e botão de deletar.
class PacienteCard extends StatelessWidget {
  const PacienteCard({
    super.key,
    required this.paciente,
    required this.onDelete,
    this.onTap,
  });

  final Paciente paciente;
  final VoidCallback onDelete;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
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
                      '${Utils.capitalize(paciente.name)} ${Utils.capitalize(paciente.sobrenome)}',
                      style: AppTextStyles.semibold16.copyWith(
                        color: AppColors.mainTextColor,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline, color: Colors.red),
                onPressed: onDelete,
                tooltip: 'Deletar paciente',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
