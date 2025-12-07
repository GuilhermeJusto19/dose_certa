import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dose_certa/Models/Models/usuario.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;

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
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'invalid-credential':
          throw FirebaseAuthException(
            code: e.code,
            message: 'Email ou senha incorretos.',
          );
        case 'network-request-failed':
          throw FirebaseAuthException(
            code: e.code,
            message:
                'Falha de conexão. Verifique sua internet e tente novamente.',
          );
        default:
          rethrow;
      }
    }
  }

  static Future<UserCredential?> registerUserWithEmailAndPassword(
    Usuario user,
    String password,
  ) async {
    try {
      UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(
            email: user.email,
            password: password,
          );
      final User? createdUser = userCredential.user;
      if (createdUser != null) {
        final userDoc = FirebaseFirestore.instance
            .collection('usuarios')
            .doc(createdUser.uid);
        final docSnapshot = await userDoc.get();
        if (!docSnapshot.exists) {
          await userDoc.set({
            'id': createdUser.uid,
            'name': user.name,
            'sobrenome': user.sobrenome,
            'email': user.email,
            'isCuidador': user.isCuidador,
            'associetedId': user.associetedId ?? '',
            'associetedName': user.associetedName ?? '',
            'hasClinica': user.hasClinica,
            'associetedClinica': user.associetedClinica ?? '',
            'associetedClinicaName': user.associetedClinicaName ?? '',
            'photoURL': user.photoURL ?? '',
            'createdAt': user.createdAt.millisecondsSinceEpoch,
            'via': 'email',
          });
        }
      }
      return userCredential;
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'invalid-credential':
          throw FirebaseAuthException(
            code: e.code,
            message: 'Email ou senha incorretos.',
          );
        case 'network-request-failed':
          throw FirebaseAuthException(
            code: e.code,
            message:
                'Falha de conexão. Verifique sua internet e tente novamente.',
          );
        default:
          rethrow;
      }
    }
  }

  static Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw e.code == 'user-not-found'
          ? FirebaseAuthException(
              code: e.code,
              message: 'Nenhum usuário encontrado para esse email.',
            )
          : e;
    }
  }

  static Future<void> deleteAccount() async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        FirebaseFirestore.instance
            .collection('usuarios')
            .doc(user.uid)
            .delete();

        await user.delete();
      } else {
        throw FirebaseAuthException(
          code: 'no-current-user',
          message: 'Nenhum usuário autenticado encontrado.',
        );
      }
    } on FirebaseAuthException {
      rethrow;
    }
  }

  static signOutUser() async {
    await _auth.signOut();
  }
}
