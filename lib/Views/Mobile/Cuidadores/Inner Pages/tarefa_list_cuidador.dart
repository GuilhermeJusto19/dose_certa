import 'package:dose_certa/viewmodels/mobile/user_viewmodel.dart';
import 'package:dose_certa/Models/Models/tarefa.dart';
import 'package:dose_certa/Views/Mobile/Lista%20Diaria/widgets/tarefa_card.dart';
import 'package:provider/provider.dart';
import 'package:dose_certa/viewmodels/mobile/tarefa_viewmodel.dart';
import 'package:dose_certa/_Core/theme/app_colors.dart';
import 'package:dose_certa/_Core/theme/app_text_style.dart';
import 'package:flutter/material.dart';

class TarefaListCuidador extends StatefulWidget {
  final List<Tarefa> items;

  const TarefaListCuidador({super.key, required this.items});

  @override
  State<TarefaListCuidador> createState() => _TarefaListCuidadorState();
}

class _TarefaListCuidadorState extends State<TarefaListCuidador> {
  // Mantém o estado dos checkboxes
  final Map<String, bool> _checked = {};
  final _userController = UserViewModel();
  final tarefaController = TarefaViewModel();

  @override
  void initState() {
    super.initState();
    // inicializa o mapa de checkeds (padrão falso)
    for (var t in widget.items) {
      _checked.putIfAbsent(t.id, () => t.state == 'Executada');
    }
  }

  @override
  void didUpdateWidget(covariant TarefaListCuidador oldWidget) {
    super.didUpdateWidget(oldWidget);
    // synchronize checked map with incoming items, keep existing checks when possible
    final newIds = widget.items.map((e) => e.id).toSet();
    // remove stale entries
    _checked.removeWhere((key, value) => !newIds.contains(key));
    // add any new items
    for (final t in widget.items) {
      _checked.putIfAbsent(t.id, () => t.state == 'Executada');
    }
  }

  double _progressValue() {
    if (widget.items.isEmpty) return 0.0;
    final total = widget.items.length;
    final done = _checked.values.where((v) => v).length;
    return total == 0 ? 0.0 : (done / total).clamp(0.0, 1.0);
  }

  @override
  Widget build(BuildContext context) {
    final grouped = groupByHour(widget.items);

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Column(
            children: [
              //* Hoje
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 8, 35, 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Hoje",
                      style: AppTextStyles.semibold24.copyWith(
                        color: AppColors.mainTextColor,
                      ),
                    ),
                    Row(
                      children: [
                        //* Linear Progress
                        Padding(
                          padding: const EdgeInsets.only(right: 5),
                          child: SizedBox(
                            width: 100,
                            child: LinearProgressIndicator(
                              value: _progressValue(),
                              color: AppColors.bluePrimary,
                              backgroundColor: AppColors.gray500,
                            ),
                          ),
                        ),
                        Icon(
                          Icons.sentiment_satisfied_alt_rounded,
                          color: AppColors.bluePrimary,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        SliverList(
          delegate: SliverChildListDelegate(
            grouped.entries.expand((entry) {
              final hour = entry.key;
              final scheduleItems = entry.value;

              return [
                // Cabeçalho do horário
                Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 0,
                    horizontal: 24,
                  ),
                  child: Text(hour, style: AppTextStyles.medium16),
                ),
                // Cards das tarefas
                ...scheduleItems.map(
                  (item) => Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 4,
                    ),
                    child: Builder(
                      builder: (context) {
                        final tarefaController = Provider.of<TarefaViewModel>(
                          context,
                          listen: false,
                        );
                        final isChecked =
                            _checked[item.id] ?? (item.state == 'Executada');

                        return TarefaCard(
                          title: item.taskName,
                          subtitle:
                              item.qtdMedicamento != null &&
                                  item.unitMedicamento != null
                              ? "${item.qtdMedicamento} ${item.unitMedicamento}"
                              : item.doctorConsulta ?? '',
                          checked: isChecked,
                          onChanged: (val) async {
                            setState(() {
                              _checked[item.id] = val;
                            });

                            // Persist the updated state: Executada when checked, Pendente when unchecked
                            final newState = val ? 'Executada' : 'Pendente';
                            final updated = item.copyWith(state: newState);
                            try {
                              await tarefaController.editTarefa(
                                updated,
                                userId:
                                    _userController.currentUser!.associetedId,
                              );
                            } catch (e) {
                              // revert UI on failure
                              setState(() {
                                _checked[item.id] = !val;
                              });
                              debugPrint('Falha ao atualizar tarefa: $e');
                            }
                          },
                          onTap: () {
                            showDialog(
                              context: context,
                              builder: (context) {
                                return _buildAlertDialog(context, item);
                              },
                            );
                          },
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ];
            }).toList(),
          ),
        ),
      ],
    );
  }

  Map<String, List<Tarefa>> groupByHour(List<Tarefa> items) {
    Map<String, List<Tarefa>> grouped = {};
    for (var item in items) {
      final hourKey =
          "${item.executionTime.hour.toString().padLeft(2, '0')}:${item.executionTime.minute.toString().padLeft(2, '0')}";
      grouped.putIfAbsent(hourKey, () => []);
      grouped[hourKey]!.add(item);
    }
    return grouped;
  }

  Widget _buildAlertDialog(BuildContext context, Tarefa item) {
    final controller = TextEditingController(text: item.comment ?? '');
    final textStyle = AppTextStyles.medium14.copyWith(
      color: AppColors.mainTextColor,
    );

    return AlertDialog(
      title: Text(
        item.comment == null || item.comment!.isEmpty
            ? 'Adicionar comentário'
            : 'Editar comentário',
      ),
      content: SingleChildScrollView(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.6,
            minWidth: double.maxFinite,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Nome: ${item.taskName}', style: textStyle),
              const SizedBox(height: 8),
              if (item.qtdMedicamento != null && item.unitMedicamento != null)
                Text(
                  'Quantidade: ${item.qtdMedicamento} ${item.unitMedicamento}',
                  style: textStyle,
                ),
              if (item.doctorConsulta != null)
                Text('Consulta com: ${item.doctorConsulta}', style: textStyle),
              const SizedBox(height: 12),
              TextField(
                controller: controller,
                maxLines: null,
                minLines: 3,
                keyboardType: TextInputType.multiline,
                decoration: InputDecoration(
                  labelText: 'Comentário',
                  hintText: 'Adicione um comentário (opcional)',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: Text('Fechar'),
        ),
        TextButton(
          onPressed: () async {
            final text = controller.text.trim();
            final updated = item.copyWith(comment: text.isEmpty ? null : text);
            try {
              await tarefaController.editTarefa(
                updated,
                userId: _userController.currentUser!.associetedId,
              );
              Navigator.of(context).pop();
            } catch (e) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Erro ao salvar comentário: $e')),
              );
            }
          },
          child: Text('Salvar'),
        ),
      ],
    );
  }
}
