import 'package:dose_certa/viewmodels/mobile/user_viewmodel.dart';
import 'package:dose_certa/viewmodels/mobile/cuidador_viewmodel.dart';
import 'package:dose_certa/Views/_shared/custom_back_button.dart';
import 'package:dose_certa/Views/_shared/primary_button.dart';
import 'package:dose_certa/Models/services/app_connectivity_service.dart';
import 'package:dose_certa/_Core/theme/app_colors.dart';
import 'package:dose_certa/_Core/theme/app_text_style.dart';
import 'package:dose_certa/_Core/utils/utils.dart';
import 'package:flutter/material.dart';

class CuidadorPage extends StatefulWidget {
  final Widget? tarefasPage;
  final Widget? medicamentosPage;
  final Widget? consultasPage;

  const CuidadorPage({
    super.key,
    this.tarefasPage,
    this.medicamentosPage,
    this.consultasPage,
  });

  @override
  State<CuidadorPage> createState() => _CuidadorPageState();
}

class _CuidadorPageState extends State<CuidadorPage> {
  final _cuidadorviewmodel = CuidadorViewmodel();
  final _userController = UserViewModel();

  late TextEditingController _idController;

  @override
  void initState() {
    _idController = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _idController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.mainBackground,
      appBar: AppBar(
        leading: CustomBackButton(),
        backgroundColor: AppColors.mainBackground,
      ),
      body: RefreshIndicator(
        onRefresh: _handleRefresh,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverFillRemaining(
              hasScrollBody: true,
              child: Builder(builder: (context) => _buildContent()),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleRefresh() async {
    try {
      final user = _userController.currentUser;
      if (user != null) {
        await _userController.loadUser(user.id);
      }
      if (mounted) setState(() {});
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao atualizar: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Widget _buildContent() {
    final user = _userController.currentUser;
    if (user == null) return const SizedBox.shrink();

    if (user.isCuidador) {
      // Cuidador com paciente associado
      if (user.associetedId != null && user.associetedId!.isNotEmpty) {
        return _buildCuidadorInfo();
      }

      // Cuidador sem paciente associado
      return _buildAssociatePaciente();
    }

    // Paciente com cuidador associado
    if (user.associetedId != null && user.associetedId!.isNotEmpty) {
      return _buildMyCuidador();
    }

    //Paciente sem cuidador associado
    return _buildBecomeCuidador();
  }

  Widget _buildAssociatePaciente() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Adicionar Paciente',
            textAlign: TextAlign.center,
            style: AppTextStyles.bold20,
          ),
          const SizedBox(height: 12),
          Text(
            'Adicione um paciente para acompanhar o progresso.',
            textAlign: TextAlign.center,
            style: AppTextStyles.medium14,
          ),
          SizedBox(height: 20),
          Image.asset('assets/images/cuidador.png'),
          SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: TextField(
              controller: _idController,
              decoration: _baseDecoration(label: 'ID do Paciente'),
            ),
          ),
          SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              PrimaryButton(
                text: 'Adicionar Paciente',
                onTap: () {
                  if (_idController.text.isNotEmpty &&
                      AppConnectivity().isConnected!) {
                    _cuidadorviewmodel
                        .becomeCuidador(_idController.text)
                        .then((_) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                "Paciente adicionado!",
                                style: const TextStyle(color: Colors.white),
                              ),
                              backgroundColor: Colors.green,
                            ),
                          );
                          if (context.mounted) {
                            Navigator.pop(context);
                          }
                        })
                        .catchError((error) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                "Erro: ${error}",
                                style: const TextStyle(color: Colors.white),
                              ),
                              backgroundColor: Colors.red,
                            ),
                          );
                        });
                  } else if (_idController.text.isEmpty &&
                      AppConnectivity().isConnected!) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          "Por favor, insira um ID válido",
                          style: const TextStyle(color: Colors.white),
                        ),
                        backgroundColor: Colors.red,
                      ),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          "Sem conexão com a internet",
                          style: const TextStyle(color: Colors.white),
                        ),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBecomeCuidador() {
    return Column(
      children: [
        SizedBox(height: 20),
        Text('Deseja tornar-se um cuidador?', style: AppTextStyles.bold20),
        SizedBox(height: 20),
        Image.asset('assets/images/cuidador.png'),
        SizedBox(height: 20),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: TextField(
            controller: _idController,
            decoration: _baseDecoration(label: 'ID do Paciente'),
          ),
        ),
        SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            PrimaryButton(
              text: 'Tornar-se um cuidador',
              onTap: () {
                if (_idController.text.isNotEmpty &&
                    AppConnectivity().isConnected!) {
                  _cuidadorviewmodel
                      .becomeCuidador(_idController.text)
                      .then((_) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              "Agora você é um cuidador!",
                              style: const TextStyle(color: Colors.white),
                            ),
                            backgroundColor: Colors.green,
                          ),
                        );
                        if (context.mounted) {
                          Navigator.pop(context);
                        }
                      })
                      .catchError((error) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              "Erro ao tornar-se cuidador: $error",
                              style: const TextStyle(color: Colors.white),
                            ),
                            backgroundColor: Colors.red,
                          ),
                        );
                      });
                } else if (_idController.text.isEmpty &&
                    AppConnectivity().isConnected!) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        "Por favor, insira um ID válido",
                        style: const TextStyle(color: Colors.white),
                      ),
                      backgroundColor: Colors.red,
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        "Sem conexão com a internet",
                        style: const TextStyle(color: Colors.white),
                      ),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCuidadorInfo() {
    // Exibe informações do cuidador e, abaixo, as tabs (Tarefas / Medicamentos / Consultas)
    return DefaultTabController(
      length: 3,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Seu paciente designado é: ",
                  style: AppTextStyles.medium16,
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      Utils.capitalizeTitle(
                        _userController.currentUser!.associetedName!,
                      ),
                      style: AppTextStyles.semibold20,
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        minimumSize: const Size(120, 40),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        textStyle: AppTextStyles.medium14,
                      ),
                      onPressed: () {
                        _cuidadorviewmodel
                            .unbindPaciente()
                            .then((_) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    "Paciente desvinculado com sucesso!",
                                    style: const TextStyle(color: Colors.white),
                                  ),
                                  backgroundColor: Colors.green,
                                ),
                              );
                              if (context.mounted) {
                                Navigator.pop(context);
                              }
                            })
                            .catchError((error) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    "Erro ao desvincular paciente: ${error}",
                                    style: const TextStyle(color: Colors.white),
                                  ),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            });
                      },
                      child: Text(
                        'Desvincular',
                        style: AppTextStyles.semibold16.copyWith(
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const Divider(),

          TabBar(
            labelColor: AppColors.mainTextColor,
            unselectedLabelColor: AppColors.gray700,
            tabs: const [
              Tab(text: 'Tarefas'),
              Tab(text: 'Medicamentos'),
              Tab(text: 'Consultas'),
            ],
          ),

          // Conteúdo das tabs
          Expanded(
            child: TabBarView(
              children: [
                widget.tarefasPage ??
                    Center(child: Text('Nenhuma página de tarefas fornecida')),
                widget.medicamentosPage ??
                    Center(
                      child: Text('Nenhuma página de medicamentos fornecida'),
                    ),
                widget.consultasPage ??
                    Center(
                      child: Text('Nenhuma página de consultas fornecida'),
                    ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMyCuidador() {
    return Column(
      children: [
        Text("Seu cuidador", style: AppTextStyles.bold20),
        SizedBox(height: 20),
        Image.asset('assets/images/cuidador.png'),
        SizedBox(height: 40),
        Center(
          child: Text(
            Utils.capitalizeTitle(_userController.currentUser!.associetedName!),
            style: AppTextStyles.semibold20,
          ),
        ),
        SizedBox(height: 40),
        PrimaryButton(
          text: 'Desvincular Cuidador',
          color: Colors.red,
          onTap: () {
            _cuidadorviewmodel
                .unbindCuidador()
                .then((_) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        "Cuidador desvinculado com sucesso!",
                        style: const TextStyle(color: Colors.white),
                      ),
                      backgroundColor: Colors.green,
                    ),
                  );
                  if (context.mounted) {
                    Navigator.pop(context);
                  }
                })
                .catchError((error) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        "Erro ao desvincular cuidador: $error",
                        style: const TextStyle(color: Colors.white),
                      ),
                      backgroundColor: Colors.red,
                    ),
                  );
                });
          },
        ),
      ],
    );
  }

  InputDecoration _baseDecoration({
    String? label,
    String? hint,
    Widget? prefix,
  }) {
    return InputDecoration(
      label: Text(label ?? '', style: AppTextStyles.medium20),
      hintText: hint,
      prefixIcon: prefix,
      floatingLabelBehavior: FloatingLabelBehavior.always,
      filled: true,
      enabledBorder: const OutlineInputBorder(
        borderSide: BorderSide(color: AppColors.gray700),
      ),
      focusedBorder: const OutlineInputBorder(
        borderSide: BorderSide(color: AppColors.blueAccent),
      ),
      fillColor: AppColors.white,
      helperText: 'O ID pode ser encontrado no perfil do paciente.',
    );
  }
}
