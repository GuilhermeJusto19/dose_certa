import 'package:dose_certa/Models/Models/medicamento.dart';
import 'package:dose_certa/viewmodels/mobile/estoque_viewmodel.dart';
import 'package:dose_certa/viewmodels/mobile/user_viewmodel.dart';
import 'package:dose_certa/viewmodels/mobile/medicamento_viewmodel.dart';
import 'package:dose_certa/Views/_shared/custom_snackbars.dart';
import 'package:dose_certa/Views/_shared/empty_screen.dart';
import 'package:dose_certa/_Core/theme/app_colors.dart';
import 'package:dose_certa/_Core/theme/app_text_style.dart';
import 'package:dose_certa/Models/services/app_connectivity_service.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

final DateFormat dateformat = DateFormat("dd/MM/yyyy HH:mm");

class MedicamentosCuidador extends StatefulWidget {
  const MedicamentosCuidador({super.key});

  @override
  State<MedicamentosCuidador> createState() => _MedicamentosCuidadorState();
}

class _MedicamentosCuidadorState extends State<MedicamentosCuidador> {
  late MedicamentoViewModel viewModel;
  late EstoqueViewModel estoqueViewModel;
  final _userController = UserViewModel();

  @override
  void initState() {
    viewModel = MedicamentoViewModel();
    estoqueViewModel = EstoqueViewModel();

    final userId = _userController.currentUser!.associetedId;
    viewModel.loadMedicamentos(userId: userId);
    estoqueViewModel.loadEstoques(userId: userId);
    super.initState();
  }

  @override
  void dispose() {
    viewModel.dispose();
    estoqueViewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Provide both medicamentos and estoques so we can show stock per medicamento
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<MedicamentoViewModel>.value(value: viewModel),
        ChangeNotifierProvider<EstoqueViewModel>.value(value: estoqueViewModel),
      ],
      child: Consumer2<MedicamentoViewModel, EstoqueViewModel>(
        builder: (context, viewModel, estoqueVm, child) {
          return Scaffold(
            backgroundColor: AppColors.mainBackground,
            body: _buildBody(viewModel, estoqueVm),
          );
        },
      ),
    );
  }

  Widget _buildBody(
    MedicamentoViewModel viewModel,
    EstoqueViewModel estoqueVm,
  ) {
    if (viewModel.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (viewModel.medicamentos.isEmpty) {
      return RefreshIndicator(
        onRefresh: () async {
          final userId = _userController.currentUser!.associetedId;
          viewModel.loadMedicamentos(userId: userId);
          estoqueVm.loadEstoques(userId: userId);
        },
        child: ListView(
          children: [
            SizedBox(
              height: MediaQuery.of(context).size.height > 350
                  ? MediaQuery.of(context).size.height - 350
                  : 0,
              child: EmptyScreen(
                imagePath: "assets/images/med_empty_screen.png",
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        final userId = _userController.currentUser!.associetedId;
        viewModel.loadMedicamentos(userId: userId);
        estoqueVm.loadEstoques(userId: userId);
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTitle(),
          Expanded(child: _buildListView(viewModel, estoqueVm)),
        ],
      ),
    );
  }

  Widget _buildTitle() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(30, 10, 30, 0),
      child: Text(
        "Medicamentos",
        style: AppTextStyles.semibold24.copyWith(
          color: AppColors.mainTextColor,
        ),
      ),
    );
  }

  Widget _buildListView(
    MedicamentoViewModel viewModel,
    EstoqueViewModel estoqueVm,
  ) {
    return ListView.builder(
      itemCount: viewModel.medicamentos.length,
      itemBuilder: (context, index) {
        final medicamento = viewModel.medicamentos[index];
        return _buildListTile(context, medicamento, viewModel, estoqueVm);
      },
    );
  }

  Widget _buildListTile(
    BuildContext context,
    Medicamento medicamento,
    MedicamentoViewModel viewModel,
    EstoqueViewModel estoqueVm,
  ) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(25, 0, 25, 16),
      child: ListTile(
        tileColor: AppColors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        leading: Image.asset(
          "assets/images/medicamento_card.png",
          width: 40,
          semanticLabel: "medicamento_card_icon",
        ),
        title: Text(medicamento.name, style: AppTextStyles.medium16),
        subtitle: Text(
          "${medicamento.quantity} ${medicamento.unit}",
          style: AppTextStyles.medium14,
        ),
        trailing: Visibility(
          // Só exibe delete quando não é medicamento de clínica e há conexão
          visible:
              !medicamento.isClinica! &&
              (AppConnectivity().isConnected ?? true),
          child: IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
            onPressed: () {
              if (!medicamento.isClinica! &&
                  (AppConnectivity().isConnected ?? true)) {
                viewModel.deleteMedicamento(
                  medicamento.id,
                  userId: _userController.currentUser!.associetedId,
                );
              } else if (!AppConnectivity().isConnected!) {
                ScaffoldMessenger.of(context).showSnackBar(
                  CustomSnackbars().errorSnackbar(
                    message:
                        'Para deletar um medicamento esteja conectado na internet.',
                    context: context,
                  ),
                );
              }
            },
          ),
        ),
        onTap: () {
          Navigator.pushNamed(
            context,
            '/editMedicamento',
            arguments: medicamento,
          );
        },
      ),
    );
  }
}
