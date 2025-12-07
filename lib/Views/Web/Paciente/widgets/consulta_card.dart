import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:dose_certa/Models/Models/consulta.dart';
import 'package:dose_certa/_Core/theme/app_colors.dart';
import 'package:dose_certa/_Core/theme/app_text_style.dart';

/// Card que exibe informações de uma consulta.
class ConsultaCard extends StatelessWidget {
  const ConsultaCard({
    super.key,
    required this.consulta,
    required this.onDelete,
    required this.onEdit,
  });

  final Consulta consulta;
  final VoidCallback onDelete;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm');

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
                      consulta.name,
                      style: AppTextStyles.semibold16.copyWith(
                        color: AppColors.mainTextColor,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${consulta.doctor ?? 'Sem médico'} - ${dateFormat.format(consulta.dateTime)}',
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
                tooltip: 'Deletar consulta',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
