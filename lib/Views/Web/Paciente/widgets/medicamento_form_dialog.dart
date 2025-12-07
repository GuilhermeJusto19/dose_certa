import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import 'package:dose_certa/Models/Models/medicamento.dart';
import 'package:dose_certa/_Core/constants/constants.dart';
import 'package:dose_certa/_Core/theme/app_colors.dart';
import 'package:dose_certa/_Core/theme/app_text_style.dart';

/// Dialog para adicionar/editar medicamento.
class MedicamentoFormDialog extends StatefulWidget {
  const MedicamentoFormDialog({
    super.key,
    this.medicamento,
    required this.editando,
    this.isClinica = false,
  });

  final Medicamento? medicamento;
  final bool editando;
  final bool isClinica;

  @override
  State<MedicamentoFormDialog> createState() => _MedicamentoFormDialogState();
}

class _MedicamentoFormDialogState extends State<MedicamentoFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final _focusNode = FocusNode();
  final _timesPerDayFieldKey = GlobalKey<FormFieldState>();

  late TextEditingController _nameController;
  late TextEditingController _quantityController;
  late TextEditingController _unitController;
  late TextEditingController _frequencyController;
  late TextEditingController _intervalController;
  late TextEditingController _timesPerDayController;
  late TextEditingController _weekDaysController;
  late TextEditingController _startDateController;
  late TextEditingController _reminderTimeController;
  late TextEditingController _noteController;

  late DateTime _pickedDate;
  late TimeOfDay _pickedTime;
  final List<TextEditingController> _reminderControllers = [];
  final List<TimeOfDay?> _reminderTimeOfDays = [];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(
      text: widget.editando ? widget.medicamento?.name : '',
    );
    _quantityController = TextEditingController(
      text: widget.editando ? widget.medicamento?.quantity.toString() : '',
    );
    _unitController = TextEditingController(
      text: widget.editando ? widget.medicamento?.unit : 'comprimido(s)',
    );
    _frequencyController = TextEditingController(
      text: widget.editando ? widget.medicamento?.frequency : 'Diariamente',
    );
    _intervalController = TextEditingController(
      text: widget.editando && widget.medicamento?.intervalHours != null
          ? widget.medicamento!.intervalHours.toString()
          : '',
    );
    _timesPerDayController = TextEditingController(
      text: widget.editando && widget.medicamento?.timesPerDay != null
          ? widget.medicamento!.timesPerDay.toString()
          : '',
    );
    _weekDaysController = TextEditingController(
      text: widget.editando && widget.medicamento?.weekDays != null
          ? widget.medicamento!.weekDays!.join(',')
          : '',
    );
    _startDateController = TextEditingController(
      text: widget.editando
          ? DateFormat('dd/MM/yyyy').format(widget.medicamento!.startDate)
          : '',
    );
    _reminderTimeController = TextEditingController(
      text: widget.editando && widget.medicamento!.reminderTimes.isNotEmpty
          ? DateFormat('HH:mm').format(widget.medicamento!.reminderTimes.first)
          : '',
    );
    _noteController = TextEditingController(
      text: widget.editando ? widget.medicamento?.notes ?? '' : '',
    );

    _pickedDate = widget.editando
        ? widget.medicamento!.startDate
        : DateTime.now();
    _pickedTime =
        widget.editando && widget.medicamento!.reminderTimes.isNotEmpty
        ? TimeOfDay.fromDateTime(widget.medicamento!.reminderTimes.first)
        : const TimeOfDay(hour: 8, minute: 0);

    if (widget.editando &&
        widget.medicamento?.frequency == 'X vezes ao dia' &&
        widget.medicamento!.reminderTimes.isNotEmpty) {
      _ensureReminderControllers(widget.medicamento!.reminderTimes.length);
      for (var i = 0; i < widget.medicamento!.reminderTimes.length; i++) {
        final time = widget.medicamento!.reminderTimes[i];
        _reminderTimeOfDays[i] = TimeOfDay.fromDateTime(time);
        _reminderControllers[i].text = DateFormat('HH:mm').format(time);
      }
    }

    _focusNode.addListener(() {
      if (!_focusNode.hasFocus) {
        _timesPerDayFieldKey.currentState?.validate();
      }
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _quantityController.dispose();
    _unitController.dispose();
    _frequencyController.dispose();
    _intervalController.dispose();
    _timesPerDayController.dispose();
    _weekDaysController.dispose();
    _noteController.dispose();
    _startDateController.dispose();
    _reminderTimeController.dispose();
    for (final c in _reminderControllers) {
      c.dispose();
    }
    _focusNode.dispose();
    super.dispose();
  }

  void _onSalvar() {
    if (!_formKey.currentState!.validate()) return;

    try {
      DateTime fullDateTime = _completeDate(_pickedDate, _pickedTime);

      if (fullDateTime.isAtSameMomentAs(DateTime.now()) ||
          fullDateTime.isBefore(DateTime.now())) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'A data do medicamento não pode ser anterior a data atual.',
            ),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      if (_weekDaysController.text.isEmpty &&
          _frequencyController.text == 'Dias específicos da semana') {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Selecione ao menos um dia da semana.'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      List<DateTime> reminderTimes;
      if (_frequencyController.text == 'X vezes ao dia' &&
          _reminderControllers.isNotEmpty) {
        reminderTimes = _collectReminderDateTimes(fullDateTime);
      } else {
        reminderTimes = [fullDateTime];
      }

      _clearFields();

      final medicamento = Medicamento(
        id: widget.editando ? widget.medicamento!.id : const Uuid().v4(),
        name: _nameController.text.trim(),
        frequency: _frequencyController.text,
        quantity: int.parse(_quantityController.text.trim()),
        unit: _unitController.text.trim(),
        intervalHours: _intervalController.text.isNotEmpty
            ? int.parse(_intervalController.text.trim())
            : null,
        timesPerDay: _timesPerDayController.text.isNotEmpty
            ? int.parse(_timesPerDayController.text.trim())
            : null,
        weekDays: _weekDaysController.text.isNotEmpty
            ? _weekDaysController.text.split(',').map(int.parse).toList()
            : null,
        startDate: fullDateTime,
        reminderTimes: reminderTimes,
        isClinica: widget.isClinica,
        notes: _noteController.text.isNotEmpty ? _noteController.text : null,
      );

      Navigator.pop(context, medicamento);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao salvar: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _clearFields() {
    if (_frequencyController.text == 'Diariamente') {
      _intervalController.clear();
      _timesPerDayController.clear();
      _weekDaysController.clear();
      _clearReminderTimes();
    } else if (_frequencyController.text == 'A cada X horas') {
      _timesPerDayController.clear();
      _weekDaysController.clear();
      _clearReminderTimes();
    } else if (_frequencyController.text == 'X vezes ao dia') {
      _intervalController.clear();
      _weekDaysController.clear();
    } else if (_frequencyController.text == 'Dias específicos da semana') {
      _intervalController.clear();
      _timesPerDayController.clear();
      _clearReminderTimes();
    }
  }

  void _ensureReminderControllers(int count) {
    while (_reminderControllers.length < count) {
      _reminderControllers.add(TextEditingController());
      _reminderTimeOfDays.add(null);
    }
    while (_reminderControllers.length > count) {
      final c = _reminderControllers.removeLast();
      c.dispose();
      _reminderTimeOfDays.removeLast();
    }
  }

  void _clearReminderTimes() {
    for (final c in _reminderControllers) {
      c.clear();
      c.dispose();
    }
    _reminderControllers.clear();
    _reminderTimeOfDays.clear();
  }

  List<DateTime> _collectReminderDateTimes(DateTime baseDate) {
    final list = <DateTime>[];
    for (var i = 0; i < _reminderTimeOfDays.length; i++) {
      final tod = _reminderTimeOfDays[i];
      if (tod != null) {
        list.add(
          DateTime(
            baseDate.year,
            baseDate.month,
            baseDate.day,
            tod.hour,
            tod.minute,
          ),
        );
      }
    }
    return list;
  }

  DateTime _completeDate(DateTime? date, TimeOfDay? time) {
    return DateTime(date!.year, date.month, date.day, time!.hour, time.minute);
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _pickedDate.isBefore(DateTime.now())
          ? DateTime.now()
          : _pickedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      _pickedDate = picked;
      setState(() {
        _startDateController.text = DateFormat('dd/MM/yyyy').format(picked);
      });
    }
  }

  Future<void> _selectTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _pickedTime,
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
        _reminderTimeController.text = DateFormat('HH:mm').format(dt);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 600),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  widget.editando
                      ? 'Editar Medicamento'
                      : 'Adicionar Medicamento',
                  style: AppTextStyles.semibold20.copyWith(
                    color: AppColors.mainTextColor,
                  ),
                ),
                const SizedBox(height: 24),
                _buildTextField(
                  controller: _nameController,
                  label: 'Medicamento',
                  hint: 'Ex: Omeprazol',
                  validator: (v) => v == null || v.isEmpty
                      ? 'Digite o nome do medicamento'
                      : null,
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _buildTextField(
                        controller: _quantityController,
                        label: 'Quantidade',
                        keyboardType: TextInputType.number,
                        validator: (v) {
                          if (v == null || v.isEmpty) {
                            return 'Digite a quantidade';
                          }
                          if (int.tryParse(v) == null || int.parse(v) <= 0) {
                            return 'Quantidade inválida';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(child: _buildUnitDropdown()),
                  ],
                ),
                const SizedBox(height: 16),
                _buildFrequencyDropdown(),
                const SizedBox(height: 16),
                ..._buildIntervalAndTimesFields(),
                const SizedBox(height: 16),
                _buildDescriptionField(),
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
                      child: const Text('Salvar'),
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

  Widget _buildTextField({
    Key? key,
    required TextEditingController controller,
    required String label,
    TextInputType? keyboardType,
    String? hint,
    String? Function(String?)? validator,
    void Function(String?)? onChanged,
    FocusNode? focusNode,
  }) {
    return TextFormField(
      key: key,
      controller: controller,
      keyboardType: keyboardType,
      onChanged: onChanged,
      focusNode: focusNode,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        floatingLabelBehavior: FloatingLabelBehavior.always,
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
    return InkWell(
      onTap: onTap,
      child: IgnorePointer(
        child: TextFormField(
          controller: controller,
          readOnly: true,
          decoration: InputDecoration(
            labelText: label,
            floatingLabelBehavior: FloatingLabelBehavior.always,
            prefixIcon: prefix,
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
              borderSide: const BorderSide(
                color: AppColors.blueAccent,
                width: 2,
              ),
            ),
          ),
          validator: validator,
        ),
      ),
    );
  }

  Widget _buildDescriptionField() {
    return TextFormField(
      controller: _noteController,
      decoration: InputDecoration(
        labelText: 'Observação',
        floatingLabelBehavior: FloatingLabelBehavior.always,
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
      inputFormatters: [LengthLimitingTextInputFormatter(220)],
      minLines: 3,
      maxLines: 3,
    );
  }

  Widget _buildUnitDropdown() {
    return DropdownButtonFormField<String>(
      value: _unitController.text.isEmpty ? null : _unitController.text,
      decoration: InputDecoration(
        labelText: 'Unidade',
        floatingLabelBehavior: FloatingLabelBehavior.always,
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
      items: Constants.unitsOptions
          .map((u) => DropdownMenuItem(value: u, child: Text(u)))
          .toList(),
      onChanged: (val) {
        setState(() {
          _unitController.text = val ?? '';
        });
      },
      validator: (v) {
        if (v == null || v.isEmpty) {
          return 'Escolha a unidade';
        }
        return null;
      },
    );
  }

  Widget _buildFrequencyDropdown() {
    return DropdownButtonFormField<String>(
      value: _frequencyController.text.isEmpty
          ? null
          : _frequencyController.text,
      decoration: InputDecoration(
        labelText: 'Frequência',
        floatingLabelBehavior: FloatingLabelBehavior.always,
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
      items: Constants.frequencyOptions
          .map((f) => DropdownMenuItem(value: f, child: Text(f)))
          .toList(),
      onChanged: (val) {
        setState(() {
          final previous = _frequencyController.text;
          _frequencyController.text = val ?? '';
          if (previous == 'X vezes ao dia' &&
              _frequencyController.text != previous) {
            _clearReminderTimes();
            _timesPerDayController.clear();
          }
          if (_frequencyController.text == 'X vezes ao dia' &&
              _timesPerDayController.text.isNotEmpty) {
            _ensureReminderControllers(
              int.tryParse(_timesPerDayController.text) ?? 0,
            );
          }
        });
      },
      validator: (v) {
        if (v == null || v.isEmpty) {
          return 'Escolha a frequência';
        }
        return null;
      },
    );
  }

  List<Widget> _buildIntervalAndTimesFields() {
    final widgets = <Widget>[];

    if (_frequencyController.text == 'A cada X horas') {
      widgets.addAll([
        _buildTextField(
          controller: _intervalController,
          label: 'Intervalo (horas)',
          keyboardType: TextInputType.number,
          validator: (v) {
            if (v == null || v.isEmpty) {
              return 'Digite o intervalo';
            }
            if (int.tryParse(v) == null || int.parse(v) <= 0) {
              return 'Intervalo inválido';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
      ]);
    } else if (_frequencyController.text == 'X vezes ao dia') {
      widgets.addAll([
        _buildTextField(
          key: _timesPerDayFieldKey,
          controller: _timesPerDayController,
          label: 'Vezes ao dia',
          keyboardType: TextInputType.number,
          validator: (v) {
            if (v == null || v.isEmpty) {
              return 'Digite a quantidade de vezes';
            }
            if (int.tryParse(v) == null || int.parse(v) <= 0) {
              return 'Quantidade inválida';
            }
            if (int.parse(v) > 4) {
              return 'A quantidade não pode ser maior que 4';
            }
            return null;
          },
          focusNode: _focusNode,
          onChanged: (value) {
            final n = int.tryParse(value ?? '0') ?? 0;
            if (n > 0 && n <= 4) {
              setState(() {
                _ensureReminderControllers(n);
              });
            }
            if (n == 0) {
              setState(() {
                _clearReminderTimes();
              });
            }
          },
        ),
        ..._buildReminderTimePickers(),
        const SizedBox(height: 16),
      ]);
    } else if (_frequencyController.text == 'Dias específicos da semana') {
      widgets.addAll([_buildDaysSelection(), const SizedBox(height: 16)]);
    }

    widgets.addAll([
      _buildReadOnlyField(
        controller: _startDateController,
        label: 'Data de início',
        prefix: const Icon(Icons.calendar_month),
        onTap: _selectDate,
        validator: (v) =>
            v == null || v.isEmpty ? 'Digite a data de início' : null,
      ),
    ]);

    if (_frequencyController.text != 'X vezes ao dia') {
      widgets.addAll([
        const SizedBox(height: 16),
        _buildReadOnlyField(
          controller: _reminderTimeController,
          label: 'Horário',
          prefix: const Icon(Icons.access_time),
          onTap: _selectTime,
          validator: (v) => v == null || v.isEmpty ? 'Digite o horário' : null,
        ),
      ]);
    }

    return widgets;
  }

  List<Widget> _buildReminderTimePickers() {
    final widgets = <Widget>[];
    for (var i = 0; i < _reminderControllers.length; i++) {
      widgets.add(const SizedBox(height: 16));
      widgets.add(
        _buildReadOnlyField(
          controller: _reminderControllers[i],
          label: 'Horário ${i + 1}',
          prefix: const Icon(Icons.access_time),
          onTap: () async {
            final picked = await showTimePicker(
              context: context,
              initialTime: const TimeOfDay(hour: 8, minute: 0),
            );
            if (picked != null) {
              _reminderTimeOfDays[i] = picked;
              final now = DateTime.now();
              final dt = DateTime(
                now.year,
                now.month,
                now.day,
                picked.hour,
                picked.minute,
              );
              _reminderControllers[i].text = DateFormat('HH:mm').format(dt);
              setState(() {});
            }
          },
          validator: (v) {
            if (v == null || v.isEmpty) return 'Escolha o horário ${i + 1}';
            return null;
          },
        ),
      );
    }
    if (_reminderTimeOfDays.isNotEmpty && _reminderTimeOfDays[0] != null) {
      _pickedTime = _reminderTimeOfDays[0]!;
    }
    return widgets;
  }

  Widget _buildDaysSelection() {
    final days = Constants.weekDaysOptions;

    return GridView.count(
      crossAxisCount: 7,
      shrinkWrap: true,
      mainAxisSpacing: 4,
      crossAxisSpacing: 4,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 0.7,
      children: List.generate(days.length, (index) {
        final isSelected = _weekDaysController.text
            .split(',')
            .contains((index + 1).toString());

        return FilterChip(
          showCheckmark: false,
          label: Center(
            child: Text(
              days[index],
              textAlign: TextAlign.center,
              style: AppTextStyles.semibold15.copyWith(
                color: isSelected ? AppColors.white : AppColors.mainTextColor,
              ),
            ),
          ),
          selected: isSelected,
          onSelected: (bool selected) {
            setState(() {
              final currentDays = _weekDaysController.text.isNotEmpty
                  ? _weekDaysController.text.split(',').map(int.parse).toList()
                  : <int>[];

              if (selected) {
                currentDays.add(index + 1);
              } else {
                currentDays.remove(index + 1);
              }

              _weekDaysController.text = currentDays.join(',');
            });
          },
          selectedColor: AppColors.bluePrimary,
          backgroundColor: AppColors.white,
          side: BorderSide(color: Colors.grey[300]!),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          labelPadding: EdgeInsets.zero,
        );
      }),
    );
  }
}
