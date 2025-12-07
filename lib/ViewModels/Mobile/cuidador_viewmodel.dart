import 'package:dose_certa/viewmodels/mobile/user_viewmodel.dart';

class CuidadorViewmodel {
  final _userController = UserViewModel();

  Future<void> becomeCuidador(String pacienteId) async {
    await _userController.becomeCuidador(pacienteId);
  }

  Future<void> unbindCuidador() async {
    await _userController.unbindCuidador();
  }

  Future<void> unbindPaciente() async {
    await _userController.unbindPaciente();
  }
}
