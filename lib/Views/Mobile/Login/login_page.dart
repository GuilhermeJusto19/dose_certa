import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:workmanager/workmanager.dart';

import 'package:dose_certa/viewmodels/mobile/user_viewmodel.dart';
import 'package:dose_certa/viewmodels/mobile/user_preferences_viewmodel.dart';
import 'package:dose_certa/Views/_shared/custom_snackbars.dart';
import 'package:dose_certa/Views/_shared/primary_button.dart';
import 'package:dose_certa/Models/services/background_tasks_service.dart';
import 'package:dose_certa/_Core/constants/constants.dart';
import 'package:dose_certa/_Core/theme/app_colors.dart';
import 'package:dose_certa/_Core/theme/app_text_style.dart';

/// Página de Login
///
/// Contém a UI e a lógica de interação para autenticação por email/senha
/// e login via Google. Esta implementação preserva toda a lógica original
/// (chamadas a controllers, validações e navegação). As melhorias aqui
/// são apenas de legibilidade, organização de imports e documentação.
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  /// Controladores de texto para os campos de email e senha.
  /// São inicializados em `initState` e descartados em `dispose`.
  late final TextEditingController _emailController;
  late final TextEditingController _passwordController;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final UserViewModel _userController = UserViewModel();

  bool _obscurePassword = true;

  @override
  void initState() {
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Ink(
        decoration: BoxDecoration(
          image: const DecorationImage(
            image: AssetImage('assets/images/background.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: Align(
          alignment: Alignment.bottomCenter,
          child: SingleChildScrollView(
            child: Container(
              constraints: BoxConstraints(
                minHeight: MediaQuery.of(context).size.height * 0.6,
              ),
              width: double.infinity,
              child: Material(
                borderRadius: BorderRadius.circular(40),
                color: AppColors.white,
                child: Center(
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const SizedBox(height: 20),
                        _buildTitle(),
                        const SizedBox(height: 20),
                        _buildEmailField(),
                        const SizedBox(height: 20),
                        _buildPasswordField(),
                        _buildForgotPasswordButton(),
                        const SizedBox(height: 20),
                        _buildLoginButton(),
                        const SizedBox(height: 20),
                        _buildCreateAccountButton(),
                        const SizedBox(height: 30),
                        _buildOpcaoText(),
                        const SizedBox(height: 20),
                        _buildGoogleButton(),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Título principal da tela.
  Widget _buildTitle() {
    return Text(
      'Entrar',
      style: AppTextStyles.bold25.copyWith(color: AppColors.bluePrimary),
    );
  }

  /// Campo de email com validação.
  Widget _buildEmailField() {
    return SizedBox(
      width: 360,
      child: TextFormField(
        controller: _emailController,
        clipBehavior: Clip.hardEdge,
        decoration: const InputDecoration(
          labelText: 'Email',
          hintText: 'usuario@email.com',
          filled: true,
          fillColor: AppColors.blueWhite,
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide.none,
            borderRadius: BorderRadius.all(Radius.circular(8)),
          ),
          border: OutlineInputBorder(
            borderSide: BorderSide(color: AppColors.blueAccent),
            borderRadius: BorderRadius.all(Radius.circular(8)),
          ),
        ),
        inputFormatters: [LengthLimitingTextInputFormatter(254)],
        validator: (value) => Constants.emailValidator(value),
      ),
    );
  }

  /// Campo de senha com sufixo para alternar visibilidade.
  Widget _buildPasswordField() {
    return SizedBox(
      width: 360,
      child: TextFormField(
        controller: _passwordController,
        clipBehavior: Clip.hardEdge,
        decoration: InputDecoration(
          labelText: 'Senha',
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
        obscureText: _obscurePassword,
        inputFormatters: [LengthLimitingTextInputFormatter(12)],
        validator: (value) => Constants.passwordValidator(value),
      ),
    );
  }

  /// Botão "Esqueci a senha" que abre um diálogo para solicitar
  /// o envio do e-mail de recuperação.
  void _handleForgotPassword() {
    final String? email = _emailController.text.trim();
    final GlobalKey<FormState> dialogFormKey = GlobalKey<FormState>();
    final TextEditingController emailController = TextEditingController(
      text: email,
    );

    showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Center(
            child: Text(
              'Recuperar Senha',
              style: AppTextStyles.semibold20.copyWith(
                color: AppColors.bluePrimary,
              ),
            ),
          ),
          content: Form(
            key: dialogFormKey,
            child: TextFormField(
              controller: emailController,
              decoration: const InputDecoration(labelText: 'Email'),
              validator: (value) => Constants.emailValidator(value),
              autofocus: true,
            ),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Cancelar',
                style: AppTextStyles.medium16.copyWith(color: Colors.red),
              ),
            ),
            TextButton(
              onPressed: () {
                if (emailController.text.isEmpty) {
                  CustomSnackbars().errorSnackbar(
                    message: 'Digite seu email',
                    context: context,
                  );
                  return;
                }
                _userController
                    .resetPassword(emailController.text.trim())
                    .then((_) {
                      if (context.mounted) {
                        CustomSnackbars().successSnackbar(
                          message:
                              'Email de recuperação enviado, confira sua caixa de entrada e spam.',
                          context: context,
                        );
                        Navigator.of(context).pop();
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
              },
              child: Text(
                'Enviar',
                style: AppTextStyles.medium16.copyWith(color: Colors.green),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildForgotPasswordButton() {
    return Padding(
      padding: const EdgeInsets.only(left: 210),
      child: TextButton(
        onPressed: _handleForgotPassword,
        child: Text(
          'Esqueci a senha',
          style: AppTextStyles.semibold15.copyWith(
            color: AppColors.bluePrimary,
          ),
        ),
      ),
    );
  }

  /// Botão de login principal.
  Widget _buildLoginButton() {
    return PrimaryButton(text: 'Login', onTap: _handleLogin);
  }

  /// Realiza login por email/senha usando o `UserController`.
  /// Preserva a lógica original (validations, navegação e chamadas).
  void _handleLogin() {
    if (_formKey.currentState!.validate()) {
      _userController
          .signInWithEmail(
            _emailController.text.trim(),
            _passwordController.text.trim(),
          )
          .then((user) {
            if (user != null && context.mounted) {
              _setFirstLoginPreference();
              _reschduleNotifications();
              Navigator.pushReplacementNamed(context, '/');
            }
          })
          .catchError((error) {
            if (!context.mounted) return;
            CustomSnackbars().errorSnackbar(
              message: (error is FirebaseAuthException) ? error.message : error,
              context: context,
            );
          });
    }
  }

  Widget _buildCreateAccountButton() {
    return PrimaryButton(
      text: 'Criar Conta',
      color: AppColors.white,
      textColor: AppColors.mainTextColor,
      onTap: () => Navigator.pushNamed(context, 'AccountType'),
    );
  }

  Widget _buildOpcaoText() {
    return Text(
      'Ou entre com',
      style: AppTextStyles.semibold15.copyWith(color: AppColors.blueAccent),
    );
  }

  /// Botão/ícone para login via Google. Mantive comportamento original.
  Widget _buildGoogleButton() {
    return Container(
      height: 50,
      width: 70,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: const [
          BoxShadow(
            color: Color.fromARGB(83, 0, 0, 0),
            spreadRadius: 1,
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      alignment: Alignment.center,
      child: IconButton(
        onPressed: _handleGoogleLogin,
        padding: EdgeInsets.zero,
        icon: const Icon(
          Icons.g_mobiledata_outlined,
          size: 40,
          color: Colors.black87,
          semanticLabel: 'Entrar com Google',
        ),
      ),
    );
  }

  /// Realiza o fluxo de login com Google. Mantive todas as chamadas e
  /// verificações originais (credential, isNewUser e navegação).
  void _handleGoogleLogin() {
    _userController
        .signInWithGoogle()
        .then((user) {
          if (user?['credential'] != null &&
              user?['isNewUser'] &&
              context.mounted) {
            Navigator.pushReplacementNamed(
              context,
              'AccountType',
              arguments: {'userCredential': user?['credential']},
            );
          } else if (user?['credential'] != null &&
              !user?['isNewUser'] &&
              context.mounted) {
            _setFirstLoginPreference();
            _reschduleNotifications();
            Navigator.pushReplacementNamed(context, '/');
          }
        })
        .catchError((error) {
          if (!context.mounted) return;
          CustomSnackbars().errorSnackbar(
            message: (error is GoogleSignInException)
                ? (error.description ?? 'Ocorreu um erro desconhecido')
                : error.toString(),
            context: context,
          );
        });
  }

  /// Define a preferência de primeiro acesso em `UserPreferencesController`.
  Future<void> _setFirstLoginPreference() async {
    final prefsController = UserPreferencesViewModel();
    await prefsController.init();
    await prefsController.setFirstAccessFalse();
  }
}

/// Registra uma tarefa única para re-agendar notificações em background.
void _reschduleNotifications() {
  Workmanager().registerOneOffTask(
    'reschedule_notifications',
    BackgroundTasks.rescheduleNotifications,
  );
}
