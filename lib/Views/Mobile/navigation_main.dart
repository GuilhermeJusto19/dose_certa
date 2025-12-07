import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'package:dose_certa/viewmodels/mobile/user_viewmodel.dart';
import 'package:dose_certa/Views/_shared/custom_appbar.dart';
import 'package:dose_certa/Views/_shared/custom_drawer.dart';
import 'package:dose_certa/Views/Mobile/ChatBot/chatbot_page.dart';
import 'package:dose_certa/Views/Mobile/Consultas/consultas_page.dart';
import 'package:dose_certa/Views/Mobile/Lista%20Diaria/home_page.dart';
import 'package:dose_certa/Views/Mobile/Medicamentos/medicamentos_page.dart';
import 'package:dose_certa/_Core/theme/app_colors.dart';

/// Página principal com navegação inferior (BottomNavigation).
///
/// Documentação (PT-BR):
/// - Mantive a lógica original: carrega o usuário atual no `initState`,
///   exibe um indicador de loading até a leitura ser concluída e mostra as
///   telas em um `IndexedStack` para manter estado entre abas.
/// - Melhorei legibilidade e extraí um helper para construir os ícones do
///   `BottomNavigationBar` sem alterar o comportamento visual.

class NavigationMain extends StatefulWidget {
  const NavigationMain({super.key});

  @override
  State<NavigationMain> createState() => _NavigationMainState();
}

class _NavigationMainState extends State<NavigationMain> {
  int _currentIndex = 0;
  final UserViewModel _userController = UserViewModel();
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: AppColors.white,
      drawer: CustomDrawer(
        name: _userController.currentUser?.name ?? 'Usuário',
        photoURL: _userController.currentUser?.photoURL,
        buildContext: context,
        id: _userController.currentUser?.id ?? '',
      ),
      floatingActionButton: _buildFloatingButton(),
      appBar: (_currentIndex == 0)
          ? CustomAppBar(name: _userController.currentUser?.name ?? 'Usuário')
          : null,
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(
            icon: _navIcon('assets/icons/home.png', 0),
            label: "Hoje",
          ),
          BottomNavigationBarItem(
            icon: _navIcon('assets/icons/medicamento.png', 1),
            label: "Medicamentos",
          ),
          BottomNavigationBarItem(
            icon: _navIcon('assets/icons/consulta.png', 2),
            label: "Consulta",
          ),
          BottomNavigationBarItem(
            icon: _navIcon('assets/icons/chatbot.png', 3),
            label: "ChatBot",
          ),
        ],
        currentIndex: _currentIndex,
        selectedItemColor: AppColors.bluePrimary,
        unselectedItemColor: AppColors.gray500,
        onTap: (value) => updateIndex(value),
        //showUnselectedLabels: true,
      ),
      body: IndexedStack(index: _currentIndex, children: _screens),
    );
  }

  void updateIndex(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  Widget? _buildFloatingButton() {
    if (_currentIndex == 1 || _currentIndex == 2) {
      return FloatingActionButton(
        backgroundColor: AppColors.bluePrimary,
        onPressed: () => _showAddPage(),
        child: const Icon(Icons.add, color: AppColors.white),
      );
    }
    return null;
  }

  _showAddPage() {
    if (_currentIndex == 1) {
      return Navigator.pushNamed(context, '/addMedicamento');
    } else if (_currentIndex == 2) {
      return Navigator.pushNamed(context, '/addConsulta');
    }
  }

  Future<void> _loadUser() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await _userController.loadUser(user.uid);
    }
    setState(() {
      _isLoading = false;
    });
  }

  /// Helper para construir o widget de ícone do BottomNavigationBar
  /// aplicando a cor correta dependendo do índice selecionado.
  Widget _navIcon(String assetPath, int index) {
    final color = _currentIndex == index
        ? AppColors.bluePrimary
        : AppColors.gray500;
    return Image.asset(assetPath, scale: 2, color: color);
  }
}

final List<Widget> _screens = [
  HomePage(),
  MedicamentosPage(),
  ConsultasPage(),
  ChatbotPage(),
];
