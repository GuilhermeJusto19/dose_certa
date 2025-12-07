import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

import 'package:dose_certa/Models/Models/tarefa.dart';
import 'package:dose_certa/Views/Mobile/Lista%20Diaria/widgets/tarefa_card.dart';
import 'package:dose_certa/viewmodels/mobile/tarefa_viewmodel.dart';
import 'package:dose_certa/_Core/theme/app_colors.dart';
import 'package:dose_certa/_Core/theme/app_text_style.dart';

class TarefaSliverList extends StatefulWidget {
  /// Lista de tarefas agrupadas por horário para exibição em um `CustomScrollView`.
  ///
  /// Recebe a lista de `items` (tarefas) e preserva toda a lógica de interação
  /// original (checagem, edição e diálogo de comentário).
  final List<Tarefa> items;

  const TarefaSliverList({super.key, required this.items});

  @override
  State<TarefaSliverList> createState() => _TarefaSliverListState();
}

class _TarefaSliverListState extends State<TarefaSliverList> {
  // Mantém o estado dos checkboxes por tarefa (id -> checked)
  final Map<String, bool> _checked = <String, bool>{};

  // Instância local de controller usada apenas no diálogo de comentário.
  final TarefaViewModel _fallbackController = TarefaViewModel();

  @override
  void initState() {
    super.initState();
    // inicializa o mapa de checkeds (padrão: true se state == 'Executada')
    for (final t in widget.items) {
      _checked.putIfAbsent(t.id, () => t.state == 'Executada');
    }
  }

  @override
  void didUpdateWidget(covariant TarefaSliverList oldWidget) {
    super.didUpdateWidget(oldWidget);
    final newIds = widget.items.map((e) => e.id).toSet();
    _checked.removeWhere((key, value) => !newIds.contains(key));
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
    final grouped = _groupByHour(widget.items);

    return CustomScrollView(
      slivers: [
        _buildHeader(),
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
                              ? '${item.qtdMedicamento} ${item.unitMedicamento}'
                              : item.doctorConsulta ?? '',
                          checked: isChecked,
                          onChanged: (val) async {
                            setState(() {
                              _checked[item.id] = val;
                            });

                            // Persiste o estado atualizado: 'Executada' quando marcado,
                            // 'Pendente' quando desmarcado. Lógica preservada.
                            final newState = val ? 'Executada' : 'Pendente';
                            final updated = item.copyWith(state: newState);
                            try {
                              await tarefaController.editTarefa(updated);

                              if (item.taskType == 'Medicamento') {
                                // Atualiza o estoque: reduz ao marcar, aumenta ao desmarcar
                                await tarefaController.updateEstoque(item, val);
                              }
                            } catch (e) {
                              // Reverte UI em caso de falha
                              setState(() {
                                _checked[item.id] = !val;
                              });
                              debugPrint('Falha ao atualizar tarefa: $e');
                            }
                          },
                          onTap: () {
                            showDialog<Tarefa?>(
                              context: context,
                              builder: (context) =>
                                  _buildAlertDialog(context, item),
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

  /// Agrupa tarefas por hora no formato `HH:mm`.
  Map<String, List<Tarefa>> _groupByHour(List<Tarefa> items) {
    final Map<String, List<Tarefa>> grouped = <String, List<Tarefa>>{};
    for (final item in items) {
      final hourKey =
          '${item.executionTime.hour.toString().padLeft(2, '0')}:${item.executionTime.minute.toString().padLeft(2, '0')}';
      grouped.putIfAbsent(hourKey, () => <Tarefa>[]);
      grouped[hourKey]!.add(item);
    }
    return grouped;
  }

  /// Constrói o header superior (divisor + título "Hoje" e progresso).
  Widget _buildHeader() {
    return SliverToBoxAdapter(
      child: Column(
        children: [
          // Divisor
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Divider(color: AppColors.gray600, thickness: 1),
          ),
          // Hoje + progresso
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 8, 35, 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Hoje',
                  style: AppTextStyles.semibold24.copyWith(
                    color: AppColors.mainTextColor,
                  ),
                ),
                Row(
                  children: [
                    // Linear Progress
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
    );
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
                decoration: const InputDecoration(
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
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Fechar'),
        ),
        TextButton(
          onPressed: () async {
            final text = controller.text.trim();
            final updated = item.copyWith(comment: text.isEmpty ? null : text);
            try {
              await _fallbackController.editTarefa(updated);
              Navigator.of(context).pop();
            } catch (e) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Erro ao salvar comentário: $e')),
              );
            }
          },
          child: const Text('Salvar'),
        ),
      ],
    );
  }
}
