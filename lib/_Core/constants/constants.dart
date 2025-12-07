import 'package:flutter_dotenv/flutter_dotenv.dart';

class Constants {

  //!API KEY OPENAI !//
  static String? openaiApiKey = dotenv.env['CHAT_KEY'];

  //! Validações de Formulários !//
  static String? emailValidator(String? value) {
    if (value == null || value.isEmpty) {
      return 'Digite seu email';
    }
    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
    if (!emailRegex.hasMatch(value)) {
      return 'Digite um email válido';
    }
    return null;
  }

  static String? passwordValidator(String? value) {
    if (value == null || value.isEmpty) {
      return 'Digite sua senha';
    }
    if (value.length < 6 || value.length > 12) {
      return 'A senha deve entre 6 e 12 caracteres';
    }
    return null;
  }

  static String? nameValidator(String? value) {
    if (value == null || value.isEmpty) {
      return 'Digite seu nome';
    }
    final nameRegExp = RegExp(r'^[A-Za-zÀ-ÖØ-öø-ÿ\s]+$');
    if (!nameRegExp.hasMatch(value)) {
      return 'O nome deve conter apenas letras';
    }
    if (value.length < 2 || value.length > 50) {
      return 'O nome deve ter entre 2 e 50 caracteres';
    }
    return null;
  }

  //! Opções de Seleção Medicamento!//
  static List<String> frequencyOptions = [
    'Diariamente',
    'A cada X horas',
    'X vezes ao dia',
    'Dias específicos da semana',
  ];

  static List<String> weekDaysOptions = [
    "Seg",
    "Ter",
    "Qua",
    "Qui",
    "Sex",
    "Sáb",
    "Dom",
  ];

  static List<String> unitsOptions = [
    //Formas sólidas
    'comprimido(s)',
    'cápsula(s)',
    'tablete(s)',
    'pílula(s)',
    'pastilha(s)',

    //Formas líquidas
    'mililitro(s)',
    'litro(s)',
    'gota(s)',
    'dose(s)',

    //Unidades de massa
    'micrograma(s)',
    'miligrama(s)',
    'grama(s)',
    'quilograma(s)',

    //Outras medidas
    'unidade(s)',
    'injeção(ões)',
    'ampola(s)',
    'aplicação(ões)',
    'dose(s)',
  ];
}
