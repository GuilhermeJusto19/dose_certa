import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dose_certa/viewmodels/mobile/user_viewmodel.dart';
import 'package:dose_certa/Models/Models/tarefa.dart';
import 'package:dose_certa/Models/Repositories/tarefa_repository.dart';

/// Implementação do repositório de tarefas usando Cloud Firestore.
///
/// Documentação (PT-BR):
/// - Fornece operações CRUD e um stream para as tarefas do dia atual.
/// - Mantive a lógica original intacta; os nomes das coleções foram preservados
///   para compatibilidade com o banco de dados existente.
class TarefaRepositoryImp extends TarefaRepository {
  TarefaRepositoryImp({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;
  final UserViewModel _userController = UserViewModel();

  // Nomes das coleções usados no Firestore.
  final String _collectionUser = 'usuarios';
  final String _collectionName = 'tarefas';

  /// Adiciona uma nova tarefa para o usuário especificado ou para o usuário
  /// atual quando `userId` for nulo.
  @override
  Future<void> addTarefa(Tarefa tarefa, {String? userId}) async {
    final String uid = userId ?? _userController.currentUser!.id;
    await _firestore
        .collection(_collectionUser)
        .doc(uid)
        .collection(_collectionName)
        .doc(tarefa.id)
        .set(tarefa.toMap())
        .timeout(const Duration(seconds: 1));
  }

  /// Atualiza uma tarefa existente.
  @override
  Future<void> editTarefa(Tarefa tarefa, {String? userId}) async {
    final String uid = userId ?? _userController.currentUser!.id;
    await _firestore
        .collection(_collectionUser)
        .doc(uid)
        .collection(_collectionName)
        .doc(tarefa.id)
        .update(tarefa.toMap())
        .timeout(const Duration(seconds: 1));
  }

  /// Deleta uma tarefa pelo id.
  @override
  Future<void> deleteTarefa(String id, {String? userId}) async {
    final String uid = userId ?? _userController.currentUser!.id;
    await _firestore
        .collection(_collectionUser)
        .doc(uid)
        .collection(_collectionName)
        .doc(id)
        .delete();
  }

  /// Retorna um stream das tarefas do dia atual (entre 00:00 e 23:59).
  ///
  /// O `userId` opcional permite operações no contexto de cuidador.
  @override
  Stream<List<Tarefa>> getTarefas({String? userId}) {
    final DateTime now = DateTime.now();
    final DateTime startOfDay = DateTime(now.year, now.month, now.day);
    final DateTime startOfNextDay = startOfDay.add(const Duration(days: 1));

    final int startMillis = startOfDay.millisecondsSinceEpoch;
    final int nextMillis = startOfNextDay.millisecondsSinceEpoch;

    final String uid = userId ?? _userController.currentUser!.id;

    return _firestore
        .collection(_collectionUser)
        .doc(uid)
        .collection(_collectionName)
        .where('executionTime', isGreaterThanOrEqualTo: startMillis)
        .where('executionTime', isLessThan: nextMillis)
        .orderBy('executionTime', descending: false)
        .snapshots()
        .map((snapshot) {
          final List<Tarefa> tarefas = snapshot.docs
              .map((doc) => Tarefa.fromMap(doc.data()))
              .toList();
          tarefas.sort((a, b) => a.executionTime.compareTo(b.executionTime));
          return tarefas;
        });
  }

  /// Deleta todas as tarefas que pertencem à mesma recorrência (`taskId`).
  ///
  /// Implementação usa batch para eficiência.
  @override
  Future<void> deleteTarefaRecurrence(String taskId, {String? userId}) async {
    final String uid = userId ?? _userController.currentUser!.id;

    final QuerySnapshot querySnapshot = await _firestore
        .collection(_collectionUser)
        .doc(uid)
        .collection(_collectionName)
        .where('taskId', isEqualTo: taskId)
        .get();

    final WriteBatch batch = _firestore.batch();

    for (final QueryDocumentSnapshot doc in querySnapshot.docs) {
      batch.delete(doc.reference);
    }

    await batch.commit();
  }
}
