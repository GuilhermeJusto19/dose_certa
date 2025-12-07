import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dose_certa/Models/Models/clinica.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ClinicaAuthService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Retorna UserCredential em caso de sucesso, ou null com erro capturado internamente
  static Future<UserCredential?> registerUserWithEmailAndPassword(
    Clinica user,
    String password,
  ) async {
    try {
      // Criar usuário no Firebase Auth
      UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(
            email: user.email,
            password: password,
          );

      final User? createdUser = userCredential.user;
      if (createdUser != null) {
        // Salvar no Firestore
        try {
          final userDoc = FirebaseFirestore.instance
              .collection('clinicas')
              .doc(createdUser.uid);

          await userDoc.set({
            'id': createdUser.uid,
            'address': user.address,
            'cnpj': user.cnpj,
            'name': user.name,
            'email': user.email,
            'createdAt': user.createdAt.millisecondsSinceEpoch,
            'phone': user.phone,
          });
        } catch (firestoreError) {
          // Se falhar ao salvar no Firestore, deletar o usuário criado
          await createdUser.delete();
          throw Exception("Erro ao salvar dados da clínica. Tente novamente.");
        }
      }
      return userCredential;
    } catch (e) {
      // Re-lançar como Exception simples para evitar problemas de tipo na web
      throw Exception(_getErrorMessage(e));
    }
  }

  static Future<UserCredential?> loginUserWithEmailAndPassword(
    String email,
    String password,
  ) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential;
    } catch (e) {
      throw Exception(_getErrorMessage(e));
    }
  }

  /// Converte erros do Firebase em mensagens amigáveis
  static String _getErrorMessage(dynamic error) {
    if (error is FirebaseAuthException) {
      switch (error.code) {
        case 'email-already-in-use':
          return 'Este email já está cadastrado.';
        case 'invalid-email':
          return 'Email inválido.';
        case 'weak-password':
          return 'A senha deve ter pelo menos 6 caracteres.';
        case 'invalid-credential':
          return 'Email ou senha incorretos.';
        case 'network-request-failed':
          return 'Falha de conexão. Verifique sua internet e tente novamente.';
        case 'user-not-found':
          return 'Nenhum usuário encontrado para esse email.';
        case 'wrong-password':
          return 'Senha incorreta.';
        default:
          return error.message ?? 'Erro de autenticação.';
      }
    } else if (error is FirebaseException) {
      return 'Erro ao salvar dados: ${error.message ?? "Erro desconhecido"}';
    } else if (error is Exception) {
      return error.toString().replaceFirst('Exception: ', '');
    }
    return 'Erro desconhecido: ${error.toString()}';
  }

  static Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } catch (e) {
      throw Exception(_getErrorMessage(e));
    }
  }

  static Future<void> deleteAccount() async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        await FirebaseFirestore.instance
            .collection('clinicas')
            .doc(user.uid)
            .delete();
        await user.delete();
      } else {
        throw Exception('Nenhum usuário autenticado encontrado.');
      }
    } catch (e) {
      throw Exception(_getErrorMessage(e));
    }
  }

  static signOutUser() async {
    await _auth.signOut();
  }
}
