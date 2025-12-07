import 'package:dose_certa/Models/Models/consulta.dart';
import 'package:dose_certa/viewmodels/mobile/consulta_viewmodel.dart';
import 'package:dose_certa/Views/_shared/custom_back_button.dart';
import 'package:dose_certa/Views/_shared/primary_button.dart';
import 'package:dose_certa/_Core/theme/app_colors.dart';
import 'package:dose_certa/_Core/theme/app_text_style.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

class AddConsultaPage extends StatefulWidget {
  const AddConsultaPage({super.key});

  @override
  State<AddConsultaPage> createState() => _AddConsultaPageState();
}

class _AddConsultaPageState extends State<AddConsultaPage> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _doctorController;
  late TextEditingController _descriptionController;
  late TextEditingController _dateController;
  late TextEditingController _timeController;

  late DateTime _pickedDate;
  late TimeOfDay _pickedTime;

  late ConsultaViewModel _viewmodel;

  @override
  void initState() {
    _nameController = TextEditingController();
    _doctorController = TextEditingController();
    _descriptionController = TextEditingController();
    _dateController = TextEditingController();
    _timeController = TextEditingController();
    _viewmodel = ConsultaViewModel();
    super.initState();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _doctorController.dispose();
    _descriptionController.dispose();
    _dateController.dispose();
    _timeController.dispose();
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
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Center(
            child: Form(
              key: _formKey,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    const SizedBox(height: 30),
                    _buildTextField(
                      controller: _nameController,
                      label: 'Procedimento',
                      hint: 'Ex: Radiografia',
                      validator: (v) => v == null || v.isEmpty
                          ? 'Digite qual é o procedimento'
                          : null,
                    ),
                    const SizedBox(height: 30),
                    _buildTextField(
                      controller: _doctorController,
                      label: 'Medico',
                      hint: 'Ex: Dr. Felipe',
                    ),
                    const SizedBox(height: 30),
                    _buildReadOnlyField(
                      controller: _dateController,
                      label: 'Data',
                      prefix: const Icon(Icons.calendar_month),
                      onTap: _selectDate,
                      validator: (v) => v == null || v.isEmpty
                          ? 'Digite a data da consulta'
                          : null,
                    ),
                    const SizedBox(height: 30),
                    _buildReadOnlyField(
                      controller: _timeController,
                      label: 'Horário',
                      prefix: const Icon(Icons.access_time),
                      onTap: _selectTime,
                      validator: (v) => v == null || v.isEmpty
                          ? 'Digite o horário da consulta'
                          : null,
                    ),
                    const SizedBox(height: 30),
                    _buildDescriptionField(),
                    const SizedBox(height: 50),
                    PrimaryButton(text: 'Salvar', onTap: _onSavePressed),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    String? hint,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      clipBehavior: Clip.hardEdge,
      decoration: _baseDecoration(label: label, hint: hint),
      validator: validator,
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

  Widget _buildDescriptionField() {
    return TextFormField(
      controller: _descriptionController,
      clipBehavior: Clip.hardEdge,
      decoration: _baseDecoration(label: 'Observação'),
      inputFormatters: [LengthLimitingTextInputFormatter(220)],
      minLines: 6,
      maxLines: 6,
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

  Future<void> _onSavePressed() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      DateTime fullDateTime = _completeDate(_pickedDate, _pickedTime);

      if (fullDateTime.isAtSameMomentAs(DateTime.now()) ||
          fullDateTime.isBefore(DateTime.now())) {
        _showSnackBar(
          "A data de criação da consulta não pode ser anterior a data atual.",
          color: Colors.red,
        );
        return;
      }

      //* Criar e salvar a consulta/tarefa/lembrete
      Consulta consulta = Consulta(
        id: Uuid().v1(),
        name: _nameController.text,
        dateTime: fullDateTime,
        doctor: _doctorController.text.isNotEmpty
            ? _doctorController.text
            : null,
        description: _descriptionController.text.isNotEmpty
            ? _descriptionController.text
            : null,
      );
      await _viewmodel.addConsulta(consulta);

      if (context.mounted) {
        Navigator.pop(context);
        _showSnackBar("Consulta adicionada", color: Colors.green);
      }
    } catch (e) {
      _showSnackBar("Falha ao adicionar consulta: $e", color: Colors.red);
    }
  }

  void _showSnackBar(String message, {Color? color, Duration? duration}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        duration: duration ?? const Duration(seconds: 4),
      ),
    );
  }

  Future<void> _selectDate() async {
    DateTime? picked = await showDatePicker(
      context: context,
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      _pickedDate = picked;
      setState(() {
        _dateController.text = DateFormat("dd/MM/yyyy").format(picked);
      });
    }
  }

  Future<void> _selectTime() async {
    TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: 8, minute: 0),
    );

    if (picked != null) {
      _pickedTime = picked;
      final now = DateTime.now();
      final dt = DateTime(
        now.year,
        now.month,
        now.day,
        picked.hour,
        picked.minute,
      );
      setState(() {
        _timeController.text = DateFormat("HH:mm").format(dt);
      });
    }
  }

  DateTime _completeDate(DateTime? date, TimeOfDay? time) {
    return DateTime(date!.year, date.month, date.day, time!.hour, time.minute);
  }
}
