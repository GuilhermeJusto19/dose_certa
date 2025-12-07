import 'package:dose_certa/Models/Models/paciente.dart';

abstract class PacienteRepository {
  Future<void> addPaciente(Paciente paciente);

  Future<void> editPaciente(Paciente paciente);

  Future<void> deletePaciente(String id);

  Stream<List<Paciente>> getPacientes({String? userId});
}
