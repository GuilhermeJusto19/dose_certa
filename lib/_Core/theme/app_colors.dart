import 'package:flutter/material.dart';

class AppColors {
  // Azuis
  static const Color bluePrimary = Color(0xFF003F88);
  static const Color blueAccent = Color(0xFF1F41BB);
  static const Color blueLight = Color(0xFF66C3E8);
  static const Color blueWhite = Color(0xFFF1F4FF);

  // Cinzas / Neutros
  static const Color grayDarkest = Color(0xFF222B45);
  static const Color mainTextColor = Color(0xFF494949);
  static const Color mainBackground = Color(0xFFE1E1E1);
  static const Color gray800 = Color(0xFF545454);
  static const Color gray700 = Color(0xFF626262);
  static const Color gray600 = Color(0xFF989898);
  static const Color gray500 = Color(0xFF9DB2CE);
  static const Color gray400 = Color(0xFFB1C0D3);
  static const Color gray300 = Color(0xFFBEC5D2);
  static const Color gray200 = Color(0xFFC9D0DA);
  static const Color gray50 = Color(0xFFECECEC);

  // Branco e preto
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);
}

//COMO USAR

// Container(
//   color: AppColors.bluePrimary,
//   child: Text(
//     "Olá",
//     style: AppTextStyles.semibold24.copyWith(color: AppColors.white),
//   ),
// );
