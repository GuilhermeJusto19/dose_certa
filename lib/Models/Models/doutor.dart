// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

class Doutor {
  final String id;
  final String nome;
  final String especialidade;

  Doutor({required this.id, required this.nome, required this.especialidade});

  Doutor copyWith({String? id, String? nome, String? especialidade}) {
    return Doutor(
      id: id ?? this.id,
      nome: nome ?? this.nome,
      especialidade: especialidade ?? this.especialidade,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'nome': nome,
      'especialidade': especialidade,
    };
  }

  factory Doutor.fromMap(Map<String, dynamic> map) {
    return Doutor(
      id: map['id'] as String,
      nome: map['nome'] as String,
      especialidade: map['especialidade'] as String,
    );
  }

  String toJson() => json.encode(toMap());

  factory Doutor.fromJson(String source) =>
      Doutor.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() =>
      'Doutor(id: $id, nome: $nome, especialidade: $especialidade)';

  @override
  bool operator ==(covariant Doutor other) {
    if (identical(this, other)) return true;

    return other.id == id &&
        other.nome == nome &&
        other.especialidade == especialidade;
  }

  @override
  int get hashCode => id.hashCode ^ nome.hashCode ^ especialidade.hashCode;
}
