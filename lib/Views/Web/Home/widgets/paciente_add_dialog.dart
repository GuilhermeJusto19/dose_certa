import 'package:flutter/material.dart';
import 'package:dose_certa/_Core/theme/app_colors.dart';
import 'package:dose_certa/_Core/theme/app_text_style.dart';

/// Dialog para adicionar um paciente via ID do usuário.
///
/// Retorna o ID do usuário se confirmado, ou null se cancelado.
class PacienteAddDialog extends StatefulWidget {
  const PacienteAddDialog({super.key});

  @override
  State<PacienteAddDialog> createState() => _PacienteAddDialogState();
}

class _PacienteAddDialogState extends State<PacienteAddDialog> {
  final _formKey = GlobalKey<FormState>();
  final _usuarioIdController = TextEditingController();

  @override
  void dispose() {
    _usuarioIdController.dispose();
    super.dispose();
  }

  void _onSalvar() {
    if (_formKey.currentState?.validate() ?? false) {
      Navigator.pop(context, _usuarioIdController.text.trim());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 500),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Adicionar Paciente',
                  style: AppTextStyles.semibold20.copyWith(
                    color: AppColors.mainTextColor,
                  ),
                ),
                const SizedBox(height: 24),
                _buildUsuarioIdField(),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancelar'),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      onPressed: _onSalvar,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.blueAccent,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Adicionar'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildUsuarioIdField() {
    return TextFormField(
      controller: _usuarioIdController,
      decoration: InputDecoration(
        labelText: 'ID do Usuário',
        hintText: 'Insira o ID do usuário',
        filled: true,
        fillColor: Colors.grey[50],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.blueAccent, width: 2),
        ),
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Por favor, insira o ID do usuário';
        }
        return null;
      },
    );
  }
}
