import 'dart:io';

import 'package:android_intent_plus/android_intent.dart';
import 'package:android_intent_plus/flag.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:dose_certa/Views/Mobile/Cuidadores/Inner%20Pages/tarefas_page.dart';
import 'package:dose_certa/Views/Mobile/Welcome/welcome_page.dart';
import 'package:dose_certa/Views/Mobile/app_navigation_handler.dart';
import 'package:dose_certa/Views/Mobile/Clinica/clinica_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

import 'package:dose_certa/Models/Models/consulta.dart';
import 'package:dose_certa/Models/Models/medicamento.dart';
import 'package:dose_certa/viewmodels/mobile/user_preferences_viewmodel.dart';
import 'package:dose_certa/Views/Mobile/Consultas/add_consulta_page.dart';
import 'package:dose_certa/Views/Mobile/Consultas/edit_consulta_page.dart';
import 'package:dose_certa/Views/Mobile/Criar%20Conta/account_type_page.dart';
import 'package:dose_certa/Views/Mobile/Criar%20Conta/create_account_page.dart';
import 'package:dose_certa/Views/Mobile/Cuidadores/Inner%20Pages/consulta_page_cuidador.dart';
import 'package:dose_certa/Views/Mobile/Cuidadores/Inner%20Pages/medicamentos_page_cuidador.dart';
import 'package:dose_certa/Views/Mobile/Cuidadores/cuidador_page.dart';
import 'package:dose_certa/Views/Mobile/Medicamentos/add_medicamento_page.dart';
import 'package:dose_certa/Views/Mobile/Medicamentos/edit_medicamento_page.dart';
import 'package:dose_certa/Views/Mobile/Notificacoes/notificacoes_page.dart';
import 'package:dose_certa/Views/Mobile/Relatorio/relatorio_page.dart';
import 'package:dose_certa/Views/Mobile/User/user_edit_page.dart';
import 'package:dose_certa/Views/Mobile/Login/login_page.dart';
import 'package:dose_certa/Views/Mobile/Static/ajuda_page.dart';
import 'package:dose_certa/Views/Mobile/Static/privacidade_page.dart';
import 'package:dose_certa/Views/Mobile/Static/seguranca_page.dart';
import 'package:dose_certa/Views/Mobile/Static/termos_page.dart';
import 'package:dose_certa/_Core/theme/app_colors.dart';

/// Chave global usada para navegação a partir de contextos que não possuem
/// um `BuildContext` direto (útil para navegação após eventos globais).
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class DoseCerta extends StatefulWidget {
  /// Widget raiz da aplicação.
  ///
  /// Responsável por determinar a rota inicial (Welcome, Login ou rota principal)
  /// e por configurar permissões necessárias ao iniciar o app.
  const DoseCerta({super.key});

  @override
  State<DoseCerta> createState() => _DoseCertaState();
}

class _DoseCertaState extends State<DoseCerta> {
  // Controlador de preferências do usuário (persistência local de flags)
  final UserPreferencesViewModel _userPreferences = UserPreferencesViewModel();

  // Future que resolve para a rota inicial (utilizada pelo FutureBuilder)
  late final Future<String> _initialRouteFuture;

  @override
  void initState() {
    super.initState();

    // Solicita permissão de notificações ao iniciar (não bloqueante)
    _requestNotificationPermission();

    // Prepara a rota inicial assincronamente
    _initialRouteFuture = _loadInitialRoute();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: _initialRouteFuture,
      builder: (context, snapshot) {
        // Enquanto a rota inicial não estiver resolvida, exibe indicador
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        // Constrói o MaterialApp em um método separado para manter build enxuto
        return _buildMaterialApp(snapshot.data!);
      },
    );
  }

  /// Constrói o `MaterialApp` com todas as rotas e a rota inicial já
  /// determinada.
  MaterialApp _buildMaterialApp(String initialRoute) {
    return MaterialApp(
      title: 'Dosecerta',
      navigatorKey: navigatorKey,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: AppColors.bluePrimary),
      ),
      debugShowCheckedModeBanner: false,
      initialRoute: initialRoute,
      routes: {
        'Welcome': (context) => WelcomePage(),
        'Login': (context) => LoginPage(),
        '/': (context) => NavigationMain(),
        '/addConsulta': (context) => AddConsultaPage(),
        '/addMedicamento': (context) => AddMedicamentoPage(),
        '/notificacoes': (context) => NotificacoesPage(),
        '/relatorio': (context) => RelatorioPage(),
        '/cuidadores': (context) => CuidadorPage(
          tarefasPage: TarefasPage(),
          medicamentosPage: MedicamentosCuidador(),
          consultasPage: ConsultasCuidador(),
        ),
        '/clinica': (context) => ClinicaPage(),
        '/perfil': (context) => UserEditPage(),
        '/seguranca': (context) => SegurancaPage(),
        '/privacidade': (context) => PrivacidadePage(),
        '/ajuda': (context) => AjudaPage(),
        '/termos': (context) => const TermosPage(),
      },
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case 'AccountType':
            final args = settings.arguments as Map<String, dynamic>?;
            final UserCredential? userCredential = args != null
                ? args['userCredential'] as UserCredential?
                : null;
            return MaterialPageRoute(
              builder: (context) => AccountTypePage(user: userCredential),
            );

          case '/editConsulta':
            final consulta = settings.arguments as Consulta;
            return MaterialPageRoute(
              builder: (context) => EditConsultaPage(consulta: consulta),
            );

          case '/editMedicamento':
            final medicamento = settings.arguments as Medicamento;
            return MaterialPageRoute(
              builder: (context) =>
                  EditMedicamentoPage(medicamento: medicamento),
            );

          case 'AddAccount':
            final args = settings.arguments as Map<String, dynamic>?;
            final UserCredential? userCredential = args != null
                ? args['userCredential'] as UserCredential?
                : null;
            final String accountType =
                args != null && args['accountType'] != null
                ? args['accountType'] as String
                : '';
            return MaterialPageRoute(
              builder: (context) => CreateAccountPage(
                accountType: accountType,
                user: userCredential,
              ),
            );

          default:
            return null;
        }
      },
    );
  }

  /// Determina a rota inicial da aplicação com base nas preferências locais e
  /// no estado de autenticação do Firebase.
  Future<String> _loadInitialRoute() async {
    await _userPreferences.init();

    final isFirstAccess = _userPreferences.isFirstAccess();
    final firebaseUser = FirebaseAuth.instance.currentUser;

    if (isFirstAccess) {
      _requestExactAlarmPermission();
      return 'Welcome';
    } else if (firebaseUser == null) {
      return 'Login';
    } else {
      return '/';
    }
  }

  /// Solicita permissão de notificações (se ainda não concedida).
  Future<void> _requestNotificationPermission() async {
    final status = await Permission.notification.status;
    if (!status.isGranted) {
      await Permission.notification.request();
    }
  }

  /// Em dispositivos Android Android 12+ (SDK >= 31) solicita permissão para
  /// agendamento exato de alarmes, abrindo a tela de configurações nativa.
  Future<void> _requestExactAlarmPermission() async {
    if (!Platform.isAndroid) return;

    final deviceInfo = DeviceInfoPlugin();
    final androidInfo = await deviceInfo.androidInfo;
    if (androidInfo.version.sdkInt >= 31) {
      const intent = AndroidIntent(
        action: 'android.settings.REQUEST_SCHEDULE_EXACT_ALARM',
        flags: <int>[Flag.FLAG_ACTIVITY_NEW_TASK],
      );
      await intent.launch();
    }
  }
}
