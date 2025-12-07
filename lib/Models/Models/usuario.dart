// Modelo de usuário da aplicação.
import 'dart:convert';

/// Representa um usuário do sistema (paciente ou cuidador).
class Usuario {
  /// Identificador do usuário.
  String id;

  /// Primeiro nome.
  String name;

  /// Sobrenome.
  String sobrenome;

  /// Email utilizado no cadastro/autenticação.
  String email;

  /// Se verdadeiro, o usuário é um cuidador que pode administrar outro paciente.
  bool isCuidador;

  /// Identificador associado (quando o usuário é cuidador ou está associado a alguém).
  /// Mantido com grafia original (`associetedId`) para compatibilidade.
  String? associetedId;

  /// Nome associado ao `associetedId` (opcional).
  String? associetedName;

  /// Indica se o usuário possui clínica associada.
  bool hasClinica;

  /// Identificador da clínica associada (opcional).
  String? associetedClinica;

  /// Nome da clínica associada (opcional).
  String? associetedClinicaName;

  /// URL da foto do usuário (opcional).
  String? photoURL;

  /// Via de autenticação (ex.: 'google', 'email', ...).
  String via;

  /// Data de criação do usuário.
  DateTime createdAt;

  Usuario({
    required this.id,
    required this.name,
    required this.sobrenome,
    required this.email,
    required this.isCuidador,
    this.associetedId,
    this.associetedName,
    required this.hasClinica,
    this.associetedClinica,
    this.associetedClinicaName,
    this.photoURL,
    required this.via,
    required this.createdAt,
  });

  /// Retorna uma cópia do usuário com os campos opcionais substituídos.
  Usuario copyWith({
    String? id,
    String? name,
    String? sobrenome,
    String? email,
    bool? isCuidador,
    String? associetedId,
    String? associetedName,
    bool? hasClinica,
    String? associetedClinica,
    String? associetedClinicaName,
    String? photoURL,
    String? via,
    DateTime? createdAt,
  }) {
    return Usuario(
      id: id ?? this.id,
      name: name ?? this.name,
      sobrenome: sobrenome ?? this.sobrenome,
      email: email ?? this.email,
      isCuidador: isCuidador ?? this.isCuidador,
      associetedId: associetedId ?? this.associetedId,
      associetedName: associetedName ?? this.associetedName,
      hasClinica: hasClinica ?? this.hasClinica,
      associetedClinica: associetedClinica ?? this.associetedClinica,
      associetedClinicaName:
          associetedClinicaName ?? this.associetedClinicaName,
      photoURL: photoURL ?? this.photoURL,
      via: via ?? this.via,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  /// Serializa para mapa (útil para Firestore / JSON).
  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'name': name,
      'sobrenome': sobrenome,
      'email': email,
      'isCuidador': isCuidador,
      'associetedId': associetedId,
      'associetedName': associetedName,
      'hasClinica': hasClinica,
      'associetedClinica': associetedClinica,
      'associetedClinicaName': associetedClinicaName,
      'photoURL': photoURL,
      'via': via,
      'createdAt': createdAt.millisecondsSinceEpoch,
    };
  }

  /// Cria uma instância a partir de um mapa.
  factory Usuario.fromMap(Map<String, dynamic> map) {
    return Usuario(
      id: map['id'] as String,
      name: map['name'] as String,
      sobrenome: map['sobrenome'] as String,
      email: map['email'] as String,
      isCuidador: map['isCuidador'] as bool,
      associetedId: map['associetedId'] != null
          ? map['associetedId'] as String
          : null,
      associetedName: map['associetedName'] != null
          ? map['associetedName'] as String
          : null,
      hasClinica: map['hasClinica'] as bool,
      associetedClinica: map['associetedClinica'] != null
          ? map['associetedClinica'] as String
          : null,
      associetedClinicaName: map['associetedClinicaName'] != null
          ? map['associetedClinicaName'] as String
          : null,
      photoURL: map['photoURL'] != null ? map['photoURL'] as String : null,
      via: map['via'] as String,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt'] as int),
    );
  }

  String toJson() => json.encode(toMap());

  factory Usuario.fromJson(String source) =>
      Usuario.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'Usuario(id: $id, name: $name, sobrenome: $sobrenome, email: $email, isCuidador: $isCuidador, associetedId: $associetedId, associetedName: $associetedName, hasClinica: $hasClinica, associetedClinica: $associetedClinica, associetedClinicaName: $associetedClinicaName, photoURL: $photoURL, via: $via, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other.runtimeType != runtimeType) return false;
    final Usuario otherUser = other as Usuario;
    return otherUser.id == id &&
        otherUser.name == name &&
        otherUser.sobrenome == sobrenome &&
        otherUser.email == email &&
        otherUser.isCuidador == isCuidador &&
        otherUser.associetedId == associetedId &&
        otherUser.associetedName == associetedName &&
        otherUser.hasClinica == hasClinica &&
        otherUser.associetedClinica == associetedClinica &&
        otherUser.associetedClinicaName == associetedClinicaName &&
        otherUser.photoURL == photoURL &&
        otherUser.via == via &&
        otherUser.createdAt == createdAt;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        name.hashCode ^
        sobrenome.hashCode ^
        email.hashCode ^
        isCuidador.hashCode ^
        (associetedId?.hashCode ?? 0) ^
        (associetedName?.hashCode ?? 0) ^
        hasClinica.hashCode ^
        (associetedClinica?.hashCode ?? 0) ^
        (associetedClinicaName?.hashCode ?? 0) ^
        (photoURL?.hashCode ?? 0) ^
        via.hashCode ^
        createdAt.hashCode;
  }

  /// Retorna o nome completo (nome + sobrenome).
  String get fullname => '$name $sobrenome';
}
