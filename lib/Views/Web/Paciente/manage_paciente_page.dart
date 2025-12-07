import 'package:flutter/material.dart';
import 'package:dose_certa/Models/Models/consulta.dart';
import 'package:dose_certa/Models/Models/medicamento.dart';
import 'package:dose_certa/Models/Models/paciente.dart';
import 'package:dose_certa/Views/Web/Home/widgets/lista_section.dart';
import 'package:dose_certa/viewmodels/web/manage_paciente_viewmodel.dart';
import 'package:dose_certa/Views/Web/Paciente/widgets/consulta_card.dart';
import 'package:dose_certa/Views/Web/Paciente/widgets/consulta_form_dialog.dart';
import 'package:dose_certa/Views/Web/Paciente/widgets/medicamento_card.dart';
import 'package:dose_certa/Views/Web/Paciente/widgets/medicamento_form_dialog.dart';
import 'package:dose_certa/Views/_shared/custom_snackbars.dart';
import 'package:dose_certa/_Core/theme/app_colors.dart';
import 'package:dose_certa/_Core/theme/app_text_style.dart';
import 'package:dose_certa/_Core/utils/utils.dart';

/// Página de gerenciamento de paciente (Web).
///
/// Exibe medicamentos e consultas do paciente selecionado.
class ManagePacientePage extends StatefulWidget {
  const ManagePacientePage({super.key});

  @override
  State<ManagePacientePage> createState() => _ManagePacientePageState();
}

