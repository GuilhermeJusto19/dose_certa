import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Controller responsável por preferências locais do usuário usando
/// `SharedPreferences` e utilitários simples relacionados ao usuário atual.
///
/// Documentação (PT-BR):
/// - `init()` deve ser chamado antes de usar as APIs que acessam `_prefs`.
/// - `isFirstAccess()` retorna `true` quando a chave `firstAccess` não foi
///   persistida ainda, preservando o comportamento anterior.
class UserPreferencesViewModel {
  SharedPreferences? _prefs;

  Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  bool isFirstAccess() {
    return _prefs?.getBool('firstAccess') ?? true;
  }

  Future<void> setFirstAccessFalse() async {
    await _prefs?.setBool('firstAccess', false);
  }

  User? getCurrentUser() {
    return FirebaseAuth.instance.currentUser;
  }
}
