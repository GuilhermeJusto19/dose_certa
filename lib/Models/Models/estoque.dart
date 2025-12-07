// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

class Estoque {
  final String id;
  final String medicamento;
  final int quantity;
  final int minimalQuantity;

  Estoque({
    required this.id,
    required this.medicamento,
    required this.quantity,
    required this.minimalQuantity,
  });

  Estoque copyWith({
    String? id,
    String? medicamento,
    int? quantity,
    int? minimalQuantity,
  }) {
    return Estoque(
      id: id ?? this.id,
      medicamento: medicamento ?? this.medicamento,
      quantity: quantity ?? this.quantity,
      minimalQuantity: minimalQuantity ?? this.minimalQuantity,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'medicamento': medicamento,
      'quantity': quantity,
      'minimalQuantity': minimalQuantity,
    };
  }

  factory Estoque.fromMap(Map<String, dynamic> map) {
    return Estoque(
      id: map['id'] as String,
      medicamento: map['medicamento'] as String,
      quantity: map['quantity'] as int,
      minimalQuantity: map['minimalQuantity'] as int,
    );
  }

  String toJson() => json.encode(toMap());

  factory Estoque.fromJson(String source) =>
      Estoque.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'Estoque(id: $id, medicamento: $medicamento, quantity: $quantity, minimalQuantity: $minimalQuantity)';
  }

  @override
  bool operator ==(covariant Estoque other) {
    if (identical(this, other)) return true;

    return other.id == id &&
        other.medicamento == medicamento &&
        other.quantity == quantity &&
        other.minimalQuantity == minimalQuantity;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        medicamento.hashCode ^
        quantity.hashCode ^
        minimalQuantity.hashCode;
  }
}
