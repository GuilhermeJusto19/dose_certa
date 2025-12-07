// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

class Clinica {
  /// Identificador do usuário.
  String id;

  /// Endereço da clínica.
  String address;

  /// CNPJ da clínica.
  String cnpj;

  /// Nome da clinica.
  String name;

  /// Email utilizado no cadastro/autenticação.
  String email;

  /// Data de criação do usuário.
  DateTime createdAt;

  /// Telefone de contato da clínica.
  String phone;

  Clinica({
    required this.id,
    required this.address,
    required this.cnpj,
    required this.name,
    required this.email,
    required this.createdAt,
    required this.phone,
  });

  Clinica copyWith({
    String? id,
    String? address,
    String? cnpj,
    String? name,
    String? email,
    DateTime? createdAt,
    String? phone,
  }) {
    return Clinica(
      id: id ?? this.id,
      address: address ?? this.address,
      cnpj: cnpj ?? this.cnpj,
      name: name ?? this.name,
      email: email ?? this.email,
      createdAt: createdAt ?? this.createdAt,
      phone: phone ?? this.phone,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'address': address,
      'cnpj': cnpj,
      'name': name,
      'email': email,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'phone': phone,
    };
  }

  factory Clinica.fromMap(Map<String, dynamic> map) {
    return Clinica(
      id: map['id'] as String,
      address: map['address'] as String,
      cnpj: map['cnpj'] as String,
      name: map['name'] as String,
      email: map['email'] as String,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt'] as int),
      phone: map['phone'] as String,
    );
  }

  String toJson() => json.encode(toMap());

  factory Clinica.fromJson(String source) =>
      Clinica.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'Clinica(id: $id, address: $address, cnpj: $cnpj, name: $name, email: $email, createdAt: $createdAt, phone: $phone)';
  }

  @override
  bool operator ==(covariant Clinica other) {
    if (identical(this, other)) return true;

    return other.id == id &&
        other.address == address &&
        other.cnpj == cnpj &&
        other.name == name &&
        other.email == email &&
        other.createdAt == createdAt &&
        other.phone == phone;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        address.hashCode ^
        cnpj.hashCode ^
        name.hashCode ^
        email.hashCode ^
        createdAt.hashCode ^
        phone.hashCode;
  }
}
