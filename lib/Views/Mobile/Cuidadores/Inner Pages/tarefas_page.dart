import 'package:dose_certa/viewmodels/mobile/tarefa_viewmodel.dart';
import 'package:dose_certa/viewmodels/mobile/user_viewmodel.dart';
import 'package:dose_certa/Models/Models/tarefa.dart';
import 'package:dose_certa/Views/Mobile/Cuidadores/Inner%20Pages/tarefa_list_cuidador.dart';
import 'package:dose_certa/Views/_shared/empty_screen.dart';
import 'package:dose_certa/_Core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class TarefasPage extends StatefulWidget {
  const TarefasPage({super.key});

  @override
  State<TarefasPage> createState() => _TarefasPageState();
}

class _TarefasPageState extends State<TarefasPage> {
  late TarefaViewModel controller;
  final _userController = UserViewModel();
  String? _loadedForUserId;

  @override
  void initState() {
    controller = TarefaViewModel();

    // Configura o callback para exibir SnackBar quando estoque estiver baixo
    controller
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

    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final assocId = _userController.currentUser?.associetedId;
    if (assocId != _loadedForUserId) {
      _loadedForUserId = assocId;
      // Load tarefas for the associated patient (or current user if null)
      controller.loadTarefas(userId: assocId);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<TarefaViewModel>.value(
      value: controller,
      child: Consumer<TarefaViewModel>(
        builder: (context, vm, child) {
          if (vm.tarefas.isEmpty) {
            return RefreshIndicator(
              onRefresh: () async {
                vm.loadTarefas(
                  userId: _userController.currentUser!.associetedId,
                );
                return Future<void>.delayed(const Duration(milliseconds: 200));
              },
              child: Container(
                color: AppColors.mainBackground,
                child: ListView(
                  children: [
                    SizedBox(
                      height: MediaQuery.of(context).size.height,
                      child: Center(
                        child: EmptyScreen(
                          title: "Nenhuma tarefa para hoje",
                          message:
                              "Parece que você não tem tarefas para hoje. Aproveite seu dia!",
                          imagePath:
                              "assets/images/task_empty_screen-removebg-preview.png",
                          scale: 2.0,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              vm.loadTarefas(userId: _userController.currentUser!.associetedId);
              return Future<void>.delayed(const Duration(milliseconds: 200));
            },
            child: Container(
              color: AppColors.mainBackground,
              child: TarefaListCuidador(items: vm.tarefas),
            ),
          );
        },
      ),
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
}
