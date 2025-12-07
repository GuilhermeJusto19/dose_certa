import 'package:dose_certa/Models/Models/estoque.dart';
import 'package:dose_certa/viewmodels/mobile/estoque_viewmodel.dart';
import 'package:dose_certa/viewmodels/mobile/medicamento_viewmodel.dart';
import 'package:dose_certa/Models/Models/medicamento.dart';
import 'package:dose_certa/_Core/constants/constants.dart';
import 'package:uuid/uuid.dart';
import 'package:dose_certa/Views/_shared/custom_back_button.dart';
import 'package:dose_certa/Views/_shared/primary_button.dart';
import 'package:dose_certa/_Core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:dose_certa/_Core/theme/app_text_style.dart';

class AddMedicamentoPage extends StatefulWidget {
  const AddMedicamentoPage({super.key});

  @override
  State<AddMedicamentoPage> createState() => _AddMedicamentoPageState();
}

class _AddMedicamentoPageState extends State<AddMedicamentoPage> {
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
  late TextEditingController _estoqueQuantityController;
  late TextEditingController _estoqueMinimalQuantityController;

  late DateTime _pickedDate;
  late TimeOfDay _pickedTime;
  final List<TextEditingController> _reminderControllers = [];
  final List<TimeOfDay?> _reminderTimeOfDays = [];

  late MedicamentoViewModel _viewmodel;
  late EstoqueViewModel _estoqueViewModel;
  bool _isEstoqueExpanded = false;

