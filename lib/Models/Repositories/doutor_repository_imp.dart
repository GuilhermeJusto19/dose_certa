import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dose_certa/viewmodels/mobile/clinica_viewmodel.dart';
import 'package:dose_certa/Models/Models/doutor.dart';
import 'package:dose_certa/Models/Repositories/doutor_repository.dart';

class DoutorRepositoryImp implements DoutorRepository {
  DoutorRepositoryImp({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;
  final ClinicaViewModel _userController = ClinicaViewModel();

  // Nomes das coleções usados no Firestore (mantidos para não alterar o
  // contrato/estrutura do banco de dados).
  final String _collectionUser = 'clinicas';
  final String _collectionName = 'doutores';

  /// Adiciona um novo doutor para a clínica atual.
  @override
  Future<void> addDoutor(Doutor consulta) async {
    final String uid = _userController.currentClinica!.id;
    await _firestore
        .collection(_collectionUser)
        .doc(uid)
        .collection(_collectionName)
        .doc(consulta.id)
        .set(consulta.toMap())
        .timeout(const Duration(seconds: 1));
  }

  /// Atualiza um doutor existente.
  @override
  Future<void> editDoutor(Doutor consulta) async {
    final String uid = _userController.currentClinica!.id;
    await _firestore
        .collection(_collectionUser)
        .doc(uid)
        .collection(_collectionName)
        .doc(consulta.id)
        .update(consulta.toMap())
        .timeout(const Duration(seconds: 1));
  }

  /// Remove um doutor pelo id.
  @override
  Future<void> deleteDoutor(String id) async {
    final String uid = _userController.currentClinica!.id;
    await _firestore
        .collection(_collectionUser)
        .doc(uid)
        .collection(_collectionName)
        .doc(id)
        .delete();
  }

  /// Retorna um stream com os doutores da clínica.
  ///
  /// O parâmetro `userId` permite buscar doutores de outra clínica se necessário.
  @override
  Stream<List<Doutor>> getDoutors({String? userId}) {
    final String uid = userId ?? _userController.currentClinica!.id;
    return _firestore
        .collection(_collectionUser)
        .doc(uid)
        .collection(_collectionName)
        .snapshots()
        .map((QuerySnapshot<Map<String, dynamic>> snapshot) {
          return snapshot.docs.map((doc) {
            return Doutor.fromMap(doc.data());
          }).toList();
        });
  }
}
