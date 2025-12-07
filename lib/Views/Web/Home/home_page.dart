import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:dose_certa/viewmodels/mobile/clinica_viewmodel.dart';
import 'package:dose_certa/Models/Models/doutor.dart';
import 'package:dose_certa/Models/Models/paciente.dart';
import 'package:dose_certa/viewmodels/web/home_viewmodel.dart';
import 'package:dose_certa/Views/Web/Home/widgets/doutor_card.dart';
import 'package:dose_certa/Views/Web/Home/widgets/doutor_form_dialog.dart';
import 'package:dose_certa/Views/Web/Home/widgets/lista_section.dart';
import 'package:dose_certa/Views/Web/Home/widgets/paciente_add_dialog.dart';
import 'package:dose_certa/Views/Web/Home/widgets/paciente_card.dart';
import 'package:dose_certa/Views/_shared/custom_drawer_web.dart';
import 'package:dose_certa/Views/_shared/custom_snackbars.dart';
import 'package:dose_certa/_Core/theme/app_colors.dart';

/// Página inicial da clínica (Web).
///
/// Dashboard principal com listas de pacientes e doutores.
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final ClinicaViewModel _clinicaController = ClinicaViewModel();
  final HomeViewmodel _viewModel = HomeViewmodel();
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadClinicaData();
    _viewModel.loadDoutores();
    _viewModel.loadPacientes();
    _viewModel.addListener(_onViewModelChanged);
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

  /// Carrega os dados da clínica logada.
  Future<void> _loadClinicaData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await _clinicaController.loadClinica(user.uid);
    }
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        backgroundColor: AppColors.bluePrimary,
        foregroundColor: Colors.white,
      ),
      drawer: CustomDrawerWeb(buildContext: context),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: Center(
          child: Wrap(
            spacing: 24,
            runSpacing: 24,
            alignment: WrapAlignment.center,
            children: [_buildPacientesSection(), _buildDoutoresSection()],
          ),
        ),
      ),
    );
  }

  /// Seção de pacientes com lista dinâmica.
  Widget _buildPacientesSection() {
    return ListaSection(
      titulo: 'Pacientes',
      onAdicionar: _onAdicionarPaciente,
      child: _viewModel.pacientes.isEmpty
          ? Container(
              padding: const EdgeInsets.all(32),
              child: const Text(
                'Nenhum paciente cadastrado',
                style: TextStyle(color: Colors.grey),
              ),
            )
          : ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _viewModel.pacientes.length,
              itemBuilder: (context, index) {
                final paciente = _viewModel.pacientes[index];
                return PacienteCard(
                  paciente: paciente,
                  onDelete: () => _onDeletarPaciente(paciente.id),
                  onTap: () => _onTapPaciente(paciente),
                );
              },
            ),
    );
  }

  /// Seção de doutores com lista dinâmica.
  Widget _buildDoutoresSection() {
    return ListaSection(
      titulo: 'Doutores',
      onAdicionar: _onAdicionarDoutor,
      child: _viewModel.doutores.isEmpty
          ? Container(
              padding: const EdgeInsets.all(32),
              child: const Text(
                'Nenhum doutor cadastrado',
                style: TextStyle(color: Colors.grey),
              ),
            )
          : ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _viewModel.doutores.length,
              itemBuilder: (context, index) {
                final doutor = _viewModel.doutores[index];
                return DoutorCard(
                  doutor: doutor,
                  onDelete: () => _onDeletarDoutor(doutor.id),
                  onEdit: () => _onEditarDoutor(doutor),
                );
              },
            ),
    );
  }

  Future<void> _onAdicionarPaciente() async {
    final usuarioId = await showDialog<String>(
      context: context,
      builder: (context) => const PacienteAddDialog(),
    );

    if (usuarioId == null || usuarioId.isEmpty || !mounted) return;

    try {
      await _viewModel.associatePaciente(usuarioId);
      if (!mounted) return;
      CustomSnackbars().successSnackbar(
        message: 'Paciente associado com sucesso',
        context: context,
      );
    } catch (e) {
      if (!mounted) return;
      final errorMessage = e.toString().replaceFirst('Exception: ', '');
      CustomSnackbars().errorSnackbar(message: errorMessage, context: context);
    }
  }

  Future<void> _onAdicionarDoutor() async {
    final result = await showDialog<Doutor>(
      context: context,
      builder: (context) => const DoutorFormDialog(editando: false),
    );

    if (result == null || !mounted) return;

    try {
      await _viewModel.addDoutor(result);
      if (!mounted) return;
      CustomSnackbars().successSnackbar(
        message: 'Doutor adicionado com sucesso',
        context: context,
      );
    } catch (e) {
      if (!mounted) return;
      CustomSnackbars().errorSnackbar(
        message: 'Erro ao adicionar doutor: $e',
        context: context,
      );
    }
  }

  Future<void> _onEditarDoutor(Doutor doutor) async {
    final result = await showDialog<Doutor>(
      context: context,
      builder: (context) => DoutorFormDialog(doutor: doutor, editando: true),
    );

    if (result == null || !mounted) return;

    try {
      await _viewModel.editDoutor(result);
      if (!mounted) return;
      CustomSnackbars().successSnackbar(
        message: 'Doutor atualizado com sucesso',
        context: context,
      );
    } catch (e) {
      if (!mounted) return;
      CustomSnackbars().errorSnackbar(
        message: 'Erro ao atualizar doutor: $e',
        context: context,
      );
    }
  }

  Future<void> _onDeletarDoutor(String id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Deletar Doutor'),
        content: const Text('Tem certeza que deseja deletar este doutor?'),
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
      await _viewModel.deleteDoutor(id);
      if (!mounted) return;
      CustomSnackbars().successSnackbar(
        message: 'Doutor deletado com sucesso',
        context: context,
      );
    } catch (e) {
      if (!mounted) return;
      CustomSnackbars().errorSnackbar(
        message: 'Erro ao deletar doutor: $e',
        context: context,
      );
    }
  }

  Future<void> _onDeletarPaciente(String id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Deletar Paciente'),
        content: const Text(
          'Tem certeza que deseja desassociar este paciente?',
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

    if (confirmed != true || !mounted) return;

    try {
      await _viewModel.deletePaciente(id);
      if (!mounted) return;
      CustomSnackbars().successSnackbar(
        message: 'Paciente desassociado com sucesso',
        context: context,
      );
    } catch (e) {
      if (!mounted) return;
      final errorMessage = e.toString().replaceFirst('Exception: ', '');
      CustomSnackbars().errorSnackbar(message: errorMessage, context: context);
    }
  }

  void _onTapPaciente(Paciente paciente) {
    Navigator.pushNamed(context, '/paciente', arguments: paciente);
  }
}
