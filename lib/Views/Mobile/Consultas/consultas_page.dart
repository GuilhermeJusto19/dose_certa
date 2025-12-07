import 'package:dose_certa/Models/Models/consulta.dart';
import 'package:dose_certa/viewmodels/mobile/consulta_viewmodel.dart';
import 'package:dose_certa/Views/_shared/custom_snackbars.dart';
import 'package:dose_certa/Views/_shared/empty_screen.dart';
import 'package:dose_certa/_Core/theme/app_colors.dart';
import 'package:dose_certa/_Core/theme/app_text_style.dart';
import 'package:dose_certa/Models/services/app_connectivity_service.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

final DateFormat dateformat = DateFormat("dd/MM/yyyy HH:mm");

class ConsultasPage extends StatefulWidget {
  const ConsultasPage({super.key});

  @override
  State<ConsultasPage> createState() => _ConsultasPageState();
}

class _ConsultasPageState extends State<ConsultasPage> {
  late ConsultaViewModel viewModel;

  @override
  void initState() {
    viewModel = ConsultaViewModel();
    viewModel.loadConsultas();
    super.initState();
  }

  @override
  void dispose() {
    viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ConsultaViewModel()..loadConsultas(),
      child: Consumer<ConsultaViewModel>(
        builder: (context, viewModel, child) {
          return Scaffold(
            backgroundColor: AppColors.mainBackground,
            body: _buildBody(viewModel),
          );
        },
      ),
    );
  }

  Widget _buildBody(ConsultaViewModel viewModel) {
    if (viewModel.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (viewModel.consultas.isEmpty) {
      return RefreshIndicator(
        onRefresh: () async {
          viewModel.loadConsultas();
        },
        child: ListView(
          children: [
            SizedBox(
              height: MediaQuery.heightOf(context),
              child: EmptyScreen(),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        viewModel.loadConsultas();
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 70),
          _buildTitle(),
          Expanded(child: _buildListView(viewModel)),
        ],
      ),
    );
  }

  Widget _buildTitle() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(30, 30, 30, 0),
      child: Text(
        "Consultas",
        style: AppTextStyles.semibold24.copyWith(
          color: AppColors.mainTextColor,
        ),
      ),
    );
  }

  Widget _buildListView(ConsultaViewModel viewModel) {
    return ListView.builder(
      itemCount: viewModel.consultas.length,
      itemBuilder: (context, index) {
        final consulta = viewModel.consultas[index];
        return _buildListTile(context, consulta, viewModel);
      },
    );
  }

  Widget _buildListTile(
    BuildContext context,
    Consulta consulta,
    ConsultaViewModel viewModel,
  ) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(25, 0, 25, 16),
      child: ListTile(
        tileColor: AppColors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        leading: Image.asset(
          "assets/images/consulta_card.png",
          width: 40,
          semanticLabel: "consulta_card_icon",
        ),
        title: Text(consulta.name, style: AppTextStyles.medium16),
        subtitle: Text(
          dateformat.format(consulta.dateTime.toLocal()),
          style: AppTextStyles.medium14,
        ),
        trailing: Visibility(
          // Só exibe delete quando não é consulta de clínica e há conexão
          visible:
              !consulta.isClinica! && (AppConnectivity().isConnected ?? true),
          child: IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
            onPressed: () {
              if (!consulta.isClinica! &&
                  (AppConnectivity().isConnected ?? true)) {
                viewModel.deleteConsulta(consulta.id);
              } else if (!AppConnectivity().isConnected!) {
                ScaffoldMessenger.of(context).showSnackBar(
                  CustomSnackbars().errorSnackbar(
                    message:
                        'Para deletar uma consulta esteja conectado na internet.',
                    context: context,
                  ),
                );
              }
            },
          ),
        ),
        onTap: () {
          Navigator.pushNamed(context, '/editConsulta', arguments: consulta);
        },
      ),
    );
  }
}
