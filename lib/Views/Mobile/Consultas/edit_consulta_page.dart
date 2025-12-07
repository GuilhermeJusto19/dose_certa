import 'package:dose_certa/Models/Models/consulta.dart';
import 'package:dose_certa/viewmodels/mobile/consulta_viewmodel.dart';
import 'package:dose_certa/Views/_shared/custom_back_button.dart';
import 'package:dose_certa/Views/_shared/primary_button.dart';
import 'package:dose_certa/_Core/theme/app_colors.dart';
import 'package:dose_certa/_Core/theme/app_text_style.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class EditConsultaPage extends StatefulWidget {
  const EditConsultaPage({super.key, required this.consulta});

  final Consulta consulta;

  @override
  State<EditConsultaPage> createState() => _EditConsultaPageState();
}

class _EditConsultaPageState extends State<EditConsultaPage> {
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
    _setTextControllers();
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.consulta.isClinica == true) {
        _showSnackBar(
          "Não é possivel editar pois a consulta foi adicionada pela clínica",
          color: AppColors.gray800,
          duration: const Duration(seconds: 10),
        );
      }
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _doctorController.dispose();
    _descriptionController.dispose();
    _dateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(leading: CustomBackButton()),
      body: Center(
        child: Form(
          key: _formKey,
          child: Padding(
            padding: const EdgeInsets.only(right: 16, left: 16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildNameField(),
                _buildDoctorField(),
                _buildDateField(),
                _buildTimeField(),
                _buildDescriptionField(),
                _buildSaveButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNameField() {
    return _buildTextField(
      controller: _nameController,
      label: 'Procedimento',
      hint: 'Ex: Radiografia',
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Digite qual é o procedimento';
        }
        return null;
      },
    );
  }

  Widget _buildDoctorField() {
    return _buildTextField(
      controller: _doctorController,
      label: 'Médico',
      hint: 'Ex: Dr. Felipe',
    );
  }

  Widget _buildDateField() {
    return _buildReadOnlyField(
      controller: _dateController,
      label: 'Data',
      prefix: const Icon(Icons.calendar_month),
      onTap: _selectDate,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Digite a data da consulta';
        }
        return null;
      },
    );
  }

  Widget _buildTimeField() {
    return _buildReadOnlyField(
      controller: _timeController,
      label: 'Horário',
      prefix: const Icon(Icons.access_time),
      onTap: _selectTime,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Digite o horário da consulta';
        }
        return null;
      },
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

  Widget _buildSaveButton() {
    final isClinica = widget.consulta.isClinica ?? false;
    return Visibility(
      visible: !isClinica,
      child: PrimaryButton(
        text: 'Salvar',
        onTap: () async {
          if (_formKey.currentState!.validate()) {
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
              Consulta updatedConsulta = Consulta(
                id: widget.consulta.id,
                name: _nameController.text,
                dateTime: fullDateTime,
                doctor: _doctorController.text.isNotEmpty
                    ? _doctorController.text
                    : null,
                description: _descriptionController.text.isNotEmpty
                    ? _descriptionController.text
                    : null,
              );
              await _viewmodel.editConsulta(updatedConsulta);
              if (mounted) {
                Navigator.pop(context);
                _showSnackBar("Consulta salva", color: Colors.green);
              }
            } catch (e) {
              _showSnackBar("Falha ao editar consulta: $e", color: Colors.red);
            }
          }
        },
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

  void _setTextControllers() {
    final dt = widget.consulta.dateTime;

    _nameController.text = widget.consulta.name;

    _dateController.text = DateFormat("dd/MM/yyyy").format(dt);

    _timeController.text = DateFormat("HH:mm").format(dt);

    if (widget.consulta.doctor != null) {
      _doctorController.text = widget.consulta.doctor!;
    }

    if (widget.consulta.description != null) {
      _descriptionController.text = widget.consulta.description!;
    }

    _pickedDate = dt;
    _pickedTime = TimeOfDay(hour: dt.hour, minute: dt.minute);
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
}
