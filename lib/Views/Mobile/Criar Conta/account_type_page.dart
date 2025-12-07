import 'package:carousel_slider/carousel_slider.dart';
import 'package:dose_certa/Views/_shared/custom_back_button.dart';
import 'package:dose_certa/Views/_shared/primary_button.dart';
import 'package:dose_certa/_Core/theme/app_colors.dart';
import 'package:dose_certa/_Core/theme/app_text_style.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AccountTypePage extends StatefulWidget {
  const AccountTypePage({super.key, this.user});

  final UserCredential? user;

  @override
  State<AccountTypePage> createState() => _AccountTypePageState();
}

class _AccountTypePageState extends State<AccountTypePage> {
  int _currentIndex = 0;

  final List<String> _tiposConta = ['Paciente', 'Cuidador'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: CustomBackButton(),
      ),
      body: Ink(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/background.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: Center(
          child: Column(
            children: [
              SizedBox(height: MediaQuery.of(context).padding.top + 100),
              Text(
                'Selecione o tipo de conta',
                style: AppTextStyles.bold25.copyWith(color: AppColors.white),
              ),
              SizedBox(height: 50),
              CarouselSlider(
                items: [
                  _buidCard('assets/images/paciente.png', 'Paciente'),
                  _buidCard('assets/images/cuidador.png', 'Cuidador'),
                ],
                options: CarouselOptions(
                  height: 400.0,
                  enlargeCenterPage: true,
                  aspectRatio: 9 / 16,
                  viewportFraction: 0.6,
                  onPageChanged: (index, reason) {
                    setState(() {
                      _currentIndex = index;
                    });
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 50),
                child: PrimaryButton(
                  text: 'Selecionar',
                  color: AppColors.white,
                  textColor: AppColors.mainTextColor,
                  onTap: () {
                    final tipoSelecionado = _tiposConta[_currentIndex];
                    Navigator.pushNamed(
                      context,
                      'AddAccount',
                      arguments: {
                        'accountType': tipoSelecionado,
                        'userCredential': widget.user,
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  _buidCard(String imagePath, String label) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Image.asset(imagePath, height: 240, width: 400, fit: BoxFit.fill),
          Padding(
            padding: const EdgeInsets.only(top: 50),
            child: Text(
              label,
              style: AppTextStyles.bold20.copyWith(
                color: AppColors.bluePrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
