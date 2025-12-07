import 'package:hive_ce/hive.dart';

part 'lembrete.g.dart';

/// Modelo de armazenamento local para lembretes de tarefas.
///
/// Esta classe é serializada pelo Hive. Cada campo está anotado com
/// `@HiveField` com índices estáticos — não altere os índices para manter
/// compatibilidade com a base existente.
@HiveType(typeId: 0)
class Lembrete extends HiveObject {
  /// Identificador interno do lembrete (pode ser o id do documento ou UUID local).
  @HiveField(0)
  final String id;

  /// Identificador da tarefa/entidade associada a este lembrete.
  @HiveField(1)
  final String taskId;

  /// Tipo da tarefa (ex.: 'medicamento', 'consulta', 'tarefa').
  ///
  /// Observação: considerar o uso de `enum` para maior segurança de tipo no
  /// futuro; manter como `String` para compatibilidade com o formato atual.
  @HiveField(2)
  final String taskType;

  /// Data e hora do lembrete.
  @HiveField(3)
  final DateTime dateTime;

  /// Título exibido no lembrete.
  @HiveField(4)
  final String title;

  /// Descrição opcional do lembrete.
  @HiveField(5)
  final String? description;

  /// Construtor.
  ///
  /// Todos os campos obrigatórios devem ser fornecidos. A classe é imutável
  /// (campos final) para segurança quando armazenada localmente.
  Lembrete({
    required this.id,
    required this.taskId,
    required this.taskType,
    required this.dateTime,
    required this.title,
    this.description,
  });

  @override
  String toString() {
    return 'Lembrete(id: $id, taskId: $taskId, taskType: $taskType, dateTime: $dateTime, title: $title, description: $description)';
  }
}
