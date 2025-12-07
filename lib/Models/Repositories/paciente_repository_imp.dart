import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dose_certa/viewmodels/mobile/clinica_viewmodel.dart';
import 'package:dose_certa/Models/Models/paciente.dart';
import 'package:dose_certa/Models/Repositories/paciente_repository.dart';

class PacienteRepositoryImp implements PacienteRepository {
  PacienteRepositoryImp({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;
  final ClinicaViewModel _userController = ClinicaViewModel();

  // Nomes das coleções usados no Firestore (mantidos para não alterar o
  // contrato/estrutura do banco de dados).
  final String _collectionUser = 'clinicas';
  final String _collectionName = 'pacientes';

  /// Adiciona um novo paciente para a clínica atual.
  @override
  Future<void> addPaciente(Paciente paciente) async {
    final String uid = _userController.currentClinica!.id;
    await _firestore
        .collection(_collectionUser)
        .doc(uid)
        .collection(_collectionName)
        .doc(paciente.id)
        .set(paciente.toMap())
        .timeout(const Duration(seconds: 1));
  }

  /// Atualiza um paciente existente.
  @override
  Future<void> editPaciente(Paciente paciente) async {
    final String uid = _userController.currentClinica!.id;
    await _firestore
        .collection(_collectionUser)
        .doc(uid)
        .collection(_collectionName)
        .doc(paciente.id)
        .update(paciente.toMap())
        .timeout(const Duration(seconds: 1));
  }

  /// Remove um paciente pelo id.
  @override
  Future<void> deletePaciente(String id) async {
    final String uid = _userController.currentClinica!.id;
    await _firestore
        .collection(_collectionUser)
        .doc(uid)
        .collection(_collectionName)
        .doc(id)
        .delete();
  }

  /// Retorna um stream com os pacientes da clínica.
  ///
  /// O parâmetro `userId` permite buscar pacientes de outra clínica se necessário.
  @override
  Stream<List<Paciente>> getPacientes({String? userId}) {
    final String uid = userId ?? _userController.currentClinica!.id;
    return _firestore
        .collection(_collectionUser)
        .doc(uid)
        .collection(_collectionName)
        .snapshots()
        .map((QuerySnapshot<Map<String, dynamic>> snapshot) {
          return snapshot.docs.map((doc) {
            return Paciente.fromMap(doc.data());
          }).toList();
        });
  }
}
