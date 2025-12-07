import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:dose_certa/viewmodels/mobile/clinica_viewmodel.dart';
import 'package:dose_certa/Models/Models/doutor.dart';
import 'package:dose_certa/Models/Models/paciente.dart';
import 'package:dose_certa/Models/Repositories/doutor_repository_imp.dart';
import 'package:dose_certa/Models/Repositories/paciente_repository_imp.dart';

class HomeViewmodel extends ChangeNotifier {
  final DoutorRepositoryImp _repository;
  final PacienteRepositoryImp _pacienteRepository;
  final ClinicaViewModel _clinicaController;

  HomeViewmodel({
    DoutorRepositoryImp? repository,
    PacienteRepositoryImp? pacienteRepository,
    ClinicaViewModel? clinicaController,
  }) : _repository = repository ?? DoutorRepositoryImp(),
       _pacienteRepository = pacienteRepository ?? PacienteRepositoryImp(),
       _clinicaController = clinicaController ?? ClinicaViewModel();

  List<Doutor> _doutores = [];
  List<Paciente> _pacientes = [];
  bool _isLoading = false;
  StreamSubscription<List<Doutor>>? _doutorSubscription;
  StreamSubscription<List<Paciente>>? _pacienteSubscription;

  List<Doutor> get doutores => _doutores;
  List<Paciente> get pacientes => _pacientes;
  bool get isLoading => _isLoading;

  Future<void> addDoutor(Doutor doutor) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _repository.addDoutor(doutor);
      // Não adiciona localmente - o stream vai atualizar automaticamente
      notifyListeners();
    } catch (e) {
      final msg = e.toString().toLowerCase();
      final isOfflineError =
          msg.contains('timeout') ||
          msg.contains('timed out') ||
          msg.contains('socketexception');

      if (!isOfflineError) {
        throw Exception('Erro ao adicionar doutor: $e');
      }
      if (kDebugMode) print('Operação offline: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> editDoutor(Doutor doutor) async {
    _isLoading = true;
    notifyListeners();

    try {
      // Não atualiza localmente - o stream vai atualizar automaticamente
      await _repository.editDoutor(doutor);
      notifyListeners();
    } catch (e) {
      final msg = e.toString().toLowerCase();
      final isOfflineError =
          msg.contains('timeout') ||
          msg.contains('timed out') ||
          msg.contains('socketexception');

      if (!isOfflineError) {
        throw Exception('Erro ao editar doutor: $e');
      }
      if (kDebugMode) print('Operação offline: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteDoutor(String id) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _repository.deleteDoutor(id);
      // Não remove localmente - o stream vai atualizar automaticamente
      notifyListeners();
    } catch (e) {
      throw Exception('Erro ao deletar doutor: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void loadDoutores({String? userId}) {
    _doutorSubscription?.cancel();
    _doutorSubscription = _repository
        .getDoutors(userId: userId)
        .listen(
          (List<Doutor> newRecords) {
            _doutores = newRecords;
            notifyListeners();
          },
          onError: (error) {
            if (kDebugMode) print('Erro ao carregar doutores: $error');
          },
        );
  }

  void loadPacientes({String? userId}) {
    _pacienteSubscription?.cancel();
    _pacienteSubscription = _pacienteRepository
        .getPacientes(userId: userId)
        .listen(
          (List<Paciente> newRecords) {
            _pacientes = newRecords;
            notifyListeners();
          },
          onError: (error) {
            if (kDebugMode) print('Erro ao carregar pacientes: $error');
          },
        );
  }

  @override
  void dispose() {
    _doutorSubscription?.cancel();
    _pacienteSubscription?.cancel();
    super.dispose();
  }

  /// Associa um usuário como paciente da clínica.
  ///
  /// Usa o [ClinicaController] para criar um paciente baseado no usuário
  /// e atualizar os campos de associação.
  Future<void> associatePaciente(String usuarioId) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _clinicaController.associateUsuario(usuarioId);
      notifyListeners();
    } catch (e) {
      throw Exception('Erro ao associar paciente: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deletePaciente(String id) async {
    _isLoading = true;
    notifyListeners();

    try {
      // Desassocia o paciente usando o ClinicaController
      await _clinicaController.desassociateUsuario(id);
      notifyListeners();
    } catch (e) {
      throw Exception('Erro ao deletar paciente: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
