import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dose_certa/Models/Models/medicamento.dart';
import 'package:dose_certa/Models/Repositories/medicamento_repository.dart';
import 'package:dose_certa/viewmodels/mobile/user_viewmodel.dart';

/// Implementação do repositório de medicamentos usando Cloud Firestore.
///
/// Documentação (PT-BR):
/// - Esta classe fornece operações CRUD para documentos de medicamentos
///   armazenados em `usuarios/{uid}/medicamentos`.
/// - O parâmetro opcional `userId` permite operações no contexto de cuidadores.
class MedicamentoRepositoryImp implements MedicamentoRepository {
  MedicamentoRepositoryImp({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;
  final UserViewModel _userController = UserViewModel();

  // Nomes das coleções mantidos para compatibilidade com o banco.
  final String _collectionUser = 'usuarios';
  final String _collectionName = 'medicamentos';

  /// Adiciona um medicamento para o usuário informado ou para o usuário
  /// atualmente logado quando `userId` for nulo.
  @override
  Future<void> addMedicamento(Medicamento medicamento, {String? userId}) async {
    final String uid = userId ?? _userController.currentUser!.id;
    await _firestore
        .collection(_collectionUser)
        .doc(uid)
        .collection(_collectionName)
        .doc(medicamento.id)
        .set(medicamento.toMap())
        .timeout(const Duration(seconds: 1));
  }

  /// Atualiza um medicamento existente.
  @override
  Future<void> editMedicamento(
    Medicamento medicamento, {
    String? userId,
  }) async {
    final String uid = userId ?? _userController.currentUser!.id;
    await _firestore
        .collection(_collectionUser)
        .doc(uid)
        .collection(_collectionName)
        .doc(medicamento.id)
        .update(medicamento.toMap())
        .timeout(const Duration(seconds: 1));
  }

  /// Deleta um medicamento pelo id.
  @override
  Future<void> deleteMedicamento(String id, {String? userId}) async {
    final String uid = userId ?? _userController.currentUser!.id;
    await _firestore
        .collection(_collectionUser)
        .doc(uid)
        .collection(_collectionName)
        .doc(id)
        .delete();
  }

  /// Retorna um [Stream] com todos os medicamentos do usuário, ordenados por
  /// nome (insensível a maiúsculas/minúsculas).
  @override
  Stream<List<Medicamento>> getMedicamentos({String? userId}) {
    final String uid = userId ?? _userController.currentUser!.id;
    return _firestore
        .collection(_collectionUser)
        .doc(uid)
        .collection(_collectionName)
        .orderBy('name', descending: false)
        .snapshots()
        .map((snapshot) {
          final List<Medicamento> medicamentos = snapshot.docs
              .map((doc) => Medicamento.fromMap(doc.data()))
              .toList();
          medicamentos.sort(
            (a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()),
          );
          return medicamentos;
        });
  }
}