class _ManagePacientePageState extends State<ManagePacientePage> {
  final ManagePacienteViewmodel _viewModel = ManagePacienteViewmodel();
  Paciente? _paciente;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_paciente == null) {
      _paciente = ModalRoute.of(context)!.settings.arguments as Paciente;
      _viewModel.loadMedicamentos(_paciente!.id);
      _viewModel.loadConsultas(_paciente!.id);
      _viewModel.addListener(_onViewModelChanged);
    }
  }

  @override
  void dispose() {
    _viewModel.removeListener(_onViewModelChanged);
    _viewModel.dispose();
    super.dispose();
  }

  void _onViewModelChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_paciente == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Gerenciar Paciente'),
        backgroundColor: AppColors.bluePrimary,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: Column(
          children: [
            Text(
              '${Utils.capitalize(_paciente!.name)} ${Utils.capitalize(_paciente!.sobrenome)}',
              style: AppTextStyles.bold30.copyWith(
                color: AppColors.mainTextColor,
              ),
            ),
            const SizedBox(height: 32),
            Center(
              child: Wrap(
                spacing: 24,
                runSpacing: 24,
                alignment: WrapAlignment.center,
                children: [
                  _buildMedicamentosSection(),
                  _buildConsultasSection(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Seção de medicamentos com lista dinâmica.
  Widget _buildMedicamentosSection() {
    return ListaSection(
      titulo: 'Medicamentos',
      onAdicionar: _onAdicionarMedicamento,
      child: _viewModel.medicamentos.isEmpty
          ? Container(
              padding: const EdgeInsets.all(32),
              child: const Text(
                'Nenhum medicamento cadastrado',
                style: TextStyle(color: Colors.grey),
              ),
            )
          : ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _viewModel.medicamentos.length,
              itemBuilder: (context, index) {
                final medicamento = _viewModel.medicamentos[index];
                return MedicamentoCard(
                  medicamento: medicamento,
                  onDelete: () => _onDeletarMedicamento(medicamento.id),
                  onEdit: () => _onEditarMedicamento(medicamento),
                );
              },
            ),
    );
  }

  /// Seção de consultas com lista dinâmica.
  Widget _buildConsultasSection() {
    return ListaSection(
      titulo: 'Consultas',
      onAdicionar: _onAdicionarConsulta,
      child: _viewModel.consultas.isEmpty
          ? Container(
              padding: const EdgeInsets.all(32),
              child: const Text(
                'Nenhuma consulta cadastrada',
                style: TextStyle(color: Colors.grey),
              ),
            )
          : ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _viewModel.consultas.length,
              itemBuilder: (context, index) {
                final consulta = _viewModel.consultas[index];
                return ConsultaCard(
                  consulta: consulta,
                  onDelete: () => _onDeletarConsulta(consulta.id),
                  onEdit: () => _onEditarConsulta(consulta),
                );
              },
            ),
    );
  }

  // ========== MEDICAMENTOS ==========

  Future<void> _onAdicionarMedicamento() async {
    final result = await showDialog<Medicamento>(
      context: context,
      builder: (context) =>
          const MedicamentoFormDialog(editando: false, isClinica: true),
    );

    if (result == null || !mounted) return;

    try {
      await _viewModel.addMedicamento(result, _paciente!.id);
      if (!mounted) return;
      CustomSnackbars().successSnackbar(
        message: 'Medicamento adicionado com sucesso',
        context: context,
      );
    } catch (e) {
      if (!mounted) return;
      CustomSnackbars().errorSnackbar(
        message: 'Erro ao adicionar medicamento: $e',
        context: context,
      );
    }
  }

  Future<void> _onEditarMedicamento(Medicamento medicamento) async {
    final result = await showDialog<Medicamento>(
      context: context,
      builder: (context) => MedicamentoFormDialog(
        medicamento: medicamento,
        editando: true,
        isClinica: true,
      ),
    );

    if (result == null || !mounted) return;

    try {
      await _viewModel.editMedicamento(result, _paciente!.id);
      if (!mounted) return;
      CustomSnackbars().successSnackbar(
        message: 'Medicamento atualizado com sucesso',
        context: context,
      );
    } catch (e) {
      if (!mounted) return;
      CustomSnackbars().errorSnackbar(
        message: 'Erro ao atualizar medicamento: $e',
        context: context,
      );
    }
  }

  Future<void> _onDeletarMedicamento(String id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Deletar Medicamento'),
        content: const Text('Tem certeza que deseja deletar este medicamento?'),
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

    if (confirmed != true || !mounted) return;

    try {
      await _viewModel.deleteMedicamento(id, _paciente!.id);
      if (!mounted) return;
      CustomSnackbars().successSnackbar(
        message: 'Medicamento deletado com sucesso',
        context: context,
      );
    } catch (e) {
      if (!mounted) return;
      CustomSnackbars().errorSnackbar(
        message: 'Erro ao deletar medicamento: $e',
        context: context,
      );
    }
  }

  // ========== CONSULTAS ==========

  Future<void> _onAdicionarConsulta() async {
    final result = await showDialog<Consulta>(
      context: context,
      builder: (context) =>
          const ConsultaFormDialog(editando: false, isClinica: true),
    );

    if (result == null || !mounted) return;

    try {
      await _viewModel.addConsulta(result, _paciente!.id);
      if (!mounted) return;
      CustomSnackbars().successSnackbar(
        message: 'Consulta adicionada com sucesso',
        context: context,
      );
    } catch (e) {
      if (!mounted) return;
      CustomSnackbars().errorSnackbar(
        message: 'Erro ao adicionar consulta: $e',
        context: context,
      );
    }
  }

  Future<void> _onEditarConsulta(Consulta consulta) async {
    final result = await showDialog<Consulta>(
      context: context,
      builder: (context) => ConsultaFormDialog(
        consulta: consulta,
        editando: true,
        isClinica: true,
      ),
    );

    if (result == null || !mounted) return;

    try {
      await _viewModel.editConsulta(result, _paciente!.id);
      if (!mounted) return;
      CustomSnackbars().successSnackbar(
        message: 'Consulta atualizada com sucesso',
        context: context,
      );
    } catch (e) {
      if (!mounted) return;
      CustomSnackbars().errorSnackbar(
        message: 'Erro ao atualizar consulta: $e',
        context: context,
      );
    }
  }

  Future<void> _onDeletarConsulta(String id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Deletar Consulta'),
        content: const Text('Tem certeza que deseja deletar esta consulta?'),
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

    if (confirmed != true || !mounted) return;

    try {
      await _viewModel.deleteConsulta(id, _paciente!.id);
      if (!mounted) return;
      CustomSnackbars().successSnackbar(
        message: 'Consulta deletada com sucesso',
        context: context,
      );
    } catch (e) {
      if (!mounted) return;
      CustomSnackbars().errorSnackbar(
        message: 'Erro ao deletar consulta: $e',
        context: context,
      );
    }
  }
}
