import 'package:dose_certa/Views/Web/Criar%20Conta/crate_account_page.dart';
import 'package:dose_certa/Views/Web/Home/home_page.dart';
import 'package:dose_certa/Views/Web/Login/login_page.dart';
import 'package:dose_certa/Views/Web/Paciente/manage_paciente_page.dart';
import 'package:dose_certa/Views/Web/Welcome/welcome_page.dart';
import 'package:dose_certa/_Core/theme/app_colors.dart';
import 'package:flutter/material.dart';

/// Chave global usada para navegação a partir de contextos que não possuem
/// um `BuildContext` direto (útil para navegação após eventos globais).
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class DoseCertaWeb extends StatelessWidget {
  /// Widget raiz da aplicação.
  ///
  /// Responsável por determinar a rota inicial (Welcome, Login ou rota principal)
  /// e por configurar permissões necessárias ao iniciar o app.
  const DoseCertaWeb({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Dose Certa - Clínica Web',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: AppColors.bluePrimary),
      ),
      initialRoute: '/welcome',
      routes: {
        '/welcome': (context) => const WelcomePage(),
        '/home': (context) => const HomePage(),
        '/login': (context) => const LoginPage(),
        '/create-account': (context) => const CreateAccountPage(),
        '/paciente': (context) => const ManagePacientePage(),
      },
    );
  }
}
