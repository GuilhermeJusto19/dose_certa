import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dose_certa/Models/Models/consulta.dart';
import 'package:dose_certa/Models/Repositories/consulta_repository.dart';
import 'package:dose_certa/viewmodels/mobile/user_viewmodel.dart';

/// Implementação do repositório de consultas usando Cloud Firestore.
///
/// Observações (PT-BR):
/// - Esta classe preserva toda a lógica existente: operações CRUD e um stream
///   de consultas futuras (filtradas por `dateTime`).
/// - Mantive as mesmas coleções ('usuarios' / 'consultas') para compatibilidade.
class ConsultaRepositoryImp implements ConsultaRepository {
  ConsultaRepositoryImp({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;
  final UserViewModel _userController = UserViewModel();

  // Nomes das coleções usados no Firestore (mantidos para não alterar o
  // contrato/estrutura do banco de dados).
  final String _collectionUser = 'usuarios';
  final String _collectionName = 'consultas';

  /// Adiciona uma nova consulta para o usuário especificado (ou para o
  /// usuário atual do controller se `userId` for nulo).
  @override
  Future<void> addConsulta(Consulta consulta, {String? userId}) async {
    final String uid = userId ?? _userController.currentUser!.id;
    await _firestore
        .collection(_collectionUser)
        .doc(uid)
        .collection(_collectionName)
        .doc(consulta.id)
        .set(consulta.toMap())
        .timeout(const Duration(seconds: 1));
  }

  /// Atualiza uma consulta existente.
  @override
  Future<void> editConsulta(Consulta consulta, {String? userId}) async {
    final String uid = userId ?? _userController.currentUser!.id;
    await _firestore
        .collection(_collectionUser)
        .doc(uid)
        .collection(_collectionName)
        .doc(consulta.id)
        .update(consulta.toMap())
        .timeout(const Duration(seconds: 1));
  }

  /// Remove uma consulta pelo id.
  @override
  Future<void> deleteConsulta(String id, {String? userId}) async {
    final String uid = userId ?? _userController.currentUser!.id;
    await _firestore
        .collection(_collectionUser)
        .doc(uid)
        .collection(_collectionName)
        .doc(id)
        .delete();
  }

  /// Retorna um stream com as consultas futuras (filtradas por `dateTime`).
  ///
  /// O parâmetro `userId` permite operações no contexto de cuidador (quando
  /// passado, busca as consultas do usuário especificado), caso contrário usa
  /// o usuário atual do `UserController`.
  @override
  Stream<List<Consulta>> getConsultas({String? userId}) {
    final String uid = userId ?? _userController.currentUser!.id;
    return _firestore
        .collection(_collectionUser)
        .doc(uid)
        .collection(_collectionName)
        .where(
          'dateTime',
          isGreaterThanOrEqualTo: DateTime.now().millisecondsSinceEpoch,
        )
        .orderBy('dateTime', descending: false)
        .snapshots()
        .map((snapshot) {
          final List<Consulta> consultas = snapshot.docs
              .map((doc) => Consulta.fromMap(doc.data()))
              .toList();
          // Garantia adicional de ordenação por data (mantida da versão anterior).
          consultas.sort((a, b) => a.dateTime.compareTo(b.dateTime));
          return consultas;
        });
  }
}
