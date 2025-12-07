import 'package:flutter/material.dart';
import 'package:dose_certa/Models/Models/consulta.dart';
import 'package:dose_certa/Models/Models/doutor.dart';
import 'package:dose_certa/Models/Repositories/doutor_repository_imp.dart';
import 'package:dose_certa/_Core/theme/app_colors.dart';
import 'package:dose_certa/_Core/theme/app_text_style.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';

/// Dialog para adicionar/editar consulta.
class ConsultaFormDialog extends StatefulWidget {
  const ConsultaFormDialog({
    super.key,
    this.consulta,
    required this.editando,
    this.isClinica = false,
  });

  final Consulta? consulta;
  final bool editando;
  final bool isClinica;

  @override
  State<ConsultaFormDialog> createState() => _ConsultaFormDialogState();
}

class _ConsultaFormDialogState extends State<ConsultaFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nomeController;
  late final TextEditingController _doctorController;
  late final TextEditingController _descriptionController;
  DateTime? _selectedDateTime;
  final DoutorRepositoryImp _doutorRepository = DoutorRepositoryImp();
  List<Doutor> _doutores = [];
  List<Doutor> _filteredDoutores = [];
  bool _showDoutorSuggestions = false;

  @override
  void initState() {
    super.initState();
    _nomeController = TextEditingController(
      text: widget.editando ? widget.consulta?.name : '',
    );
    _doctorController = TextEditingController(
      text: widget.editando ? widget.consulta?.doctor : '',
    );
    _descriptionController = TextEditingController(
      text: widget.editando ? widget.consulta?.description : '',
    );
    _selectedDateTime = widget.editando ? widget.consulta?.dateTime : null;
    _loadDoutores();
  }

  void _loadDoutores() {
    _doutorRepository.getDoutors().listen((doutores) {
      if (mounted) {
        setState(() {
          _doutores = doutores;
          _filteredDoutores = doutores;
        });
      }
    });
  }

  void _filterDoutores(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredDoutores = _doutores;
        _showDoutorSuggestions = false;
      } else {
        _filteredDoutores = _doutores.where((doutor) {
          final nomeMatch = doutor.nome.toLowerCase().contains(
            query.toLowerCase(),
          );
          final especialidadeMatch = doutor.especialidade
              .toLowerCase()
              .contains(query.toLowerCase());
          return nomeMatch || especialidadeMatch;
        }).toList();
        _showDoutorSuggestions = true;
      }
    });
  }

  void _selectDoutor(Doutor doutor) {
    setState(() {
      _doctorController.text = doutor.nome;
      _showDoutorSuggestions = false;
    });
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _doctorController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _selectDateTime() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDateTime ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (date == null || !mounted) return;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_selectedDateTime ?? DateTime.now()),
    );

    if (time == null || !mounted) return;

    setState(() {
      _selectedDateTime = DateTime(
        date.year,
        date.month,
        date.day,
        time.hour,
        time.minute,
      );
    });
  }

  void _onSalvar() {
    if (_formKey.currentState?.validate() ?? false) {
      if (_selectedDateTime == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Selecione uma data e hora')),
        );
        return;
      }

      final consulta = Consulta(
        id: widget.editando ? widget.consulta!.id : const Uuid().v4(),
        name: _nomeController.text.trim(),
        doctor: _doctorController.text.trim().isEmpty
            ? null
            : _doctorController.text.trim(),
        description: _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
        dateTime: _selectedDateTime!,
        isClinica: widget.isClinica,
      );
      Navigator.pop(context, consulta);
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm');

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 500),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  widget.editando ? 'Editar Consulta' : 'Adicionar Consulta',
                  style: AppTextStyles.semibold20.copyWith(
                    color: AppColors.mainTextColor,
                  ),
                ),
                const SizedBox(height: 24),
                _buildTextField(
                  controller: _nomeController,
                  label: 'Nome da Consulta',
                  hint: 'Ex: Consulta Cardiologista',
                  required: true,
                ),
                const SizedBox(height: 16),
                _buildDoutorSearchField(),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _descriptionController,
                  label: 'Descrição',
                  hint: 'Observações adicionais',
                  required: false,
                  maxLines: 3,
                ),
                const SizedBox(height: 16),
                InkWell(
                  onTap: _selectDateTime,
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _selectedDateTime == null
                              ? 'Selecione data e hora'
                              : dateFormat.format(_selectedDateTime!),
                          style: TextStyle(
                            color: _selectedDateTime == null
                                ? Colors.grey[600]
                                : AppColors.mainTextColor,
                          ),
                        ),
                        const Icon(
                          Icons.calendar_today,
                          color: AppColors.blueAccent,
                        ),
                      ],
                    ),
                  ),
                ),
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
    required TextEditingController controller,
    required String label,
    required String hint,
    required bool required,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
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
      validator: required
          ? (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Campo obrigatório';
              }
              return null;
            }
          : null,
    );
  }

  Widget _buildDoutorSearchField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextFormField(
          controller: _doctorController,
          decoration: InputDecoration(
            labelText: 'Médico',
            hintText: 'Digite o nome do médico',
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
            suffixIcon: _doctorController.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      setState(() {
                        _doctorController.clear();
                        _showDoutorSuggestions = false;
                      });
                    },
                  )
                : null,
          ),
          onChanged: _filterDoutores,
          onTap: () {
            if (_doctorController.text.isNotEmpty) {
              _filterDoutores(_doctorController.text);
            } else {
              setState(() {
                _filteredDoutores = _doutores;
                _showDoutorSuggestions = true;
              });
            }
          },
        ),
        if (_showDoutorSuggestions && _filteredDoutores.isNotEmpty)
          Container(
            margin: const EdgeInsets.only(top: 4),
            constraints: const BoxConstraints(maxHeight: 200),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[300]!),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: _filteredDoutores.length,
              itemBuilder: (context, index) {
                final doutor = _filteredDoutores[index];
                return ListTile(
                  title: Text(doutor.nome, style: AppTextStyles.semibold16),
                  subtitle: Text(
                    doutor.especialidade,
                    style: AppTextStyles.medium14.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                  onTap: () => _selectDoutor(doutor),
                  hoverColor: AppColors.blueAccent.withOpacity(0.1),
                );
              },
            ),
          ),
      ],
    );
  }
}
