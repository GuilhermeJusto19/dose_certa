import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:dose_certa/Models/Models/usuario.dart';
import 'package:dose_certa/Models/services/auth_service.dart';
import 'package:dose_certa/Models/services/google_auth_service.dart';

/// Controller singleton responsável por operações de autenticação e gestão do
/// usuário logado.
///
/// Documentação (PT-BR):
/// - Carrega e mantém uma instância de `Usuario?` em `currentUser`.
/// - Fornece métodos para login, cadastro, associação cuidador/paciente,
///   atualização e remoção de conta.
class UserViewModel {
  UserViewModel._internal();

  static final UserViewModel _instance = UserViewModel._internal();
  factory UserViewModel() => _instance;

  Usuario? currentUser;

  Future<UserCredential?> signInWithEmail(String email, String password) async {
    try {
      final UserCredential? credential =
          await AuthService.loginUserWithEmailAndPassword(email, password);
      if (credential?.user != null) {
        await loadUser(credential!.user!.uid);
        return credential;
      }
      return null;
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>?> signInWithGoogle() async {
    try {
      final Map<String, dynamic> result =
          await GoogleAuthService.signInWithGoogle();
      if (result['credential']?.user != null) {
        await loadUser(result['credential']!.user!.uid);
        return result;
      }
      return null;
    } catch (e) {
      rethrow;
    }
  }

  Future<bool?> registerUserWithGoogle(
    Usuario usuario,
    UserCredential credential,
  ) async {
    try {
      await GoogleAuthService.registerUserWithGoogle(
        usuario,
        credential.user!.uid,
      );
      if (credential.user != null) {
        await loadUser(credential.user!.uid);
        return true;
      }
      return false;
    } catch (e) {
      rethrow;
    }
  }

  Future<UserCredential?> registerWithEmail(
    Usuario usuario,
    String password,
  ) async {
    try {
      final UserCredential? credential =
          await AuthService.registerUserWithEmailAndPassword(usuario, password);
      if (credential?.user != null) {
        await loadUser(credential!.user!.uid);
        return credential;
      }
      return null;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> loadUser(String uid) async {
    try {
      final DocumentSnapshot<Map<String, dynamic>> doc = await FirebaseFirestore
          .instance
          .collection('usuarios')
          .doc(uid)
          .get();
      if (doc.exists && doc.data() != null) {
        currentUser = Usuario.fromMap(doc.data()!);
      } else {
        currentUser = null;
      }
    } catch (e) {
      currentUser = null;
    }
  }

  Future<void> becomeCuidador(String pacienteId) async {
    try {
      if (currentUser == null) return;

      if (currentUser!.id == pacienteId) {
        throw 'Você não pode se tornar cuidador de si mesmo.';
      }

      final DocumentSnapshot<Map<String, dynamic>> pacienteDoc =
          await FirebaseFirestore.instance
              .collection('usuarios')
              .doc(pacienteId)
              .get();

      if (!pacienteDoc.exists) {
        throw 'Paciente com ID $pacienteId não encontrado.';
      }

      final String assocName = '${currentUser!.name} ${currentUser!.sobrenome}';

      await FirebaseFirestore.instance
          .collection('usuarios')
          .doc(pacienteId)
          .update({
            'associetedId': currentUser!.id,
            'associetedName': assocName,
          });

      currentUser!.isCuidador = true;
      currentUser!.associetedId = pacienteId;

      final Map<String, dynamic>? pacienteData = pacienteDoc.data();
      final String? pacienteName =
          (pacienteData != null && pacienteData['name'] != null)
          ? '${pacienteData['name']}${pacienteData['sobrenome'] != null ? ' ${pacienteData['sobrenome']}' : ''}'
          : null;
      currentUser!.associetedName = pacienteName;

      await FirebaseFirestore.instance
          .collection('usuarios')
          .doc(currentUser!.id)
          .update({
            'isCuidador': true,
            'associetedId': pacienteId,
            'associetedName': pacienteName ?? '',
          });
    } catch (e) {
      rethrow;
    }
  }

  Future<void> unbindCuidador() async {
    try {
      if (currentUser == null) return;

      final String? caregiverId = currentUser!.associetedId;
      if (caregiverId == null || caregiverId.isEmpty) {
        throw 'Nenhum cuidador associado para desvincular.';
      }

      final DocumentSnapshot<Map<String, dynamic>> caregiverDoc =
          await FirebaseFirestore.instance
              .collection('usuarios')
              .doc(caregiverId)
              .get();

      if (caregiverDoc.exists) {
        await FirebaseFirestore.instance
            .collection('usuarios')
            .doc(caregiverId)
            .update({
              'isCuidador': false,
              'associetedId': '',
              'associetedName': '',
            });
      }

      await FirebaseFirestore.instance
          .collection('usuarios')
          .doc(currentUser!.id)
          .update({'associetedId': '', 'associetedName': ''});

      currentUser!.associetedId = null;
      currentUser!.associetedName = null;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> unbindPaciente() async {
    try {
      if (currentUser == null || !currentUser!.isCuidador) return;

      final String? pacienteId = currentUser!.associetedId;
      if (pacienteId == null || pacienteId.isEmpty) {
        throw 'Nenhum paciente associado para desvincular.';
      }

      final DocumentSnapshot<Map<String, dynamic>> pacienteDoc =
          await FirebaseFirestore.instance
              .collection('usuarios')
              .doc(pacienteId)
              .get();

      if (pacienteDoc.exists) {
        await FirebaseFirestore.instance
            .collection('usuarios')
            .doc(pacienteId)
            .update({'associetedId': '', 'associetedName': ''});
      }

      await FirebaseFirestore.instance
          .collection('usuarios')
          .doc(currentUser!.id)
          .update({'associetedId': '', 'associetedName': ''});

      currentUser!.associetedId = null;
      currentUser!.associetedName = null;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateUser(Usuario usuario) async {
    try {
      await FirebaseFirestore.instance
          .collection('usuarios')
          .doc(usuario.id)
          .update(usuario.toMap());
      currentUser = usuario;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> resetPassword(String email) async {
    try {
      await AuthService.resetPassword(email);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'network-request-failed') {
        throw FirebaseAuthException(
          code: e.code,
          message:
              'Falha de conexão. Verifique sua internet e tente novamente.',
        );
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteAccount() async {
    try {
      if (currentUser == null) return;

      if (currentUser!.via == 'google') {
        await GoogleAuthService.deleteGoogleUser();
      } else {
        await AuthService.deleteAccount();
      }

      currentUser = null;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> logout() async {
    if (currentUser!.via == 'google') {
      await GoogleAuthService.signOut();
    } else {
      await AuthService.signOutUser();
    }
    currentUser = null;
  }
}
