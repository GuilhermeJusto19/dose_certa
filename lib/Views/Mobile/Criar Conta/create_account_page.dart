import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:firebase_auth/firebase_auth.dart';

import 'package:dose_certa/viewmodels/mobile/user_viewmodel.dart';
import 'package:dose_certa/viewmodels/mobile/user_preferences_viewmodel.dart';
import 'package:dose_certa/Models/Models/usuario.dart';
import 'package:dose_certa/Views/_shared/custom_back_button.dart';
import 'package:dose_certa/Views/_shared/custom_snackbars.dart';
import 'package:dose_certa/Views/_shared/primary_button.dart';
import 'package:dose_certa/_Core/constants/constants.dart';
import 'package:dose_certa/_Core/theme/app_colors.dart';
import 'package:dose_certa/_Core/theme/app_text_style.dart';

/// Página de criação de conta.
///
/// Contém o formulário para criação de usuário tanto por e-mail/senha
/// quanto via credencial do Google. Mantive a lógica original de validação
/// e chamadas ao `UserController`, apenas melhorei legibilidade, organização
/// de imports e adicionei documentação em PT-BR.
class CreateAccountPage extends StatefulWidget {
  const CreateAccountPage({super.key, required this.accountType, this.user});

  final String accountType;
  final UserCredential? user;

  @override
  State<CreateAccountPage> createState() => _CreateAccountPageState();
}

