// Modelo de dados para uma consulta médica.
import 'dart:convert';

/// Representa uma consulta agendada.
///
/// Campos:
/// - `id`: identificador da consulta (geralmente o id do documento no banco).
/// - `name`: título ou nome da consulta.
/// - `doctor`: nome do médico (opcional).
/// - `description`: descrição adicional (opcional).
/// - `dateTime`: data e hora da consulta.
/// - `isClinica`: flag opcional indicando se a consulta é em clínica (padrão false).
class Consulta {
  /// Identificador da consulta.
  String id;

  /// Nome/título da consulta.
  String name;

  /// Nome do médico (opcional).
  String? doctor;

  /// Descrição opcional da consulta.
  String? description;

  /// Data e hora completos da consulta.
  DateTime dateTime;

  /// Indica se a consulta ocorrerá em uma clínica.
  bool? isClinica;

  /// Cria uma instância de [Consulta].
  Consulta({
    required this.id,
    required this.name,
    this.doctor,
    this.description,
    required this.dateTime,
    this.isClinica = false,
  });

  /// Retorna uma cópia da consulta com campos sobrescritos.
  Consulta copyWith({
    String? id,
    String? name,
    String? doctor,
    String? description,
    DateTime? dateTime,
    bool? isClinica,
  }) {
    return Consulta(
      id: id ?? this.id,
      name: name ?? this.name,
      doctor: doctor ?? this.doctor,
      description: description ?? this.description,
      dateTime: dateTime ?? this.dateTime,
      isClinica: isClinica ?? this.isClinica,
    );
  }

  /// Converte esta instância para um mapa para persistência (ex.: Firestore).
  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'name': name,
      'doctor': doctor,
      'description': description,
      // Armazenamos a data como milissegundos desde epoch para interoperabilidade.
      'dateTime': dateTime.millisecondsSinceEpoch,
      'isClinica': isClinica,
    };
  }

  /// Cria uma instância de [Consulta] a partir de um [Map].
  ///
  /// Observação: o campo `dateTime` é esperado em milissegundos (int).
  factory Consulta.fromMap(Map<String, dynamic> map) {
    return Consulta(
      id: map['id'] as String,
      name: map['name'] as String,
      doctor: map['doctor'] != null ? map['doctor'] as String : null,
      description: map['description'] != null
          ? map['description'] as String
          : null,
      dateTime: DateTime.fromMillisecondsSinceEpoch(map['dateTime'] as int),
      // Mantemos o comportamento original: permite que isClinica seja nulo.
      isClinica: map['isClinica'] != null ? map['isClinica'] as bool : null,
    );
  }

  /// Serializa para JSON.
  String toJson() => json.encode(toMap());

  /// Desserializa uma JSON string para [Consulta].
  factory Consulta.fromJson(String source) =>
      Consulta.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'Consulta(id: $id, name: $name, doctor: $doctor, description: $description, dateTime: $dateTime, isClinica: $isClinica)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other.runtimeType != runtimeType) return false;
    final Consulta otherConsulta = other as Consulta;
    return otherConsulta.id == id &&
        otherConsulta.name == name &&
        otherConsulta.doctor == doctor &&
        otherConsulta.description == description &&
        otherConsulta.dateTime == dateTime &&
        otherConsulta.isClinica == isClinica;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        name.hashCode ^
        (doctor?.hashCode ?? 0) ^
        (description?.hashCode ?? 0) ^
        dateTime.hashCode ^
        (isClinica?.hashCode ?? 0);
  }

  /*
  Como usar para selecionar data e hora em UI:

  1. Pegar data com showDatePicker:
     final selectedDate = await showDatePicker(
       context: context,
       initialDate: DateTime.now(),
       firstDate: DateTime(2000),
       lastDate: DateTime(2100),
     );

  2. Pegar hora com showTimePicker:
     final selectedTime = await showTimePicker(
       context: context,
       initialTime: TimeOfDay.now(),
     );

  3. Combinar em DateTime:
     final fullDateTime = DateTime(
       selectedDate!.year,
       selectedDate.month,
       selectedDate.day,
       selectedTime!.hour,
       selectedTime.minute,
     );
  */
}
