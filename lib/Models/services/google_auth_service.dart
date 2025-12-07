import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dose_certa/Models/Models/usuario.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

/// Serviço utilitário para autenticação via Google.
///
/// Documentação (PT-BR):
/// - Esta classe encapsula o fluxo de login com Google, registro de usuário
///   no Firestore, remoção de conta Google e logout.
/// - NÃO alterei a lógica de autenticação; apenas organizei imports,
///   adicionei documentação e melhorei nomes locais para legibilidade.
///
/// Observação de possível bug (preservado):
/// - `initSignIn()` é assíncrono, mas no método `signInWithGoogle()` ele é
///   chamado sem `await`, o que pode causar condição de corrida em alguns
///   cenários. Não corrigi isso automaticamente para evitar alterar o fluxo
///   atual, mas recomendo revisar para aguardar a inicialização quando
///   apropriado.
class GoogleAuthService {
  GoogleAuthService._();

  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final GoogleSignIn _googleSignIn = GoogleSignIn.instance;

  /// Indica se a inicialização já foi executada.
  static bool isInitialize = false;

  /// Inicializa o cliente Google Sign-In para a plataforma atual.
  static Future<void> initSignIn() async {
    if (!isInitialize) {
      String? clientId;
      if (defaultTargetPlatform == TargetPlatform.android) {
        clientId =
            '661495323611-oald3fa8u76avsc92l3g3eutnadtiglj.apps.googleusercontent.com';
      } else if (defaultTargetPlatform == TargetPlatform.iOS) {
        clientId =
            '661495323611-r4a7e8ccroon5qrhqp3ufdcg6od7d67e.apps.googleusercontent.com';
      } else {
        clientId =
            '661495323611-oald3fa8u76avsc92l3g3eutnadtiglj.apps.googleusercontent.com';
      }

      await _googleSignIn.initialize(serverClientId: clientId);
    }

    isInitialize = true;
  }

  /// Realiza o fluxo de login com Google e retorna um mapa com as credenciais
  /// e se o usuário é novo no Firestore.
  static Future<Map<String, dynamic>> signInWithGoogle() async {
    try {
      // Nota: initSignIn() não é awaitado aqui na implementação original.
      initSignIn();

      final GoogleSignInAccount googleUser = await _googleSignIn.authenticate();
      final idToken = googleUser.authentication.idToken;
      final authorizationClient = googleUser.authorizationClient;

      GoogleSignInClientAuthorization? authorization = await authorizationClient
          .authorizationForScopes(['email', 'profile']);

      final accessToken = authorization?.accessToken;

      if (accessToken == null) {
        final nextAuthorization = await authorizationClient
            .authorizationForScopes(['email', 'profile']);
        if (nextAuthorization?.accessToken == null) {
          throw FirebaseAuthException(code: 'error', message: 'error');
        }
        authorization = nextAuthorization;
      }

      final credential = GoogleAuthProvider.credential(
        accessToken: accessToken,
        idToken: idToken,
      );

      final UserCredential userCredential = await FirebaseAuth.instance
          .signInWithCredential(credential);

      final User? user = userCredential.user;

      if (user != null) {
        final userDoc = FirebaseFirestore.instance
            .collection('usuarios')
            .doc(user.uid);
        final docSnapshot = await userDoc.get();
        final isNewUser = !docSnapshot.exists;
        return {'credential': userCredential, 'isNewUser': isNewUser};
      }

      return {'credential': userCredential, 'isNewUser': false};
    } on GoogleSignInException catch (e) {
      if (e.code == GoogleSignInExceptionCode.canceled) {
        throw GoogleSignInException(
          code: e.code,
          description: 'Login cancelado pelo usuário.',
        );
      } else {
        throw GoogleSignInException(
          code: e.code,
          description: 'Erro ao tentar realizar o Login.',
        );
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Registra um usuário no Firestore caso o documento ainda não exista.
  static Future<void> registerUserWithGoogle(Usuario user, String id) async {
    final userDoc = FirebaseFirestore.instance.collection('usuarios').doc(id);
    final docSnapshot = await userDoc.get();
    if (!docSnapshot.exists) {
      await userDoc.set({
        'id': id,
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
        'via': 'google',
      });
    }
  }

  /// Deleta o documento do usuário no Firestore e remove a conta do FirebaseAuth.
  static Future<void> deleteGoogleUser() async {
    try {
      final User? user = _auth.currentUser;
      if (user != null) {
        FirebaseFirestore.instance
            .collection('usuarios')
            .doc(user.uid)
            .delete();

        await user.delete();
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Faz sign-out da conta Google e do FirebaseAuth.
  static Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
      await _auth.signOut();
    } catch (e) {
      rethrow;
    }
  }
}
