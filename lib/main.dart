import 'package:dose_certa/Views/Web/web_app.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:workmanager/workmanager.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';

import 'package:dose_certa/Models/DataSource/lembrete_box_handler.dart';
import 'package:dose_certa/Models/Models/lembrete.dart';
import 'package:dose_certa/Models/services/app_connectivity_service.dart';
import 'package:dose_certa/Models/services/background_tasks_service.dart';
import 'package:dose_certa/Models/services/notifications_service.dart';
import 'package:dose_certa/Views/Mobile/app.dart';

import 'firebase_options.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

/// Ponto de entrada da aplicação.
///
/// Executa a sequência de inicializações necessárias:
/// - Mobile: Firebase, conectividade, Firestore persistence, Hive, WorkManager, notificações e .env
/// - Web: Apenas Firebase (Auth e Firestore)
///
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Checa se está rodando na web
  final isMobile = !kIsWeb;

  if (isMobile) {
    // Mobile: inicialização completa
    await _initializeFirebase();
    await _initializeHive();
    _setupWorkManager();
    await _initializeNotifications();
    await _loadEnv();

    debugPrint("Running on Mobile");
  } else {
    // Web: apenas Firebase (Auth e Firestore)
    await _initializeFirebaseWeb();

    debugPrint("Running on Web");
  }

  // Inicializa a UI da aplicação de acordo com a plataforma
  runApp(isMobile ? DoseCerta() : DoseCertaWeb());
}

/// Inicializa o Firebase para plataformas mobile.
///
/// Configura Firebase com conectividade e persistência local do Firestore.
Future<void> _initializeFirebase() async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Dispara verificação inicial de conectividade (singleton AppConnectivity)
  AppConnectivity().checkConnectivity();

  // Habilita cache local do Firestore (persistência)
  FirebaseFirestore.instance.settings = const Settings(
    persistenceEnabled: true,
  );
}

/// Inicializa o Firebase para a plataforma web.
///
/// Apenas inicializa Firebase Auth e Firestore sem configurações específicas de mobile.
Future<void> _initializeFirebaseWeb() async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Web não precisa de configurações adicionais
  // Firebase Auth e Firestore funcionam automaticamente
}

/// Inicializa o Hive e prepara a box de lembretes.
Future<void> _initializeHive() async {
  await Hive.initFlutter();
  Hive.registerAdapter(LembreteAdapter());
  await LembreteBoxHandler().init();
}

/// Configura o WorkManager para execução periódica de tarefas em background.
///
/// Mantém a mesma periodicidade e o mesmo identificador do código original.
void _setupWorkManager() {
  Workmanager().initialize(callbackDispatcher);

  // Agenda tarefa periódica diária para renovar lembretes
  Workmanager().registerPeriodicTask(
    'daily_worker_unique',
    BackgroundTasks.dailyWorker,
    frequency: const Duration(hours: 24),
    initialDelay: const Duration(minutes: 1),
  );
}

/// Inicializa o plugin de notificações locais.
Future<void> _initializeNotifications() async {
  final notificationsService = NotificationsService();
  await notificationsService.initialize();
}

/// Carrega variáveis de ambiente a partir do arquivo `.env`.
Future<void> _loadEnv() async {
  try {
    await dotenv.load(fileName: ".env");
  } catch (e) {
    debugPrint("Erro ao carregar o arquivo .env: $e");
  }
}

@pragma('vm:entry-point')
void callbackDispatcher() async {
  Workmanager().executeTask((task, inputData) async {
    final success = await BackgroundTasks.execute(task);
    return Future.value(success);
  });
}
