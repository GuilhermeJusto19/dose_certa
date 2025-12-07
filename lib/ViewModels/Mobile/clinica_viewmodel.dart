import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dose_certa/Models/Models/clinica.dart';
import 'package:dose_certa/Models/Models/paciente.dart';
import 'package:dose_certa/Models/Models/usuario.dart';
import 'package:dose_certa/Models/Repositories/paciente_repository_imp.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:dose_certa/Models/services/clinica_auth_service.dart';

/// Controller singleton responsável por operações de autenticação e gestão da
/// clínica logada.
///
/// Documentação (PT-BR):
/// - Carrega e mantém uma instância de `Clinica?` em `currentClinica`.
/// - Fornece métodos para login, cadastro, atualização e remoção de conta.
class ClinicaViewModel {
  ClinicaViewModel._internal();

  static final ClinicaViewModel _instance = ClinicaViewModel._internal();
  factory ClinicaViewModel() => _instance;

  Clinica? currentClinica;

  Future<UserCredential?> signInWithEmail(String email, String password) async {
    try {
      final UserCredential? credential =
          await ClinicaAuthService.loginUserWithEmailAndPassword(
            email,
            password,
          );
      if (credential?.user != null) {
        await loadClinica(credential!.user!.uid);
        return credential;
      }
      return null;
    } catch (e) {
      rethrow;
    }
  }

  Future<UserCredential?> registerWithEmail(
    Clinica clinica,
    String password,
  ) async {
    try {
      final credential =
          await ClinicaAuthService.registerUserWithEmailAndPassword(
            clinica,
            password,
          );

      if (credential?.user != null) {
        await loadClinica(credential!.user!.uid);
        return credential;
      }

      return null;
    } on FirebaseAuthException catch (e) {
      throw Exception(e.message ?? "Erro no Firebase Auth.");
    } catch (e) {
      throw Exception("Erro ao registrar: ${e.toString()}");
    }
  }

  Future<void> loadClinica(String uid) async {
    try {
      final DocumentSnapshot<Map<String, dynamic>> doc = await FirebaseFirestore
          .instance
          .collection('clinicas')
          .doc(uid)
          .get();
      if (doc.exists && doc.data() != null) {
        currentClinica = Clinica.fromMap(doc.data()!);
      } else {
        currentClinica = null;
      }
    } catch (e) {
      currentClinica = null;
    }
  }

  Future<void> updateClinica(Clinica clinica) async {
    try {
      await FirebaseFirestore.instance
          .collection('clinicas')
          .doc(clinica.id)
          .update(clinica.toMap());
      currentClinica = clinica;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> resetPassword(String email) async {
    try {
      await ClinicaAuthService.resetPassword(email);
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
      if (currentClinica == null) return;

      await ClinicaAuthService.deleteAccount();

      currentClinica = null;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> logout() async {
    await ClinicaAuthService.signOutUser();
    currentClinica = null;
  }

  Future<void> associateUsuario(String usuarioId) async {
    try {
      if (currentClinica == null) {
        throw Exception('Nenhuma clínica logada.');
      }

      final DocumentSnapshot<Map<String, dynamic>> usuarioDoc =
          await FirebaseFirestore.instance
              .collection('usuarios')
              .doc(usuarioId)
              .get();

      if (!usuarioDoc.exists || usuarioDoc.data() == null) {
        throw Exception('Usuário com ID $usuarioId não encontrado.');
      }

      final Usuario usuario = Usuario.fromMap(usuarioDoc.data()!);

      if (usuario.hasClinica) {
        throw Exception(
          'Este usuário já está associado à clínica ${usuario.associetedClinicaName ?? ""}.',
        );
      }

      final Paciente novoPaciente = Paciente(
        id: usuario.id,
        name: usuario.name,
        sobrenome: usuario.sobrenome,
      );

      final PacienteRepositoryImp pacienteRepository = PacienteRepositoryImp();
      await pacienteRepository.addPaciente(novoPaciente);

      await FirebaseFirestore.instance
          .collection('usuarios')
          .doc(usuarioId)
          .update({
            'hasClinica': true,
            'associetedClinica': currentClinica!.id,
            'associetedClinicaName': currentClinica!.name,
          });
    } catch (e) {
      rethrow;
    }
  }

  Future<void> desassociateUsuario(String usuarioId) async {
    try {
      if (currentClinica == null) {
        throw Exception('Nenhuma clínica logada.');
      }

      final DocumentSnapshot<Map<String, dynamic>> usuarioDoc =
          await FirebaseFirestore.instance
              .collection('usuarios')
              .doc(usuarioId)
              .get();

      if (!usuarioDoc.exists || usuarioDoc.data() == null) {
        throw Exception('Usuário com ID $usuarioId não encontrado.');
      }

      final Usuario usuario = Usuario.fromMap(usuarioDoc.data()!);

      if (!usuario.hasClinica ||
          usuario.associetedClinica != currentClinica!.id) {
        throw Exception('Este usuário não está associado a esta clínica.');
      }

      final PacienteRepositoryImp pacienteRepository = PacienteRepositoryImp();
      await pacienteRepository.deletePaciente(usuarioId);

      await FirebaseFirestore.instance
          .collection('usuarios')
          .doc(usuarioId)
          .update({
            'hasClinica': false,
            'associetedClinica': '',
            'associetedClinicaName': '',
          });
    } catch (e) {
      rethrow;
    }
  }
}
