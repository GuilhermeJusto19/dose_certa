import 'package:dose_certa/viewmodels/mobile/user_viewmodel.dart';
import 'package:dose_certa/Views/_shared/custom_back_button.dart';
import 'package:dose_certa/Views/_shared/custom_snackbars.dart';
import 'package:dose_certa/Views/_shared/primary_button.dart';
import 'package:dose_certa/_Core/constants/constants.dart';
import 'package:dose_certa/_Core/theme/app_colors.dart';
import 'package:dose_certa/_Core/theme/app_text_style.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class UserEditPage extends StatefulWidget {
  const UserEditPage({super.key});

  @override
  State<UserEditPage> createState() => _UserEditPageState();
}

class _UserEditPageState extends State<UserEditPage> {
  final _userController = UserViewModel();

  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _sobrenomeController;
  late TextEditingController _emailController;
  late TextEditingController _idContoller;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(
      text: _userController.currentUser?.name ?? '',
    );
    _sobrenomeController = TextEditingController(
      text: _userController.currentUser?.sobrenome ?? '',
    );
    _emailController = TextEditingController(
      text: _userController.currentUser?.email ?? '',
    );
    _idContoller = TextEditingController(
      text: _userController.currentUser?.id ?? '',
    );
  }

  late String name = _userController.currentUser?.name ?? 'Usuário';
  late String? photoURL = _userController.currentUser?.photoURL;
  late String id = _userController.currentUser?.id ?? '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.mainBackground,
      appBar: AppBar(
        leading: CustomBackButton(),
        title: Text(
          "Editar Perfil",
          style: AppTextStyles.semibold24.copyWith(
            color: AppColors.mainTextColor,
          ),
        ),
        backgroundColor: AppColors.mainBackground,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(30, 16, 30, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [_buildContent()],
        ),
      ),
    );
  }

  Widget _buildContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        CircleAvatar(
          radius: 40,
          backgroundColor: AppColors.gray200,
          backgroundImage: (photoURL != null && photoURL!.isNotEmpty)
              ? NetworkImage(photoURL!)
              : null,
          child: (photoURL == null || photoURL!.isEmpty)
              ? Icon(Icons.person, size: 30)
              : null,
        ),
        SizedBox(height: 20),
        Form(
          key: _formKey,
          child: Column(
            children: [
              _buildTextField(
                controller: _nameController,
                label: 'Nome',
                validator: (v) =>
                    v == null || v.isEmpty ? 'Digite seu nome' : null,
              ),
              SizedBox(height: 20),
              _buildTextField(
                controller: _sobrenomeController,
                label: 'Sobrenome',
                validator: (v) =>
                    v == null || v.isEmpty ? 'Digite seu sobrenome' : null,
              ),
              SizedBox(height: 20),
              _buildTextField(
                controller: _emailController,
                label: 'Email',
                validator: (v) {
                  Constants.emailValidator(v);
                  return null;
                },
              ),
              SizedBox(height: 20),
              _buildReadOnlyField(controller: _idContoller, label: 'ID'),
              SizedBox(height: 40),
              PrimaryButton(text: 'Salvar', onTap: _onSavePressed),
              SizedBox(height: 20),
              PrimaryButton(
                text: 'Deletar Conta',
                onTap: _onDeletPressed,
                color: Colors.red,
              ),
            ],
          ),
        ),
      ],
    );
  }

  _onDeletPressed() {
    // Substitui o diálogo simples por um formulário de revalidação:
    // - Solicita email e senha do usuário para reautenticação (sign-in)
    // - Em caso de sucesso, prossegue com a remoção da conta
    // - Em caso de erro, exibe snackbar com a mensagem retornada
    final parentContext = context;
    final _dialogFormKey = GlobalKey<FormState>();
    final TextEditingController _dialogEmailController = TextEditingController(
      text: _emailController.text,
    );
    final TextEditingController _dialogPasswordController =
        TextEditingController();

    showDialog(
      context: parentContext,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Revalidação antes da deleção'),
          content: Form(
            key: _dialogFormKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Para confirmar a exclusão definitiva da conta, revalide suas credenciais.',
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _dialogEmailController,
                  decoration: _baseDecoration(label: 'Email'),
                  validator: (v) =>
                      v == null || v.isEmpty ? 'Digite seu email' : null,
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _dialogPasswordController,
                  obscureText: true,
                  decoration: _baseDecoration(label: 'Senha'),
                  validator: (v) =>
                      v == null || v.isEmpty ? 'Digite sua senha' : null,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () async {
                // Validação do formulário
                if (!_dialogFormKey.currentState!.validate()) return;

                final String email = _dialogEmailController.text.trim();
                final String password = _dialogPasswordController.text;

                try {
                  // Reautentica usando o método existente no UserController
                  final credential = await _userController.signInWithEmail(
                    email,
                    password,
                  );
                  if (credential == null) {
                    // Caso inesperado: credential null
                    if (!parentContext.mounted) return;
                    CustomSnackbars().errorSnackbar(
                      message: 'Falha na revalidação. Tente novamente.',
                      context: parentContext,
                    );
                    return;
                  }

                  // Se reautenticação bem-sucedida, prossegue com a deleção
                  await _userController.deleteAccount();

                  if (!dialogContext.mounted) return;
                  Navigator.of(dialogContext).pop();
                  if (!parentContext.mounted) return;
                  CustomSnackbars().successSnackbar(
                    message: 'Conta deletada com sucesso!',
                    context: parentContext,
                  );
                  Navigator.pushNamedAndRemoveUntil(
                    parentContext,
                    'Login',
                    (route) => false,
                  );
                } on FirebaseAuthException catch (e) {
                  // Erro de autenticação explícito
                  if (!dialogContext.mounted) return;
                  CustomSnackbars().errorSnackbar(
                    message: e.message ?? 'Erro de autenticação',
                    context: parentContext,
                  );
                } catch (e) {
                  // Outros erros
                  if (!dialogContext.mounted) return;
                  CustomSnackbars().errorSnackbar(
                    message: 'Erro ao deletar conta: $e',
                    context: parentContext,
                  );
                }
              },
              child: const Text(
                'Validar e Deletar',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }

  _onSavePressed() {
    if (_formKey.currentState!.validate()) {
      _userController
          .updateUser(
            _userController.currentUser!.copyWith(
              name: _nameController.text,
              sobrenome: _sobrenomeController.text,
              email: _emailController.text,
            ),
          )
          .then((_) {
            if (!context.mounted) return;
            CustomSnackbars().successSnackbar(
              message: 'Perfil atualizado com sucesso!',
              context: context,
            );
          })
          .catchError((error) {
            if (!context.mounted) return;
            CustomSnackbars().errorSnackbar(
              message: 'Erro ao atualizar perfil: $error',
              context: context,
            );
          });
    }
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    String? hint,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      clipBehavior: Clip.hardEdge,
      decoration: _baseDecoration(label: label, hint: hint),
      validator: validator,
    );
  }

  Widget _buildReadOnlyField({
    required TextEditingController controller,
    required String label,
    Widget? prefix,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      readOnly: true,
      decoration: _baseDecoration(label: label, prefix: prefix),
      validator: validator,
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
    );
  }
}
