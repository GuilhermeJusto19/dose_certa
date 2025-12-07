import 'package:dose_certa/Models/Models/medicamento.dart';

abstract class MedicamentoRepository {
  Future<void> addMedicamento(Medicamento medicamento, {String? userId});

  Future<void> editMedicamento(Medicamento medicamento, {String? userId});

  Future<void> deleteMedicamento(String id, {String? userId});

  Stream<List<Medicamento>> getMedicamentos({String? userId});
}
