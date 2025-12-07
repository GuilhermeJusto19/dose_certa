import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

/// Serviço singleton para monitorar conectividade de rede e habilitar/desabilitar
/// o uso de rede do Firestore de acordo com o estado.
///
/// Documentação (PT-BR):
/// - Método `checkConnectivity` inicia a escuta de alterações de conectividade
///   e ativa/desativa a rede do Firestore conforme apropriado.
/// - Chame `dispose()` para cancelar a escuta quando o serviço não for mais
///   necessário (por exemplo ao finalizar a aplicação).
///
/// Observação sobre correção de bug:
/// - A implementação original usava `result.contains(ConnectivityResult.none)`
///   onde `result` é um `ConnectivityResult` — isso parece ser um erro óbvio
///   (tipo incompatível). Para preservar a intenção original, a verificação foi
///   convertida para `result == ConnectivityResult.none`.
class AppConnectivity {
  AppConnectivity._internal();

  static final AppConnectivity _instance = AppConnectivity._internal();
  factory AppConnectivity() => _instance;

  // Em algumas versões/plataformas o stream emite uma lista de resultados
  // (por exemplo: [ConnectivityResult.wifi]) — por isso usamos o tipo List.
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;

  /// Estado atual de conectividade. Pode ser `null` se ainda não verificado.
  bool? isConnected;

  /// Inicia o monitoramento de conectividade e habilita/desabilita a rede do
  /// Firestore conforme eventos vindos do plugin `connectivity_plus`.
  Future<void> checkConnectivity() async {
    _connectivitySubscription = Connectivity().onConnectivityChanged.listen((
      List<ConnectivityResult> result,
    ) {
      // O resultado pode ser uma lista; verificamos se contém o estado "none".
      if (result.contains(ConnectivityResult.none)) {
        FirebaseFirestore.instance.disableNetwork();
        isConnected = false;
        return;
      }

      FirebaseFirestore.instance.enableNetwork();
      isConnected = true;
    });
  }

  /// Cancela o listener de conectividade e libera recursos.
  void dispose() {
    _connectivitySubscription?.cancel();
  }
}
