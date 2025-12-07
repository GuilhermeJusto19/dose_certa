import 'package:dose_certa/Views/_shared/custom_back_button.dart';
import 'package:dose_certa/Views/_shared/custom_snackbars.dart';
import 'package:dose_certa/Views/_shared/primary_button.dart';
import 'package:dose_certa/Models/services/app_connectivity_service.dart';
import 'package:dose_certa/Models/services/relatorio_service.dart';
import 'package:dose_certa/_Core/theme/app_colors.dart';
import 'package:dose_certa/_Core/theme/app_text_style.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class RelatorioPage extends StatefulWidget {
  const RelatorioPage({super.key});

  @override
  State<RelatorioPage> createState() => _RelatorioPageState();
}

class _RelatorioPageState extends State<RelatorioPage> {
  late TextEditingController _initialDateController;
  late TextEditingController _finalDateController;
  DateTime? _initialDateValue;
  DateTime? _finalDateValue;
  bool _isLoading = false;

  final _relatorioService = RelatorioService();

  @override
  void initState() {
    _initialDateController = TextEditingController();
    _finalDateController = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _initialDateController.dispose();
    _finalDateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.mainBackground,
      appBar: AppBar(
        leading: const CustomBackButton(),
        backgroundColor: AppColors.mainBackground,
      ),
      body: _buildContent(),
    );
  }

  Widget _buildContent() {
    return Center(
      child: Column(
        children: [
          Text(
            'Gerar Relatório de Adesão',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.mainTextColor,
            ),
          ),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.only(left: 30, right: 30),
            child: _buildReadOnlyField(
              controller: _initialDateController,
              label: 'Data Inicial',
              prefix: const Icon(Icons.calendar_month),
              onTap: () => _selectDate(_initialDateController),
              validator: (v) => v == null || v.isEmpty
                  ? 'Digite a data inicial da busca'
                  : null,
            ),
          ),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.only(left: 30, right: 30),
            child: _buildReadOnlyField(
              controller: _finalDateController,
              label: 'Data Final',
              prefix: const Icon(Icons.calendar_month),
              onTap: () => _selectDate(_finalDateController),
              validator: (v) => v == null || v.isEmpty
                  ? 'Digite a data final da busca'
                  : null,
            ),
          ),
          const SizedBox(height: 40),
          _isLoading
              ? const CircularProgressIndicator()
              : PrimaryButton(text: 'Gerar', onTap: onTap),
        ],
      ),
    );
  }

  Widget _buildReadOnlyField({
    required TextEditingController controller,
    required String label,
    Widget? prefix,
    VoidCallback? onTap,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      readOnly: true,
      decoration: _baseDecoration(label: label, prefix: prefix),
      onTap: onTap,
      validator: validator,
    );
  }

  InputDecoration _baseDecoration({
    String? label,
    String? hint,
    Widget? prefix,
  }) {
    return InputDecoration(
      label: Text(label ?? '', style: AppTextStyles.medium20),
      hintText: hint,
      prefixIcon: prefix,
      floatingLabelBehavior: FloatingLabelBehavior.always,
      filled: true,
      enabledBorder: const OutlineInputBorder(
        borderSide: BorderSide(color: AppColors.gray700),
      ),
      focusedBorder: const OutlineInputBorder(
        borderSide: BorderSide(color: AppColors.blueAccent),
      ),
      fillColor: AppColors.white,
    );
  }

  Future<void> _selectDate(TextEditingController controller) async {
    DateTime? picked = await showDatePicker(
      context: context,
      firstDate: DateTime(2025),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      final asDate = DateTime(picked.year, picked.month, picked.day);
      setState(() {
        controller.text = DateFormat("dd/MM/yyyy").format(picked);
        if (controller == _initialDateController) {
          _initialDateValue = asDate;
        } else if (controller == _finalDateController) {
          _finalDateValue = asDate;
        }
      });
    }
  }

  Future<void> onTap() async {
    // validate dates
    if (_initialDateValue == null || _finalDateValue == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        CustomSnackbars().errorSnackbar(
          message: 'Selecione o período para gerar o relatório',
          context: context,
        ),
      );
      return;
    }

    if (_initialDateValue!.isAfter(_finalDateValue!)) {
      ScaffoldMessenger.of(context).showSnackBar(
        CustomSnackbars().errorSnackbar(
          message: 'A data inicial não pode ser posterior à data final.',
          context: context,
        ),
      );
      return;
    }

    if (AppConnectivity().isConnected != true) {
      ScaffoldMessenger.of(context).showSnackBar(
        CustomSnackbars().errorSnackbar(
          message:
              'É necessária conexão com a internet para gerar o relatório.',
          context: context,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      final relatorio = await _relatorioService.generateRelatorioPdf(
        fileName: 'relatorio_adesao_DoseCerta.pdf',
        initialDate: _initialDateValue!,
        finalDate: _finalDateValue!,
      );
      await _relatorioService.openPdf(relatorio);
    } on Exception catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        CustomSnackbars().errorSnackbar(
          message: 'Erro ao gerar relatório: $e',
          context: context,
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
}
