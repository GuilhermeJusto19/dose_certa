import 'dart:async';

import 'package:dose_certa/Models/DataSource/lembrete_box_handler.dart';
import 'package:dose_certa/Models/Models/consulta.dart';
import 'package:dose_certa/Models/Models/lembrete.dart';
import 'package:dose_certa/Models/Models/medicamento.dart';
import 'package:dose_certa/Models/Models/tarefa.dart';
import 'package:dose_certa/Models/Repositories/tarefa_repository_imp.dart';
import 'package:dose_certa/viewmodels/mobile/estoque_viewmodel.dart';
import 'package:dose_certa/viewmodels/mobile/user_viewmodel.dart';
import 'package:dose_certa/Models/services/notifications_service.dart';
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

/// Controller responsável por gerenciar as tarefas (medicamentos e consultas).
///
/// Documentação (PT-BR):
/// - Responsabilidades:
///   * Criar tarefas a partir de medicamentos/consultas e persistir no Firestore.
///   * Quando a operação for local (sem `userId`), também persiste lembretes
///     locais no Hive e agenda notificações locais.
/// - Observação: preservei a lógica original; a refatoração extraiu helpers
///   para reduzir duplicação sem alterar o comportamento.
class TarefaViewModel extends ChangeNotifier {
  final TarefaRepositoryImp _repository;

  final int diasAdiante = 15;

  void Function(
    String nomeMedicamento,
    int quantidadeAtual,
    int quantidadeMinima,
  )?
  onEstoqueBaixo;

  TarefaViewModel({TarefaRepositoryImp? repository})
    : _repository = repository ?? TarefaRepositoryImp();

  final LembreteBoxHandler _lembreteHandler = LembreteBoxHandler();

  List<Tarefa> _tarefas = [];
  bool _isLoading = false;
  StreamSubscription<List<Tarefa>>? _subscription;

  List<Tarefa> get tarefas => _tarefas;
  bool get isLoading => _isLoading;

  bool _isLocalOperation(String? userId) {
    return userId == null || userId == UserViewModel().currentUser!.id;
  }

  Future<void> _persistAndSchedule(List<Tarefa> tarefas, String? userId) async {
    final bool isLocal = _isLocalOperation(userId);
    for (final tarefa in tarefas) {
      await _repository.addTarefa(tarefa, userId: userId);
      if (isLocal) {
        final Lembrete lembrete = _createLembreteFromTarefa(tarefa);
        await _lembreteHandler.addLembrete(lembrete);
        if (lembrete.dateTime.isAfter(DateTime.now())) {
          await NotificationsService().scheduleLembrete(lembrete);
        }
      }
    }
  }

  Future<void> addTarefa({
    Medicamento? medicamento,
    Consulta? consulta,
    String? userId,
  }) async {
    if (medicamento != null) {
      switch (medicamento.frequency) {
        case 'A cada X horas':
          final tarefas = gerarTarefasACadaXHoras(medicamento, diasAdiante);
          await _persistAndSchedule(tarefas, userId);
          break;
        case 'X vezes ao dia':
          final tarefas = gerarTarefasXVezesDia(medicamento, diasAdiante);
          await _persistAndSchedule(tarefas, userId);
          break;
        case 'Dias específicos da semana':
          final tarefas = gerarTarefasDiasEspecificos(medicamento, diasAdiante);
          await _persistAndSchedule(tarefas, userId);
          break;
        case 'Diariamente':
          final tarefas = gerarTarefasDiariamente(medicamento, diasAdiante);
          await _persistAndSchedule(tarefas, userId);
          break;
        default:
          throw ArgumentError('Recorrência de medicamento desconhecida');
      }
    } else if (consulta != null) {
      final Tarefa tarefa = gerarTarefaConsulta(consulta).first;
      await _repository.addTarefa(tarefa, userId: userId);
      if (_isLocalOperation(userId)) {
        final Lembrete lembrete = _createLembreteFromTarefa(tarefa);
        await _lembreteHandler.addLembrete(lembrete);
        if (lembrete.dateTime.isAfter(DateTime.now())) {
          await NotificationsService().scheduleLembrete(lembrete);
        }
      }
    } else {
      throw ArgumentError('Deve ser informado um medicamento ou uma consulta');
    }
  }

