// Modelo de domínio para uma tarefa (registro de execução/lembrança).
import 'dart:convert';

/// Representa uma tarefa associada a um recurso (medicamento, consulta, etc.).
class Tarefa {
  /// Identificador local/externo da tarefa.
  final String id;

  /// Identificador da entidade associada (por exemplo id do medicamento).
  final String taskId;

  /// Tipo da tarefa (ex.: 'medicamento', 'consulta', ...).
  final String taskType;

  /// Nome descritivo da tarefa.
  final String taskName;

  /// Comentário opcional inserido pelo usuário.
  final String? comment;

  /// Quantidade de medicamento (quando aplicável).
  final int? qtdMedicamento;

  /// Unidade do medicamento (quando aplicável).
  final String? unitMedicamento;

  /// Médico associado na consulta (quando aplicável).
  final String? doctorConsulta;

  /// Data e hora de execução/ocorrência da tarefa.
  final DateTime executionTime;

  /// Estado da tarefa (ex.: 'realizada', 'pendente').
  final String state;

  Tarefa({
    required this.id,
    required this.taskId,
    required this.taskType,
    required this.taskName,
    this.comment,
    this.qtdMedicamento,
    this.unitMedicamento,
    this.doctorConsulta,
    required this.executionTime,
    required this.state,
  });

  /// Retorna uma cópia da tarefa com campos substituídos.
  Tarefa copyWith({
    String? id,
    String? taskId,
    String? taskType,
    String? taskName,
    int? qtdMedicamento,
    String? unitMedicamento,
    String? doctorConsulta,
    String? comment,
    DateTime? executionTime,
    String? state,
  }) {
    return Tarefa(
      id: id ?? this.id,
      taskId: taskId ?? this.taskId,
      taskType: taskType ?? this.taskType,
      taskName: taskName ?? this.taskName,
      comment: comment ?? this.comment,
      qtdMedicamento: qtdMedicamento ?? this.qtdMedicamento,
      unitMedicamento: unitMedicamento ?? this.unitMedicamento,
      doctorConsulta: doctorConsulta ?? this.doctorConsulta,
      executionTime: executionTime ?? this.executionTime,
      state: state ?? this.state,
    );
  }

  /// Serializa para mapa (útil para Firestore e JSON).
  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'taskId': taskId,
      'taskType': taskType,
      'taskName': taskName,
      'comment': comment,
      'qtdMedicamento': qtdMedicamento,
      'unitMedicamento': unitMedicamento,
      'doctorConsulta': doctorConsulta,
      'executionTime': executionTime.millisecondsSinceEpoch,
      'state': state,
    };
  }

  /// Cria uma instância a partir de um mapa.
  factory Tarefa.fromMap(Map<String, dynamic> map) {
    return Tarefa(
      id: map['id'] as String,
      taskId: map['taskId'] as String,
      taskType: map['taskType'] as String,
      taskName: map['taskName'] as String,
      qtdMedicamento: map['qtdMedicamento'] != null
          ? map['qtdMedicamento'] as int
          : null,
      unitMedicamento: map['unitMedicamento'] != null
          ? map['unitMedicamento'] as String
          : null,
      doctorConsulta: map['doctorConsulta'] != null
          ? map['doctorConsulta'] as String
          : null,
      comment: map['comment'] != null ? map['comment'] as String : null,
      executionTime: DateTime.fromMillisecondsSinceEpoch(
        map['executionTime'] as int,
      ),
      state: map['state'] as String,
    );
  }

  String toJson() => json.encode(toMap());

  factory Tarefa.fromJson(String source) =>
      Tarefa.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'Tarefa(id: $id, taskId: $taskId, taskType: $taskType, taskName: $taskName, comment: $comment, qtdMedicamento: $qtdMedicamento, unitMedicamento: $unitMedicamento, doctorConsulta: $doctorConsulta, executionTime: $executionTime, state: $state)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other.runtimeType != runtimeType) return false;
    final Tarefa otherT = other as Tarefa;
    return otherT.id == id &&
        otherT.taskId == taskId &&
        otherT.taskType == taskType &&
        otherT.taskName == taskName &&
        otherT.qtdMedicamento == qtdMedicamento &&
        otherT.unitMedicamento == unitMedicamento &&
        otherT.doctorConsulta == doctorConsulta &&
        otherT.comment == comment &&
        otherT.executionTime == executionTime &&
        otherT.state == state;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        taskId.hashCode ^
        taskType.hashCode ^
        taskName.hashCode ^
        (qtdMedicamento?.hashCode ?? 0) ^
        (unitMedicamento?.hashCode ?? 0) ^
        (doctorConsulta?.hashCode ?? 0) ^
        (comment?.hashCode ?? 0) ^
        executionTime.hashCode ^
        state.hashCode;
  }
}
