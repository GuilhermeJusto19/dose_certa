// Modelo de dados para medicamentos.
import 'dart:convert';

import 'package:flutter/foundation.dart';

/// Representa um medicamento e sua programação de administração.
///
/// Campos principais:
/// - `frequency`: descrição da frequência (por exemplo "Diariamente", "A cada 8h").
/// - `intervalHours`: usado quando a frequência é baseada em intervalo de horas.
/// - `weekDays`: lista de dias da semana (1..7) quando aplicável.
class Medicamento {
  /// Identificador do medicamento.
  final String id;

  /// Nome do medicamento.
  final String name;

  /// Descrição textual da frequência.
  final String frequency; // "Diariamente", "A cada 8h", "Dias específicos"

  /// Quantidade por administração.
  final int quantity;

  /// Unidade da dose (ex.: 'mg', 'ml', 'comprimido').
  final String unit;

  /// Intervalo em horas quando aplicável (por exemplo para "a cada X horas").
  final int? intervalHours;

  /// Número de vezes por dia quando aplicável.
  final int? timesPerDay;

  /// Lista de dias da semana aplicáveis (1 = segunda, ... 7 = domingo).
  final List<int>? weekDays;

  /// Data de início do tratamento.
  final DateTime startDate;

  /// Horários (DateTime) em que o medicamento deve ser lembrado.
  final List<DateTime> reminderTimes;

  /// Indica se a administração ocorre em clínica.
  final bool? isClinica;

  /// Observações adicionais.
  final String? notes;

  Medicamento({
    required this.id,
    required this.name,
    required this.frequency,
    required this.quantity,
    required this.unit,
    this.intervalHours,
    this.timesPerDay,
    this.weekDays,
    required this.startDate,
    required this.reminderTimes,
    this.isClinica = false,
    this.notes,
  });

  /// Retorna uma cópia modificada do medicamento.
  Medicamento copyWith({
    String? id,
    String? name,
    String? frequency,
    int? quantity,
    String? unit,
    int? intervalHours,
    int? timesPerDay,
    List<int>? weekDays,
    DateTime? startDate,
    List<DateTime>? reminderTimes,
    bool? isClinica,
    String? notes,
  }) {
    return Medicamento(
      id: id ?? this.id,
      name: name ?? this.name,
      frequency: frequency ?? this.frequency,
      quantity: quantity ?? this.quantity,
      unit: unit ?? this.unit,
      intervalHours: intervalHours ?? this.intervalHours,
      timesPerDay: timesPerDay ?? this.timesPerDay,
      weekDays: weekDays ?? this.weekDays,
      startDate: startDate ?? this.startDate,
      reminderTimes: reminderTimes ?? this.reminderTimes,
      isClinica: isClinica ?? this.isClinica,
      notes: notes ?? this.notes,
    );
  }

  /// Serializa para um mapa (útil para persistência em Firestore).
  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'name': name,
      'frequency': frequency,
      'quantity': quantity,
      'unit': unit,
      'intervalHours': intervalHours,
      'timesPerDay': timesPerDay,
      'weekDays': weekDays,
      'startDate': startDate.millisecondsSinceEpoch,
      'reminderTimes': reminderTimes
          .map((x) => x.millisecondsSinceEpoch)
          .toList(),
      'isClinica': isClinica,
      'notes': notes,
    };
  }

  /// Desserializa um mapa para [Medicamento].
  factory Medicamento.fromMap(Map<String, dynamic> map) {
    return Medicamento(
      id: map['id'] as String,
      name: map['name'] as String,
      frequency: map['frequency'] as String,
      quantity: map['quantity'] as int,
      unit: map['unit'] as String,
      intervalHours: map['intervalHours'] != null
          ? map['intervalHours'] as int
          : null,
      timesPerDay: map['timesPerDay'] != null
          ? map['timesPerDay'] as int
          : null,
      weekDays: map['weekDays'] != null
          ? List<int>.from(map['weekDays'])
          : null,
      startDate: DateTime.fromMillisecondsSinceEpoch(map['startDate'] as int),
      reminderTimes: map['reminderTimes'] != null
          ? (map['reminderTimes'] as List)
                .map((x) => DateTime.fromMillisecondsSinceEpoch(x as int))
                .toList()
          : [],
      isClinica: map['isClinica'] != null ? map['isClinica'] as bool : null,
      notes: map['notes'] != null ? map['notes'] as String : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory Medicamento.fromJson(String source) =>
      Medicamento.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'Medicamento(id: $id, name: $name, frequency: $frequency, quantity: $quantity, unit: $unit, intervalHours: $intervalHours, timesPerDay: $timesPerDay, weekDays: $weekDays, startDate: $startDate, reminderTimes: $reminderTimes, isClinica: $isClinica, notes: $notes)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other.runtimeType != runtimeType) return false;
    final Medicamento otherMed = other as Medicamento;
    return otherMed.id == id &&
        otherMed.name == name &&
        otherMed.frequency == frequency &&
        otherMed.quantity == quantity &&
        otherMed.unit == unit &&
        otherMed.intervalHours == intervalHours &&
        otherMed.timesPerDay == timesPerDay &&
        listEquals(otherMed.weekDays, weekDays) &&
        otherMed.startDate == startDate &&
        listEquals(otherMed.reminderTimes, reminderTimes) &&
        otherMed.isClinica == isClinica &&
        otherMed.notes == notes;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        name.hashCode ^
        frequency.hashCode ^
        quantity.hashCode ^
        unit.hashCode ^
        (intervalHours?.hashCode ?? 0) ^
        (timesPerDay?.hashCode ?? 0) ^
        (weekDays?.hashCode ?? 0) ^
        startDate.hashCode ^
        reminderTimes.hashCode ^
        (isClinica?.hashCode ?? 0) ^
        (notes?.hashCode ?? 0);
  }
}