  Future<void> editTarefa(Tarefa tarefa, {String? userId}) async {
    try {
      _isLoading = true;

      final int index = _tarefas.indexWhere((c) => c.id == tarefa.id);
      if (index != -1) {
        _tarefas[index] = tarefa;
      }

      await _repository.editTarefa(tarefa, userId: userId);
      notifyListeners();
    } catch (e) {
      debugPrint('Erro ao adicionar tarefa: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateEstoque(
    Tarefa tarefa,
    bool isChecked, {
    String? userId,
  }) async {
    try {
      final estoqueViewModel = EstoqueViewModel();

      estoqueViewModel.loadEstoques(userId: userId);

      await Future.delayed(const Duration(milliseconds: 500));

      final estoquesDoMedicamento = estoqueViewModel.estoques
          .where((e) => e.medicamento == tarefa.taskId)
          .toList();

      if (estoquesDoMedicamento.isEmpty) {
        debugPrint(
          'Nenhum estoque encontrado para o medicamento ${tarefa.taskName}',
        );
        return;
      }

      final estoqueAtual = estoquesDoMedicamento.first;
      final quantidadeTarefa = tarefa.qtdMedicamento ?? 1;

      final novaQuantidade = isChecked
          ? estoqueAtual.quantity - quantidadeTarefa
          : estoqueAtual.quantity + quantidadeTarefa;

      final quantidadeFinal = novaQuantidade < 0 ? 0 : novaQuantidade;

      final estoqueAtualizado = estoqueAtual.copyWith(
        quantity: quantidadeFinal,
      );

      await estoqueViewModel.editEstoque(estoqueAtualizado, userId: userId);

      if (isChecked && quantidadeFinal <= estoqueAtual.minimalQuantity) {
        await _dispararNotificacaoEstoqueBaixo(
          nomeMedicamento: tarefa.taskName,
          quantidadeAtual: quantidadeFinal,
          quantidadeMinima: estoqueAtual.minimalQuantity,
        );

        onEstoqueBaixo?.call(
          tarefa.taskName,
          quantidadeFinal,
          estoqueAtual.minimalQuantity,
        );
      }

      debugPrint(
        'Estoque atualizado: ${tarefa.taskName} - Quantidade: $quantidadeFinal',
      );
    } catch (e) {
      debugPrint('Erro ao atualizar estoque: $e');
    }
  }

  Future<void> _dispararNotificacaoEstoqueBaixo({
    required String nomeMedicamento,
    required int quantidadeAtual,
    required int quantidadeMinima,
  }) async {
    try {
      final lembrete = Lembrete(
        id: Uuid().v1(),
        taskId: 'estoque_baixo',
        taskType: 'Alerta',
        title: 'Estoque baixo: $nomeMedicamento',
        description: quantidadeAtual == 0
            ? 'O estoque de $nomeMedicamento acabou! Quantidade mínima recomendada: $quantidadeMinima.'
            : 'O estoque de $nomeMedicamento está baixo ($quantidadeAtual restante). Quantidade mínima recomendada: $quantidadeMinima.',
        dateTime: DateTime.now().add(const Duration(minutes: 15)),
      );

      await NotificationsService().scheduleLembrete(lembrete);
      debugPrint(
        'Notificação de estoque baixo disparada para $nomeMedicamento',
      );
    } catch (e) {
      debugPrint('Erro ao disparar notificação de estoque baixo: $e');
    }
  }

  Future<void> deleteTarefa(String taskId, {String? userId}) async {
    try {
      final bool isLocal = _isLocalOperation(userId);

      await _repository.deleteTarefaRecurrence(taskId, userId: userId);

      if (isLocal) {
        final List<Lembrete> lembretes = _lembreteHandler.getLembreteRecurrence(
          taskId,
        );
        for (final lembrete in lembretes) {
          try {
            await NotificationsService().cancelLembreteById(lembrete.id);
          } catch (_) {}
        }
        await _lembreteHandler.deleteLembreteRecurrence(taskId);
      }

      _tarefas.removeWhere((c) => c.taskId == taskId);
      notifyListeners();
    } catch (e) {
      debugPrint('Erro ao deletar tarefa: $e');
    }
  }

  Lembrete _createLembreteFromTarefa(Tarefa tarefa) {
    final bool isConsulta = tarefa.taskType == 'Consulta';
    final DateTime lembreteDate = isConsulta
        ? tarefa.executionTime.subtract(const Duration(hours: 1))
        : tarefa.executionTime;

    final String title = isConsulta
        ? '${tarefa.taskName} em 1 hora'
        : 'Hora do medicamento: ${tarefa.taskName}';
    final String description = isConsulta
        ? 'Você tem uma consulta agendada: ${tarefa.taskName}${tarefa.doctorConsulta != null ? ' com o(a) ${tarefa.doctorConsulta}' : ''}'
        : '${tarefa.qtdMedicamento} ${tarefa.unitMedicamento}';

    return Lembrete(
      id: Uuid().v1(),
      taskId: tarefa.taskId,
      taskType: tarefa.taskType,
      title: title,
      description: description,
      dateTime: lembreteDate,
    );
  }

  void loadTarefas({String? userId}) {
    _subscription?.cancel();
    _subscription = _repository
        .getTarefas(userId: userId)
        .listen(
          (List<Tarefa> newRecord) async {
            final List<Future<void>> updates = <Future<void>>[];
            final List<Tarefa> adjusted = <Tarefa>[];

            for (final Tarefa t in newRecord) {
              if (t.state != 'Executada' && t.state != 'Pendente') {
                final Tarefa updated = t.copyWith(state: 'Pendente');
                adjusted.add(updated);
                updates.add(_repository.editTarefa(updated, userId: userId));
              } else {
                adjusted.add(t);
              }
            }

            if (updates.isNotEmpty) {
              try {
                await Future.wait(updates);
              } catch (e) {
                debugPrint('Erro ao normalizar estados das tarefas: $e');
              }
            }

            _tarefas = adjusted;
            notifyListeners();
          },
          onError: (error) {
            return error;
          },
        );
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  List<Tarefa> gerarTarefaConsulta(Consulta consulta) {
    return [
      Tarefa(
        id: Uuid().v1(),
        taskId: consulta.id,
        taskType: 'Consulta',
        taskName: consulta.name,
        doctorConsulta: consulta.doctor,
        executionTime: consulta.dateTime,
        state: 'Novo',
      ),
    ];
  }

  List<Tarefa> gerarTarefasACadaXHoras(Medicamento med, int diasAdiante) {
    final DateTime now = DateTime.now();
    final DateTime dataFinal = now.add(Duration(days: diasAdiante));

    final List<Tarefa> lembretes = <Tarefa>[];
    DateTime proximo = med.startDate;

    while (proximo.isBefore(dataFinal)) {
      if (proximo.isAfter(now)) {
        lembretes.add(
          Tarefa(
            id: Uuid().v1(),
            taskId: med.id,
            taskName: med.name,
            taskType: 'Medicamento',
            qtdMedicamento: med.quantity,
            unitMedicamento: med.unit,
            executionTime: proximo,
            state: 'Novo',
          ),
        );
      }
      proximo = proximo.add(Duration(hours: med.intervalHours!));
    }

    return lembretes;
  }

  List<Tarefa> gerarTarefasXVezesDia(Medicamento med, int diasAdiante) {
    final DateTime now = DateTime.now();
    final List<Tarefa> lembretes = <Tarefa>[];

    for (int i = 0; i < diasAdiante; i++) {
      final DateTime dia = med.startDate.add(Duration(days: i));
      for (final horario in med.reminderTimes) {
        final DateTime lembreteDate = DateTime(
          dia.year,
          dia.month,
          dia.day,
          horario.hour,
          horario.minute,
        );

        if (lembreteDate.isAfter(now)) {
          lembretes.add(
            Tarefa(
              id: Uuid().v1(),
              taskId: med.id,
              taskName: med.name,
              taskType: 'Medicamento',
              qtdMedicamento: med.quantity,
              unitMedicamento: med.unit,
              executionTime: lembreteDate,
              state: 'Novo',
            ),
          );
        }
      }
    }

    return lembretes;
  }

  List<Tarefa> gerarTarefasDiasEspecificos(Medicamento med, int diasAdiante) {
    final DateTime now = DateTime.now();
    final List<Tarefa> lembretes = <Tarefa>[];

    for (int i = 0; i < diasAdiante; i++) {
      final DateTime dia = med.startDate.add(Duration(days: i));
      final int diaSemana = dia.weekday;

      if (med.weekDays!.contains(diaSemana)) {
        for (final horario in med.reminderTimes) {
          final DateTime lembreteDate = DateTime(
            dia.year,
            dia.month,
            dia.day,
            horario.hour,
            horario.minute,
          );

          if (lembreteDate.isAfter(now)) {
            lembretes.add(
              Tarefa(
                id: Uuid().v1(),
                taskId: med.id,
                taskName: med.name,
                taskType: 'Medicamento',
                qtdMedicamento: med.quantity,
                unitMedicamento: med.unit,
                executionTime: lembreteDate,
                state: 'Novo',
              ),
            );
          }
        }
      }
    }

    return lembretes;
  }

  List<Tarefa> gerarTarefasDiariamente(Medicamento med, int diasAdiante) {
    final DateTime now = DateTime.now();
    final List<Tarefa> lembretes = <Tarefa>[];

    for (int i = 0; i < diasAdiante; i++) {
      final DateTime dia = med.startDate.add(Duration(days: i));

      for (final horario in med.reminderTimes) {
        final DateTime lembreteDate = DateTime(
          dia.year,
          dia.month,
          dia.day,
          horario.hour,
          horario.minute,
        );

        if (lembreteDate.isAfter(now)) {
          lembretes.add(
            Tarefa(
              id: Uuid().v1(),
              taskId: med.id,
              taskName: med.name,
              taskType: 'Medicamento',
              qtdMedicamento: med.quantity,
              unitMedicamento: med.unit,
              executionTime: lembreteDate,
              state: 'Novo',
            ),
          );
        }
      }
    }

    return lembretes;
  }
}
