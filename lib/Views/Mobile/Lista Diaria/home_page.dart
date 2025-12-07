import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

import 'package:dose_certa/Views/Mobile/Lista%20Diaria/widgets/tarefa_list.dart';
import 'package:dose_certa/Views/_shared/empty_screen.dart';
import 'package:dose_certa/_Core/theme/app_colors.dart';
import 'package:dose_certa/viewmodels/mobile/tarefa_viewmodel.dart';

/// Tela principal da lista diária.
///
/// Fornece a lista de tarefas do dia e um estado vazio quando não há tarefas.
/// A lógica original que carrega tarefas e o RefreshIndicator foi preservada.
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  /// Controller responsável por carregar e expor as `tarefas`.
  late final TarefaViewModel _controller;

  @override
  void initState() {
    super.initState();
    _controller = TarefaViewModel();

    // Configura o callback para exibir SnackBar quando estoque estiver baixo
    _controller
        .onEstoqueBaixo = (nomeMedicamento, quantidadeAtual, quantidadeMinima) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.warning_amber_rounded, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    quantidadeAtual == 0
                        ? 'Estoque de $nomeMedicamento acabou! Reponha urgentemente.'
                        : 'Estoque baixo: $nomeMedicamento ($quantidadeAtual restante). Mínimo recomendado: $quantidadeMinima.',
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
            backgroundColor: Colors.amber[700],
            duration: const Duration(seconds: 5),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    };
  }

  @override
  Widget build(BuildContext context) {
    // Mantive a chamada `loadTarefas()` via cascade no provider para preservar
    // exatamente o comportamento anterior (não movi a chamada para initState).
    return ChangeNotifierProvider<TarefaViewModel>.value(
      value: _controller..loadTarefas(),
      child: Consumer<TarefaViewModel>(
        builder: (context, vm, child) {
          if (vm.tarefas.isEmpty) {
            return _buildEmptyScreen();
          }

          return RefreshIndicator(
            onRefresh: () async {
              vm.loadTarefas();
              return Future<void>.delayed(const Duration(milliseconds: 200));
            },
            child: Container(
              color: AppColors.mainBackground,
              child: TarefaSliverList(items: vm.tarefas),
            ),
          );
        },
      ),
    );
  }

  /// Widget auxiliar para a tela vazia (nenhuma tarefa).
  Widget _buildEmptyScreen() {
    return Container(
      color: AppColors.mainBackground,
      child: const Center(
        child: EmptyScreen(
          title: 'Nenhuma tarefa para hoje',
          message:
              'Parece que você não tem tarefas para hoje. Aproveite seu dia!',
          imagePath: 'assets/images/task_empty_screen-removebg-preview.png',
          scale: 2.0,
        ),
      ),
    );
  }

  /// Agrupa tarefas por hora de execução no formato `HH:mm`.
  ///
  /// Método preserva a lógica original; renomeado para privado para
  /// indicar uso interno.
  // Map<String, List<Tarefa>> _groupByHour(List<Tarefa> items) {
  //   final Map<String, List<Tarefa>> grouped = {};
  //   for (final item in items) {
  //     final hourKey =
  //         '${item.executionTime.hour.toString().padLeft(2, '0')}:${item.executionTime.minute.toString().padLeft(2, '0')}';
  //     grouped.putIfAbsent(hourKey, () => <Tarefa>[]);
  //     grouped[hourKey]!.add(item);
  //   }
  //   return grouped;
  // }
}