class _CreateAccountPageState extends State<CreateAccountPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  late final TextEditingController _nameController;
  late final TextEditingController _sobrenomeController;
  late final TextEditingController _emailController;
  late final TextEditingController _passwordController;
  late final TextEditingController _confirmPasswordController;

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  final UserViewModel _userController = UserViewModel();

  @override
  void initState() {
    super.initState();
    String? nome;
    String? email;
    if (widget.user != null && widget.user!.user != null) {
      nome = widget.user!.user!.displayName;
      email = widget.user!.user!.email;
    }

    _nameController = TextEditingController(text: nome ?? '');
    _sobrenomeController = TextEditingController();
    _emailController = TextEditingController(text: email ?? '');
    _passwordController = TextEditingController();
    _confirmPasswordController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _sobrenomeController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: const CustomBackButton(),
      ),
      body: Ink(
        decoration: _buildBackgroundDecoration(),
        child: Center(
          child: Form(
            key: _formKey,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: SingleChildScrollView(
                reverse: true,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildTitle(),
                    _buildSubtitle(),
                    const SizedBox(height: 20),
                    _buildFormFields(),
                    const SizedBox(height: 30),
                    _buildSubmitButton(),
                    const SizedBox(height: 10),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  BoxDecoration _buildBackgroundDecoration() {
    return const BoxDecoration(
      image: DecorationImage(
        image: AssetImage('assets/images/background.png'),
        fit: BoxFit.cover,
      ),
    );
  }

  Widget _buildTitle() {
    return Center(
      child: Text(
        'Criar Conta',
        style: AppTextStyles.bold25.copyWith(color: AppColors.white),
      ),
    );
  }

  Widget _buildSubtitle() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 24),
      child: Text(
        'Crie sua conta para poder aproveitar os benefícios do aplicativo',
        textAlign: TextAlign.center,
        style: AppTextStyles.medium14.copyWith(color: AppColors.white),
      ),
    );
  }

  Widget _buildFormFields() {
    return Container(
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(20)),
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          const SizedBox(height: 30),
          _buildNameField(),
          const SizedBox(height: 30),
          _buildSobrenomeField(),
          const SizedBox(height: 30),
          _buildEmailField(),
          const SizedBox(height: 30),
          _buildPasswordField(),
          const SizedBox(height: 30),
          _buildConfirmPasswordField(),
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  /// Retorna uma `InputDecoration` padronizada para os campos do formulário.
  ///
  /// Aceita label e um hint opcional; mantém o mesmo visual usado anteriormente
  /// para evitar qualquer alteração de comportamento ou aparência.
  InputDecoration _fieldDecoration(String label, {String? hint}) {
    return InputDecoration(
      labelText: label,
      floatingLabelBehavior: FloatingLabelBehavior.never,
      hintText: hint,
      filled: true,
      fillColor: AppColors.blueWhite,
      enabledBorder: const OutlineInputBorder(
        borderSide: BorderSide.none,
        borderRadius: BorderRadius.all(Radius.circular(8)),
      ),
      border: const OutlineInputBorder(
        borderSide: BorderSide(color: AppColors.blueAccent),
        borderRadius: BorderRadius.all(Radius.circular(8)),
      ),
    );
  }

  Widget _buildNameField() {
    return TextFormField(
      controller: _nameController,
      clipBehavior: Clip.hardEdge,
      decoration: _fieldDecoration('Nome'),
      inputFormatters: [LengthLimitingTextInputFormatter(50)],
      validator: (value) => Constants.nameValidator(value),
    );
  }

  Widget _buildSobrenomeField() {
    return TextFormField(
      controller: _sobrenomeController,
      clipBehavior: Clip.hardEdge,
      decoration: _fieldDecoration('Sobrenome'),
      inputFormatters: [LengthLimitingTextInputFormatter(100)],
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Digite seu sobrenome';
        }
        final nameRegExp = RegExp(r'^[A-Za-zÀ-ÖØ-öø-ÿ\s]+$');
        if (!nameRegExp.hasMatch(value)) {
          return 'O nome deve conter apenas letras';
        }
        return null;
      },
    );
  }

  Widget _buildEmailField() {
    return TextFormField(
      controller: _emailController,
      clipBehavior: Clip.hardEdge,
      decoration: _fieldDecoration('Email', hint: 'usuario@email.com'),
      inputFormatters: [LengthLimitingTextInputFormatter(254)],
      validator: (value) => Constants.emailValidator(value),
    );
  }

  Widget _buildPasswordField() {
    return TextFormField(
      controller: _passwordController,
      obscureText: _obscurePassword,
      decoration: _fieldDecoration('Senha').copyWith(
        suffixIcon: IconButton(
          icon: Icon(
            _obscurePassword ? Icons.visibility_off : Icons.visibility,
            color: Colors.grey,
          ),
          onPressed: () {
            setState(() {
              _obscurePassword = !_obscurePassword;
            });
          },
        ),
      ),
      inputFormatters: [LengthLimitingTextInputFormatter(12)],
      validator: (value) => Constants.passwordValidator(value),
    );
  }

  Widget _buildConfirmPasswordField() {
    return TextFormField(
      controller: _confirmPasswordController,
      obscureText: _obscureConfirmPassword,
      decoration: _fieldDecoration('Confirmar Senha').copyWith(
        suffixIcon: IconButton(
          icon: Icon(
            _obscureConfirmPassword ? Icons.visibility_off : Icons.visibility,
            color: Colors.grey,
          ),
          onPressed: () {
            setState(() {
              _obscureConfirmPassword = !_obscureConfirmPassword;
            });
          },
        ),
      ),
      inputFormatters: [LengthLimitingTextInputFormatter(12)],
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Confirme sua senha';
        }
        if (value != _passwordController.text) {
          return 'As senhas não coincidem';
        }
        return null;
      },
    );
  }

  Widget _buildSubmitButton() {
    return PrimaryButton(
      text: 'Criar',
      color: AppColors.blueAccent,
      onTap: () {
        if (_formKey.currentState!.validate()) {
          final Usuario user = Usuario(
            id: '',
            name: _nameController.text.trim().toLowerCase(),
            sobrenome: _sobrenomeController.text.trim().toLowerCase(),
            email: _emailController.text.trim(),
            isCuidador: widget.accountType == 'Cuidador',
            associetedId: null,
            hasClinica: false,
            associetedClinica: null,
            photoURL: widget.user?.user?.photoURL,
            via: (widget.user != null && widget.user!.user != null)
                ? 'google'
                : 'email',
            createdAt: DateTime.now(),
          );

          if (widget.user != null) {
            _userController
                .registerUserWithGoogle(user, widget.user!)
                .then((result) {
                  if (result == true && context.mounted) {
                    _setFirstLoginPreference();
                    Navigator.pushReplacementNamed(context, '/');
                  }
                })
                .catchError((error) {
                  if (!context.mounted) return;
                  CustomSnackbars().errorSnackbar(
                    message: (error is FirebaseAuthException)
                        ? (error.message ?? 'Ocorreu um erro desconhecido')
                        : error.toString(),
                    context: context,
                  );
                });
          } else {
            _userController
                .registerWithEmail(user, _passwordController.text.trim())
                .then((user) {
                  if (user != null && context.mounted) {
                    _setFirstLoginPreference();
                    Navigator.pushReplacementNamed(context, '/');
                  }
                })
                .catchError((error) {
                  if (!context.mounted) return;
                  CustomSnackbars().errorSnackbar(
                    message: (error is FirebaseAuthException)
                        ? error.message
                        : error,
                    context: context,
                  );
                });
          }
        }
      },
    );
  }

  Future<void> _setFirstLoginPreference() async {
    final prefsController = UserPreferencesViewModel();
    await prefsController.setFirstAccessFalse();
  }
}