  @override
  void initState() {
    _nameController = TextEditingController();
    _quantityController = TextEditingController();
    _unitController = TextEditingController(text: 'comprimido(s)');
    _frequencyController = TextEditingController(text: 'Diariamente');
    _intervalController = TextEditingController();
    _timesPerDayController = TextEditingController();
    _weekDaysController = TextEditingController();
    _startDateController = TextEditingController();
    _reminderTimeController = TextEditingController();
    _noteController = TextEditingController();
    _estoqueQuantityController = TextEditingController();
    _estoqueMinimalQuantityController = TextEditingController();
    _viewmodel = MedicamentoViewModel();
    _estoqueViewModel = EstoqueViewModel();
    _focusNode.addListener(() {
      if (!_focusNode.hasFocus) {
        _timesPerDayFieldKey.currentState?.validate();
      }
    });
    super.initState();
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
    _estoqueQuantityController.dispose();
    _estoqueMinimalQuantityController.dispose();
    for (final c in _reminderControllers) {
      c.dispose();
    }
    _focusNode.dispose();
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
                    const SizedBox(height: 20),
                    _buildTextField(
                      controller: _nameController,
                      label: 'Medicamento',
                      hint: 'Ex: Omeprazol',
                      validator: (v) => v == null || v.isEmpty
                          ? 'Digite o nome do medicamento'
                          : null,
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                              if (int.tryParse(v) == null ||
                                  int.parse(v) <= 0) {
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
                    const SizedBox(height: 20),
                    _buildFrequencyDropdown(),
                    const SizedBox(height: 20),
                    ..._buildIntervalAndTimesFields(),
                    const SizedBox(height: 20),
                    _buildDescriptionField(),
                    const SizedBox(height: 20),
                    _buildEstoqueSection(),
                    const SizedBox(height: 40),
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
      clipBehavior: Clip.hardEdge,
      keyboardType: keyboardType,
      onChanged: onChanged,
      decoration: _baseDecoration(label: label, hint: hint),
      validator: validator,
      focusNode: focusNode,
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
      controller: _noteController,
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

  Widget _buildUnitDropdown() {
    return DropdownButtonFormField<String>(
      initialValue: _unitController.text,
      decoration: _baseDecoration(label: 'Unidade'),
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
      initialValue: _frequencyController.text.isNotEmpty
          ? _frequencyController.text
          : 'Diariamente',
      decoration: _baseDecoration(label: 'Frequência'),
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
      final section = [
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
        const SizedBox(height: 20),
      ];
      widgets.addAll(section);
    } else if (_frequencyController.text == 'X vezes ao dia') {
      final section = [
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
            if (int.tryParse(v) == null || int.parse(v) >= 5) {
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
        const SizedBox(height: 20),
      ];
      widgets.addAll(section);
    } else if (_frequencyController.text == 'Dias específicos da semana') {
      final section = [_buildDaysSelection(), const SizedBox(height: 20)];
      widgets.addAll(section);
    }

    final defaultSection = [
      _buildReadOnlyField(
        controller: _startDateController,
        label: 'Data de início',
        prefix: const Icon(Icons.calendar_month),
        onTap: _selectDate,
        validator: (v) =>
            v == null || v.isEmpty ? 'Digite a data de início' : null,
      ),
    ];

    if (_frequencyController.text != 'X vezes ao dia') {
      defaultSection.add(const SizedBox(height: 20));
      defaultSection.add(
        _buildReadOnlyField(
          controller: _reminderTimeController,
          label: 'Horário',
          prefix: const Icon(Icons.access_time),
          onTap: _selectTime,
          validator: (v) =>
              v == null || v.isEmpty ? 'Digite o horário da consulta' : null,
        ),
      );
    }

    widgets.addAll(defaultSection);
    return widgets;
  }

  void _ensureReminderControllers(int count) {
    // create controllers up to count
    while (_reminderControllers.length < count) {
      _reminderControllers.add(TextEditingController());
      _reminderTimeOfDays.add(null);
    }
    // if too many, remove extras
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

  List<Widget> _buildReminderTimePickers() {
    final widgets = <Widget>[];
    for (var i = 0; i < _reminderControllers.length; i++) {
      widgets.add(const SizedBox(height: 20));
      widgets.add(
        _buildReadOnlyField(
          controller: _reminderControllers[i],
          label: 'Horário ${i + 1}',
          prefix: const Icon(Icons.access_time),
          onTap: () async {
            final picked = await showTimePicker(
              context: context,
              initialTime: TimeOfDay(hour: 8, minute: 0),
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
    _pickedTime =
        _reminderTimeOfDays.isNotEmpty && _reminderTimeOfDays[0] != null
        ? _reminderTimeOfDays[0]!
        : TimeOfDay(hour: 8, minute: 0);
    return widgets;
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

  Widget _buildDaysSelection() {
    final days = Constants.weekDaysOptions;

    return SizedBox(
      width: double.infinity,
      child: GridView.count(
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

          return SizedBox.expand(
            child: FilterChip(
              showCheckmark: false,
              label: Center(
                child: Text(
                  days[index],
                  textAlign: TextAlign.center,
                  style: AppTextStyles.semibold15.copyWith(
                    color: isSelected
                        ? AppColors.white
                        : AppColors.mainTextColor,
                  ),
                ),
              ),
              selected: isSelected,
              onSelected: (bool selected) {
                setState(() {
                  final currentDays = _weekDaysController.text.isNotEmpty
                      ? _weekDaysController.text
                            .split(',')
                            .map(int.parse)
                            .toList()
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
              side: BorderSide(color: AppColors.blueWhite),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              labelPadding: EdgeInsets.zero,
            ),
          );
        }),
      ),
    );
  }

  Widget _buildEstoqueSection() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.gray700),
        borderRadius: BorderRadius.circular(4),
        color: AppColors.white,
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          title: Text(
            'Adicionar ao Estoque',
            style: AppTextStyles.medium16.copyWith(
              color: AppColors.mainTextColor,
            ),
          ),
          trailing: Icon(
            _isEstoqueExpanded
                ? Icons.keyboard_arrow_up
                : Icons.keyboard_arrow_down,
            color: AppColors.mainTextColor,
          ),
          onExpansionChanged: (expanded) {
            setState(() {
              _isEstoqueExpanded = expanded;
            });
          },
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildTextField(
                    controller: _estoqueQuantityController,
                    label: 'Quantidade em Estoque',
                    hint: 'Ex: 30',
                    keyboardType: TextInputType.number,
                    validator: (v) {
                      if (_isEstoqueExpanded && (v == null || v.isEmpty)) {
                        return 'Digite a quantidade';
                      }
                      if (v != null &&
                          v.isNotEmpty &&
                          (int.tryParse(v) == null || int.parse(v) < 0)) {
                        return 'Quantidade inválida';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: _estoqueMinimalQuantityController,
                    label: 'Quantidade Mínima',
                    hint: 'Ex: 5',
                    keyboardType: TextInputType.number,
                    validator: (v) {
                      if (_isEstoqueExpanded && (v == null || v.isEmpty)) {
                        return 'Digite a quantidade mínima';
                      }
                      if (v != null &&
                          v.isNotEmpty &&
                          (int.tryParse(v) == null || int.parse(v) < 0)) {
                        return 'Quantidade inválida';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'O sistema alertará quando o estoque atingir a quantidade mínima',
                    style: AppTextStyles.medium14.copyWith(
                      color: AppColors.gray800,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _onSavePressed() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      DateTime fullDateTime = _completeDate(_pickedDate, _pickedTime);

      if (fullDateTime.isAtSameMomentAs(DateTime.now()) ||
          fullDateTime.isBefore(DateTime.now())) {
        _showSnackBar(
          "A atribuição do Medicamento não pode ser anterior a data atual.",
          color: Colors.red,
        );
        return;
      }

      if (_weekDaysController.text.isEmpty &&
          _frequencyController.text == 'Dias específicos da semana') {
        _showSnackBar(
          "Selecione ao menos um dia da semana.",
          color: Colors.red,
        );
        return;
      }

      if (_isEstoqueExpanded) {
        if (_estoqueMinimalQuantityController.text.isEmpty ||
            _estoqueQuantityController.text.isEmpty) {
          _showSnackBar("Preencha os campos do estoque.", color: Colors.red);
          return;
        }
      }

      List<DateTime> reminderTimes;
      if (_frequencyController.text == 'X vezes ao dia' &&
          _reminderControllers.isNotEmpty) {
        reminderTimes = _collectReminderDateTimes(fullDateTime);
      } else {
        reminderTimes = [fullDateTime];
      }

      _clearFields();

      Medicamento medicamento = Medicamento(
        id: Uuid().v1(),
        name: _nameController.text,
        frequency: _frequencyController.text,
        quantity: int.parse(_quantityController.text),
        unit: _unitController.text,
        intervalHours: _intervalController.text.isNotEmpty
            ? int.parse(_intervalController.text)
            : null,
        timesPerDay: _timesPerDayController.text.isNotEmpty
            ? int.parse(_timesPerDayController.text)
            : null,
        weekDays: _weekDaysController.text.isNotEmpty
            ? _weekDaysController.text.split(',').map(int.parse).toList()
            : null,
        startDate: fullDateTime,
        reminderTimes: reminderTimes,
        notes: _noteController.text.isNotEmpty ? _noteController.text : null,
      );

      await _viewmodel.addMedicamento(medicamento);

      if (_isEstoqueExpanded) {
        final estoque = Estoque(
          id: Uuid().v1(),
          medicamento: medicamento.id,
          quantity: int.parse(_estoqueQuantityController.text),
          minimalQuantity: int.parse(_estoqueMinimalQuantityController.text),
        );
        await _estoqueViewModel.addEstoque(estoque);
      }

      if (context.mounted) {
        Navigator.pop(context);
        _showSnackBar("Medicamento adicionado", color: Colors.green);
      }
    } catch (e) {
      _showSnackBar("Falha ao adicionar consulta: $e", color: Colors.red);
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
        _startDateController.text = DateFormat("dd/MM/yyyy").format(picked);
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
        _reminderTimeController.text = DateFormat("HH:mm").format(dt);
      });
    }
  }

  DateTime _completeDate(DateTime? date, TimeOfDay? time) {
    return DateTime(date!.year, date.month, date.day, time!.hour, time.minute);
  }
}
