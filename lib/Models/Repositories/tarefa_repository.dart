import 'package:dose_certa/Models/Models/tarefa.dart';

abstract class TarefaRepository {
  Future<void> addTarefa(Tarefa tarefa, {String? userId});

  Future<void> editTarefa(Tarefa tarefa, {String? userId});

  Future<void> deleteTarefa(String id, {String? userId});

  Future<void> deleteTarefaRecurrence(String taskId, {String? userId});

  Stream<List<Tarefa>> getTarefas({String? userId});
}
