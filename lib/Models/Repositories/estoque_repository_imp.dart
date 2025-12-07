import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dose_certa/Models/Models/estoque.dart';
import 'package:dose_certa/Models/Repositories/estoque_repository.dart';
import 'package:dose_certa/viewmodels/mobile/user_viewmodel.dart';

/// Implementação do repositório de estoque usando Cloud Firestore.
///
/// Observações (PT-BR):
/// - Esta classe fornece operações CRUD para documentos de estoque
///   armazenados em `usuarios/{uid}/medicamentos/{medicamentoId}/estoque`.
/// - O atributo `medicamento` do estoque armazena o ID do medicamento.
class EstoqueRepositoryImp implements EstoqueRepository {
  EstoqueRepositoryImp({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;
  final UserViewModel _userController = UserViewModel();

  // Nomes das coleções usados no Firestore
  final String _collectionUser = 'usuarios';
  final String _collectionMedicamento = 'medicamentos';
  final String _collectionEstoque = 'estoque';

  /// Adiciona um novo item ao estoque do medicamento especificado.
  @override
  Future<void> addEstoque(Estoque estoque, {String? userId}) async {
    final String uid = userId ?? _userController.currentUser!.id;
    await _firestore
        .collection(_collectionUser)
        .doc(uid)
        .collection(_collectionMedicamento)
        .doc(estoque.medicamento)
        .collection(_collectionEstoque)
        .doc(estoque.id)
        .set(estoque.toMap())
        .timeout(const Duration(seconds: 1));
  }

  /// Atualiza um item existente no estoque do medicamento.
  @override
  Future<void> editEstoque(Estoque estoque, {String? userId}) async {
    final String uid = userId ?? _userController.currentUser!.id;
    await _firestore
        .collection(_collectionUser)
        .doc(uid)
        .collection(_collectionMedicamento)
        .doc(estoque.medicamento)
        .collection(_collectionEstoque)
        .doc(estoque.id)
        .update(estoque.toMap())
        .timeout(const Duration(seconds: 1));
  }

  /// Remove um item do estoque do medicamento especificado.
  /// Requer o ID do medicamento para localizar o estoque correto.
  @override
  Future<void> deleteEstoque(String id, {String? userId}) async {
    final String uid = userId ?? _userController.currentUser!.id;

    // Busca o estoque em todos os medicamentos para encontrar e deletar
    final QuerySnapshot medicamentos = await _firestore
        .collection(_collectionUser)
        .doc(uid)
        .collection(_collectionMedicamento)
        .get();

    for (final medicamentoDoc in medicamentos.docs) {
      final docRef = _firestore
          .collection(_collectionUser)
          .doc(uid)
          .collection(_collectionMedicamento)
          .doc(medicamentoDoc.id)
          .collection(_collectionEstoque)
          .doc(id);

      final doc = await docRef.get();
      if (doc.exists) {
        await docRef.delete();
        break;
      }
    }
  }

  /// Retorna um stream com todos os itens do estoque de todos os medicamentos do usuário.
  ///
  /// O parâmetro `userId` permite operações no contexto de cuidador (quando
  /// passado, busca o estoque do usuário especificado), caso contrário usa
  /// o usuário atual do `UserController`.
  @override
  Stream<List<Estoque>> getEstoque({String? userId}) {
    final String uid = userId ?? _userController.currentUser!.id;

    return _firestore
        .collection(_collectionUser)
        .doc(uid)
        .collection(_collectionMedicamento)
        .snapshots()
        .asyncMap((medicamentosSnapshot) async {
          final List<Estoque> todosEstoques = [];

          for (final medicamentoDoc in medicamentosSnapshot.docs) {
            final estoqueSnapshot = await _firestore
                .collection(_collectionUser)
                .doc(uid)
                .collection(_collectionMedicamento)
                .doc(medicamentoDoc.id)
                .collection(_collectionEstoque)
                .get();

            final estoques = estoqueSnapshot.docs
                .map((doc) => Estoque.fromMap(doc.data()))
                .toList();

            todosEstoques.addAll(estoques);
          }

          return todosEstoques;
        });
  }
}
