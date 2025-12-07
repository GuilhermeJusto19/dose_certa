// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

class Paciente {
  final String id;
  final String name;
  final String sobrenome;

  Paciente({required this.id, required this.name, required this.sobrenome});

  Paciente copyWith({String? id, String? name, String? sobrenome}) {
    return Paciente(
      id: id ?? this.id,
      name: name ?? this.name,
      sobrenome: sobrenome ?? this.sobrenome,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{'id': id, 'name': name, 'sobrenome': sobrenome};
  }

  factory Paciente.fromMap(Map<String, dynamic> map) {
    return Paciente(
      id: map['id'] as String,
      name: map['name'] as String,
      sobrenome: map['sobrenome'] as String,
    );
  }

  String toJson() => json.encode(toMap());

  factory Paciente.fromJson(String source) =>
      Paciente.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() => 'Paciente(id: $id, name: $name, sobrenome: $sobrenome)';

  @override
  bool operator ==(covariant Paciente other) {
    if (identical(this, other)) return true;

    return other.id == id && other.name == name && other.sobrenome == sobrenome;
  }

  @override
  int get hashCode => id.hashCode ^ name.hashCode ^ sobrenome.hashCode;
}
