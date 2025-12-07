import 'package:flutter/material.dart';

import 'package:dose_certa/_Core/theme/app_colors.dart';
import 'package:dose_certa/_Core/theme/app_text_style.dart';

/// Seção com header e botão de adicionar para listas.
///
/// Layout reutilizável para exibir listas de entidades (pacientes, doutores).
class ListaSection extends StatelessWidget {
  const ListaSection({
    super.key,
    required this.titulo,
    required this.onAdicionar,
    required this.child,
  });

  final String titulo;
  final VoidCallback onAdicionar;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 600),
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [_buildHeader(), const Divider(height: 1), child],
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            titulo,
            style: AppTextStyles.semibold20.copyWith(
              color: AppColors.mainTextColor,
            ),
          ),
          ElevatedButton.icon(
            onPressed: onAdicionar,
            icon: const Icon(Icons.add, size: 20),
            label: const Text('Adicionar'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.blueAccent,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
