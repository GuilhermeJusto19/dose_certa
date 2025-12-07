import 'package:dose_certa/Views/_shared/custom_back_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:firebase_auth/firebase_auth.dart';

import 'package:dose_certa/viewmodels/mobile/clinica_viewmodel.dart';
import 'package:dose_certa/Models/Models/clinica.dart';
import 'package:dose_certa/Views/_shared/custom_snackbars.dart';
import 'package:dose_certa/_Core/constants/constants.dart';
import 'package:dose_certa/_Core/theme/app_colors.dart';
import 'package:dose_certa/_Core/theme/app_text_style.dart';

/// Página de criação de conta da clínica.
///
/// Contém o formulário para cadastro de clínica com campos específicos:
/// nome, CNPJ, endereço, telefone, email e senha.
class CreateAccountPage extends StatefulWidget {
  const CreateAccountPage({super.key, this.user});

  final UserCredential? user;

  @override
  State<CreateAccountPage> createState() => _CreateAccountPageState();
}

class _CreateAccountPageState extends State<CreateAccountPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  late final TextEditingController _nameController;
  late final TextEditingController _cnpjController;
  late final TextEditingController _addressController;
  late final TextEditingController _phoneController;
  late final TextEditingController _emailController;
  late final TextEditingController _passwordController;
  late final TextEditingController _confirmPasswordController;

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  final ClinicaViewModel _clinicaController = ClinicaViewModel();

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _cnpjController = TextEditingController();
    _addressController = TextEditingController();
    _phoneController = TextEditingController();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
    _confirmPasswordController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _cnpjController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bluePrimary,
      appBar: AppBar(leading: CustomBackButton()),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(vertical: 40),
          child: Center(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 600),
              margin: const EdgeInsets.symmetric(horizontal: 24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Form(
                key: _formKey,
                child: Padding(
                  padding: const EdgeInsets.all(48.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildTitle(),
                      const SizedBox(height: 12),
                      _buildSubtitle(),
                      const SizedBox(height: 40),
                      _buildFormFields(),
                      const SizedBox(height: 32),
                      _buildSubmitButton(),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTitle() {
    return Text(
      'Cadastro de Clínica',
      textAlign: TextAlign.center,
      style: AppTextStyles.bold25.copyWith(
        color: AppColors.bluePrimary,
        fontSize: 32,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildSubtitle() {
    return Text(
      'Cadastre sua clínica para gerenciar pacientes e medicamentos',
      textAlign: TextAlign.center,
      style: AppTextStyles.medium14.copyWith(
        color: AppColors.gray600,
        fontSize: 16,
      ),
    );
  }

  Widget _buildFormFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildNameField(),
        const SizedBox(height: 20),
        _buildCnpjField(),
        const SizedBox(height: 20),
        _buildAddressField(),
        const SizedBox(height: 20),
        _buildPhoneField(),
        const SizedBox(height: 20),
        _buildEmailField(),
        const SizedBox(height: 20),
        _buildPasswordField(),
        const SizedBox(height: 20),
        _buildConfirmPasswordField(),
      ],
    );
  }

  /// Retorna uma `InputDecoration` padronizada para os campos do formulário.
  InputDecoration _fieldDecoration(String label, {String? hint}) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      labelStyle: const TextStyle(color: AppColors.gray600, fontSize: 16),
      hintStyle: TextStyle(
        color: AppColors.gray600.withOpacity(0.6),
        fontSize: 14,
      ),
      filled: true,
      fillColor: Colors.grey[50],
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Colors.grey[300]!, width: 1),
        borderRadius: BorderRadius.circular(12),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: AppColors.blueAccent, width: 2),
        borderRadius: BorderRadius.circular(12),
      ),
      errorBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: Colors.red, width: 1),
        borderRadius: BorderRadius.circular(12),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: Colors.red, width: 2),
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }

  Widget _buildNameField() {
    return TextFormField(
      controller: _nameController,
      clipBehavior: Clip.hardEdge,
      decoration: _fieldDecoration('Nome da Clínica'),
      inputFormatters: [LengthLimitingTextInputFormatter(100)],
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Digite o nome da clínica';
        }
        return null;
      },
    );
  }

  Widget _buildCnpjField() {
    return TextFormField(
      controller: _cnpjController,
      clipBehavior: Clip.hardEdge,
      decoration: _fieldDecoration('CNPJ', hint: '00.000.000/0000-00'),
      keyboardType: TextInputType.number,
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
        LengthLimitingTextInputFormatter(14),
      ],
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Digite o CNPJ';
        }
        if (value.length != 14) {
          return 'CNPJ deve ter 14 dígitos';
        }
        return null;
      },
    );
  }

  Widget _buildAddressField() {
    return TextFormField(
      controller: _addressController,
      clipBehavior: Clip.hardEdge,
      decoration: _fieldDecoration('Endereço'),
      inputFormatters: [LengthLimitingTextInputFormatter(200)],
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Digite o endereço';
        }
        return null;
      },
    );
  }

  Widget _buildPhoneField() {
    return TextFormField(
      controller: _phoneController,
      clipBehavior: Clip.hardEdge,
      decoration: _fieldDecoration('Telefone', hint: '(00) 00000-0000'),
      keyboardType: TextInputType.phone,
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
        LengthLimitingTextInputFormatter(11),
      ],
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Digite o telefone';
        }
        if (value.length < 10) {
          return 'Telefone inválido';
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
    return SizedBox(
      height: 56,
      child: ElevatedButton(
        onPressed: () {
          if (_formKey.currentState!.validate()) {
            final Clinica clinica = Clinica(
              id: '',
              name: _nameController.text.trim(),
              cnpj: _cnpjController.text.trim(),
              address: _addressController.text.trim(),
              phone: _phoneController.text.trim(),
              email: _emailController.text.trim(),
              createdAt: DateTime.now(),
            );

            _clinicaController
                .registerWithEmail(clinica, _passwordController.text.trim())
                .then((credential) {
                  if (credential != null && context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Clínica cadastrada com sucesso!'),
                        backgroundColor: Colors.green,
                        duration: Duration(seconds: 3),
                      ),
                    );
                    Navigator.pushReplacementNamed(context, '/home');
                  }
                })
                .catchError((error) {
                  if (!context.mounted) return;

                  String errorMessage = error.toString();
                  if (errorMessage.startsWith('Exception: ')) {
                    errorMessage = errorMessage.substring(11);
                  }

                  CustomSnackbars().errorSnackbar(
                    message: errorMessage,
                    context: context,
                  );
                });
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.blueAccent,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: const Text(
          'Cadastrar Clínica',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}
