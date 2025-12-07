import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import 'package:dose_certa/Models/Models/doutor.dart';
import 'package:dose_certa/_Core/theme/app_colors.dart';
import 'package:dose_certa/_Core/theme/app_text_style.dart';

/// Dialog para criar ou editar um doutor.
///
/// Quando `editando` é true, os campos são preenchidos com os dados do doutor.
class DoutorFormDialog extends StatefulWidget {
  const DoutorFormDialog({super.key, this.doutor, this.editando = false});

  final Doutor? doutor;
  final bool editando;

  @override
  State<DoutorFormDialog> createState() => _DoutorFormDialogState();
}

class _DoutorFormDialogState extends State<DoutorFormDialog> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late final TextEditingController _nomeController;
  late final TextEditingController _especialidadeController;

  @override
  void initState() {
    super.initState();
    _nomeController = TextEditingController(
      text: widget.editando ? widget.doutor?.nome : '',
    );
    _especialidadeController = TextEditingController(
      text: widget.editando ? widget.doutor?.especialidade : '',
    );
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _especialidadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 500),
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildTitle(),
              const SizedBox(height: 24),
              _buildNomeField(),
              const SizedBox(height: 16),
              _buildEspecialidadeField(),
              const SizedBox(height: 24),
              _buildActions(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTitle() {
    return Text(
      widget.editando ? 'Editar Doutor' : 'Adicionar Doutor',
      style: AppTextStyles.semibold20.copyWith(color: AppColors.mainTextColor),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildNomeField() {
    return TextFormField(
      controller: _nomeController,
      decoration: InputDecoration(
        labelText: 'Nome',
        hintText: 'Digite o nome do doutor',
        labelStyle: const TextStyle(color: AppColors.gray600, fontSize: 16),
        filled: true,
        fillColor: Colors.grey[50],
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 18,
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.grey[300]!, width: 1),
          borderRadius: BorderRadius.circular(12),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: AppColors.blueAccent, width: 2),
          borderRadius: BorderRadius.circular(12),
        ),
        errorBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.red, width: 1),
          borderRadius: BorderRadius.circular(12),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.red, width: 2),
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Digite o nome do doutor';
        }
        return null;
      },
    );
  }

  Widget _buildEspecialidadeField() {
    return TextFormField(
      controller: _especialidadeController,
      decoration: InputDecoration(
        labelText: 'Especialidade',
        hintText: 'Digite a especialidade',
        labelStyle: const TextStyle(color: AppColors.gray600, fontSize: 16),
        filled: true,
        fillColor: Colors.grey[50],
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 18,
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.grey[300]!, width: 1),
          borderRadius: BorderRadius.circular(12),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: AppColors.blueAccent, width: 2),
          borderRadius: BorderRadius.circular(12),
        ),
        errorBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.red, width: 1),
          borderRadius: BorderRadius.circular(12),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.red, width: 2),
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Digite a especialidade';
        }
        return null;
      },
    );
  }

  Widget _buildActions() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Cancelar', style: TextStyle(color: AppColors.gray600)),
        ),
        const SizedBox(width: 8),
        ElevatedButton(
          onPressed: _onSalvar,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.blueAccent,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: Text(widget.editando ? 'Salvar' : 'Adicionar'),
        ),
      ],
    );
  }

  void _onSalvar() {
    if (_formKey.currentState!.validate()) {
      final doutor = Doutor(
        id: widget.editando ? widget.doutor!.id : const Uuid().v1(),
        nome: _nomeController.text.trim(),
        especialidade: _especialidadeController.text.trim(),
      );
      Navigator.pop(context, doutor);
    }
  }
}
