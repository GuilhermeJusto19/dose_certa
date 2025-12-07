import 'package:dose_certa/Models/Models/consulta.dart';

abstract class ConsultaRepository {
  Future<void> addConsulta(Consulta consulta, {String? userId});

  Future<void> editConsulta(Consulta consulta, {String? userId});

  Future<void> deleteConsulta(String id, {String? userId});

  Stream<List<Consulta>> getConsultas({String? userId});
}
